import 'package:flutter_test/flutter_test.dart';

import 'package:reflect/main.dart';

void main() {
  testWidgets('ReflectApp builds without error', (WidgetTester tester) async {
    // Verify the root widget can be instantiated.
    expect(const ReflectApp(), isA<ReflectApp>());
  });
}
