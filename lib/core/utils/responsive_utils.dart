import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.2; // Larger text on desktop
    } else if (isTablet(context)) {
      return baseSize * 1.1; // Slightly larger on tablet
    }
    return baseSize; // Standard size on mobile
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double mobile = 16,
    double tablet = 24,
    double desktop = 32,
  }) {
    if (isDesktop(context)) {
      return EdgeInsets.all(desktop);
    } else if (isTablet(context)) {
      return EdgeInsets.all(tablet);
    }
    return EdgeInsets.all(mobile);
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4; // 4 columns on desktop
    } else if (isTablet(context)) {
      return 3; // 3 columns on tablet
    }
    return 2; // 2 columns on mobile
  }

  static double getCardWidth(BuildContext context) {
    final crossAxisCount = getGridCrossAxisCount(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getResponsivePadding(context).left * 2;
    final spacing = 16.0 * (crossAxisCount - 1); // spacing between cards

    return (screenWidth - padding - spacing) / crossAxisCount;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  )
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return builder(context, isMobile, isTablet, isDesktop);
  }
}
