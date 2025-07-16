// user_service.dart
class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  String? _username;

  void setUsername(String username) {
    _username = username;
  }

  String? getUsername() {
    return _username;
  }

  void clearUsername() {
    _username = null;
  }
}
