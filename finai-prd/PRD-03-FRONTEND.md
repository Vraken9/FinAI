# FinAI — PRD Frontend (Flutter)
**Versi:** 1.0.0  
**Dokumen:** PRD-03-FRONTEND  
**Framework:** Flutter 3.x + Dart 3.x  
**State Management:** Riverpod 2.x  
**Baca PRD-00-MASTER.md terlebih dahulu.**

---

## 1. Struktur Folder Project Flutter

```
lib/
├── main.dart                    # Entry point, setup Riverpod & Supabase
├── app.dart                     # MaterialApp + GoRouter setup + theme
│
├── core/                        # Kode yang digunakan di seluruh app
│   ├── constants/
│   │   ├── app_colors.dart      # Semua warna (light + dark)
│   │   ├── app_text_styles.dart # Semua text style
│   │   ├── app_icons.dart       # Mapping nama icon ke IconData
│   │   └── app_strings.dart     # Semua string (untuk i18n nanti)
│   ├── exceptions/
│   │   ├── app_exception.dart   # Base exception class
│   │   └── api_exception.dart   # HTTP/API specific exceptions
│   ├── extensions/
│   │   ├── currency_extension.dart   # int.toCurrency() → "Rp 20.000"
│   │   ├── datetime_extension.dart   # DateTime.toRelative() → "Kemarin"
│   │   └── string_extension.dart
│   ├── router/
│   │   └── app_router.dart      # GoRouter: semua route definition
│   ├── services/
│   │   ├── supabase_service.dart       # Singleton Supabase client
│   │   ├── secure_storage_service.dart # Flutter secure storage untuk PIN
│   │   ├── biometric_service.dart      # local_auth package
│   │   ├── notification_service.dart   # FCM setup + handling
│   │   └── sentry_service.dart         # Sentry init + helpers
│   └── utils/
│       ├── validators.dart       # Form validation functions
│       └── formatters.dart       # Number formatting, date formatting
│
├── data/                        # Data layer (repositories + models)
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── asset.dart
│   │   ├── category.dart
│   │   ├── transaction.dart
│   │   ├── transaction_attachment.dart
│   │   ├── budget.dart
│   │   ├── recurring_rule.dart
│   │   ├── ai_conversation.dart
│   │   ├── ai_message.dart
│   │   └── parsed_transaction.dart  # Response dari AI parse
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── asset_repository.dart
│   │   ├── category_repository.dart
│   │   ├── transaction_repository.dart
│   │   ├── budget_repository.dart
│   │   ├── recurring_repository.dart
│   │   └── ai_repository.dart       # Panggil Edge Functions AI
│   └── local/
│       ├── drift_database.dart      # Drift (SQLite) setup
│       └── drift_tables.dart        # Definisi tabel lokal
│
├── providers/                   # Riverpod providers
│   ├── auth_provider.dart
│   ├── asset_provider.dart
│   ├── category_provider.dart
│   ├── transaction_provider.dart
│   ├── budget_provider.dart
│   ├── analytics_provider.dart
│   ├── recurring_provider.dart
│   └── ai_provider.dart
│
└── presentation/                # UI layer
    ├── common/                  # Widget yang dipakai di banyak tempat
    │   ├── widgets/
    │   │   ├── amount_display.dart       # Tampilan nominal Rupiah
    │   │   ├── category_icon.dart        # Ikon kategori dengan warna
    │   │   ├── asset_chip.dart           # Chip nama aset
    │   │   ├── transaction_list_item.dart
    │   │   ├── empty_state.dart          # Widget empty state dengan ilustrasi
    │   │   ├── error_state.dart          # Widget error state dengan retry
    │   │   ├── loading_skeleton.dart     # Shimmer loading
    │   │   ├── confirmation_dialog.dart  # Dialog konfirmasi destruktif
    │   │   ├── ai_loading_indicator.dart # Animasi loading AI
    │   │   └── custom_bottom_sheet.dart  # Bottom sheet yang konsisten
    │   └── layouts/
    │       └── main_scaffold.dart        # Scaffold utama dengan bottom nav
    │
    ├── auth/                    # Halaman autentikasi
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   ├── onboarding_screen.dart        # Setup awal setelah register
    │   └── pin_lock_screen.dart
    │
    ├── home/                    # Dashboard utama
    │   ├── home_screen.dart
    │   └── widgets/
    │       ├── balance_card.dart
    │       ├── summary_cards.dart
    │       ├── ai_quick_input.dart       # Bar input AI (teks + mic + kamera)
    │       ├── daily_expense_chart.dart  # Chart bar harian
    │       ├── health_score_widget.dart
    │       ├── budget_progress_strip.dart
    │       ├── upcoming_recurring.dart
    │       ├── ai_daily_insight.dart
    │       └── recent_transactions.dart
    │
    ├── transaction/             # Halaman transaksi
    │   ├── add_transaction_screen.dart   # Form tambah (expense/income/transfer)
    │   ├── transaction_detail_screen.dart
    │   ├── transaction_list_screen.dart  # Semua transaksi + filter + search
    │   └── widgets/
    │       ├── amount_input.dart         # Input nominal khusus
    │       ├── category_picker.dart      # Bottom sheet pilih kategori
    │       ├── asset_picker.dart         # Bottom sheet pilih aset
    │       ├── date_time_picker.dart
    │       ├── attachment_picker.dart    # Upload foto/file
    │       ├── ai_fill_button.dart       # Tombol "Isi dengan AI"
    │       ├── recurring_setup.dart      # Setup recurring di form
    │       └── type_toggle.dart          # Toggle expense/income/transfer
    │
    ├── ai_input/                # Halaman AI input (modal)
    │   ├── ai_text_input_sheet.dart      # Bottom sheet input teks natural
    │   ├── ai_voice_input_sheet.dart     # Rekam suara + animasi
    │   └── ai_scan_screen.dart           # Kamera + preview hasil scan
    │
    ├── analytics/               # Halaman analitik
    │   ├── analytics_screen.dart
    │   └── widgets/
    │       ├── period_filter_tabs.dart
    │       ├── summary_stats_row.dart
    │       ├── expense_donut_chart.dart
    │       ├── income_expense_line_chart.dart
    │       ├── monthly_bar_chart.dart
    │       ├── top_expenses_list.dart
    │       └── ai_analytics_insight.dart
    │
    ├── chatbot/                 # Halaman chatbot AI
    │   ├── chatbot_screen.dart
    │   └── widgets/
    │       ├── chat_message_bubble.dart
    │       ├── chat_input_bar.dart
    │       └── quick_prompt_chips.dart
    │
    ├── budget/                  # Halaman budget
    │   ├── budget_screen.dart
    │   ├── add_budget_screen.dart
    │   └── widgets/
    │       └── budget_category_card.dart
    │
    ├── recurring/               # Halaman recurring transactions
    │   ├── recurring_screen.dart
    │   ├── recurring_detail_screen.dart
    │   └── widgets/
    │       └── recurring_rule_card.dart
    │
    ├── settings/                # Halaman pengaturan
    │   ├── settings_screen.dart
    │   ├── manage_assets_screen.dart     # CRUD aset
    │   ├── manage_categories_screen.dart # CRUD kategori custom
    │   ├── export_screen.dart
    │   ├── import_screen.dart
    │   ├── backup_screen.dart
    │   ├── feedback_screen.dart
    │   └── widgets/
    │       └── settings_list_item.dart
    │
    └── onboarding/
        ├── welcome_screen.dart
        ├── setup_assets_screen.dart      # Input saldo awal
        └── setup_budget_screen.dart      # Setup budget awal (opsional)
```

