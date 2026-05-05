import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:weatheria/core/core_barrel.dart';
import 'package:weatheria/core/utils/connectivity/connectivity_listener.dart';
import 'package:weatheria/core/utils/platform_helpers.dart';
import 'package:weatheria/core/utils/provider/weather_provider.dart';
import 'package:weatheria/core/utils/weather_icons.dart';
import 'package:weatheria/core/widget/adaptive_dialog.dart';
import 'package:weatheria/core/widget/app_menu_bar.dart';
import 'package:weatheria/core/widget/context_menu.dart';
import 'package:weatheria/core/widget/hover_scale_button.dart';
import 'package:weatheria/features/home/model/saved_location.dart';
import 'package:weatheria/features/home/provider/saved_locations_provider.dart';
import 'package:weatheria/features/home/provider/geolocation_provider.dart';
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
  bool _showInitialLocationAnimation = true;
  DateTime? _lastRefreshAt;
  static const Duration _refreshDebounce = Duration(milliseconds: 900);

  void _showCitySearchDialog() {
    showAdaptiveSheet(
      context: context,
      builder: (context) => const CitySearch(),
    );
  }

  void _showLocationPickerDialog() {
    showAdaptiveSheet(
      context: context,
      builder: (context) => const LocationPickerSheet(),
    );
  }

  void _refreshWeather() {
    final now = DateTime.now();
    final lastRefreshAt = _lastRefreshAt;
    if (lastRefreshAt != null &&
        now.difference(lastRefreshAt) < _refreshDebounce) {
      return;
    }

    _lastRefreshAt = now;
    ref.invalidate(currentWeatherProvider);
    ref.invalidate(hourlyWeatherProvider);
    ref.invalidate(weeklyWeatherProvider);
    ref.invalidate(geolocationProvider);
    ref.invalidate(currentLocationSessionProvider);
    ref.invalidate(connectivityProvider);
  }

  void _toggleTheme() {
    final themeMode = ref.read(themeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    ref.read(themeProvider.notifier).setTheme(
          isDark ? ThemeMode.light : ThemeMode.dark,
        );
  }

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
    final isOffline = ref.watch(isOfflineProvider);

    return AppMenuBarWrapper(
      onSearch: _showCitySearchDialog,
      onLocationPicker: _showLocationPickerDialog,
      onRefresh: _refreshWeather,
      onToggleTheme: _toggleTheme,
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final breakpoint =
                LayoutBreakpoint.fromWidth(constraints.maxWidth);

            return SizedBox.expand(
              child: Stack(
                children: [
                  _buildContent(
                    context: context,
                    breakpoint: breakpoint,
                    colors: colors,
                    isDark: isDark,
                    weather: weather,
                    hourly: hourly,
                    weekly: weekly,
                    activeLocation: activeLocation,
                    isOffline: isOffline,
                  ),
                  _ActionBar(
                    colors: colors,
                    breakpoint: breakpoint,
                    onSearch: _showCitySearchDialog,
                    onLocationPicker: _showLocationPickerDialog,
                    onRefresh: _refreshWeather,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required LayoutBreakpoint breakpoint,
    required AppColors colors,
    required bool isDark,
    required AsyncValue<Weather> weather,
    required AsyncValue<HourlyWeather> hourly,
    required AsyncValue<WeeklyWeather> weekly,
    required ActiveLocation activeLocation,
    required bool isOffline,
  }) {
    final horizontalPadding = breakpoint == LayoutBreakpoint.expanded
        ? 40.0
        : breakpoint == LayoutBreakpoint.medium
            ? 32.0
            : 20.0;

    Widget content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isOffline
                    ? const SizedBox(height: 16)
                    : SizedBox(height: MediaQuery.of(context).padding.top),
                _buildHeader(
                  activeLocation: activeLocation,
                  colors: colors,
                  isDark: isDark,
                  breakpoint: breakpoint,
                ),
                const SizedBox(height: 16),
                weather.when(
                  data: (weatherData) {
                    return _buildWeatherContent(
                      weatherData: weatherData,
                      hourly: hourly,
                      weekly: weekly,
                      colors: colors,
                      isDark: isDark,
                      breakpoint: breakpoint,
                    );
                  },
                  error: (error, _) => _buildErrorState(
                    error: error,
                    colors: colors,
                  ),
                  loading: () => Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: HomeCurrentWeatherShimmer(colors: colors),
                  ),
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );

    return content;
  }

  Widget _buildHeader({
    required ActiveLocation activeLocation,
    required AppColors colors,
    required bool isDark,
    required LayoutBreakpoint breakpoint,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppContextMenu(
            menuItems: [
              AppContextMenuItem(
                label: 'Refresh Weather',
                icon: Icons.refresh,
                onTap: _refreshWeather,
              ),
              AppContextMenuItem(
                label: 'Copy Location',
                icon: Icons.copy,
                onTap: () {
                 
                },
              ),
              AppContextMenuItem(
                label: 'Toggle Theme',
                icon: isDark ? Icons.light_mode : Icons.dark_mode,
                onTap: _toggleTheme,
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationLabel(
                  label: activeLocation.label,
                  colors: colors,
                ),
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        HoverScaleButton(
          tooltip: 'Toggle theme',
          onTap: _toggleTheme,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PhosphorIcon(
              isDark
                  ? PhosphorIconsFill.moon
                  : PhosphorIconsRegular.sun,
              color: colors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherContent({
    required Weather weatherData,
    required AsyncValue<HourlyWeather> hourly,
    required AsyncValue<WeeklyWeather> weekly,
    required AppColors colors,
    required bool isDark,
    required LayoutBreakpoint breakpoint,
  }) {
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
                    weathercode: weatherData.current.condition.code,
                  ),
                ),
                const SizedBox(width: 12),
                _buildTemperatureText(
                  weatherData: weatherData,
                  colors: colors,
                  isDark: isDark,
                ),
              ],
            ),
            Flexible(
              child: Text(
                weatherData.current.condition.text,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 0.9,
                  color: colors.textColor,
                ),
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
        weekly.when(
          data: (weeklyData) => Column(
            children: [
              _MetricsGrid(
                metrics: _buildMetrics(
                  weatherData: weatherData,
                  weeklyData: weeklyData,
                ),
                colors: colors,
                breakpoint: breakpoint,
              ),
              const SizedBox(height: 4),
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
  }

  Widget _buildErrorState({
    required Object error,
    required AppColors colors,
  }) {
    final msg = error.toString().toLowerCase();
    final isLocationError = _isLocationErrorMessage(msg);
    final isNetworkError = _isNetworkErrorMessage(msg);

    final icon = isLocationError
        ? PhosphorIconsRegular.mapPin
        : isNetworkError
            ? PhosphorIconsRegular.wifiSlash
            : PhosphorIconsRegular.warningCircle;

    final headline = isLocationError
        ? 'Location unavailable'
        : isNetworkError
            ? 'No internet connection'
            : 'Couldn\'t load weather data';

    final subtitle = isLocationError
        ? 'Please enable location services\nor grant location permission.'
        : isNetworkError
            ? 'Check your connection and try again.'
            : 'Something went wrong while loading weather data.\nPlease try again.';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 96),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhosphorIcon(
                  icon,
                  size: 48,
                  color: colors.textColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 14),
                Text(
                  headline,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.textColor,
                    foregroundColor: colors.backgroundColor,
                  ),
                  onPressed: _refreshWeather,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationLabel({
    required String label,
    required AppColors colors,
  }) {
    final textStyle = AppTextStyles.titleLarge.copyWith(
      color: colors.textColor,
    );

    if (!_showInitialLocationAnimation) {
      return Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }

    return SizedBox(
      height: 32,
      child: AnimatedTextKit(
        isRepeatingAnimation: false,
        totalRepeatCount: 1,
        onFinished: () {
          if (!mounted) {
            return;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _showInitialLocationAnimation = false;
              });
            }
          });
        },
        animatedTexts: [
          TyperAnimatedText(
            label,
            textStyle: textStyle,
            speed: const Duration(milliseconds: 150),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureText({
    required Weather weatherData,
    required AppColors colors,
    required bool isDark,
  }) {
    final temperatureText = '${weatherData.current.tempC.round()}\u00B0';
    final textStyle = AppTextStyles.displayLarge.copyWith(
      fontSize: 72,
      fontWeight: FontWeight.w700,
      height: 0.9,
      color: colors.textColor,
    );

    return AnimatedTextKit(
      key: ValueKey(
        '${isDark}_${weatherData.location.lat}_${weatherData.location.lon}_${weatherData.current.tempC.round()}',
      ),
      isRepeatingAnimation: false,
      totalRepeatCount: 1,
      displayFullTextOnTap: true,
      animatedTexts: [
        TyperAnimatedText(
          temperatureText,
          textStyle: textStyle,
          speed: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.colors,
    required this.breakpoint,
    required this.onSearch,
    required this.onLocationPicker,
    required this.onRefresh,
  });

  final AppColors colors;
  final LayoutBreakpoint breakpoint;
  final VoidCallback onSearch;
  final VoidCallback onLocationPicker;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors.textColor,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HoverScaleButton(
                  tooltip: 'Search city (Ctrl+F)',
                  onTap: onSearch,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      color: colors.backgroundColor,
                    ),
                  ),
                ),
                HoverScaleButton(
                  tooltip: 'Saved locations (Ctrl+L)',
                  onTap: onLocationPicker,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      PhosphorIconsFill.mapTrifold,
                      color: colors.backgroundColor,
                    ),
                  ),
                ),
                if (breakpoint != LayoutBreakpoint.compact)
                  HoverScaleButton(
                    tooltip: 'Refresh (F5)',
                    onTap: onRefresh,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        PhosphorIconsRegular.arrowClockwise,
                        color: colors.backgroundColor,
                      ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  '${entry.tempC.round()}\u00B0',
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
    return SizedBox.fromSize(
      size: const Size(double.infinity, 62),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 24),
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
                '${day.day.mintempC.round()}\u00B0/${day.day.maxtempC.round()}\u00B0',
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
  const _MetricsGrid({
    required this.metrics,
    required this.colors,
    required this.breakpoint,
  });

  final List<_MetricData> metrics;
  final AppColors colors;
  final LayoutBreakpoint breakpoint;

  @override
  Widget build(BuildContext context) {
    final columns = metricsColumnCount(breakpoint);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: columns == 4 ? 32 : 24,
        childAspectRatio: columns == 4
            ? 1.6
            : columns == 3
                ? 1.7
                : 2.0,
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
      value: '${weatherData.current.feelslikeC.round()}\u00B0',
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

bool _isLocationErrorMessage(String message) {
  return message.contains('location') ||
      message.contains('permission') ||
      message.contains('geolocator') ||
      message.contains('geocod') ||
      message.contains('disabled');
}

bool _isNetworkErrorMessage(String message) {
  return message.contains('socketexception') ||
      message.contains('network is unreachable') ||
      message.contains('failed host lookup') ||
      message.contains('connection error') ||
      message.contains('connection timed out') ||
      message.contains('timed out') ||
      message.contains('xmlhttprequest') ||
      message.contains('clientexception') ||
      message.contains('offline');
}
