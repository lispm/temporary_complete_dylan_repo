module: gtk-support

define constant generic-dylan-marshaller = callback-method
    (closure :: <GClosure>, return-value :: <GValue*>,
     n_param_values :: <guint>, param_values :: <GValue*>,
     invocation_hint :: <gpointer>, marshal_data :: <gpointer>) => ();
  format-out("");
end;
    
define function g-signal-connect(instance, detailed-signal, c-handler, data)
  g-signal-connect-data (instance, detailed-signal, 
                         c-handler, as(<gpointer>, data | $null-pointer),
                         as(<GClosureNotify>, $null-pointer), 0)
end function g-signal-connect;

define function g-signal-connect-swapped
    (instance, detailed-signal, c-handler, data)
  g-signal-connect-data (instance, detailed-signal, 
                         c-handler, as(<gpointer>, data | $null-pointer),
                         as(<GClosureNotify>, $null-pointer), 
                         $G-CONNECT-SWAPPED)
end function g-signal-connect-swapped;

define method export-value(cls == <GCallback>, value :: <function>) => (result :: <function-pointer>);
  make(<function-pointer>, pointer: value.callback-entry); 
end method export-value;

define method import-value(cls == <function>, value :: <GCallback>) => (result :: <function>);
  error("Is this possible?");
end method import-value;

define method export-value(cls == <gpointer>, the-value :: <object>) 
 => (result :: <gpointer>);
  object-address(make(<value-cell>, value: the-value));
end method export-value;

define method import-value(cls == <object>, the-value :: <gpointer>) 
 => (result :: <gpointer>);
  object-at(the-value).value;
end method export-value;


// Another stupid workaround. Sometimes we need to access mapped types
// as pointers, and Melange doesn't provide any way to do so. Or does it?
define sealed functional class <c-pointer-vector> (<c-vector>) end;

define sealed domain make (singleton(<c-pointer-vector>));

define constant $pointer-size = 4;

define sealed method pointer-value
    (ptr :: <c-pointer-vector>, #key index = 0)
 => (result :: <statically-typed-pointer>);
  pointer-at(ptr,
	     offset: index * $pointer-size,
	     class: <statically-typed-pointer>);
end method pointer-value;

define sealed method pointer-value-setter
    (value :: <statically-typed-pointer>,
     ptr :: <c-pointer-vector>, #key index = 0)
 => (result :: <statically-typed-pointer>);
  pointer-at(ptr,
	     offset: index * $pointer-size,
	     class: <statically-typed-pointer>) := value;
  value;
end method pointer-value-setter;

define sealed method content-size (value :: subclass(<c-pointer-vector>))
 => (result :: <integer>);
  $pointer-size;
end method content-size;

define function gtk-init(progname, arguments)
  let (argc, argv) = c-arguments(progname, arguments);
  %gtk-init(argc, argv);
end function gtk-init;

define method c-arguments(progname :: <string>, arguments)
 => (<int*>, <char***>)
  let argc = 1 + arguments.size;
  let argv :: <c-string-vector> =
    make(<c-string-vector>, element-count: argc + 1);
  // XXX - We'd need to delete these if we weren't using
  // a garbage collector which handles the C heap.
  argv[0] := progname;
  for (i from 1 below argc,
       arg in arguments)
    argv[i] := arg;
  end for;
  as(<c-pointer-vector>, argv)[argc] := null-pointer;
  let pargc = make(<int*>);
  pointer-value(pargc) := argc;
  let pargv = make(<char***>);
  pointer-value(pargv) := argv;
  values(pargc, pargv);
end method c-arguments;
