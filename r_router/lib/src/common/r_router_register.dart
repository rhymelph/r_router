part of 'r_router.dart';

class RRouterRegister {
  final List<NavigatorRoute> _routes = [];
  PathTree<NavigatorRoute> _routeTree = PathTree<NavigatorRoute>();

  ///Register Routes
  /// [routes] You want to register routes.
  void add(Iterable<NavigatorRoute> routes) {
    _routes.addAll(routes);
  }

  /// Register Route
  /// [route] You want to register route.
  void addRoute(NavigatorRoute route, {bool? isReplaceRouter}) {
    if (isReplaceRouter == true) {
      _build();
      NavigatorRoute? handler = _routeTree.match(route.pathSegments, 'GET');
      _routes.remove(handler);
    }
    _routes.add(route);
  }

  void _build() {
    _routeTree = PathTree<NavigatorRoute>();
    for (NavigatorRoute route in _routes) {
      _routeTree.addPathAsSegments(route.pathSegments, route,
          pathRegEx: route.pathRegEx);
    }
  }

  /// match Route handle
  /// [uri] requestUrl
  NavigatorRoute? match(Uri uri) {
    NavigatorRoute? handler = _routeTree.match(uri.pathSegments, 'GET');
    return handler;
  }
}
