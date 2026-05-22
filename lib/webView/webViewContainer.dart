import 'package:flutter/material.dart';

class WebView extends StatelessWidget {
  final Widget? child;
  final List<Color> gradientColors;
  final List<double> gradientStops;

  const WebView({
    super.key,
    this.child,
    this.gradientColors = const [
      Color(0xff536976),
      Color(0xff292e49),
    ],
    this.gradientStops = const [
      0,
      1
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            stops: gradientStops,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
