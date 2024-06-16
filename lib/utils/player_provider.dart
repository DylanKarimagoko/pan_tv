import 'package:flutter/material.dart';

class PlayerProvider with ChangeNotifier {
  bool _fullScreen = false;
  bool get fullScreen => _fullScreen;

  changeOrientation(bool value) {
    _fullScreen = value;
    notifyListeners();
  }
}
