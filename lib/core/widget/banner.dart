import 'package:flutter/material.dart';
import 'package:weatheria/core/core_barrel.dart';

class ConnectionBanner extends StatefulWidget {
  final bool isVisible;
  const ConnectionBanner({required this.isVisible, super.key});

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  bool _showSucess = false;
  @override
  void didUpdateWidget(ConnectionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isVisible && !widget.isVisible) {
      setState(() {
        _showSucess = true;

        Future.delayed(Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showSucess = false;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isShowing = widget.isVisible || _showSucess;
    final Color backgroundColor = widget.isVisible
        ? Colors.red[700]!
        : Colors.green[600]!;

    final String text = widget.isVisible
        ? 'No internet Connection'
        : 'Internet restored';
    return AnimatedSize(
      duration: const Duration(milliseconds: 700),
      curve: Curves.linear,
      child: Container(
        width: double.infinity,
          color: isShowing ? backgroundColor : Colors.transparent,
        child: isShowing
            ? SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        text,
                        key: ValueKey(text),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
