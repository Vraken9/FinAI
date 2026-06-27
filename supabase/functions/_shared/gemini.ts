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

      if (!response.ok) {
        const err = await response.json();
        
        // Smart retry for 429 Rate Limit
        if (response.status === 429) {
          const retryInfo = err?.error?.details?.find(
            (d: any) => d['@type']?.includes('RetryInfo')
          );
          const delaySeconds = retryInfo?.retryDelay
            ? parseInt(retryInfo.retryDelay) + 1
            : 30; // Default 30 detik
          
          if (attempt < retries) {
            console.log(`Rate limited. Menunggu ${delaySeconds} detik sebelum percobaan ulang...`);
            await new Promise(r => setTimeout(r, delaySeconds * 1000));
            continue;
          }
        }
        
        // Simple backoff for 503 Service Unavailable
        if (response.status === 503 && attempt < retries) {
          await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
          continue;
        }

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

export function extractJSON(raw: string): string {
  // 1. Coba temukan blok JSON pertama yang valid di dalam teks
  const jsonMatch = raw.match(/\{[\s\S]*\}/);
  if (!jsonMatch) throw new Error("Tidak ada JSON ditemukan di response");
  
  let jsonStr = jsonMatch[0];
  
  // 2. Hapus komentar JS (// ... dan /* ... */)
  jsonStr = jsonStr.replace(/\/\/[^\n]*\n/g, ' ');
  jsonStr = jsonStr.replace(/\/\*[\s\S]*?\*\//g, ' ');
  
  // 3. Hapus trailing comma sebelum } atau ]
  jsonStr = jsonStr.replace(/,(\s*[}\]])/g, '$1');
  
  // 4. Coba parse — jika gagal, kembalikan error yang jelas
  try {
    JSON.parse(jsonStr);
    return jsonStr;
  } catch (e: any) {
    throw new Error("JSON tidak valid setelah pembersihan: " + e.message);
  }
}
