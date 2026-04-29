import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:weatheria/core/core_barrel.dart';
import 'package:weatheria/core/utils/connectivity/connectivity_listener.dart';
import 'package:weatheria/core/utils/provider/weather_provider.dart';
import 'package:weatheria/core/utils/weather_icons.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';
import 'package:weatheria/features/home/widget/city_search.dart';
import 'package:weatheria/features/home/widget/home_loading_shimmers.dart';
import 'package:weatheria/features/home/widget/location_picker_sheet.dart';
import 'package:weatheria/features/weather/model/hourly_weather.dart';
import 'package:weatheria/features/weather/model/weather.dart';
import 'package:weatheria/features/weather/model/weekly_weather.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    final colors = isDark ? AppColors.dark : AppColors.light;

    final weather = ref.watch(currentWeatherProvider);
    final hourly = ref.watch(hourlyWeatherProvider);
    final weekly = ref.watch(weeklyWeatherProvider);
    final activeLocation = ref.watch(activeLocationProvider);
    final isoffline = ref.watch(isOfflineProvider);

    void _showCitySearchDialog() {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: true,
        builder: (context) => CitySearch(),
      );
    }

    void _showLocationPickerDialog() {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: true,
        builder: (context) => const LocationPickerSheet(),
      );
    }

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isoffline
                        ? const SizedBox(height: 16)
                        : SizedBox(height: MediaQuery.of(context).padding.top),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              activeLocation.when(
                                data: (location) => Text(
                                  location.label,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: colors.textColor,
                                  ),
                                ),
                                loading: () =>
                                    HomeLocationShimmer(colors: colors),
                                error: (_, _) =>
                                    HomeLocationShimmer(colors: colors),
                              ),
                              Text(
                                DateFormat(
                                  'EEEE, d MMMM',
                                ).format(DateTime.now()),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colors.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(themeProvider.notifier)
                                .setTheme(
                                  isDark ? ThemeMode.light : ThemeMode.dark,
                                );
                          },
                          icon: PhosphorIcon(
                            isDark
                                ? PhosphorIconsFill.moon
                                : PhosphorIconsRegular.sun,
                            color: colors.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    weather.when(
                      data: (weatherData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconTheme(
                                      data: IconThemeData(
                                        size: 32,
                                        color: colors.textColor,
                                      ),
                                      child: getWeatherIcon(
                                        weatherData.current.isDay,
                                        weathercode:
                                            weatherData.current.condition.code,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${weatherData.current.tempC.round()}°',
                                      style: AppTextStyles.displayLarge
                                          .copyWith(
                                            fontSize: 72,
                                            fontWeight: FontWeight.w700,
                                            height: 0.9,
                                            color: colors.textColor,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  weatherData.current.condition.text,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 0.9,
                                    color: colors.textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            hourly.when(
                              data: (hourlyData) => _HourlyForecastRow(
                                entries: _selectNowPlusSevenHours(
                                  hourlyData: hourlyData,
                                  localTimeSource: weatherData,
                                ),
                                colors: colors,
                              ),
                              error: (error, _) => _InlineError(
                                text: error.toString(),
                                colors: colors,
                              ),
                              loading: () => HomeHourlyShimmer(colors: colors),
                            ),
                            const SizedBox(height: 18),
                            weekly.when(
                              data: (weeklyData) => Column(
                                children: [
                                  _MetricsGrid(
                                    metrics: _buildMetrics(
                                      weatherData: weatherData,
                                      weeklyData: weeklyData,
                                    ),
                                    colors: colors,
                                  ),
                                  const SizedBox(height: 14),
                                  _DailyForecastRow(
                                    forecastDays: weeklyData.forecastDays,
                                    colors: colors,
                                  ),
                                ],
                              ),
                              error: (error, _) => _InlineError(
                                text: error.toString(),
                                colors: colors,
                              ),
                              loading: () => HomeWeeklyShimmer(colors: colors),
                            ),
                          ],
                        );
                      },
                      error: (error, stacktrace) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 128),
                              child: Center(
                                child: Column(
                                  children: [
                                    PhosphorIcon(
                                      PhosphorIconsRegular.wifiSlash,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'No internet connection',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: colors.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: HomeCurrentWeatherShimmer(colors: colors),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 0,
              left: 0,
              child: SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.textColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _showCitySearchDialog,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Icon(
                              PhosphorIconsRegular.magnifyingGlass,
                              color: colors.backgroundColor,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showLocationPickerDialog,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: Icon(
                              PhosphorIconsFill.mapTrifold,
                              color: colors.backgroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyForecastRow extends StatelessWidget {
  const _HourlyForecastRow({required this.entries, required this.colors});

  final List<WeatherEntry> entries;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final entry = entries[index];

          return SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0 ? 'Now' : _formatHour(entry.time),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                IconTheme(
                  data: IconThemeData(
                    size: 24,
                    color: colors.textColor.withValues(alpha: 0.86),
                  ),
                  child: getWeatherIcon(
                    entry.isDay,
                    weathercode: entry.condition.code,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.tempC.round()}°',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyForecastRow extends StatelessWidget {
  const _DailyForecastRow({required this.forecastDays, required this.colors});

  final List<ForecastDay> forecastDays;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    if (forecastDays.isEmpty) {
      return const SizedBox.shrink();
    }

    final days = forecastDays.take(5).toList();
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final day = days[index];
          final date = DateTime.tryParse(day.date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date == null ? day.date : DateFormat('d MMM').format(date),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${day.day.mintempC.round()}°/${day.day.maxtempC.round()}°',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics, required this.colors});

  final List<_MetricData> metrics;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 18,
        childAspectRatio: 2.15,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: colors.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              metric.value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: colors.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.secondaryTextColor,
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData({required this.label, required this.value});

  final String label;
  final String value;
}

List<WeatherEntry> _selectNowPlusSevenHours({
  required HourlyWeather hourlyData,
  required Weather localTimeSource,
}) {
  if (hourlyData.list.isEmpty) {
    return const [];
  }

  final localTime =
      DateTime.tryParse(localTimeSource.location.localtime) ?? DateTime.now();

  final withDate = hourlyData.list.map((entry) {
    return (entry: entry, time: DateTime.tryParse(entry.time));
  }).toList();

  final startIndex = withDate.indexWhere((entryWithTime) {
    final time = entryWithTime.time;
    if (time == null) {
      return false;
    }
    return !time.isBefore(localTime.subtract(const Duration(hours: 1)));
  });

  final normalizedStart = startIndex < 0 ? 0 : startIndex;
  final end = (normalizedStart + 8).clamp(0, hourlyData.list.length);
  return hourlyData.list.sublist(normalizedStart, end);
}

List<_MetricData> _buildMetrics({
  required Weather weatherData,
  required WeeklyWeather weeklyData,
}) {
  final today = weeklyData.forecastDays.isNotEmpty
      ? weeklyData.forecastDays.first
      : null;

  return [
    _MetricData(label: 'Sunrise', value: today?.astro.sunrise ?? '--'),
    _MetricData(label: 'Sunset', value: today?.astro.sunset ?? '--'),
    _MetricData(
      label: 'Feels like',
      value: '${weatherData.current.feelslikeC.round()}°',
    ),
    _MetricData(
      label: 'Wind',
      value:
          '${weatherData.current.windKph.round()} km/h ${weatherData.current.windDir}',
    ),
    _MetricData(label: 'Humidity', value: '${weatherData.current.humidity}%'),
    _MetricData(
      label: 'Atmospheric pressure',
      value: '${weatherData.current.pressureMb.round()} hPa',
    ),
    _MetricData(
      label: 'Visibility',
      value: '${weatherData.current.visKm.round()} km',
    ),
    _MetricData(
      label: 'Ultraviolet',
      value:
          '${weatherData.current.uv.round()} ${_uvLevel(weatherData.current.uv)}',
    ),
  ];
}

String _uvLevel(double uv) {
  if (uv < 3) {
    return 'low';
  }
  if (uv < 6) {
    return 'moderate';
  }
  if (uv < 8) {
    return 'high';
  }
  if (uv < 11) {
    return 'very high';
  }
  return 'extreme';
}

String _formatHour(String source) {
  final time = DateTime.tryParse(source);
  if (time == null) {
    return source;
  }
  return DateFormat('HH:mm').format(time);
}
