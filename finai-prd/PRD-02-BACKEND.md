# FinAI — PRD Backend (Supabase Edge Functions & AI Pipeline)
**Versi:** 1.1.0  
**Dokumen:** PRD-02-BACKEND  
**Runtime:** Supabase Edge Functions (Deno + TypeScript)  
**Perubahan v1.1:** Semua AI service dikonsolidasi ke satu Gemini API key.  
**Baca PRD-00-MASTER.md dan PRD-01-DATABASE.md terlebih dahulu.**

---

## 1. Arsitektur Backend

FinAI tidak menggunakan server Node.js/Express terpisah. Semua logic backend berjalan di:
- **Supabase PostgreSQL** — data storage, RLS, views, functions
- **Supabase Edge Functions** — Deno runtime, dipanggil dari Flutter via HTTP
- **Supabase Realtime** — sync perubahan data antar device
- **Google Gemini API** — satu-satunya AI service untuk semua kebutuhan (teks, suara, gambar, chatbot)

> **Mengapa AI dipanggil dari Edge Functions, bukan Flutter langsung?**  
> `GEMINI_API_KEY` harus TIDAK PERNAH ada di kode Flutter karena bisa diekstrak dari APK. Semua API key disimpan di environment variable Edge Functions yang aman.

> **Mengapa hanya satu Gemini API key?**  
> Gemini 2.0 Flash adalah model multimodal yang mampu memproses teks, audio, dan gambar dalam satu API yang sama. Tidak perlu Whisper (speech-to-text) atau Google Vision (OCR) sebagai layanan terpisah. Satu key, satu vendor, satu titik monitoring biaya.

---

## 2. Environment Variables (Supabase Edge Functions)

```env
# AI Service — hanya satu key untuk semua kebutuhan AI
GEMINI_API_KEY=AIza...

# Supabase (auto-tersedia di Edge Functions)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...   # untuk bypass RLS di server-side operations

# Push Notification
FCM_SERVER_KEY=...

# Monitoring
SENTRY_DSN=https://...

# App Config
APP_ENV=production              # production | staging | development
AI_DAILY_LIMIT_PER_USER=50     # max AI calls per user per hari
GEMINI_MODEL_TEXT=gemini-2.0-flash        # untuk parse teks & chatbot
GEMINI_MODEL_MULTIMODAL=gemini-2.0-flash  # untuk audio & gambar (model sama, beda input)
```

---

## 3. Daftar Edge Functions

| Function | Method | Path | Deskripsi |
|---|---|---|---|
| `ai-parse-text` | POST | `/functions/v1/ai-parse-text` | Parse input teks natural ke field transaksi |
| `ai-parse-voice` | POST | `/functions/v1/ai-parse-voice` | Kirim audio ke Gemini → transkripsi + parse transaksi dalam 1 request |
| `ai-parse-image` | POST | `/functions/v1/ai-parse-image` | Kirim foto struk ke Gemini → OCR + parse transaksi dalam 1 request |
| `ai-chat` | POST | `/functions/v1/ai-chat` | Chatbot analitis dengan konteks data keuangan user |
| `export-excel` | POST | `/functions/v1/export-excel` | Generate file Excel dari data transaksi |
| `import-excel` | POST | `/functions/v1/import-excel` | Validasi dan import data dari file Excel |
| `generate-recurring` | POST | `/functions/v1/generate-recurring` | Trigger generate recurring drafts (juga via cron) |
| `send-notification` | POST | `/functions/v1/send-notification` | Kirim push notification via FCM |
| `health-score` | GET | `/functions/v1/health-score` | Hitung skor kesehatan keuangan user |

---

## 4. Spesifikasi Edge Functions

### 4.0 Helper Bersama — Gemini Client

Buat file shared yang digunakan oleh semua function AI:

```typescript
// supabase/functions/_shared/gemini.ts

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
```

---

### 4.1 `ai-parse-text` — Parse Teks Natural

