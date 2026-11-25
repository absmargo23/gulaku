import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_icon.dart';
import '../data/food_log_providers.dart';
import '../data/food_photo_storage.dart';
import '../domain/entities/food_log.dart';
import '../domain/entities/food_suggestion.dart';
import '../domain/use_cases/daily_carbohydrate_total.dart';
import 'food_strings.dart';

class FoodDiaryPage extends ConsumerWidget {
  const FoodDiaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(todayFoodLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(FoodStrings.title)),
      body: AppBackground(
        variant: AppBackgroundVariant.normal,
        child: SafeArea(
          top: false,
          child: logs.when(
            data: (values) => _FoodDiaryContent(
              logs: values,
              onAdd: (meal) => _openEditor(context, ref, meal),
              onDelete: (log) => _deleteLog(context, ref, log),
            ),
            loading: () => const _DiaryMessage(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(FoodStrings.loading),
                ],
              ),
            ),
            error: (error, stackTrace) => _DiaryMessage(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FoodStrings.loadError,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(todayFoodLogsProvider),
                    child: const Text(FoodStrings.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    FoodMeal meal,
  ) async {
    final log = await showDialog<FoodLog>(
      context: context,
      builder: (context) => _FoodLogEditorDialog(initialMeal: meal),
    );
    if (log != null) {
      await ref.read(foodLogRepositoryProvider).saveLog(log);
    }
  }

  Future<void> _deleteLog(
    BuildContext context,
    WidgetRef ref,
    FoodLog log,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(FoodStrings.delete),
        content: const Text(FoodStrings.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(FoodStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(FoodStrings.deleteButton),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      try {
        await ref.read(foodLogRepositoryProvider).deleteLog(log.id);
        await const FoodPhotoStorage().delete(log.photoPath);
      } on FileSystemException {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(FoodStrings.photoError)),
          );
        }
      }
    }
  }
}

class _FoodDiaryContent extends StatelessWidget {
  const _FoodDiaryContent({
    required this.logs,
    required this.onAdd,
    required this.onDelete,
  });

  final List<FoodLog> logs;
  final ValueChanged<FoodMeal> onAdd;
  final ValueChanged<FoodLog> onDelete;

  @override
  Widget build(BuildContext context) {
    final total = const DailyCarbohydrateTotal()(logs);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const AppIcon(AppIcons.plate, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FoodStrings.dailyTotal,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '$total g',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (logs.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
            child: Text(
              FoodStrings.emptyDay,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        for (final meal in FoodMeal.values)
          _MealSection(
            meal: meal,
            logs: logs.where((log) => log.meal == meal).toList(),
            onAdd: () => onAdd(meal),
            onDelete: onDelete,
          ),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.meal,
    required this.logs,
    required this.onAdd,
    required this.onDelete,
  });

  final FoodMeal meal;
  final List<FoodLog> logs;
  final VoidCallback onAdd;
  final ValueChanged<FoodLog> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meal.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text(FoodStrings.addFood),
                ),
              ],
            ),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  FoodStrings.emptyMeal,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final log in logs)
                _FoodLogTile(log: log, onDelete: () => onDelete(log)),
          ],
        ),
      ),
    );
  }
}

class _FoodLogTile extends StatelessWidget {
  const _FoodLogTile({required this.log, required this.onDelete});

  final FoodLog log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(log.timestamp).format(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: log.photoPath == null
          ? const AppIcon(AppIcons.plate)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _EncryptedFoodPhoto(
                path: log.photoPath!,
                semanticLabel: log.name,
              ),
            ),
      title: Text(log.name),
      subtitle: Text(
        '$time · ${log.estimatedCarbsGrams} ${FoodStrings.grams}',
      ),
      trailing: IconButton(
        tooltip: FoodStrings.delete,
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}

class _EncryptedFoodPhoto extends StatefulWidget {
  const _EncryptedFoodPhoto({
    required this.path,
    required this.semanticLabel,
  });

  final String path;
  final String semanticLabel;

