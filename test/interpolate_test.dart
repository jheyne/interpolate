// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library interpolate.test;

import 'package:test/test.dart';

import 'package:interpolate/interpolate.dart';

/// Assure that getters and setters are accessible
testGettersAndSetters() {
  var myInstance = new MyInstance();
  var getter = myInstance.generatedAccessors();
  var modelGetter = getter.findGetter('\$model');
  expect(modelGetter, isNotNull);
  expect(modelGetter.label, equals('model'));
  var firstNameGetter = getter.findGetter('\$model.firstName');
  expect(firstNameGetter, isNotNull);
  expect(firstNameGetter.label, equals('firstName'));
  var lastNameGetter = getter.findGetter('\$model.lastName');
  expect(lastNameGetter, isNotNull);
  expect(lastNameGetter.label, equals('lastName'));
  var noNameGetter = getter.findGetter('\$model.noName');
  expect(noNameGetter, isNull);
  var noNameSetter = getter.findSetter('\$model.noName');
  expect(noNameSetter, isNull);
  var firstNameSetter = getter.findSetter('\$model.firstName');
  expect(firstNameSetter, isNotNull);
  expect(firstNameSetter.label, equals('firstName'));
  var modelSetter = getter.findSetter('\$model');
  expect(modelSetter, isNotNull);
  expect(modelSetter.label, equals('model'));
  var bestFriendGetter = getter.findGetter('\$model.bestFriend()');
  var bestFriendLastNameGetter = getter.findGetter('\$model.bestFriend().lastName');
}

/// Assure that getters and setters can manipulate and access values
testAccessors() {
  var myInstance = new MyInstance();
  myInstance.model = new SampleModel();
  myInstance.model.firstName = 'Jim';
  myInstance.model.lastName = 'Heyne';
  var getter = myInstance.generatedAccessors();

  var firstNameGetter = getter.findGetter('\$model.firstName');
  expect(firstNameGetter.value(), equals('Jim'));

  var lastNameGetter = getter.findGetter('\$model.lastName');
  expect(lastNameGetter.value(), equals('Heyne'));

  var firstNameSetter = getter.findSetter('\$model.firstName');
  firstNameSetter.setValue('Linda');
  expect(firstNameGetter.value(), equals('Linda'));

  var lastNameSetter = getter.findSetter('\$model.lastName');
  lastNameSetter.setValue('Smith');
  expect(lastNameGetter.value(), equals('Smith'));

  var modelSetter = getter.findSetter('\$model');
  var sally = new SampleModel();
  sally.firstName = 'Sally';
  sally.lastName = 'Shelley';
  modelSetter.setValue(sally);
  expect(firstNameGetter.value(), equals('Sally'));
  expect(lastNameGetter.value(), equals('Shelley'));

  var bestFriendGetter = getter.findGetter('\$model.bestFriend()');
  print(bestFriendGetter.label);
  print(bestFriendGetter.getter);
  expect(bestFriendGetter.value(), new isInstanceOf<SampleModel>());
  var bestFriendLastNameGetter = getter.findGetter('\$model.bestFriend().lastName');
  expect(bestFriendLastNameGetter.value(), equals('Shelley'));
}

/// Assure changes are propagated as expected
testBindings() {
  TestBond t = new TestBond();
  // Ask binding to detect change
  t.one.model.firstName = 'Sally';
  expect(t.oneFirstBound.lookForChange(), isTrue);
  expect(t.two.model.firstName, equals('Sally'));
  // No change expected
  expect(t.oneFirstBound.lookForChange(), isFalse);

  // Ask bond to detect change
  t.one.model.firstName = 'Joan';
  expect(t.bond.lookForChange(), isTrue);
  expect(t.two.model.firstName, equals('Joan'));
  // No change expected
  expect(t.bond.lookForChange(), isFalse);
  // check if original value has changed
  expect(t.twoFirstBound.isOriginalValue(), isFalse);
  t.one.model.firstName = 'Jim';
  expect(t.bond.lookForChange(), isTrue);
  expect(t.twoFirstBound.isOriginalValue(), isTrue);
}

