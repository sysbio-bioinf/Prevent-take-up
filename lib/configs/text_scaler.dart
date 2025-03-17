import 'package:flutter/material.dart';

class TextScaleProvider with ChangeNotifier {
  double scaling = 1;
  double get scale => scaling;

  TextScaleProvider() {
    this.scaling = 1;
  }

  void setScale(double scale) {
    this.scaling = scale;
    notifyListeners();
  }
}
