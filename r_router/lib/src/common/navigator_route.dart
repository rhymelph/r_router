part of 'r_router.dart';

typedef RouteInterceptor = FutureOr<bool> Function(Context ctx);

/// Function that modifies [context]
typedef ResponseProcessor = FutureOr<dynamic> Function(
    Context context, dynamic result);

typedef RouteHandler = FutureOr<dynamic> Function(Context context);

/// Register this Navigator Route
///
/// [path] you want registe path, such as: /user/:id   or /user/*
/// [pathRegEx] Map of regular expression matchers for specific path segment
///     such as  path = /:id/name   pathRegEx = {'id':r'^[0-9]*$'}
/// [handler] you want to return Widget
/// [defaultPageTransaction] page transaction.
class NavigatorRoute {
  /// Path of the route
  final String path;

  /// Map of regular expression matchers for specific path segment
  final Map<String, String>? pathRegEx;

  RouteHandler handler;

  final List<RouteInterceptor> _interceptors;

  final _pathVarMapping = <String, int>{};

  int? _pathGlobVarMapping;

  String? _pathGlobVarName;

  final Iterable<String> pathSegments;

  final ResponseProcessor? responseProcessor;

  PageTransitionsBuilder? defaultPageTransaction;

  NavigatorRoute(this.path, this.handler,
      {this.pathRegEx,
      this.responseProcessor,
      this.defaultPageTransaction,
      List<RouteInterceptor>? interceptors})
      : pathSegments = pathToSegments(path),
        _interceptors = interceptors ?? [] {
    for (int i = 0; i < pathSegments.length; i++) {
      String seg = pathSegments.elementAt(i);
      if (seg.startsWith(':')) {
        if (i == pathSegments.length - 1 && seg.endsWith('*')) {
          _pathGlobVarMapping = i;
          _pathGlobVarName = seg.substring(1, seg.length - 1);
        } else {
          seg = seg.substring(1);
          if (seg.isNotEmpty) _pathVarMapping[seg] = i;
        }
      }
    }
  }

  Future<dynamic> call(Context ctx) async {
    for (String pathParam in _pathVarMapping.keys) {
      ctx.pathParams[pathParam] = ctx.pathSegments[_pathVarMapping[pathParam]!];
    }
    if (_pathGlobVarMapping != null) {
      ctx.pathParams[_pathGlobVarName!] =
          ctx.pathSegments.skip(_pathGlobVarMapping!).join('/');
    }
    return await ctx.execute(this);
  }

  List<RouteInterceptor> getInterceptor() => _interceptors.toList();

  /// Add [interceptor] and optionally
  /// [handler] in the route chain.
  void addInterceptor(RouteInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  String toString() => '$path';
}
