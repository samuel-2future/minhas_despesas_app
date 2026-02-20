import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const String currencySymbol = 'R\$';

  static String formatReal(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  static String formatRealWithoutSymbol(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(value).trim();
  }
}

extension RealFormatting on double {
  String toReal() => CurrencyFormatter.formatReal(this);
  
  String toRealNoSymbol() => CurrencyFormatter.formatRealWithoutSymbol(this);
}
