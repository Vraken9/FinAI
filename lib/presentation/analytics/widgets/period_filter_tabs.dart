import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PeriodFilterTabs extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const PeriodFilterTabs({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = ['7H', '30H', '3B', '6B', 'Tahun', 'Custom'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onPeriodChanged(period);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
