copyright: see below
module: dylan-viscera

//======================================================================
//
// Copyright (c) 1995, 1996, 1997  Carnegie Mellon University
// Copyright (c) 1998, 1999, 2000  Gwydion Dylan Maintainers
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
//    University, and the Gwydion Dylan Maintainers.
// 
// This software is made available "as is".  Neither the authors nor
// Carnegie Mellon University make any warranty about the software,
// its performance, or its conformity to any specification.
// 
// Bug reports should be sent to <gd-bugs@gwydiondylan.org>; questions,
// comments and suggestions are welcome at <gd-hackers@gwydiondylan.org>.
// Also, see http://www.gwydiondylan.org/ for updates and documentation. 
//
//======================================================================

// Stretchy-vectors
//
// Seals for most collection operations on the built-in collections can be
// found in seals.dylan.  Some exceptions apply, such as "make" and "as".
// See seals.dylan for more info.
//


// <stretchy-vector>

define open abstract primary class <stretchy-vector>
    (<stretchy-sequence>, <vector>)
end class <stretchy-vector>;

define open abstract class <builtin-stretchy-vector>
    (<stretchy-vector>)
  //
  // The current size of the stretchy vector.
  sealed slot ssv-current-size :: <integer> = 0;
end class <builtin-stretchy-vector>;

define open generic ssv-data (sv :: <builtin-stretchy-vector>);

define open generic ssv-data-setter
    (value :: <object>, sv :: <builtin-stretchy-vector>);

