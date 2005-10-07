Module:    dylan-user
Author:    Shri Amit
Synopsis:  A wrapper suite around all emulator supported test-suites
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library emulator-test-suite
  use functional-dylan;
  use testworks;
  use generic-test-suite;
  use threads-test-suite;

  export emulator-test-suite
end;

define module emulator-test-suite
  use functional-dylan;
  use testworks;
  use generic-test-suite;
  use threads-test-suite;

  export emulator-test-suite
end;