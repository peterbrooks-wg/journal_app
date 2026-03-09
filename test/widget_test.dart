import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reflect/main.dart';

void main() {
  testWidgets('ReflectApp renders without crashing',
      (WidgetTester tester) async {
    // Provide empty SharedPreferences so AuthNotifier can read state.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: ReflectApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reflect'), findsOneWidget);
  });
}
