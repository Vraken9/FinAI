extension DateTimeExtension on DateTime {
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays == 0 && day == now.day) {
      return 'Hari ini';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && day != now.day)) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
    }
  }
}
