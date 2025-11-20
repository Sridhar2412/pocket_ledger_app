import 'package:dartz/dartz.dart';
import 'package:pocket_ledger_app/core/exceptions/app_exception.dart';
import 'package:pocket_ledger_app/domain/repositories/auth_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _authTokenKey = 'authToken';
  static const String _userKeyPrefix = 'user::';
  static const String _userIdKey = 'userId';

  @override
  Future<Either<AppException, String>> login(
      String email, String password) async {
    try {
      final key = '$_userKeyPrefix${email.toLowerCase().trim()}';
      final stored = _prefs.getString(key);
      if (stored != null) {
        if (stored == password) {
          await _prefs.setString(_authTokenKey, 'mockToken');
          await _prefs.setString(_userIdKey, email.toLowerCase().trim());
          return Right(email.toLowerCase().trim());
        } else {
          return Left(AppException(
              type: ErrorType.other, message: 'Invalid credentials'));
        }
      }

      // fallback test user
      if (email == 'admin@yopmail.com' && password == 'admin') {
        await _prefs.setString(_authTokenKey, 'mockToken');
        await _prefs.setString(_userIdKey, email.toLowerCase().trim());
        return Right(email.toLowerCase().trim());
      }

      return Left(
          AppException(type: ErrorType.other, message: 'Invalid credentials'));
    } catch (e, st) {
      return Left(AppException(
          type: ErrorType.other, message: e.toString(), trace: st));
    }
  }

  @override
  Future<Either<AppException, String>> signup(
      String email, String password) async {
    try {
      final key = '$_userKeyPrefix${email.toLowerCase().trim()}';
      await _prefs.setString(key, password);
      await _prefs.setString(_authTokenKey, 'mockToken');
      await _prefs.setString(_userIdKey, email.toLowerCase().trim());
      return Right(email.toLowerCase().trim());
    } catch (e, st) {
      return Left(AppException(
          type: ErrorType.other, message: e.toString(), trace: st));
    }
  }

  @override
  Future<Either<AppException, bool>> getAuthStatus() async {
    try {
      final token = _prefs.getString(_authTokenKey);
      return Right(token != null && token.isNotEmpty);
    } catch (e, st) {
      return Left(AppException(
          type: ErrorType.other, message: e.toString(), trace: st));
    }
  }

  @override
  Future<Either<AppException, Unit>> logout() async {
    try {
      await _prefs.remove(_authTokenKey);
      await _prefs.remove(_userIdKey);
      return const Right(unit);
    } catch (e, st) {
      return Left(AppException(
          type: ErrorType.other, message: e.toString(), trace: st));
    }
  }
}
