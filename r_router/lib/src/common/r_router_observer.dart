part of 'r_router.dart';

/// route observer
class RRouterObserver extends NavigatorObserver {
  List<String> _routeList = [];

  String get topPath => _routeList.length > 0 ? _routeList.last : '';

  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    String? path = route?.settings.name;
    String? previousPath = previousRoute?.settings.name;
    if (path != null && path != '') {
      if (!_routeList.contains(path)) {
        _routeList.add(path);
      }
    }
    RRouter._print(
        'RRouter --> did push $path , previous $previousPath , current top $topPath');
  }

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    String? path = route?.settings.name;
    String? previousPath = previousRoute?.settings.name;
    if (path != null && path != '') {
      if (_routeList.contains(path)) {
        int index = _routeList.lastIndexOf(path);
        if (index > 0) _routeList.removeAt(index);
      }
    }
    if (previousPath != null && previousPath != '') {
      if (!_routeList.contains(previousPath)) {
        _routeList.add(previousPath);
      }
    }
    RRouter._print(
        'RRouter --> did pop $path , previous $previousPath , current top $topPath');
  }

  @override
  void didRemove(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    String? path = route?.settings.name;
    String? previousPath = previousRoute?.settings.name;
    if (path != null && path != '') {
      if (_routeList.contains(path)) {
        int index = _routeList.lastIndexOf(path);
        if (index > 0) _routeList.removeAt(index);
      }
    }
    if (previousPath != null && previousPath != '') {
      if (!_routeList.contains(previousPath)) {
        _routeList.add(previousPath);
      }
    }
    RRouter._print(
        'RRouter --> did remove $path , previous $previousPath , current top $topPath');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    String? path = newRoute?.settings.name;
    String? oldPath = oldRoute?.settings.name;
    if (oldPath != null && oldPath != '') {
      if (_routeList.contains(oldPath)) {
        int index = _routeList.lastIndexOf(oldPath);
        if (index > 0) _routeList.removeAt(index);
      }
    }
    if (path != null && path != '') {
      if (!_routeList.contains(path)) {
        _routeList.add(path);
      }
    }
    RRouter._print(
        'RRouter --> did replace $path , old $oldPath , current top $topPath');
  }
}
