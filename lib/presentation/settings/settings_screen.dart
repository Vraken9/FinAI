import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/services/export_service.dart';
import '../common/widgets/confirmation_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  void _updateProfile(String key, dynamic value) {
    ref.read(authNotifierProvider.notifier).updateProfile({key: value});
  }

  void _exportExcel() async {
    final transactions = ref.read(transactionNotifierProvider).valueOrNull ?? [];
    await ExportService.exportToExcel(context, transactions);
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Keluar',
        message: 'Yakin ingin keluar dari akun ini?',
        confirmText: 'Keluar',
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      ref.read(authNotifierProvider.notifier).logout();
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final profile = authState.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          // PROFIL USER
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.fullName, style: AppTextStyles.headline1.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Pengguna FinAI', style: AppTextStyles.body.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildSectionHeader('Tampilan'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema Gelap'),
            trailing: DropdownButton<String>(
              value: profile.theme,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'system', child: Text('Sistem')),
                DropdownMenuItem(value: 'light', child: Text('Terang')),
                DropdownMenuItem(value: 'dark', child: Text('Gelap')),
              ],
              onChanged: (val) {
                if (val != null) _updateProfile('theme', val);
              },
            ),
          ),
          const ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Mata Uang'),
            trailing: Text('IDR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Format Tanggal'),
            trailing: Text(profile.dateFormat, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),

          _buildSectionHeader('Akun'),
          ListTile(
            leading: const Icon(Icons.pie_chart_outline),
            title: const Text('Atur Anggaran'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/budget'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Kelola Dompet / Aset'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/assets'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Kelola Kategori'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/categories'),
          ),

          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export ke Excel'),
            onTap: _exportExcel,
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Import dari Excel'),
            onTap: () => context.push('/settings/import'),
          ),

          _buildSectionHeader('Notifikasi'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Peringatan Anggaran'),
            value: profile.budgetAlertEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => _updateProfile('budget_alert_enabled', val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.event_repeat_outlined),
            title: const Text('Pengingat Tagihan Rutin'),
            value: profile.recurringReminderEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => _updateProfile('recurring_reminder_enabled', val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.insights_outlined),
            title: const Text('Insight AI Pintar'),
            value: profile.aiInsightEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => _updateProfile('ai_insight_enabled', val),
          ),

          _buildSectionHeader('Lainnya'),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Beri Masukan'),
            onTap: () => context.push('/settings/feedback'),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Laporkan Bug'),
            onTap: () => context.push('/settings/feedback?source=bug_report'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versi Aplikasi'),
            trailing: Text(_appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.expense),
            title: const Text('Keluar', style: TextStyle(color: AppColors.expense)),
            onTap: _logout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
