import 'package:flutter_test/flutter_test.dart';
import 'package:baloga_ar_rescue/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BalogaApp()));
  });
}
