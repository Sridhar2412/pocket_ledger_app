import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/core/di/di_provider.dart';
import 'package:pocket_ledger_app/core/theme/app_color.dart';
import 'package:pocket_ledger_app/presentation/providers/auth_provider.dart';
import 'package:pocket_ledger_app/presentation/routes/app_router.gr.dart';

class ResponsiveScaffold extends ConsumerWidget {
  final Widget body;
  final Widget? drawer;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.drawer,
    this.appBar,
    this.floatingActionButton,
    this.currentIndex = 0,
    this.onIndexChanged,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 800; // breakpoint for web/tablet

    final logoutAction = IconButton(
      tooltip: 'Logout',
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.router.replace(const LoginRoute());
        }
      },
    );

    final prefsAsync = ref.watch(sharedPreferencesProvider);
    final userId = prefsAsync.value?.getString('userId');

    PreferredSizeWidget finalAppBar;
    Widget titleWidget;
    if (userId != null && userId.isNotEmpty) {
      titleWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pocket Ledger'),
          Text(userId,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColor.white)),
        ],
      );
    } else {
      titleWidget = const Text('Pocket Ledger');
    }

    if (appBar is AppBar) {
      final a = appBar as AppBar;
      finalAppBar = AppBar(
        title: a.title ?? titleWidget,
        centerTitle: a.centerTitle,
        automaticallyImplyLeading: false,
        actions: [...?a.actions, logoutAction],
      );
    } else if (appBar != null) {
      finalAppBar = appBar!;
    } else {
      finalAppBar = AppBar(
        title: titleWidget,
        automaticallyImplyLeading: false,
        actions: [logoutAction],
      );
    }

    if (isWide) {
      return Scaffold(
        appBar: finalAppBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onIndexChanged,
              labelType: NavigationRailLabelType.all,
              leading: Semantics(
                button: true,
                label: 'Open navigation',
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    try {
                      Scaffold.of(context).openDrawer();
                    } catch (_) {}
                  },
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet),
                  label: Text('Wallets'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.swap_horiz_outlined),
                  selectedIcon: Icon(Icons.swap_horiz),
                  label: Text('Transactions'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
        drawer: drawer,
        floatingActionButton: floatingActionButton,
      );
    }

    // Mobile / narrow layout
    return Scaffold(
      appBar: finalAppBar,
      body: body,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onIndexChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Wallets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz), label: 'Transactions'),
        ],
      ),
    );
  }
}
