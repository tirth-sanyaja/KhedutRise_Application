import 'package:flutter/material.dart';

/// A simple, lightweight responsive wrapper that keeps content comfortably
/// centered and constrained on tablets, laptops, and desktop screens,
/// while providing full-width fluid layouts on mobile devices.
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
