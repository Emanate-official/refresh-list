import 'package:flutter/material.dart';

class BottomIndicator extends StatelessWidget {
  const BottomIndicator({
    Key? key,
    required this.bottomIndicatorOffset,
    required this.loadingIndicator,
    required this.position,
  }) : super(key: key);

  final double bottomIndicatorOffset;
  final Widget loadingIndicator;
  final double position;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(
        bottom: bottomIndicatorOffset,
      ),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(right: 15),
            child: loadingIndicator,
            transform: Matrix4.translationValues(0, position, 0),
          ),
        ],
      ),
    );
  }
}
