module: string-hacking
author: Nick Kramer (nkramer@cs.cmu.edu)
synopsis: Random functionality for working with strings
copyright:  Copyright (C) 1994, Carnegie Mellon University.
            All rights reserved.
rcs-header: $Header: /home/housel/work/rcs/gd/src/common/string-ext/string-hacking.dylan,v 1.1 1996/02/17 16:12:26 nkramer Exp $

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

// add has no useful guarenteed behavior on strings.
//
define method add-last (string :: <string>, character :: <character>) 
    => new-string :: <string>;
  concatenate(string, make(<string>, size: 1, fill: character));
end method add-last;

// Like character-- in C
//
define method predecessor (c :: <character>) => c2 :: <character>;
  as(<character>, as(<integer>, c) - 1);
end method predecessor;

// Like character++ in C
//
define method successor (c :: <character>) => c2 :: <character>;
  as(<character>, as(<integer>, c) + 1);
end method successor;

define method case-insensitive-equal (o1 :: <object>, o2 :: <object>)
 => answer :: <boolean>;
  #f;
end method case-insensitive-equal;

// This is useful for converting from uppercase to lowercase
//
define constant a-minus-A 
  = as(<integer>, 'a') - as(<integer>, 'A');

// Only works for ASCII and Unicode, and the case folding part works
// only for English.
//
// The idea is to do equality checks first, and only if they are
// somehow equal do further computation to see if the equality
// actually meant anything.
//
define method case-insensitive-equal (c1 :: <character>, c2 :: <character>)
 => answer :: <boolean>;
  c1 == c2
    | (as(<integer>, c1)
	  == as(<integer>, c2) + a-minus-A & uppercase?(c2))
    | (as(<integer>, c1) + a-minus-A
	 == as(<integer>, c2) & uppercase?(c1));
end method case-insensitive-equal;

