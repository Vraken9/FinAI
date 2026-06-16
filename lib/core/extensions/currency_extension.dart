import 'package:intl/intl.dart';

extension CurrencyExtension on num {
  String toCurrency() {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(this);
  }

  String toCurrencyCompact() {
    final format = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(this);
  }
}
