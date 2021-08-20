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
    return _routerStack.isEmpty
        ? Container()
        : Navigator(
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
    if (_routerStack.length > 0) {
      final finder = _routerStack.removeLast();
      (finder as CustomPage).completerResult.complete(null);
      _markNeedsUpdate();
      return SynchronousFuture(true);
    }
    return SynchronousFuture(false);
  }

  void pop<T extends Object?>([T? result]) {
    final finder = _routerStack.removeLast();
    _markNeedsUpdate();
    (finder as CustomPage).completerResult.complete(result);
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