/// Generate the accessors used in other tests
/// Used in MyInstance.generatedAccessors
testAccessorGeneration() {
  GetterGenerator g = new GetterGenerator();
  expect(g.toString(), equals('\tvar root = new Getter(null, (ignore) => this, null);\n\treturn root;\n'));
  List<String> list = ['model', 'firstName'];
  g.property(list, 0, true, true);
  g.property(list, 1, true, true);
  list = ['model', 'lastName'];
  g.property(list, 0, true, true);
  g.property(list, 1, true, true);
  list = ['model', 'bestFriend()', 'lastName'];
  g.property(list, 1, true, false);
  g.property(list, 2, true, true);
  print(g.toString());
}

void main() {
  group('Interpolation accessor tests:', () {
    setUp(() {
    });
    test('Getters and Setters can be located in accessors', testGettersAndSetters);
    test('Accessors can get and set values', testAccessors);
    test('Bindings in bonds propagate change', testBindings);
    test('Accessor generation', testAccessorGeneration);
  });
}

/// A contrived test class to exercise Getters and Setters
class SampleModel {
  String firstName;
  String lastName;

  SampleModel bestFriend() {
    return this;
  }
}

/// A contrived test class to exercise Getters and Setters
class MyInstance extends MyDsl {

  SampleModel model;

  /// sample interpolation akin to that found in these tests
  get source => '''
  First Name: ${model.firstName}
  Last Name: ${model.lastName}
  Best Friend Name: ${model.bestFriend().firstName}
  ''';

  /// The body of this method was generated by testAccessorGeneration
  Getter generatedAccessors() {
    var root = new Getter(null, (ignore) => this, null);
    var g_model = new Getter("model", (o) => o.model, root);
    var s_model = new Setter("model", ((o, value) => o.model = value), root);
    var g_model_firstName = new Getter("firstName", (o) => o.firstName, g_model);
    var s_model_firstName = new Setter("firstName", ((o, value) => o.firstName = value), g_model);
    var g_model_lastName = new Getter("lastName", (o) => o.lastName, g_model);
    var s_model_lastName = new Setter("lastName", ((o, value) => o.lastName = value), g_model);
    var g_model_bestFriend__ = new Getter("bestFriend()", (o) => o.bestFriend(), g_model);
    var g_model_bestFriend___lastName = new Getter("lastName", (o) => o.lastName, g_model_bestFriend__);
    var s_model_bestFriend___lastName = new Setter("lastName", ((o, value) => o.lastName = value), g_model_bestFriend__);
    return root;
  }

}

/// A dummy object used to test Bond change propagation
class TestBond {
  MyInstance one;
  Getter oneAccessor;
  Binding oneFirstBound;
  MyInstance two;
  Getter twoAccessor;
  Binding twoFirstBound;
  Bond bond;

  TestBond() {
    one = new MyInstance();
    oneAccessor = one.generatedAccessors();
    {
      one.model = new SampleModel();
      one.model.firstName = 'Jim';
      one.model.lastName = 'Heyne';
      var firstNameGetter = oneAccessor.findGetter('\$model.firstName');
      var lastNameGetter = oneAccessor.findGetter('\$model.lastName');
      var firstNameSetter = oneAccessor.findSetter('\$model.firstName');
      var lastNameSetter = oneAccessor.findSetter('\$model.lastName');
      oneFirstBound = new Binding(firstNameGetter, firstNameSetter);
    }
    // Set up binding on second object
    two = new MyInstance();
    twoAccessor = two.generatedAccessors();
    {
      two.model = new SampleModel();
      two.model.firstName = 'Jim';
      two.model.lastName = 'Heyne';
      var firstNameGetter = twoAccessor.findGetter('\$model.firstName');
      var lastNameGetter = twoAccessor.findGetter('\$model.lastName');
      var firstNameSetter = twoAccessor.findSetter('\$model.firstName');
      var lastNameSetter = twoAccessor.findSetter('\$model.lastName');
      twoFirstBound = new Binding(firstNameGetter, firstNameSetter);
    }

    var bonds = [oneFirstBound, twoFirstBound];
    bond = new Bond(bonds);
  }
}