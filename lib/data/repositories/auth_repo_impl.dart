import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger_app/core/exceptions/app_exception.dart';
import 'package:pocket_ledger_app/domain/repositories/auth_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'auth_repo_impl.g.dart';

@riverpod
AuthRepository authRepo(Ref ref) => AuthRepositoryImpl();

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  @override
  Future<Either<AppException, bool>> getAuthStatus() {
    // TODO: implement getAuthStatus
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, String>> login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, String>> signup(String email, String password) {
    // TODO: implement signup
    throw UnimplementedError();
  }
}
