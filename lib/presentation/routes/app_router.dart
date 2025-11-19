import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.gr.dart';
import 'guards/auth_guard.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends $AppRouter {
  AppRouter(this._ref, {super.navigatorKey});

  final Ref _ref;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true),
        AutoRoute(page: SignupRoute.page),
        AutoRoute(page: DashboardRoute.page, guards: [AuthGuard(_ref)]),
        AutoRoute(page: WalletRoute.page, guards: [AuthGuard(_ref)]),
        AutoRoute(page: TransactionRoute.page, guards: [AuthGuard(_ref)]),
      ];
}
