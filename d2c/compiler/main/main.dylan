module: main
rcs-header: $Header: /scm/cvs/src/d2c/compiler/main/main.dylan,v 1.46 2001/03/17 03:43:34 bruce Exp $
copyright: see below

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


// This should have some reasonable association with cback
// <unit-state> (but it doesn't.)
//
define class <main-unit-state> (<object>)
  slot unit-lid-file :: <byte-string>, required-init-keyword: lid-file:;
  slot unit-command-line-features :: <list>, 
    required-init-keyword: command-line-features:;
  slot unit-target :: <platform>,
    required-init-keyword: target:;
  slot unit-log-dependencies :: <boolean>, 
    required-init-keyword: log-dependencies:;
  slot unit-no-binaries :: <boolean>,
    required-init-keyword: no-binaries:;
  slot unit-link-static :: <boolean>,
    required-init-keyword: link-static:;
  slot unit-link-rpath :: false-or(<string>),
    required-init-keyword: link-rpath:;
  
  // A facility for hacking around C compiler bugs by using a different
  // command for particular C compilations.  cc-override is a format string
  // used instead of the normal platform compile-c-command.  It is used
  // whenever compiling one of the files in the override-files list.
  slot unit-cc-override :: false-or(<string>),
    required-init-keyword: cc-override:;
  slot unit-override-files :: <list>,
    required-init-keyword: override-files:;
  
  slot unit-header :: <header>;
  slot unit-files :: <stretchy-vector>;
  slot unit-lib-name :: <byte-string>;
  slot unit-lib :: <library>;
  // unit-prefix already a <unit-state> accessor
  slot unit-mprefix :: <byte-string>;
  slot unit-tlf-vectors :: <stretchy-vector> = make(<stretchy-vector>);
  slot unit-init-functions :: <stretchy-vector> = make(<stretchy-vector>);
  slot unit-cback-unit :: <unit-state>;
  slot unit-other-cback-units :: <simple-object-vector>;
  
  // Simplistic flags to control debugging (and someday, optimization).
  // We only have one of these right now.
  slot unit-debug? :: <boolean>, init-keyword: debug?:, init-value: #f;
  slot unit-profile? :: <boolean>, init-keyword: profile?:, init-value: #f;

  slot unit-shared? :: <boolean>, init-keyword: shared?:, init-value: #f;
  
  slot unit-cc-flags;
  // Makefile generation streams, etc.
  slot unit-all-generated-files :: <list>, init-value: #();
  slot unit-makefile-name :: <byte-string>;
  slot unit-temp-makefile-name :: <byte-string>;
  slot unit-makefile :: <file-stream>;
  slot unit-objects-stream :: <buffered-byte-string-output-stream>;
  slot unit-clean-stream :: <buffered-byte-string-output-stream>;
  slot unit-real-clean-stream :: <buffered-byte-string-output-stream>;
  
  slot unit-entry-function :: false-or(<ct-function>), init-value: #f;
  slot unit-unit-info :: <unit-info>;
  
  // All names of the .o files we generated in a string.
  slot unit-objects :: <byte-string>;
  
  // The name of the .ar file we generated.
  slot unit-ar-name :: <byte-string>;
  
  // The name of the executable file we generate.
  slot unit-executable :: false-or(<byte-string>);
end class <main-unit-state>;


// Roots registry.

// Information which needs to go into the library dump file.
//
define class <unit-info> (<object>)
  slot unit-name :: <byte-string>,
    required-init-keyword: #"unit-name";
  
  slot undumped-objects :: <simple-object-vector>,
    required-init-keyword: #"undumped-objects";
  
  slot extra-labels :: <simple-object-vector>,
    required-init-keyword: #"extra-labels";
  
  slot unit-linker-options :: false-or(<byte-string>),
    init-value: #f, init-keyword: #"linker-options";
end class <unit-info>;

define sealed domain make (singleton(<unit-info>));
define sealed domain initialize (<unit-info>);

define variable *units* :: <stretchy-vector> = make(<stretchy-vector>);

