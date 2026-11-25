import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_strings.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_icon.dart';
import '../../glucose/data/providers/glucose_providers.dart';
import '../../glucose/domain/entities/glucose_reading.dart';
import '../../glucose/domain/entities/glucose_result.dart';
import '../../glucose/domain/entities/glucose_status.dart';
import '../../glucose/domain/use_cases/average_reading.dart';
import '../../glucose/domain/use_cases/classify_reading.dart';
import '../../glucose/domain/use_cases/highest_and_lowest.dart';
import 'dashboard_strings.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayReadings = ref.watch(todayGlucoseReadingsProvider);

    return Scaffold(
      body: AppBackground(
        variant: AppBackgroundVariant.header,
        child: SafeArea(
          child: todayReadings.when(
            data: (readings) => _DashboardContent(
              todayReadings: readings,
              weeklyReadings: ref.watch(lastSevenDaysGlucoseReadingsProvider),
            ),
            loading: () => const _StatusContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(DashboardStrings.loading),
                ],
              ),
            ),
            error: (error, stackTrace) => _StatusContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DashboardStrings.loadError,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(todayGlucoseReadingsProvider),
                    child: const Text(DashboardStrings.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/glucose/entry'),
        icon: const Icon(Icons.add),
        label: const Text(DashboardStrings.addReading),
      ),
      bottomNavigationBar: const _DashboardNavigationBar(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.todayReadings,
    required this.weeklyReadings,
  });

  final List<GlucoseReading> todayReadings;
  final AsyncValue<List<GlucoseReading>> weeklyReadings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          sliver: SliverList.list(
            children: [
              Text(
                '${_greeting()}, ${DashboardStrings.nameFallback}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
              ),
              const SizedBox(height: 24),
              if (todayReadings.isEmpty)
                _EmptyReadingsCard(
                  onAddReading: () => context.push('/glucose/entry'),
                )
              else ...[
                _LatestReadingCard(reading: todayReadings.first),
                const SizedBox(height: 24),
                Text(
                  DashboardStrings.todaySummary,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _TodaySummary(readings: todayReadings),
              ],
              const SizedBox(height: 24),
              _WeeklyTrendCard(readings: weeklyReadings),
              const SizedBox(height: 16),
              const _NextReminderCard(),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return DashboardStrings.morningGreeting;
    }
    if (hour < 15) {
      return DashboardStrings.afternoonGreeting;
    }
    return DashboardStrings.eveningGreeting;
  }
}

class _LatestReadingCard extends StatelessWidget {
  const _LatestReadingCard({required this.reading});

  final GlucoseReading reading;

  @override
  Widget build(BuildContext context) {
    final status = _statusFor(reading.valueMgDl);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DashboardStrings.latestReadingTitle,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  key: const ValueKey('latest-glucose-value'),
                  '${reading.valueMgDl}',
                  style: AppTextStyles.glucoseValue.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'mg/dL',
                  style: textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            status == null
                ? const _InvalidReadingBadge()
                : _StatusBadge(status: status),
            const SizedBox(height: 12),
            Text(
              '${DashboardStrings.measuredAt} '
              '${_formatTime(reading.timestamp)}, ${reading.context.label}',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.readings});

  final List<GlucoseReading> readings;

