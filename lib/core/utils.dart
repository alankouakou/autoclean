import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

String capitalize(String name) {
  if (name.isNotEmpty) {
    return '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
  } else {
    return '';
  }
}

void showToast({required String message}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.teal,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16,
      timeInSecForIosWeb: 1);
}
