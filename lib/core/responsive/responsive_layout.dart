import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= AppBreakpoints.tablet) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppBreakpoints.tablet;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppBreakpoints.tablet && width < AppBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppBreakpoints.desktop;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double contentMaxWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width >= AppBreakpoints.largeDesktop) return 1200;
    if (width >= AppBreakpoints.desktop) return 1000;
    if (width >= AppBreakpoints.tablet) return 800;
    return width; // Full width on mobile
  }

  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32.0;
    if (isTablet(context)) return 24.0;
    return 16.0; // Mobile
  }

  static int gridColumnCount(BuildContext context) {
    final width = screenWidth(context);
    if (width >= AppBreakpoints.largeDesktop) return 5;
    if (width >= AppBreakpoints.desktop) return 4;
    if (width >= AppBreakpoints.tablet) return 3;
    if (width >= AppBreakpoints.mobile) return 2;
    return 1;
  }
}
