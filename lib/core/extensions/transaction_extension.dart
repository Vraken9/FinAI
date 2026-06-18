import '../../data/models/transaction.dart';

extension TransactionExpenseExtension on Transaction {
  /// Nominal yang DIHITUNG sebagai pengeluaran sesuai aturan bisnis
  /// PRD-00: transfer BUKAN pengeluaran, kecuali biaya transfernya
  int get effectiveExpenseAmount {
    if (type == TransactionType.expense) return amount;
    if (type == TransactionType.transfer) return transferFee ?? 0;
    return 0; // income tidak dihitung sebagai pengeluaran
  }
}
