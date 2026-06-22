import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../data/models/transaction.dart' as model_transaction;
import '../../data/repositories/transaction_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/asset_provider.dart';

import '../../providers/category_provider.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  int _currentStep = 0;
  File? _selectedFile;
  List<Map<String, dynamic>> _previewData = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _errorMessage = null;
        });
        _processFile();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memilih file: $e');
    }
  }

  Future<void> _processFile() async {
    setState(() => _isLoading = true);

    try {
      final bytes = await _selectedFile!.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      List<Map<String, dynamic>> data = [];
      
      // Look for the first sheet or specific sheet
      final sheet = excel.tables.keys.first;
      final table = excel.tables[sheet];
      
      if (table != null) {
        final rows = table.rows;
        if (rows.length > 1) {
          // Skip header row
          for (var i = 1; i < rows.length; i++) {
            final row = rows[i];
            // Format expected: Tanggal | Tipe | Jumlah | Kategori | Catatan
            if (row.length >= 3 && row[0]?.value != null && row[1]?.value != null && row[2]?.value != null) {
              DateTime? date;
              final dateVal = row[0]?.value;
              if (dateVal is DateTimeCellValue) {
                date = dateVal.asDateTimeLocal();
              } else if (dateVal is TextCellValue) {
                try {
                  date = DateFormat('yyyy-MM-dd').parse(dateVal.value.toString());
                } catch (_) {
                  try {
                    date = DateFormat('dd/MM/yyyy').parse(dateVal.value.toString());
                  } catch (_) {}
                }
              }

              final typeStr = row[1]?.value.toString().toUpperCase() ?? '';
              model_transaction.TransactionType type = model_transaction.TransactionType.expense;
              if (typeStr.contains('INCOME') || typeStr.contains('PEMASUKAN')) {
                type = model_transaction.TransactionType.income;
              } else if (typeStr.contains('TRANSFER')) {
                type = model_transaction.TransactionType.transfer;
              }

              int amount = 0;
              final amountVal = row[2]?.value;
              if (amountVal is IntCellValue) {
                amount = amountVal.value;
              } else if (amountVal is DoubleCellValue) {
                amount = amountVal.value.toInt();
              } else if (amountVal is TextCellValue) {
                amount = int.tryParse(amountVal.value.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              }

              final categoryName = row.length > 3 ? row[3]?.value?.toString() : null;
              final note = row.length > 4 ? row[4]?.value?.toString() : '';

              if (date != null && amount > 0) {
                data.add({
                  'date': date,
                  'type': type,
                  'amount': amount,
                  'category_name': categoryName,
                  'note': note,
                });
              }
            }
          }
        }
      }

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ditemukan data valid dalam file. Pastikan format: Tanggal | Tipe | Jumlah';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _previewData = data;
        _currentStep = 1;
        _isLoading = false;
        _errorMessage = null;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membaca file Excel. Pastikan formatnya benar (.xlsx). Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _importData() async {
    setState(() => _isLoading = true);
    
    try {
      final repository = TransactionRepository();
      final userId = ref.read(authNotifierProvider).profile?.id;
      
      if (userId == null) throw Exception('User tidak terautentikasi');

      // Ambil default asset id
      final assets = await ref.read(assetNotifierProvider.future);
      if (assets.isEmpty) throw Exception('Anda harus memiliki setidaknya satu aset/dompet.');
      String assetId;
      try {
        assetId = assets.firstWhere((a) => a.isDefault).id;
      } catch (_) {
        assetId = assets.first.id;
      }

      // Ambil daftar kategori
      final categories = await ref.read(categoryNotifierProvider.future);

      int successCount = 0;

      for (var item in _previewData) {
        final type = item['type'] as model_transaction.TransactionType;
        
        // Resolve Category
        String? categoryId;
        if (type != model_transaction.TransactionType.transfer) {
          final catName = item['category_name'] as String?;
          final typeStr = type == model_transaction.TransactionType.expense ? 'expense' : 'income';
          
          if (catName != null && catName.trim().isNotEmpty) {
            try {
              categoryId = categories.firstWhere((c) => c.type == typeStr && c.name.toLowerCase() == catName.trim().toLowerCase()).id;
            } catch (_) {}
          }
          
          // Fallback if no matching category found
          if (categoryId == null) {
            try {
              categoryId = categories.firstWhere((c) => c.type == typeStr).id;
            } catch (_) {
              throw Exception('Sistem membutuhkan minimal satu kategori untuk tipe $typeStr. Silakan buat kategori terlebih dahulu di Pengaturan.');
            }
          }
        }

        final tx = model_transaction.Transaction(
          id: '', // Will be set by backend
          userId: userId,
          type: type,
          amount: item['amount'] as int,
          transactionDate: item['date'] as DateTime,
          assetId: assetId,
          categoryId: categoryId,
          note: item['note'] as String?,
          status: model_transaction.TransactionStatus.confirmed,
          aiGenerated: false,
          createdAt: DateTime.now(),
        );
        
        await repository.addTransaction(tx);
        successCount++;
      }

      ref.invalidate(transactionNotifierProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog(successCount);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menyimpan data: $e';
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Import Berhasil'),
        content: Text('$count transaksi berhasil ditambahkan.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to settings
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Transaksi')),
      body: Stepper(
        currentStep: _currentStep,
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        onStepContinue: () {
          if (_currentStep == 0 && _selectedFile != null) {
            _processFile();
          } else if (_currentStep == 1) {
            setState(() => _currentStep = 2);
          } else if (_currentStep == 2) {
            _importData();
          }
        },
        controlsBuilder: (context, details) {
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (_currentStep == 0) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 2 ? 'Mulai Import' : 'Lanjut'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Kembali'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Upload File'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih file Excel (.xlsx) yang berisi data transaksi Anda.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Format yang Diperbolehkan:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Baris pertama akan diabaikan (dianggap Header).', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Kolom 1: Tanggal (Contoh: 2026-12-31 atau 31/12/2026)\nKolom 2: Tipe (Expense / Income / Transfer)\nKolom 3: Jumlah Nominal (Contoh: 50000)\nKolom 4: Kategori (Opsional, diabaikan saat ini)\nKolom 5: Catatan (Opsional)', style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      const Text('AI Parsing Aktif: FinAI akan mencoba mencocokkan tipe transaksi dan membersihkan format nominal secara otomatis.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.primaryAccent)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: AppColors.expense)),
                  ),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_selectedFile == null ? 'Pilih File Excel' : 'Ganti File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                if (_selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(child: Text('File: ${_selectedFile!.path.split(Platform.pathSeparator).last}')),
                  ),
              ],
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Preview Data'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ditemukan ${_previewData.length} baris data yang valid.'),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    itemCount: _previewData.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _previewData[index];
                      final date = item['date'] as DateTime;
                      final amount = item['amount'] as int;
                      final type = item['type'] as model_transaction.TransactionType;
                      final isExpense = type == model_transaction.TransactionType.expense;

                      return ListTile(
                        leading: Icon(
                          isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isExpense ? AppColors.expense : AppColors.income,
                        ),
                        title: Text(item['note'] ?? 'Tanpa Catatan'),
                        subtitle: Text(DateFormat('dd MMM yyyy').format(date)),
                        trailing: Text(
                          amount.toCurrency(),
                          style: TextStyle(
                            color: isExpense ? AppColors.expense : AppColors.income,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Konfirmasi'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data siap diimport ke dalam sistem FinAI.'),
                const SizedBox(height: 8),
                Text('Total Transaksi: ${_previewData.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text(
                  'Catatan: Karena keterbatasan file, semua transaksi akan dimasukkan ke dompet utama (default asset). Anda bisa mengubahnya nanti di detail transaksi.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: AppColors.expense)),
                  ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
