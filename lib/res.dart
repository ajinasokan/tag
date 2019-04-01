import 'package:flutter/material.dart';

var bigText = TextStyle(
  color: Colors.white,
  fontSize: 24,
  fontWeight: FontWeight.w500,
  decoration: TextDecoration.none,
);

var smallText = bigText.copyWith(fontSize: 16);

class Data {
  Color color;
  int score = 0;
  double x = 0, y = 0;
  bool zombie = false, live = false;
  Data(this.color, this.score);
}

final Map<int, Data> data = {
  1: Data(Colors.blue, 10),
  2: Data(Colors.red, 4),
  3: Data(Colors.purple, 2),
  4: Data(Colors.yellow, 8),
  5: Data(Colors.teal, 11),
};
