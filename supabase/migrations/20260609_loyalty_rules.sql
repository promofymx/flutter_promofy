-- ═══════════════════════════════════════════════════════════════════
-- Reglas configurables del programa de lealtad
--   • one_per_day          → máx. 1 sello por día por cliente
--   • min_ticket_mxn       → consumo mínimo (0 = sin regla)
--   • min_hours_between    → horas mínimas entre sellos (0 = sin regla)
--   • stamp_validity_days  → los sellos en curso vencen tras N días sin visita
--   • reward_validity_days → la recompensa lista vence tras N días sin canjear
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE public.loyalty_programs
  ADD COLUMN IF NOT EXISTS one_per_day          boolean       NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS min_ticket_mxn       numeric(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS min_hours_between    int           NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS stamp_validity_days  int           NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS reward_validity_days int           NOT NULL DEFAULT 0;

ALTER TABLE public.stamp_cards
  ADD COLUMN IF NOT EXISTS reward_ready_at timestamptz;

-- ─── record_loyalty_visit: valida reglas activas y acepta monto de ticket ───
CREATE OR REPLACE FUNCTION public.record_loyalty_visit(
  p_program_id    uuid,
  p_client_id     uuid,
  p_ticket_amount numeric DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_program      loyalty_programs%ROWTYPE;
  v_card         stamp_cards%ROWTYPE;
  v_last_visit   timestamptz;
  v_today        date := (now() AT TIME ZONE 'America/Mexico_City')::date;
  v_new_prog     int;
  v_new_life     int;
  v_reward_ready bool := false;
  v_visit_id     uuid;
BEGIN
  -- Programa activo y vigente
  SELECT * INTO v_program
  FROM loyalty_programs
  WHERE id = p_program_id AND is_active = true
    AND starts_at <= now() AND ends_at >= now();
  IF NOT FOUND THEN
    RETURN json_build_object('ok', false, 'error', 'program_inactive');
  END IF;

  -- Caller dueño del establecimiento
  IF NOT EXISTS (
    SELECT 1 FROM establishments
    WHERE id = v_program.establishment_id AND owner_id = auth.uid()
  ) THEN
    RETURN json_build_object('ok', false, 'error', 'unauthorized');
  END IF;

  -- ── Regla: consumo mínimo ────────────────────────────────────────
  IF v_program.min_ticket_mxn > 0 THEN
    IF p_ticket_amount IS NULL OR p_ticket_amount < v_program.min_ticket_mxn THEN
      RETURN json_build_object('ok', false, 'error', 'min_ticket',
                               'min_ticket', v_program.min_ticket_mxn);
    END IF;
  END IF;

  -- Última visita del cliente en este programa
  SELECT max(created_at) INTO v_last_visit
  FROM loyalty_visit_log
  WHERE program_id = p_program_id AND client_id = p_client_id;

  -- ── Regla: máx. 1 sello por día (zona horaria MX) ────────────────
  IF v_program.one_per_day AND v_last_visit IS NOT NULL THEN
    IF (v_last_visit AT TIME ZONE 'America/Mexico_City')::date = v_today THEN
      RETURN json_build_object('ok', false, 'error', 'already_today');
    END IF;
  END IF;

  -- ── Regla: tiempo mínimo entre sellos ────────────────────────────
  IF v_program.min_hours_between > 0 AND v_last_visit IS NOT NULL THEN
    IF now() < v_last_visit + make_interval(hours => v_program.min_hours_between) THEN
      RETURN json_build_object(
        'ok', false, 'error', 'too_soon',
        'wait_minutes',
          CEIL(EXTRACT(EPOCH FROM
            (v_last_visit + make_interval(hours => v_program.min_hours_between) - now())
          ) / 60)
      );
    END IF;
  END IF;

  -- Tarjeta existente
  SELECT * INTO v_card
  FROM stamp_cards
  WHERE user_id = p_client_id AND program_id = p_program_id;

  IF v_card.id IS NULL THEN
    -- Nueva tarjeta
    v_new_prog := 1;
    v_new_life := 1;
    INSERT INTO stamp_cards
      (user_id, program_id, program_visits, lifetime_visits, updated_at, reward_ready_at)
    VALUES
      (p_client_id, p_program_id, v_new_prog, v_new_life, now(),
       CASE WHEN v_new_prog >= v_program.visits_required THEN now() ELSE NULL END);
  ELSE
    v_new_life := v_card.lifetime_visits + 1;

    -- ── Regla: vigencia de sellos (reinicia ciclo en curso si venció) ──
    IF v_program.stamp_validity_days > 0
       AND NOT v_card.reward_claimed
       AND v_card.program_visits < v_program.visits_required
       AND v_last_visit IS NOT NULL
       AND v_last_visit < now() - make_interval(days => v_program.stamp_validity_days) THEN
      v_new_prog := 1;
    ELSE
      v_new_prog := v_card.program_visits + 1;
    END IF;

    UPDATE stamp_cards
    SET program_visits  = v_new_prog,
        lifetime_visits = v_new_life,
        updated_at      = now(),
        reward_ready_at = CASE
          WHEN v_new_prog >= v_program.visits_required AND v_card.reward_ready_at IS NULL THEN now()
          WHEN v_new_prog <  v_program.visits_required THEN NULL
          ELSE v_card.reward_ready_at
        END
    WHERE id = v_card.id;
  END IF;

  v_reward_ready := v_new_prog >= v_program.visits_required;

  -- Registrar visita (con monto si se capturó)
  INSERT INTO loyalty_visit_log (program_id, client_id, establishment_id, ticket_amount)
  VALUES (p_program_id, p_client_id, v_program.establishment_id, p_ticket_amount)
  RETURNING id INTO v_visit_id;

  RETURN json_build_object(
    'ok',              true,
    'visit_id',        v_visit_id,
    'program_visits',  v_new_prog,
    'lifetime_visits', v_new_life,
    'visits_required', v_program.visits_required,
    'reward_ready',    v_reward_ready
  );
END;
$function$;

-- ─── claim_loyalty_reward: respeta la vigencia de la recompensa ─────
CREATE OR REPLACE FUNCTION public.claim_loyalty_reward(
  p_program_id uuid,
  p_client_id  uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_caller_id uuid := auth.uid();
  v_card      stamp_cards%ROWTYPE;
  v_program   loyalty_programs%ROWTYPE;
BEGIN
  SELECT lp.* INTO v_program
  FROM loyalty_programs lp
  JOIN establishments e ON e.id = lp.establishment_id
  WHERE lp.id = p_program_id AND e.owner_id = v_caller_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', 'unauthorized');
  END IF;

  SELECT * INTO v_card
  FROM stamp_cards
  WHERE user_id = p_client_id AND program_id = p_program_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', 'card_not_found');
  END IF;

  IF v_card.program_visits < v_program.visits_required THEN
    RETURN jsonb_build_object('ok', false, 'error', 'not_enough_visits');
  END IF;

  IF v_card.reward_claimed THEN
    RETURN jsonb_build_object('ok', false, 'error', 'already_claimed');
  END IF;

  -- ── Regla: vigencia de la recompensa ─────────────────────────────
  IF v_program.reward_validity_days > 0
     AND v_card.reward_ready_at IS NOT NULL
     AND now() > v_card.reward_ready_at + make_interval(days => v_program.reward_validity_days) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'reward_expired');
  END IF;

  UPDATE stamp_cards
  SET reward_claimed = true, updated_at = now()
  WHERE id = v_card.id;

  RETURN jsonb_build_object('ok', true);
END;
$function$;
