/// Exception thrown when database operations fail
class DatabaseException implements Exception {
  final String message;
  final String? details;

  DatabaseException(this.message, [this.details]);

  @override
  String toString() =>
      'DatabaseException: $message${details != null ? ' ($details)' : ''}';
}
