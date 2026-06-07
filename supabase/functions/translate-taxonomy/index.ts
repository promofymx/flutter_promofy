// ════════════════════════════════════════════════════════════════════════════
// translate-taxonomy
//
// Auto-traduce el campo `name` de las tablas `categories` y `characteristics`
// a inglés (name_en) y alemán (name_de) usando DeepL.
//
// Se invoca vía Database Webhook (AFTER INSERT/UPDATE). Para evitar bucles
// infinitos, solo traduce cuando:
//   - es un INSERT, o
//   - es un UPDATE en el que `name` cambió.
// (La propia actualización que hace esta función NO cambia `name`, así que el
//  webhook que dispara se ignora.)
//
// Requiere el secreto DEEPL_API_KEY (clave del plan Free, termina en ":fx").
// SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los inyecta Supabase automáticamente.
// ════════════════════════════════════════════════════════════════════════════

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const DEEPL_KEY = Deno.env.get("DEEPL_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Las keys Free usan api-free; las Pro usan api. Detectamos por el sufijo ":fx".
const DEEPL_ENDPOINT = DEEPL_KEY.endsWith(":fx")
  ? "https://api-free.deepl.com/v2/translate"
  : "https://api.deepl.com/v2/translate";

function ok(body: unknown = { ok: true }) {
  return new Response(JSON.stringify(body), {
    headers: { "Content-Type": "application/json" },
  });
}

async function translate(text: string, target: string): Promise<string> {
  const res = await fetch(DEEPL_ENDPOINT, {
    method: "POST",
    headers: {
      Authorization: `DeepL-Auth-Key ${DEEPL_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      text: [text],
      source_lang: "ES",
      target_lang: target, // "EN-US" | "DE"
    }),
  });
  if (!res.ok) {
    console.error("DeepL error", res.status, await res.text());
    return text; // fallback: deja el original
  }
  const data = await res.json();
  return data?.translations?.[0]?.text ?? text;
}

Deno.serve(async (req) => {
  try {
    if (!DEEPL_KEY) return ok({ error: "DEEPL_API_KEY no configurada" });

    const payload = await req.json();
    const table: string = payload?.table;
    const type: string = payload?.type; // INSERT | UPDATE | DELETE
    const record = payload?.record;
    const oldRecord = payload?.old_record;

    if (!record || (table !== "categories" && table !== "characteristics")) {
      return ok({ skipped: "tabla/registro no aplicable" });
    }

    const nameChanged =
      type === "INSERT" || (oldRecord && oldRecord.name !== record.name);
    if (!nameChanged) return ok({ skipped: "name sin cambios (evita bucle)" });

    const name: string = record.name ?? "";
    if (!name.trim()) return ok({ skipped: "name vacío" });

    const [en, de] = await Promise.all([
      translate(name, "EN-US"),
      translate(name, "DE"),
    ]);

    const supabase = createClient(SUPABASE_URL, SERVICE_ROLE);
    const { error } = await supabase
      .from(table)
      .update({ name_en: en, name_de: de })
      .eq("id", record.id);

    if (error) {
      console.error("update error", error);
      return ok({ error: error.message });
    }
    return ok({ id: record.id, name, en, de });
  } catch (e) {
    console.error(e);
    return ok({ error: String(e) });
  }
});