---

## 2. Routing (GoRouter)

```dart
// lib/core/router/app_router.dart
final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    final isOnboarded = ref.read(authProvider).isOnboarded;
    final isPinLocked = ref.read(authProvider).isPinLocked;
    
    if (!isLoggedIn) return '/auth/login';
    if (isPinLocked) return '/pin-lock';
    if (!isOnboarded) return '/onboarding';
    return null; // lanjut ke route tujuan
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/pin-lock', builder: (_, __) => PinLockScreen()),
    GoRoute(path: '/auth/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/auth/register', builder: (_, __) => RegisterScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => OnboardingScreen()),
    
    // Shell route untuk bottom nav
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
        GoRoute(path: '/analytics', builder: (_, __) => AnalyticsScreen()),
        GoRoute(path: '/chatbot', builder: (_, __) => ChatbotScreen()),
        GoRoute(path: '/settings', builder: (_, __) => SettingsScreen()),
        
        // Sub-routes
        GoRoute(
          path: '/transaction/add',
          builder: (_, state) => AddTransactionScreen(
            initialType: state.uri.queryParameters['type']
          )
        ),
        GoRoute(
          path: '/transaction/:id',
          builder: (_, state) => TransactionDetailScreen(id: state.pathParameters['id']!)
        ),
        GoRoute(path: '/budget', builder: (_, __) => BudgetScreen()),
        GoRoute(path: '/budget/add', builder: (_, __) => AddBudgetScreen()),
        GoRoute(path: '/recurring', builder: (_, __) => RecurringScreen()),
        GoRoute(path: '/settings/assets', builder: (_, __) => ManageAssetsScreen()),
        GoRoute(path: '/settings/categories', builder: (_, __) => ManageCategoriesScreen()),
        GoRoute(path: '/settings/export', builder: (_, __) => ExportScreen()),
        GoRoute(path: '/settings/import', builder: (_, __) => ImportScreen()),
        GoRoute(path: '/settings/feedback', builder: (_, __) => FeedbackScreen()),
      ]
    ),
  ]
);
```

