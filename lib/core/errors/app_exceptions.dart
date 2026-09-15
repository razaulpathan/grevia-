/// Central Exception Classes for Grevia
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, [super.code]);

  factory AuthException.fromFirebaseCode(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return const AuthException(
            'Invalid phone number format.', 'invalid-phone-number');
      case 'invalid-verification-code':
        return const AuthException(
            'Invalid OTP entered. Please check and try again.',
            'invalid-verification-code');
      case 'session-expired':
        return const AuthException(
            'Verification code has expired. Request a new one.',
            'session-expired');
      case 'quota-exceeded':
        return const AuthException(
            'SMS quota exceeded. Please try again later.', 'quota-exceeded');
      default:
        return AuthException('Authentication error: $code', code);
    }
  }
}

class UsernameTakenException extends AppException {
  const UsernameTakenException([String username = ''])
      : super('Username @$username is already taken. Please choose another.',
            'username-taken');
}

class NetworkException extends AppException {
  const NetworkException(
      [String message =
          'Unable to connect to the network. Please check your connection.'])
      : super(message, 'network-error');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(String permissionName)
      : super(
            'Permission for $permissionName was denied. Enable it in Settings.',
            'permission-denied');
}

class CallException extends AppException {
  const CallException(super.message, [super.code]);
}

class StorageUploadException extends AppException {
  const StorageUploadException(
      [String message = 'Failed to upload media file.'])
      : super(message, 'upload-failed');
}
