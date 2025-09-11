import 'package:http/http.dart';

// Api response exeption
abstract class ResponseExeption implements Exception {
  const ResponseExeption([this.message = '', this.source, this.response]);

  final String message;
  final dynamic source;
  final StreamedResponse? response;

  @override
  String toString() {
    return message;
  }
}

/// Use on invalid api response exeptions
class InvalidResponseExeption extends ResponseExeption {
  const InvalidResponseExeption([super.message, super.source, super.response]);
}

/// Use on parse exeptions
class ResponseParseExeption extends InvalidResponseExeption {
  const ResponseParseExeption([super.message, super.source, super.response]);
}

/// Use on valid api response exeptions
abstract class HandeledResponseExeption extends ResponseExeption {
  const HandeledResponseExeption([super.message, super.source, super.response]);
}

/// Use on failed validation api response
class ResponseValidationExeption extends HandeledResponseExeption {
  const ResponseValidationExeption([
    super.message,
    super.source,
    super.response,
  ]);
}
