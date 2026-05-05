sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error occurred']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Storage error occurred']);
}

class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Database error occurred']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation error occurred']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission denied']);
}
