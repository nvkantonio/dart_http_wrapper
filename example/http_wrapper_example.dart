import 'dart:convert';
import 'package:http_wrapper/http_wrapper.dart';

Future<void> main() async {
  /// Create request with parsed model type
  final model = await postRequest<Object>(
    /// Add your api uri
    uri: Uri.parse('your_uri'),
    validatorFunction: (response) {
      /// Define your response validator
      ///
      /// On found exeption throw [ResponseValidationExeption] (inherited
      /// from [HandeledResponseExeption]) or [ResponseInvalidExeption].
      /// Or event create custom exeptions extending
      /// [HandeledResponseExeption] or [ResponseExeption].
      return;
    },
    parserFunction: (response) {
      /// Define your model parser
      return response;
    },
    encoding: utf8,
    headers: {
      /// Define your request headers
    },
    body: {
      /// Define your request body
    },
  );

  print(model);
}
