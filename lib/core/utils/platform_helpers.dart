import 'package:flutter/foundation.dart';


enum LayoutBreakpoint {

  compact,


  medium,


  expanded;

  static LayoutBreakpoint fromWidth(double width) {
    if (width >= 840) return LayoutBreakpoint.expanded;
    if (width >= 600) return LayoutBreakpoint.medium;
    return LayoutBreakpoint.compact;
  }
}


bool isDesktopOrWeb() {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
}


bool primaryInputIsPointer() => isDesktopOrWeb();


int metricsColumnCount(LayoutBreakpoint breakpoint) {
  switch (breakpoint) {
    case LayoutBreakpoint.compact:
      return 2;
    case LayoutBreakpoint.medium:
      return 3;
    case LayoutBreakpoint.expanded:
      return 4;
  }
}


const double kMaxContentWidth = 1024.0;

const double kMinWindowWidth = 400.0;
const double kMinWindowHeight = 600.0;
