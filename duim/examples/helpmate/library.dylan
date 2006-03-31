Module:       dylan-user
Author:       Jason Trenouth
Synopsis:     Example DUIM Help code
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library helpmate
  use functional-dylan;
  use duim;
  use io;
  export helpmate;
end library;

define module helpmate
  use functional-dylan;
  use duim;
  use format;
end module;