  @override
  State<_EncryptedFoodPhoto> createState() => _EncryptedFoodPhotoState();
}

class _EncryptedFoodPhotoState extends State<_EncryptedFoodPhoto> {
  late Future<Uint8List> _image;

  @override
  void initState() {
    super.initState();
    _image = const FoodPhotoStorage().read(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _image,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _placeholder();
        }
        final bytes = snapshot.data;
        if (bytes == null) {
          return const SizedBox.square(
            dimension: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return Image.memory(
          bytes,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          semanticLabel: widget.semanticLabel,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      },
    );
  }

  Widget _placeholder() {
    return Semantics(
      label: FoodStrings.photoError,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 48,
          child: Center(child: const AppIcon(AppIcons.plate)),
        ),
      ),
    );
  }
}

class _FoodLogEditorDialog extends StatefulWidget {
  const _FoodLogEditorDialog({required this.initialMeal});

  final FoodMeal initialMeal;

  @override
  State<_FoodLogEditorDialog> createState() => _FoodLogEditorDialogState();
}

class _FoodLogEditorDialogState extends State<_FoodLogEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _carbsController = TextEditingController();
  final _photoStorage = const FoodPhotoStorage();
  late FoodMeal _meal = widget.initialMeal;
  XFile? _pickedPhoto;
  bool _isSaving = false;
  String? _photoError;

  @override
  void dispose() {
    _nameController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(FoodStrings.addFood),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<FoodMeal>(
                  initialValue: _meal,
                  decoration:
                      const InputDecoration(labelText: FoodStrings.meal),
                  items: FoodMeal.values
                      .map(
                        (meal) => DropdownMenuItem(
                          value: meal,
                          child: Text(meal.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (meal) {
                    if (meal != null) {
                      setState(() => _meal = meal);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: FoodStrings.foodName,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? FoodStrings.invalidName
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _carbsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: FoodStrings.carbohydrates,
                    suffixText: 'g',
                  ),
                  validator: (value) {
                    final grams = int.tryParse(value ?? '');
                    if (grams == null || grams < 0 || grams > 500) {
                      return FoodStrings.invalidCarbs;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _pickPhoto,
                  icon: const Icon(Icons.photo_outlined),
                  label: Text(
                    _pickedPhoto == null
                        ? FoodStrings.addPhoto
                        : _pickedPhoto!.name,
                  ),
                ),
                if (_photoError != null)
                  Text(
                    _photoError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  FoodStrings.suggestions,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final suggestion
                        in FoodSuggestion.commonIndonesianFoods)
                      ActionChip(
                        label: Text(suggestion.description),
                        onPressed: () => _selectSuggestion(suggestion),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text(FoodStrings.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(FoodStrings.save),
        ),
      ],
    );
  }

  void _selectSuggestion(FoodSuggestion suggestion) {
    _nameController.text = '${suggestion.name} (${suggestion.portion})';
    _carbsController.text = suggestion.estimatedCarbsGrams.toString();
    _formKey.currentState?.validate();
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (mounted && photo != null) {
        setState(() {
          _pickedPhoto = photo;
          _photoError = null;
        });
      }
    } on PlatformException {
      if (mounted) {
        setState(() => _photoError = FoodStrings.photoError);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final photoPath = _pickedPhoto == null
          ? null
          : await _photoStorage.save(
              _pickedPhoto!,
              now.microsecondsSinceEpoch.toString(),
            );
      final log = FoodLog(
        id: now.microsecondsSinceEpoch.toString(),
        timestamp: now,
        meal: _meal,
        name: _nameController.text.trim(),
        estimatedCarbsGrams: int.parse(_carbsController.text),
        photoPath: photoPath,
      );
      if (mounted) {
        Navigator.pop(context, log);
      }
    } on FileSystemException {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _photoError = FoodStrings.photoError;
        });
      }
    } on PlatformException {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _photoError = FoodStrings.photoError;
        });
      }
    } on StateError {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _photoError = FoodStrings.photoError;
        });
      }
    }
  }
}

class _DiaryMessage extends StatelessWidget {
  const _DiaryMessage({required this.child});

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
