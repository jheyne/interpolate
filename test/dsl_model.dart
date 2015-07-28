library ae;

import 'package:interpolate/interpolate.dart';

class Example {

  /// an identifier for the multiplier
  String id;

  /// A descriptive label
  String description;

  String get stuff {
    return 'stuff';
  }

  void set stuff(String value) {}

  String doSomething() {
    return 'Jim';
  }

  void interpolation() {
    var getter = (Example c) => c.stuff;
    var setter = (Example c, String value) => c.stuff = value;
    @BuildAccessors(#getTemplateAccessors)
    var source ='''
body
  div id=$id
  div class=${stuff}
  div onClick=${doSomething()}
  x $stuff
  y $doSomething()
    ''';
  }

  Getter getTemplateAccessors() {

  }
}


