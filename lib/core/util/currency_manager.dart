import 'package:shared_preferences/shared_preferences.dart';

class CurrencyManager {
  static const String currencyKey = "APP_CURRENCY_KEY";

  static const List<Map<String, String>> availableCurrencies = [
    {"code": "FCFA", "symbol": "FCFA", "name": "Franc CFA (XAF/XOF)"},
    {"code": "EUR", "symbol": "€", "name": "Euro (€)"},
    {"code": "USD", "symbol": "\$", "name": "Dollar Américain (\$)"},
    {"code": "CAD", "symbol": "CA\$", "name": "Dollar Canadien (CA\$)"},
    {"code": "GBP", "symbol": "£", "name": "Livre Sterling (£)"},
    {"code": "NGN", "symbol": "₦", "name": "Naira Nigérian (₦)"},
    {"code": "GNF", "symbol": "FG", "name": "Franc Guinéen (FG)"},
    {"code": "MAD", "symbol": "DH", "name": "Dirham Marocain (DH)"},
  ];

  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currencyKey) ?? "FCFA";
  }

  static Future<void> setCurrency(String currencySymbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currencyKey, currencySymbol);
  }
}
