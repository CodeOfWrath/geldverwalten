import 'package:shared_preferences/shared_preferences.dart';
import 'data_change_notifier.dart';

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

  static final Map<String, double> exchangeRatesFromFcfa = {
    "FCFA": 1.0,
    "€": 1 / 655.957,
    "\$": 1 / 600.0,
    "CA\$": 1 / 440.0,
    "£": 1 / 760.0,
    "₦": 2.5,
    "FG": 14.2,
    "DH": 0.0165,
  };

  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currencyKey) ?? "FCFA";
  }

  static Future<void> setCurrency(String currencySymbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currencyKey, currencySymbol);
    dataChangeNotifier.notifyDataChanged();
  }

  static String formatConverted(int amountFcfa, String targetCurrencySymbol) {
    final rate = exchangeRatesFromFcfa[targetCurrencySymbol] ?? 1.0;
    final converted = amountFcfa * rate;
    if (targetCurrencySymbol == "FCFA" || targetCurrencySymbol == "FG" || targetCurrencySymbol == "₦") {
      return "${converted.round()} $targetCurrencySymbol";
    }
    return "${converted.toStringAsFixed(2)} $targetCurrencySymbol";
  }
}
