// Edge Function: places
// Proxy para Google Places API que evita el bloqueo CORS en Flutter Web.
// Las credenciales de Google nunca salen del servidor.
//
// Tipos soportados:
//   { type: "autocomplete", input: "Av. López" }
//   { type: "details", placeId: "ChIJ..." }

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GOOGLE_KEY = Deno.env.get("GOOGLE_PLACES_API_KEY") ?? "";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json",
};

serve(async (req: Request) => {
  // Preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }

  try {
    const { type, input, placeId } = (await req.json()) as {
      type: "autocomplete" | "details";
      input?: string;
      placeId?: string;
    };

    let googleUrl: URL;

    if (type === "autocomplete" && input) {
      googleUrl = new URL(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      );
      googleUrl.searchParams.set("input", input);
      googleUrl.searchParams.set("key", GOOGLE_KEY);
      googleUrl.searchParams.set("language", "es");
      googleUrl.searchParams.set("components", "country:mx");
    } else if (type === "details" && placeId) {
      googleUrl = new URL(
        "https://maps.googleapis.com/maps/api/place/details/json",
      );
      googleUrl.searchParams.set("place_id", placeId);
      googleUrl.searchParams.set("key", GOOGLE_KEY);
      googleUrl.searchParams.set("fields", "geometry,formatted_address");
      googleUrl.searchParams.set("language", "es");
    } else {
      return new Response(JSON.stringify({ error: "Parámetros inválidos" }), {
        status: 400,
        headers: cors,
      });
    }

    const res = await fetch(googleUrl.toString());
    const data = await res.json();

    return new Response(JSON.stringify(data), { headers: cors });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: cors,
    });
  }
});
