import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'http_wrapper_exeptions.dart';

typedef ParserFunction<T> = FutureOr<T> Function(dynamic json);
typedef ValidatorFunction = FutureOr Function(dynamic json);
typedef ValidatorFunctionWithResponse = FutureOr Function(
    dynamic json, Response response);

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
///   /// On found exeption throw [ResponseValidationExeption] (inherited
///   /// from [HandeledResponseExeption]) or [ResponseInvalidExeption].
///   /// Or event create custom exeptions extending
///   /// [HandeledResponseExeption] or [ResponseExeption].
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
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) async {
  assert(
    validatorFunction == null || validatorFunctionWithResponse == null,
    'Either validatorFunction or validatorFunctionWithResponse should be used for httpWrapper',
  );

  final Response response;
  final dynamic json;

  try {
    response = await Response.fromStream(await request.send());
  } catch (e) {
    rethrow;
  }

  try {
    json = jsonDecode(response.body);
  } catch (e) {
    throw InvalidResponseExeption(
      message: 'Cannot parse response to json',
      source: response.body,
      causedError: e,
      response: response,
    );
  }

  try {
    await validatorFunction?.call(json);
    await validatorFunctionWithResponse?.call(json, response);
  } on ResponseExeption {
    rethrow;
  } catch (e) {
    InvalidResponseExeption(
      message: 'Validator function cathed unhandled exeption',
      source: json,
      causedError: e,
      response: response,
    );
  }

  if (parserFunction != null) {
    try {
      return await parserFunction(json);
    } on ResponseExeption {
      rethrow;
    } catch (e) {
      throw ResponseParseExeption(
        message: e.toString(),
        source: json,
        causedError: e,
        response: response,
      );
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
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
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
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
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
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
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
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) {
  final request = MultipartRequest('POST', uri);

  if (headers != null) {
    request.headers.addAll(headers);
  }

  if (fields != null && fields.isNotEmpty) {
    request.fields.addAll(fields);
  }

  if (files != null && files.isEmpty) {
    request.files.addAll(files);
  }

  return httpWrapper<R>(
    request: request,
    parserFunction: parserFunction,
    encoding: encoding,
    validatorFunction: validatorFunction,
    validatorFunctionWithResponse: validatorFunctionWithResponse,
  );
}
