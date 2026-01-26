# Http_wrapper

A simple [dart:http](https://pub.dev/packages/http) wrapper using validator and parser.

## Usage

```dart
import 'package:http_wrapper/http_wrapper.dart';

Future<void> main() async {
  /// Create request with parse model type.
  final model = await postRequest<Object>(
    /// Add your api uri
    uri: Uri.parse('your_uri'),
    validatorFunction: (dynamic  json) {
      /// Define your response validator.
      ///
      /// On found exception throw [ResponseValidationException] (inherited
      /// from [HandledResponseException]) or [ResponseInvalidException].
      /// Or event create custom exceptions extending
      /// [HandledResponseException] or [ResponseException].
      return;
    },
    parserFunction: (dynamic  json) {
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
}
```

Validator and parser with ResponseData object:

```dart
import 'package:http_wrapper/http_wrapper.dart';

Future<void> main() async {
  final model = await postRequest<Object>(
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

  print(model);
}
```

Use `httpWrapper()` to define your own request.

Available requests shortHands for httpWrapper:

- `getRequest()`
- `postRequest()`
- `getMultipartRequest()`
- `postMultipartRequest()`
