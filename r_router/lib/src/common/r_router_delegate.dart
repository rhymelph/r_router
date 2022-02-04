part of 'r_router.dart';

class RRouterDelegate extends RouterDelegate<Page<dynamic>>
    with ChangeNotifier {
  List<Page<dynamic>> _routerStack = [];
  final List<NavigatorObserver> observers;

  RRouterDelegate({List<NavigatorObserver>? observers})
      : this.observers = observers ?? [];

  static RRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is RRouterDelegate, 'Delegate type must match');
    return delegate as RRouterDelegate;
  }

  void addObserver(NavigatorObserver observer) {
    this.observers.add(observer);
  }

  void addObservers(Iterable<NavigatorObserver> observers) {
    this.observers.addAll(observers);
  }

  bool _isDisposed = false;

  @override
  Widget build(BuildContext context) {
    assert(!_isDisposed);
    if (_routerStack.isEmpty) return Container();

    return Navigator(
      pages: List.from(_routerStack),
      onPopPage: _onPopPage,
      observers: [
        RRouter._observer,
        ...observers,
      ],
    );
  }

  @override
  Page<dynamic>? get currentConfiguration {
    assert(!_isDisposed);
    return _routerStack.length > 0 ? _routerStack.last : null;
  }

  @override
  Future<void> setNewRoutePath(Page<dynamic> configuration) async {
    if (_routerStack.isNotEmpty) {
      final lastRouter = _routerStack.last;
      if (configuration.name == lastRouter.name) {
        return SynchronousFuture(null);
      }
      if (configuration is CustomPage) {
        final newParams = configuration.arguments as Map;
        if (lastRouter.name == null && newParams['isDirectly']) {
          return SynchronousFuture(null);
        }
      }
    }
    _routerStack.clear();
    _routerStack.add(configuration);
    _markNeedsUpdate();
    return SynchronousFuture(null);
  }

  Future<dynamic> push(Page<dynamic> page) async {
    _routerStack.add(page);
    _markNeedsUpdate();
    return await (page as CustomPage).completerResult.future;
  }

  Future<dynamic> clearTracePush(Page<dynamic> page) async {
    _routerStack.clear();
    return await push(page);
  }

  Future<dynamic> replacePush<T extends Object?, TO extends Object?>(
      Page<dynamic> page, TO? result) async {
    final finder = _routerStack.removeLast();
    (finder as CustomPage).completerResult.complete(result);
    return await push(page);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _markNeedsUpdate() {
    assert(!_isDisposed);
    notifyListeners();
  }

  bool _onPopPage(Route route, result) {
    if (route.didPop(result)) {
      final finder = _routerStack.removeLast();
      (finder as CustomPage).completerResult.complete(result);
      _markNeedsUpdate();
      return true;
    }
    return false;
  }

  @override
  Future<bool> popRoute() {
    if (_routerStack.length > 1) {
      final finder = _routerStack.removeLast();
      (finder as CustomPage).completerResult.complete(null);
      _markNeedsUpdate();
      return SynchronousFuture(true);
    }
    return RRouter._popHome();
  }

  void pop<T extends Object?>([T? result]) {
    final finder = (_routerStack.removeLast() as CustomPage);
    _markNeedsUpdate();
    Future.delayed(finder.transitionDuration, () {
      finder.completerResult.complete(result);
    });
  }

  Future<bool> maybePop<T extends Object?>([T? result]) {
    if (canPop()) {
      final finder = _routerStack.removeLast();
      _markNeedsUpdate();
      (finder as CustomPage).completerResult.complete(result);
      return SynchronousFuture(true);
    }
    return SynchronousFuture(false);
  }

  bool canPop() => _routerStack.length > 0;
}
