Module:    Dylan-User
Author:    Andy Armstrong, Scott McKay
Synopsis:  A regression test-suite for Win32 DUIM
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define module win32-duim-regression-test-suite
  use functional-dylan;
  use simple-format;
  use simple-random;
  use threads;

  use duim;
  use duim-internals,
    exclude: { position };

  // The start up function
  export start-tests
end module win32-duim-regression-test-suite;