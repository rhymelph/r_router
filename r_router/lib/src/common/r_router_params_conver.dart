import 'dart:convert';

abstract class RRouterParamsConvert {
  String encode<T>(T value);

  T? decode<T>(String value);
}

class DefaultParamsConvert extends RRouterParamsConvert {
  @override
  T? decode<T>(String value) {
    return json.decode(value);
  }

  @override
  String encode<T>(T value) {
    return json.encode(value);
  }
}
