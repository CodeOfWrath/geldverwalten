import 'package:flutter/foundation.dart';

class DataChangeNotifier extends ChangeNotifier {
  static final DataChangeNotifier instance = DataChangeNotifier._internal();
  factory DataChangeNotifier() => instance;
  DataChangeNotifier._internal();

  void notifyDataChanged() {
    notifyListeners();
  }
}

final dataChangeNotifier = DataChangeNotifier();
