// Copyright (c) 2015, Jim Heyne. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.


library interpolate.base;

const Getter ROOT_GETTER = null;

void info(String info) {
//  print(info);
}

class Getter<T> {
  final String label;
  final Getter parent;
  final Function getter;
  List<Getter> childGetters = new List<Getter>();
  List<Setter> setters = new List<Setter>();

  bool isRoot() {
    return parent == null;
  }

//  Getter.root(String this.label, Function this.getter)  {
//    this.parent = null;
//  }

  Getter(String this.label, Function this.getter, Getter this.parent) {
    if (parent != null) {
      parent.childGetters.add(this);
    }
  }

  T value() {
    return isRoot() ? getter(null) : getter(parent.value());
  }

  Getter findGetter(String path) {
    var p = path.replaceFirst('\$', '');
    info('Path is $p');
    var list = p.split('\.');
    info('List is $list');
    if (isRoot()) {
      for (Getter child in childGetters) {
        var target = child._findGetterPrim(list);
        if (target != null) {
          return target;
        }
      }
      return null;
    } else {
      return _findGetterPrim(list);
    }
  }

  Setter findSetter(String path) {
    var p = path.replaceFirst('\$', '');
    info('Path is $p');
    var list = p.split('\.');
    info('List is $list');
    if (list.length == 1) {
      for (Setter child in setters) {
        if (child.label == list.first) {
          return child;
        }
      }
      return null;
    }
    if (isRoot()) {
      for (Getter child in childGetters) {
        var target = child._findSetterPrim(list);
        if (target != null) {
          return target;
        }
      }
      return null;
    } else {
      return _findSetterPrim(list);
    }
  }

  Getter _findGetterPrim(List<String> labels) {
    if (labels.isEmpty) {
      info('Return null');
      return null;
    }
    if (labels.length == 1) {
      info('Length is one');
      if (labels.last == label) {
        info('Returning this');
        return this;
      } else {
        info('Returning null last is ${labels.last} my label is $label');
        return null;
      }
    }
    if (labels.first == label) {
      var sublist = labels.sublist(1);
      for (Getter child in childGetters) {
        var childGetter = child._findGetterPrim(sublist);
        if (childGetter != null) {
          return childGetter;
        }
      }
    }
    return null;
  }

  Setter _findSetterPrim(List<String> labels) {
    if (labels.length < 2) {
      info('Return null');
      return null;
    }
    if (labels.length == 2) {
      info('Length is two');
      if (labels.first == label) {
        var sublist = labels.sublist(1);
        for (Setter child in setters) {
          if (child.label == labels.last) {
            return child;
          }
        }
      } else {
        info('Returning null first is ${labels.first} my label is $label');
        return null;
      }
      info('Returning null child setter not found $labels my label is $label');
      return null;
    }
    if (labels.first == label) {
      var sublist = labels.sublist(1);
      for (Getter child in childGetters) {
        var childSetter = child._findSetterPrim(sublist);
        if (childSetter != null) {
          return childSetter;
        }
      }
    }
    return null;
  }

}

class Setter<T> {
  final String label;
  final Getter parent;
  final Function setter;

//  Setter.root(String label, Function setter) {
//    this(label, setter, ROOT_GETTER);
//  }

  Setter(String this.label, Function this.setter, Getter this.parent) {
    if (parent != ROOT_GETTER) {
      parent.setters.add(this);
    }
  }

  void setValue(T value) {
    setter(parent.value(), value);
  }
}

class BuildAccessors {
  final Symbol methodName;

  const BuildAccessors(this.methodName);
}

abstract class Interpolated {
  String get source;

//  Map<String, Accessor> get accessors;
}

abstract class MyDsl extends Interpolated {
  void doStuff() {
    this.source.contains('xxx');
  }
}

class Bond {
  List<Binding> bound = new List<Binding>();
  ConflictResolver conflictResolver;

  void changed(Binding source, var oldValue, var newValue) {
    for (Binding target in bound) {
      if (target != source && target.setter != null) {
        target.updateValue(newValue);
      }
    }
  }

  addParticipant(Binding participant) {
    bound.add(participant);
    participant.bond = this;
  }

  Bond(List<Binding> participants, {ConflictResolver this.conflictResolver}) {
    for (Binding participant in participants) {
      addParticipant(participant);
    }
  }

  bool lookForChange() {
    for (Binding binding in bound) {
      if (binding.lookForChange()) {
        return true;
      }
    }
    return false;
  }
}

