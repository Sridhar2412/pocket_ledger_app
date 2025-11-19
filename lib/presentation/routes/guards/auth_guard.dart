import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/presentation/providers/auth_provider.dart';
import 'package:pocket_ledger_app/presentation/routes/app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isLoggedIn = _ref.read(authProvider);

    if (isLoggedIn == AuthStatus.authenticated) {
      resolver.next(true);
      return;
    }

    // If auth status is still loading, listen for changes and resolve when known
    if (isLoggedIn == AuthStatus.loading) {
      late final ProviderSubscription sub;
      sub = _ref.listen<AuthStatus>(authProvider, (prev, next) {
        if (next == AuthStatus.authenticated) {
          resolver.next(true);
          sub.close();
        } else if (next == AuthStatus.initial || next == AuthStatus.error) {
          resolver.next(false);
          router.push(const LoginRoute());
          sub.close();
        }
      });
      return;
    }

    // not authenticated
    resolver.next(false);
    router.push(const LoginRoute());
  }
}
