part of 'r_router.dart';

/// A [Map] that delegates all operations to a base map.
///
/// This class can be used to hide non-`Map` methods of an object that extends
/// `Map`, or it can be extended to add extra functionality on top of an
/// existing map object.
class DelegatingMap<K, V> implements Map<K, V> {
  final Map<K, V> _base;

  const DelegatingMap(Map<K, V> base) : _base = base;

  /// Creates a wrapper that asserts the types of keys and values in [base].
  ///
  /// This soundly converts a [Map] without generic types to a `Map<K, V>` by
  /// asserting that its keys are instances of `E` and its values are instances
  /// of `V` whenever they're accessed. If they're not, it throws a [CastError].
  /// Note that even if an operation throws a [CastError], it may still mutate
  /// the underlying collection.
  ///
  /// This forwards all operations to [base], so any changes in [base] will be
  /// reflected in [this]. If [base] is already a `Map<K, V>`, it's returned
  /// unmodified.
  @Deprecated('Use map.cast<K, V> instead.')
  static Map<K, V> typed<K, V>(Map base) => base.cast<K, V>();

  @override
  V? operator [](Object? key) => _base[key];

  @override
  void operator []=(K key, V value) {
    _base[key] = value;
  }

  @override
  void addAll(Map<K, V> other) {
    _base.addAll(other);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    _base.addEntries(entries);
  }

  @override
  void clear() {
    _base.clear();
  }

  @override
  Map<K2, V2> cast<K2, V2>() => _base.cast<K2, V2>();

  @override
  bool containsKey(Object? key) => _base.containsKey(key);

  @override
  bool containsValue(Object? value) => _base.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => _base.entries;

  @override
  void forEach(void Function(K, V) f) {
    _base.forEach(f);
  }

  @override
  bool get isEmpty => _base.isEmpty;

  @override
  bool get isNotEmpty => _base.isNotEmpty;

  @override
  Iterable<K> get keys => _base.keys;

  @override
  int get length => _base.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      _base.map(transform);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) =>
      _base.putIfAbsent(key, ifAbsent);

  @override
  V? remove(Object? key) => _base.remove(key);

  @override
  void removeWhere(bool Function(K, V) test) => _base.removeWhere(test);

  @deprecated
  Map<K2, V2> retype<K2, V2>() => cast<K2, V2>();

  @override
  Iterable<V> get values => _base.values;

  @override
  String toString() => _base.toString();

  @override
  V update(K key, V Function(V) update, {V Function()? ifAbsent}) =>
      _base.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(V Function(K, V) update) => _base.updateAll(update);
}

class CastableStringMap extends DelegatingMap<String, String> {
  CastableStringMap(Map<String, String> map) : super(map);

  ///Retrieve a value from this map
  String? get(String key, [String? defaultValue]) {
    if (!containsKey(key)) {
      return defaultValue;
    }

    return this[key];
  }

  ///Retrieve a value from this map
  int? getInt(String key, [int? defaultValue]) {
    if (!containsKey(key)) {
      return defaultValue;
    }

    dynamic valueDyn = this[key];

    if (valueDyn is int) {
      return valueDyn;
    }

    if (valueDyn is String) {
      return stringToInt(valueDyn, defaultValue);
    }

    return defaultValue;
  }

  ///Retrieve a value from this map
  double? getDouble(String key, [double? defaultValue]) {
    if (!containsKey(key)) {
      return defaultValue;
    }

    dynamic valueDyn = this[key];

    if (valueDyn is double) {
      return valueDyn;
    }

    if (valueDyn is String) {
      return stringToDouble(valueDyn, defaultValue);
    }

    return defaultValue;
  }

  ///Retrieve a value from this map
  num? getNum(String key, [num? defaultValue]) {
    if (!containsKey(key)) {
      return defaultValue;
    }

    dynamic valueDyn = this[key];

    if (valueDyn is num) {
      return valueDyn;
    }

    if (valueDyn is String) {
      return stringToNum(valueDyn, defaultValue);
    }

    return defaultValue;
  }

  ///Retrieve a value from this map
  bool? getBool(String key, [bool? defaultValue]) {
    if (!containsKey(key)) {
      return defaultValue;
    }

    dynamic valueDyn = this[key];

    if (valueDyn is bool) {
      return valueDyn;
    }

    if (valueDyn is String) {
      return stringToBool(valueDyn, defaultValue);
    }

    return defaultValue;
  }

  DateTime? getDateTime(String key, {DateTime? defaultValue}) {
    final micros = getInt(key);
    if (micros == null) return defaultValue;

    return DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);
  }

  List<String> getList(String key, [Pattern separator = ","]) {
    if (!containsKey(key)) return [];
    return this[key]!.split(separator);
  }
}

/// Class to hold path parameters
class PathParams extends CastableStringMap {
  PathParams([Map<String, String>? map]) : super({}) {
    if (map is Map) {
      addAll(map!);
    }
  }

  PathParams.fromPathParam(PathParams param) : super(param);
}

/// Class to hold query parameters
class QueryParams extends CastableStringMap {
  QueryParams(Map<String, String> map) : super(map);

  QueryParams.fromQueryParam(QueryParams param) : super(param);

  String toString() => this
      .entries
      .map((e) =>
          '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
}
