import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/asset.dart';
import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/models/parsed_transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/asset_provider.dart';

import 'widgets/ai_fill_button.dart';
import 'widgets/amount_input.dart';
import 'widgets/asset_picker.dart';
import 'widgets/attachment_picker.dart';
import 'widgets/category_picker.dart';
import 'widgets/date_time_picker.dart';
import 'widgets/recurring_setup.dart';
import 'widgets/type_toggle.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final Transaction? initialTransaction;
  final ParsedTransaction? initialParsed;
  final File? initialImage;

  const AddTransactionScreen({
    super.key, 
    this.initialType, 
    this.initialTransaction,
    this.initialParsed,
    this.initialImage,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _type;
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  Category? _category;
  Asset? _asset;
  Asset? _transferToAsset;
  final _transferFeeController = TextEditingController();
  final _noteController = TextEditingController();
  final _descController = TextEditingController();
  final _merchantController = TextEditingController();
  
  List<File> _attachments = [];
  String? _pendingAttachmentPath;
  bool _recurringEnabled = false;
  String? _recurringFrequency;
  
  bool _isLoading = false;

  final Set<String> _aiFilledFields = {};

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    if (tx != null) {
      _type = tx.type.name;
      _amountController.text = tx.amount.toString();
      _date = tx.transactionDate;
      _category = tx.category;
      _asset = tx.asset;
      _transferToAsset = tx.transferToAsset;
      if (tx.transferFee != null) _transferFeeController.text = tx.transferFee.toString();
      if (tx.note != null) _noteController.text = tx.note!;
      if (tx.description != null) _descController.text = tx.description!;
      if (tx.merchant != null) _merchantController.text = tx.merchant!;
    } else {
      _type = widget.initialType ?? 'expense';
    }

    if (widget.initialParsed != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAiParsed(widget.initialParsed!, widget.initialImage);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transferFeeController.dispose();
    _noteController.dispose();
    _descController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _handleAiParsed(ParsedTransaction parsed, [File? image]) {
    setState(() {
      if (parsed.type != null) _type = parsed.type!;
      
      if (parsed.amount != null) {
        _amountController.text = parsed.amount.toString();
        _aiFilledFields.add('amount');
      }
      
      if (parsed.note != null && parsed.note!.isNotEmpty) {
        _noteController.text = parsed.note!;
        _aiFilledFields.add('note');
      }
      if (parsed.description != null && parsed.description!.isNotEmpty) {
        _descController.text = parsed.description!;
        _aiFilledFields.add('description');
      }
      if (parsed.merchant != null && parsed.merchant!.isNotEmpty) {
        _merchantController.text = parsed.merchant!;
        _aiFilledFields.add('merchant');
      }
      if (parsed.pendingAttachmentPath != null) {
        _pendingAttachmentPath = parsed.pendingAttachmentPath;
        _aiFilledFields.add('attachment');
        // TODO: File in 'pending/' path will become an orphan if user cancels this transaction.
        // A scheduled cleanup job in Supabase is needed to remove old pending files.
      } else if (image != null) {
        _attachments = [image];
        _aiFilledFields.add('attachment');
      }
    });

    if (parsed.categoryId != null) {
      final categories = ref.read(categoryNotifierProvider).valueOrNull ?? [];
      final cat = categories.where((c) => c.id == parsed.categoryId).firstOrNull;
      if (cat != null) {
        setState(() {
          _category = cat;
          _aiFilledFields.add('category');
        });
      }
    }

    if (parsed.assetId != null) {
      final assets = ref.read(assetNotifierProvider).valueOrNull ?? [];
      final asset = assets.where((a) => a.id == parsed.assetId).firstOrNull;
      if (asset != null) {
        setState(() {
          _asset = asset;
          _aiFilledFields.add('asset');
        });
      }
    }
  }

  Color? _getHighlightColor(String field) {
    return _aiFilledFields.contains(field) ? Colors.yellow.withValues(alpha: 25) : null;
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_type != 'transfer' && _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori')));
      return;
    }
    if (_asset == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih dompet/aset')));
      return;
    }
    if (_type == 'transfer' && _transferToAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih dompet tujuan')));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final amount = int.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final fee = _transferFeeController.text.isNotEmpty 
          ? int.parse(_transferFeeController.text.replaceAll(RegExp(r'[^0-9]'), ''))
          : null;

      final supabase = SupabaseService().client;
      final userId = supabase.auth.currentUser?.id ?? '';

      final transaction = Transaction(
        id: widget.initialTransaction?.id ?? '', // handle default in backend if uuid is generated
        userId: userId, 
        type: TransactionType.values.firstWhere((e) => e.name == _type),
        amount: amount,
        transactionDate: _date,
        categoryId: _type != 'transfer' ? _category?.id : null,
        assetId: _asset!.id,
        transferToAssetId: _type == 'transfer' ? _transferToAsset?.id : null,
        transferFee: _type == 'transfer' ? fee : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        description: _descController.text.isNotEmpty ? _descController.text : null,
        merchant: _merchantController.text.isNotEmpty ? _merchantController.text : null,
        aiGenerated: _aiFilledFields.isNotEmpty,
        aiInputType: _aiFilledFields.isNotEmpty ? 'ai' : null,
        status: TransactionStatus.confirmed,
        createdAt: DateTime.now(),
      );

      Transaction savedTransaction;
      if (widget.initialTransaction != null) {
        await ref.read(transactionNotifierProvider.notifier).updateTransaction(widget.initialTransaction!.id, transaction);
        savedTransaction = transaction.copyWith(id: widget.initialTransaction!.id);
      } else {
        savedTransaction = await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
      }
      final transactionId = savedTransaction.id;
      
      int failedUploads = 0;

      if (_pendingAttachmentPath != null) {
        try {
          final fileName = _pendingAttachmentPath!.split('/').last;
          final finalPath = '$userId/$transactionId/$fileName';
          
          await supabase.storage.from('transaction-attachments').move(_pendingAttachmentPath!, finalPath);
          
          final fileExtension = fileName.split('.').last.toLowerCase();
          String fileType = 'application/pdf';
          if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
            fileType = 'image/jpeg';
          } else if (fileExtension == 'png') {
            fileType = 'image/png';
          }
          
          await supabase.from('transaction_attachments').insert({
            'transaction_id': transactionId,
            'user_id': userId,
            'file_path': finalPath,
            'file_name': fileName,
            'file_type': fileType,
            'file_size_bytes': 0, // Pending file size is unknown on client side without downloading
          });
        } catch (e) {
          debugPrint('Upload pending attachment error: $e');
          failedUploads++;
        }
      }

      if (widget.initialTransaction != null && _attachments.isNotEmpty) {
        final oldAttachments = widget.initialTransaction!.attachments ?? [];
        if (oldAttachments.isNotEmpty) {
          try {
            final oldPaths = oldAttachments.map((a) => a.filePath).toList();
            await supabase.storage.from('transaction-attachments').remove(oldPaths);
            await supabase.from('transaction_attachments').delete().eq('transaction_id', widget.initialTransaction!.id);
          } catch (e) {
            debugPrint('Failed to delete old attachments: $e');
          }
        }
      }

      for (var file in _attachments) {
        try {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
          final fullPath = '$userId/$transactionId/$fileName';
          
          await supabase.storage.from('transaction-attachments').upload(fullPath, file);
          
          final fileExtension = file.path.split('.').last.toLowerCase();
          String fileType = 'application/pdf'; // default fallback
          if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
            fileType = 'image/jpeg';
          } else if (fileExtension == 'png') {
            fileType = 'image/png';
          }
          
          await supabase.from('transaction_attachments').insert({
            'transaction_id': transactionId,
            'user_id': userId,
            'file_path': fullPath,
            'file_name': file.path.split('/').last,
            'file_type': fileType,
            'file_size_bytes': await file.length(),
          });
        } catch (e) {
          debugPrint('Upload attachment error: $e');
          failedUploads++;
        }
      }
      
      if (mounted) {
        ref.read(transactionNotifierProvider.notifier).refresh();
        context.pop();
        if (failedUploads > 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi berhasil disimpan, namun $failedUploads lampiran gagal diunggah. Kamu bisa menambahkan lampiran lagi dari halaman detail transaksi.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil disimpan')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTransaction != null ? 'Edit Transaksi' : 'Tambah Transaksi'),
      ),
      floatingActionButton: AiFillButton(onAiParsed: _handleAiParsed),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TypeToggle(
                selectedType: _type,
                onChanged: (val) {
                  setState(() {
                    _type = val;
                    if (_type == 'transfer') _category = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              Container(
                color: _getHighlightColor('amount'),
                child: AmountInput(controller: _amountController, type: _type),
              ),
              const SizedBox(height: 24),
              
              Container(
                color: _getHighlightColor('date'),
                child: DateTimePicker(
                  selectedDate: _date,
                  onSelected: (date) => setState(() => _date = date),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_type != 'transfer') ...[
                Container(
                  color: _getHighlightColor('category'),
                  child: CategoryPicker(
                    selectedCategory: _category,
                    transactionType: _type,
                    onSelected: (cat) => setState(() => _category = cat),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Container(
                color: _getHighlightColor('asset'),
                child: AssetPicker(
                  label: _type == 'transfer' ? 'Dari Dompet' : 'Dompet',
                  selectedAsset: _asset,
                  onSelected: (asset) => setState(() => _asset = asset),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_type == 'transfer') ...[
                Container(
                  color: _getHighlightColor('transferToAsset'),
                  child: AssetPicker(
                    label: 'Ke Dompet',
                    selectedAsset: _transferToAsset,
                    onSelected: (asset) => setState(() => _transferToAsset = asset),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  color: _getHighlightColor('transferFee'),
                  child: TextFormField(
                    controller: _transferFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Biaya Transfer (opsional)',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Container(
                color: _getHighlightColor('note'),
                child: TextFormField(
                  controller: _noteController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Catatan singkat',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                color: _getHighlightColor('description'),
                child: TextFormField(
                  controller: _descController,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_type == 'expense') ...[
                Container(
                  color: _getHighlightColor('merchant'),
                  child: TextFormField(
                    controller: _merchantController,
                    decoration: const InputDecoration(
                      labelText: 'Merchant / Toko',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Container(
                color: _getHighlightColor('attachment'),
                child: AttachmentPicker(
                  attachments: _attachments,
                  onChanged: (files) => setState(() => _attachments = files),
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                color: _getHighlightColor('recurring'),
                child: RecurringSetup(
                  isEnabled: _recurringEnabled,
                  frequency: _recurringFrequency,
                  onToggle: (val) => setState(() => _recurringEnabled = val),
                  onFrequencyChanged: (val) => setState(() => _recurringFrequency = val),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
