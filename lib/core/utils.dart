import 'package:intl/intl.dart';

String formatCFA(double amount) {
  // Create a NumberFormat instance for currency formatting
  NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'fr_FR', // Change the locale as needed
    symbol:
        'FCFA', // The currency symbol, empty string if you want only the code
    decimalDigits: 0, // The number of decimal digits to display
  );

  // Format the amount as currency
  return currencyFormat.format(amount);
}
