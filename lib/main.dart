import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'shared/providers/demo_data_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initSupabase(); // Disabled for demo — no credentials needed
  runApp(const ProviderScope(child: ReflectApp()));
}

/// Root widget for the Reflect journaling app.
class ReflectApp extends ConsumerWidget {
  const ReflectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seed demo data on first build.
    ref.read(demoDataProvider);

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Reflect',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
