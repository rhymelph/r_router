part of 'r_router.dart';

class Context {
  final DateTime at;
  final String path;
  dynamic body;

  Context(this.path, {this.body, DateTime? at}) : at = at ?? DateTime.now();

  Uri get uri => Uri.parse(path);

  Map toJson() {
    return {
      'at': at.microsecondsSinceEpoch,
      'path': path,
      'body': body,
      'pathParams': pathParams,
    };
  }

  factory Context.fromJson(Map map) {
    Context ctx = Context(map['path'],
        body: map['body'], at: DateTime.fromMicrosecondsSinceEpoch(map['at']));
    ctx.pathParams.addAll(map['pathParams']);
    return ctx;
  }

  List<String> get pathSegments => uri.pathSegments;

  final pathParams = PathParams();

  QueryParams? _query;

  QueryParams get query => _query ??= QueryParams(uri.queryParameters);

  Future<WidgetBuilder?> execute(NavigatorRoute route) async {
    WidgetBuilder? builder;
    dynamic maybeFuture;
    {
      final info = route;
      dynamic res = route.handler(this);
      if (res is Future) res = await res;
      if (res is Widget) {
        builder = (BuildContext context) => res;
      } else if (res is WidgetBuilder) {
        builder = res;
      } else {
        if (builder == null) {
          if (info.responseProcessor != null) {
            maybeFuture = info.responseProcessor!(this, res);
            if (maybeFuture is Future) await maybeFuture;
          }
        }
      }
    }
    return builder;
  }
}
