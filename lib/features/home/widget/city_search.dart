import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:weatheria/core/theme/app_color.dart';
import 'package:weatheria/core/theme/text_style.dart';
import 'package:weatheria/core/theme/theme_provider.dart';
import 'package:weatheria/core/utils/provider/weather_provider.dart';
import 'package:weatheria/core/utils/weather_icons.dart';
import 'package:weatheria/features/home/model/saved_location.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';

class CitySearch extends ConsumerStatefulWidget {
  const CitySearch({super.key});

  @override
  ConsumerState<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends ConsumerState<CitySearch> {
  final TextEditingController _controller = TextEditingController();
  String? _searchQuery;

  void _searchLocation() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _searchQuery = _controller.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final colors = isDark ? AppColors.dark : AppColors.light;

    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final weatherAsync = _searchQuery != null
        ? ref.watch(searchWeatherProvider(_searchQuery!))
        : null;

    return CupertinoActionSheet(
      message: Padding(
        padding: EdgeInsets.only(
          bottom: bottomInset > 0 ? bottomInset - 40 : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoSearchTextField(
              controller: _controller,
              placeholder: 'Search for a city',
              onSuffixTap: _searchQuery != null
                  ? () {
                      _controller.clear();
                      setState(() => _searchQuery = null);
                    }
                  : null,
              onSubmitted: (_) => _searchLocation(),
            ),
            const SizedBox(height: 16),

            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: _searchQuery == null
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            weatherAsync?.when(
                              data: (weather) {
                                return Column(
                                  children: [
                                    IconTheme(
                                      data: IconThemeData(
                                        size: 48,
                                        color: colors.textColor,
                                      ),
                                      child: getWeatherIcon(
                                        weather.current.isDay,
                                        weathercode:
                                            weather.current.condition.code,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${weather.location.name}: ${weather.current.condition.text}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "${weather.current.tempC.round()}°C",
                                      style: AppTextStyles.titleLarge.copyWith(
                                        fontSize: 64,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    CupertinoButton(
                                      minimumSize: Size(double.infinity, 40),
                                      color: colors.textColor,
                                      sizeStyle: CupertinoButtonSize.medium,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),

                                      onPressed: () async {
                                        final savedLocationId =
                                            SavedLocation.coordinateId(
                                              weather.location.lat,
                                              weather.location.lon,
                                            );

                                        await ref
                                            .read(
                                              savedLocationsProvider.notifier,
                                            )
                                            .addFromWeatherLocation(
                                              weather.location,
                                            );
                                        await ref
                                            .read(
                                              selectedLocationProvider.notifier,
                                            )
                                            .select(savedLocationId);

                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Add Location',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontSize: 14,
                                              color: colors.backgroundColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.only(top: 40.0),
                                child: Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              ),
                              error: (err, stack) => Padding(
                                padding: const EdgeInsets.only(top: 40.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIconsFill.buildings,
                                        size: 48,
                                      ),
                                      Text(
                                        "City not found",
                                        style: AppTextStyles.headlineSmall
                                            .copyWith(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ) ??
                            const SizedBox.shrink(),
                      ),
                    ),
            ),

            if (_searchQuery == null)
              CupertinoButton(
                minimumSize: Size(double.infinity, 40),
                color: colors.textColor,
                sizeStyle: CupertinoButtonSize.medium,
                onPressed: _searchLocation,
                child: Text(
                  'Search',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.backgroundColor,
                    fontSize: 16,
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
