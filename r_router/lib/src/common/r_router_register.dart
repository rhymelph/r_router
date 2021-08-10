import 'package:path_tree/path_tree.dart';
import 'package:r_router/src/common/navigator_route.dart';

class RRouterRegister {
  final List<NavigatorRoute> _routes = [];
  PathTree<NavigatorRoute> _routeTree = PathTree<NavigatorRoute>();

  ///Registe Routes
  /// [routes] You want to registe routes.
  void registe(Iterable<NavigatorRoute> routes) {
    _routes.addAll(routes);
  }

  /// Registe Route
  /// [route] You want to registe route.
  void registeRoute(NavigatorRoute route, {bool? isReplaceRouter}) {
    if (isReplaceRouter == true) {
      build();
      NavigatorRoute? handler = _routeTree.match(route.pathSegments, 'GET');
      _routes.remove(handler);
    }
    _routes.add(route);
  }

  void build() {
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
