documented: #t
module: portability
copyright: Copyright (C) 1994, Carnegie Mellon University
	   All rights reserved.
	   This code was produced by the Gwydion Project at Carnegie Mellon
	   University.  If you are interested in using this code, contact
	   "Scott.Fahlman@cs.cmu.edu" (Internet).
rcs-header: $Header: 

//======================================================================
//
// Copyright (c) 1994  Carnegie Mellon University
// All rights reserved.
//
//======================================================================

//======================================================================
// Module portability is a tiny OS dependent module which defines the
// preprocessor definions and "standard" include directories which would be
// used by a typical C compiler for that OS.  It may, at some future date,
// also include behavioral switches for things like slot allocation or sizes
// of different sorts of numbers.
//
// This particular implementation of module portability corresponds to the
// compilation environment for an HP 735 running HPUX.
//======================================================================

// default defines came from "gcc -v anyfile.c"
//
define constant $default-defines
  = #["const", "",
      "volatile", "",
      "hppa", "",
      "hp9000s800", "",
      "__hp9000s800", "",
      "hp9k8", "",
      "PWB", "",
      "hpux", "",
      "unix", "",
      "_HPUX_SOURCE", "",
      "__hppa__", "",
      "__hp9000s800__", "",
      "__hp9k8__", "",
      "__PWB", "",
      "__hpux__", "",
      "__unix__", "",
      "___HPUX_SOURCE__", "",
      "__hppa", "",
      "__hp9000s800", "",
      "__hp9000s800", "",
      "__hp9k8 _" "__PWB",
      "__hpux", "",
      "__unix", "",
      "___HPUX_SOURCE", "",
      "__hp9aaas700", "",
      "_PA_RISC1_1", "",
      "__STDC__", ""];

  
define constant hp-include-directories
  = #["/usr/local/include", "/usr/include"];

for (dir in hp-include-directories)
  push-last(include-path, dir);
end for;


// These constants should be moved here in the future.  Until the module
// declarations can be sufficiently rearranged to allow their definition
// here, they will remain commented out.  -- panda
//
// define constant c-type-size = unix-type-size;
// define constant c-type-alignment = unix-type-alignment;
// define constant $default-alignment :: <integer> = 4;


define constant $integer-size :: <integer> = 4;
define constant $short-int-size :: <integer> = 2;
define constant $long-int-size :: <integer> = 4;
define constant $char-size :: <integer> = 1;
define constant $float-size :: <integer> = 4;
define constant $double-float-size :: <integer> = 8;
define constant $long-double-size :: <integer> = 16;
define constant $enum-size :: <integer> = $integer-size;
define constant $pointer-size :: <integer> = 4;
define constant $function-pointer-size :: <integer> = $pointer-size;
