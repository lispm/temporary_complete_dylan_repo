module: compile-time-values
rcs-header: $Header: /home/housel/work/rcs/gd/src/d2c/compiler/base/ctv.dylan,v 1.8 1995/05/29 20:57:58 wlott Exp $
copyright: Copyright (c) 1994  Carnegie Mellon University
	   All rights reserved.

define abstract class <ct-value> (<object>)
end;

define abstract class <literal> (<ct-value>)
end;

define abstract class <eql-ct-value> (<ct-value>)
  slot ct-value-singleton :: union(<false>, <ctype>),
    init-value: #f;
end;

define abstract class <eql-literal> (<literal>, <eql-ct-value>)
end;


// Literal booleans.

define abstract class <literal-boolean> (<eql-literal>) end;
define class <literal-true> (<literal-boolean>) end;
define class <literal-false> (<literal-boolean>) end;

define variable *literal-true* = #f;
define variable *literal-false* = #f;

define method make (wot == <literal-true>, #next next-method, #key)
  *literal-true* | (*literal-true* := next-method());
end;

define method make (wot == <literal-false>, #next next-method, #key)
  *literal-false* | (*literal-false* := next-method());
end;

define method as (class == <ct-value>, thing == #t) => res :: <literal-true>;
  make(<literal-true>);
end;

define method as (class == <ct-value>, thing == #f) => res :: <literal-false>;
  make(<literal-false>);
end;

define method print-object (lit :: <literal-true>, stream :: <stream>) => ();
  write("{literal #t}", stream);
end;

define method print-object (lit :: <literal-false>, stream :: <stream>) => ();
  write("{literal #f}", stream);
end;

define method print-message (lit :: <literal-true>, stream :: <stream>) => ();
  write("#t", stream);
end;

define method print-message (lit :: <literal-false>, stream :: <stream>) => ();
  write("#f", stream);
end;

define method \= (x :: <true>, y :: <literal-true>) => res :: <boolean>;
  #t;
end;
    
define method \= (x :: <literal-true>, y :: <true>) => res :: <boolean>;
  #t;
end;
    
define method \= (x :: <false>, y :: <literal-false>) => res :: <boolean>;
  #t;
end;
    
define method \= (x :: <literal-false>, y :: <false>) => res :: <boolean>;
  #t;
end;


// Literal numbers.

define abstract class <literal-number> (<eql-literal>)
  slot literal-value :: <number>, required-init-keyword: value:;
end;

define method \= (x :: <number>, y :: <literal-number>) => res :: <boolean>;
  x = y.literal-value;
end;

define method \= (x :: <literal-number>, y :: <number>) => res :: <boolean>;
  x.literal-value = y;
end;

define method \~= (x :: <number>, y :: <literal-number>) => res :: <boolean>;
  x ~= y.literal-value;
end;

define method \~= (x :: <literal-number>, y :: <number>) => res :: <boolean>;
  x.literal-value ~= y;
end;

define method \< (x :: <number>, y :: <literal-number>) => res :: <boolean>;
  x < y.literal-value;
end;

define method \< (x :: <literal-number>, y :: <number>) => res :: <boolean>;
  x.literal-value < y;
end;

define method \<= (x :: <number>, y :: <literal-number>) => res :: <boolean>;
  x <= y.literal-value;
end;

define method \<= (x :: <literal-number>, y :: <number>) => res :: <boolean>;
  x.literal-value <= y;
end;

define abstract class <literal-real> (<literal-number>) end;
define abstract class <literal-rational> (<literal-real>) end;
define abstract class <literal-integer> (<literal-rational>) end;
define class <literal-fixed-integer> (<literal-integer>) end;
define class <literal-extended-integer> (<literal-integer>) end;
define class <literal-ratio> (<literal-rational>) end;
define abstract class <literal-float> (<literal-real>) end;
define class <literal-single-float> (<literal-float>) end;
define class <literal-double-float> (<literal-float>) end;
define class <literal-extended-float> (<literal-float>) end;
				       
define constant $literal-fixed-integer-memo = make(<table>);
define constant $literal-extended-integer-memo = make(<table>);
define constant $literal-ratio-memo = make(<table>);
define constant $literal-single-float-memo = make(<table>);
define constant $literal-double-float-memo = make(<table>);
define constant $literal-extended-float-memo = make(<table>);

define method make (class == <literal-fixed-integer>, #next next-method,
		    #key value)
  element($literal-fixed-integer-memo, value, default: #f)
    | (element($literal-fixed-integer-memo, value) := next-method());
end;

define method make (class == <literal-extended-integer>, #next next-method,
		    #key value)
  element($literal-extended-integer-memo, value, default: #f)
    | (element($literal-extended-integer-memo, value) := next-method());
end;

define method make (class == <literal-ratio>, #next next-method, #key value)
  element($literal-ratio-memo, value, default: #f)
    | (element($literal-ratio-memo, value) := next-method());
end;

define method make (class == <literal-single-float>, #next next-method,
		    #key value)
  element($literal-single-float-memo, value, default: #f)
    | (element($literal-single-float-memo, value) := next-method());
end;

define method make (class == <literal-double-float>, #next next-method,
		    #key value)
  element($literal-double-float-memo, value, default: #f)
    | (element($literal-double-float-memo, value) := next-method());
end;

define method make (class == <literal-extended-float>, #next next-method,
		    #key value)
  element($literal-extended-float-memo, value, default: #f)
    | (element($literal-extended-float-memo, value) := next-method());
end;

define method print-object (lit :: <literal-fixed-integer>, stream :: <stream>)
    => ();
  format(stream, "{literal fixed-integer %d}", lit.literal-value);
end;

define method print-message
    (lit :: <literal-fixed-integer>, stream :: <stream>)
    => ();
  format(stream, "%d", lit.literal-value);
end;

define method print-object
    (lit :: <literal-extended-integer>, stream :: <stream>)
    => ();
  format(stream, "{literal extended-integer %d}", lit.literal-value);
end;

define method print-message
    (lit :: <literal-extended-integer>, stream :: <stream>)
    => ();
  format(stream, "#e%d", lit.literal-value);
end;

define method print-object (lit :: <literal-ratio>, stream :: <stream>) => ();
  format(stream, "{literal ratio %=}", lit.literal-value);
end;

define method print-message (lit :: <literal-ratio>, stream :: <stream>)
    => ();
  format(stream, "%=", as(<ratio>, lit.literal-value));
end;

define method print-object (lit :: <literal-single-float>, stream :: <stream>)
    => ();
  format(stream, "{literal single-float %=}",
	 as(<single-float>, lit.literal-value));
end;

define method print-message (lit :: <literal-single-float>, stream :: <stream>)
    => ();
  format(stream, "%=", as(<single-float>, lit.literal-value));
end;

define method print-object (lit :: <literal-double-float>, stream :: <stream>)
    => ();
  format(stream, "{literal double-float %=}",
	 as(<double-float>, lit.literal-value));
end;

define method print-message (lit :: <literal-double-float>, stream :: <stream>)
    => ();
  format(stream, "%=", as(<double-float>, lit.literal-value));
end;

define method print-object (lit :: <literal-extended-float>,
			    stream :: <stream>)
    => ();
  format(stream, "{literal extended-float %=}",
	 as(<extended-float>, lit.literal-value));
end;

define method print-message
    (lit :: <literal-extended-float>, stream :: <stream>)
    => ();
  format(stream, "%=", as(<extended-float>, lit.literal-value));
end;

define method as (class == <ct-value>, value :: <fixed-integer>)
  make(<literal-fixed-integer>, value: value);
end;

define method as (class == <ct-value>, value :: <extended-integer>)
  make(<literal-extended-integer>, value: value);
end;

define method as (class == <ct-value>, value :: <ratio>)
  make(<literal-ratio>, value: value);
end;

define method as (class == <ct-value>, value :: <single-float>)
  make(<literal-single-float>, value: value);
end;

define method as (class == <ct-value>, value :: <double-float>)
  make(<literal-double-float>, value: value);
end;

define method as (class == <ct-value>, value :: <extended-float>)
  make(<literal-extended-float>, value: value);
end;


// Literal symbols.

define class <literal-symbol> (<literal>)
  slot literal-value :: <symbol>, required-init-keyword: value:;
end;

define constant $literal-symbol-memo = make(<table>);

define method make (class == <literal-symbol>, #next next-method, #key value)
  element($literal-symbol-memo, value, default: #f)
    | (element($literal-symbol-memo, value) := next-method());
end;

define method print-object (lit :: <literal-symbol>, stream :: <stream>)
    => ();
  format(stream, "{literal symbol %=}", lit.literal-value);
end;

define method print-message (lit :: <literal-symbol>, stream :: <stream>)
    => ();
  print(lit.literal-value, stream);
end;

define method as (class == <ct-value>, sym :: <symbol>)
  make(<literal-symbol>, value: sym);
end;

define method \= (x :: <symbol>, y :: <literal-symbol>) => res :: <boolean>;
  x = y.literal-value;
end;

define method \= (x :: <literal-symbol>, y :: <symbol>) => res :: <boolean>;
  x.literal-value = y;
end;


// Literal characters.

define class <literal-character> (<literal>)
  slot literal-value :: <character>, required-init-keyword: value:;
end;

define constant $literal-character-memo = make(<table>);

define method make (class == <literal-character>, #next next-method,
		    #key value)
  element($literal-character-memo, value, default: #f)
    | (element($literal-character-memo, value) := next-method());
end;

define method print-object (lit :: <literal-character>, stream :: <stream>)
    => ();
  format(stream, "{literal character %=}", lit.literal-value);
end;

define method print-message (lit :: <literal-character>, stream :: <stream>)
    => ();
  print(lit.literal-value, stream);
end;

define method as (class == <ct-value>, char :: <character>)
  make(<literal-character>, value: char);
end;

define method \= (x :: <character>, y :: <literal-character>)
    => res :: <boolean>;
  x = y.literal-value;
end;

define method \= (x :: <literal-character>, y :: <character>)
    => res :: <boolean>;
  x.literal-value = y;
end;

define method \< (x :: <character>, y :: <literal-character>)
    => res :: <boolean>;
  x < y.literal-value;
end;

define method \< (x :: <literal-character>, y :: <character>)
    => res :: <boolean>;
  x.literal-value < y;
end;


// Literal sequences.

define abstract class <literal-sequence> (<literal>)
end;

define abstract class <literal-list> (<literal-sequence>)
end;

define method make (class == <literal-list>, #next next-method,
		    #key sharable: sharable?, contents, tail)
  local
    method repeat (index)
      if (index == contents.size)
	tail | make(<literal-empty-list>);
      else
	make(<literal-pair>,
	     sharable: sharable?,
	     head: contents[index],
	     tail: repeat(index + 1));
      end;
    end;
  repeat(0);
end;

define class <literal-pair> (<literal-list>)
  slot literal-head :: <ct-value>, required-init-keyword: head:;
  slot literal-tail :: <ct-value>, required-init-keyword: tail:;
end;

define class <literal-pair-memo-table> (<table>)
end;

define method table-protocol (table :: <literal-pair-memo-table>)
    => (tester :: <function>, hasher :: <function>);
  values(method (key1, key2) => res :: <boolean>;
	   key1.head == key2.head
	     & key1.tail == key2.tail;
	 end,
	 method (key) => (id :: <fixed-integer>, state);
	   let (head-id, head-state) = object-hash(key.head);
	   let (tail-id, tail-state) = object-hash(key.tail);
	   merge-hash-codes(head-id, head-state, tail-id, tail-state,
			    ordered: #t);
	 end);
end;

define constant $literal-pair-memo = make(<literal-pair-memo-table>);

define method make (class == <literal-pair>, #next next-method,
		    #key sharable: sharable?, head, tail)
  if (sharable?)
    let key = pair(head, tail);
    element($literal-pair-memo, key, default: #f)
      | (element($literal-pair-memo, key) := next-method());
  else
    next-method();
  end;
end;

define method initialize (lit :: <literal-pair>, #key sharable) => ();
end;

define method print-message (lit :: <literal-pair>, stream :: <stream>) => ();
  write("{a <pair>}", stream);
end;

define method as (class == <ct-value>, thing :: <pair>)
  make(<literal-pair>,
       sharable: #t,
       head: as(<ct-value>, thing.head),
       tail: as(<ct-value>, thing.tail));
end;

define class <literal-empty-list> (<literal-list>, <eql-literal>)
end;

define variable *literal-empty-list* = #f;

define method make (class == <literal-empty-list>, #next next-method, #key)
  *literal-empty-list* | (*literal-empty-list* := next-method());
end;

define method print-message (lit :: <literal-empty-list>, stream :: <stream>)
    => ();
  write("#()", stream);
end;

define method as (class == <ct-value>, thing :: <empty-list>)
  make(<literal-empty-list>);
end;

define method literal-head (empty-list :: <literal-empty-list>)
    => res :: <literal-empty-list>;
  empty-list;
end;

define method literal-tail (empty-list :: <literal-empty-list>)
    => res :: <literal-empty-list>;
  empty-list;
end;

define method \= (x :: <empty-list>, y :: <literal-empty-list>)
    => res :: <boolean>;
  #t;
end;

define method \= (x :: <literal-empty-list>, y :: <empty-list>)
    => res :: <boolean>;
  #t;
end;


define abstract class <literal-vector> (<literal-sequence>)
end;

define class <literal-simple-object-vector> (<literal-vector>)
  slot literal-contents :: <simple-object-vector>,
    required-init-keyword: contents:;
end;

define constant $literal-vector-memo = make(<equal-table>);

define method make (class == <literal-simple-object-vector>, #next next-method,
		    #key sharable: sharable?, contents)
  do(rcurry(check-type, <ct-value>), contents);
  let contents = as(<simple-object-vector>, contents);
  if (sharable?)
    element($literal-vector-memo, contents, default: #f)
      | (element($literal-vector-memo, contents) :=
	   next-method(class, contents: contents));
  else
    next-method(class, contents: contents);
  end;
end;

define method initialize (lit :: <literal-simple-object-vector>, #key sharable)
    => ();
end;

define method print-message
    (lit :: <literal-simple-object-vector>, stream :: <stream>) => ();
  write("{a <simple-object-vector>}", stream);
end;

define method as (class == <ct-value>, vec :: <simple-object-vector>)
  make(<literal-simple-object-vector>,
       sharable: #t,
       contents: map(curry(as, <ct-value>), vec));
end;

define class <literal-string> (<literal-vector>)
  slot literal-value :: <byte-string>, required-init-keyword: value:;
end;

define constant $literal-string-memo = make(<string-table>);

define method make (class == <literal-string>, #next next-method,
		    #key value)
  element($literal-string-memo, value, default: #f)
    | (element($literal-string-memo, value) := next-method());
end;

define method print-object (lit :: <literal-string>, stream :: <stream>)
    => ();
  format(stream, "{literal string %=}", lit.literal-value);
end;

define method print-message (lit :: <literal-string>, stream :: <stream>)
    => ();
  print(lit.literal-value, stream);
end;

define method as (class == <ct-value>, string :: <byte-string>)
  make(<literal-string>, value: string);
end;

define method concatenate (str1 :: <literal-string>, #rest more)
    => res :: <literal-string>;
  make(<literal-string>,
       value: apply(concatenate,
		    str1.literal-value,
		    map(literal-value, more)));
end;
