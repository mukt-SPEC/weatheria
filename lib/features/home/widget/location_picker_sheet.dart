import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatheria/core/theme/app_color.dart';
import 'package:weatheria/core/theme/text_style.dart';
import 'package:weatheria/core/theme/theme_provider.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';

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
      error: (_, _) => 'Use current location',
    );

    return CupertinoActionSheet(
      message: Container(
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                trailing: currentLocationSession.isLoading
                    ? CupertinoActivityIndicator(color: colors.textColor)
                    : null,
              ),
              if (currentLocationSession.hasError)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    _formatCurrentLocationError(currentLocationSession.error),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                ),
              if (savedLocations.isNotEmpty)
                const Divider(height: 1, thickness: 0.3),
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
                  if (!isLast) const Divider(height: 1, thickness: 0.3),
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
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancel',
          style: AppTextStyles.bodyMedium.copyWith(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.title,
    required this.isSelected,
    required this.canDelete,
    required this.colors,
    required this.onTap,
    required this.onDelete,
    this.trailing,
  });

  final String title;
  final bool isSelected;
  final bool canDelete;
  final AppColors colors;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onPressed: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                CupertinoIcons.check_mark,
                size: 18,
                color: colors.textColor,
              ),
            ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: trailing!,
            ),
          if (canDelete)
            CupertinoButton(
              padding: const EdgeInsets.only(left: 10),
              minimumSize: Size.zero,
              onPressed: onDelete,
              child: const Icon(
                CupertinoIcons.trash,
                color: CupertinoColors.destructiveRed,
                size: 20,
              ),
            ),
        ],
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
