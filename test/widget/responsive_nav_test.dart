import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/presentation/components/responsive_scaffold.dart';

void main() {
  testWidgets('ResponsiveScaffold bottom nav calls onIndexChanged',
      (tester) async {
    int? tapped;
    // Force a narrow screen so the BottomNavigationBar is displayed
    tester.binding.window.physicalSizeTestValue = const Size(400, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: ResponsiveScaffold(
          appBar: AppBar(title: const Text('Test')),
          body: const SizedBox.shrink(),
          currentIndex: 0,
          onIndexChanged: (i) => tapped = i,
        ),
      ),
    ));

    // ensure bottom navigation exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // tap the Wallets item (index 1)
    await tester.tap(find.text('Wallets'));
    await tester.pumpAndSettle();

    expect(tapped, 1);

    // tap the Transactions item (index 2)
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(tapped, 2);
  });
}
