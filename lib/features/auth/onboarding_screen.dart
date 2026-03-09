import 'package:flutter/material.dart';

/// Placeholder for the onboarding flow.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Reflect')),
      body: const Center(
        child: Text('Onboarding — Phase 3'),
      ),
    );
  }
}
