Module:       Dylan-User
Synopsis:     DUIM back-end for Deuce
Author:       Scott McKay
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library duim-deuce
  use functional-dylan;
  use collections;

  //--- Use this instead of Simple-Print for better 'print-object' behavior
  use io;

  use duim;
  use deuce;

  export duim-deuce,
	 duim-deuce-internals;
end library duim-deuce;