**Request:**
```typescript
{
  text: string;               // "makan siang nasi goreng 15rb + es teh 5rb"
  default_asset_id: string;   // aset default user (biasanya cash)
  transaction_type?: 'income' | 'expense';
  user_timezone?: string;     // "Asia/Jakarta"
}
```

**Response (success):**
```typescript
{
  success: true;
  data: {
    type: 'income' | 'expense';
    amount: number;           // 20000
    category_name: string;    // "Makanan & Minuman"
    category_id?: string;
    asset_id: string;
    note: string;
    description: string;
    merchant?: string;
    transaction_date: string; // ISO timestamp
    confidence: number;       // 0–1
    ai_raw_input: string;
  };
  warning?: string;
}
```

**Implementasi:**
```typescript
// supabase/functions/ai-parse-text/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini } from "../_shared/gemini.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  // 1. Verifikasi JWT
  const authHeader = req.headers.get("Authorization");
  const { data: { user }, error: authError } = await supabase.auth.getUser(
    authHeader?.replace("Bearer ", "") ?? ""
  );
  if (authError || !user) {
    return new Response(JSON.stringify({ success: false, error: "Unauthorized" }), 
      { status: 401 });
  }

  // 2. Rate limiting
  const todayUsage = await checkDailyAiUsage(user.id);
  const limit = parseInt(Deno.env.get("AI_DAILY_LIMIT_PER_USER") ?? "50");
  if (todayUsage >= limit) {
    return new Response(JSON.stringify({
      success: false,
      error: "Batas penggunaan AI harian tercapai. Coba lagi besok.",
      code: "RATE_LIMITED"
    }), { status: 429 });
  }

  // 3. Parse body
  const { text, default_asset_id } = await req.json();

  // 4. Ambil kategori user
  const { data: categories } = await supabase
    .from("categories")
    .select("id, name, type")
    .or(`user_id.is.null,user_id.eq.${user.id}`)
    .is("deleted_at", null);

  const categoryList = categories?.map(c => `${c.name} (${c.type})`).join(", ");

  // 5. Panggil Gemini
  const systemPrompt = `Kamu adalah asisten parsing transaksi keuangan untuk aplikasi FinAI.
Tugas kamu: ekstrak informasi transaksi dari input teks bahasa Indonesia natural.

Kategori yang tersedia: ${categoryList}

Aturan parsing:
- Jika tidak ada mata uang, asumsikan Rupiah Indonesia
- "rb" atau "ribu" = dikali 1000, "jt" atau "juta" = dikali 1.000.000
- Jika ada beberapa item (misal: nasi goreng 15rb + es teh 5rb), jumlahkan totalnya
- Jika tipe transaksi tidak jelas dari konteks, asumsikan "expense"
- Jika aset tidak disebutkan, gunakan "cash"
- Merchant adalah nama toko/restoran jika disebutkan

Balas HANYA dengan JSON valid, tanpa teks tambahan, tanpa markdown code block:
{
  "type": "income" atau "expense",
  "amount": angka integer dalam Rupiah,
  "category_name": string dari daftar kategori,
  "note": string ringkasan singkat max 100 karakter,
  "description": string deskripsi detail max 200 karakter,
  "merchant": string atau null,
  "confidence": angka 0-1,
  "ambiguity": string atau null jika ada hal yang tidak yakin
}`;

  const rawText = await callGemini({
    model: Deno.env.get("GEMINI_MODEL_TEXT")!,
    systemInstruction: systemPrompt,
    contents: [{ role: "user", parts: [{ text: `Input: "${text}"` }] }],
    generationConfig: { maxOutputTokens: 500 },
  });

  // 6. Parse JSON response
  try {
    const parsed = JSON.parse(rawText.trim());
    const matchedCategory = categories?.find(c =>
      c.name.toLowerCase() === parsed.category_name?.toLowerCase()
    );

    await logAiUsage(user.id, "parse_text");

    return new Response(JSON.stringify({
      success: true,
      data: {
        type: parsed.type,
        amount: parsed.amount,
        category_name: parsed.category_name,
        category_id: matchedCategory?.id,
        asset_id: default_asset_id,
        note: parsed.note,
        description: parsed.description,
        merchant: parsed.merchant,
        transaction_date: new Date().toISOString(),
        confidence: parsed.confidence,
        ai_raw_input: text,
      },
      warning: parsed.ambiguity,
    }), { headers: { "Content-Type": "application/json" } });

  } catch {
    return new Response(JSON.stringify({
      success: false,
      error: "AI tidak dapat memproses input ini. Coba dengan kalimat yang lebih jelas.",
      code: "PARSE_FAILED",
    }), { status: 422 });
  }
});

async function checkDailyAiUsage(userId: string): Promise<number> {
  const today = new Date().toISOString().split("T")[0];
  const { count } = await supabase
    .from("ai_messages")
    .select("*", { count: "exact", head: true })
    .eq("user_id", userId)
    .gte("created_at", today);
  return count ?? 0;
}

async function logAiUsage(userId: string, type: string) {
  await supabase.from("ai_messages").insert({
    user_id: userId,
    role: "user",
    content: type,
    input_type: "text",
  });
}
```

