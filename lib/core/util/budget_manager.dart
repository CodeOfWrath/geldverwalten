import 'package:shared_preferences/shared_preferences.dart';

class BudgetManager {
  static const String KEY_PREFIX = "BUDGET_LIMIT_";

  static Map<String, int> defaultLimits = {
    "Alimentation": 50000,
    "Transport": 30000,
    "Loisirs": 20000,
    "Santé": 25000,
    "Maison": 40000,
    "Autre": 15000,
  };

  static Future<int> getLimit(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final defaultVal = defaultLimits[category] ?? 30000;
    return prefs.getInt("$KEY_PREFIX$category") ?? defaultVal;
  }

  static Future<void> setLimit(String category, int limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("$KEY_PREFIX$category", limit);
  }

  static Future<Map<String, int>> getAllLimits() async {
    final Map<String, int> result = {};
    for (var cat in defaultLimits.keys) {
      result[cat] = await getLimit(cat);
    }
    return result;
  }
}
