import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/exceptions/app_exception.dart';
import '../../data/models/asset.dart';
import '../../providers/asset_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SetupAssetsScreen extends ConsumerStatefulWidget {
  const SetupAssetsScreen({super.key});

  @override
  ConsumerState<SetupAssetsScreen> createState() => _SetupAssetsScreenState();
}

class _SetupAssetsScreenState extends ConsumerState<SetupAssetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _balanceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('VALIDASI FORM GAGAL');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final rawValue = _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final initialBalance = int.tryParse(rawValue) ?? 0;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw AppException('User session tidak ditemukan');
      }

      final newAsset = Asset(
        id: '', // Will be removed in repository before insert
        userId: userId,
        name: 'Cash',
        icon: 'wallet',
        color: '#185FA5',
        assetType: 'cash',
        initialBalance: initialBalance,
        isDefault: true,
        isActive: true,
        sortOrder: 0,
      );

      await ref.read(assetNotifierProvider.notifier).createAsset(newAsset);

      await ref.read(authNotifierProvider.notifier).completeOnboarding();
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.userFriendlyMessage),
          backgroundColor: AppColors.expense,
        ),
      );
    } catch (e) {
      debugPrint('Setup asset error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyiapkan dompet: $e'),
          backgroundColor: AppColors.expense,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saldo Awal'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Berapa saldo yang Anda miliki saat ini?',
                    style: AppTextStyles.headline1.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saldo ini akan menjadi dompet utama Anda',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 32),
                  
                  TextFormField(
                    controller: _balanceController,
                    decoration: const InputDecoration(
                      labelText: 'Saldo Awal',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.amountLarge.copyWith(fontSize: 24),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Masukkan saldo awal';
                      if (int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) == null) {
                        return 'Format angka tidak valid';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Selesai'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
