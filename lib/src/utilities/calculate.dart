import 'package:flutter/material.dart';

class Calculate {
  static int skeletonCount(
    BoxConstraints constraints,
    double indicatorHeight,
  ) {
    return (constraints.maxHeight ~/ indicatorHeight) + 1;
  }
}
