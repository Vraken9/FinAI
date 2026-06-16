# FinAI — Product Requirements Document (Master)
**Versi:** 1.0.0  
**Tanggal:** Juni 2025  
**Status:** Draft untuk Review  
**Dokumen ini adalah induk dari seluruh PRD FinAI. Baca ini sebelum membaca dokumen lainnya.**

---

## Daftar Dokumen PRD

| Dokumen | Isi |
|---|---|
| `PRD-00-MASTER.md` | Visi, scope, fitur, roadmap (dokumen ini) |
| `PRD-01-DATABASE.md` | Schema database PostgreSQL lengkap (Supabase) |
| `PRD-02-BACKEND.md` | Arsitektur backend, Edge Functions, API contract, AI pipeline |
| `PRD-03-FRONTEND.md` | Arsitektur Flutter, struktur folder, semua halaman & state |

---

## 1. Visi & Tujuan Produk

### 1.1 Deskripsi Singkat
FinAI adalah aplikasi manajemen keuangan pribadi berbasis mobile (Flutter) yang mengintegrasikan kecerdasan buatan secara mendalam. Pengguna dapat mencatat transaksi melalui teks natural, suara, atau scan struk. AI memberikan analitik personal dan saran keuangan kontekstual berdasarkan data nyata pengguna.

### 1.2 Target Pengguna
Individu usia 17–35 tahun di Indonesia yang ingin mengelola keuangan pribadi namun merasa aplikasi pencatatan keuangan konvensional terlalu rumit atau membosankan.

### 1.3 Proposisi Nilai Utama
- Input transaksi secepat mengirim pesan WhatsApp (teks natural / suara / foto)
- AI yang benar-benar "tahu" kondisi keuangan pengguna dan memberi saran relevan
- Analitik visual yang langsung dapat diaksi (actionable), bukan sekadar angka

### 1.4 Tujuan Versi 1 (MVP)
1. Pengguna dapat mencatat semua transaksi dengan detail lengkap
2. AI dapat memproses input teks, suara, dan foto struk
3. Dashboard memberikan gambaran keuangan real-time
4. Chatbot AI mampu menjawab pertanyaan dan memberi saran personal
5. Analitik dengan visualisasi yang dapat difilter waktu
6. Budget per kategori yang dapat diatur user
7. Transfer antar aset dan transaksi berulang (recurring)
8. Export/import Excel dan backup data

---

## 2. Tech Stack Final

### 2.1 Frontend
| Komponen | Teknologi | Alasan |
|---|---|---|
| Framework | Flutter 3.x | Cross-platform iOS + Android, performa native |
| State management | Riverpod 2.x | Async-first, mudah testing, cocok untuk AI calls |
| Local database | Drift (SQLite) | Strongly typed, offline support, query kompleks |
| HTTP client | Dio | Interceptor untuk auth, retry, logging |
| Chart | FL Chart | Library chart Flutter terbaik, support semua jenis chart |
| Audio recording | record package | Input suara untuk AI |
| Image picker | image_picker | Lampiran foto dan scan struk |
| File export | open_file + path_provider | Download Excel |
| Error tracking | Sentry Flutter SDK | Crash reporting otomatis |
| Navigation | Go Router | Deep linking, declarative routing |

### 2.2 Backend
| Komponen | Teknologi | Alasan |
|---|---|---|
| Platform | Supabase | PostgreSQL + Auth + Storage + Edge Functions dalam satu platform, gratis untuk development |
| Database | PostgreSQL 15 (via Supabase) | ACID compliant, RLS built-in, JSON support |
| Auth | Supabase Auth | JWT, OAuth Google, email/password |
| File storage | Supabase Storage | Untuk lampiran foto dan file transaksi |
| Serverless functions | Supabase Edge Functions (Deno) | AI orchestration, export/import, webhook |
| Realtime | Supabase Realtime | Sync data antar device |

### 2.3 AI Services (External APIs)
| Layanan | Provider | Fungsi |
|---|---|---|
| NLU & Chatbot | Claude API (claude-sonnet-4-6) | Parse teks natural, chatbot analitis |
| Speech-to-text | OpenAI Whisper API | Konversi suara ke teks |
| OCR Struk | Google Cloud Vision API | Baca teks dari foto struk/invoice |
| Push notification | Firebase Cloud Messaging | Notifikasi budget, reminder |