define method case-insensitive-equal (s1 :: <string>, s2 :: <string>)
 => answer :: <boolean>;
  if (size(s1) ~= size(s2))
    #f;
  else
    block (return)
      for (c1 in s1, c2 in s2)
	if (~ case-insensitive-equal(c1, c2))
	  return(#f);
	end if;
      end for;
      #t;
    end block;
  end if;
end method case-insensitive-equal;

// -----------------------------------------------------------------

// The following two functions are not exported.

define method xor (value1 :: <object>, value2 :: <object>) 
 => answer :: <object>;
  if (value1)
    ~value2;
  else
    value2;
  end if;
end method xor;

// This does a "reverse curry".  It takes a function of one argument,
// and returns a function of two arguments that ignores the second
// argument.  Useful for making functions for remove!.
//
define method make-test (predicate? :: <function>) => tester :: <function>;
  method (value :: <object>, ignored :: <object>) => answer :: <boolean>;
    predicate?(value);
  end method;
end method make-test;

// -----------------------------------------------------------------

// Character-set: A reasonably efficient way of storing sets of
// characters.  Store byte characters in a vector of size 256, and
// keep the rest as sequences of ranges and single characters.
//
define sealed abstract class <character-set> (<collection>)
  slot byte-characters :: <byte-character-table>,
    init-function: method () make(<byte-character-table>) end;
  slot char-ranges :: <vector>;
               // sequence of begin-char/end-char pairs
  slot single-chars :: <unicode-string>;
               // Characters that aren't part of a range
  slot negated-set? :: <boolean>;
end class <character-set>;

// Uses = as a comparison
//
define class <case-sensitive-character-set> (<character-set>)
end class <case-sensitive-character-set>;

// Uses case-insensitive-equal as a comparison
//
define class <case-insensitive-character-set> (<character-set>)
end class <case-insensitive-character-set>;

define method key-test (set :: <case-sensitive-character-set>)
 => id :: <function>;
  \==;
end method key-test;

define method key-test (set :: <case-insensitive-character-set>)
 => case-insensitive-equal :: <function>;
  case-insensitive-equal;
end method key-test;

define method type-for-copy (set :: <character-set>) => cls :: <class>;
  <object-table>;
end method type-for-copy;

// Fills the byte-vector with #t's corresponding to byte characters in
// the ranges and single-chars.  Also converts ranges and single-chars
// to vectors and strings, respectively.  negated: is handled by
// an init-keyword.
//
define method initialize (set :: <character-set>,
			  #next next-method, 
			  #key description = "",
			  #all-keys)
 => false :: singleton(#f);
  next-method();
  let (ranges, chars, negated) = parse-description(description);
  set.negated-set? := negated;
  if (negated)
    // Add all byte characters to the vector, and we will delete the ones we
    // don't want.
    for (i from 0 below 256)
      // Was as(<byte-character>,...), which isn't supported
      set.byte-characters[as(<character>, i)] := #t;
    end for;
  end if;
    
  handle-single-chars!(set, chars);

  let unicode-ranges = #();
  for (range in ranges)
    let first = head(range);
    let last = tail(range);
    if (byte-character?(first) & byte-character?(last))
      for (c = first then successor(c), until: c > last)
	add-to-byte-vector!(set, c);
      end for;
    else 
      unicode-ranges := add!(unicode-ranges, range);
    end if;
  end for;
  set.char-ranges := as(<vector>, unicode-ranges);
  #f;
end method initialize;

// Not exported.  Turns the appropriate character or characters in the
// byte-vector to #t.
//
define method add-to-byte-vector!
    (set :: <case-sensitive-character-set>, char :: <byte-character>)
 => false :: singleton(#f);
  set.byte-characters[char] := ~set.negated-set?;
  #f;
end method add-to-byte-vector!;

define method add-to-byte-vector!
    (set :: <case-insensitive-character-set>, char :: <byte-character>)
 => false :: singleton(#f);
  set.byte-characters[as-lowercase(char)] := ~set.negated-set?;
  set.byte-characters[as-uppercase(char)] := ~set.negated-set?;
  #f;
end method add-to-byte-vector!;

define variable no-default = pair(#f, #f);

// Call member? to do real work.
//
define method element (set :: <character-set>, char :: <character>,
		       #key default = no-default)
 => char-or-f :: false-or(<character>);
  if (member?(char, set))
    char;
  elseif (default == no-default)
    error("Element %= not found", char);
  else
    default;
  end if;
end method element;

// test: is accepted but ignored.
//
define method member? (char :: <byte-character>, set :: <character-set>, 
		       #next next-method, #key test)
 => answer :: <boolean>;
  if (~test | test == key-test(set))
    in-byte-vector?(set, char);
  else
    next-method();
  end if;
end method member?;

// char is not a byte-character
//
define method member? (c :: <character>, set :: <character-set>,
		       #key test: ignored)
 => answer :: <boolean>;
  xor(in-single-chars?(c, set) | in-ranges?(c, set), set.negated-set?);
end method member?;

define method handle-single-chars! (set :: <character-set>, 
				    char-coll :: <collection>)
 => same-set :: <character-set>;
  let not-byte-chars = make(<unicode-string>, size: 0);
  for (c in char-coll)
    if (instance?(c, <byte-character>))
      add-to-byte-vector!(set, c);
    else
      not-byte-chars := add!(not-byte-chars, c);
    end if;
  end for;
  set.single-chars := not-byte-chars;
  set;
end method handle-single-chars!;

// Convert a character set string (without [ and ]) into a character set.
//
define method as (type == <character-set>, coll :: <collection>)
 => set :: <character-set>;
  error("Need to specify whether you want a <case-sensitive-character-set>"
	  " or a <case-insensitive-character-set>");
end method as;

define method as
    (type == <case-sensitive-character-set>, coll :: <collection>)
 => set :: <character-set>;
  let set = make(<case-sensitive-character-set>);
  handle-single-chars!(set, coll);
  set;
end method as;

define method as
    (type == <case-insensitive-character-set>, coll :: <collection>)
 => set :: <character-set>;
  let set = make(<case-insensitive-character-set>);
  handle-single-chars!(set, coll);
  set;
end method as;

// Not exported.
// Type is either <case-sensitive..> or <case-insensitive...>
//
define method parse-description (string :: <sequence>);
  let s = make(<parse-string>, string: string);
  let negated = (lookahead(s) == '^');
  if (negated)   consume(s)   end;

  let char-list  = #();
  let range-list = #();

  until (lookahead(s) = #f)         // until end of string
    let char = lookahead(s);
    consume(s);
    if (lookahead(s) = '-')
      consume(s);
      let second-char = lookahead(s);
      consume(s);
      range-list := add!(range-list, pair(char, second-char));
    elseif (char = '\\')
      let escaped-char = lookahead(s);
      consume(s);
      select (escaped-char by \=)
	'n' => char-list  := add!(char-list, '\n');    // newline
	't' => char-list  := add!(char-list, '\t');    // tab
	'f' => char-list  := add!(char-list, '\f');    // formfeed
	'r' => char-list  := add!(char-list, '\r');    // carriage return
	'b' => char-list  := add!(char-list, '\b');    // backspace

	'd' => range-list := add!(range-list, pair('0', '9'));  // digit-char

	'w' =>                                              // word-char
	  range-list := concatenate(range-list, list(pair('a', 'z'), 
						     pair('A', 'Z'), 
						     pair('0', '9')));
	  char-list := add!(char-list, '_');

	's' => char-list := concatenate(char-list, " \t\n\r\f");  // whitespace
	otherwise => char-list := add!(char-list, escaped-char);
      end select;
    else
      char-list := add!(char-list, char);
    end if;
  end until;
  values(range-list, char-list, negated);
end method parse-description;

// Not highly useful for a non-mutable class, but why bother erasing
// perfectly good code..
//
define method shallow-copy (set :: <character-set>) 
 => new-set :: <character-set>;
  let new-set = make(object-class(set));
  // Wish I had keyed-by
  let coll = set.byte-characters;
  let (state, limit, next, done?, cur-key, cur-elt)
    = forward-iteration-protocol(coll);
  for (st = state then next(coll, st), until: done?(coll, st, limit))
    let elt = cur-elt(coll, st);
    let key = cur-key(coll, st);
    new-set.byte-characters[key] := elt;
  end for;
  new-set.char-ranges := shallow-copy(set.char-ranges);
  new-set.single-chars := shallow-copy(set.single-chars);
  new-set.negated-set? := set.negated-set?;
  new-set;
end method shallow-copy;

// The following in-? functions are not exported, and ignore the
// negated? bit.
//
define method in-byte-vector? (set :: <character-set>, c :: <byte-character>)
 => answer :: <boolean>;
  set.byte-characters[c];
end method in-byte-vector?;

define method in-ranges? (c :: <character>, 
			  set :: <case-sensitive-character-set>)
 => answer :: <boolean>;
  block (return)
    for (range in set.char-ranges)
      if (c >= head(range) & c <= tail(range))
	return(#t);
      end if;
    end for;
    #f;
  end block;
end method in-ranges?;

define method in-ranges? (c :: <character>, 
			  set :: <case-insensitive-character-set>)
 => answer :: <boolean>;
  block (return)
    for (range in set.char-ranges)
      if (as-lowercase(c) >= head(range)
	    & as-lowercase(c) <= tail(range))
	return(#t);
      elseif (as-uppercase(c) >= head(range)
		& as-uppercase(c) <= tail(range))
	return(#t);
      end if;
    end for;
    #f;
  end block;  
end method in-ranges?;

define method in-single-chars? (set :: <case-sensitive-character-set>, 
				c :: <character>)
 => answer :: <boolean>;
  member?(c, set.single-chars, test: \==);
end method in-single-chars?;

define method in-single-chars? (set :: <case-insensitive-character-set>, 
				c :: <character>)
 => answer :: <boolean>;
  member?(c, set.single-chars, test: case-insensitive-equal);
end method in-single-chars?;

define constant $max-character = as(<character>, 65535);

// Plows through all possible characters, using member? to see if it's
// a valid key.
//
define method forward-iteration-protocol (set :: <character-set>)
 => (initial-state :: <object>, limit :: <object>, next-state :: <function>,
     finished-state? :: <function>, current-key :: <function>,
     current-element :: <function>, current-element-setter :: <function>,
     copy-state :: <function>);
  let limit
    = block (found-limit) 
	for (c = $max-character then predecessor(c),
	     until: c == as(<character>, 0))
	  if (member?(c, set))
	    found-limit(c);
	  end if;
	finally   // c is \000
	  if (member?(c, set))  c  else  #f  end;
	end for;
      end block;

  values(as(<character>, 0),    // init
	 limit,                 // limit

	 // next
	 method (set :: <character-set>, state :: <character>)
	  => next-state :: <character>;
	   for (c = state then successor(c), until: member?(c, set))
	   finally
	     c;
	   end for;
	 end method,
	 
	 // finished?
	 method (set :: <character-set>, state :: <character>, 
		 limit :: false-or(<character>))
	  => answer :: <boolean>;
	   ~limit | state == limit;
	 end method,

	 // key
	 method (set :: <character-set>, state :: <character>) 
	  => state :: <character>;
	   state;
	 end method,
	 
	 // element
	 method (set :: <character-set>, state :: <character>)
	  => state :: <character>;
	   state;
	 end method,

	 // element-setter
	 method (value, set :: <character-set>, state :: <character>) 
	  => state :: <character>;
	   error("Character sets are immutable");
	 end method,

	 // copy-state
	 method (set :: <character-set>, state :: <character>) 
	  => state :: <character>;
	   state;
	 end method);
end method forward-iteration-protocol;

// -----------------------------------------------------------------

// <byte-character-table> has nothing to do with a hashtable
// (<table>). It's really just a vector that uses byte-characters instead
// of integers as indices.
//
define class <byte-character-table> (<mutable-explicit-key-collection>)
  slot jump-vector :: <simple-object-vector>, 
    init-function: method () 
		     make(<simple-object-vector>, size: 256, fill: #f) 
		   end;
end class <byte-character-table>;

// This function doesn't believe in the concept of defaults.
// The parameter is there only to make the compiler happy.
//
define method element 
    (jt :: <byte-character-table>, key :: <character>,
     #key default: default = #f) 
 => elt :: <object>;
  jt.jump-vector [as(<integer>, key)];
end method element;

define method element-setter (value, jt :: <byte-character-table>, 
			      key :: <character>) => value :: <object>;
  jt.jump-vector [as(<integer>, key)] := value;
end method element-setter;

define method forward-iteration-protocol (jt :: <byte-character-table>)
 => (initial-state :: <object>, limit :: <object>, next-state :: <function>,
     finished-state? :: <function>, current-key :: <function>,
     current-element :: <function>, current-element-setter :: <function>,
     copy-state :: <function>);
  values(0, 256,        // init and limit
	 method (coll, state) state + 1 end,               // next-state
	 method (coll, state, limit) state >= limit end,   // finished-state?
	 method (coll, state) as(<character>, state) end,  // current-key
	 method (coll, state) jt.jump-vector[state] end,   // current-elt
	 method (value, coll, state) jt.jump-vector[state] := value end,
	                // Current-elt-setter
	 method (coll, state) state end);                  // copy-state
end method forward-iteration-protocol;
