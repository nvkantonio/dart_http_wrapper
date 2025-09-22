import 'package:http/http.dart';

// Api response exeption
abstract interface class ResponseExeption implements Exception {
  String get message;
  dynamic get source;
  Object? get causedError;
  BaseResponse? get response;

  @override
  String toString() {
    return message;
  }
}

/// Use on valid api response exeptions
class HandeledResponseExeption implements ResponseExeption {
  const HandeledResponseExeption({
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

/// Use on invalid api response exeptions
class InvalidResponseExeption implements ResponseExeption {
  const InvalidResponseExeption({
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

/// Use on parse exeptions
class ResponseParseExeption extends InvalidResponseExeption {
  const ResponseParseExeption({
    super.message,
    super.source,
    super.response,
    super.causedError,
  });
}

/// Use on failed validation api response
class ResponseValidationExeption extends HandeledResponseExeption {
  const ResponseValidationExeption({
    super.message = '',
    super.source,
    super.causedError,
    super.response,
  });
}
