const GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta/models";

export async function callGemini(params: {
  model: string;
  contents: GeminiContent[];
  systemInstruction?: string;
  generationConfig?: Record<string, unknown>;
}, retries = 2): Promise<string> {
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

  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });

      if (response.status === 503 && attempt < retries) {
        // Tunggu sebentar sebelum retry (exponential backoff sederhana)
        await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
        continue;
      }

      if (!response.ok) {
        const err = await response.json();
        throw new Error(`Gemini API error ${response.status}: ${JSON.stringify(err)}`);
      }

      const data = await response.json();
      return data.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    } catch (error) {
      if (attempt === retries) throw error;
      
      // Jika terjadi error jaringan (misal ECONNRESET) sebelum mendapatkan response
      await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
    }
  }
  throw new Error("Gemini API gagal setelah beberapa percobaan");
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

export function uint8ArrayToBase64(bytes: Uint8Array): string {
  let binary = '';
  const chunkSize = 8192; // proses per 8KB agar tidak overflow stack
  for (let i = 0; i < bytes.length; i += chunkSize) {
    const chunk = bytes.subarray(i, i + chunkSize);
    binary += String.fromCharCode(...chunk);
  }
  return btoa(binary);
}
