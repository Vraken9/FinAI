class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  String get userFriendlyMessage => message;
  bool get isRetryable => false;

  @override
  String toString() => 'AppException: $message';
}

class ApiException extends AppException {
  final int? statusCode;

  ApiException(super.message, {this.statusCode, super.code});

  @override
  String get userFriendlyMessage {
    switch (code) {
      case 'UNAUTHORIZED':
        return 'Sesi habis, silakan login kembali';
      case 'VALIDATION_ERROR':
        return 'Data yang dikirim tidak valid';
      case 'RATE_LIMITED':
        return 'Terlalu banyak request, coba lagi nanti';
      default:
        return message.isNotEmpty 
          ? message 
          : 'Terjadi kesalahan tidak terduga';
    }
  }

  @override
  bool get isRetryable {
    return code == 'RATE_LIMITED' || code == 'EXTERNAL_API_ERROR' || statusCode == 503;
  }
}

class NetworkException extends AppException {
  NetworkException(super.message);
}
