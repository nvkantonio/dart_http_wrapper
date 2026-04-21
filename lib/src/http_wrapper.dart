import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_wrapper/src/http_wrapper_response_data.dart';

import 'http_wrapper_exceptions.dart';

typedef ParserFunction<R> = FutureOr<R> Function(dynamic json);
typedef ValidatorFunction = FutureOr Function(dynamic json);

@Deprecated('Use ValidatorFunctionFromData instead')
typedef ValidatorFunctionWithResponse = FutureOr Function(
    ResponseData data, Response response);

typedef ParserFunctionFromData<R> = FutureOr<R> Function(ResponseData data);
typedef ValidatorFunctionFromData = FutureOr Function(ResponseData data);

/// Base http request processor
///
/// ```dart
/// await httpWrapper<R>(
///   /// Add your api request
///   request: Request("GET", Uri.parse('your_uri')),
///   {@template http_wrapper_params}
///   parserFunction: (json) {
///     /// Define your model parser.
///     return json as R;
///   },
///   validatorFunction: (dynamic json) {
///   /// Define your response validator.
///   ///
///   /// On found exception throw [ResponseValidationException] (inherited
///   /// from [HandledResponseException]) or [ResponseInvalidException].
///   /// Or event create custom exceptions extending
///   /// [HandledResponseException] or [ResponseException].
///   return;
///   },
///   {@endtemplate}
/// );
/// ```
///
Future<R> httpWrapper<R>({
  required BaseRequest request,
  ParserFunction<R>? parserFunction,
  ValidatorFunction? validatorFunction,
  @Deprecated('Use validatorFunctionFromData instead')
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  ValidatorFunctionFromData? validatorFunctionFromData,
  ParserFunctionFromData<R>? parserFunctionFromData,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) async {
  assert(
    _countBoolIterable(
            [parserFunction == null || parserFunctionFromData == null]) <=
        1,
    'Only one or none parser function must be used for httpWrapper',
  );
  assert(
    _countBoolIterable([
          validatorFunction == null ||
              validatorFunctionWithResponse == null ||
              validatorFunctionFromData == null
        ]) <=
        1,
    'Only one or none validator function must be used for httpWrapper',
  );

  final Response response;
  final dynamic json;
  final ResponseData responseData;

  try {
    response = await Response.fromStream(await request.send());
  } catch (e) {
    rethrow;
  }

  try {
    json = jsonDecode(response.body);
  } catch (e, st) {
    Error.throwWithStackTrace(
        InvalidResponseException(
          message: 'Cannot parse response to json',
          source: response.body,
          causedError: e,
          response: response,
          request: request,
        ),
        st);
  }

  responseData = ResponseData(json: json, response: response, request: request);

  try {
    await validatorFunction?.call(responseData);
    await validatorFunctionWithResponse?.call(responseData, response);
    await validatorFunctionFromData?.call(responseData);
  } on ResponseException catch (e, st) {
    Error.throwWithStackTrace(
        e.merge(
          ResponseException(
            message:
                'Can not validate response ${request.url} ${request.method}',
            source: json,
            request: request,
            response: response,
          ),
        ),
        st);
  } catch (e, st) {
    Error.throwWithStackTrace(
        InvalidResponseException(
          message:
              'Can not validate response with unhandled exception ${request.url} ${request.method}: $e',
          source: json,
          causedError: e,
          response: response,
          request: request,
        ),
        st);
  }

  if (parserFunction != null || parserFunctionFromData != null) {
    try {
      if (parserFunctionFromData != null) {
        return await parserFunctionFromData(responseData);
      } else {
        return await parserFunction!(json);
      }
    } on ResponseException catch (e, st) {
      Error.throwWithStackTrace(
          e.merge(
            ResponseException(
              message:
                  'Can not parse response ${request.url} ${request.method}',
              source: json,
              request: request,
              response: response,
            ),
          ),
          st);
    } catch (e, st) {
      Error.throwWithStackTrace(
          ResponseParseException(
            message:
                'Can not parse response with unhandled exception ${request.url} ${request.method}: $e',
            source: json,
            causedError: e,
            response: response,
            request: request,
          ),
          st);
    }
  } else {
    return json;
  }
}

/// Shorthand for `httpWrapper()` with "GET" Request
///
/// ```dart
/// await getRequest<R>(
///   /// Add your api uri
///   request: Uri.parse('your_uri'),
///   headers: {
///     /// Define your request headers.
///   },
///   {@macro http_wrapper_params}
/// );
/// ```
///
Future<R> getRequest<R>({
  required Uri uri,
  ParserFunction<R>? parserFunction,
  Map<String, String>? headers,
  ValidatorFunction? validatorFunction,
  @Deprecated('Use validatorFunctionFromData instead')
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  ParserFunctionFromData<R>? parserFunctionFromData,
  ValidatorFunctionFromData? validatorFunctionFromData,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) {
  final request = Request('GET', uri);

  if (headers != null) {
    request.headers.addAll(headers);
  }

  return httpWrapper<R>(
    request: request,
    parserFunction: parserFunction,
    encoding: encoding,
    validatorFunction: validatorFunction,
    parserFunctionFromData: parserFunctionFromData,
    validatorFunctionFromData: validatorFunctionFromData,
    validatorFunctionWithResponse: validatorFunctionWithResponse,
  );
}

/// Shorthand for `httpWrapper()` with "POST" Request
///
/// ```dart
/// await postRequest<R>(
///   /// Add your api uri
///   request: Uri.parse('your_uri'),
///   headers: {
///     /// Define your request headers.
///   },
///   body: {
///     /// Define your request body.
///   },
///   {@macro http_wrapper_params}
/// );
/// ```
///
Future<R> postRequest<R>({
  required Uri uri,
  ParserFunction<R>? parserFunction,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  ValidatorFunction? validatorFunction,
  @Deprecated('Use validatorFunctionFromData instead')
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  ParserFunctionFromData<R>? parserFunctionFromData,
  ValidatorFunctionFromData? validatorFunctionFromData,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) {
  final request = Request('POST', uri);

  if (headers != null) {
    request.headers.addAll(headers);
  }

  if (body != null) {
    request.body = json.encode(body);
  }

  return httpWrapper<R>(
    request: request,
    parserFunction: parserFunction,
    encoding: encoding,
    validatorFunction: validatorFunction,
    parserFunctionFromData: parserFunctionFromData,
    validatorFunctionFromData: validatorFunctionFromData,
    validatorFunctionWithResponse: validatorFunctionWithResponse,
  );
}

/// Shorthand for `httpWrapper()` with "GET" MultipartRequest
///
/// ```dart
/// await getMultipartRequest<R>(
///   /// Add your api uri
///   request: Uri.parse('your_uri'),
///   headers: {
///     /// Define your request headers.
///   },
///   {@macro http_wrapper_params}
/// );
/// ```
///
Future<R> getMultipartRequest<R>({
  required Uri uri,
  ParserFunction<R>? parserFunction,
  Map<String, String>? headers,
  ValidatorFunction? validatorFunction,
  @Deprecated('Use validatorFunctionFromData instead')
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  ParserFunctionFromData<R>? parserFunctionFromData,
  ValidatorFunctionFromData? validatorFunctionFromData,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) {
  final request = MultipartRequest('GET', uri);

  if (headers != null) {
    request.headers.addAll(headers);
  }

  return httpWrapper<R>(
    request: request,
    parserFunction: parserFunction,
    encoding: encoding,
    validatorFunction: validatorFunction,
    parserFunctionFromData: parserFunctionFromData,
    validatorFunctionFromData: validatorFunctionFromData,
    validatorFunctionWithResponse: validatorFunctionWithResponse,
  );
}

/// Shorthand for `httpWrapper()` with "POST" MultipartRequest
///
/// ```dart
/// await postMultipartRequest<R>(
///   /// Add your api uri
///   request: Uri.parse('your_uri'),
///   headers: {
///     /// Define your request headers.
///   },
///   fields: {
///     /// Define your request fields.
///   }
///   files: {
///     /// Define your request files.
///   }
///   {@macro http_wrapper_params}
/// );
/// ```
///
Future<R> postMultipartRequest<R>({
  required Uri uri,
  ParserFunction<R>? parserFunction,
  Map<String, String>? headers,
  Map<String, String>? fields,
  Iterable<MultipartFile>? files,
  ValidatorFunction? validatorFunction,
  @Deprecated('Use validatorFunctionFromData instead')
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  ParserFunctionFromData<R>? parserFunctionFromData,
  ValidatorFunctionFromData? validatorFunctionFromData,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) {
  final request = MultipartRequest('POST', uri);

  if (headers != null) {
    request.headers.addAll(headers);
  }

  if (fields != null && fields.isNotEmpty) {
    request.fields.addAll(fields);
  }

  if (files != null && files.isNotEmpty) {
    request.files.addAll(files);
  }

  return httpWrapper<R>(
    request: request,
    parserFunction: parserFunction,
    encoding: encoding,
    validatorFunction: validatorFunction,
    parserFunctionFromData: parserFunctionFromData,
    validatorFunctionFromData: validatorFunctionFromData,
    validatorFunctionWithResponse: validatorFunctionWithResponse,
  );
}

int _countBoolIterable(Iterable<bool> iterable) {
  int count = 0;

  for (final e in iterable) {
    if (e) {
      count++;
    }
  }

  return count;
}