### 2.4 DevOps & Monitoring
| Komponen | Teknologi |
|---|---|
| CI/CD | GitHub Actions + Codemagic |
| Error tracking | Sentry |
| Analytics | Firebase Analytics |
| Version control | GitHub |

---

## 3. Fitur Lengkap Versi 1

### 3.1 Autentikasi & Profil
- [x] Register dengan email + password
- [x] Login dengan email + password  
- [x] Login dengan Google OAuth
- [x] PIN lock / biometric (fingerprint/face ID) setelah login
- [x] Onboarding: setup saldo awal per aset
- [x] Profil pengguna (nama, foto, mata uang)
- [x] Session timeout otomatis (15 menit idle)

### 3.2 Manajemen Aset (Dompet)
- [x] Aset default: Cash, Rekening Bank, E-Wallet
- [x] User dapat menambah aset custom (nama + ikon + warna)
- [x] User dapat mengedit dan menghapus aset (dengan konfirmasi)
- [x] Saldo per aset ditampilkan di halaman utama
- [x] Total saldo adalah jumlah semua aset aktif

### 3.3 Transaksi Pengeluaran
Field wajib:
- [x] Tanggal dan waktu (default: sekarang, bisa diubah)
- [x] Nominal (wajib, bilangan positif)
- [x] Kategori (pilihan dari daftar + custom)
- [x] Aset yang digunakan (dari daftar aset user)

Field opsional:
- [x] Catatan singkat (max 100 karakter)
- [x] Deskripsi detail (max 500 karakter)
- [x] Merchant/kontak (tag nama toko/orang)
- [x] Lampiran foto atau file (max 5MB, format: jpg/png/pdf)

### 3.4 Transaksi Pemasukan
Field identik dengan pengeluaran, dengan tambahan:
- [x] Sumber pemasukan (field teks bebas, misal: "Gaji", "Freelance", "Bonus")
- [x] Aset tujuan (ke mana uang masuk)

### 3.5 Transfer Antar Aset
- [x] Tipe transaksi ketiga: "Transfer"
- [x] Field: aset asal, aset tujuan, nominal, tanggal, catatan
- [x] Tidak mempengaruhi total kekayaan bersih (saldo asal berkurang, tujuan bertambah)
- [x] Ditampilkan terpisah di riwayat (badge "Transfer")
- [x] Biaya transfer opsional (jika ada biaya admin)

### 3.6 Transaksi Berulang (Recurring)
- [x] Opsi "Jadikan berulang" di form transaksi
- [x] Frekuensi: harian, mingguan, dua mingguan, bulanan, tahunan
- [x] Tanggal berulang dapat dikustomisasi (misal: "setiap tanggal 15")
- [x] Sistem membuat draft transaksi otomatis pada tanggal yang ditentukan
- [x] Push notification H-1 dan di hari H: "Ada transaksi terjadwal, konfirmasi?"
- [x] User dapat confirm, skip, atau edit sebelum transaksi tersimpan
- [x] Halaman manajemen recurring transaction (lihat, edit, hapus)

### 3.7 Kategori Transaksi
Kategori default pengeluaran:
- Makanan & Minuman, Transportasi, Kesehatan, Belanja, Tagihan & Utilitas, Pendidikan, Hiburan, Perawatan Diri, Rumah Tangga, Lainnya

Kategori default pemasukan:
- Gaji, Freelance/Usaha, Investasi, Hadiah/Bonus, Lainnya

- [x] User dapat menambah kategori custom (nama + ikon + warna)
- [x] User dapat mengedit kategori custom
- [x] Kategori default tidak dapat dihapus (hanya disembunyikan)

### 3.8 Budget Per Kategori
- [x] User menetapkan batas pengeluaran per kategori per bulan (input manual)
- [x] Dashboard budget menampilkan: sudah terpakai / total budget / persentase
- [x] Progress bar visual per kategori
- [x] Notifikasi saat pengeluaran mencapai 80% budget
- [x] Notifikasi saat pengeluaran melampaui budget
- [x] AI chatbot dapat mereferensikan budget saat memberi saran
- [x] Budget bisa di-carry over atau reset tiap awal bulan (pilihan user)

