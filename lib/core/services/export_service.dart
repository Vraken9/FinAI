import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/transaction.dart';
import '../extensions/transaction_extension.dart';

class ExportService {
  static Future<void> exportToExcel(BuildContext context, List<Transaction> transactions) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Transactions'];
      excel.setDefaultSheet('Transactions');

      // Add Headers
      List<String> headers = ['Tanggal', 'Tipe', 'Nominal (Efektif)', 'Kategori', 'Aset Sumber', 'Aset Tujuan', 'Catatan'];
      sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

      // Add Data
      for (var t in transactions) {
        final amount = t.type == TransactionType.income ? t.amount : t.effectiveExpenseAmount;
        List<CellValue> row = [
          TextCellValue(t.transactionDate.toIso8601String()),
          TextCellValue(t.type.name),
          IntCellValue(amount),
          TextCellValue(t.category?.name ?? t.categoryId ?? ''),
          TextCellValue(t.asset?.name ?? t.assetId),
          TextCellValue(t.transferToAsset?.name ?? t.transferToAssetId ?? ''),
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
        if (context.mounted) {
          await Share.shareXFiles([XFile(path)], text: 'Export Laporan FinAI');
        }
      }
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      if (context.mounted) {
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
}
