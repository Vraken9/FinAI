import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_text_styles.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  const DateTimePicker({
    super.key,
    required this.selectedDate,
    required this.onSelected,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!context.mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );
    if (time == null) return;

    onSelected(DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _pickDateTime(context),
      leading: const Icon(Icons.calendar_today_outlined),
      title: Text(
        DateFormat('dd MMM yyyy, HH:mm').format(selectedDate),
        style: AppTextStyles.body,
      ),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