---

### 4.2 `ai-parse-voice` — Parse Input Suara

**Perbedaan utama dari versi lama:** Tidak ada Whisper API. Audio dikirim langsung ke Gemini sebagai base64. Gemini melakukan transkripsi DAN parsing transaksi dalam **satu request** sekaligus.

**Request:** `multipart/form-data`
```
audio: File (format: webm/ogg/mp4/wav, max 20MB)
default_asset_id: string
```

**Alur kerja (lebih singkat dari sebelumnya):**
```
Audio file dari Flutter
  → Encode ke base64 di Edge Function
  → Kirim ke Gemini 2.0 Flash sebagai inlineData (mimeType audio/*)
  → Gemini sekaligus: transkripsi + parse transaksi
  → Return ParsedTransaction
```

**Implementasi:**
```typescript
// supabase/functions/ai-parse-voice/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini } from "../_shared/gemini.ts";

serve(async (req) => {
  // ... auth & rate limiting (sama seperti ai-parse-text) ...

  const formData = await req.formData();
  const audioFile = formData.get("audio") as File;
  const defaultAssetId = formData.get("default_asset_id") as string;

  if (!audioFile) {
    return new Response(JSON.stringify({
      success: false, error: "File audio tidak ditemukan.", code: "VALIDATION_ERROR"
    }), { status: 422 });
  }

  // Encode audio ke base64
  const audioBuffer = await audioFile.arrayBuffer();
  const audioBase64 = btoa(String.fromCharCode(...new Uint8Array(audioBuffer)));
  const mimeType = audioFile.type || "audio/webm"; // fallback jika mime tidak terdeteksi

  // Ambil kategori user
  const { data: categories } = await supabase
    .from("categories")
    .select("id, name, type")
    .or(`user_id.is.null,user_id.eq.${user.id}`)
    .is("deleted_at", null);
  const categoryList = categories?.map(c => `${c.name} (${c.type})`).join(", ");

  // Satu request ke Gemini: transkripsi + parse sekaligus
  const prompt = `Dengarkan audio ini. Pengguna sedang menyebutkan transaksi keuangan dalam bahasa Indonesia.

Tugas kamu:
1. Transkripsi apa yang diucapkan
2. Ekstrak informasi transaksi dari ucapan tersebut

Kategori tersedia: ${categoryList}
Aturan: nominal tanpa mata uang = Rupiah, "rb/ribu" = x1000, "jt/juta" = x1.000.000, default tipe = expense, default aset = cash.

