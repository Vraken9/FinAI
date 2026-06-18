import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/period_filter_tabs.dart';
import 'widgets/summary_stats_row.dart';
import 'widgets/expense_donut_chart.dart';
import 'widgets/income_expense_line_chart.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/top_expenses_list.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {

  void _onPeriodChanged(String period) {
    ref.read(selectedPeriodProvider.notifier).state = period;
  }

  Future<void> _exportToExcel() async {
    try {
      final transactions = ref.read(transactionNotifierProvider).valueOrNull ?? [];
      
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Transactions'];
      excel.setDefaultSheet('Transactions');

      // Add Headers
      List<String> headers = ['ID', 'Date', 'Type', 'Amount', 'Category', 'Asset', 'Note'];
      sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

      // Add Data
      for (var t in transactions) {
        List<CellValue> row = [
          TextCellValue(t.id),
          TextCellValue(t.transactionDate.toIso8601String()),
          TextCellValue(t.type.name),
          IntCellValue(t.amount),
          TextCellValue(t.categoryId ?? ''),
          TextCellValue(t.assetId),
          TextCellValue(t.note ?? ''),
        ];
        sheetObject.appendRow(row);
      }

      // Save to device
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/finai_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        File file = File(path);
        await file.writeAsBytes(fileBytes);

        // Share the file
        if (mounted) {
          await Share.shareXFiles([XFile(path)], text: 'Export Laporan FinAI');
        }
      }
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Gagal'),
            content: SingleChildScrollView(
              child: Text('${e.runtimeType}\n\n$e\n\nStack:\n$stackTrace'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Analisis Keuangan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary),
            onPressed: _exportToExcel,
            tooltip: 'Export ke Excel',
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PeriodFilterTabs(
              selectedPeriod: ref.watch(selectedPeriodProvider),
              onPeriodChanged: _onPeriodChanged,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(
            child: SummaryStatsRow(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(
            child: ExpenseDonutChart(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(
            child: IncomeExpenseLineChart(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(
            child: MonthlyBarChart(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(
            child: TopExpensesList(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 180)), // Extra padding agar FAB tidak menutupi konten
        ],
      ),
    );
  }
}
