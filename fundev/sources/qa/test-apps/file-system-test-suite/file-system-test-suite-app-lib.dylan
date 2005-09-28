Module:    dylan-user
Author:    Carl Gay
Synopsis:  An application library for the file-system-test-suite
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library file-system-test-suite-app
  use file-system-test-suite;
  use testworks;
end;

define module file-system-test-suite-app
  use file-system-test-suite;
  use testworks;
end;