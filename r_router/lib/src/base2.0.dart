part of 'base.dart';

class RRouterData {
  final String path;
  final String fullPath;
  final dynamic params;
  final Map<String, String>? queryParams;
  final List<String>? pathParams;

  const RRouterData(this.path, this.fullPath,
      {this.params, this.queryParams, this.pathParams});
}

class RRouterDataProvider extends InheritedWidget {
  final RRouterData value;

  RRouterDataProvider(Widget child, {required this.value})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant RRouterDataProvider oldWidget) {
    return value != oldWidget.value;
  }
}

extension RRouterContextExtension on BuildContext {
  RRouterData? readRRouterData() {
    final data = this.dependOnInheritedWidgetOfExactType<RRouterDataProvider>();
    return data?.value;
  }
}

class RRouterInformationParser extends RouteInformationParser<RRouterData> {
  @override
  Future<RRouterData> parseRouteInformation(
      RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return RRouterData('/', '/');
    } else {
      final uri = Uri.parse(routeInformation.location!);
      print(
          'uri.pathSegments:${uri.pathSegments}\nuri.queryParameters:${uri.queryParameters}\nrouteInformation.state:${routeInformation.state}');
      return RRouterData(routeInformation.location!, routeInformation.location!,
          params: routeInformation.state,
          queryParams: uri.queryParameters,
          pathParams: uri.pathSegments);
    }
  }

  @override
  RouteInformation? restoreRouteInformation(RRouterData configuration) {
    return RouteInformation(
        location: configuration.path, state: configuration.params);
  }
}

class RRouterDelegate extends RouterDelegate<RRouterData>
    with PopNavigatorRouterDelegateMixin<RRouterData>, ChangeNotifier {
  List<RRouterData> _routerStack = [];

  RRouterDelegate() : navigatorKey = GlobalKey();

  static RRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is RRouterDelegate, 'Delegate type must match');
    return delegate as RRouterDelegate;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _onGeneratePages(context),
      onPopPage: _onPopPage,
      observers: [
        RRouter.myRouter.observer,
      ],
    );
  }

  @override
  RRouterData? get currentConfiguration =>
      _routerStack.length > 0 ? _routerStack.last : null;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Future<void> setNewRoutePath(RRouterData configuration) async {
    _routerStack.add(configuration);
    notifyListeners();
  }


  List<Page<RRouterData>> _onGeneratePages(BuildContext context) {
    List<Page<RRouterData>> result = [];
    for (final item in _routerStack) {
      if (item.path == '/404') {
        assert(RRouter.myRouter.notFoundPage != null,
            "Please Setting Not Found page.such as:`RRouter.myRouter.notFoundPage = Text('')`");
        result.add(MaterialPage<RRouterData>(
            child: RRouter.myRouter.notFoundPage!(null)));
      } else {
        RRouterWidgetBuilder? builder = RRouter.myRouter._routeMap[item.path];
        if (builder != null) {
          result.add(_pageGenerate(
              item, context, (BuildContext context) => builder(null)));
        } else {
          try {
            assert(RRouter.myRouter.notFoundPage != null,
                "Please Setting Not Found page.such as:`RRouter.myRouter.notFoundPage = Text('')`");
            result.add(_pageGenerate(
                item,
                context,
                (BuildContext context) =>
                    RRouter.myRouter.notFoundPage!.call(item.path)));
          } catch (_) {
            String error =
                "No registered route was found to handle '${item.path}'.";
            throw RRouterNotFoundException(error, item.path);
          }
        }
      }
    }
    if (result.length == 0) {
      result.add(MaterialPage<RRouterData>(child: Scaffold()));
    }
    return result;
  }

  bool _onPopPage(Route route, result) {
    return route.didPop(result);
  }

  Page<RRouterData> _pageGenerate(
      RRouterData data, BuildContext context, WidgetBuilder builder) {
    String name = data.path;
    RRouterPageBuilderType? pageBuilder =
        RRouter.myRouter._pageBuilderTypeMap[name];
    PageTransitionsBuilder? pageTransitions =
        RRouter.myRouter._pageTransitionsMap[name];
    if (pageTransitions != null) {
      return CustomPage<RRouterData>(
        pageTransitionsBuilder: pageTransitions,
        child: RRouterDataProvider(
          builder(context),
          value: data,
        ),
        key: ValueKey(data.path),
        name: data.path,
        arguments: data.params,
        restorationId: data.path,
      );
    }
    if (pageBuilder != null) {
      if (pageBuilder == RRouterPageBuilderType.cupertino) {
        return CupertinoPage<RRouterData>(
          child: RRouterDataProvider(
            builder(context),
            value: data,
          ),
          name: data.path,
          key: ValueKey(data.path),
          arguments: data.params,
          restorationId: data.path,
        );
      } else {
        return MaterialPage<RRouterData>(
          child: RRouterDataProvider(
            builder(context),
            value: data,
          ),
          name: data.path,
          key: ValueKey(data.path),
          arguments: data.params,
          restorationId: data.path,
        );
      }
    } else {
      return MaterialPage<RRouterData>(
        child: RRouterDataProvider(
          builder(context),
          value: data,
        ),
        key: ValueKey(data.path),
        arguments: data.params,
        restorationId: data.path,
      );
    }
  }
}