### 3.9 Halaman Utama (Dashboard)
- [x] Greeting personal dengan nama user
- [x] Total saldo semua aset (dengan toggle tampil/sembunyikan)
- [x] Pemasukan dan pengeluaran bulan ini (dengan perbandingan bulan lalu)
- [x] AI Quick Input Bar (teks + ikon mikrofon + ikon kamera)
- [x] Grafik batang: pengeluaran harian dalam bulan ini
- [x] Widget "Kesehatan Keuangan" (skor 0–100)
- [x] Progress bar budget per kategori (top 3 yang paling kritis)
- [x] Reminder tagihan terjadwal yang akan jatuh tempo (3 hari ke depan)
- [x] Saran AI harian (1 insight otomatis berdasarkan data)
- [x] Daftar transaksi terbaru (5 item terakhir)

### 3.10 AI Input (Triple Mode)
**Mode 1 — Teks Natural:**
- [x] User mengetik: "makan siang nasi goreng 15rb + es teh 5rb"
- [x] AI memparse dan mengisi form: nominal Rp 20.000, kategori Makanan, aset Cash (default)
- [x] AI menambah deskripsi otomatis yang relevan
- [x] Hasil ditampilkan di form untuk divalidasi user sebelum disimpan

**Mode 2 — Suara:**
- [x] User menekan tombol mikrofon dan bicara
- [x] Whisper API mengkonversi suara ke teks
- [x] Teks dikirim ke Claude API untuk diparse sama seperti Mode 1
- [x] Hasil ditampilkan di form untuk divalidasi

**Mode 3 — Foto/Scan:**
- [x] User mengambil foto struk / invoice / nota
- [x] Google Vision API mengekstrak teks dari gambar (OCR)
- [x] Teks hasil OCR dikirim ke Claude API untuk diparse ke field transaksi
- [x] Jika ada beberapa item di struk, AI membuat satu transaksi dengan total
- [x] Foto asli otomatis dilampirkan ke transaksi sebagai bukti
- [x] Fallback: jika OCR gagal, form tetap terbuka dengan pesan error yang jelas

### 3.11 Chatbot AI Analitis
- [x] Akses ke seluruh data transaksi user (baca saja, tidak bisa tulis)
- [x] Dapat menjawab pertanyaan tentang pola pengeluaran
- [x] Dapat membandingkan periode (minggu ini vs minggu lalu, dst)
- [x] Saran personal berdasarkan konteks nyata (budget, saldo, pola belanja)
- [x] Dapat mendeteksi anomali: "Pengeluaran kamu hari ini 3x dari biasanya"
- [x] Aware terhadap pembelian serupa di periode yang sama (anti-duplikasi boros)
- [x] Riwayat percakapan tersimpan per sesi
- [x] Quick prompt suggestion (chip teks yang bisa diketuk)

### 3.12 Halaman Analitik
- [x] Filter periode: 7 hari, 30 hari, 3 bulan, 6 bulan, tahun ini, custom
- [x] Ringkasan: total pemasukan, pengeluaran, net balance, saving rate
- [x] Donut chart: distribusi pengeluaran per kategori + persentase
- [x] Line chart: tren pemasukan vs pengeluaran per periode
- [x] Bar chart: perbandingan antar bulan
- [x] Tabel top pengeluaran terbesar
- [x] AI insight di bawah setiap chart
- [x] Filter per aset (lihat analitik khusus satu dompet)
- [x] Tombol export PDF / Excel dari halaman ini

### 3.13 Pengaturan
- [x] Mode gelap / terang / ikuti sistem
- [x] Mata uang (default IDR, dapat diubah)
- [x] Format tanggal (DD/MM/YYYY atau MM/DD/YYYY)
- [x] PIN lock toggle + ubah PIN
- [x] Biometric toggle
- [x] Notifikasi: budget alert, recurring reminder, AI insight harian
- [x] Export ke Excel (seluruh data atau pilih rentang tanggal)
- [x] Import dari Excel (dengan template yang bisa diunduh)
- [x] Backup data manual ke cloud
- [x] Auto-backup toggle (harian/mingguan)
- [x] Form feedback pengguna (dengan rating + teks)
- [x] Laporan bug (dengan screenshot opsional, dikirim ke Sentry)
- [x] Versi aplikasi dan informasi

### 3.14 Error Handling & UX Robustness
- [x] Semua operasi async memiliki loading state yang jelas
- [x] Semua error API ditangkap dan ditampilkan dengan pesan ramah (bukan stack trace)
- [x] Operasi destruktif (hapus transaksi) selalu ada dialog konfirmasi
- [x] Offline mode: dapat input transaksi saat offline, sync saat online
- [x] Empty state yang didesain untuk semua halaman (bukan layar kosong)
- [x] Retry button untuk semua operasi network yang gagal
- [x] Form validation real-time dengan pesan error yang spesifik
- [x] Sentry otomatis merekam crash dengan konteks (tanpa data finansial sensitif)

