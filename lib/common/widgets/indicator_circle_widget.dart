import 'package:flutter/material.dart';

class ActiveStatusIndicatorWidget extends StatelessWidget {
  const ActiveStatusIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration:  BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle
      ),
    );
  }
}
