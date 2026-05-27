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
/// Triggers the premium paywall navigation.
class PaywallException extends AppException {
  const PaywallException()
      : super('Daily message limit reached.', statusCode: 403);

  @override
  String toString() => 'PaywallException: Daily message limit reached.';
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

/// Thrown on invalid credentials (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}