define sealed inline method make
    (class == <stretchy-vector>, #key size :: <integer> = 0, fill = #f)
    => res :: <stretchy-object-vector>;
  make(<stretchy-object-vector>, size: size, fill: fill);
end method;

define sealed inline method size (ssv :: <builtin-stretchy-vector>)
    => size :: <integer>;
  ssv.ssv-current-size;
end method size;


// <stretchy-object-vector>

// Invariants:
//   1. ssv-current-size <= ssv-data.size
//   2. elements [ssv-current-size..ssv-data.size] are always set to #f.  
//      Any method reducing ssv-current-size must set the elements of
//      the unused data area to #f.
//   3. Elements [0..ssv-current-size] contain user supplied data.
//
define sealed class <stretchy-object-vector> (<builtin-stretchy-vector>)
  //
  // A <simple-object-vector> holding the vector elements.  Obviously
  // at least as long as the stretchy vector.
  sealed slot ssv-data :: <simple-object-vector> = #[];
end class <stretchy-object-vector>;

define sealed domain make(singleton(<stretchy-object-vector>));

define constant $default-initial-ssv-capacity = 4;

// Returns an appropriate size for the new ssv data vector
define function calc-size (needed-size :: <integer>)
 => new-data-size :: <integer>;
  if (needed-size < 0)
    error("size: can't be negative.");
  end;
  for (new-data-size = $default-initial-ssv-capacity then new-data-size * 2,
       until: new-data-size >= needed-size)
  finally
    // earlier code considered doubling to be too wastefull for large
    // vectors and increased by no more than 1024 elements, but if you
    // don't increase it geometrically you lose the important property
    // of O(N) amortised time.  So we now take two steps to double...
    //
    let three-quarters = new-data-size - ash(new-data-size, -2);
    if (needed-size < three-quarters)
      three-quarters
    else
      new-data-size
    end;
  end for;
end calc-size;

define sealed method initialize
    (object :: <stretchy-object-vector>, #key size :: <integer> = 0, fill = #f)
 => ();
  let data-size = calc-size(size);

  // The "fill:" keyword assures that elements above ssv-current-size
  // will be #f...
  let data = make(<simple-object-vector>, size: data-size, fill: #f);

  // ...and then we manually fill the other elements if necessary.
  if (fill) fill!(data, fill, end: size) end if;
  object.ssv-data := data;
  object.ssv-current-size := size;
end method initialize;

define method size-setter
    (new-size :: <integer>, ssv :: <stretchy-object-vector>)
    => new-size :: <integer>;
  let current-size = ssv.size;
  let data = ssv.ssv-data;
  if (new-size > current-size)
    let current-data-size = data.size;
    if (new-size > current-data-size)
      let new-data-size = calc-size(new-size);
      let new-data = make(<simple-object-vector>, size: new-data-size);
      // Only copy the used region of the old data vector to the new data vector
      for (index :: <integer> from 0 below current-size)
        %element(new-data, index) := %element(data, index);
      end for;
      ssv.ssv-data := new-data;
    end if;
  else
    fill!(data, #f, start: new-size, end: current-size);
  end if;
  ssv.ssv-current-size := new-size;
end method size-setter;


define sealed inline method element
    (ssv :: <stretchy-object-vector>, key :: <integer>,
     #key default = $not-supplied)
    => result :: <object>;
  case
    (key >= 0 & key < ssv.size) =>
      // Warning: unchecked reference.  However, if we're *sure* we
      // satisfy the invariants, we're be safe.
      %element(ssv.ssv-data, key);
    (default == $not-supplied) =>
      element-error(ssv, key);
    otherwise =>
      default;
  end case;
end method element;

define sealed inline method element-setter
    (value, ssv :: <stretchy-object-vector>, key :: <integer>)
    => value :: <object>;
  if (key < 0)
    element-error(ssv, key);
  else
    if (key >= ssv.size)
      ssv.size := key + 1;
    end if;
    // Warning: unchecked reference.  However, if we're *sure* we
    // satisfy the invariants, we're be safe.
    %element(ssv.ssv-data, key) := value;
  end if;
end method element-setter;

define inline method %element
    (v :: <stretchy-object-vector>,
     i :: <integer>)
 => (obj :: <object>);
  %element(v.ssv-data, i);
end;

define inline method %element-setter
    (new-value :: <object>,
     v :: <stretchy-object-vector>,
     i :: <integer>)
 => (new-value :: <object>);
  %element(v.ssv-data, i) := new-value;
end;

// This method is identical to the one in "array.dylan", except that it
// is more tightly specialized to a single sealed class.  If you need to 
// make a general change, you should probably grep for "outlined-iterator" 
// and change all matching locations.
//
define inline method forward-iteration-protocol
    (array :: <stretchy-object-vector>)
    => (initial-state :: <integer>,
	limit :: <integer>,
	next-state :: <function>,
	finished-state? :: <function>,
	current-key :: <function>,
	current-element :: <function>,
	current-element-setter :: <function>,
	copy-state :: <function>);
  values(0,
	 array.size,
	 method (array :: <stretchy-object-vector>, state :: <integer>)
	     => new-state :: <integer>;
	   state + 1;
	 end,
	 method (array :: <stretchy-object-vector>, state :: <integer>,
		 limit :: <integer>)
	     => done? :: <boolean>;
	   // We use >= instead of == so that the constraint propagation
	   // stuff can tell that state is < limit if this returns #f.
	   state >= limit;
	 end,
	 method (array :: <stretchy-object-vector>, state :: <integer>)
	     => key :: <integer>;
	   state;
	 end,
	 method (array :: <stretchy-object-vector>, state :: <integer>)
	     => element :: <object>;
	   element(array, state);
	 end,
	 method (new-value :: <object>, array :: <stretchy-object-vector>,
		 state :: <integer>)
	     => new-value :: <object>;
	   element(array, state) := new-value;
	 end,
	 method (array :: <stretchy-object-vector>, state :: <integer>)
	     => state-copy :: <integer>;
	   state;
	 end);
end;

define inline method empty? (ssv :: <stretchy-object-vector>)
 => res :: <boolean>;
  ssv.size == 0;
end method;

define method add! (ssv :: <stretchy-object-vector>, new-element)
    => ssv :: <stretchy-object-vector>;
  let data = ssv.ssv-data;
  let current-size = ssv.size;
  if (current-size == data.size)
    let new-data-size = current-size * 2;
    let new-data = make(<simple-object-vector>, size: new-data-size);
    // simce the old data vector is full copy all of it to the new data vector
    for (elt keyed-by index in data)
      %element(new-data, index) := elt; 
    end;
    ssv.ssv-data := new-data;
    %element(new-data, current-size) := new-element;
  else
    %element(data, current-size) := new-element;
  end if;
  ssv.ssv-current-size := current-size + 1;
  ssv;
end method add!;

// This method has not been optimized yet by changing element to 
// %element.
define method remove! (ssv :: <stretchy-object-vector>, elem,
                       #key test :: <function> = \==,
		            count :: false-or(<integer>))
    => ssv :: <stretchy-object-vector>;
  unless (count & (count <= 0))
    let data = ssv.ssv-data;
    let sz = ssv.size;
    local
      method copy (src :: <integer>, dst :: <integer>,
		   deleted :: <integer>)
	  => ();
	case
	  src == sz =>
	    ssv.ssv-current-size := sz - deleted;
	  otherwise =>
	    data[dst] := data[src];
	    copy(src + 1, dst + 1, deleted);
	end case;
      end method copy,
      method search-and-copy (src :: <integer>, dst :: <integer>,
			      deleted :: <integer>)
	  => ();
	if (src == sz)
	  ssv.ssv-current-size := sz - deleted;
	else 
	  let this-element = data[src];
	  case
	    test(this-element, elem) =>
	      let deleted = deleted + 1;
	      if (count & (deleted == count))
		copy(src + 1, dst, deleted);
	      else
		search-and-copy(src + 1, dst, deleted);
	      end if;
	    otherwise =>
	      data[dst] := data[src];
	      search-and-copy(src + 1, dst + 1, deleted);
	  end case;
	end if;
      end method search-and-copy,
      method search (src :: <integer>) => ();
	unless (src == sz)
	  let this-element = data[src];
	  if (test(this-element, elem))
	    if (count & (count == 1))
	      copy(src + 1, src, 1);
	    else 
	      search-and-copy(src + 1, src, 1);
	    end if;
	  else
	    search(src + 1);
	  end if;
	end unless;
      end method search;
    search(0);
    fill!(data, #f, start: ssv.size, end: sz);
  end unless;
  ssv;
end method remove!;

define sealed method concatenate!
    (ssv :: <stretchy-object-vector>, #rest more-sequences)
 => (ssv :: <stretchy-object-vector>)
  let current-size = ssv.size;

  let needed-size
    = for (sequence in more-sequences,
          needed-size = current-size then needed-size + sequence.size)
      finally
        needed-size;
      end;
    
  if (needed-size >= ssv.ssv-data.size)
    let data = ssv.ssv-data;
    let new-data-size = calc-size(needed-size);
    let new-data = make(<simple-object-vector>, size: new-data-size);
    // Only copy the used region of the old data vector to the new data vector
    for (index :: <integer> from 0 below current-size)
      %element(new-data, index) := %element(data, index);
    end for;
    ssv.ssv-data := new-data;
  end if;

  // We won't blindly trust that size(collection) returns a 
  // value consistent with the forward-iteration-protocol for 
  // the collections so let's be sure not to iterate past needed-size.
  // (It's possible that a user-implemented collection class 
  // could be incorrect.)
  let data = ssv.ssv-data;
  for (sequence in more-sequences,
      outer-index = current-size
        then for (index from outer-index below needed-size, elt in sequence)
               %element(data, index) := elt;
             finally
               index;
             end)
  end;
  
  ssv.ssv-current-size := needed-size;
  ssv;
end method concatenate!;

define sealed method as
    (class == <stretchy-vector>, collection :: <collection>)
 => (res :: <stretchy-object-vector>);
  // We won't blindly trust that size(collection) returns a 
  // value consistent with the forward-iteration-protocol for 
  // the collection so let's be sure not to iterate past sz.
  // (It's possible that a user-implemented collection class 
  // could be incorrect.)
  // Also don't used the key-by clause here because it may be
  // slow for collection.
  let sz = collection.size;
  let res = make(<stretchy-object-vector>, size: sz);
  for (index :: <integer> from 0 below sz, elt in collection)
    %element(res, index) := elt;
  end;
  res;
end;

define inline method as
    (class == <stretchy-vector>, vector :: <stretchy-vector>)
 => (res :: <stretchy-vector>);
  vector;
end;

// Not strictly necessary, but produces slightly more optimal code
//
define inline method type-for-copy (object :: <stretchy-object-vector>)
 => (class :: <class>)
  <stretchy-object-vector>;
end;

define method map-into (destination :: <stretchy-object-vector>,
			proc :: <function>, sequence :: <sequence>,
			#next next-method, #rest more-sequences)
    => res :: <stretchy-vector>;
  if (empty?(more-sequences))
    let sz = size(sequence);
    if (sz == #f)
      error("Cannot map unbounded sequences into stretchy-vectors.");
    elseif (sz > size(destination))
      size(destination) := sz
    end if;
    // We won't blindly trust that size(collection) returns a 
    // value consistent with the forward-iteration-protocol for 
    // the collection so let's be sure not to iterate past sz.
    // (It's possible that a user-implemented collection class 
    // could be incorrect.)
    // Also don't used the keyed-by clause here because it may be
    // slow for collection.
    let data = ssv-data(destination);
    for (key :: <integer> from 0 below sz, elt in sequence)
      %element(data, key) := proc(elt);
    end for;
    destination;
  else
    next-method();
  end if;
end method map-into;



define open abstract class <limited-stretchy-vector>
    (<builtin-stretchy-vector>)
end class <limited-stretchy-vector>;

define open generic lsv-data-type (sv :: <limited-stretchy-vector>)
 => (result :: <class>);

define open generic lsv-fill (sv :: <limited-stretchy-vector>)
 => (result :: <object>);

define macro limited-sv-class
  { limited-sv-class(?:name, ?element-type:expression, ?fill:expression,
		     ?compname:name) }
    => { begin
	   define limited-collection ?compname (<vector>)
             of ?element-type = ?fill;
	   define sealed class ?name (<limited-stretchy-vector>)
	     // We can't trivially initialize this to a vector, so we pay a
	     // penalty at runtime.  Bother.
	     sealed slot ssv-data :: false-or(?compname) = #f;
	   end class ?name;
           define sealed domain make(singleton(?name));
           define sealed inline method lsv-data-type (sv :: ?name)
	    => result :: <class>;
	     ?compname;
	   end method lsv-data-type;
           define sealed inline method lsv-fill (sv :: ?name)
	    => result :: <object>;
	     ?fill;
	   end method lsv-fill;
	   define sealed inline method element-type
	       (class :: subclass(?name))
	    => (type :: <type>, indefinite? :: <false>);
	     values(?element-type, #f);
	   end method element-type;
           define sealed inline method element
	       (ssv :: ?name, key :: <integer>,
		#key default = $not-supplied)
	    => result :: <object>; // because of default:
	     case
	       (key >= 0 & key < ssv.size) =>
		 // Query: Is this fast enough, or do we need to drop in a
		 // call to %elem instead.
		 check-type(ssv.ssv-data, ?compname)[key];
	       (default == $not-supplied) =>
		 element-error(ssv, key);
	       otherwise =>
		 default;
	     end case;
	   end method element;
           define sealed inline method element-setter
	       (value :: ?element-type, ssv :: ?name, key :: <integer>)
	    => value :: ?element-type;
	     if (key < 0)
	       element-error(ssv, key);
	     else
	       if (key >= ssv.size)
		 ssv.size := key + 1;
	       end if;
	       // Query: Is this fast enough, or do we need to drop in a call
	       // to %elem instead.
	       check-type(ssv.ssv-data, ?compname)[key] := value;
	     end if;
	   end method element-setter;

	   // This method is identical to the one in "array.dylan", except
	   // that it is more tightly specialized to a single sealed class.
	   // If you need to make a general change, you should probably grep
	   // for "outlined-iterator" and change all matching locations.
	   //
	   define inline method forward-iteration-protocol (array :: ?name)
	    => (initial-state :: <integer>,
		limit :: <integer>,
		next-state :: <function>,
		finished-state? :: <function>,
		current-key :: <function>,
		current-element :: <function>,
		current-element-setter :: <function>,
		copy-state :: <function>);
	     values(0,
		    array.size,
		    method (array :: ?name, state :: <integer>)
		     => new-state :: <integer>;
		      state + 1;
		    end,
		    method (array :: ?name, state :: <integer>,
			    limit :: <integer>)
		     => done? :: <boolean>;
		      // We use >= instead of == so that the constraint
		      // propagation stuff can tell that state is < limit if
		      // this returns #f.
		      state >= limit;
		    end,
		    method (array :: ?name, state :: <integer>)
		     => key :: <integer>;
		      state;
		    end,
		    method (array :: ?name, state :: <integer>)
		     => element :: ?element-type;
		      element(array, state);
		    end,
		    method (new-value :: ?element-type, array :: ?name,
			    state :: <integer>)
		     => new-value :: ?element-type;
		      element(array, state) := new-value;
		    end,
		    method (array :: ?name, state :: <integer>)
		     => state-copy :: <integer>;
		      state;
		    end);
	   end;
           define sealed inline method add!
	       (ssv :: ?name, new-element :: ?element-type)
	    => ssv :: ?name;
	     ssv[ssv.size] := new-element;
	     ssv;
	   end method add!;
	 end;
       }
end macro;

define sealed method initialize
    (object :: <limited-stretchy-vector>,
     #key size :: <integer> = 0, fill = $not-supplied)
 => ();
  let data-size = case
		    size < 0 =>
		      error("size: can't be negative.");
		    size < 16 => 16;
		    size < 1024 =>
		      for (data-size = 16 then data-size * 2,
			   until: size < data-size)
		      finally data-size;
		      end for;
		    otherwise =>
		      ceiling/(size + 1024, 1024) * 1024;
		  end case;
  // The vector will automatically be filled with the originally designated
  // value...
  let data = make(object.lsv-data-type, size: data-size);
  // ...and then we manually fill the other elements, but only if necessary.
  if (fill ~== $not-supplied & fill ~== object.lsv-fill)
    fill!(data, fill, end: size)
  end if;
  object.ssv-data := data;
  object.ssv-current-size := size;
end method initialize;

define sealed method size-setter
    (new-size :: <integer>, ssv :: <limited-stretchy-vector>)
 => new-size :: <integer>;
  let current-size = ssv.ssv-current-size;
  let data = ssv.ssv-data;
  if (new-size > current-size)
    let current-data-size = data.size;
    if (new-size > current-data-size)
      let new-data-size = calc-size(new-size);
      let new-data = make(ssv.lsv-data-type, size: new-data-size);
      let (init, limit, next, done?, key, elem, elem-setter, copy)
	= forward-iteration-protocol(new-data);
      for (old-elem in data,
	   index :: <integer> from 0 below current-size,
	   state = init then next(new-data, state))
	elem(new-data, state) := old-elem;
      end for;
      ssv.ssv-data := new-data;
    end if;
  else
    fill!(data, #f, start: new-size, end: current-size);
  end if;
  ssv.ssv-current-size := new-size;
end method size-setter;

define sealed method remove! (ssv :: <limited-stretchy-vector>, elem,
                              #key test :: <function> = \==,
			            count :: false-or(<integer>))
 => ssv :: <limited-stretchy-vector>;
  unless (count & (count <= 0))
    let data = ssv.ssv-data;
    let sz = ssv.size;
    local
      method copy (src :: <integer>, dst :: <integer>,
		   deleted :: <integer>)
       => ();
	case
	  src == sz =>
	    ssv.ssv-current-size := sz - deleted;
	  otherwise =>
	    data[dst] := data[src];
	    copy(src + 1, dst + 1, deleted);
	end case;
      end method copy,
      method search-and-copy (src :: <integer>, dst :: <integer>,
			      deleted :: <integer>)
       => ();
	if (src == sz)
	  ssv.ssv-current-size := sz - deleted;
	else 
	  let this-element = data[src];
	  case
	    test(this-element, elem) =>
	      let deleted = deleted + 1;
	      if (count & (deleted == count))
		copy(src + 1, dst, deleted);
	      else
		search-and-copy(src + 1, dst, deleted);
	      end if;
	    otherwise =>
	      data[dst] := data[src];
	      search-and-copy(src + 1, dst + 1, deleted);
	  end case;
	end if;
      end method search-and-copy,
      method search (src :: <integer>) => ();
	unless (src == sz)
	  let this-element = data[src];
	  if (test(this-element, elem))
	    if (count & (count == 1))
	      copy(src + 1, src, 1);
	    else 
	      search-and-copy(src + 1, src, 1);
	    end if;
	  else
	    search(src + 1);
	  end if;
	end unless;
      end method search;
    search(0);
  end unless;
  ssv;
end method remove!;

define sealed method map-into (destination :: <limited-stretchy-vector>,
				proc :: <function>, sequence :: <sequence>,
				#next next-method, #rest more-sequences)
 => res :: <stretchy-vector>;
  if (empty?(more-sequences))
    let sz = size(sequence);
    if (sz == #f)
      error("Cannot map unbounded sequences into stretchy-vectors.");
    elseif (sz > size(destination))
      size(destination) := sz
    end if;
    let data = ssv-data(destination);
    let (init, limit, next, done?, key, elem, elem-setter, copy)
      = forward-iteration-protocol(data);
    // We've already assured that "data" is big enough to hold everything, so
    // we don't need to call "done?".
    for (old-elem in sequence,
	 state = init then next(data, state))
      elem(data, state) := proc(old-elem);
    end for;
    destination;
  else
    next-method();
  end if;
end method map-into;

limited-sv-class(<foo>, <integer>, 3, ***foo-internal***);