// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9
/*@testedFeatures=inference*/
library test;

abstract class A {
  Iterable<String> get foo;
}

class B implements A {
  final foo = /*@ typeArgs=String* */ const [];
}

void main() {}
