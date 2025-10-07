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
      /// On found exeption throw [ResponseValidationExeption] (inherited
      /// from [HandeledResponseExeption]) or [ResponseInvalidExeption].
      /// Or event create custom exeptions extending
      /// [HandeledResponseExeption] or [ResponseExeption].
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
    validatorFunctionWithResponse: (json, response) {
      if (response.statusCode != 200) {
        throw 'Status code is ${response.statusCode}';
      }
    },
  );

  print(model2);
}
