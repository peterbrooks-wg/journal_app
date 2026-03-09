import 'package:flutter/material.dart';

/// Home screen — the main landing page after auth.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reflect')),
      body: const Center(
        child: Text('Home Screen — Phase 4'),
      ),
    );
  }
}
