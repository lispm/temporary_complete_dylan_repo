Module:    utilities
Synopsis:  Various small utilities
Author:    Carl Gay
Copyright: Copyright (c) 2001 Carl L. Gay.  All rights reserved.
           Original Code is Copyright (c) 2001 Functional Objects, Inc.  All rights reserved.
License:   Functional Objects Library Public License Version 1.0
Warranty:  Distributed WITHOUT WARRANTY OF ANY KIND



define macro iff
  { iff(?test:expression, ?true:expression, ?false:expression) }
    => { if (?test) ?true else ?false end }
  { iff(?test:expression, ?true:expression) }
    => { if (?test) ?true end }
end;



define macro with-restart
  { with-restart (?condition:expression, #rest ?initargs:*)
      ?:body
    end }
    => { block ()
	   ?body
	 exception (?condition, init-arguments: vector(?initargs))
	   values(#f, #t)
	 end }
end macro with-restart;

define macro with-simple-restart
  { with-simple-restart (?format-string:expression, ?format-args:*)
      ?:body
    end }
    => { with-restart (<simple-restart>,
		       format-string: ?format-string,
		       format-arguments: vector(?format-args))
	   ?body
         end }
end macro with-simple-restart;



define class <sealed-constructor> (<object>) end;
define sealed domain make (subclass(<sealed-constructor>));
define sealed domain initialize (<sealed-constructor>);



define open abstract class <singleton-object> (<object>)
end;

// Maps classes to their singleton instances.
define constant $singletons :: <table> = make(<table>);

define method make
    (class :: subclass(<singleton-object>), #rest args, #key)
 => (object :: <singleton-object>)
  element($singletons, class, default: #f)
  | begin
      $singletons[class] := next-method()
    end
end;



define macro inc!
  { inc! (?place:expression, ?dx:expression) }
    => { ?place := ?place + ?dx; }
  { inc! (?place:expression) }
    => { ?place := ?place + 1; }
end macro inc!;

define macro wrapping-inc!
  { wrapping-inc! (?place:expression) }
    => { let n :: <integer> = ?place;
	 ?place := if (n == $maximum-integer) 0 else n + 1 end; }
end;

define macro dec!
  { dec! (?place:expression, ?dx:expression) }
    => { ?place := ?place - ?dx; }
  { dec! (?place:expression) }
    => { ?place := ?place - 1; }
end macro dec!;



// Things that expire.
define class <expiring-mixin> (<object>)
  constant slot duration :: <day/time-duration>
    = encode-day/time-duration(0, 1, 0, 0, 0),      // 1 hour
    init-keyword: #"duration";
  // When the object was last modified (e.g., loaded from a file).
  slot mod-time :: false-or(<date>) = #f;
end;

define method expired?
    (thing :: <expiring-mixin>) => (expired? :: <boolean>)
  thing.mod-time == #f
  | begin
      let now = current-date();
      (now - thing.mod-time) < thing.duration
    end
end expired?;



define function file-contents
    (filename :: <pathname>) => (contents :: false-or(<string>))
  // In FD 2.0 SP1 if-does-not-exist: #f still signals an error if the file doesn't exist.
  // Remove this block when fixed.  (Reported to Fun-O August 2001.)
  block ()
    with-open-file(input-stream = filename,
                   direction: #"input",
                   if-does-not-exist: #f)
      read-to-end(input-stream)
    end
  exception (<file-does-not-exist-error>)
    #f
  end
end file-contents;



//// multiple-value-setq

//define macro mset
//  { mset(?:expression, ?vars:*) } => { do-mset(?expression, ?vars) ?vars end }
//end macro mset;

define macro pset
  { pset (?vars:*) <= ?:expression end }
    => { do-mset(?expression, ?vars) ?vars end }
end macro pset;

define macro do-mset
  { do-mset(?:expression, ?bind-vars) ?sets end }
    => { let (?bind-vars) = ?expression; ?sets }
bind-vars:
  { } => { }
  { ?:name, ... } => { "bind-" ## ?name ## "", ... }
sets:
  { } => { }
  { ?:name, ... } => { ?name := "bind-" ## ?name ## "" ; ... }
end macro do-mset;



define macro ignore-errors
  { ignore-errors(?error:expression, ?body:expression) }
    => { block ()
           ?body
         exception (?error)
           #f
         end }
end;



// Compare two locator-path elements.
//---*** TODO: portability - This isn't portable.
define method path-element-equal?
    (elem1 :: <object>, elem2 :: <object>) => (equal? :: <boolean>)
  elem1 = elem2
end;

define method path-element-equal?
    (elem1 :: <string>, elem2 :: <string>) => (equal? :: <boolean>)
  string-equal?(elem1, elem2)
end;

define sideways method locator-path
    (locator :: <file-locator>) => (path :: <sequence>)
  locator-path(locator-directory(locator))
end;



define method parent-directory
    (dir :: <locator>, #key levels = 1) => (dir :: <directory-locator>)
  for (i from 1 to levels)
    // is there a better way to get the containing directory?
    dir := simplify-locator(subdirectory-locator(dir, ".."));
  end;
  dir
end;


//// Attributes

define class <attributes-mixin> (<object>)
  constant slot attributes :: <table> = make(<table>);
end;

define method reinitialize-resource
    (resource :: <attributes-mixin>)
  remove-all-keys!(resource.attributes);
end;

define method resource-size
    (resource :: <attributes-mixin>)
  size(attributes(resource));
end;

define generic get-attribute (this :: <attributes-mixin>, key :: <object>, #key);
define generic set-attribute (this :: <attributes-mixin>, key :: <object>, value :: <object>);
define generic remove-attribute (this :: <attributes-mixin>, key :: <object>);

// API
define method get-attribute
    (this :: <attributes-mixin>, key :: <object>, #key default)
 => (attribute :: <object>)
  element(this.attributes, key, default: default)
end;

// API
define method set-attribute
    (this :: <attributes-mixin>, key :: <object>, value :: <object>)
  this.attributes[key] := value;
end;

// API
define method remove-attribute
    (this :: <attributes-mixin>, key :: <object>)
  this.attributes[key] := #f;
end;


