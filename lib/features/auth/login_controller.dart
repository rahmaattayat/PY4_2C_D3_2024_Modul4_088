enum LoginResult { success, failed, blocked }

class LoginController {
  final Map<String, String> _users = {
    'admin': '123',
    'amaw': '456',
    'rahma': '789',
  };

  int _failedAttempts = 0;

  int get failedAttempts => _failedAttempts;

  void resetBlock() {
    _failedAttempts = 0;
  }

  LoginResult login(String username, String password) {
    if (username.trim().isEmpty || password.isEmpty) {
      return LoginResult.failed;
    }

    if (_users.containsKey(username) && _users[username] == password) {
      _failedAttempts = 0;
      return LoginResult.success;
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        return LoginResult.blocked;
      }
      return LoginResult.failed;
    }
  }
}