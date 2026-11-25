import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_icon.dart';
import '../../glucose/data/providers/glucose_providers.dart';
import '../../glucose/domain/entities/glucose_reading.dart';
import '../data/report_providers.dart';
import 'report_strings.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _typeController = TextEditingController();
  bool _isExporting = false;
  String? _exportError;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readings = ref.watch(lastThirtyDaysGlucoseReadingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ReportStrings.screenTitle),
        leading: IconButton(
          tooltip: ReportStrings.back,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const AppIcon(AppIcons.report),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ReportStrings.patientDetails,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: ReportStrings.patientName,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: ReportStrings.age,
                      hintText: ReportStrings.ageHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _typeController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: ReportStrings.diabetesType,
                      hintText: ReportStrings.diabetesTypeHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          readings.when(
            data: (values) => _ReportDataState(
              readings: values,
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(ReportStrings.loading),
                  ],
                ),
              ),
            ),
            error: (error, stackTrace) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      ReportStrings.loadError,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(lastThirtyDaysGlucoseReadingsProvider),
                      child: const Text(ReportStrings.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_exportError != null) ...[
            const SizedBox(height: 8),
            Text(
              _exportError!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          readings.when(
            data: (values) => _ExportActions(
              enabled: values.isNotEmpty && !_isExporting,
              isExporting: _isExporting,
              onPreview: () => _export(values, share: false),
              onShare: () => _confirmAndShare(values),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _export(
    List<GlucoseReading> readings, {
    required bool share,
  }) async {
    setState(() {
      _isExporting = true;
      _exportError = null;
    });
    try {
      final bytes = await ref.read(glucoseReportPdfBuilderProvider).build(
            patientName: _nameController.text,
            age: _ageController.text,
            diabetesType: _typeController.text,
            readings: readings,
            generatedAt: DateTime.now(),
          );
      final printer = ref.read(reportPrinterProvider);
      if (share) {
        await printer.share(bytes);
      } else {
        await printer.preview(bytes);
      }
    } on PlatformException {
      if (mounted) {
        setState(() => _exportError = ReportStrings.exportError);
      }
    } on Exception {
      if (mounted) {
        setState(() => _exportError = ReportStrings.exportError);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _confirmAndShare(List<GlucoseReading> readings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ReportStrings.sharingTitle),
        content: const Text(ReportStrings.sharingExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(ReportStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(ReportStrings.continueSharing),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _export(readings, share: true);
    }
  }
}

class _ReportDataState extends StatelessWidget {
  const _ReportDataState({required this.readings});

  final List<GlucoseReading> readings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: readings.isEmpty
            ? Text(
                ReportStrings.noData,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              )
            : Text(
                '${readings.length} catatan tersedia untuk laporan.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
      ),
    );
  }
}

class _ExportActions extends StatelessWidget {
  const _ExportActions({
    required this.enabled,
    required this.isExporting,
    required this.onPreview,
    required this.onShare,
  });

  final bool enabled;
  final bool isExporting;
  final VoidCallback onPreview;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: enabled ? onPreview : null,
          icon: isExporting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print_outlined),
          label: const Text(ReportStrings.preview),
        ),
        OutlinedButton.icon(
          onPressed: enabled ? onShare : null,
          icon: const Icon(Icons.share_outlined),
          label: const Text(ReportStrings.share),
        ),
      ],
    );
  }
}
