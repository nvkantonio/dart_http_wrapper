import 'dart:developer';

import 'package:http/http.dart';
import 'package:http_wrapper/http_wrapper.dart';

Future<void> main() async {
  /// Create request with parse model type.
  final model = await postRequest<Object>(
    /// Add your api uri
    uri: Uri.parse('your_uri'),
    validatorFunction: (dynamic json) {
      /// Define your response validator.
      ///
      /// On found exception throw [ResponseValidationException] (inherited
      /// from [HandledResponseException]) or [ResponseInvalidException].
      /// Or event create custom exceptions extending
      /// [HandledResponseException] or [ResponseException].
      return;
    },
    parserFunction: (dynamic json) {
      /// Define your model parser.
      return json;
    },
    headers: {
      /// Define your request headers.
    },
    body: {
      /// Define your request body.
    },
  );

  print(model);

  final model1 = await httpWrapper(
    request: Request("GET", Uri.parse('your_uri')),
    parserFunction: (json) => json,
  );

  print(model1);

  final model2 = await httpWrapper(
    request: Request("GET", Uri.parse('your_uri')),
    validatorFunctionFromData: (data) {
      if (data.response.statusCode != 200) {
        throw 'Status code is ${data.response.statusCode}';
      }
    },
    parserFunctionFromData: (data) {
      return data.json;
    },
  );

  print(model2);

  final model3 = await postRequest<Object>(
    /// Add your api uri
    uri: Uri.parse('your_uri'),
    validatorFunctionFromData: (data) {
      /// For e.g. use `if (data.response.statusCode == 200)` to check
      /// response status code.
      if (data.response.statusCode != 200) {
        throw 'Status code is ${data.response.statusCode}';
      }
      return;
    },
    parserFunctionFromData: (data) {
      /// For e.g. use `data.request.method` for better exception explanations
      try {
        return data.json['response'];
      } catch (e) {
        log('Response was not found for: ${data.request.method}');
        rethrow;
      }
    },
    headers: {},
    body: {},
  );

  print(model3);
}
