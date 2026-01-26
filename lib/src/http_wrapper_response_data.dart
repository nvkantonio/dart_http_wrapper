import 'package:http/http.dart';
import 'package:meta/meta.dart';

@immutable
class ResponseData {
  const ResponseData(
      {required this.json, required this.response, required this.request});

  final dynamic json;
  final Response response;
  final BaseRequest request;

  operator [](key) => json[key];
}