---

## 3. State Management (Riverpod)

### 3.1 Provider Utama

```dart
// lib/providers/transaction_provider.dart

// State untuk daftar transaksi dengan filter
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build({
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    // Watch filter changes dan refetch otomatis
    return ref.read(transactionRepositoryProvider)
      .getTransactions(filter: filter);
  }

  Future<void> addTransaction(CreateTransactionParams params) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(transactionRepositoryProvider).create(params);
      ref.invalidateSelf(); // refresh list
      ref.invalidate(dashboardSummaryProvider); // refresh dashboard
      ref.invalidate(budgetProgressProvider);   // refresh budget
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      SentryService.captureException(e, st);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await ref.read(transactionRepositoryProvider).softDelete(id);
      ref.invalidateSelf();
      ref.invalidate(dashboardSummaryProvider);
    } catch (e, st) {
      SentryService.captureException(e, st);
      rethrow; // biarkan UI handle untuk show error
    }
  }
}

// State untuk AI parsing
@riverpod
class AiParseState extends _$AiParseState {
  @override
  AiParseStatus build() => const AiParseStatus.idle();

  Future<ParsedTransaction?> parseText(String text) async {
    state = const AiParseStatus.loading();
    try {
      final result = await ref.read(aiRepositoryProvider).parseText(text);
      state = AiParseStatus.success(result);
      return result;
    } on ApiException catch (e) {
      state = AiParseStatus.error(e.userFriendlyMessage);
      return null;
    }
  }

  void reset() => state = const AiParseStatus.idle();
}
```

### 3.2 Model Data Utama

```dart
// lib/data/models/transaction.dart
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required TransactionType type,
    required int amount,           // dalam Rupiah (integer)
    required DateTime transactionDate,
    String? categoryId,
    required String assetId,
    String? transferToAssetId,
    int? transferFee,
    String? note,
    String? description,
    String? merchant,
    String? incomeSource,
    String? recurringRuleId,
    required bool aiGenerated,
    String? aiInputType,
    required TransactionStatus status,
    required DateTime createdAt,
    DateTime? deletedAt,
    
    // Joined data (tidak disimpan, diambil dari join)
    Category? category,
    Asset? asset,
    Asset? transferToAsset,
    List<TransactionAttachment>? attachments,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) 
    => _$TransactionFromJson(json);
}

enum TransactionType { income, expense, transfer }
enum TransactionStatus { confirmed, draft, skipped }
```

---

## 4. Spesifikasi Halaman

### 4.1 Halaman: Home (Dashboard)

**State:** `dashboardSummaryProvider` (auto-refresh setiap kali ada perubahan transaksi)

