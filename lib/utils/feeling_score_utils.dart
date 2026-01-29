import 'package:flutter/material.dart';

class FeelingScoreUtils {
  /// Get color for feeling score
  /// Red for low scores (1-3), Orange for medium (4-7), Green for high (8-10)
  static Color getColorForScore(int score) {
    if (score <= 3) {
      return Colors.red;
    } else if (score <= 7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
