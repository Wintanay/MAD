import '../models/user.dart';

class AuthService {
  User? _currentUser;

  // Get current logged in user
  User? getCurrentUser() {
    return _currentUser;
  }

  // Simple login (Firebase will replace this later)
  bool login(String email, String password) {
    // Placeholder until Firebase is set up
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: '1',
        fullName: 'Test User',
        email: email,
        phoneNumber: '',
      );
      return true;
    }
    return false;
  }

  // Logout
  void logout() {
    _currentUser = null;
  }
}