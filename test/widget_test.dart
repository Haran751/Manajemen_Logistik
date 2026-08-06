import 'package:flutter_test/flutter_test.dart';
import 'package:rans/main.dart';

void main() {
  testWidgets('WMS App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WmsApp());
    expect(find.text('Gudang Utama Jakarta'), findsOneWidget);
  });
}
