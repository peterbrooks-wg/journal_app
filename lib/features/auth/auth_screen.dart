import 'package:flutter/material.dart';

/// Placeholder for the authentication screen.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: const Center(
        child: Text('Auth Screen — Phase 3'),
      ),
    );
  }
}
