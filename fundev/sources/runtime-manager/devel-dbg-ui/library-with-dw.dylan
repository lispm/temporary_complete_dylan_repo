module:         dylan-user
synopsis:       The tty user interface for the devel debugger
author:         Paul Howard
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define library interactive-compiler

       // STUFF

       use functional-dylan;
       use collections;
       use c-ffi;
       use system;
       use io;

       // THE RUNTIME MANAGER AND COFF MANAGER

       use access-path;
       use debugger-manager;
       use tether-downloader;
       use interactive-symbol-table;
       use coff-manager;
       use coff-debug;
       use interactive-downloader;
       use disasm;
       
       // DFMC

       use projects;      
       use dfmc-browser-support;
       use dfmc-namespace;
       use dfmc-optimization;
       use dfmc-debug-back-end;
       use dfmc-pentium-file-compiler;
       use pentium-dw;

       // THE PENTIUM BACK-END
       export devel-dbg-ui;
end library;

define module devel-dbg-ui
       use functional-dylan;
       use collectors;
       use c-ffi;
       use operating-system,
          exclude: {load-library},
          rename: {application-filename => os-application-filename};
       use streams;
       use standard-io;
       use format;
       use print;
       use format-out;
       use threads, rename: {thread-name => threads-thread-name};
       use access-path, exclude: {debugger-message};
       use debugger-manager, exclude: {debugger-message};
       use tether-downloader;
       use coff-representation;
       use coff-reader;
       use coff-print;
       use byte-vector;
       use interactive-symbol-table;
       use interactive-downloader;
       use disasm;
       use shell;
       use dw;
       use projects;      
       use projects-implementation;      
       use dfmc-interactive-execution;
       use dfmc-namespace;
       use dfmc-optimization;
       use dfmc-debug;
end module;