class Binding {
  Bond bond;
  var currentValue;
  var originalValue;
  Getter getter;
  Setter setter;

  Binding(this.getter, this.setter) {
    originalValue = getter.value();
    currentValue = originalValue;
  }

  bool isOriginalValue() {
    return currentValue == originalValue;
  }

  void updateValue(var newValue) {
    setter.setValue(newValue);
    currentValue = newValue;
  }

  bool lookForChange() {
    var value = getter.value();
    if (value != currentValue) {
      bond.changed(this, currentValue, value);
      currentValue = value;
      return true;
    }
    return false;
  }
}

class ConflictResolver {

}

class RefreshTimer {

  final int _refreshInMilliseconds = 30;

  Timer _refreshTimer;

  final List<Binding> _activeElements = new List();

  static final Map<int, RefreshTimer> _cache = new Map<int, RefreshTimer>();

  RefreshTimer(this._refreshInMilliseconds);

  /// Supplies an instance for a particular refresh interval
  factory RefreshTimer.RefreshTimer(int refreshInSeconds) {
    return _cache.putIfAbsent(refreshInSeconds, () => new RefreshTimer(refreshInSeconds));
  }

  void register(Binding bond) {
    if (_activeElements.isEmpty) {
      _startTimer();
    }
    _activeElements.add(bond);
  }

  void unregister(Binding lapse) {
    _activeElements.remove(lapse);
    if (_activeElements.isEmpty) {
      _refreshTimer.cancel();
    }
  }

  void _startTimer() {
    final Duration refreshPeriod = new Duration(seconds: _refreshInMilliseconds);
    _refreshTimer = new Timer.periodic(refreshPeriod, refreshAllDates);
  }

  void refreshAllDates(Timer timer) {
    _activeElements.forEach((e) => e.lookForChange());
  }
}

class GetterGenerator {
  Set<String> alreadyWritten = new Set();
  StringBuffer b = new StringBuffer();

//  var root = new Getter(null, null, null);
//  var g_model = new Getter("model", () => model, root);
//  var s_model = new Setter("model", ((SampleModel value) => model = value), root);
//  var g_model_firstName = new Getter("firstName", (SampleModel model) => model.firstName, g_model);
//  var s_model_firstName = new Setter("firstName", ((SampleModel model, String value) => model.firstName = value), g_model);
//  var g_model_lastName = new Getter("lastName", (model) => model.lastName, g_model);
//  var s_model_lastName = new Setter("lastName", (model, value) => model.lastName = value, g_model);
//  return root;

  void property(List<String> path, int index, bool hasGetter, bool hasSetter) {
    var label = path[index];
    var getterVar = variable(path, index, false, false);
    if (hasGetter && !alreadyWritten.contains(getterVar)) {
      b.write('\tvar ${getterVar} = new Getter("$label", (o) => o.$label, ${variable(path, index, true, false)});\n');
      alreadyWritten.add(getterVar);
    }
    var setterVar = variable(path, index, false, true);
    if (hasSetter && !alreadyWritten.contains(setterVar)) {
      b.write('\tvar ${setterVar} = new Setter("$label", ((o, value) => o.$label = value), ${variable(path, index, true, false)});\n');
      alreadyWritten.add(setterVar);
    }
  }

  void method(List<String> path) {
    var label = path.last;
    var getterVar = variable(path, path.length - 1, false, false);
    if (!alreadyWritten.contains(getterVar)) {
      b.write('\tvar ${getterVar} = new Getter("$label", () => $label, ${variable(path, path.length - 1, true, false)});\n');
      alreadyWritten.add(getterVar);
    }
  }

  String variable(List<String> path, int index, bool isParent, bool isSetter) {
    if (index == (isParent ? 0 : -1)) {
      return isParent ? 'root' : 'null';
    }
    var sb = new StringBuffer(isSetter ? 's' : 'g');
    path.sublist(0, (isParent ? index : index + 1)).forEach((String label) {
      sb.write('_${trimParens(label)}');
    });
    return sb.toString();
  }

  String trimParens(String label) {
    label = label.replaceAll('(', '_');
    label = label.replaceAll(')', '_');
    return label;
  }

  GetterGenerator() {
    b.write('\tvar root = new Getter(null, (ignore) => this, null);\n');
  }

  String toString() {
    return '${b.toString()}\treturn root;\n';
  }
}
