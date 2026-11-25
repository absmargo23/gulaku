import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../glucose/data/providers/glucose_providers.dart';
import '../../glucose/domain/entities/estimated_a1c.dart';
import '../../glucose/domain/entities/glucose_range.dart';
import '../../glucose/domain/entities/glucose_reading.dart';
import '../../glucose/domain/entities/glucose_result.dart';
import '../../glucose/domain/entities/glucose_status.dart';
import '../../glucose/domain/entities/reading_extremes.dart';
import '../../glucose/domain/use_cases/average_reading.dart';
import '../../glucose/domain/use_cases/calculate_time_in_range.dart';
import '../../glucose/domain/use_cases/classify_reading.dart';
import '../../glucose/domain/use_cases/estimate_a1c.dart';
import '../../glucose/domain/use_cases/highest_and_lowest.dart';
import 'history_strings.dart';

enum _HistoryPeriod { daily, weekly, monthly }

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _HistoryPeriod.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(HistoryStrings.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: HistoryStrings.daily),
              Tab(text: HistoryStrings.weekly),
              Tab(text: HistoryStrings.monthly),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _HistoryPeriodView(period: _HistoryPeriod.daily),
            _HistoryPeriodView(period: _HistoryPeriod.weekly),
            _HistoryPeriodView(period: _HistoryPeriod.monthly),
          ],
        ),
      ),
    );
  }
}

class _HistoryPeriodView extends ConsumerWidget {
  const _HistoryPeriodView({required this.period});

  final _HistoryPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readings = ref.watch(lastThirtyDaysGlucoseReadingsProvider);