Balas HANYA dengan JSON valid tanpa markdown:
{
  "transcription": string ucapan pengguna,
  "type": "income" atau "expense",
  "amount": integer Rupiah,
  "category_name": string dari daftar kategori,
  "note": string max 100 karakter,
  "description": string max 200 karakter,
  "merchant": string atau null,
  "confidence": angka 0-1,
  "ambiguity": string atau null
}`;

  const rawText = await callGemini({
    model: Deno.env.get("GEMINI_MODEL_MULTIMODAL")!,
    contents: [{
      role: "user",
      parts: [
        { inlineData: { mimeType, data: audioBase64 } },
        { text: prompt },
      ],
    }],
    generationConfig: { maxOutputTokens: 600 },
  });

  try {
    const parsed = JSON.parse(rawText.trim());
    const matchedCategory = categories?.find(c =>
      c.name.toLowerCase() === parsed.category_name?.toLowerCase()
    );

    return new Response(JSON.stringify({
      success: true,
      transcription: parsed.transcription, // dikirim ke Flutter untuk ditampilkan ke user
      data: {
        type: parsed.type,
        amount: parsed.amount,
        category_name: parsed.category_name,
        category_id: matchedCategory?.id,
        asset_id: defaultAssetId,
        note: parsed.note,
        description: parsed.description,
        merchant: parsed.merchant,
        transaction_date: new Date().toISOString(),
        confidence: parsed.confidence,
        ai_raw_input: parsed.transcription,
      },
      warning: parsed.ambiguity,
    }), { headers: { "Content-Type": "application/json" } });

  } catch {
    return new Response(JSON.stringify({
      success: false,
      error: "Suara tidak dapat diproses. Coba ucapkan lebih jelas atau isi manual.",
      code: "PARSE_FAILED",
    }), { status: 422 });
  }
});
```

> **Catatan ukuran file audio:** Gemini `inlineData` mendukung hingga 20MB. Untuk rekaman suara pendek (< 60 detik) ukurannya jauh di bawah batas ini. Jika di masa depan dibutuhkan audio lebih panjang, gunakan Gemini Files API (upload dulu, lalu referensikan `fileUri`).

---

### 4.3 `ai-parse-image` — OCR + Parse Foto Struk

**Perbedaan utama dari versi lama:** Tidak ada Google Cloud Vision API terpisah. Foto dikirim langsung ke Gemini sebagai base64. Gemini melakukan OCR DAN parsing transaksi dalam **satu request** sekaligus.

**Request:** `multipart/form-data`
```
image: File (format: jpeg/png, max 5MB)
default_asset_id: string
```

**Alur kerja:**
```
Foto struk dari Flutter
  → Encode ke base64 di Edge Function
  → Kirim ke Gemini 2.0 Flash sebagai inlineData (mimeType image/*)
  → Gemini sekaligus: baca teks struk + parse transaksi
  → Upload foto asli ke Supabase Storage (sebagai lampiran)
  → Return ParsedTransaction + attachment_path
```

**Implementasi:**
```typescript
// supabase/functions/ai-parse-image/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini } from "../_shared/gemini.ts";

serve(async (req) => {
  // ... auth & rate limiting ...

  const formData = await req.formData();
  const imageFile = formData.get("image") as File;
  const defaultAssetId = formData.get("default_asset_id") as string;

  if (!imageFile) {
    return new Response(JSON.stringify({
      success: false, error: "File gambar tidak ditemukan.", code: "VALIDATION_ERROR"
    }), { status: 422 });
  }

  // Encode gambar ke base64
  const imageBuffer = await imageFile.arrayBuffer();
  const imageBase64 = btoa(String.fromCharCode(...new Uint8Array(imageBuffer)));
  const mimeType = imageFile.type || "image/jpeg";

  // Ambil kategori user
  const { data: categories } = await supabase
    .from("categories")
    .select("id, name, type")
    .or(`user_id.is.null,user_id.eq.${user.id}`)
    .is("deleted_at", null);
  const categoryList = categories?.map(c => `${c.name} (${c.type})`).join(", ");

  // Satu request ke Gemini: baca struk + parse sekaligus
  const prompt = `Lihat gambar struk/nota/invoice ini dengan teliti.

Tugas kamu:
1. Baca semua teks yang ada di struk
2. Ekstrak informasi transaksi dari struk tersebut

