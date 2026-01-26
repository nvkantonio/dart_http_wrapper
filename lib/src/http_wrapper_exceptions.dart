import 'package:http/http.dart';
import 'package:meta/meta.dart';

// Api response exception
abstract interface class IResponseException implements Exception {
  String get message;
  dynamic get source;
  Object? get causedError;
  Response? get response;
  BaseRequest? get request;

  ResponseException merge(IResponseException merge);
}

class ResponseException implements IResponseException {
  const ResponseException({
    this.message = '',
    this.source,
    this.causedError,
    this.response,
    this.request,
  });

  @override
  final String message;
  @override
  final dynamic source;
  @override
  final Object? causedError;
  @override
  final Response? response;
  @override
  final BaseRequest? request;

  @override
  @mustBeOverridden
  ResponseException merge(IResponseException merge) => throw UnsupportedError(
      'Merge method is not defined for ResponseException');

  @override
  String toString() => message;
}

/// Use on valid api response exception
class HandledResponseException extends ResponseException {
  const HandledResponseException({
    super.message,
    super.source,
    super.causedError,
    super.response,
    super.request,
  });

  @override
  HandledResponseException merge(IResponseException merge) {
    return HandledResponseException(
      message: message.isNotEmpty ? message : merge.message,
      source: source ?? merge.source,
      causedError: causedError ?? merge.causedError,
      response: merge.response ?? response,
      request: merge.request ?? request,
    );
  }
}

/// Use on invalid api response exceptions
class InvalidResponseException extends ResponseException {
  const InvalidResponseException({
    super.message,
    super.source,
    super.causedError,
    super.response,
    super.request,
  });

  @override
  InvalidResponseException merge(IResponseException merge) {
    return InvalidResponseException(
      message: message.isNotEmpty ? message : merge.message,
      source: source ?? merge.source,
      causedError: causedError ?? merge.causedError,
      response: merge.response ?? response,
      request: merge.request ?? request,
    );
  }
}

/// Use on parse exceptions
class ResponseParseException extends InvalidResponseException {
  const ResponseParseException({
    super.message,
    super.source,
    super.causedError,
    super.response,
    super.request,
  });

  @override
  ResponseParseException merge(IResponseException merge) {
    return ResponseParseException(
      message: message.isNotEmpty ? message : merge.message,
      source: source ?? merge.source,
      causedError: causedError ?? merge.causedError,
      response: merge.response ?? response,
      request: merge.request ?? request,
    );
  }
}

/// Use on failed validation api response
class ResponseValidationException extends HandledResponseException {
  const ResponseValidationException({
    super.message = '',
    super.source,
    super.causedError,
    super.response,
    super.request,
  });

  @override
  ResponseValidationException merge(IResponseException merge) {
    return ResponseValidationException(
      message: message.isNotEmpty ? message : merge.message,
      source: source ?? merge.source,
      causedError: causedError ?? merge.causedError,
      response: merge.response ?? response,
      request: merge.request ?? request,
    );
  }
}
