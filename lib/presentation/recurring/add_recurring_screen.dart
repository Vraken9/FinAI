import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/asset.dart';
import '../../../data/models/category.dart' as model_category;
import '../../../data/models/recurring_rule.dart';
import '../../../providers/recurring_provider.dart';
import '../transaction/widgets/asset_picker.dart';
import '../transaction/widgets/category_picker.dart';
import '../transaction/widgets/type_toggle.dart';

class AddRecurringScreen extends ConsumerStatefulWidget {
  const AddRecurringScreen({super.key});

  @override
  ConsumerState<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends ConsumerState<AddRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();

  String _transactionType = 'EXPENSE';
  model_category.Category? _selectedCategory;
  Asset? _selectedAsset;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();

  bool _isLoading = false;

  void _saveRule() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null || _selectedAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori dan dompet')),
      );
      return;
    }

    final amountStr = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      
      // Hitung nextDueDate awal (karena ini baru dibuat, nextDueDate = startDate)
      // Logika generation akan dihandle oleh Edge Function atau logika lain nantinya.
      
      final rule = RecurringRule(
        id: '',
        userId: '',
        transactionType: _transactionType,
        amount: amount,
        categoryId: _selectedCategory!.id,
        assetId: _selectedAsset!.id,
        merchant: _merchantController.text.trim().isEmpty ? null : _merchantController.text.trim(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        frequency: _frequency,
        startDate: _startDate,
        nextDueDate: _startDate,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(recurringRulesNotifierProvider.notifier).createRule(rule);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tagihan rutin berhasil dibuat')),
        );
      }
    } catch (e) {
      debugPrint('Error creating recurring rule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat tagihan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tagihan Rutin'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TypeToggle(
                    selectedType: _transactionType,
                    onChanged: (type) {
                      setState(() {
                        _transactionType = type;
                        _selectedCategory = null; // reset category when type changes
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Text('Nominal', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.amountLarge.copyWith(fontSize: 24),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '0',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Isi nominal' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Merchant / Nama Tagihan', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _merchantController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Netflix, Listrik, Gaji',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Isi nama tagihan' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Frekuensi', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<RecurringFrequency>(
                              value: _frequency,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: RecurringFrequency.daily, child: Text('Harian')),
                                DropdownMenuItem(value: RecurringFrequency.weekly, child: Text('Mingguan')),
                                DropdownMenuItem(value: RecurringFrequency.biweekly, child: Text('2 Mingguan')),
                                DropdownMenuItem(value: RecurringFrequency.monthly, child: Text('Bulanan')),
                                DropdownMenuItem(value: RecurringFrequency.yearly, child: Text('Tahunan')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _frequency = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal Mulai', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _pickStartDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(DateFormat('dd MMM yyyy').format(_startDate)),
                                    const Icon(Icons.calendar_today, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Kategori', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  CategoryPicker(
                    transactionType: _transactionType,
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) => setState(() => _selectedCategory = cat),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Dompet', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  AssetPicker(
                    selectedAsset: _selectedAsset,
                    onSelected: (asset) => setState(() => _selectedAsset = asset),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Catatan Tambahan', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Opsional',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveRule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Simpan',
                        style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
