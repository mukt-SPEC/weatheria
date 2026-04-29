import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weatheria/core/theme/app_color.dart';
import 'package:weatheria/core/theme/text_style.dart';
import 'package:weatheria/core/theme/theme_provider.dart';
import 'package:weatheria/features/home/provider/geolocation_provider.dart';
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
    final currentLocationAsync = ref.watch(geolocationProvider);

    final currentLocationLabel = currentLocationAsync.when(
      data: (geoLocation) => geoLocation.displayName.isEmpty
          ? 'Current location'
          : geoLocation.displayName,
      loading: () => 'Current location',
      error: (_, _) => 'Current location',
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
              isSelected: selectedId == currentLocationId,
              canDelete: false,
              colors: colors,
              onTap: () async {
                await ref
                    .read(selectedLocationProvider.notifier)
                    .select(currentLocationId);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              onDelete: null,
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
                    isSelected: selectedId == location.id,
                    canDelete: true,
                    colors: colors,
                    onTap: () async {
                      await ref
                          .read(selectedLocationProvider.notifier)
                          .select(location.id);
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
  });

  final String title;
  final bool isSelected;
  final bool canDelete;
  final AppColors colors;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

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