define method initialize (info :: <unit-info>, #next next-method, #key) => ();
  next-method();
  add!(*units*, info);
end;
  
add-make-dumper(#"unit-info", *compiler-dispatcher*, <unit-info>,
		list(unit-name, unit-name:, #f,
		     undumped-objects, undumped-objects:, #f,
		     extra-labels, extra-labels:, #f,
		     unit-linker-options, linker-options: #f));


// Compilation driver.

define method file-tokenizer
    (lib :: <library>, name :: <byte-string>)
    => (tokenizer :: <tokenizer>, module :: <module>);
  let source = make(<source-file>, name: name);
  let (header, start-line, start-posn) = parse-header(source);
  values(make(<lexer>,
	      source: source,
	      start-posn: start-posn,
	      start-line: start-line),
	 find-module(lib, as(<symbol>, header[#"module"])));
end;


define method test-lexer (file :: <byte-string>) => ();
  block ()
    let (tokenizer, module) = file-tokenizer($dylan-library, file);
    block (return)
      *Current-Module* := module;
      while (#t)
	let token = get-token(tokenizer);
	if (token.token-kind == $eof-token)
	  return();
	else
	  format(*debug-output*, "%=\n", token);
	end if;
      end while;
    cleanup
      *Current-Module* := #f;
    end block;
  exception (<fatal-error-recovery-restart>)
    #f;
  end block;
end method test-lexer;


define method set-module (module :: type-union(<false>, <module>)) => ();
  *current-module* := module;
end method set-module;

define method set-module (module :: <symbol>) => ();
  block ()
    *current-module*
      := find-module(*Current-Library* | $Dylan-library, module);
  exception (<fatal-error-recovery-restart>)
    #f;
  end block;
end method set-module;

define method set-library (library :: type-union(<false>, <library>)) => ();
  *current-library* := library;
end method set-library;

define method set-library (library :: <symbol>) => ();
  block ()
    *current-library* := find-library(library);
  exception (<fatal-error-recovery-restart>)
    #f;
  end block;
end method set-library;


// The identifier for the current directory
// Used in searching for files

define constant $this-dir = #if (macos)
			       "";
			    #else
			       ".";
			    #endif

define method test-parse
    (parser :: <function>, file :: <byte-string>,
     #key debug: debug? :: <boolean>)
    => result :: <object>;
  block ()
    let (tokenizer, module) = file-tokenizer($dylan-library, file);
    let orig-library = *current-library*;
    let orig-module = *current-module*;
    block ()
      *current-library* := $dylan-library;
      *current-module* := module;
      parser(tokenizer, debug: debug?);
    cleanup
      *current-library* := orig-library;
      *current-module* := orig-module;
    end block;
  exception (<fatal-error-recovery-restart>)
    #f;
  end block;
end method test-parse;

define function translate-abstract-filename (abstract-name :: <byte-string>)
 => (physical-name :: <byte-string>)
  // XXX - We should eventually replace this with a routine that checks
  // for foo.dylan and then foo.dyl, preferably using some sort of abstract
  // locator translation. But for now, we keep it simple.
  concatenate(abstract-name, ".dylan");
end;

define method parse-lid (state :: <main-unit-state>) => ();
  let source = make(<source-file>, name: state.unit-lid-file);
  let (header, start-line, start-posn) = parse-header(source);

  // We support two types of lid files: old "Gwydion LID" and new
  // "official LID". The Gwydion format had a series of file names after
  // the header; the new format has a 'Files:' keyword in the header. We
  // grab the keyword value, transform the filenames in a vaguely appropriate
  // fashion, and then grab anything in the body "as is". This handles both
  // formats. See translate-abstract-filename for details of the new format.
  let contents = source.contents;
  let end-posn = contents.size;

  // Common-Dylan header-file style
  let files = map-as(<stretchy-vector>,
		     translate-abstract-filename,
		     split-at-whitespace(element(header, #"files",
						 default: "")));

  let ofiles = split-at-whitespace(element(header, #"c-object-files",
					   default: ""));

  local
    method repeat (posn :: <integer>)
      if (posn < end-posn)
	let char = as(<character>, contents[posn]);
	if (char.whitespace?)
	  repeat(posn + 1);
	elseif (char == '/' & (posn + 1 < contents.size) 
		  & as(<character>, contents[posn + 1]) == '/')
	  repeat(find-newline(posn + 1));
	else
	  let name-end = find-end-of-word(posn);
	  let len = name-end - posn;
	  let name = make(<byte-string>, size: len);
	  copy-bytes(name, 0, contents, posn, len);
	  add!(files, name);
	  repeat(name-end);
	end;
      end;
    end,
    method find-newline (posn :: <integer>)
     => newline :: <integer>;
      if (posn < end-posn)
	let char = as(<character>, contents[posn]);
	if (char == '\n')
	  posn;
	else
	  find-newline(posn + 1);
	end;
      else
	posn;
      end;
    end method,

    // find-end-of-word returns the position of the first character
    // after the word, where "end of word" is defined as whitespace.
    method find-end-of-word (posn :: <integer>)
     => end-of-word :: <integer>;
      if (posn < end-posn)
	let char = as(<character>, contents[posn]);
	if (char.whitespace?)
	  posn;
	else
	  find-end-of-word(posn + 1);
	end;
      else
	posn;
      end;
    end method;
 
  repeat(start-posn);

  state.unit-header := header;
  state.unit-files := concatenate(files, ofiles);
end method parse-lid;
// Considers anything with an ASCII value less than 32 (' ') to be
// whitespace.  This includes control characters as well as what we
// normally consider whitespace.
define method split-at-whitespace (string :: <byte-string>)
    => res :: <list>;
  split-at(method (x :: <character>) x <= ' ' end, string);
end method split-at-whitespace;


// Split a string at locations where test returns true, removing the delimiter
// characters.
define method split-at (test :: <function>, string :: <byte-string>)
    => res :: <list>;
  let size = string.size;
  local
    method scan (posn :: <integer>, results :: <list>)
	=> res :: <list>;
      if (posn == size)
	results;
      elseif (test(string[posn]))
	scan(posn + 1, results);
      else
	copy(posn + 1, posn, results);
      end;
    end method scan,
    method copy (posn :: <integer>, start :: <integer>,
		 results :: <list>)
	=> res :: <list>;
      if (posn == size | test(string[posn]))
	scan(posn,
	     pair(copy-sequence(string, start: start, end: posn), results));
      else
	copy(posn + 1, start, results);
      end;
    end method copy;
  reverse!(scan(0, #()));
end method split-at;


define method process-feature (feature :: <byte-string>) => ();
  if (feature.empty? | feature[0] ~== '~')
    add-feature(as(<symbol>, feature));
  else
    remove-feature(as(<symbol>, copy-sequence(feature, start: 1)));
  end if;
end method process-feature;


// Find the library object file (archive) using the data-unit search path.
// There might be more than one possible object file suffix, so we try them
// all, but if we find it under more than one suffix, we error.
//
// If the platform supports shared libraries (as indicated by the presence
// of shared-library-filename-suffix in platforms.descr), and if the user
// didn't specify '-static' on the command line, locate shared library
// version first. 

#if (macos)

// At the moment we don't include compiled libs, so we don't need to look properly
// This will cause problems for MPW and building projects, 
// and so this is a temporary measure

define method find-library-archive
    (unit-name :: <byte-string>, state :: <main-unit-state>)
 => path :: <byte-string>;
	let target = state.unit-target;
	let suffixes = split-at-whitespace( target.library-filename-suffix );
	let libname = concatenate( target.library-filename-prefix, unit-name, first( suffixes ) );
 	libname;
 end method find-library-archive;

#else

define method find-library-archive
    (unit-name :: <byte-string>, state :: <main-unit-state>)
 => path :: <byte-string>;
  let target = state.unit-target;
  let libname = concatenate(target.library-filename-prefix, unit-name);
  let suffixes = split-at-whitespace(target.library-filename-suffix);

  let found = #();

  let find = method (suffixes)
	       let found = #();
	       for (suffix in suffixes)
		 let suffixed = concatenate(libname, suffix);
		 let path = find-file(suffixed, *data-unit-search-path*);
		 if (path)
		   found := pair(path, found);
		 end if;
	       end for;
	       found;
	     end method;

  if (target.shared-library-filename-suffix & ~state.unit-link-static)  
    let shared-suffixes
      = split-at-whitespace(target.shared-library-filename-suffix);
    found := find(shared-suffixes);
    if (empty?(found))
      found := find(suffixes);
    end if;
  else
    found := find(suffixes);
  end if;

  if (empty?(found))
    error("Can't find object file for library %s.", unit-name);
  elseif (found.tail ~== #())
    error("Found more than one type of object file for library %s:\n"
	  "  %=",
	  unit-name,
	  found);
  else
    found.head;
  end if;
end method find-library-archive;

#endif


// save-c-file is #t when we don't want the .c file added to the
// real-clean target.  Used when the C file is actually source code,
// rather than the result of Dylan->C.
//
define method output-c-file-rule
    (state :: <main-unit-state>, c-name :: <string>, o-name :: <string>,
     #key save-c-file = #f)
 => ();
  let cc-command
      = if (member?(c-name, state.unit-override-files, test: \=))
          state.unit-cc-override;
	elseif(state.unit-shared?
		 & state.unit-target.compile-c-for-shared-command)
	  state.unit-target.compile-c-for-shared-command;
	else
	  state.unit-target.compile-c-command;
	end if;

  format(state.unit-makefile, "%s : %s\n", o-name, c-name);
  format(state.unit-makefile, "\t%s\n",
         format-to-string(cc-command, c-name, o-name));
  format(state.unit-objects-stream, " %s", o-name);
  format(state.unit-clean-stream, " %s", o-name);
  format(state.unit-real-clean-stream, " %s", o-name);
  if (~save-c-file)
    format(state.unit-real-clean-stream, " %s", c-name);
  end if;
end method output-c-file-rule;

// This function compares old-filename to new-filename.  If they are
// different, or if one doesn't exist (presumably old-filename), then
// new-filename will be renamed old-filename, and what used to be
// old-filename will be deleted.  Otherwise, new-filename will be
// deleted.  This allows us to avoid unnecessary recompilation of .c
// files.
//
define method pick-which-file
    (old-filename :: <string>, new-filename :: <string>, 
     target :: <platform>)
 => (used-new-file :: <boolean>);
  if (files-identical?(old-filename, new-filename))
    delete-file(new-filename);
    #f;
  else
    rename-file(new-filename, old-filename);
    #t;
  end if;
end method pick-which-file;
     
// Look up a header element with a boolean default.  If specified, the option
// must be "yes" or "no".
//
define function boolean-header-element 
    (name :: <symbol>, default :: <boolean>, state :: <main-unit-state>) 
 => res :: <boolean>;
  let found = element(state.unit-header, name, default: #f);
  if (found)
    select (as-uppercase(found) by \=)
      "YES" => #t;
      "NO" => #f;
      otherwise => 
	compiler-error("%s: header option is %s, not \"yes\" or \"no\".",
		       name, found);
    end select;
  else
    default;
  end if;
end function boolean-header-element;
     
define method parse-and-finalize-library (state :: <main-unit-state>) => ();
  parse-lid(state);
  do(process-feature,
     split-at-whitespace(state.unit-target.default-features));
  do(process-feature,
     split-at-whitespace(element(state.unit-header, #"features",
				 default: "")));
  do(process-feature, state.unit-command-line-features);
  
  let lib-name = state.unit-header[#"library"];
  state.unit-lib-name := lib-name;
  format(*debug-output*, "Compiling library %s\n", lib-name);
  let lib = find-library(as(<symbol>, lib-name), create: #t);
  state.unit-lib := lib;
  state.unit-mprefix := as-lowercase(lib-name);
  if(element(state.unit-header, #"unit-prefix", default: #f))
    format(*debug-output*, "Warning: unit-prefix header is deprecated, ignoring it.\n");
  end if;

  state.unit-shared?
    := ~state.unit-link-static
       & ~element(state.unit-header, #"executable", default: #f)
       & boolean-header-element(#"shared-library", #t, state)
       & state.unit-target.shared-library-filename-suffix
       & state.unit-target.shared-object-filename-suffix
       & state.unit-target.link-shared-library-command
       & #t;

  // XXX these two look suspicious
  // second one is ok, default is now according to DRM
  *defn-dynamic-default* := boolean-header-element(#"dynamic", #f, state);
  *implicitly-define-next-method*
    := boolean-header-element(#"implicitly-define-next-method", #t, state);

  for (file in state.unit-files)
    let extension = file.filename-extension;
    if (extension = state.unit-target.object-filename-suffix)
      // Add any random crap to the unit-tlf-vectors so that it will
      // have as many elements as there are files mentioned in the
      // .lid file
      add!(state.unit-tlf-vectors, make(<stretchy-vector>));

      if (state.unit-shared?)
	let shared-file
	  = concatenate(file.extensionless-filename,
			state.unit-target.shared-object-filename-suffix);
	let prefixed-filename 
	  = find-file(shared-file,
		      vector($this-dir, state.unit-lid-file.filename-prefix));
	if (prefixed-filename)
	  log-dependency(prefixed-filename);
	else
	  compiler-fatal-error("Can't find object file %=, and thus can't"
				 " record dependency info.", 
			       shared-file);
	end if;
      else
	let prefixed-filename 
	  = find-file(file, vector($this-dir, state.unit-lid-file.filename-prefix));
	if (prefixed-filename)
	  log-dependency(prefixed-filename);
	else
	#if (macos)
		#t;// Do nothing
	#else
	  compiler-fatal-error("Can't find object file %=, and thus can't"
				 " record dependency info.", 
			       file);
	#endif
	end if;
      end if;
    else  // assumed a Dylan file, with or without a ".dylan" extension
      block ()
	format(*debug-output*, "Parsing %s\n", file);
	// ### prefixed-filename is still not (necessarily) an absolute
	// filename, but it's getting closer
	let prefixed-filename
	  = find-file(file, vector($this-dir, state.unit-lid-file.filename-prefix));
	if (prefixed-filename == #f)
	  compiler-fatal-error("Can't find source file %=.", file);
	end if;
	log-dependency(prefixed-filename);
	let (tokenizer, mod) = file-tokenizer(state.unit-lib, 
					      prefixed-filename);
	block ()
	  *Current-Library* := state.unit-lib;
	  *Current-Module* := mod;
	  let tlfs = make(<stretchy-vector>);
	  *Top-Level-Forms* := tlfs;
	  add!(state.unit-tlf-vectors, tlfs);
	  parse-source-record(tokenizer);
	cleanup
	  *Current-Library* := #f;
	  *Current-Module* := #f;
	end;
      exception (<fatal-error-recovery-restart>)
	format(*debug-output*, "skipping rest of %s\n", file);
      end block;
    end if;
  end for;
#if (mindy)
  collect-garbage(purify: #t);
#endif
  format(*debug-output*, "Finalizing definitions\n");
  for (tlfs in state.unit-tlf-vectors)
    *Top-Level-Forms* := tlfs;
    for (tlf in copy-sequence(tlfs))
      note-context(tlf);
      finalize-top-level-form(tlf);
      end-of-context();
    end for;
  end;
  format(*debug-output*, "inheriting slots\n");
  inherit-slots();
  format(*debug-output*, "inheriting overrides\n");
  inherit-overrides();
  begin
    let unique-id-base 
      = element(state.unit-header, #"unique-id-base", default: #f);
    if (unique-id-base)
      format(*debug-output*, "assigning unique ids\n");
      assign-unique-ids(string-to-integer(unique-id-base));
    end;
  end;
  format(*debug-output*, "seeding representations\n");
  seed-representations();
  format(*debug-output*, "laying out instances\n");
  layout-instance-slots();
end method parse-and-finalize-library;


// Open various streams used to build the makefiles that we generate to compile
// the C output code.
define method emit-make-prologue (state :: <main-unit-state>) => ();
  let cc-flags
    = getenv("CCFLAGS") 
        | format-to-string(if (state.unit-profile?)
			     state.unit-target.default-c-compiler-profile-flags;
			   elseif (state.unit-debug?)
			     state.unit-target.default-c-compiler-debug-flags;
			   else
			     state.unit-target.default-c-compiler-flags;
			   end if,
			   $runtime-include-dir);

  state.unit-cc-flags := concatenate(cc-flags, getenv("CCOPTS")|"");

  state.unit-cback-unit := make(<unit-state>, prefix: state.unit-mprefix);
  state.unit-other-cback-units := map-as(<simple-object-vector>, unit-name, 
					 *units*);

  let makefile-name = format-to-string("cc-%s-files.mak", state.unit-mprefix);
#if (macos)
  let temp-makefile-name = "makefile";
#else
  let temp-makefile-name = concatenate(makefile-name, "-temp");
#endif
  state.unit-makefile-name := makefile-name;
  state.unit-temp-makefile-name := temp-makefile-name;
  format(*debug-output*, "Creating %s\n", makefile-name);
  let makefile = make(<file-stream>, locator: temp-makefile-name,
		      direction: #"output", if-exists: #"overwrite");
  state.unit-makefile := makefile;
  format(makefile, "# Makefile for compiling the .c and .s files\n");
  format(makefile, "# If you want to compile .dylan files, don't use "
	   "this makefile.\n\n");
  format(makefile, "CCFLAGS = %s\n", cc-flags);
  let libtool = getenv("LIBTOOL") | state.unit-target.libtool-command;
  if (libtool)
    format(makefile, "LIBTOOL = %s\n", libtool);
  end;

  format(makefile, "# We only know the ultimate target when we've finished"
	   " building the rest\n");
  format(makefile, "# of this makefile.  So we use this fake "
	   "target...\n#\n");
  format(makefile, "all : all-at-end-of-file\n\n");

  // These next three streams gather filenames.  Objects-stream is
  // simply *.o.  clean-stream is the list of files we will delete
  // with the "clean" target--all objects plus the library archive
  // (.a), the library summary (.du), and the executable.
  // real-clean-stream is everything in clean plus *.c, *.s, and
  // cc-lib-files.mak.
  //
  state.unit-objects-stream := make(<buffered-byte-string-output-stream>);
  state.unit-clean-stream := make(<buffered-byte-string-output-stream>);
  state.unit-real-clean-stream := make(<buffered-byte-string-output-stream>);
  format(state.unit-real-clean-stream, " %s", makefile-name);
end method emit-make-prologue;


// The actual meat of compilation.  Does FER conversion, optimizes and emits
// output code.
//
define method compile-1-tlf
    (tlf :: <top-level-form>, file :: <file-state>, state :: <main-unit-state>) 
 => ();
  let name = format-to-string("%s", tlf);
  begin
    let column = *debug-output*.current-column;
    if (column & column > 75)
      format(*debug-output*, "\n");
    end if;
  end;
  format(*debug-output*, ".");
  force-output(*debug-output*);
  note-context(name);
  let component = make(<fer-component>);
  let builder = make-builder(component);
  convert-top-level-form(builder, tlf);
  let inits = builder-result(builder);
  let name-obj = make(<anonymous-name>, location: tlf.source-location);
  unless (instance?(inits, <empty-region>))
    let result-type = make-values-ctype(#(), #f);
    let source = make(<source-location>);
    let init-function
      = build-function-body
          (builder, $Default-Policy, source, #f,
	   name-obj,
	   #(), result-type, #t);
    build-region(builder, inits);
    build-return
      (builder, $Default-Policy, source, init-function, #());
    end-body(builder);
    let sig = make(<signature>, specializers: #(), returns: result-type);
    let ctv = make(<ct-function>, name: name-obj, signature: sig);
    make-function-literal(builder, ctv, #"function", #"global",
			  sig, init-function);
    add!(state.unit-init-functions, ctv);
  end;
  optimize-component(*current-optimizer*, component);
  emit-tlf-gunk(tlf, file);
  emit-component(component, file);
end method compile-1-tlf;


// Establish various condition handlers while iterating over all of the source
// files and compiling each of them to an output file.
//
define method compile-all-files (state :: <main-unit-state>) => ();
  for (file in state.unit-files, tlfs in state.unit-tlf-vectors)
    let extension = file.filename-extension;
    if (extension = state.unit-target.object-filename-suffix)
      if (state.unit-shared?)
	let shared-file
	  = concatenate(file.extensionless-filename,
			state.unit-target.shared-object-filename-suffix);
	format(*debug-output*, "Adding %s\n", shared-file);
	format(state.unit-objects-stream, " %s", shared-file);
      else
	format(*debug-output*, "Adding %s\n", file);
	format(state.unit-objects-stream, " %s", file);
      end;
    else  // assumed a Dylan file, with or without a ".dylan" extension
      block ()
	format(*debug-output*, "Processing %s\n", file);
	let base-name = file.base-filename;
	let c-name = concatenate(base-name, ".c");
        #if (macos)
        let temp-c-name = concatenate(state.unit-lid-file.filename-prefix,
				      c-name);
        #else
        let temp-c-name = concatenate(c-name, "-temp");
        #endif
	let body-stream
	  = make(<file-stream>, locator: temp-c-name, direction: #"output");
	block ()
	  let file = make(<file-state>, unit: state.unit-cback-unit,
			  body-stream: body-stream);
	  emit-prologue(file, state.unit-other-cback-units);
	  for (tlf in tlfs)
	    block ()
	      compile-1-tlf(tlf, file, state);
	    cleanup
	      end-of-context();
	    exception (<fatal-error-recovery-restart>)
	      #f;
	    end block;
	  end for;
	cleanup
	  close(body-stream);
	  fresh-line(*debug-output*);
	end block;

	pick-which-file(c-name, temp-c-name, state.unit-target);
	let o-name
	  = concatenate(base-name,
			if (state.unit-shared?)
			  state.unit-target.shared-object-filename-suffix;
			else
			  state.unit-target.object-filename-suffix;
			end);
	state.unit-all-generated-files
	  := add!(state.unit-all-generated-files, c-name);
	output-c-file-rule(state, c-name, o-name);

      exception (<fatal-error-recovery-restart>)
	format(*debug-output*, "skipping rest of %s\n", file);
      exception (<simple-restart>,
		   init-arguments:
		   vector(format-string: "Blow off compiling this file."))
	#f;
      end block;
    end if;
  end for;
end method compile-all-files;


// Build initialization function for this library, generate the corresponding
// .c and .o and update the make file.
// 
define method build-library-inits (state :: <main-unit-state>) => ();
    let executable = element(state.unit-header, #"executable", default: #f);
    let executable
     = if (executable)
	 concatenate(executable, state.unit-target.executable-filename-suffix);
       else 
	 #f;
       end if;
    state.unit-executable := executable;
    let entry-point = element(state.unit-header, #"entry-point", default: #f);
    if (entry-point & ~executable)
      compiler-fatal-error("Can only specify an entry-point when producing an "
			     "executable.");
    end if;

    begin
      let c-name = concatenate(state.unit-mprefix, "-init.c");
      #if (macos)
      let temp-c-name = concatenate(state.unit-lid-file.filename-prefix,
				    c-name);
      #else
      let temp-c-name = concatenate(c-name, "-temp");
      #endif
      let body-stream = make(<file-stream>, 
			     locator: temp-c-name, direction: #"output");
      let file = make(<file-state>, unit: state.unit-cback-unit,
      		      body-stream: body-stream);
      emit-prologue(file, state.unit-other-cback-units);
      if (entry-point)
        state.unit-entry-function
	  := build-command-line-entry(state.unit-lib, entry-point, file);
      end if;
      build-unit-init-function(state.unit-mprefix, state.unit-init-functions,
			       body-stream);
      close(body-stream);

      pick-which-file(c-name, temp-c-name, state.unit-target);
      let o-name
	= concatenate(state.unit-mprefix, "-init", 
		      if (state.unit-shared?)
			state.unit-target.shared-object-filename-suffix
		      else
			state.unit-target.object-filename-suffix
		      end if);
      output-c-file-rule(state, c-name, o-name);
      state.unit-all-generated-files 
	:= add!(state.unit-all-generated-files, c-name);
    end;
end method build-library-inits;


define method build-local-heap-file (state :: <main-unit-state>) => ();
  format(*debug-output*, "Emitting Library Heap.\n");
  let c-name = concatenate(state.unit-mprefix, "-heap.c");
  #if (macos)
  let temp-c-name = concatenate(state.unit-lid-file.filename-prefix, c-name);
  #else
  let temp-c-name = concatenate(c-name, "-temp");
  #endif
  let heap-stream = make(<file-stream>, 
			 locator: temp-c-name, direction: #"output");
  let prefix = state.unit-cback-unit.unit-prefix;
  let heap-state = make(<local-heap-file-state>, unit: state.unit-cback-unit,
			body-stream: heap-stream, // target: state.unit-target,
			id-prefix: stringify(prefix, "_L"));

  let (undumped, extra-labels) = build-local-heap(state.unit-cback-unit, 
						  heap-state);
  close(heap-stream);

  pick-which-file(c-name, temp-c-name, state.unit-target);
  let o-name = concatenate(state.unit-mprefix, "-heap", 
			   if (state.unit-shared?)
			     state.unit-target.shared-object-filename-suffix;
			   else
			     state.unit-target.object-filename-suffix
			   end);
  output-c-file-rule(state, c-name, o-name);
  state.unit-all-generated-files 
    := add!(state.unit-all-generated-files, c-name);

  let linker-options = element(state.unit-header, #"linker-options", 
			       default: #f);
  state.unit-unit-info := make(<unit-info>, unit-name: state.unit-mprefix,
			       undumped-objects: undumped,
			       extra-labels: extra-labels,
			       linker-options: linker-options);
end method build-local-heap-file;


define method build-ar-file (state :: <main-unit-state>) => ();
  let objects = stream-contents(state.unit-objects-stream);
  let target = state.unit-target;
  let suffix = split-at-whitespace(if (state.unit-shared?) 
				     target.shared-library-filename-suffix;
				   else
				     target.library-filename-suffix;
				   end if).first;
  let ar-name = concatenate(target.library-filename-prefix,
  			    state.unit-mprefix,
			    suffix);

  state.unit-objects := objects;
  state.unit-ar-name := ar-name;
  format(state.unit-makefile, "\n%s : %s\n", ar-name, objects);
  format(state.unit-makefile, "\t%s %s\n",
	 target.delete-file-command, ar-name);
  
  let objects = use-correct-path-separator(objects, target);

  let link-string = if (state.unit-shared?)
		      format-to-string(target.link-shared-library-command,
				       ar-name, objects,
				       state.unit-link-rpath);
		    else
		      format-to-string(target.link-library-command,
				       ar-name, objects);
		    end;

  format(state.unit-makefile, "\t%s\n", link-string);
  
  if (target.randomize-library-command & ~state.unit-shared?)
    let randomize-string = format-to-string(target.randomize-library-command,
					    ar-name);
    format(state.unit-makefile, "\t%s\n", randomize-string);
  end if;
end method;


define method build-da-global-heap (state :: <main-unit-state>) => ();
  format(*debug-output*, "Emitting Global Heap.\n");
  #if (macos)
  let heap-stream 
       = make(<file-stream>, 
	      locator: concatenate(state.unit-lid-file.filename-prefix,
				   "heap.c"), 
	      direction: #"output");
  #else
  let heap-stream 
  	= make(<file-stream>, locator: "heap.c", direction: #"output");
  #endif
  let heap-state = make(<global-heap-file-state>, unit: state.unit-cback-unit,
			body-stream: heap-stream); //, target: state.unit-target);
  build-global-heap(apply(concatenate, map(undumped-objects, *units*)),
		    heap-state);
  close(heap-stream);
end method;


define method build-inits-dot-c (state :: <main-unit-state>) => ();
  format(*debug-output*, "Building inits.c.\n");
#if (macos) 
  let stream
   = make(<file-stream>, 
	  locator: concatenate(state.unit-lid-file.filename-prefix,
			       "inits.c"), 
	  direction: #"output");
#else
  let stream
   = make(<file-stream>, locator: "inits.c", direction: #"output");
#endif
  format(stream, "#include <runtime.h>\n\n");
  format(stream, 
	"/* This file is machine generated.  Do not edit. */\n\n");
  let entry-function-name
    = (state.unit-entry-function
	 & (make(<ct-entry-point>, for: state.unit-entry-function,
	 	 kind: #"main")
	      .entry-point-c-name));
  if (entry-function-name)
    format(stream,
	   "extern void %s(descriptor_t *sp, int argc, void *argv);\n\n",
	   entry-function-name);
  end if;
  format(stream,
	 "void inits(descriptor_t *sp, int argc, char *argv[])\n{\n");
  for (unit in *units*)
    format(stream, "    %s_Library_init(sp);\n", string-to-c-name(unit.unit-name));
  end;
  if (entry-function-name)
    format(stream, "    %s(sp, argc, argv);\n", entry-function-name);
  end if;
  format(stream, "}\n");
  format(stream, "\nextern void real_main(int argc, char *argv[]);\n\n");
#if (macos)
  format(stream, "#include<console.h>\n");
#endif
  format(stream, "int main(int argc, char *argv[]) {\n");
#if (macos)
  format(stream, "    argc = ccommand( &argv );\n");
#endif
  format(stream, "    real_main(argc, argv);\n");
  format(stream, "    return 0;\n");
  format(stream, "}\n");
  close(stream);
end method;

define function use-correct-path-separator
    (string :: <byte-string>, target :: <platform>) 
 => new-string :: <byte-string>;
  map(method (c :: <character>) => new-char :: <character>;
	if (c == '/') target.path-separator else c end if;
      end method,
      string);
end function use-correct-path-separator;

define method build-executable (state :: <main-unit-state>) => ();
  let target = state.unit-target;
  let unit-libs = "";
  let dash-small-ells = "";
  let linker-args = concatenate(" ", target.link-executable-flags);
  if(state.unit-profile? & target.link-profile-flags)
    linker-args := concatenate(linker-args, " ", target.link-profile-flags);
  end if;

  local method add-archive (name :: <byte-string>) => ();
          if (state.unit-no-binaries)
	    // If cross-compiling use -l -L search mechanism.
	    dash-small-ells := stringify(" -l", name, dash-small-ells);
	  else
	    let archive = find-library-archive(name, state);
	    unit-libs := stringify(' ', archive, unit-libs);
	  end if;
	end method add-archive;

  // Under Unix, the order of the libraries is significant!  First to
  // be added go at the end of the command line...
  add-archive("gc");
  add-archive("runtime");

  for (unit in *units*)
    if (unit.unit-linker-options)
      linker-args
	:= stringify(' ', unit.unit-linker-options, linker-args);
    end if;
    unless (unit == state.unit-unit-info)
      add-archive(unit.unit-name);
    end unless;
  end;

  // We make sure the linker is not given any source files, only
  // library and object files
  format(state.unit-makefile, "\n");
  let inits-dot-o 
    = concatenate("inits", state.unit-target.object-filename-suffix);
  let heap-dot-o
    = concatenate("heap", state.unit-target.object-filename-suffix);
  output-c-file-rule(state, "inits.c", inits-dot-o);
  output-c-file-rule(state, "heap.c", heap-dot-o);

  let dash-cap-ells = "";
  // If cross-compiling, throw in a bunch of -Ls that will probably help.
  if (state.unit-no-binaries)
    for (dir in *data-unit-search-path*)
      dash-cap-ells := concatenate(dash-cap-ells, " -L", dir);
    end for;
    dash-cap-ells
      := concatenate(" $(LDFLAGS)",
      		     use-correct-path-separator(dash-cap-ells,
		     				state.unit-target),
		     " ");						

  end;

  let unit-libs = use-correct-path-separator(unit-libs, state.unit-target);

  // Again, make sure inits.o and heap.o come first
  let objects = format-to-string("%s %s %s %s", inits-dot-o, heap-dot-o, 
				 state.unit-ar-name, unit-libs);

  // rule to link executable
  format(state.unit-makefile, "\n%s : %s\n", state.unit-executable, objects);
  let link-string
    = format-to-string(state.unit-target.link-executable-command,
		       state.unit-executable,
		       concatenate(objects, dash-cap-ells, dash-small-ells," "),
		       linker-args);
  format(state.unit-makefile, "\t%s\n", link-string);

  format(state.unit-clean-stream, " %s %s", 
	 state.unit-ar-name, state.unit-executable);
  format(state.unit-real-clean-stream, " %s %s", 
	 state.unit-ar-name, state.unit-executable);
  format(state.unit-makefile, "\nall-at-end-of-file : %s\n", 
	 state.unit-executable);
end method build-executable;


define method dump-library-summary (state :: <main-unit-state>) => ();
  format(*debug-output*, "Dumping library summary.\n");
  let dump-buf
    = begin-dumping(as(<symbol>, state.unit-lib-name),
    		    $library-summary-unit-type);

  for (tlfs in state.unit-tlf-vectors)
    for (tlf in tlfs)
      dump-od(tlf, dump-buf);
    end;
  end;
  dump-od(state.unit-unit-info, dump-buf);
  dump-queued-methods(dump-buf);

  end-dumping(dump-buf);
  format(state.unit-makefile, "\nall-at-end-of-file : %s\n",
  	 state.unit-ar-name);
  format(state.unit-clean-stream, " %s", state.unit-ar-name);
  format(state.unit-real-clean-stream, " %s %s.lib.du", state.unit-ar-name, 
	 as-lowercase(state.unit-lib-name));
end method;


define method do-make (state :: <main-unit-state>) => ();
  let target = state.unit-target;
  format(state.unit-makefile, "\nclean :\n");
  format(state.unit-makefile, "\t%s %s\n", target.delete-file-command, 
	 state.unit-clean-stream.stream-contents);
  format(state.unit-makefile, "\nrealclean :\n");
  format(state.unit-makefile, "\t%s %s\n", target.delete-file-command, 
	 state.unit-real-clean-stream.stream-contents);
  close(state.unit-makefile);

  if (pick-which-file(state.unit-makefile-name,
		      state.unit-temp-makefile-name,
		      target)
	= #t)
    // If the new makefile is different from the old one, then we need
    // to recompile all .c and .s files, regardless of whether they
    // were changed.  So touch them to make them look newer than the
    // object files.
    unless (empty?(state.unit-all-generated-files))
      let touch-command = "touch";
      for (filename in state.unit-all-generated-files)
	touch-command := stringify(touch-command, ' ', filename);
      end for;
      format(*debug-output*, "%s\n", touch-command);
      if (system(touch-command) ~== 0)
	cerror("so what", "touch failed?");
      end if;
    end unless;
  end if;

  if (~state.unit-no-binaries)
    let make-string = format-to-string("%s -f %s", target.make-command, 
				       state.unit-makefile-name);
    format(*debug-output*, "%s\n", make-string);
    unless (zero?(system(make-string)))
      cerror("so what", "gmake failed?");
    end;
  end if;
end method do-make;


define method compile-library (state :: <main-unit-state>)
    => worked? :: <boolean>;
  block (give-up)
    // We don't really have to give-up if we don't want to, but it
    // seems kind of pointless to compile a file that doesn't parse,
    // or create a dump file for library with undefined variables.
    // Thus, we stick some calls to give-up where it seems useful..
    parse-and-finalize-library(state);
    if (~ zero?(*errors*)) give-up(); end if;
    emit-make-prologue(state);
    compile-all-files(state);
    if (~ zero?(*errors*)) give-up(); end if;
    build-library-inits(state);
    build-local-heap-file(state);
    build-ar-file(state);
    if (state.unit-executable)
      log-target(state.unit-executable);
      calculate-type-inclusion-matrix();
      build-da-global-heap(state);
      build-inits-dot-c(state);
      build-executable(state);
    else
      dump-library-summary(state);
    end if;

    if (state.unit-log-dependencies)
      spew-dependency-log(concatenate(state.unit-mprefix, ".dep"));
    end if;

    do-make(state);

  exception (<fatal-error-recovery-restart>)
    format(*debug-output*, "giving up.\n");
  end block;
  
  format(*debug-output*, "Optimize called %d times.\n", *optimize-ncalls*);

  let worked? = zero?(*errors*);
  format(*debug-output*,
	 "Compilation %s with %d Warning%s and %d Error%s\n",
	 if (worked?) "finished" else "failed" end,
	 *warnings*, if (*warnings* == 1) "" else "s" end,
	 *errors*, if (*errors* == 1) "" else "s" end);

  worked?;
end method compile-library;

define constant $max-inits-per-function = 25;

define method emit-init-functions
    (prefix :: <byte-string>, init-functions :: <vector>,
     start :: <integer>, finish :: <integer>, stream :: <stream>)
    => body :: <byte-string>;
  let string-stream = make(<buffered-byte-string-output-stream>);
  if (finish - start <= $max-inits-per-function)
    for (index from start below finish)
      let init-function = init-functions[index];
      let ep = make(<ct-entry-point>, for: init-function, kind: #"main");
      let name = ep.entry-point-c-name;
      format(stream, "extern void %s(descriptor_t *sp);\n\n", name);
      format(string-stream, "    %s(sp);\n", name);
    end for;
  else
    for (divisions = finish - start
	   then ceiling/(divisions, $max-inits-per-function),
	 while: divisions > $max-inits-per-function)
    finally
      for (divisions from divisions above 0 by -1)
	let count = ceiling/(finish - start, divisions);
	let name = format-to-string("%s_init_%d_%d",
				    prefix, start, start + count - 1);
	let guts = emit-init-functions(prefix, init-functions,
				       start, start + count, stream);
	format(stream, "static void %s(descriptor_t *sp)\n{\n%s}\n\n",
	       name, guts);
	format(string-stream, "    %s(sp);\n", name);
	start := start + count;
      end for;
    end for;
  end if;
  string-stream.stream-contents;
end method emit-init-functions;

define method build-unit-init-function
    (prefix :: <byte-string>, init-functions :: <vector>,
     stream :: <stream>)
    => ();
  let init-func-guts = emit-init-functions(string-to-c-name(prefix), init-functions,
					   0, init-functions.size, stream);
  // The function this generated used to be called simply "%s_init",
  // but that conflicted with the heap object of the same name.  (Of
  // course, on the HP, the linker has separate namespaces for code
  // and data, but most other platforms do not)
  format(stream, "void %s_Library_init(descriptor_t *sp)\n{\n%s}\n",
	 string-to-c-name(prefix), init-func-guts);
end;


define method split-at-colon (string :: <byte-string>)
    => (module :: <byte-string>, name :: <byte-string>);
  block (return)
    for (index :: <integer> from 0 below string.size)
      if (string[index] == ':')
	return(copy-sequence(string, end: index),
	       copy-sequence(string, start: index + 1));
      end if;
    end for;
    compiler-fatal-error
      ("Invalid entry point: %s -- must be of the form module:variable.",
       string);
  end block;
end method split-at-colon;


define method build-command-line-entry
    (lib :: <library>, entry :: <byte-string>, file :: <file-state>)
    => entry-function :: <ct-function>;
  let (module-name, variable-name) = split-at-colon(entry);
  let module = find-module(lib, as(<symbol>, module-name));
  unless (module)
    compiler-fatal-error("Invalid entry point: %s -- no module %s.",
			 entry, module-name);
  end unless;
  let variable = find-variable(make(<basic-name>,
				    symbol: as(<symbol>, variable-name),
				    module: module));
  unless (variable)
    compiler-fatal-error
      ("Invalid entry point: %s -- no variable %s in module %s.",
       entry, variable-name, module-name);
  end unless;
  let defn = variable.variable-definition;
  unless (defn)
    compiler-fatal-error
      ("Invalid entry point: %s -- it isn't defined.", entry);
  end unless;

  let component = make(<fer-component>);
  let builder = make-builder(component);
  let source = make(<source-location>);
  let policy = $Default-Policy;
  let name = "Command Line Entry";
  let name-obj
    = make(<basic-name>, module: $dylan-module, symbol: #"command-line-entry");

  let int-type = specifier-type(#"<integer>");
  let rawptr-type = specifier-type(#"<raw-pointer>");
  let result-type = make-values-ctype(#(), #f);
  let argc = make-local-var(builder, #"argc", int-type);
  let argv = make-local-var(builder, #"argv", rawptr-type);
  let func
    = build-function-body
        (builder, policy, source, #f,
	 name-obj, list(argc, argv), result-type, #t); 

  let user-func = build-defn-ref(builder, policy, source, defn);
  // ### Should really spread the arguments out, but I'm lazy.
  build-assignment(builder, policy, source, #(),
		   make-unknown-call(builder, user-func, #f,
				     list(argc, argv)));
  build-return(builder, policy, source, func, #());
  end-body(builder);
  let sig = make(<signature>, specializers: list(int-type, rawptr-type),
		 returns: result-type);
  let ctv = make(<ct-function>, name: name-obj, signature: sig);
  make-function-literal(builder, ctv, #"function", #"global", sig, func);
  optimize-component(*current-optimizer*, component);
  emit-component(component, file);
  ctv;
end method build-command-line-entry;

define constant $search-path-seperator =
#if (compiled-for-win32)
  ';';
#else
  #if (macos)
     '\t';
  #else
     ':';
  #endif
#endif


//----------------------------------------------------------------------
// <feature-option-parser> - handles -D, -U
//----------------------------------------------------------------------
// d2c has a delightfully non-standard '-D' flag with a corresponding '-U'
// flag which allows you to undefine things (well, sort of). We create a
// new option parser class to handle these using the option-parser-protocol
// module from the parse-arguments library.

define class <d2c-feature-option-parser> (<negative-option-parser>)
end class <d2c-feature-option-parser>;

define method reset-option-parser
    (parser :: <d2c-feature-option-parser>, #next next-method) => ()
  next-method();
  parser.option-value := make(<deque> /* of: <string> */);
end;

define method parse-option
    (parser :: <d2c-feature-option-parser>,
     arg-parser :: <argument-list-parser>)
 => ()
  let negative? = negative-option?(parser, get-argument-token(arg-parser));
  let value = get-argument-token(arg-parser).token-value;
  push-last(parser.option-value,
	    if (negative?)
	      concatenate("~", value)
	    else
	      value
	    end if);
end method parse-option;

    
//----------------------------------------------------------------------
// Built-in help.
//----------------------------------------------------------------------

define method show-copyright(stream :: <stream>) => ()
  format(stream, "d2c (Gwydion Dylan) %s\n", $version);
  format(stream, "Compiles Dylan source into C, then compiles that.\n");
  format(stream, "Copyright 1994-1997 Carnegie Mellon University\n");
  format(stream, "Copyright 1998-2000 Gwydion Dylan Maintainers\n");
end method show-copyright;

define method show-usage(stream :: <stream>) => ()
  format(stream,
"Usage: d2c [options] -Llibdir... lidfile\n");
end method show-usage;

define method show-usage-and-exit() => ()
  show-usage(*standard-error*);
  exit(exit-code: 1);
end method show-usage-and-exit;

define method show-help(stream :: <stream>) => ()
  show-copyright(stream);
  format(stream, "\n");
  show-usage(stream);
  format(stream,
"       -L, --libdir:      Extra directories to search for libraries.\n"
"       -D, --define:      Define conditional compilation features.\n"
"       -U, --undefine:    Undefine conditional compilation features.\n"
"       -M, --log-deps:    Log dependencies to a file.\n"
"       -T, --target:      Target platform name.\n"
"       -p, --platforms:   File containing platform descriptions.\n"
"       --no-binaries:     Do not compile generated C files.\n"
"       -g, --debug:       Generate debugging code.\n"
"       --profile:         Generate profiling code.\n"
"       -s, --static:      Force static linking.\n"
"       -d, --break:       Debug d2c by breaking on errors.\n"
"       -o, --optimizer-option:\n"
"                          Turn on an optimizer option. Prefix option with\n"
"                          'no-' to turn it off.\n"
"       --debug-optimizer: Display detailed optimizer information.\n"
"       -F, --cc-overide-command:\n"
"                          Alternate method of invoking the C compiler.\n"
"                          Used on files specified with -f.\n"
"       -f, --cc-overide-file:\n"
"                          Files which need special C compiler invocation.\n"
"       --help:            Show this help text.\n"
"       --version          Show version number.\n"
	   );
end method show-help;

define method show-compiler-info(stream :: <stream>) => ()
  local method p (#rest args)
	  apply(format, stream, args);
	end;

  // This output gets read by ./configure.
  // All output must be of the form "KEY=VALUE". All keys must begin with
  // "_DCI_" (for "Dylan compiler info") and either "DYLAN" (which designates
  // a general purpose value) or "D2C" (which should be used for anything
  // which is necessarily specific to d2c).

  // This value indicates how much of LID we implement correctly.
  //   0: We only support CMU-style LID files.
  //   1: We support everything from 0 plus the 'File:' keyword.
  //   2: 1 but with unit-prefix being ignored
  p("_DCI_DYLAN_LID_FORMAT_VERSION=2\n");

  // Increment this value here (and CURRENT_BOOTSTRAP_COUNTER) in
  // configure.in to force an automatic bootstrap.
  p("_DCI_D2C_BOOTSTRAP_COUNTER=7\n");

  // The directory (relative to --prefix) where ./configure can find our
  // runtime libraries. This is used when bootstrapping.
  p("_DCI_D2C_RUNTIME_SUBDIR=%s/%s\n", $version, as(<string>, $default-target-name));

  // The absolute path to where d2c searches for user-installed libraries.
  // This is used by the Makefile generated by make-dylan-lib to install
  // site-local Dylan code in the right directoy.
  p("_DCI_D2C_DYLAN_USER_DIR=%s/lib/dylan/%s/%s/dylan-user\n", $dylan-user-dir, $version, as(<string>, $default-target-name));
end method;

define method show-dylan-user-location(stream :: <stream>) => ()
  format(stream, "%s/lib/dylan/%s/%s/dylan-user\n", $dylan-user-dir, $version, as(<string>, $default-target-name));
end method;

//----------------------------------------------------------------------
// Where to find various important files.
//----------------------------------------------------------------------

// $default-dylan-dir and $default-target-name are defined in
// file-locations.dylan, which is generated by makegen.

// If DYLANDIR is defined, then it is assumed to be the root of the install
// area, and the location of platforms.descr and the libraries are derived from
// there.  Otherwise we use the autoconf prefix @prefix@.  It would be nice to
// use libdir, etc., but the default substitutions contain ${prefix}
// variables, which Dylan doesn't have yet.

#if (macos)

define constant $dylan-dir = $default-dylan-dir;
define constant $dylan-user-dir = $default-dylan-user-dir;

// Platform parameter database.
define constant $default-targets-dot-descr = concatenate($dylan-dir, ":support:platforms.descr" );

// Library search path.
define constant $default-dylan-path = concatenate($dylan-dir, ":support:\t");

// Location of runtime.h
define constant $runtime-include-dir = concatenate($dylan-dir, ":support:runtime-includes" );

#else

define constant $dylan-dir = getenv("DYLANDIR") | $default-dylan-dir;
define constant $dylan-user-dir = getenv("DYLANUSERDIR") | getenv("DYLANDIR") | $default-dylan-user-dir;

// Platform parameter database.
define constant $default-targets-dot-descr
  = concatenate($dylan-dir, "/etc/platforms.descr");

// Library search path.
define constant $default-dylan-path
  = concatenate(".:", $dylan-user-dir, "/lib/dylan/", $version, "/", as(<string>, $default-target-name), "/dylan-user:", 
                      $dylan-dir, "/lib/dylan/", $version, "/", as(<string>, $default-target-name));

// Location of runtime.h
define constant $runtime-include-dir
  = concatenate($dylan-dir, "/include");

#endif


//----------------------------------------------------------------------
// Main
//----------------------------------------------------------------------

define method main (argv0 :: <byte-string>, #rest args) => ();
  #if (~mindy)
  no-core-dumps();
  #endif
  *random-state* := make(<random-state>, seed: 0);
  define-bootstrap-module();
 
  // Set up our argument parser with a description of the available options.
  let argp = make(<argument-list-parser>);
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("help"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("version"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("compiler-info"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("dylan-user-location"));
  add-option-parser-by-type(argp,
			    <repeated-parameter-option-parser>,
			    long-options: #("libdir"),
			    short-options: #("L"));
  add-option-parser-by-type(argp,
			    <d2c-feature-option-parser>,
			    long-options: #("define"),
			    short-options: #("D"),
			    negative-long-options: #("undefine"),
			    negative-short-options: #("U"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("log-deps"),
			    short-options: #("M"));
  add-option-parser-by-type(argp,
			    <parameter-option-parser>,
			    long-options: #("target"),
			    short-options: #("T"));
  add-option-parser-by-type(argp,
			    <parameter-option-parser>,
			    long-options: #("platforms"),
			    short-options: #("p"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("no-binaries"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("break"),
			    short-options: #("d"));
  add-option-parser-by-type(argp,
			    <parameter-option-parser>,
			    long-options: #("cc-override-command"),
			    short-options: #("F"));
  add-option-parser-by-type(argp,
			    <repeated-parameter-option-parser>,
			    long-options: #("cc-override-file"),
			    short-options: #("f"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("debug"),
			    short-options: #("g"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("profile"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("static"),
			    short-options: #("s"));
  add-option-parser-by-type(argp,
			    <parameter-option-parser>,
			    long-options: #("rpath"));
  add-option-parser-by-type(argp,
			    <simple-option-parser>,
			    long-options: #("debug-optimizer",
					    "dump-transforms"));
  add-option-parser-by-type(argp,
			    <repeated-parameter-option-parser>,
			    long-options: #("optimizer-option"),
			    short-options: #("o"));

  // Parse our command-line arguments.
  unless(parse-arguments(argp, args))
    show-usage-and-exit();
  end unless;

  // Handle our informational options.
  if (option-value-by-long-name(argp, "help"))
    show-help(*standard-output*);
    exit(exit-code: 0);
  end if;
  if (option-value-by-long-name(argp, "version"))
    show-copyright(*standard-output*);
    exit(exit-code: 0);
  end if;
  if (option-value-by-long-name(argp, "compiler-info"))
    show-compiler-info(*standard-output*);
    exit(exit-code: 0);
  end if;
  if (option-value-by-long-name(argp, "dylan-user-location"))
    show-dylan-user-location(*standard-output*);
    exit(exit-code: 0);
  end if;
  
  // Get our simple options.
  let library-dirs = option-value-by-long-name(argp, "libdir");
  let features = option-value-by-long-name(argp, "define");
  let log-dependencies = option-value-by-long-name(argp, "log-deps");
  let no-binaries = option-value-by-long-name(argp, "no-binaries");
  let cc-override = option-value-by-long-name(argp, "cc-override-command");
  let override-files = option-value-by-long-name(argp, "cc-override-file");
  let link-static = option-value-by-long-name(argp, "static");
  // this is broken. we need to walk through $default-dylan-path,
  // and build an rpath entry for each library we find.
  let link-rpath = option-value-by-long-name(argp, "rpath")
       | format-to-string("%s/lib/dylan/%s/%s/dylan-user",
			  $dylan-user-dir,
			  $version, as(<string>, $default-target-name));
     
  *break-on-compiler-errors* = option-value-by-long-name(argp, "break");
  let debug? = option-value-by-long-name(argp, "debug");
  let profile? = option-value-by-long-name(argp, "profile");
  *emit-all-function-objects?* = debug?;

  // For folks who have *way* too much time (or a d2c bug) on their hands.
  let debug-optimizer = option-value-by-long-name(argp, "debug-optimizer");

  // Determine our compilation target.
  let target-machine-name = option-value-by-long-name(argp, "target");
  let target-machine =
    if(target-machine-name)
      as(<symbol>, target-machine-name);
    else
      $default-target-name;
    end if;
  let targets-file = option-value-by-long-name(argp, "platforms") |
    $default-targets-dot-descr;

  // Decide if anyone passed some '-o' flags to our optimizer.
  let optimizer-options = option-value-by-long-name(argp, "optimizer-option");
  let optimizer-option-table = make(<table>);
  for (option :: <string> in optimizer-options)
    let (key, value) =
      if (option.size > 3 & copy-sequence(option, end: 3) = "no-")
	values(copy-sequence(option, start: 3), #f);
      else
	values(option, #t);
      end;
    optimizer-option-table[as(<symbol>, key)] := value;
  end for;

  // Process our regular arguments, too.
  let args = regular-arguments(argp);
  unless (args.size = 1)
    show-usage-and-exit();
  end unless;
  let lid-file = args[0];

  // Figure out which optimizer to use.
  let optimizer-class =
    if (element(optimizer-option-table, #"null", default: #f))
      format(*standard-error*,
	     "d2c: warning: -onull produces incorrect code\n");
      <null-optimizer>;
    else
      <cmu-optimizer>;
    end;
  *current-optimizer* := make(optimizer-class,
			      options: optimizer-option-table,
			      debug-optimizer?: debug-optimizer);

  // Set up our target.
  if (targets-file == #f)
    error("Can't find platforms.descr");
  end if;
  parse-platforms-file(targets-file);
  *current-target* := get-platform-named(target-machine);

  // Stuff in DYLANPATH goes after any explicitly listed directories.
  let dylanpath = getenv("DYLANPATH") | $default-dylan-path;
  let dirs = split-at(method (x :: <character>);
			x == $search-path-seperator;
		      end,
		      dylanpath);
  for (dir in dirs)
    push-last(library-dirs, dir);
  end for;
  		       
  *Data-Unit-Search-Path* := as(<simple-object-vector>, library-dirs);

  let state
      = make(<main-unit-state>,
             lid-file: lid-file,
	     command-line-features: as(<list>, features), 
	     log-dependencies: log-dependencies,
	     target: *current-target*,
	     no-binaries: no-binaries,
	     link-static: link-static,
	     link-rpath: link-rpath,
	     debug?: debug?,
	     profile?: profile?,
	     cc-override: cc-override,
	     override-files: as(<list>, override-files));
  let worked? = compile-library(state);
  exit(exit-code: if (worked?) 0 else 1 end);
end method main;

#if (mindy)
collect-garbage(purify: #t);
#endif
