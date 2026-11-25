import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/app_strings.dart';
import '../../../core/widgets/app_background.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../data/onboarding_consent_provider.dart';
import 'onboarding_strings.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _consentGiven = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      (OnboardingStrings.firstTitle, OnboardingStrings.firstDescription),
      (OnboardingStrings.secondTitle, OnboardingStrings.secondDescription),
      (OnboardingStrings.thirdTitle, OnboardingStrings.thirdDescription),
    ];

    return Scaffold(
      body: AppBackground(
        variant: AppBackgroundVariant.onboarding,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (page) => setState(() {
                    _currentPage = page;
                    _errorMessage = null;
                  }),
                  itemBuilder: (context, index) => _OnboardingSlide(
                    title: slides[index].$1,
                    description: slides[index].$2,
                    showPrivacyDetails: index == 2,
                  ),
                ),
              ),
              Semantics(
                label: 'Halaman ${_currentPage + 1} dari 3',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: index == _currentPage ? 24 : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index == _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              if (_currentPage == 2)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: CheckboxListTile(
                    value: _consentGiven,
                    onChanged: _isSaving
                        ? null
                        : (value) => setState(
                              () => _consentGiven = value ?? false,
                            ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(OnboardingStrings.consent),
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _isSaving ? null : _goBack,
                        child: const Text(OnboardingStrings.previous),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _isSaving ? null : _continue,
                      child: _isSaving
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentPage == slides.length - 1
                                  ? OnboardingStrings.agreeAndContinue
                                  : OnboardingStrings.continueLabel,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _continue() async {
    if (_currentPage < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }
    if (!_consentGiven) {
      setState(() => _errorMessage = OnboardingStrings.consentRequired);
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await saveOnboardingConsent();
      ref.invalidate(onboardingConsentProvider);
    } on Exception {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = OnboardingStrings.saveError;
        });
      }
    }
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.showPrivacyDetails,
  });

  final String title;
  final String description;
  final bool showPrivacyDetails;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.45,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bloodtype_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
              semanticLabel: AppStrings.appName,
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (showPrivacyDetails) ...[
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        OnboardingStrings.privacyTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        OnboardingStrings.privacyDetails,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        OnboardingStrings.disclaimer,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OnboardingConsentGate extends ConsumerWidget {
  const OnboardingConsentGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(onboardingConsentProvider).when(
          data: (consented) =>
              consented ? const DashboardPage() : const OnboardingPage(),
          loading: () => const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(OnboardingStrings.loading),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(OnboardingStrings.loadError),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(onboardingConsentProvider),
                    child: const Text(OnboardingStrings.retry),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
