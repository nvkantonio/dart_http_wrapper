import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'http_wrapper_exeptions.dart';

typedef ParserFunction<T> = FutureOr<T> Function(dynamic response);
typedef ValidatorFunction = FutureOr Function(dynamic response);

Future<R> httpWrapper<R>({
  required BaseRequest request,
  required ParserFunction<R> parserFunction,
  ValidatorFunction? validatorFunction,
  Encoding? encoding,
}) async {
  final String response;
  final StreamedResponse streamedResponse;
  final dynamic jsonResponse;

  try {
    streamedResponse = await request.send();

    response = await streamedResponse.stream.bytesToString(encoding ?? utf8);
  } catch (e) {
    rethrow;
  }

  try {
    jsonResponse = jsonDecode(response);
  } catch (e) {
    throw InvalidResponseExeption(
      'Cannot decode response',
      e,
      streamedResponse,
    );
  }

  try {
    if (validatorFunction != null) {
      await validatorFunction(jsonResponse);
    }
  } on ResponseExeption {
    rethrow;
  } catch (e) {
    InvalidResponseExeption(
      'Validator function sent unhandled exeption',
      e,
      streamedResponse,
    );
  }

  try {
    return await parserFunction(response);
  } on ResponseExeption {
    rethrow;
  } catch (e) {
    throw ResponseParseExeption(e.toString(), e, streamedResponse);
  }
}

Future<R> getRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
  Map<String, String>? headers,
  ValidatorFunction? validatorFunction,
  Encoding? encoding,
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
  );
}

Future<R> postRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  ValidatorFunction? validatorFunction,
  Encoding? encoding,
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
  );
}

Future<R> getMultipartRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
  Map<String, String>? headers,
  ValidatorFunction? validatorFunction,
  Encoding? encoding,
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
  );
}

Future<R> postMultipartRequest<R>({
  required Uri uri,
  required ParserFunction<R> parserFunction,
  Map<String, String>? headers,
  Map<String, String>? fields,
  Iterable<MultipartFile>? files,
  ValidatorFunction? validatorFunction,
  Encoding? encoding,
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
  );
}
