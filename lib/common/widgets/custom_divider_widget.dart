import 'package:flutter/material.dart';

class CustomDividerWidget extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;
  /// [color] defaults to the active theme's divider colour so dashed dividers
  /// stay visible in both light and dark themes.
  const CustomDividerWidget({super.key, this.height = 1, this.color, this.width = 5.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final double dashWidth = width;
        final double dashHeight = height;
        final int dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (value) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color ?? Theme.of(context).dividerColor,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}