import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

typedef EnqueueCallback = FutureOr Function();
typedef RRouterRequestCallback = RouteSettings Function(RouteSettings settings);

class Lock {
  Future? _lock;
  late Completer _completer;

  /// Whether this interceptor has been locked.
  bool get locked => _lock != null;

  /// Lock the interceptor.
  ///
  /// Once the request/response interceptor is locked, the incoming request/response
  /// will be added to a queue  before they enter the interceptor, they will not be
  /// continued until the interceptor is unlocked.
  void lock() {
    if (!locked) {
      _completer = Completer();
      _lock = _completer.future;
    }
  }

  /// Unlock the interceptor. please refer to [lock()]
  void unlock() {
    if (locked) {
      _completer.complete();
      _lock = null;
    }
  }

  /// Clean the interceptor queue.
  void clear([String msg = 'cancelled']) {
    if (locked) {
      _completer.completeError(msg);
      _lock = null;
    }
  }

  /// If the interceptor is locked, the incoming request/response task
  /// will enter a queue.
  ///
  /// [callback] the function  will return a `Future`
  /// @nodoc
  Future? enqueue(EnqueueCallback callback) {
    if (locked) {
      // we use a future as a queue
      return _lock!.then((d) => callback());
    }
    return null;
  }
}

class RRouterInterceptors extends ListMixin<RRouterInterceptor> {
  final _list = <RRouterInterceptor>[];
  final Lock _requestLock = Lock();

  Lock get requestLock => _requestLock;
  @override
  int length = 0;

  @override
  RRouterInterceptor operator [](int index) {
    return _list[index];
  }

  @override
  void operator []=(int index, RRouterInterceptor value) {
    if (_list.length == index) {
      _list.add(value);
    } else {
      _list[index] = value;
    }
  }
}

/// interceptor if you want to interceptor router
class RRouterInterceptor {
  RouteSettings onRequest(RouteSettings settings) => settings;
}

/// interceptor wrapper
class RRouterInterceptorWrapper extends RRouterInterceptor {
  final RRouterRequestCallback? _onRequest;

  RRouterInterceptorWrapper({RRouterRequestCallback? onRequest})
      : _onRequest = onRequest;

  @override
  RouteSettings onRequest(RouteSettings settings) {
    if (_onRequest != null) {
      return _onRequest!.call(settings);
    }
    return super.onRequest(settings);
  }
}