---

## 4. Fitur yang TIDAK ada di Versi 1 (Backlog)

Fitur-fitur berikut disimpan untuk versi 2 agar scope MVP tetap terkendali:

- Tujuan tabungan (Savings Goals)
- Investasi tracking (saham, reksa dana, kripto)
- Laporan pajak otomatis
- Multi-currency per transaksi
- Sinkronisasi dengan rekening bank (Open Banking API)
- Widget home screen OS
- Apple Watch / Wear OS companion app
- Mode keluarga / shared account
- Langganan (subscription tracking)
- Kalkulator keuangan (cicilan, bunga, dst)

---

## 5. Roadmap Pengembangan

### Sprint 1–2 (Minggu 1–2): Fondasi
- Setup Supabase project dan semua tabel database
- Setup Flutter project dengan struktur folder lengkap
- Implementasi auth: register, login, Google OAuth
- Onboarding setup aset awal
- Manajemen aset (CRUD)

### Sprint 3–4 (Minggu 3–4): Core Transaksi
- Form input pengeluaran lengkap (semua field)
- Form input pemasukan lengkap
- Form transfer antar aset
- Validasi form real-time
- Riwayat transaksi dengan filter dan search
- Detail transaksi (edit & hapus)

### Sprint 5–6 (Minggu 5–6): Dashboard & Analitik
- Dashboard halaman utama (semua widget)
- Halaman analitik dengan semua chart
- Filter periode analitik
- Budget per kategori (setup, tracking, notifikasi)

### Sprint 7–8 (Minggu 7–8): AI Integration
- AI Input Mode 1: teks natural (Claude API)
- AI Input Mode 2: suara (Whisper → Claude)
- AI Input Mode 3: scan foto (Vision → Claude)
- Chatbot AI analitis dengan akses database

### Sprint 9–10 (Minggu 9–10): Fitur Tambahan & Polish
- Recurring transaction (setup, notifikasi, konfirmasi)
- Export Excel dan import Excel
- Backup otomatis
- Pengaturan lengkap (dark mode, notifikasi, PIN, biometric)
- Error handling komprehensif
- Sentry integration

### Sprint 11–12 (Minggu 11–12): QA & Launch
- Testing menyeluruh (unit test logika keuangan, integration test)
- Performance optimization
- Beta testing dengan user nyata (minimal 10 orang)
- Bug fixing
- Persiapan deploy ke App Store dan Play Store

---

## 6. Aturan Bisnis Kritis

Aturan-aturan ini WAJIB diimplementasikan dengan benar karena menyangkut akurasi data keuangan:

1. **Saldo tidak pernah negatif tanpa konfirmasi** — jika transaksi menyebabkan saldo aset negatif, tampilkan peringatan (bukan error hard-stop) dan minta konfirmasi user.
2. **Transfer bukan pengeluaran** — transfer antar aset TIDAK boleh mengubah total kekayaan bersih user.
3. **Soft delete saja** — transaksi yang dihapus ditandai `deleted_at`, tidak benar-benar dihapus dari database. Ini penting untuk integritas data analitik.
4. **Tanggal transaksi bisa di-backdate** — user bisa input transaksi kemarin atau seminggu lalu. Sistem harus menggunakan `transaction_date` user, bukan `created_at` server.
5. **Budget dihitung dari `transaction_date`** — bukan dari waktu input. Transaksi yang di-backdate mempengaruhi budget bulan yang sesuai.
6. **Recurring transaction adalah draft dulu** — sistem TIDAK menyimpan transaksi recurring secara otomatis. Selalu butuh konfirmasi user.
7. **AI tidak pernah menyimpan transaksi langsung** — AI hanya mengisi form. User yang menekan tombol simpan. Ini prinsip "human in the loop".
8. **Data keuangan tidak masuk ke log Sentry** — nominal, nama merchant, dan catatan transaksi TIDAK boleh dikirim ke Sentry. Hanya metadata error (tipe error, screen, timestamp).
9. **RLS Supabase wajib aktif** — setiap tabel yang berisi data user HARUS dilindungi Row Level Security. User hanya boleh mengakses data miliknya sendiri.
10. **Semua angka disimpan dalam satuan terkecil** — simpan dalam rupiah penuh (integer), bukan desimal. Tidak ada transaksi 0.01 rupiah.