    return readings.when(
      data: (values) {
        final filteredReadings = _filterReadings(values, period);
        if (filteredReadings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                HistoryStrings.empty,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return _HistoryResults(readings: filteredReadings);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                HistoryStrings.loadError,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(lastThirtyDaysGlucoseReadingsProvider),
                child: const Text(HistoryStrings.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<GlucoseReading> _filterReadings(
    List<GlucoseReading> readings,
    _HistoryPeriod period,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = switch (period) {
      _HistoryPeriod.daily => today,
      _HistoryPeriod.weekly => today.subtract(const Duration(days: 6)),
      _HistoryPeriod.monthly => today.subtract(const Duration(days: 29)),
    };

    return readings
        .where(
          (reading) =>
              !reading.timestamp.isBefore(start) &&
              reading.timestamp.isBefore(today.add(const Duration(days: 1))),
        )
        .toList(growable: false);
  }
}

class _HistoryResults extends StatelessWidget {
  const _HistoryResults({required this.readings});

  final List<GlucoseReading> readings;

  @override
  Widget build(BuildContext context) {
    final range = const CalculateTimeInRange().range;
    final inRangePercent = const CalculateTimeInRange()(readings);
    final average = const AverageReading()(readings);
    final extremes = const HighestAndLowest()(readings);
    final a1c = const EstimateA1c()(readings);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _ChartCard(
              readings: readings,
              low: range.low,
              normalMax: range.normalMax,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: _SummaryCard(
              readings: readings,
              inRangePercent: inRangePercent,
              average: average,
              extremes: extremes,
              a1c: a1c,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              HistoryStrings.readings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverList.builder(
          itemCount: readings.length,
          itemBuilder: (context, index) {
            final reading = readings[index];
            return _DismissibleReading(
              reading: reading,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            );
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom + 16,
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.readings,
    required this.low,
    required this.normalMax,
  });

  final List<GlucoseReading> readings;
  final int low;
  final int normalMax;

  @override
  Widget build(BuildContext context) {
    final ordered = readings.reversed.toList(growable: false);
    final spots = [
      for (var index = 0; index < ordered.length; index++)
        FlSpot(index.toDouble(), ordered[index].valueMgDl.toDouble()),
    ];
    final minValue = ordered
        .map((reading) => reading.valueMgDl)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    final maxValue = ordered
        .map((reading) => reading.valueMgDl)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final yPadding = math.max((maxValue - minValue) * 0.15, 10);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HistoryStrings.chartTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${HistoryStrings.targetRange}: $low–$normalMax ${HistoryStrings.mgDl}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Semantics(
                label: HistoryStrings.chartTitle,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: math.max(spots.length - 1, 1).toDouble(),
                    minY: math.min(minValue - yPadding, low - 10),
                    maxY: math.max(maxValue + yPadding, normalMax + 10),
                    gridData:
                        const FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    rangeAnnotations: RangeAnnotations(
                      horizontalRangeAnnotations: [
                        HorizontalRangeAnnotation(
                          y1: low.toDouble(),
                          y2: normalMax.toDouble(),
                          color: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 2,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                        dotData: FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            final reading = ordered[index];
                            return _statusDotPainter(
                              _statusFor(reading.valueMgDl),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _StatusLegend(),
          ],
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  const _StatusLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: GlucoseStatus.values.map((status) {
        final statusColor = status.colorFor(Theme.of(context).brightness);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(status.icon, size: 18, color: statusColor),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                  ),
            ),
          ],
        );
      }).toList(growable: false),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.readings,
    required this.inRangePercent,
    required this.average,
    required this.extremes,
    required this.a1c,
  });

  final List<GlucoseReading> readings;
  final double? inRangePercent;
  final double? average;
  final ReadingExtremes? extremes;
  final EstimatedA1c? a1c;

  @override
  Widget build(BuildContext context) {
    final inRangeCount = _inRangeCount(readings);
    final outOfRangeCount = readings.length - inRangeCount;
    final percent = inRangePercent?.round() ?? 0;
    final sections = <PieChartSectionData>[
      if (inRangeCount > 0)
        PieChartSectionData(
          value: inRangeCount.toDouble(),
          color: AppColors.green,
          title: '',
          radius: 16,
        ),
      if (outOfRangeCount > 0)
        PieChartSectionData(
          value: outOfRangeCount.toDouble(),
          color: AppColors.amber,
          title: '',
          radius: 16,
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${HistoryStrings.timeInRange} $percent%',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Semantics(
                      label: '${HistoryStrings.timeInRange} $percent%',
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 34,
                          startDegreeOffset: -90,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _Metric(
                  label: HistoryStrings.average,
                  value: average?.round().toString() ?? '—',
                ),
                _Metric(
                  label: HistoryStrings.highest,
                  value: extremes?.highest.valueMgDl.toString() ?? '—',
                ),
                _Metric(
                  label: HistoryStrings.lowest,
                  value: extremes?.lowest.valueMgDl.toString() ?? '—',
                ),
                _Metric(
                  label: HistoryStrings.estimatedA1c,
                  value: a1c?.value.toStringAsFixed(1) ?? '—',
                  suffix: a1c?.label,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _inRangeCount(List<GlucoseReading> values) {
    const range = GlucoseRange();
    return values
        .where(
          (reading) =>
              reading.valueMgDl >= range.low &&
              reading.valueMgDl <= range.normalMax,
        )
        .length;
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.suffix,
  });

  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          if (suffix != null)
            Text(suffix!, style: Theme.of(context).textTheme.bodyMedium),
          if (label != HistoryStrings.estimatedA1c)
            Text(HistoryStrings.mgDl,
                style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DismissibleReading extends ConsumerWidget {
  const _DismissibleReading({
    required this.reading,
    required this.margin,
  });

  final GlucoseReading reading;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = _statusFor(reading.valueMgDl);
    return Dismissible(
      key: ValueKey(reading.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: margin,
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const AppIcon(AppIcons.warning),
      ),
      onDismissed: (direction) async {
        final repository = ref.read(glucoseRepositoryProvider);
        final messenger = ScaffoldMessenger.of(context);
        try {
          await repository.deleteReading(reading.id);
        } on Exception {
          ref.invalidate(lastThirtyDaysGlucoseReadingsProvider);
          messenger.showSnackBar(
            const SnackBar(content: Text(HistoryStrings.deleteFailure)),
          );
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: const Text(HistoryStrings.delete),
            action: SnackBarAction(
              label: HistoryStrings.undo,
              onPressed: () async {
                try {
                  await repository.saveReading(reading);
                } on Exception {
                  ref.invalidate(lastThirtyDaysGlucoseReadingsProvider);
                  messenger.showSnackBar(
                    const SnackBar(content: Text(HistoryStrings.undoFailure)),
                  );
                }
              },
            ),
          ),
        );
      },
      child: Card(
        margin: margin,
        child: ListTile(
          title: Text(
            '${reading.valueMgDl} ${HistoryStrings.mgDl}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Text(
            '${_formatDateTime(reading.timestamp)} · ${reading.context.label}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: _StatusBadge(status: status),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final GlucoseStatus? status;

  @override
  Widget build(BuildContext context) {
    final value = status;
    final color = value?.color ?? Theme.of(context).colorScheme.error;
    final foregroundColor =
        value?.colorFor(Theme.of(context).brightness) ?? color;
    final label = value?.label ?? HistoryStrings.loadError;
    final icon = value?.icon ?? AppIcons.warning;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 18, color: foregroundColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

GlucoseStatus? _statusFor(int valueMgDl) {
  return switch (const ClassifyReading()(valueMgDl)) {
    GlucoseSuccess<GlucoseStatus>(:final value) => value,
    GlucoseFailure<GlucoseStatus>() => null,
  };
}

FlDotPainter _statusDotPainter(GlucoseStatus? status) {
  final value = status;
  if (value == null) {
    return FlDotCrossPainter(color: AppColors.red, size: 12, width: 3);
  }

  return switch (value) {
    GlucoseStatus.rendah =>
      FlDotCrossPainter(color: value.color, size: 12, width: 3),
    GlucoseStatus.normal =>
      FlDotCirclePainter(color: value.color, radius: 5, strokeWidth: 0),
    GlucoseStatus.waspada =>
      FlDotSquarePainter(color: value.color, size: 10, strokeWidth: 0),
    GlucoseStatus.tinggi => _TriangleDotPainter(value.color),
  };
}

class _TriangleDotPainter extends FlDotPainter {
  const _TriangleDotPainter(this.color);

  final Color color;

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    const radius = 7.0;
    final path = Path()
      ..moveTo(offsetInCanvas.dx, offsetInCanvas.dy - radius)
      ..lineTo(offsetInCanvas.dx - radius, offsetInCanvas.dy + radius)
      ..lineTo(offsetInCanvas.dx + radius, offsetInCanvas.dy + radius)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  Size getSize(FlSpot spot) => const Size.square(14);

  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is! _TriangleDotPainter || b is! _TriangleDotPainter) {
      return b;
    }
    return _TriangleDotPainter(Color.lerp(a.color, b.color, t)!);
  }

  @override
  List<Object?> get props => [color];
}

String _formatDateTime(DateTime timestamp) {
  final day = timestamp.day.toString().padLeft(2, '0');
  final month = timestamp.month.toString().padLeft(2, '0');
  final hour = timestamp.hour.toString().padLeft(2, '0');
  final minute = timestamp.minute.toString().padLeft(2, '0');
  return '$day.$month $hour.$minute';
}