**Widget tree utama:**
```
HomeScreen
└── RefreshIndicator (pull to refresh)
    └── CustomScrollView
        ├── BalanceCard
        │   ├── Total saldo (toggle tampil/sembunyikan)
        │   ├── Pemasukan bulan ini
        │   └── Pengeluaran bulan ini
        ├── SummaryCardsRow
        │   ├── Saving rate bulan ini
        │   └── Perbandingan vs bulan lalu (persentase)
        ├── AiQuickInput
        │   ├── TextField placeholder: 'Ketik... "makan siang 25rb"'
        │   ├── IconButton mikrofon → ai_voice_input_sheet.dart
        │   └── IconButton kamera → ai_scan_screen.dart
        ├── HealthScoreWidget (tap → penjelasan skor)
        ├── BudgetProgressStrip (top 3 kategori kritis)
        ├── UpcomingRecurringWidget (jika ada dalam 3 hari)
        ├── DailyExpenseChart (bar chart 30 hari terakhir)
        ├── AiDailyInsight (collapsible, refresh 1x per hari)
        └── RecentTransactions (5 item, tap "Lihat semua" → /transaction/list)
```

**Behavior:**
- Pull to refresh: refresh semua data
- Tap balance card → toggle tampil/sembunyikan nominal
- Tap AI Quick Input bar → fokus ke TextField dan keyboard muncul
- Tap mikrofon → buka `AiVoiceInputSheet`
- Tap kamera → buka `AiScanScreen`
- Long press transaksi di recent list → quick action (edit, hapus)

---

### 4.2 Halaman: Tambah Transaksi

**Route:** `/transaction/add?type=expense`

**Tab di bagian atas:** Pengeluaran | Pemasukan | Transfer

**State machine form:**
```
FormState {
  type: TransactionType,
  amount: int?,
  date: DateTime,
  categoryId: String?,
  assetId: String?,
  transferToAssetId: String?,   // hanya untuk transfer
  note: String,
  description: String,
  merchant: String,
  attachments: List<File>,
  recurringEnabled: bool,
  recurringFrequency: String?,
  
  // AI state
  isAiFilling: bool,
  aiFilledFields: Set<String>,  // track field mana yang diisi AI (tampilkan highlight)
}
```

**Widget form (urutan dari atas ke bawah):**
1. `AiFillButton` — "Isi dengan AI" (membuka AiTextInputSheet)
2. Divider "atau isi manual"
3. `AmountInput` — input nominal besar di tengah
4. `DateTimePicker` — tanggal + waktu (default: sekarang)
5. `CategoryPicker` — grid ikon kategori (bottom sheet)
6. `AssetPicker` — chip aset (bottom sheet)
7. Transfer fields (jika tipe = Transfer): aset tujuan + biaya transfer
8. `TextFormField` — Catatan singkat (max 100 char, counter)
9. `TextFormField` — Deskripsi (max 500 char, multiline)
10. `TextFormField` — Merchant/kontak
11. `AttachmentPicker` — upload foto/file (preview thumbnail jika ada)
12. `RecurringSetup` — expandable section
13. `ElevatedButton` — "Simpan"

**Validasi real-time:**
- Nominal: wajib, > 0, max 999.999.999.999
- Kategori: wajib (kecuali transfer)
- Aset: wajib
- Tanggal: tidak boleh lebih dari 5 tahun ke belakang atau masa depan

**Behavior AI fill:**
1. User tap "Isi dengan AI" → `AiTextInputSheet` terbuka sebagai bottom sheet
2. User ketik teks → tap "Proses"
3. Loading indicator (animasi AI)
4. Hasil parse ditampilkan di form dengan highlight kuning di field yang diisi AI
5. User review dan bisa edit field manapun
6. Tap "Simpan" untuk menyimpan transaksi

---

### 4.3 Halaman: AI Voice Input Sheet

```dart
// Tampilan bottom sheet rekam suara
AiVoiceInputSheet:
  - Animasi waveform saat merekam
  - Timer durasi rekaman
  - Tombol besar merah (tap untuk mulai, tap lagi untuk berhenti)
  - Transkripsi muncul real-time saat selesai
  - Tombol "Proses" setelah ada transkripsi
  - Tombol "Rekam ulang"
  - Maksimum durasi: 60 detik
```

