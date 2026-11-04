import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecurringTransaction {
  final String id;
  final String title;
  final int amount;
  final String category;
  final String frequency; // Mensuel, Hebdomadaire, Annuel
  final bool isExpense;

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.isExpense,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: json['amount'] ?? 0,
      category: json['category'] ?? '',
      frequency: json['frequency'] ?? 'Mensuel',
      isExpense: json['isExpense'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'isExpense': isExpense,
    };
  }
}

class RecurringManager {
  static const String recurringKey = "RECURRING_TRANSACTIONS_KEY";

  static Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(recurringKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => RecurringTransaction.fromJson(item)).toList();
    }
    return [];
  }

  static Future<void> addRecurringTransaction(RecurringTransaction item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getRecurringTransactions();
    list.add(item);
    final jsonString = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(recurringKey, jsonString);
  }
}
