Module: sql-implementation
Author: eec
Copyright:    Original Code is Copyright (c) 1995-2004 Functional Objects, Inc.
              All rights reserved.
License:      Functional Objects Library Public License Version 1.0
Dual-license: GNU Lesser General Public License
Warranty:     Distributed WITHOUT WARRANTY OF ANY KIND

// $HopeName: DBdylan-sql!make.dylan(trunk.1) $

// Within the dynamic scope of a with-dbms macro call, calls to make on
// <user>, <database> or <sql-statement> classes will result in dbms-
// specific instances. This presupposes the dbms-specific implementation
// of DWSQL provide methods on the generic function make-dbms-specific
// to create the dbms-specific instances.


define open generic make-dbms-specific
    (type :: <class>, dbms :: <dbms>, #rest more-args)
 => (instance :: <object>);


//++ I wonder if there is a way to combine these three methods
//   into one method.

define method make(type == <user>, #rest more-args, #key)
  => (instance :: <user>)
  apply(make-dbms-specific, type, default-dbms(), more-args);
end method;


define method make(type == <database>, #rest more-args, #key)
 => (instance :: <database>)
  apply(make-dbms-specific, type, default-dbms(), more-args);
end method;


define method make(type == <sql-statement>, #rest more-args, #key)
 => (instance :: <sql-statement>)
  apply(make-dbms-specific, type, default-dbms(), more-args);
end method;
