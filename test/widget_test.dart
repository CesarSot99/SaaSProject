import 'package:flutter_test/flutter_test.dart';
import 'package:saas_project/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BarberSyncApp());
    expect(find.text('Welcome to BarberSync'), findsOneWidget);
  });
}
