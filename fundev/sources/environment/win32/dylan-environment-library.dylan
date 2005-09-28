Module:    Dylan-User
Synopsis:  Collection of all the environment libraries
Author:    Nosa Omo
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library dylan-environment
  use environment-commands;
  use environment-application-commands;
  use editor-manager;
  use editor-deuce-backend;
  use environment-framework;
  use environment-tools;
  use environment-property-pages;
  use environment-deuce;
  use environment-debugger;
end library dylan-environment;