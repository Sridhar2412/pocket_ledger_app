import 'package:uuid/uuid.dart';

// Simple wrapper for generating a unique ID
abstract class AppUtils {
  static const Uuid _uuid = Uuid();
  static String generateUuid() => _uuid.v4();
}
