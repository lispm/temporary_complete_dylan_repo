Module:       win32-duim-gui-test-suite
Author:       Andy Armstrong, Scott McKay
Synopsis:     Win32 DUIM test suite
Copyright:    Original Code is Copyright (c) 1997-2000 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define method main
    (arguments :: <sequence>) => (status-code :: <integer>)
  debug-message("Starting Win32 DUIM GUI tests with arguments %=", arguments);
  let status-code = start-tests();
  debug-message("Exiting Win32 DUIM GUI tests with status code %d", status-code);
  status-code
end method main;

//---*** Should we use the operating system library to get the
//---*** real arguments?
main(#[]);