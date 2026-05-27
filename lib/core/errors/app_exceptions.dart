// lib/core/errors/app_exceptions.dart

/// Base exception for all app-level errors.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message (code: $statusCode)';
}

/// Thrown when a network request fails due to connectivity issues or timeout.
class NetworkException extends AppException {
  const NetworkException(super.message) : super(statusCode: null);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown on 4xx/5xx HTTP responses that aren't specifically handled.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when the backend returns 403 (message limit exhausted).
class PaywallException extends AppException {
  const PaywallException()
      : super('Daily message limit reached.', statusCode: 403);
}

/// Thrown when the device has already registered a premium account (400).
class AlreadyRegisteredException extends AppException {
  const AlreadyRegisteredException()
      : super('This device already has an account.', statusCode: 400);
}

/// Thrown when no verified payment exists for this device (402).
class NoPaymentException extends AppException {
  const NoPaymentException()
      : super('No verified payment found.', statusCode: 402);
}

/// Thrown when secure storage read/write fails.
class StorageException extends AppException {
  const StorageException(super.message);

  @override
  String toString() => 'StorageException: $message';
}

/// Thrown on wrong alias or PIN (401).
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
      : super('Incorrect alias or PIN. Please try again.', statusCode: 401);
}

/// Thrown when alias not found on login (404).
class UserNotFoundException extends AppException {
  const UserNotFoundException()
      : super('No account found with this alias.', statusCode: 404);
}

/// Thrown when auth token is expired or invalid (401 on profile/logout).
class SessionExpiredException extends AppException {
  const SessionExpiredException()
      : super('Your session has expired. Please log in again.', statusCode: 401);
}

/// Thrown on invalid credentials (401) — generic.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}
