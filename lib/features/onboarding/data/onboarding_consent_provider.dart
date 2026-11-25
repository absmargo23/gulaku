import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const onboardingConsentKey = 'onboarding_consent_v1';

final onboardingConsentProvider = FutureProvider<bool>((ref) async {
  final preferences = await SharedPreferences.getInstance();
  return preferences.getBool(onboardingConsentKey) ?? false;
});

Future<void> saveOnboardingConsent() async {
  final preferences = await SharedPreferences.getInstance();
  final saved = await preferences.setBool(onboardingConsentKey, true);
  if (!saved) {
    throw StateError('Persetujuan tidak dapat disimpan.');
  }
}
