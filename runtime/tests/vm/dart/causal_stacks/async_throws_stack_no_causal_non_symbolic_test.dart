// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// VMOptions=--dwarf-stack-traces --save-debugging-info=async_no_causal_debug.so --no-causal-async-stacks --no-lazy-async-stacks

import 'dart:async';

import 'utils.dart';

Future<void> main(List<String> args) async =>
    await doTestsNoCausalNoLazy('async_no_causal_debug.so');