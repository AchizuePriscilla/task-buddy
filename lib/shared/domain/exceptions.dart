class AppException implements Exception {
  final String message;
  final String? statusCode;
  final String? identifier;

  AppException({required this.message, this.statusCode, this.identifier});

  @override
  String toString() {
    return 'statusCode=$statusCode\nmessage=$message\nidentifier=$identifier';
  }
}

class DatabaseException implements AppException {
  final String _message;
  DatabaseException(this._message);
  @override
  String get message => _message;

  @override
  String? get statusCode => '500';

  @override
  String? get identifier => 'database_exception';

}


