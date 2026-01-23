import 'package:encrypt/encrypt.dart';

class SessionKeyManager {
  static Key? _sessionKey;

  static void setKey(Key key) {
    _sessionKey = key;
  }

  static Key getKey() {
    if (_sessionKey == null) {
      throw Exception('Session key not initialized');
    }
    return _sessionKey!;
  }

  static bool hasKey() {
    return _sessionKey != null;
  }

  static void clear() {
    _sessionKey = null;
  }
}
