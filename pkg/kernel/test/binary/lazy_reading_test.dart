// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.9

import 'package:kernel/binary/ast_from_binary.dart';
import 'package:kernel/src/tool/find_referenced_libraries.dart';
import 'utils.dart';

main() {
  Library lib;
  {
    /// Create a library with two classes (A and B) where class A - in its
    /// constructor - invokes the constructor for B.
    lib = new Library(Uri.parse('org-dartlang:///lib.dart'));
    final Class classA = new Class(name: "A");
    lib.addClass(classA);
    final Class classB = new Class(name: "B");
    lib.addClass(classB);

    final Constructor classBConstructor = new Constructor(
        new FunctionNode(new EmptyStatement()),
        name: new Name(""));
    classB.addConstructor(classBConstructor);

    final Constructor classAConstructor = new Constructor(
        new FunctionNode(new ExpressionStatement(new ConstructorInvocation(
            classBConstructor, new Arguments.empty()))),
        name: new Name(""));
    classA.addConstructor(classAConstructor);
  }
  Component c = new Component(libraries: [lib]);
  c.setMainMethodAndMode(null, false, NonNullableByDefaultCompiledMode.Weak);
  List<int> loadMe = serializeComponent(c);

  // Load and make sure we can get at class B from class A (i.e. that it's
  // loaded correctly!).
  Component loadedComponent = new Component();
  new BinaryBuilder(loadMe,
          disableLazyReading: false, disableLazyClassReading: false)
      .readSingleFileComponent(loadedComponent);
  {
    final Library loadedLib = loadedComponent.libraries.single;
    final Class loadedClassA = loadedLib.classes.first;
    final ExpressionStatement loadedConstructorA =
        loadedClassA.constructors.single.function.body;
    final ConstructorInvocation loadedConstructorInvocation =
        loadedConstructorA.expression;
    final Class pointedToClass =
        loadedConstructorInvocation.target.enclosingClass;
    final Library pointedToLib =
        loadedConstructorInvocation.target.enclosingLibrary;

    Set<Library> reachable = findAllReferencedLibraries([loadedLib]);
    if (reachable.length != 1 || reachable.single != loadedLib) {
      throw "Expected only the single library to be reachable, "
          "but found $reachable";
    }

    final Class loadedClassB = loadedLib.classes[1];
    if (loadedClassB != pointedToClass) {
      throw "Doesn't point to the right class";
    }
    if (pointedToLib != loadedLib) {
      throw "Doesn't point to the right library";
    }
  }
  // Attempt to load again, overwriting the old stuff. This should logically
  // "relink" to the newly loaded version.
  Component loadedComponent2 = new Component(nameRoot: loadedComponent.root);
  new BinaryBuilder(loadMe,
          disableLazyReading: false,
          disableLazyClassReading: false,
          alwaysCreateNewNamedNodes: true)
      .readSingleFileComponent(loadedComponent2);
  {
    final Library loadedLib = loadedComponent2.libraries.single;
    final Class loadedClassA = loadedLib.classes.first;
    final ExpressionStatement loadedConstructorA =
        loadedClassA.constructors.single.function.body;
    final ConstructorInvocation loadedConstructorInvocation =
        loadedConstructorA.expression;
    final Class pointedToClass =
        loadedConstructorInvocation.target.enclosingClass;
    final Library pointedToLib =
        loadedConstructorInvocation.target.enclosingLibrary;

    Set<Library> reachable = findAllReferencedLibraries([loadedLib]);
    if (reachable.length != 1 || reachable.single != loadedLib) {
      throw "Expected only the single library to be reachable, "
          "but found $reachable";
    }

    final Class loadedClassB = loadedLib.classes[1];
    if (loadedClassB != pointedToClass) {
      throw "Doesn't point to the right class";
    }
    if (pointedToLib != loadedLib) {
      throw "Doesn't point to the right library";
    }
  }
}
