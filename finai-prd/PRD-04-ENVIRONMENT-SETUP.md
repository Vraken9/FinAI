# FinAI — Panduan Setup Environment
**Versi:** 1.0.0  
**Dokumen:** PRD-04-ENVIRONMENT-SETUP  
**Baca dokumen ini PERTAMA sebelum memberikan perintah apapun ke AI agent.**

Dokumen ini memandu kamu menyiapkan semua akun, credentials, dan konfigurasi  
yang dibutuhkan FinAI dari nol. Ikuti urutan bagian demi bagian.

---

## Daftar Isi

1. [Gambaran Besar — Apa yang Perlu Disiapkan](#1-gambaran-besar)
2. [Supabase — Database + Auth + Storage + Edge Functions](#2-supabase)
3. [Google Gemini API — Satu-satunya AI Service](#3-google-gemini-api)
4. [Firebase Cloud Messaging — Push Notification](#4-firebase-cloud-messaging)
5. [Sentry — Error Tracking](#5-sentry)
6. [Hosting Backend — Supabase sebagai Backend Gratis](#6-hosting-backend)
7. [File .env Final yang Lengkap](#7-file-env-final)
8. [Konfigurasi Supabase CLI untuk AI Agent](#8-supabase-cli-untuk-ai-agent)
9. [Checklist Sebelum Mulai Coding](#9-checklist-final)

---

## 1. Gambaran Besar

Sebelum AI agent bisa menjalankan perintah (migrasi database, deploy Edge Functions, dll), kamu perlu menyiapkan credentials dari 4 layanan berikut:

```
┌─────────────────────────────────────────────────────┐
│  Layanan          │ Fungsi            │ Biaya        │
├─────────────────────────────────────────────────────┤
│  Supabase         │ DB + Auth +       │ GRATIS       │
│                   │ Storage + Backend │ (free tier)  │
├─────────────────────────────────────────────────────┤
│  Google Gemini    │ Semua AI          │ GRATIS       │
│  API              │ (teks/suara/foto/ │ (free tier   │
│                   │ chatbot)          │ sangat murah)│
├─────────────────────────────────────────────────────┤
│  Firebase (FCM)   │ Push notification │ GRATIS       │
│                   │                   │ (selalu)     │
├─────────────────────────────────────────────────────┤
│  Sentry           │ Error tracking    │ GRATIS       │
│                   │                   │ (free tier)  │
└─────────────────────────────────────────────────────┘
```

**Total biaya untuk development dan skala kecil: Rp 0**

Setelah semua credentials didapat, kamu akan mengisinya ke file `.env` di folder proyek,
lalu AI agent bisa membacanya untuk menjalankan semua perintah.

---

## 2. Supabase

Supabase adalah backend utama FinAI. Di sinilah database PostgreSQL, Auth, Storage,
dan Edge Functions (serverless functions) berjalan. Ini sekaligus sebagai hosting backend — 
tidak perlu server terpisah.

### 2.1 Buat Akun dan Project Supabase

**Langkah 1 — Daftar akun**
1. Buka https://supabase.com
2. Klik **"Start your project"**
3. Daftar menggunakan akun GitHub (disarankan) atau email

**Langkah 2 — Buat project baru**
1. Setelah login, klik **"New project"**
2. Isi form:
   - **Name:** `finai` (atau nama yang kamu mau)
   - **Database Password:** buat password yang kuat, **simpan baik-baik** karena ini tidak bisa dilihat lagi
   - **Region:** pilih `Southeast Asia (Singapore)` — paling dekat dengan Indonesia
   - **Pricing Plan:** pilih **Free**
3. Klik **"Create new project"**
4. Tunggu 1–2 menit sampai project selesai dibuat (ada loading spinner)

**Langkah 3 — Ambil credentials project**

Setelah project siap, buka **Project Settings** (ikon gear di sidebar kiri bawah):

**Tab "API":**
- Catat **Project URL** → ini adalah `SUPABASE_URL`
  - Contoh: `https://abcdefghijklmn.supabase.co`
- Catat **anon public key** → ini adalah `SUPABASE_ANON_KEY` (dipakai di Flutter)
- Catat **service_role secret key** → ini adalah `SUPABASE_SERVICE_ROLE_KEY`
  > ⚠️ `service_role` key bersifat rahasia. Jangan pernah masukkan ke kode Flutter. Hanya untuk Edge Functions dan AI agent di server.

**Tab "Database":**
- Catat **Connection string (URI)** → ini adalah `DATABASE_URL`
  - Format: `postgresql://postgres:[PASSWORD]@db.xxx.supabase.co:5432/postgres`
  - Ganti `[PASSWORD]` dengan database password yang kamu buat tadi

### 2.2 Aktifkan Email Auth

1. Di sidebar kiri, klik **Authentication**
2. Klik tab **Providers**
3. Pastikan **Email** sudah enabled (biasanya sudah default aktif)
4. Untuk Google OAuth (opsional di tahap awal): aktifkan **Google** dan ikuti instruksi di sana

### 2.3 Ambil Credentials untuk Edge Functions

Di **Project Settings > API**, scroll ke bawah:
- **JWT Secret** → catat ini sebagai `SUPABASE_JWT_SECRET`

---

## 3. Google Gemini API

Gemini adalah satu-satunya AI yang digunakan FinAI untuk semua fungsi: parse teks, parse suara, OCR foto struk, dan chatbot.

### 3.1 Aktifkan Gemini API dan Dapatkan API Key

**Langkah 1 — Buka Google AI Studio**
1. Buka https://aistudio.google.com
2. Login dengan akun Google kamu

**Langkah 2 — Buat API Key**
1. Di halaman Google AI Studio, klik **"Get API key"** di sidebar kiri
2. Klik **"Create API key"**
3. Pilih **"Create API key in new project"** (Google akan otomatis membuat Google Cloud project)
4. API key akan muncul — contoh: `AIzaSyAbc123...`
5. Klik ikon copy untuk menyalin
6. **Simpan key ini sekarang** — kamu akan membutuhkannya di file `.env`

> **Penting:** API key dari Google AI Studio sudah langsung bisa digunakan untuk Gemini 2.0 Flash tanpa perlu setup billing terlebih dahulu. Ada free tier yang sangat generous untuk development.

**Langkah 3 — Cek quota gratis**
1. Di Google AI Studio, klik **"View rate limits"** atau buka https://aistudio.google.com/app/apikey
2. Gemini 2.0 Flash free tier: 15 requests/menit, 1 juta tokens/hari — lebih dari cukup untuk development

**Langkah 4 (Opsional tapi disarankan) — Batasi penggunaan API key**
1. Buka https://console.cloud.google.com
2. Masuk ke **APIs & Services > Credentials**
3. Klik API key yang baru dibuat
4. Di bagian **"Application restrictions"**, pilih **"None"** untuk sekarang (aman untuk development)
5. Di bagian **"API restrictions"**, pilih **"Restrict key"** → pilih **"Generative Language API"**
6. Klik **Save**

Credentials yang didapat:
```
GEMINI_API_KEY=AIzaSyAbc123...
GEMINI_MODEL_TEXT=gemini-2.0-flash
GEMINI_MODEL_MULTIMODAL=gemini-2.0-flash
```

---

## 4. Firebase Cloud Messaging (FCM)

FCM digunakan untuk mengirim push notification ke HP pengguna (reminder tagihan, budget alert, dll). FCM dari Google dan **selalu gratis tanpa batas**.

### 4.1 Buat Project Firebase

**Langkah 1 — Buka Firebase Console**
1. Buka https://console.firebase.google.com
2. Login dengan akun Google yang sama dengan Google AI Studio

**Langkah 2 — Buat project baru**
1. Klik **"Add project"** atau **"Create a project"**
2. Isi nama project: `finai` (atau nama apapun)
3. **Google Analytics:** pilih **"Enable Google Analytics"** → pilih akun atau buat baru
   - Ini opsional tapi berguna untuk tracking usage nantinya
4. Klik **"Create project"**
5. Tunggu beberapa detik, lalu klik **"Continue"**

**Langkah 3 — Tambahkan app Android ke Firebase**
1. Di dashboard Firebase, klik ikon **Android** (robot hijau)
2. Isi **Android package name** — ini harus sama persis dengan yang akan kamu gunakan di Flutter
   - Contoh: `com.namaapp.finai` atau `com.namakamu.finai`
   - **Catat package name ini** karena akan dipakai saat setup Flutter
3. **App nickname:** `FinAI Android` (opsional)
4. Klik **"Register app"**
5. **Download `google-services.json`** — simpan file ini, akan dibutuhkan di project Flutter nanti
6. Klik **"Next"** terus sampai selesai (instruksi SDK akan dikerjakan oleh AI agent)

**Langkah 4 — Tambahkan app iOS ke Firebase (jika perlu)**
1. Klik ikon **iOS** (buah apel)
2. Isi **iOS bundle ID** — contoh: `com.namaapp.finai`
3. **Download `GoogleService-Info.plist`** — simpan file ini
4. Klik **"Next"** terus sampai selesai

### 4.2 Dapatkan FCM Server Key

**Untuk FCM v1 API (yang terbaru dan disarankan):**

1. Di Firebase Console, klik **ikon gear** (Project settings) di sidebar kiri
2. Klik tab **"Service accounts"**
3. Di bagian **"Firebase Admin SDK"**, klik **"Generate new private key"**
4. Klik **"Generate key"** pada dialog konfirmasi
5. File JSON akan terdownload — namanya seperti `finai-firebase-adminsdk-xxx.json`
6. **Simpan file ini dengan aman** — ini adalah service account key untuk mengirim notifikasi dari server

> **Catatan penting:** FCM sekarang menggunakan sistem OAuth2 (service account), bukan lagi "Server Key" string sederhana. Cara kerjanya: Edge Function membaca file JSON ini untuk generate access token sementara setiap kali ingin kirim notifikasi. AI agent akan mengimplementasikan ini di Edge Function `send-notification`.

**Yang perlu dicatat dari file JSON tersebut:**
```
FCM_PROJECT_ID=finai-xxxxx           (ambil dari field "project_id" di JSON)
FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@finai-xxxxx.iam.gserviceaccount.com
FCM_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...  (seluruh isi field "private_key")
```

> Simpan ketiga nilai di atas, bukan file JSON-nya langsung, karena file JSON tidak bisa langsung dimasukkan ke environment variable.

---

## 5. Sentry

Sentry menangkap semua error/crash dari aplikasi Flutter maupun Edge Functions secara otomatis, lengkap dengan stack trace dan konteks, sehingga kamu tahu apa yang salah tanpa harus menunggu laporan dari user.

### 5.1 Buat Akun dan Project Sentry

**Langkah 1 — Daftar akun**
1. Buka https://sentry.io
2. Klik **"Get started for free"**
3. Daftar dengan GitHub, Google, atau email
4. Pilih plan **Free** (batas 5.000 error/bulan — lebih dari cukup untuk tahap awal)

**Langkah 2 — Buat Organization**
1. Setelah login, kamu akan diminta membuat organization
2. Isi nama: `FinAI` atau nama kamu
3. Klik **"Create Organization"**

**Langkah 3 — Buat project untuk Flutter (frontend)**
1. Klik **"Create project"**
2. Pilih platform: cari dan pilih **"Flutter"**
3. Set alert frequency: **"Alert me on every new issue"** (disarankan untuk awal)
4. Isi project name: `finai-flutter`
5. Klik **"Create project"**
6. Halaman berikutnya akan menampilkan DSN — catat:
   - **DSN:** `https://abc123@xxx.ingest.sentry.io/123456`
   - Simpan sebagai `SENTRY_DSN_FLUTTER`

**Langkah 4 — Buat project untuk Backend (Edge Functions)**
1. Klik **"Create project"** lagi
2. Pilih platform: **"JavaScript"** (untuk Deno/TypeScript)
3. Project name: `finai-backend`
4. Klik **"Create project"**
5. Catat DSN yang muncul → simpan sebagai `SENTRY_DSN_BACKEND`

**Setelah langkah ini kamu punya:**
```
SENTRY_DSN_FLUTTER=https://abc123@xxx.ingest.sentry.io/111111
SENTRY_DSN_BACKEND=https://def456@xxx.ingest.sentry.io/222222
```

---

## 6. Hosting Backend

### 6.1 Supabase ADALAH Backend Hosting-nya

Kabar baik: **kamu tidak perlu hosting server terpisah**. Supabase yang sudah kamu setup di bagian 2 sudah sekaligus menjadi hosting backend untuk FinAI. Ini yang sudah di-host Supabase secara otomatis:

| Komponen | Di-host di | Biaya |
|---|---|---|
| PostgreSQL Database | Supabase cloud | Gratis (500MB) |
| Auth (JWT, OAuth) | Supabase cloud | Gratis |
| File Storage | Supabase cloud | Gratis (1GB) |
| Edge Functions (serverless) | Supabase cloud (Deno) | Gratis (500rb invocations/bulan) |
| Realtime (WebSocket) | Supabase cloud | Gratis (200 koneksi) |

**Free tier Supabase lebih dari cukup untuk:**
- Development dan testing
- Aplikasi dengan ratusan pengguna aktif
- Hingga jutaan baris transaksi

**Kapan perlu upgrade?**
- Lebih dari 500MB data database → upgrade ke Pro ($25/bulan)
- Lebih dari 1GB file lampiran (foto struk) → tambah storage
- Lebih dari 500rb Edge Function calls/bulan → masih sangat jauh untuk awal

### 6.2 Cara Deploy Edge Functions ke Supabase

Ini dilakukan via Supabase CLI yang akan diinstal dan dijalankan oleh AI agent. Tapi kamu perlu tahu alurnya:

```
Kode Edge Function (TypeScript) di folder lokal
  → supabase functions deploy nama-function
  → Otomatis ter-deploy ke Supabase cloud
  → Langsung bisa dipanggil dari Flutter via HTTPS
```

Tidak ada proses build, tidak ada Docker, tidak ada server config. AI agent cukup menjalankan satu perintah CLI untuk deploy setiap function.

### 6.3 Cara Deploy Migrasi Database

Sama seperti Edge Functions, dilakukan via CLI:

```
File SQL migration di folder supabase/migrations/
  → supabase db push
  → SQL otomatis dijalankan di PostgreSQL Supabase
```

AI agent akan membuat file migration dari schema di PRD-01-DATABASE.md dan menjalankan satu perintah untuk apply ke database.

---

## 7. File .env Final yang Lengkap

Setelah menyelesaikan bagian 2–5, kamu akan memiliki semua nilai untuk mengisi file ini.  
Buat file bernama `.env` di root folder project FinAI.

> ⚠️ **PENTING:** Tambahkan `.env` ke `.gitignore` agar tidak ter-upload ke GitHub.

```env
# ================================================================
# SUPABASE — Database, Auth, Storage, Edge Functions
# Sumber: Supabase Dashboard > Project Settings > API
# ================================================================
SUPABASE_URL=https://XXXXXXXXXXXXXXXX.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-jwt-secret-from-settings
DATABASE_URL=postgresql://postgres:PASSWORD@db.XXXXXXXXXXXXXXXX.supabase.co:5432/postgres

# ================================================================
# GOOGLE GEMINI API — Satu-satunya AI service (teks, suara, gambar, chatbot)
# Sumber: https://aistudio.google.com > Get API key
# ================================================================
GEMINI_API_KEY=AIzaSy...
GEMINI_MODEL_TEXT=gemini-2.0-flash
GEMINI_MODEL_MULTIMODAL=gemini-2.0-flash

# ================================================================
# FIREBASE CLOUD MESSAGING — Push notification
# Sumber: Firebase Console > Project Settings > Service Accounts > Generate new private key
# Ambil nilai dari file JSON yang terdownload
# ================================================================
FCM_PROJECT_ID=finai-xxxxx
FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@finai-xxxxx.iam.gserviceaccount.com
FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAAS...\n-----END PRIVATE KEY-----\n"

# ================================================================
# SENTRY — Error tracking (dua project: Flutter dan Backend)
# Sumber: https://sentry.io > Project Settings > Client Keys (DSN)
# ================================================================
SENTRY_DSN_FLUTTER=https://abc123@xxx.ingest.sentry.io/111111
SENTRY_DSN_BACKEND=https://def456@xxx.ingest.sentry.io/222222

# ================================================================
# APP CONFIG
# ================================================================
APP_ENV=development
AI_DAILY_LIMIT_PER_USER=50
```

### 7.1 File .env.example (Aman untuk Dicommit ke GitHub)

Buat juga file `.env.example` yang berisi template tanpa nilai asli.  
File ini aman untuk dicommit ke GitHub sebagai referensi:

```env
# Salin file ini menjadi .env dan isi dengan nilai yang sebenarnya

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_JWT_SECRET=
DATABASE_URL=

GEMINI_API_KEY=
GEMINI_MODEL_TEXT=gemini-2.0-flash
GEMINI_MODEL_MULTIMODAL=gemini-2.0-flash

FCM_PROJECT_ID=
FCM_CLIENT_EMAIL=
FCM_PRIVATE_KEY=

SENTRY_DSN_FLUTTER=
SENTRY_DSN_BACKEND=

APP_ENV=development
AI_DAILY_LIMIT_PER_USER=50
```

---

## 8. Supabase CLI untuk AI Agent

AI agent membutuhkan Supabase CLI terinstal dan terkonfigurasi untuk bisa menjalankan migrasi database dan deploy Edge Functions. Ikuti langkah ini sebelum memberikan perintah ke AI agent.

### 8.1 Instal Supabase CLI

**Di macOS:**
```bash
brew install supabase/tap/supabase
```

**Di Windows (via Scoop):**
```bash
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

**Di Linux:**
```bash
curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz
sudo mv supabase /usr/local/bin/
```

**Verifikasi instalasi:**
```bash
supabase --version
# Output: supabase version x.x.x
```

### 8.2 Login Supabase CLI

```bash
supabase login
```

Browser akan terbuka → login dengan akun Supabase kamu → klik **"Authorize"**.

### 8.3 Inisialisasi Project Supabase di Folder Lokal

Di folder root project Flutter kamu:

```bash
supabase init
```

Ini akan membuat folder `supabase/` dengan struktur:
```
supabase/
├── config.toml          # Konfigurasi project
├── migrations/          # Folder untuk file SQL migration
│   └── .gitkeep
└── functions/           # Folder untuk Edge Functions
    └── .gitkeep
```

### 8.4 Hubungkan CLI dengan Project Supabase di Cloud

```bash
supabase link --project-ref XXXXXXXXXXXXXXXX
```

Ganti `XXXXXXXXXXXXXXXX` dengan **Project Reference ID** kamu.  
Cara menemukan Project Reference ID:
1. Buka Supabase Dashboard
2. Klik project kamu
3. Lihat URL di browser: `https://supabase.com/dashboard/project/XXXXXXXXXXXXXXXX`
4. Bagian `XXXXXXXXXXXXXXXX` itulah Project Reference ID

Setelah menjalankan perintah ini, CLI akan meminta **Database Password** yang kamu buat saat setup project. Masukkan password tersebut.

### 8.5 Set Environment Variables di Supabase (untuk Edge Functions)

Environment variables untuk Edge Functions TIDAK dibaca dari file `.env` lokal.  
Mereka harus diset di Supabase cloud menggunakan perintah CLI:

```bash
# Jalankan satu per satu — ganti nilainya dengan nilai asli dari file .env kamu

supabase secrets set GEMINI_API_KEY=AIzaSy...
supabase secrets set GEMINI_MODEL_TEXT=gemini-2.0-flash
supabase secrets set GEMINI_MODEL_MULTIMODAL=gemini-2.0-flash
supabase secrets set FCM_PROJECT_ID=finai-xxxxx
supabase secrets set FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@finai-xxxxx.iam.gserviceaccount.com
supabase secrets set SENTRY_DSN_BACKEND=https://def456@xxx.ingest.sentry.io/222222
supabase secrets set APP_ENV=development
supabase secrets set AI_DAILY_LIMIT_PER_USER=50

# Untuk FCM_PRIVATE_KEY yang mengandung newline, gunakan tanda kutip:
supabase secrets set FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...
-----END PRIVATE KEY-----"
```

**Verifikasi secrets sudah tersimpan:**
```bash
supabase secrets list
```

### 8.6 Jalankan Migrasi Database

Setelah AI agent membuat file SQL migration dari PRD-01-DATABASE.md, jalankan:

```bash
supabase db push
```

Perintah ini akan:
1. Membaca semua file `.sql` di folder `supabase/migrations/`
2. Menjalankannya secara berurutan di database PostgreSQL Supabase
3. Melaporkan status tiap migration (success/failed)

**Untuk melihat status migration:**
```bash
supabase migration list
```

### 8.7 Deploy Edge Functions

Setelah AI agent membuat kode Edge Functions, deploy dengan:

```bash
# Deploy satu function
supabase functions deploy ai-parse-text

# Deploy semua functions sekaligus
supabase functions deploy
```

**Verifikasi function sudah ter-deploy:**
```bash
supabase functions list
```

**Test function yang sudah di-deploy:**
```bash
# Ganti URL dengan URL project kamu
curl -X POST 'https://XXXXXXXXXXXXXXXX.supabase.co/functions/v1/health-score' \
  -H 'Authorization: Bearer SUPABASE_ANON_KEY' \
  -H 'Content-Type: application/json'
```

### 8.8 Struktur Folder yang Harus Ada Sebelum AI Agent Mulai

```
finai/                              ← root project Flutter
├── .env                            ← credentials (JANGAN commit ke git)
├── .env.example                    ← template aman (boleh commit)
├── .gitignore                      ← pastikan .env ada di sini
├── pubspec.yaml                    ← dependencies Flutter
├── lib/                            ← kode Flutter
├── supabase/
│   ├── config.toml                 ← dibuat oleh `supabase init`
│   ├── migrations/                 ← AI agent akan buat file SQL di sini
│   │   ├── 20250601000001_initial_schema.sql
│   │   ├── 20250601000002_seed_categories.sql
│   │   └── ...
│   └── functions/                  ← AI agent akan buat kode Edge Functions di sini
│       ├── _shared/
│       │   └── gemini.ts           ← helper Gemini (shared)
│       ├── ai-parse-text/
│       │   └── index.ts
│       ├── ai-parse-voice/
│       │   └── index.ts
│       ├── ai-parse-image/
│       │   └── index.ts
│       ├── ai-chat/
│       │   └── index.ts
│       ├── export-excel/
│       │   └── index.ts
│       ├── import-excel/
│       │   └── index.ts
│       ├── generate-recurring/
│       │   └── index.ts
│       ├── send-notification/
│       │   └── index.ts
│       └── health-score/
│           └── index.ts
└── android/
    └── app/
        └── google-services.json    ← file dari Firebase (untuk FCM Android)
```

---

## 9. Checklist Final

Sebelum memberikan perintah ke AI agent, pastikan semua item ini sudah selesai:

### Akun & Credentials
- [ ] Akun Supabase dibuat dan project `finai` sudah running
- [ ] `SUPABASE_URL` sudah dicatat
- [ ] `SUPABASE_ANON_KEY` sudah dicatat
- [ ] `SUPABASE_SERVICE_ROLE_KEY` sudah dicatat (rahasia!)
- [ ] `SUPABASE_JWT_SECRET` sudah dicatat
- [ ] `DATABASE_URL` sudah dicatat dengan password yang benar
- [ ] Gemini API key sudah dibuat di https://aistudio.google.com
- [ ] `GEMINI_API_KEY` sudah dicatat
- [ ] Firebase project sudah dibuat
- [ ] App Android sudah ditambahkan ke Firebase
- [ ] File `google-services.json` sudah didownload
- [ ] Service account key sudah di-generate dari Firebase
- [ ] `FCM_PROJECT_ID`, `FCM_CLIENT_EMAIL`, `FCM_PRIVATE_KEY` sudah dicatat
- [ ] Akun Sentry sudah dibuat
- [ ] Project `finai-flutter` dibuat di Sentry → `SENTRY_DSN_FLUTTER` dicatat
- [ ] Project `finai-backend` dibuat di Sentry → `SENTRY_DSN_BACKEND` dicatat

### Setup Lokal
- [ ] File `.env` sudah dibuat dan diisi dengan semua nilai di atas
- [ ] `.env` sudah ada di `.gitignore`
- [ ] File `.env.example` sudah dibuat (aman untuk dicommit)
- [ ] Supabase CLI sudah terinstal (`supabase --version`)
- [ ] Sudah login ke Supabase CLI (`supabase login`)
- [ ] Folder project sudah diinisialisasi (`supabase init`)
- [ ] CLI sudah dihubungkan ke project cloud (`supabase link`)
- [ ] Semua secrets sudah diset di Supabase (`supabase secrets set ...`)
- [ ] File `google-services.json` sudah ada di `android/app/`

### Siap Untuk AI Agent
- [ ] Semua checklist di atas selesai
- [ ] Folder `supabase/migrations/` dan `supabase/functions/` sudah ada
- [ ] Baca PRD-00-MASTER.md, PRD-01-DATABASE.md, PRD-02-BACKEND.md, PRD-03-FRONTEND.md

---

## Perintah Referensi Cepat (Quick Reference)

Simpan bagian ini untuk digunakan saat bekerja dengan AI agent:

```bash
# Cek status koneksi ke Supabase
supabase status

# Jalankan semua migration SQL ke database
supabase db push

# Reset database dan jalankan ulang semua migration (HATI-HATI: menghapus semua data)
supabase db reset

# Deploy satu Edge Function
supabase functions deploy nama-function

# Deploy semua Edge Functions
supabase functions deploy

# Lihat logs Edge Function secara live (berguna untuk debugging)
supabase functions logs nama-function --tail

# Lihat semua secrets yang tersimpan
supabase secrets list

# Update satu secret
supabase secrets set NAMA_KEY=nilai-baru

# Buka Supabase Studio (database GUI) di browser
supabase studio

# Buat file migration baru (AI agent akan mengisi isinya)
supabase migration new nama_migration
```

---

## Troubleshooting Umum

**"supabase: command not found"**  
→ CLI belum terinstal atau belum ada di PATH. Ulangi langkah instalasi di 8.1.

**"Error: Project not linked"**  
→ Jalankan `supabase link --project-ref XXXXXXXXXXXXXXXX` dulu.

**"Invalid API key" saat memanggil Edge Function**  
→ Pastikan kamu menggunakan `SUPABASE_ANON_KEY` (bukan `SERVICE_ROLE_KEY`) di header Authorization dari Flutter.

**Edge Function dapat dipanggil tapi AI tidak bekerja**  
→ Cek apakah `GEMINI_API_KEY` sudah di-set: `supabase secrets list`  
→ Cek logs: `supabase functions logs ai-parse-text --tail`

**"relation does not exist" di database**  
→ Migration belum dijalankan. Jalankan `supabase db push`.

**FCM notification tidak terkirim**  
→ Pastikan `FCM_PRIVATE_KEY` di-set dengan tanda kutip dan newline yang benar.  
→ Cek logs: `supabase functions logs send-notification --tail`

**Push notification tidak muncul di HP (Android)**  
→ Pastikan file `google-services.json` ada di folder `android/app/`  
→ Pastikan package name di Flutter sama persis dengan yang didaftarkan di Firebase.