import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/export_service.dart';
import '../../providers/transaction_provider.dart';
import '../../data/repositories/transaction_repository.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isExporting = false;

  void _selectDateRange() async {
    final initialDateRange = _selectedDateRange ?? 
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() => _selectedDateRange = newRange);
    }
  }

  void _performExport() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rentang tanggal terlebih dahulu')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final repo = TransactionRepository();
      final transactions = await repo.getTransactionsByDateRange(
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );

      if (!mounted) return;

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data transaksi di rentang tanggal ini')),
        );
        setState(() => _isExporting = false);
        return;
      }

      await ExportService.exportToExcel(context, transactions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${transactions.length} transaksi berhasil diexport'),
            backgroundColor: AppColors.primaryAccent,
          ),
        );
        // Optional: Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(title: const Text('Export ke Excel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.file_download_outlined, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Export Data Transaksi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unduh laporan keuangan Anda dalam format file Excel (.xlsx).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 48),

          // Date Range Selection
          const Text(
            'Rentang Tanggal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDateRange == null
                          ? 'Pilih rentang tanggal'
                          : '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDateRange == null ? Colors.grey : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_isExporting || _selectedDateRange == null) ? null : _performExport,
              child: _isExporting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Download Excel'),
            ),
          ),
        ],
      ),
    );
  }
}
