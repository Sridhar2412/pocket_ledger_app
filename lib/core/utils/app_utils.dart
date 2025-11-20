import 'package:uuid/uuid.dart';

abstract class AppUtils {
  static const Uuid _uuid = Uuid();
  // Simple method for generating a unique ID
  static String generateUuid() => _uuid.v4();
}
