Module:    Dylan-User
Synopsis:  Win32 Environment Basic Edition
Author:    Andy Armstrong
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library basic-win32-environment
  use functional-dylan;
  use system;

  use basic-release-info;

  use c-ffi;
  use win32-common;
  use win32-user;
  use win32-shell;

  use duim;
  use win32-duim;

  // Use these libraries just to get bitmap and color constants
  use deuce;
  use duim-deuce;

  use dylan-environment;
  use environment-protocols;
  use environment-framework;
  use environment-tools;
  use basic-environment-project-wizard;
  use environment-debugger;

  use editor-manager;
  use editor-deuce-backend;

  use source-control-manager;

  export win32-environment;
end library basic-win32-environment;
