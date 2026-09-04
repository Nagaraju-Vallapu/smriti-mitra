import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smriti_mitra/main.dart';
import 'package:smriti_mitra/navigation/app_state.dart';

void main() {
  testWidgets('Smriti Mitra app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const SmritiMitraApp(),
      ),
    );

    // Allow the app to initialize.
    await tester.pump();

    expect(find.byType(SmritiMitraApp), findsOneWidget);
  });
}
