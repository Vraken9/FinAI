const GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta/models";

export async function callGemini(params: {
  model: string;
  contents: GeminiContent[];
  systemInstruction?: string;
  generationConfig?: Record<string, unknown>;
}): Promise<string> {
  const apiKey = Deno.env.get("GEMINI_API_KEY")!;
  const url = `${GEMINI_API_BASE}/${params.model}:generateContent?key=${apiKey}`;

  const body: Record<string, unknown> = {
    contents: params.contents,
    generationConfig: {
      temperature: 0.1,      // rendah = output konsisten & deterministik
      maxOutputTokens: 1024,
      ...params.generationConfig,
    },
  };

  if (params.systemInstruction) {
    body.systemInstruction = {
      parts: [{ text: params.systemInstruction }]
    };
  }

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(`Gemini API error ${response.status}: ${JSON.stringify(err)}`);
  }

  const data = await response.json();
  return data.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
}

// Tipe untuk Gemini content parts
export interface GeminiContent {
  role: "user" | "model";
  parts: GeminiPart[];
}

export type GeminiPart =
  | { text: string }
  | { inlineData: { mimeType: string; data: string } }  // base64 untuk audio/gambar
  | { fileData: { mimeType: string; fileUri: string } }; // untuk file besar via Files API