  @override
  Widget build(BuildContext context) {
    final average = const AverageReading()(readings);
    final extremes = const HighestAndLowest()(readings);
    final width = MediaQuery.sizeOf(context).width;
    final itemWidth = (width - 56) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          width: itemWidth,
          title: DashboardStrings.averageToday,
          value: average?.round().toString() ?? '—',
        ),
        _SummaryCard(
          width: itemWidth,
          title: DashboardStrings.highestToday,
          value: extremes?.highest.valueMgDl.toString() ?? '—',
        ),
        _SummaryCard(
          width: itemWidth,
          title: DashboardStrings.lowestToday,
          value: extremes?.lowest.valueMgDl.toString() ?? '—',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.width,
    required this.title,
    required this.value,
  });

  final double width;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(
                AppStrings.glucoseUnit,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.readings});

  final AsyncValue<List<GlucoseReading>> readings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DashboardStrings.weeklyTrend, style: textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 132,
              child: Semantics(
                label: DashboardStrings.glucoseSparkline,
                child: readings.when(
                  data: (values) => values.isEmpty
                      ? Center(
                          child: Text(
                            DashboardStrings.insufficientTrend,
                            style: textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _Sparkline(readings: values),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      DashboardStrings.loadError,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
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

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.readings});

  final List<GlucoseReading> readings;

  @override
  Widget build(BuildContext context) {
    final dailyAverages = _dailyAverages(readings);
    if (dailyAverages.isEmpty) {
      return Center(
        child: Text(
          DashboardStrings.insufficientTrend,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    final values = dailyAverages.map((spot) => spot.y).toList();
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final padding = math.max((max - min) * 0.2, 10);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: min - padding,
        maxY: max + padding,
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: dailyAverages,
            isCurved: true,
            barWidth: 3,
            color: Theme.of(context).colorScheme.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _dailyAverages(List<GlucoseReading> values) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final spots = <FlSpot>[];

    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      final date = today.subtract(Duration(days: 6 - dayIndex));
      final dayValues = values.where((reading) {
        return reading.timestamp.year == date.year &&
            reading.timestamp.month == date.month &&
            reading.timestamp.day == date.day;
      });
      final average = const AverageReading()(dayValues);
      if (average != null) {
        spots.add(FlSpot(dayIndex.toDouble(), average));
      }
    }

    return spots;
  }
}

class _NextReminderCard extends StatelessWidget {
  const _NextReminderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const AppIcon(AppIcons.bell),
        title: const Text(DashboardStrings.nextReminder),
        subtitle: const Text(DashboardStrings.noReminder),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () => context.push('/reminders'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptyReadingsCard extends StatelessWidget {
  const _EmptyReadingsCard({required this.onAddReading});

  final VoidCallback onAddReading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const AppIcon(AppIcons.glucoseMeter, size: 40),
            const SizedBox(height: 16),
            Text(
              DashboardStrings.emptyTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              DashboardStrings.emptyAction,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAddReading,
              child: const Text(DashboardStrings.addReading),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final GlucoseStatus status;

  @override
  Widget build(BuildContext context) {
    final statusColor = status.colorFor(Theme.of(context).brightness);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(status.icon, size: 20, color: statusColor),
            const SizedBox(width: 8),
            Text(
              status.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DashboardNavigationBar extends StatelessWidget {
  const _DashboardNavigationBar();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        final paths = ['/', '/history', '/food', '/settings'];
        context.go(paths[index]);
      },
      destinations: const [
        NavigationDestination(
          icon: AppIcon(AppIcons.drop),
          label: DashboardStrings.home,
        ),
        NavigationDestination(
          icon: AppIcon(AppIcons.calendar),
          label: DashboardStrings.history,
        ),
        NavigationDestination(
          icon: AppIcon(AppIcons.plate),
          label: DashboardStrings.notes,
        ),
        NavigationDestination(
          icon: AppIcon(AppIcons.family),
          label: DashboardStrings.profile,
        ),
      ],
    );
  }
}

String _formatTime(DateTime timestamp) {
  final hour = timestamp.hour.toString().padLeft(2, '0');
  final minute = timestamp.minute.toString().padLeft(2, '0');
  return '$hour.$minute';
}

GlucoseStatus? _statusFor(int valueMgDl) {
  final result = const ClassifyReading()(valueMgDl);
  return switch (result) {
    GlucoseSuccess<GlucoseStatus>(:final value) => value,
    GlucoseFailure<GlucoseStatus>() => null,
  };
}

class _InvalidReadingBadge extends StatelessWidget {
  const _InvalidReadingBadge();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(AppIcons.warning, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              DashboardStrings.invalidReading,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