**Flow:**
1. Sheet terbuka → minta izin microphone jika belum ada
2. User tap tombol → mulai rekam (countdown timer)
3. User tap lagi atau otomatis setelah 60 detik → stop rekam
4. Loading: "Mentranskripsi suara..."
5. Transkripsi ditampilkan
6. User tap "Proses" → loading "AI sedang menganalisis..."
7. Berhasil → sheet tutup, form terisi, notifikasi sukses
8. Gagal → pesan error yang jelas + opsi "Isi manual"

---

### 4.4 Halaman: AI Scan Screen

```dart
// Full screen kamera untuk scan struk
AiScanScreen:
  - CameraPreview full screen
  - Overlay guide (bingkai area scan)
  - Tips: "Pastikan seluruh struk terlihat dan pencahayaan cukup"
  - Tombol shutter besar di bawah
  - Tombol galeri (pilih dari galeri)
  - Flash toggle
  - Cancel button
```

**Flow:**
1. Screen terbuka → minta izin kamera
2. User foto → preview foto ditampilkan
3. Tombol "Gunakan foto ini" atau "Foto ulang"
4. Loading full-screen: "AI sedang membaca struk..."
5. Progress: OCR dulu → parse transaksi
6. Berhasil → navigasi ke form dengan field terisi + foto dilampirkan otomatis
7. Gagal OCR → pesan "Foto kurang jelas. Coba lagi atau isi manual." + form kosong

---

### 4.5 Halaman: Analitik

**Filter periode:** chip tabs horizontal (7H | 30H | 3B | 6B | Tahun | Custom)

**Sections:**
1. **Summary row** — Total Pemasukan | Total Pengeluaran | Net | Saving Rate
2. **Donut chart** — distribusi pengeluaran per kategori
   - Legend di bawah dengan persentase
   - Tap slice → highlight + tampilkan detail kategori
3. **Line chart** — tren pemasukan vs pengeluaran per periode
   - Toggle: harian / mingguan / bulanan
4. **Bar chart** — perbandingan bulanan (3–6 bulan terakhir)
5. **Top pengeluaran** — list 5 transaksi terbesar di periode ini
6. **AI insight** — analisis otomatis dari AI berdasarkan data ini
7. **Export button** — export data periode ini ke Excel/PDF

---

### 4.6 Halaman: Chatbot AI

**Layout:**
- AppBar: foto + nama "FinAI Advisor" + status "Online"
- Chat messages (scrollable, newest at bottom)
- Quick prompt chips di atas input (saran pertanyaan)
- Input bar: TextField + tombol mikrofon + tombol kirim

**Quick prompt suggestions (berputar berdasarkan konteks):**
- "Berapa pengeluaran makananku bulan ini?"
- "Apakah keuanganku sehat?"  
- "Di mana aku paling boros?"
- "Berikan saran menabung untukku"
- "Bandingkan pengeluaranku dengan bulan lalu"

**Message bubble:**
- User: aligned right, warna primary
- AI: aligned left, warna surface, dengan avatar robot kecil
- AI loading: tiga titik animasi
- AI error: bubble merah dengan "Coba tanya lagi"

**Konteks AI:** setiap request menyertakan ringkasan keuangan terbaru user (dari `get_user_financial_summary` function)

---

### 4.7 Halaman: Budget

**Layout:**
- Header: bulan yang dipilih (bisa ganti bulan dengan swipe atau picker)
- Total budget vs total pengeluaran bulan ini
- List kartu budget per kategori:
  - Nama kategori + ikon
  - Progress bar (hijau < 60%, kuning 60–90%, merah > 90%)
  - "Rp X dari Rp Y" + persentase
  - Tap → detail transaksi di kategori ini

**FAB:** + Tambah Budget (untuk kategori yang belum ada budget)

**Empty state:** "Belum ada budget. Tap + untuk mulai mengatur anggaran."

---

### 4.8 Halaman: Recurring Transactions

