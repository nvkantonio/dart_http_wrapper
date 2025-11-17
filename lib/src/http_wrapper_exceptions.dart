import 'package:http/http.dart';

// Api response exception
abstract interface class ResponseException implements Exception {
  String get message;
  dynamic get source;
  Object? get causedError;
  BaseResponse? get response;

  @override
  String toString() {
    return message;
  }
}

/// Use on valid api response exception
class HandledResponseException implements ResponseException {
  const HandledResponseException({
    this.message = '',
    this.source,
    this.causedError,
    this.response,
  });

  @override
  final String message;
  @override
  final dynamic source;
  @override
  final Object? causedError;
  @override
  final Response? response;
}

/// Use on invalid api response exceptions
class InvalidResponseException implements ResponseException {
  const InvalidResponseException({
    this.message = '',
    this.source,
    this.causedError,
    this.response,
  });

  @override
  final String message;
  @override
  final dynamic source;
  @override
  final Object? causedError;
  @override
  final Response? response;
}

/// Use on parse exceptions
class ResponseParseException extends InvalidResponseException {
  const ResponseParseException({
    super.message,
    super.source,
    super.response,
    super.causedError,
  });
}

/// Use on failed validation api response
class ResponseValidationException extends HandledResponseException {
  const ResponseValidationException({
    super.message = '',
    super.source,
    super.causedError,
    super.response,
  });
}
