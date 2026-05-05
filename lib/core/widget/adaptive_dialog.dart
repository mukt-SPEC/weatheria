import 'package:flutter/material.dart';
import 'package:weatheria/core/utils/platform_helpers.dart';

/// Shows a dialog that adapts to the current breakpoint:
/// - compact: modal bottom sheet
/// - medium/expanded: centered dialog
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool isDismissible = true,
  double maxDialogWidth = 480,
  double maxDialogHeight = 600,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final breakpoint = LayoutBreakpoint.fromWidth(width);

  if (breakpoint == LayoutBreakpoint.compact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheetWrapper(child: builder(ctx)),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (ctx) => _DialogWrapper(
      maxWidth: maxDialogWidth,
      maxHeight: maxDialogHeight,
      child: builder(ctx),
    ),
  );
}

class _BottomSheetWrapper extends StatelessWidget {
  const _BottomSheetWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DialogWrapper extends StatelessWidget {
  const _DialogWrapper({
    required this.child,
    required this.maxWidth,
    required this.maxHeight,
  });

  final Widget child;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
