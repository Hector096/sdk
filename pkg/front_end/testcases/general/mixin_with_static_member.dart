// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9
class A extends B with M {}

class B {
  final Object m = null;
}

class M {
  static Object m() => null;
}

main() {
  new A();
}
