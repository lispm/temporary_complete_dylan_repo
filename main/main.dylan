module: main
rcs-header: $Header: /home/housel/work/rcs/gd/src/d2c/compiler/main/main.dylan,v 1.9 1995/05/03 07:20:10 wlott Exp $
copyright: Copyright (c) 1994  Carnegie Mellon University
	   All rights reserved.


define method file-tokenizer (lib :: <library>, name :: <byte-string>)
  let source = make(<source-file>, name: name);
  let (header, start-line, start-posn) = parse-header(source);
  make(<lexer>,
       source: source,
       module: find-module(lib,
			   as(<symbol>, header[#"module"]),
			   create: #t),
       start-posn: start-posn,
       start-line: start-line);
end;


define method compile (#rest files) => res :: <component>;
  $Top-Level-Forms.size := 0;
  for (file in files)
    format(*debug-output*, "Parsing %s\n", file);
    parse-program(file-tokenizer($Dylan-Library, file));
  end;
  format(*debug-output*, "Finalizing definitions\n");
  do(finalize-top-level-form, $Top-Level-Forms);
  format(*debug-output*, "inhereting slots, assigning unique ids\n");
  inherit-slots();
  assign-unique-ids();
  format(*debug-output*, "seeding representations\n");
  seed-representations();
  format(*debug-output*, "laying out instances\n");
  layout-instance-slots();
  format(*debug-output*, "Converting in FER\n");
  let component = make(<fer-component>);
  let builder = make-builder(component);
  let init-function
    = build-method-body(builder, $Default-Policy, make(<source-location>),
			"Top Level Initializations", #());
  do(curry(convert-top-level-form, builder), $Top-Level-Forms);
  build-return(builder, $Default-Policy, make(<source-location>),
	       init-function, #());
  end-body(builder);
  format(*debug-output*, "Optimizing\n");
  optimize-component(component);
  format(*debug-output*, "Emitting C code.\n");
  let output-info = make(<output-info>);
  do(rcurry(emit-tlf-gunk, output-info), $Top-Level-Forms);
  do(rcurry(emit-lambda, output-info), component.all-methods);
  output-info-results(output-info);
  component;
end;

define method main (argv0, #rest files)
  if (empty?(files))
    error("No files supplied.");
    #f;
  else
    apply(compile, files);
  end;
end;
