import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_icon.dart';
import '../data/providers/glucose_providers.dart';
import '../domain/entities/glucose_context.dart';
import '../domain/entities/glucose_reading.dart';
import '../domain/entities/glucose_result.dart';
import '../domain/entities/glucose_status.dart';
import '../domain/use_cases/classify_reading.dart';
import 'glucose_entry_strings.dart';

class GlucoseEntryPage extends ConsumerStatefulWidget {
  const GlucoseEntryPage({super.key});

  @override
  ConsumerState<GlucoseEntryPage> createState() => _GlucoseEntryPageState();
}

class _GlucoseEntryPageState extends ConsumerState<GlucoseEntryPage> {
  static const _backspaceKey = '⌫';
  static const _keypadKeys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '',
    '0',
    _backspaceKey,
  ];

  String _valueInput = '';
  String? _errorMessage;
  String? _saveErrorMessage;
  GlucoseContext _context = GlucoseContext.puasa;
  bool _isSaving = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(GlucoseEntryStrings.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: AppBackground(
        variant: AppBackgroundVariant.normal,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ValueDisplay(value: _valueInput),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                _buildKeypad(),
                const SizedBox(height: 20),
                _buildContextSelector(),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: GlucoseEntryStrings.noteLabel,
                  ),
                ),
                if (_saveErrorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _saveErrorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSaving ? null : _saveReading,
                  child: _isSaving
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(GlucoseEntryStrings.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _keypadKeys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final keyValue = _keypadKeys[index];
        if (keyValue.isEmpty) {
          return const SizedBox.shrink();
        }

        final isBackspace = keyValue == _backspaceKey;
        return Semantics(
          label: isBackspace ? GlucoseEntryStrings.backspace : keyValue,
          button: true,
          child: FilledButton.tonal(
            onPressed: _isSaving ? null : () => _pressKey(keyValue),
            child: isBackspace
                ? const AppIcon(AppIcons.backspace, size: 24)
                : Text(
                    keyValue,
                    style: AppTextStyles.title.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildContextSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: GlucoseContext.values.map((glucoseContext) {
        return ChoiceChip(
          label: Text(_contextLabel(glucoseContext)),
          selected: _context == glucoseContext,
          onSelected: _isSaving
              ? null
              : (_) => setState(() => _context = glucoseContext),
        );
      }).toList(growable: false),
    );
  }

  void _pressKey(String key) {
    setState(() {
      _errorMessage = null;
      _saveErrorMessage = null;
      if (key == _backspaceKey) {
        if (_valueInput.isNotEmpty) {
          _valueInput = _valueInput.substring(0, _valueInput.length - 1);
        }
      } else if (_valueInput.length < 3) {
        _valueInput += key;
      }
    });
  }

  Future<void> _saveReading() async {
    final value = int.tryParse(_valueInput);
    if (value == null) {
      setState(() => _errorMessage = GlucoseEntryStrings.emptyValue);
      return;
    }

    final result = const ClassifyReading()(value);
    final GlucoseStatus status;
    switch (result) {
      case GlucoseFailure<GlucoseStatus>(
          error: GlucoseValidationError.invalidRange
        ):
        setState(() => _errorMessage = GlucoseEntryStrings.invalidRange);
        return;
      case GlucoseFailure<GlucoseStatus>():
        setState(() => _errorMessage = GlucoseEntryStrings.invalidValue);
        return;
      case GlucoseSuccess<GlucoseStatus>(:final value):
        status = value;
    }
    final reading = GlucoseReading(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      valueMgDl: value,
      timestamp: DateTime.now(),
      context: _context,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _saveErrorMessage = null;
    });

    try {
      await ref.read(glucoseRepositoryProvider).saveReading(reading);
    } on Exception {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveErrorMessage = GlucoseEntryStrings.saveError;
        });
      }
      return;
    }

    if (!mounted) {
      return;
    }
    if (status == GlucoseStatus.rendah) {
      context.go('/glucose/hypo', extra: reading);
      return;
    }

    if (status == GlucoseStatus.tinggi) {
      ScaffoldMessenger.of(context)
        ..hideCurrentMaterialBanner()
        ..showMaterialBanner(
          MaterialBanner(
            content: const Text(GlucoseEntryStrings.highReadingBanner),
            leading: const AppIcon(AppIcons.warning),
            actions: [
              TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: const Text(GlucoseEntryStrings.saved),
              ),
            ],
          ),
        );
    }
    context.pop();
  }

  String _contextLabel(GlucoseContext context) {
    return switch (context) {
      GlucoseContext.puasa => GlucoseEntryStrings.puasa,
      GlucoseContext.sebelumMakan => GlucoseEntryStrings.beforeMeal,
      GlucoseContext.sesudahMakan => GlucoseEntryStrings.afterMeal,
      GlucoseContext.sebelumTidur => GlucoseEntryStrings.beforeSleep,
    };
  }
}

class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 12,
        children: [
          Text(
            value.isEmpty ? '___' : value,
            key: const ValueKey('glucose-entry-value'),
            style: AppTextStyles.glucoseValue.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            GlucoseEntryStrings.unit,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
