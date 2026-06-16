import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class RecurringSetup extends StatelessWidget {
  final bool isEnabled;
  final String? frequency;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String?> onFrequencyChanged;

  const RecurringSetup({
    super.key,
    required this.isEnabled,
    required this.frequency,
    required this.onToggle,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text('Buat Berulang', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          subtitle: const Text('Otomatis catat transaksi ini setiap periode tertentu'),
          value: isEnabled,
          onChanged: onToggle,
          contentPadding: EdgeInsets.zero,
        ),
        if (isEnabled) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: frequency,
            decoration: InputDecoration(
              labelText: 'Periode Berulang',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Harian')),
              DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
              DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
              DropdownMenuItem(value: 'yearly', child: Text('Tahunan')),
            ],
            onChanged: onFrequencyChanged,
            validator: (val) {
              if (isEnabled && val == null) return 'Pilih periode berulang';
              return null;
            },
          ),
        ],
      ],
    );
  }
}
