module:   parse-string
author:   Nick Kramer (nkramer@cs.cmu.edu)
synopsis: A useful little data structure that's not useful enough to 
          export outside the library.
copyright:  Copyright (C) 1994, Carnegie Mellon University.
            All rights reserved.
rcs-header: $Header: /home/housel/work/rcs/gd/src/common/string-ext/parse-string.dylan,v 1.1 1996/02/17 16:12:26 nkramer Exp $

//======================================================================
//
// Copyright (c) 1994  Carnegie Mellon University
// All rights reserved.
// 
// Use and copying of this software and preparation of derivative
// works based on this software are permitted, including commercial
// use, provided that the following conditions are observed:
// 
// 1. This copyright notice must be retained in full on any copies
//    and on appropriate parts of any derivative works.
// 2. Documentation (paper or online) accompanying any system that
//    incorporates this software, or any part of it, must acknowledge
//    the contribution of the Gwydion Project at Carnegie Mellon
//    University.
// 
// This software is made available "as is".  Neither the authors nor
// Carnegie Mellon University make any warranty about the software,
// its performance, or its conformity to any specification.
// 
// Bug reports, questions, comments, and suggestions should be sent by
// E-mail to the Internet address "gwydion-bugs@cs.cmu.edu".
//
//======================================================================

// Parse strings: A string along with some state. A parse-string
// supports two operations: lookahead and consume. lookahead(s) gets
// the next character in the parse string, while consume(s) moves the
// pointer along.
//
define class <parse-string> (<object>)
  slot string :: <sequence>, required-init-keyword: #"string";
  slot index :: <integer>, init-value: 0;
end class <parse-string>;

define constant <character?> = false-or(<character>);

define method consume (s :: <parse-string>) => s :: <parse-string>;
  if (s.index >= size(s.string))
    #f;
  else
    s.index := s.index + 1;
    s;
  end if;
end method consume;

define method lookahead (s :: <parse-string>) => answer :: <character?>;
  if (s.index >= size(s.string))
    #f;
  else
    s.string[s.index];
  end if;
end method lookahead;

define method parse-string-done? (s :: <parse-string>) => answer :: <boolean>;
  s.index >= s.string.size;
end method parse-string-done?;

