import 'package:flutter/widgets.dart';

typedef Selector<R extends Listenable> = dynamic Function(R model);

abstract class RStatelessWidget extends StatelessWidget with _Watchable {
  const RStatelessWidget({Key? key}) : super(key: key);

  @override
  StatelessElement createElement() => _RStatelessElement(this);
}

abstract class RStatefulWidget extends StatefulWidget with _Watchable {
  const RStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() => _RStatefulElement(this);
}

mixin _RElement on ComponentElement {
  final _listeners = <_ListenerKey, _ListenerValue>{};

  void watch<R extends Listenable>(R model, {Selector<R>? selector}) {
    final key = _ListenerKey(model, selector.hashCode);

    void callback() {
      if (!mounted) {
        return;
      }

      if (selector == null) {
        unwatch();
        return markNeedsBuild();
      }

      final selection = selector(model);
      final oldSelection = _listeners[key]?.selection;

      assert(selection is! Map || selection is! Set || selection is! List);
      assert(
        oldSelection is! Map || oldSelection is! Set || oldSelection is! List,
      );

      if (selection != oldSelection) {
        unwatch();
        markNeedsBuild();
      }

      _listeners[key] = _ListenerValue(callback, selection);
    }

    final selection = selector?.call(model);
    final entry = _ListenerValue(callback, selection);
    _listeners[key] = entry;
    model.addListener(entry.callback);
  }

  void unwatch<R extends Listenable>() {
    for (final MapEntry(:key, :value) in _listeners.entries) {
      key.model.removeListener(value.callback);
    }

    _listeners.clear();
  }

  @override
  void unmount() {
    unwatch();
    super.unmount();
  }
}

class _RStatelessElement extends StatelessElement with _RElement {
  _RStatelessElement(StatelessWidget widget) : super(widget);
}

class _RStatefulElement extends StatefulElement with _RElement {
  _RStatefulElement(StatefulWidget widget) : super(widget);
}

mixin _Watchable {
  R watch<R extends Listenable>(
    BuildContext context,
    R model, {
    Selector<R>? selector,
  }) {
    if (context is! _RElement) {
      throw ArgumentError('watch can only be called inside RWidget');
    }

    context.watch(model, selector: selector);
    return model;
  }
}

extension ListenableX<R extends Listenable> on R {
  void watch(
    BuildContext context, {
    Selector<R>? selector,
  }) {
    if (context is! _RElement) {
      throw ArgumentError('watch can only be called inside RWidget');
    }

    context.watch(this, selector: selector);
  }
}

class _ListenerValue<R extends Listenable> {
  final VoidCallback callback;
  final dynamic selection;

  const _ListenerValue(this.callback, this.selection);

  @override
  bool operator ==(Object other) {
    return other is _ListenerValue &&
        other.callback == callback &&
        other.selection == selection;
  }

  @override
  int get hashCode => Object.hash(callback, selection);
}

class _ListenerKey<T extends Listenable> {
  const _ListenerKey(this.model, this.code);

  final T model;
  final int code;

  @override
  bool operator ==(Object other) {
    return other is _ListenerKey && other.model == model && other.code == code;
  }

  @override
  int get hashCode => Object.hash(model, code);
}