Yang perlu dicari:
- TOTAL AKHIR pembayaran (bukan subtotal atau harga per item)
- Nama toko/merchant (biasanya di header struk)
- Tanggal dan waktu transaksi (jika ada)
- Item-item yang dibeli (untuk dimasukkan ke deskripsi)
- Metode pembayaran jika disebutkan

Kategori tersedia: ${categoryList}
Aturan: jika tanggal tidak ada gunakan hari ini, gunakan TOTAL AKHIR bukan jumlah item.

Balas HANYA dengan JSON valid tanpa markdown:
{
  "type": "expense",
  "amount": integer Rupiah total akhir,
  "category_name": string dari daftar kategori,
  "note": string nama merchant + ringkasan max 100 karakter,
  "description": string daftar item yang dibeli max 300 karakter,
  "merchant": string nama toko atau null,
  "transaction_date": string ISO timestamp atau null jika tidak ada di struk,
  "confidence": angka 0-1 seberapa jelas struk terbaca,
  "ambiguity": string atau null jika ada yang tidak terbaca jelas
}`;

  const rawText = await callGemini({
    model: Deno.env.get("GEMINI_MODEL_MULTIMODAL")!,
    contents: [{
      role: "user",
      parts: [
        { inlineData: { mimeType, data: imageBase64 } },
        { text: prompt },
      ],
    }],
    generationConfig: { maxOutputTokens: 700 },
  });

  try {
    const parsed = JSON.parse(rawText.trim());
    const matchedCategory = categories?.find(c =>
      c.name.toLowerCase() === parsed.category_name?.toLowerCase()
    );

    // Upload foto ke Supabase Storage untuk dilampirkan ke transaksi
    const fileName = `receipt_${Date.now()}.${mimeType.split("/")[1]}`;
    const storagePath = `${user.id}/pending/${fileName}`;
    await supabase.storage
      .from("transaction-attachments")
      .upload(storagePath, imageFile, { contentType: mimeType });

    return new Response(JSON.stringify({
      success: true,
      data: {
        type: parsed.type ?? "expense",
        amount: parsed.amount,
        category_name: parsed.category_name,
        category_id: matchedCategory?.id,
        asset_id: defaultAssetId,
        note: parsed.note,
        description: parsed.description,
        merchant: parsed.merchant,
        transaction_date: parsed.transaction_date ?? new Date().toISOString(),
        confidence: parsed.confidence,
        ai_raw_input: "image_scan",
        pending_attachment_path: storagePath, // Flutter pakai ini saat simpan transaksi
      },
      warning: parsed.ambiguity,
    }), { headers: { "Content-Type": "application/json" } });

  } catch {
    return new Response(JSON.stringify({
      success: false,
      error: "Struk tidak dapat dibaca. Pastikan foto cukup jelas dan terang, atau isi manual.",
      code: "PARSE_FAILED",
    }), { status: 422 });
  }
});
```

---

### 4.4 `ai-chat` — Chatbot Analitis

**Request:**
```typescript
{
  message: string;           // pesan dari user
  conversation_id?: string;  // untuk melanjutkan percakapan
  history?: Array<{ role: 'user' | 'model'; text: string }>; // riwayat chat dari Flutter
}
```

**Implementasi:**
```typescript
// supabase/functions/ai-chat/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { callGemini, GeminiContent } from "../_shared/gemini.ts";

serve(async (req) => {
  // ... auth & rate limiting ...

  const { message, history = [] } = await req.json();

  // 1. Ambil ringkasan keuangan user dari database
  const { data: summary } = await supabase.rpc("get_user_financial_summary", {
    p_user_id: user.id
  });

  // 2. Ambil 10 transaksi terbaru
  const { data: recentTx } = await supabase
    .from("transactions")
    .select("type, amount, note, merchant, transaction_date, categories(name)")
    .eq("user_id", user.id)
    .is("deleted_at", null)
    .eq("status", "confirmed")
    .order("transaction_date", { ascending: false })
    .limit(10);

  // 3. Bangun system instruction dengan konteks keuangan nyata
  const systemInstruction = `Kamu adalah FinAI Advisor, asisten keuangan personal yang cerdas dan empatik.