**List item tiap rule:**
- Ikon kategori + nama
- "Rp X setiap [frekuensi]"
- Jatuh tempo berikutnya: "5 hari lagi"
- Badge status: Aktif / Tidak Aktif

**Notifikasi draft:**
- Saat ada draft recurring yang pending, tampilkan banner di atas list
- "2 transaksi terjadwal menunggu konfirmasi"
- Tap → daftar draft untuk di-confirm/skip

---

### 4.9 Halaman: Import Excel

**Step 1 — Upload:**
- Tombol upload file .xlsx
- Link download template Excel
- Penjelasan format kolom yang diterima

**Step 2 — Preview validasi:**
- Tabel preview 5 baris pertama
- Summary: "X baris valid, Y baris bermasalah"
- List error per baris: "Baris 3: Kategori 'Ojol' tidak ditemukan"
- Tombol "Import X transaksi" (hanya yang valid)
- Tombol "Batalkan"

**Step 3 — Konfirmasi:**
- Dialog konfirmasi: "Import 45 transaksi. Lanjutkan?"
- Progress bar saat import berlangsung
- Sukses: "45 transaksi berhasil diimport"

---

## 5. Desain & Tema

### 5.1 Color Scheme

```dart
// lib/core/constants/app_colors.dart
class AppColors {
  // Primary
  static const primary = Color(0xFF1A1A2E);      // Dark navy
  static const primaryAccent = Color(0xFF639922); // Green accent
  static const secondary = Color(0xFF185FA5);     // Blue

  // Semantic
  static const income = Color(0xFF3B6D11);         // Dark green
  static const expense = Color(0xFFA32D2D);         // Dark red
  static const transfer = Color(0xFF185FA5);        // Blue
  static const warning = Color(0xFFBA7517);         // Amber
  
  // Neutrals
  static const surface = Color(0xFFF8F8F6);
  static const surfaceDark = Color(0xFF1C1C1E);
  
  // Budget status
  static const budgetSafe = Color(0xFF3B6D11);     // < 60%
  static const budgetWarning = Color(0xFFBA7517);  // 60–90%
  static const budgetOver = Color(0xFFA32D2D);     // > 90%
}
```

### 5.2 Typography

```dart
// Semua text style menggunakan Google Fonts: Inter
static const TextStyle headline1 = TextStyle(
  fontSize: 28, fontWeight: FontWeight.w500, letterSpacing: -0.5
);
static const TextStyle amountLarge = TextStyle(
  fontSize: 32, fontWeight: FontWeight.w500, letterSpacing: -1
);
static const TextStyle body = TextStyle(
  fontSize: 14, fontWeight: FontWeight.w400, height: 1.5
);
static const TextStyle caption = TextStyle(
  fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary
);
```

---

## 6. Offline Mode & Sync

### 6.1 Drift Local Database

Tabel yang di-cache lokal (untuk offline access):
- `local_transactions` — last 3 bulan
- `local_assets`
- `local_categories`
- `local_budgets`

### 6.2 Sync Strategy

```dart
// lib/data/repositories/transaction_repository.dart

Future<void> addTransaction(CreateTransactionParams params) async {
  // 1. Simpan ke local Drift database dulu (selalu berhasil)
  final localId = await _localDb.insertTransaction(params);
  
  // 2. Coba sync ke Supabase
  try {
    await _supabase.from('transactions').insert(params.toJson());
    // Mark sebagai synced
    await _localDb.markSynced(localId);
  } on SocketException {
    // Offline: simpan sebagai "pending sync"
    await _localDb.markPendingSync(localId);
    // Akan di-sync saat koneksi kembali
  }
}

// Connectivity listener untuk auto-sync
final connectivitySubscription = Connectivity()
  .onConnectivityChanged
  .listen((result) {
    if (result != ConnectivityResult.none) {
      _syncPendingTransactions();
    }
  });
```

---

## 7. Error Handling di Flutter

### 7.1 Global Error Handler

```dart
// lib/main.dart
FlutterError.onError = (details) {
  SentryService.captureFlutterError(details);
};

PlatformDispatcher.instance.onError = (error, stack) {
  SentryService.captureException(error, stack);
  return true;
};
```

