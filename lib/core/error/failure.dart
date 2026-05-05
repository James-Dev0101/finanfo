sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