Kamu memiliki akses ke data keuangan nyata pengguna dan HARUS menggunakannya saat memberi saran.

DATA KEUANGAN PENGGUNA (bulan ini):
- Total saldo semua aset: Rp ${summary?.total_balance?.toLocaleString("id") ?? "0"}
- Pemasukan bulan ini: Rp ${summary?.this_month_income?.toLocaleString("id") ?? "0"}
- Pengeluaran bulan ini: Rp ${summary?.this_month_expense?.toLocaleString("id") ?? "0"}
- Pengeluaran per kategori: ${JSON.stringify(summary?.expense_by_category ?? [])}
- Aset yang dimiliki: ${JSON.stringify(summary?.assets ?? [])}

10 TRANSAKSI TERBARU:
${recentTx?.map(t =>
  `- ${t.type}: Rp ${t.amount.toLocaleString("id")} | ${(t.categories as {name:string})?.name} | ${t.note ?? "-"} | ${t.merchant ?? "-"} | ${new Date(t.transaction_date).toLocaleDateString("id")}`
).join("\n") ?? "Belum ada transaksi."}

ATURAN SARAN:
1. Selalu referensikan data nyata pengguna, bukan asumsi umum
2. Jika ditanya soal pembelian baru, cek apakah sudah ada pembelian serupa bulan ini
3. Berikan saran yang realistis dan spesifik dalam Rupiah Indonesia
4. Gunakan bahasa Indonesia yang natural dan hangat, tidak kaku
5. Jangan menghakimi, tapi jujur dan to-the-point
6. Jika data tidak cukup untuk menjawab, katakan dengan jelas
7. Respons maksimal 3 paragraf pendek agar mudah dibaca di layar mobile`;

  // 4. Bangun riwayat percakapan untuk Gemini (multi-turn)
  const contents: GeminiContent[] = [
    ...history.map(h => ({
      role: h.role as "user" | "model",
      parts: [{ text: h.text }],
    })),
    { role: "user", parts: [{ text: message }] },
  ];

  // 5. Panggil Gemini
  const aiResponse = await callGemini({
    model: Deno.env.get("GEMINI_MODEL_TEXT")!,
    systemInstruction,
    contents,
    generationConfig: { maxOutputTokens: 1024, temperature: 0.7 },
  });

  // 6. Simpan pesan ke database
  await supabase.from("ai_messages").insert([
    { user_id: user.id, role: "user", content: message, input_type: "text" },
    { user_id: user.id, role: "assistant", content: aiResponse },
  ]);

  return new Response(JSON.stringify({
    success: true,
    response: aiResponse,
  }), { headers: { "Content-Type": "application/json" } });
});
```

---

### 4.5 `export-excel` — Export Data ke Excel

**Request:**
```typescript
{
  start_date?: string;  // ISO date, default: awal bulan ini
  end_date?: string;    // ISO date, default: hari ini
  types?: ('income' | 'expense' | 'transfer')[];
}
```

**Response:** File Excel (.xlsx) sebagai binary download

**Sheet yang dihasilkan:**
1. **Ringkasan** — total pemasukan, pengeluaran, net, per kategori
2. **Semua Transaksi** — semua field transaksi dalam rentang waktu
3. **Per Kategori** — subtotal per kategori
4. **Aset** — saldo akhir per aset

**Library:** `https://esm.sh/xlsx@0.18.5` (SheetJS untuk Deno)

---

### 4.6 `import-excel` — Import dari Excel

**Request:** `multipart/form-data`
```
file: File (.xlsx)
```

**Format Excel yang diterima (sheet "Transaksi"):**

| Kolom | Tipe | Wajib | Keterangan |
|---|---|---|---|
| Tanggal | DD/MM/YYYY | Ya | Tanggal transaksi |
| Waktu | HH:MM | Tidak | Default 00:00 |
| Tipe | income/expense/transfer | Ya | |
| Nominal | Number | Ya | Dalam Rupiah |
| Kategori | Text | Ya untuk non-transfer | Harus cocok dengan kategori yang ada |
| Aset | Text | Ya | Harus cocok dengan nama aset user |
| Catatan | Text | Tidak | |
| Deskripsi | Text | Tidak | |

