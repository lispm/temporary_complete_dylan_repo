Module:    Dylan-User
Synopsis:  The command line version of the environment
Author:    Andy Armstrong
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library minimal-console-environment
  use functional-dylan;
  use system;
  use io;
  use commands;

  use internal-release-info;
  use build-system;
  use licensing;

  use environment-protocols;
  use environment-commands;
  use environment-application-commands;
  use environment-internal-commands;

  export console-environment;
end library minimal-console-environment;