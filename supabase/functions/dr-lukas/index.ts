// ─────────────────────────────────────────────
// Edge Function "dr-lukas"
// KI-Lernbegleiter (Gemini) für die ZahnChallenge-App.
//
//   mode "ask"            Frage zum aktuellen Schritt – Tipps, aber keine Lösung
//   mode "explain"        nach dem Beantworten: erklärt, warum eine Antwort falsch/richtig ist
//   mode "evaluate_photo" bewertet ein hochgeladenes Foto nach dem Prompt aus den Falldaten
//
// Secrets (Dashboard → Edge Functions → Secrets):
//   GEMINI_API_KEY   (Pflicht)
//   GEMINI_MODEL     (optional, Standard: gemini-2.5-flash)
//   AI_DAILY_LIMIT   (optional, Standard: 100 Anfragen pro Nutzer:in und Tag)
// ─────────────────────────────────────────────
import { createClient } from "jsr:@supabase/supabase-js@2";

type Mode = "ask" | "explain" | "evaluate_photo";

interface ChatMessage {
  role: "user" | "assistant";
  text: string;
}

interface StepContext {
  type: string;
  question: string;
  context?: string;
  options?: string[];
  // nur bei "explain":
  givenAnswer?: string;
  correctAnswer?: string;
  expertComment?: string;
}

interface DrLukasRequest {
  mode: Mode;
  caseTitle?: string;
  patientSummary?: string;
  step?: StepContext;
  messages?: ChatMessage[];
  // nur bei "evaluate_photo":
  prompt?: string;
  imageBase64?: string;
}

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const PERSONA = `Du bist Dr. Lukas, ein freundlicher, erfahrener Zahnarzt und Tutor an der Universität Regensburg.
Du begleitest Zahnmedizinstudierende durch interaktive Patientenfälle.
Regeln:
- Antworte immer auf Deutsch, duze die Studierenden.
- Kurz und klar: höchstens 120 Wörter, gerne mit kurzen Absätzen.
- Fachlich korrekt. Wenn du dir unsicher bist, sag das offen und verweise auf Lehrbuch oder Betreuer:in.
- Ermutigender, aber ernsthafter Ton – es geht um Medizin. Keine Emojis.
- Beziehe dich nur auf Zahnmedizin und den aktuellen Fall. Lehne fachfremde Anfragen höflich ab.
- Es handelt sich um fiktive Lehrfälle, keine echten Patientendaten.`;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

function describeStep(req: DrLukasRequest): string {
  const s = req.step;
  if (!s) return "";
  const lines = [
    `Fall: ${req.caseTitle ?? "unbekannt"}`,
    req.patientSummary ? `Patient:in: ${req.patientSummary}` : "",
    s.context ? `Neue Information im Fall: ${s.context}` : "",
    `Aufgabe (${s.type}): ${s.question}`,
    s.options?.length ? `Antwortmöglichkeiten: ${s.options.join(" | ")}` : "",
  ];
  return lines.filter(Boolean).join("\n");
}