**Validasi yang dilakukan:**
1. Format kolom benar
2. Nominal adalah angka positif
3. Kategori ada di database (sistem atau custom user)
4. Aset ada di database user
5. Tanggal valid
6. Tipe transaksi valid

**Response:**
```typescript
{
  success: true;
  data: {
    total_rows: number;
    valid_rows: number;
    invalid_rows: number;
    errors: Array<{ row: number; message: string }>;
    preview: ParsedTransaction[];  // 5 baris pertama untuk preview
    import_token: string;          // token untuk konfirmasi import
  }
}
```

**Alur 2 langkah:**
1. Upload → validasi → preview (belum simpan)
2. User konfirmasi → kirim `import_token` → simpan ke database

---

### 4.7 `health-score` — Skor Kesehatan Keuangan

**Kalkulasi skor (0–100):**

```typescript
function calculateHealthScore(summary: FinancialSummary): number {
  let score = 0;

  // 1. Saving rate (max 40 poin) — ideal: >30% pemasukan ditabung
  const savingRate = summary.this_month_income > 0
    ? (summary.this_month_income - summary.this_month_expense) / summary.this_month_income
    : 0;
  if (savingRate >= 0.3) score += 40;
  else if (savingRate >= 0.2) score += 30;
  else if (savingRate >= 0.1) score += 20;
  else if (savingRate >= 0) score += 10;

  // 2. Budget compliance (max 30 poin)
  const budgetCategories = summary.expense_by_category?.filter(c => c.budget > 0) ?? [];
  if (budgetCategories.length > 0) {
    const withinBudget = budgetCategories.filter(c => c.total <= c.budget).length;
    score += Math.round((withinBudget / budgetCategories.length) * 30);
  } else {
    score += 15; // Netral jika belum set budget
  }

  // 3. Konsistensi pencatatan (max 20 poin)
  const activeDays = summary.active_days_this_month ?? 0;
  const daysElapsed = new Date().getDate();
  score += Math.round((activeDays / daysElapsed) * 20);

  // 4. Emergency fund proxy (max 10 poin)
  const monthlyExpense = summary.this_month_expense;
  if (summary.total_balance >= monthlyExpense * 6) score += 10;
  else if (summary.total_balance >= monthlyExpense * 3) score += 7;
  else if (summary.total_balance >= monthlyExpense) score += 3;

  return Math.min(100, Math.max(0, score));
}
```

---

### 4.8 `generate-recurring` — Cron Job

Dijalankan otomatis setiap hari pukul 06:00 WIB via Supabase Cron:

```sql
-- Di Supabase Dashboard > Database > Cron Jobs
SELECT cron.schedule(
  'generate-recurring-drafts',
  '0 23 * * *',  -- 06:00 WIB = 23:00 UTC
  'SELECT net.http_post(
    url := current_setting(''app.edge_function_url'') || ''/generate-recurring'',
    headers := jsonb_build_object(''Authorization'', ''Bearer '' || current_setting(''app.service_role_key'')),
    body := ''{}''
  )'
);
```

Setelah draft dibuat, Edge Function memanggil `send-notification` untuk FCM push notification ke device user.

---

## 5. Error Handling Backend

### 5.1 Standard Error Response Format

```typescript
interface ErrorResponse {
  success: false;
  error: string;   // Pesan ramah dalam bahasa Indonesia
  code: string;    // Kode untuk Flutter agar bisa handle spesifik
  details?: any;   // Debug info (hanya di APP_ENV=development)
}
```

### 5.2 Error Codes

