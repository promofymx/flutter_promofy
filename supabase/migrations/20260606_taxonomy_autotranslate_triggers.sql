-- ════════════════════════════════════════════════════════════════════════════
-- Auto-traducción de taxonomía (categorías / características)
--
-- Database Webhooks que llaman a la edge function `translate-taxonomy` en cada
-- INSERT/UPDATE. La función traduce `name` -> name_en / name_de con DeepL.
-- La función evita bucles (solo traduce en INSERT o cuando `name` cambió).
--
-- Requiere:
--   - extensión pg_net (la usa supabase_functions.http_request)
--   - secreto DEEPL_API_KEY configurado en Edge Functions
-- ════════════════════════════════════════════════════════════════════════════

drop trigger if exists translate_categories_webhook on public.categories;
create trigger translate_categories_webhook
after insert or update on public.categories
for each row execute function supabase_functions.http_request(
  'https://hfmvelirrcawsxaudhfl.supabase.co/functions/v1/translate-taxonomy',
  'POST',
  '{"Content-Type":"application/json"}',
  '{}',
  '5000'
);

drop trigger if exists translate_characteristics_webhook on public.characteristics;
create trigger translate_characteristics_webhook
after insert or update on public.characteristics
for each row execute function supabase_functions.http_request(
  'https://hfmvelirrcawsxaudhfl.supabase.co/functions/v1/translate-taxonomy',
  'POST',
  '{"Content-Type":"application/json"}',
  '{}',
  '5000'
);
