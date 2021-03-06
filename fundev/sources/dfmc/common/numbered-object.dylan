Module: dfmc-common
Author: Jonathan Bachrach
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      See License.txt in this distribution for details.
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

define variable *id* :: <integer> = -1;

define method make-next-id () => (res :: <integer>)
  *id* := *id* + 1
end method;

define compiler-open class <numbered-object> (<object>)
  slot id :: <integer> = make-next-id();
end class;