| Code | HTTP Status | Pesan Default |
|---|---|---|
| `UNAUTHORIZED` | 401 | Sesi habis, silakan login kembali |
| `FORBIDDEN` | 403 | Kamu tidak punya akses ke resource ini |
| `VALIDATION_ERROR` | 422 | Data yang dikirim tidak valid |
| `RATE_LIMITED` | 429 | Terlalu banyak request, coba lagi nanti |
| `PARSE_FAILED` | 422 | AI tidak dapat memproses input ini |
| `AMBIGUOUS_INPUT` | 422 | Input tidak jelas, coba lebih spesifik |
| `EXTERNAL_API_ERROR` | 503 | Layanan AI sedang tidak tersedia |
| `DATABASE_ERROR` | 500 | Terjadi kesalahan, tim kami sudah diberitahu |

### 5.3 Fallback untuk Gemini API Error

Jika Gemini API gagal (timeout, rate limit, quota habis):
1. Flutter tetap membuka form input kosong — tidak crash
2. Pesan ditampilkan: "Maaf, AI sedang sibuk. Kamu tetap bisa isi manual."
3. Error dilog ke Sentry tanpa data keuangan sensitif user

---

## 6. Keamanan Backend

### 6.1 API Key Security
- `GEMINI_API_KEY` hanya ada di Supabase Secrets (environment variable Edge Functions)
- Tidak ada API key di kode Flutter maupun di repository Git
- API key di-rotate setiap 90 hari
- Aktifkan API key restriction di Google Cloud Console: batasi hanya bisa dipanggil dari IP Supabase

### 6.2 Request Validation
- Semua Edge Function memvalidasi JWT dari Supabase Auth sebelum melakukan apapun
- Input size limit: 1MB untuk JSON, 20MB untuk audio, 5MB untuk image
- Rate limiting: 50 AI calls per user per hari, dicek via tabel `ai_messages`

### 6.3 Data Privacy di Logging
```typescript
// BENAR — hanya kirim metadata ke Sentry, bukan konten
Sentry.captureException(error, {
  tags: { function: "ai-parse-text", user_id: userId },
  extra: { error_code: "PARSE_FAILED", input_length: text.length }
});

// SALAH — jangan pernah kirim konten transaksi ke Sentry
// extra: { raw_input: text }        ← DILARANG
// extra: { amount: 50000 }          ← DILARANG
// extra: { category: "Makanan" }    ← DILARANG
```

---

## 7. Supabase Realtime

Aktifkan realtime untuk tabel yang perlu sync antar device:

```sql
ALTER TABLE transactions REPLICA IDENTITY FULL;
ALTER TABLE assets REPLICA IDENTITY FULL;
ALTER TABLE budgets REPLICA IDENTITY FULL;
ALTER TABLE recurring_rules REPLICA IDENTITY FULL;

BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE
    transactions, assets, budgets, recurring_rules;
COMMIT;
```

Flutter subscribe ke channel:
```dart
supabase
  .from('transactions')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .listen((data) => ref.read(transactionProvider.notifier).refresh());
```

---

## 8. Monitoring & Alerting

### 8.1 Sentry Edge Functions
```typescript
import * as Sentry from "https://deno.land/x/sentry/index.mjs";
Sentry.init({ dsn: Deno.env.get("SENTRY_DSN") });

serve(Sentry.wrapRequestHandler(async (req) => {
  // ... handler logic
}));
```

### 8.2 Metrik yang dimonitor
- Latency per Edge Function (target: < 4 detik untuk AI calls dengan audio/gambar)
- Error rate per function (alert jika > 5% dalam 10 menit)
- Jumlah AI call per hari per user (untuk budget cost control)
- Gemini API quota usage (pantau di Google Cloud Console)
- Database query time (alert jika > 1 detik)

### 8.3 Estimasi Biaya Gemini API
Sebagai referensi perencanaan (harga dapat berubah, cek pricing Gemini terbaru):
- Gemini 2.0 Flash: input/output token sangat murah, cocok untuk aplikasi dengan banyak user
- Audio input: dihitung per detik audio
- Image input: dihitung per gambar
- Dengan limit 50 AI calls/user/hari, biaya per user per bulan diperkirakan sangat kecil