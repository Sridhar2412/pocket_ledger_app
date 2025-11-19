import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/presentation/routes/app_router.dart';

final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter(ref);
});
