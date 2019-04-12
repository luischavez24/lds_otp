class SamePinException implements Exception {
  final message;
  SamePinException(this.message);
}

class AuthFailException implements Exception {
  final message;
  AuthFailException(this.message);
}