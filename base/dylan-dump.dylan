module: dylan-dump
rcs-header: $Header: /home/housel/work/rcs/gd/src/d2c/compiler/base/dylan-dump.dylan,v 1.1 1995/10/09 22:26:11 ram Exp $
copyright: Copyright (c) 1994  Carnegie Mellon University
	   All rights reserved.

// This file contains ODF dumping and loading methods for various simple dylan
// values (integers, etc.)  Since most uses of ODF will want to build on these
// values, the loader methods are added to *default-dispatcher*.
//
// Currently supported classes:
//    <list>, <simple-object-vector>, <boolean>, <symbol>,
//    <byte-string>, <byte-character>, <integer>, <ratio>
//
// The <list> and <simple-object-vector> dumpers don't recognize sharing or
// circularity.


// Boolean methods:

define method dump-od(obj == #t, buf :: <dump-state>) => ();
  dump-definition-header($true-odf-id, buf);
end method;

add-od-loader(*default-dispatcher*, $true-odf-id, 
  method (state :: <load-state>)
   => res :: <boolean>;
    #t;
  end method
);

define method dump-od(obj == #f, buf :: <dump-state>) => ();
  dump-definition-header($false-odf-id, buf);
end method;

add-od-loader(*default-dispatcher*, $false-odf-id, 
  method (state :: <load-state>)
   => res :: <boolean>;
    #f;
  end method
);


// Fixed-integer methods:

define method dump-od(obj :: <fixed-integer>, buf :: <dump-state>)
 => ();
  dump-definition-header($fixed-integer-odf-id, buf, 
  			 raw-data: $odf-word-raw-data-format);
  dump-word(1, buf);
  dump-word(obj, buf);
end method;

define constant $e1 = as(<extended-integer>, 1);


// Sign-extend a word-integer.
//
define method sign-extend (val :: <integer>) => res :: <integer>;
  let val = as(<extended-integer>, val);
  if (logand(val, ash($e1, $word-bits - 1)) = 0)
    val;
  else
    logior(ash(-$e1, $word-bits), val);
  end;
end method;


// Load a signed fixed integer.
//
add-od-loader(*default-dispatcher*, $fixed-integer-odf-id, 
  method (state :: <load-state>)
   => res :: <fixed-integer>;
    state.od-next := state.od-next + $word-bytes; // skip count word
    let res =
      as(<fixed-integer>,
         sign-extend(buffer-word(state.od-buffer,
       			         fill-at-least($word-bytes, state))));
    state.od-next := state.od-next + $word-bytes; // skip data word
    res;
  end method
);


// Extended integer methods:

// Return the number of bits needed to represent N as a signed integer.
//
define method integer-length(n :: <integer>) => res :: <fixed-integer>;
  for (size from 1, x = abs(n) then ash(x, -1), until: zero?(x))
    finally size;
  end;
end method;

define constant $word-mask = lognot(ash(-$e1, $word-bits));

define method dump-od(obj :: <extended-integer>, buf :: <dump-state>)
 => ();
  dump-definition-header($extended-integer-odf-id, buf, 
  			 raw-data: $odf-word-raw-data-format);
  let len = ceiling/(integer-length(obj), $word-bits);
  dump-word(len, buf);
  for (i from 0 below len, x = obj then ash(x, - $word-bits))
    dump-word(logand(x, $word-mask), buf);
  end;
end method;

add-od-loader(*default-dispatcher*, $extended-integer-odf-id, 
  method (state :: <load-state>)
   => res :: <extended-integer>;
    let buffer = state.od-buffer;
    let next = state.od-next;
    let len = buffer-word(buffer, next); // count word
    let bsize = $word-bytes * len;
    state.od-next := next + $word-bytes;

    let next = fill-at-least(bsize, state);
    let res
      = sign-extend(buffer-word(buffer, next + ((len - 1) * $word-bytes)));

    for (i from len - 2 to 0 by -1)
      res := logior(buffer-word(buffer, (i * $word-bytes) + next),
                    ash(res, $word-bits));
    end for;

    state.od-next := next + bsize;
    res;
  end method
);


// Ratio methods:

define method dump-od(obj :: <ratio>, buf :: <dump-state>) => ();
  let start-posn = buf.current-pos;
  dump-definition-header($ratio-odf-id, buf, subobjects: #t);
  dump-od(obj.numerator, buf);
  dump-od(obj.denominator, buf);
  dump-end-entry(start-posn, buf);
end method;

add-od-loader(*default-dispatcher*, $ratio-odf-id, 
  method (state :: <load-state>) => res :: <ratio>;
    
    let npart = load-object-dispatch(state);
    let dpart = load-object-dispatch(state);
    assert(load-object-dispatch(state) == $end-object);
    ratio(npart, dpart);
  end method
);


// Byte-string methods:

// <dump-buffer> for extern-handle dumping.  
// ### Too bad about EQness.
// 
define method dump-od(obj :: <byte-string>, buf :: <dump-buffer>) => ();
  dump-definition-header($byte-string-odf-id, buf,
  			 raw-data: $odf-byte-raw-data-format);
  dump-raw-data(obj, obj.size, buf);
end method;

add-od-loader(*default-dispatcher*, $byte-string-odf-id, 
  method (state :: <load-state>)
   => res :: <byte-string>;
    let next = state.od-next;
    let bsize = buffer-word(state.od-buffer, next);
    state.od-next := next + $word-bytes;
    let res = make(<byte-string>, size: bsize);
    load-raw-data(res, bsize, state);
    res;
  end method
);


// Symbol methods:

// This method works on <dump-buffer> because we need it for extern-handle
// dumping.  This is o.k., because symbol semantics preserve EQ'ness.
//
define method dump-od(obj :: <symbol>, buf :: <dump-buffer>) => ();
  dump-definition-header($byte-symbol-odf-id, buf,
  			 raw-data: $odf-byte-raw-data-format);
  let lval = as(<byte-string>, obj);
  dump-raw-data(lval, lval.size, buf);
end method;

add-od-loader(*default-dispatcher*, $byte-symbol-odf-id, 
  method (state :: <load-state>) => res :: <symbol>;
    let next = state.od-next;
    let bsize = buffer-word(state.od-buffer, next);
    state.od-next := state.od-next + $word-bytes;
    let res = make(<byte-string>, size: bsize);
    load-raw-data(res, bsize, state);
    as(<symbol>, res);
  end method
);


// Character methods:
//
// We load/dump like a one-char string so we can reuse the mechanism.

define method dump-od(obj :: <byte-character>, buf :: <dump-state>)
 => ();
  dump-definition-header($byte-character-odf-id, buf,
  			 raw-data: $odf-byte-raw-data-format);
  let lval = make(<byte-string>, size: 1, fill: obj);
  dump-raw-data(lval, 1, buf);
end method;

add-od-loader(*default-dispatcher*, $byte-character-odf-id, 
  method (state :: <load-state>) => res :: <byte-character>;
    let res = make(<byte-string>, size: 1);
    state.od-next := state.od-next + $word-bytes; // skip count
    load-raw-data(res, 1, state);
    res[0];
  end method
);


// List methods:

// To dump a list, figure out if it is improper (so we know whether to use list
// or list*), then recurse on elements.
//
define method dump-od(obj :: <list>, buf :: <dump-state>) => ();
  let improper
    = for (el = obj then el.tail, 
    	   while: instance?(el, <pair>))
	finally if (el == #()) #f else el end;
      end for;
 
  let start-pos = buf.current-pos;
  dump-definition-header(if (improper) $list*-odf-id else $list-odf-id end,
  		 	 buf, subobjects: #t);
  
  for (el = obj then el.tail, while: instance?(el, <pair>))
    dump-od(el.head, buf);
  end;

  if (improper)
    dump-od(improper, buf);
  end;
  
  dump-end-entry(start-pos, buf);

end method;


// To load a list, get the subobjects and convert to a list.
//
add-od-loader(*default-dispatcher*, $list-odf-id, 
  method (state :: <load-state>) => res :: <list>;
    as(<list>, load-subobjects-vector(state));
  end method
);


// To load an improper list, get subobjects and build list in reverse order,
// starting with tail.
//
add-od-loader(*default-dispatcher*, $list*-odf-id, 
  method (state :: <load-state>) => res :: <list>;
    let contents = load-subobjects-vector(state);
    let last-idx = contents.size - 1;
    for (i from last-idx - 1 to 0, 
         res = contents[last-idx] then pair(contents[i], res))
      finally res;
    end;
  end method
);



// Vector methods:

// To dump a vector, we just recursively dump the entire contents.
//
define method dump-od
  (obj :: <simple-object-vector>, buf :: <dump-state>)
 => ();
  let start-pos = buf.current-pos;
  dump-definition-header($simple-object-vector-odf-id, buf, subobjects: #t);
  for (el in obj)
    dump-od(el, buf);
  end;
  dump-end-entry(start-pos, buf);
end method;


// Get subobjects and convert to a simple object vector.
//
add-od-loader(*default-dispatcher*, $simple-object-vector-odf-id, 
  method (state :: <load-state>) => res :: <simple-object-vector>;
    as(<simple-object-vector>, load-subobjects-vector(state));
  end method
);
