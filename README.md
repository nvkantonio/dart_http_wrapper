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

Validator with Response object:

```dart
import 'package:http_wrapper/http_wrapper.dart';

Future<void> main() async {
  final model = await postRequest<Object>(
    /// Add your api uri
    uri: Uri.parse('your_uri'),
    validatorFunctionWithResponse: (dynamic json, Response response) {
      /// For e.g. use `if (response.statusCode == 200)` to check response status code.
      if (response.statusCode != 200) {
        throw 'Status code is ${response.statusCode}';
      }
      return;
    },
    parserFunction: (response) => response,
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
