import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'http_wrapper_exeptions.dart';

typedef ParserFunction<T> = FutureOr<T> Function(dynamic response);
typedef ValidatorFunction = FutureOr Function(dynamic parsedJson);
typedef ValidatorFunctionWithResponse = FutureOr Function(
    dynamic parsedJson, Response response);

Future<R> httpWrapper<R>({
  required BaseRequest request,
  required ParserFunction<R> parserFunction,
  ValidatorFunction? validatorFunction,
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) async {
  assert(
    validatorFunction == null || validatorFunctionWithResponse == null,
    'Either validatorFunction or validatorFunctionWithResponse should be used for httpWrapper',
  );

  final Response response;
  final dynamic parsedJson;

  try {
    response = await Response.fromStream(await request.send());
  } catch (e) {
    rethrow;
  }

  try {
    parsedJson = jsonDecode(response.body);
  } catch (e) {
    throw InvalidResponseExeption(
      message: 'Cannot decode response',
      source: response.body,
      causedError: e,
      response: response,
    );
  }

  try {
    await validatorFunction?.call(parsedJson);
    await validatorFunctionWithResponse?.call(parsedJson, response);
  } on ResponseExeption {
    rethrow;
  } catch (e) {
    InvalidResponseExeption(
      message: 'Validator function sent unhandled exeption',
      source: parsedJson,
      causedError: e,
      response: response,
    );
  }

  try {
    return await parserFunction(parsedJson);
  } on ResponseExeption {
    rethrow;
  } catch (e) {
    throw ResponseParseExeption(
      message: e.toString(),
      source: parsedJson,
      causedError: e,
      response: response,
    );
  }
}

Future<R> getRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
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

Future<R> postRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
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

Future<R> getMultipartRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
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

Future<R> postMultipartRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
  Map<String, String>? headers,
  Map<String, String>? fields,
  Iterable<MultipartFile>? files,
  ValidatorFunction? validatorFunction,
  ValidatorFunctionWithResponse? validatorFunctionWithResponse,
  @Deprecated('Set encoding for request') Encoding? encoding,
}) {
  final request = MultipartRequest('GET', uri);

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
