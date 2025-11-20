import 'package:dartz/dartz.dart';
import 'package:pocket_ledger_app/core/exceptions/app_exception.dart';

// An repository for authentication operations
abstract class AuthRepository {
  Future<Either<AppException, String>> login(String email, String password);
  Future<Either<AppException, String>> signup(String email, String password);
  Future<Either<AppException, bool>> getAuthStatus();
  Future<Either<AppException, Unit>> logout();
}