### 7.2 API Error Handling di UI

```dart
// Pattern standar untuk semua screen
ref.listen(someProvider, (prev, next) {
  next.whenOrNull(
    error: (error, _) {
      if (error is ApiException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.userFriendlyMessage),
            action: error.isRetryable 
              ? SnackBarAction(label: 'Coba lagi', onPressed: retry)
              : null,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
  );
});
```

### 7.3 User Feedback untuk Error AI

```dart
// Widget khusus untuk error state AI
class AiErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onManualInput;
  
  @override
  Widget build(BuildContext context) => Column(
    children: [
      // Ikon ramah (bukan ikon error merah)
      Icon(Icons.psychology_alt, size: 48, color: Colors.grey),
      Text(message),
      Row(children: [
        OutlinedButton(onPressed: onRetry, child: Text('Coba lagi')),
        ElevatedButton(onPressed: onManualInput, child: Text('Isi manual')),
      ])
    ]
  );
}
```

---

## 8. Notifikasi (FCM)

### 8.1 Tipe Notifikasi

| ID | Judul | Isi | Trigger |
|---|---|---|---|
| `budget_80` | Anggaran hampir habis | "[Kategori] sudah 80% dari budget bulan ini" | Saat pengeluaran mencapai 80% budget |
| `budget_over` | Anggaran terlampaui | "[Kategori] sudah melebihi budget Rp X" | Saat pengeluaran > budget |
| `recurring_reminder` | Tagihan terjadwal | "[Nama] Rp X jatuh tempo besok. Konfirmasi?" | H-1 dari tanggal jatuh tempo |
| `recurring_today` | Konfirmasi transaksi | "[Nama] Rp X hari ini. Ketuk untuk konfirmasi" | Di hari H |
| `ai_insight` | Insight keuangan | Teks insight dari AI | 1x sehari (pagi hari) |

### 8.2 Deep Link dari Notifikasi

- `budget_*` → `/budget`
- `recurring_*` → `/recurring`  
- `ai_insight` → `/home`

---

## 9. Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Supabase
  supabase_flutter: ^2.5.0
  
  # Local DB
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  
  # HTTP
  dio: ^5.4.0
  
  # Charts
  fl_chart: ^0.68.0
  
  # UI
  google_fonts: ^6.2.0
  shimmer: ^3.0.0
  
  # Media
  image_picker: ^1.1.0
  record: ^5.1.0           # Audio recording
  camera: ^0.11.0
  
  # File
  file_picker: ^8.0.0
  open_file: ^3.3.2
  path_provider: ^2.1.0
  share_plus: ^9.0.0
  
  # Auth & Security
  local_auth: ^2.2.0        # Biometric
  flutter_secure_storage: ^9.0.0
  
  # Connectivity & Network
  connectivity_plus: ^6.0.0
  
  # Notifications
  firebase_messaging: ^14.9.0
  flutter_local_notifications: ^17.0.0
  
  # Error tracking
  sentry_flutter: ^8.3.0
  
  # Utils
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
  intl: ^0.19.0
  uuid: ^4.4.0
  equatable: ^2.0.5

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  drift_dev: ^2.18.0
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0
```

---

## 10. Testing Strategy

### 10.1 Unit Tests (Wajib)
- Semua logika kalkulasi keuangan (saldo, budget progress, health score)
- Semua repository functions (mock Supabase)
- Currency formatter dan extension

### 10.2 Widget Tests
- Form tambah transaksi (validasi)
- AI fill flow (mock AI response)
- Empty state dan error state tiap halaman

### 10.3 Integration Tests
- Full flow: login → tambah transaksi → cek di dashboard
- AI parse text flow
- Export Excel flow

```dart
// Contoh unit test
test('Budget progress dihitung dengan benar', () {
  const budget = Budget(amount: 500000, ...);
  const spent = 350000;
  final progress = BudgetCalculator.calculateProgress(budget, spent);
  
  expect(progress.percentage, equals(70.0));
  expect(progress.status, equals(BudgetStatus.warning)); // 60-90%
  expect(progress.remaining, equals(150000));
});
```