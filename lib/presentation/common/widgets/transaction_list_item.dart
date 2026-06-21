import 'package:flutter/material.dart';
import '../../../data/models/transaction.dart';
import 'amount_display.dart';
import 'category_icon.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Kolom Kiri: Icon dan Kategori
            SizedBox(
              width: 100, // Fixed width agar sejajar rapi ke bawah
              child: Row(
                children: [
                  CategoryIcon(
                    iconName: transaction.category?.icon ?? 'swap_horiz',
                    colorHex: transaction.category?.color ?? '#888780',
                    size: 24, // Dikecilkan sesuai gambar
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction.category?.name ?? 'Transfer',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Kolom Tengah: Catatan dan Dompet/Aset
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note != null && transaction.note!.isNotEmpty
                          ? transaction.note!
                          : (transaction.category?.name ?? 'Tanpa Keterangan'),
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.asset?.name ?? '-',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Kolom Kanan: Nominal
            AmountDisplay(
              amount: transaction.amount,
              type: transaction.type.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
