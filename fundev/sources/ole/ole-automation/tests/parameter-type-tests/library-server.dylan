Module:    dylan-user
Synopsis:  Tests of parameter types for COM interfaces.
Author:    Seth LaForge
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library parameter-type-tests-server
  use functional-dylan;
  use big-integers;
  use generic-arithmetic;
  use c-ffi;
  use com;
  use ole-automation;
  use win32-common;
  use system;
  use testworks;
end library parameter-type-tests-server;


define module parameter-type-tests
  use machine-words;
  use simple-format;
  use simple-random;
  use big-integers;
  use generic-arithmetic-functional-dylan;
  use c-ffi;
  use com;
  use ole-automation;
  use win32-common;
  use date;
  use file-system;
  use operating-system;
  use testworks;
end module parameter-type-tests;
