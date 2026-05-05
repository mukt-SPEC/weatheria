import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weatheria/core/theme/app_color.dart';

class HomeLocationShimmer extends StatelessWidget {
  const HomeLocationShimmer({super.key, required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return _HomeShimmer(
      colors: colors,
      child: Container(
        width: 160,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class HomeCurrentWeatherShimmer extends StatelessWidget {
  const HomeCurrentWeatherShimmer({super.key, required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return _HomeShimmer(
      colors: colors,
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 170,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeHourlyShimmer extends StatelessWidget {
  const HomeHourlyShimmer({super.key, required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return _HomeShimmer(
      colors: colors,
      child: SizedBox(
        height: 94,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 8,
          separatorBuilder: (_, _) => const SizedBox(width: 18),
          itemBuilder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(32, 12),
                const SizedBox(height: 6),
                _box(22, 22),
                const SizedBox(height: 6),
                _box(26, 14),
              ],
            );
          },
        ),
      ),
    );
  }
}

class HomeWeeklyShimmer extends StatelessWidget {
  const HomeWeeklyShimmer({super.key, required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return _HomeShimmer(
      colors: colors,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 18,
              childAspectRatio: 2.15,
            ),
            itemBuilder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(74, 12),
                  const SizedBox(height: 6),
                  _box(110, 18),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(52, 12),
                    const SizedBox(height: 4),
                    _box(66, 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer({required this.child, required this.colors});

  final Widget child;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      period: const Duration(milliseconds: 1100),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          colors.secondaryTextColor.withValues(alpha: 0.16),
          colors.textColor.withValues(alpha: 0.08),
          colors.secondaryTextColor.withValues(alpha: 0.16),
        ],
      ),
      child: child,
    );
  }
}

Widget _box(double width, double height) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
