import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:weatheria/core/theme/app_color.dart';
import 'package:weatheria/core/theme/text_style.dart';
import 'package:weatheria/core/theme/theme_provider.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';

/// Adaptive location picker — works as both bottom sheet and dialog content.
/// Replaces the former CupertinoActionSheet-based picker.
class LocationPickerSheet extends ConsumerWidget {
  const LocationPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final colors = isDark ? AppColors.dark : AppColors.light;

    final selectedId = ref.watch(selectedLocationProvider);
    final savedLocations = ref.watch(savedLocationsProvider);
    final activeSource = ref.watch(activeLocationSourceProvider);
    final currentLocationSession = ref.watch(currentLocationSessionProvider);

    final currentLocationLabel = currentLocationSession.when(
      data: (location) => location?.label ?? 'Use current location',
      loading: () => 'Finding current location...',
      error: (_, __) => 'Use current location',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Locations',
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textColor,
              ),
            ),
          ),

          // Current location row
          Container(
            decoration: BoxDecoration(
              color: colors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.borderColor),
            ),
            child: Column(
              children: [
                _LocationRow(
                  title: currentLocationLabel,
                  isSelected:
                      activeSource == ActiveLocationSource.currentLocation,
                  canDelete: false,
                  colors: colors,
                  onTap: () async {
                    final success = await ref
                        .read(locationSelectionControllerProvider)
                        .useCurrentLocation();
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  onDelete: null,
                  leading: Icon(
                    PhosphorIconsRegular.crosshair,
                    color: colors.textColor,
                    size: 20,
                  ),
                  trailing: currentLocationSession.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                ),

                // Error message for current location
                if (currentLocationSession.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      _formatCurrentLocationError(
                          currentLocationSession.error),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red[400],
                      ),
                    ),
                  ),

                if (savedLocations.isNotEmpty)
                  Divider(
                    height: 1,
                    thickness: 0.3,
                    color: colors.borderColor,
                  ),

                // Saved locations
                ...savedLocations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final location = entry.value;
                  final isLast = index == savedLocations.length - 1;

                  return Column(
                    children: [
                      _LocationRow(
                        title: location.label,
                        isSelected:
                            activeSource == ActiveLocationSource.startup &&
                            selectedId == location.id,
                        canDelete: true,
                        colors: colors,
                        onTap: () async {
                          await ref
                              .read(locationSelectionControllerProvider)
                              .selectStartupLocation(location.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        onDelete: () async {
                          await ref
                              .read(savedLocationsProvider.notifier)
                              .deleteById(location.id);
                        },
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 0.3,
                          color: colors.borderColor,
                        ),
                    ],
                  );
                }),

                if (savedLocations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Text(
                      'No saved locations yet. Use search to add one.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.secondaryTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatefulWidget {
  const _LocationRow({
    required this.title,
    required this.isSelected,
    required this.canDelete,
    required this.colors,
    required this.onTap,
    required this.onDelete,
    this.leading,
    this.trailing,
  });

  final String title;
  final bool isSelected;
  final bool canDelete;
  final AppColors colors;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Widget? leading;
  final Widget? trailing;

  @override
  State<_LocationRow> createState() => _LocationRowState();
}

class _LocationRowState extends State<_LocationRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.colors.textColor.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: widget.colors.textColor,
                      fontWeight: widget.isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: widget.colors.textColor,
                    ),
                  ),
                if (widget.trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: widget.trailing!,
                  ),
                if (widget.canDelete)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                        size: 20,
                      ),
                      tooltip: 'Delete location',
                      onPressed: widget.onDelete,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatCurrentLocationError(Object? error) {
  final message = error?.toString() ?? 'Unable to use current location.';
  if (message.toLowerCase().contains('permission')) {
    return 'Location permission was denied. We kept your current city selected.';
  }
  if (message.toLowerCase().contains('disabled')) {
    return 'Location services are disabled. We kept your current city selected.';
  }
  return 'Unable to load your current location right now.';
}
