import 'package:flutter/material.dart';

class RefreshProvider extends ChangeNotifier {
  VoidCallback? _refreshCallback;

  VoidCallback? get refreshCallback => _refreshCallback;

  void setRefreshCallback(VoidCallback callback) {
    _refreshCallback = callback;
    notifyListeners();
  }
}