function systemPrompt(req: DrLukasRequest): string {
  switch (req.mode) {
    case "ask":
      if (!req.step) {
        return `${PERSONA}

Die/der Studierende stellt dir eine allgemeine Frage (z. B. zur Zahnmedizin, zum Lernen oder zur App).
Die App enthält interaktive Patientenfälle mit Fragen, Punkten, einem Ranking, 3D-Modellen und dir als Begleiter.`;
      }
      return `${PERSONA}

Die/der Studierende bearbeitet gerade diese Aufgabe und hat sie NOCH NICHT beantwortet:
${describeStep(req)}

WICHTIG: Verrate auf keinen Fall die richtige Antwort, auch nicht indirekt (nicht "Option X ist richtig",
nicht ausschließen, was falsch ist). Gib stattdessen Denkanstöße, erkläre Begriffe und Grundlagen und
stelle Gegenfragen, damit die/der Studierende selbst auf die Lösung kommt.
Wenn direkt nach der Lösung gefragt wird, erkläre freundlich, dass du sie erst nach dem Beantworten erklärst.`;
    case "explain": {
      const s = req.step;
      return `${PERSONA}

Die/der Studierende hat diese Aufgabe gerade beantwortet:
${describeStep(req)}

Gegebene Antwort: ${s?.givenAnswer ?? "–"}
Richtige Antwort: ${s?.correctAnswer ?? "–"}
${s?.expertComment ? `Expertenkommentar aus dem Fall: ${s.expertComment}` : ""}

Erkläre verständlich, WARUM die richtige Antwort richtig ist und was an der gegebenen Antwort nicht stimmt.
Nenne die zugrundeliegende Regel oder das Prinzip, damit man es sich merken kann. Halte dich an den
Expertenkommentar, falls vorhanden – er hat Vorrang vor deinem eigenen Wissen.`;
    }
    default:
      return PERSONA;
  }
}

async function callGemini(system: string, contents: unknown[]): Promise<string> {
  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) throw new Error("GEMINI_API_KEY ist nicht gesetzt");
  const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: system }] },
        contents,
        generationConfig: { maxOutputTokens: 600, temperature: 0.4 },
      }),
    },
  );
  if (!res.ok) {
    throw new Error(`Gemini-Fehler ${res.status}: ${await res.text()}`);
  }
  const data = await res.json();
  const text: string | undefined = data?.candidates?.[0]?.content?.parts
    ?.map((p: { text?: string }) => p.text ?? "")
    .join("")
    .trim();
  if (!text) throw new Error("Leere Antwort von Gemini");
  return text;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Nur POST erlaubt" }, 405);

  // Mit dem Token der Nutzer:in arbeiten → RLS und auth.uid() greifen
  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );

  let body: DrLukasRequest;
  try {
    body = await req.json();
  } catch {
    return json({ error: "Ungültige Anfrage" }, 400);
  }
  if (!["ask", "explain", "evaluate_photo"].includes(body.mode)) {
    return json({ error: "Unbekannter Modus" }, 400);
  }

  const dailyLimit = Number(Deno.env.get("AI_DAILY_LIMIT") ?? "100");
  const { data: allowed, error: quotaError } = await supabase.rpc("consume_ai_quota", {
    daily_limit: dailyLimit,
  });
  if (quotaError) return json({ error: "Nicht angemeldet" }, 401);
  if (!allowed) {
    return json({ error: "Tageslimit erreicht – morgen ist Dr. Lukas wieder für dich da." }, 429);
  }

  try {
    if (body.mode === "evaluate_photo") {
      if (!body.prompt || !body.imageBase64) {
        return json({ error: "Prompt oder Bild fehlt" }, 400);
      }
      // Bilder größer als ~4 MB (Base64) ablehnen
      if (body.imageBase64.length > 5_500_000) {
        return json({ error: "Bild ist zu groß" }, 413);
      }
      const reply = await callGemini(PERSONA, [{
        role: "user",
        parts: [
          { text: body.prompt },
          { inline_data: { mime_type: "image/jpeg", data: body.imageBase64 } },
        ],
      }]);
      return json({ reply });
    }

    // Chat-Verlauf (höchstens die letzten 12 Nachrichten, je max. 1000 Zeichen)
    const history = (body.messages ?? []).slice(-12).map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: String(m.text).slice(0, 1000) }],
    }));
    if (body.mode === "explain" && history.length === 0) {
      history.push({ role: "user", parts: [{ text: "Warum ist das so? Erklär es mir bitte." }] });
    }
    if (history.length === 0) return json({ error: "Keine Frage gestellt" }, 400);

    const reply = await callGemini(systemPrompt(body), history);
    return json({ reply });
  } catch (err) {
    console.error(err);
    return json({ error: "Dr. Lukas ist gerade nicht erreichbar. Bitte versuch es gleich nochmal." }, 502);
  }
});
