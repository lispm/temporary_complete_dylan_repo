Module:    dfmc-shell
Synopsis:  Dylan Compiler Shell
Author:    Gary Palter
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define function system-registry-path () => (path :: <string>)
  "Unknown"
end function system-registry-path;

define function user-registry-path () => (path :: false-or(<string>))
  #f
end function user-registry-path;
