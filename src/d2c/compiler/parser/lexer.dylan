module: lexer
rcs-header: $Header: /home/housel/work/rcs/gd/src/d2c/compiler/parser/lexer.dylan,v 1.3 1994/12/17 01:44:22 wlott Exp $
copyright: Copyright (c) 1994  Carnegie Mellon University
	   All rights reserved.


// Constructors.

// make-binary-operator, make-tilde, make-minus, make-equal,
// make-double-equal -- internal.
//
// Make a various kinds of operators.
// 
define method make-binary-operator (lexer :: <lexer>,
				    source-location :: <file-source-location>)
  make(<binary-operator-token>,
       source-location: source-location,
       symbol: as(<symbol>, extract-string(source-location)),
       module: *Current-Module*);
end;
//
define method make-tilde (lexer :: <lexer>,
			  source-location :: <file-source-location>)
  make(<tilde-token>,
       source-location: source-location,
       symbol: #"~",
       module: *Current-Module*);
end;
//
define method make-minus (lexer :: <lexer>,
			  source-location :: <file-source-location>)
  make(<minus-token>,
       source-location: source-location,
       symbol: #"-",
       module: *Current-Module*);
end;
//
define method make-equal (lexer :: <lexer>,
			  source-location :: <file-source-location>)
  make(<equal-token>,
       source-location: source-location,
       symbol: #"=",
       module: *Current-Module*);
end;
//
define method make-double-equal (lexer :: <lexer>,
				 source-location :: <file-source-location>)
  make(<double-equal-token>,
       source-location: source-location,
       symbol: #"==",
       module: *Current-Module*);
end;


// make-quoted-name -- internal.
//
// Make a <quoted-name-token> for \-quoted operator.
// 
define method make-quoted-name (lexer :: <lexer>,
				  source-location :: <file-source-location>)
  make(<quoted-name-token>,
       source-location: source-location,
       symbol: as(<symbol>,
		  extract-string(source-location,
				 start: source-location.start-posn + 1)),
       module: *Current-Module*);
end;

// maybe-reserved-word -- internal.
//
// Extract the name from the source location, figure out what kind of word it
// is, and make it.
// 
define method maybe-reserved-word (lexer :: <lexer>,
				   source-location :: <file-source-location>)
  let name = as(<symbol>, extract-string(source-location));
  let mod = *Current-Module*;
  make(element(mod.module-syntax-table, name, default: <name-token>),
       source-location: source-location,
       symbol: name,
       module: mod);
end;

// make-constrainted-name -- internal.
//
// Make a constrained name.
// 
define method make-constrained-name (lexer :: <lexer>,
				     source-location :: <file-source-location>)
  let colon-posn
    = block (return)
	let contents = source-location.source-file.contents;
	for (posn from source-location.start-posn
	       below source-location.end-posn)
	  if (contents[posn] == as(<integer>, ':'))
	    return(posn);
	  end;
	end;
	error("No : in a constrained-name?");
	#f;
      end;
  make(<constrained-name-token>,
       source-location: source-location,
       constraint: as(<symbol>,
		      extract-string(source-location, end: colon-posn)),
       symbol: as(<symbol>,
		  extract-string(source-location, start: colon-posn + 1)));
end method;

// escape-character -- internal.
//
// Return the real character that corresponds to the \-quoted
// character in a string or character literal.
//
define method escape-character (char :: <character>)
  select (char)
    'a' => '\a';
    'b' => '\b';
    'e' => '\e';
    'f' => '\f';
    'n' => '\n';
    'r' => '\r';
    't' => '\t';
    '0' => '\0';
    '\\' => '\\';
    '\'' => '\'';
    '"' => '"';
  end;
end;

// decode-string -- internal.
//
// Like extract string, except process escape characters.  Also, we
// default to starting one character in from either end, under the
// assumption that the string will be surrounded by quotes.
//
define method decode-string (source-location :: <file-source-location>,
			     #key start :: <integer>
			       = source-location.start-posn + 1,
			     end: finish :: <integer>
			       = source-location.end-posn - 1)
  let contents = source-location.source-file.contents;
  let length = begin
		 local method repeat (posn, result)
			 if (posn < finish)
			   if (contents[posn] == as(<integer>, '\\'))
			     repeat (posn + 2, result + 1);
			   else
			     repeat (posn + 1, result + 1);
			   end;
			 else
			   result;
			 end;
		       end;
		 repeat(start, 0);
	       end;
  let result = make(<string>, size: length);
  local method repeat (src, dst)
	  if (dst < length)
	    if (contents[src] == as(<integer>, '\\'))
	      result[dst] := escape-character(as(<character>,
						 contents[src + 1]));
	      repeat(src + 2, dst + 1);
	    else
	      result[dst] := as(<character>, contents[src]);
	      repeat(src + 1, dst + 1);
	    end;
	  end;
	end;
  repeat(start, 0);
  result;
end;
			 
// make-quoted-keyword -- internal.
//
// Make a <keyword-token> when confronted with the #"foo" syntax.
//
define method make-quoted-keyword (lexer :: <lexer>,
				   source-location :: <file-source-location>)
  make(<keyword-token>,
       source-location: source-location,
       literal: as(<symbol>,
		   decode-string(source-location,
				 start: source-location.start-posn + 2)));
end;

// make-colon-keyword -- internal.
//
// Make a <keyword-token> when confronted with the foo: syntax.
// 
define method make-colon-keyword (lexer :: <lexer>,
				  source-location :: <file-source-location>)
  make(<keyword-token>,
       source-location: source-location,
       literal: as(<symbol>,
		   extract-string(source-location,
				  end: source-location.end-posn - 1)));
end;
		    
// parse-integer -- internal.
//
// Parse and return an integer in the supplied radix.
// 
define method parse-integer (source-location :: <file-source-location>,
			     #key radix :: <integer> = 10,
			     start :: <integer>
			       = source-location.start-posn,
			     end: finish :: <integer>
			       = source-location.end-posn)
  let contents = source-location.source-file.contents;
  local method repeat (posn, result)
	  if (posn < finish)
	    let digit = contents[posn];
	    if (as(<integer>, '0') <= digit & digit <= as(<integer>, '9'))
	      repeat(posn + 1, result * radix + digit - as(<integer>, '0'));
	    elseif (as(<integer>, 'A') <= digit & digit <= as(<integer>, 'F'))
	      repeat(posn + 1,
		     result * radix + digit - as(<integer>, 'A') + 10);
	    elseif (as(<integer>, 'a') <= digit & digit <= as(<integer>, 'f'))
	      repeat(posn + 1,
		     result * radix + digit - as(<integer>, 'a') + 10);
	    else
	      error("Bogus digit in integer: %=", as(<character>, digit));
	    end;
	  else
	    result;
	  end;
	end;
  if (contents[start] == as(<integer>, '-'))
    -repeat(start + 1, 0);
  else
    repeat(start, 0);
  end;
end;

// parse-{binary,octal,decimal,hex}-literal -- all internal.
//
// Parse an integer and return a <literal-token> holding it.
// 
define method parse-binary-literal (lexer :: <lexer>,
				    source-location :: <file-source-location>)
  make(<literal-token>,
       source-location: source-location,
       literal: parse-integer(source-location,
			      radix: 2,
			      start: source-location.start-posn + 2));
end;

define method parse-octal-literal (lexer :: <lexer>,
				   source-location :: <file-source-location>)
  make(<literal-token>,
       source-location: source-location,
       literal: parse-integer(source-location,
			      radix: 8,
			      start: source-location.start-posn + 2));
end;

define method parse-decimal-literal (lexer :: <lexer>,
				     source-location :: <file-source-location>)
  make(<literal-token>,
       source-location: source-location,
       literal: parse-integer(source-location));
end;

define method parse-hex-literal (lexer :: <lexer>,
				 source-location :: <file-source-location>)
  make(<literal-token>,
       source-location: source-location,
       literal: parse-integer(source-location,
			      radix: 16,
			      start: source-location.start-posn + 2));
end;

// make-character-literal -- internal.
//
// Return a <literal-token> holding the character token.
// 
define method make-character-literal (lexer :: <lexer>,
				      source-location :: <file-source-location>)
  let contents = source-location.source-file.contents;
  let posn = source-location.start-posn + 1;
  let char = as(<character>, contents[posn]);
  make(<literal-token>,
       source-location: source-location,
       literal: if (char == '\\')
		  escape-character(as(<character>, contents[posn + 1]));
		else
		  char;
		end);
end;

// make-string-literal -- internal.
//
// Should be obvious by now.
//
define method make-string-literal (lexer :: <lexer>,
				   source-location :: <file-source-location>)
  make(<string-token>,
       source-location: source-location,
       literal: decode-string(source-location));
end;

// parse-ratio-literal -- internal.
// 
define method parse-ratio-literal (lexer :: <lexer>,
				   source-location :: <file-source-location>)
  error("Can't deal with ratios yet.");
end;

// parse-fp-literal -- internal.
// 
define method parse-fp-literal (lexer :: <lexer>,
				source-location :: <file-source-location>)
  error("Can't deal with floats yet.");
end;


// state machine.

// <state> -- internal.
//
// A particular state in the state machine.
// 
define class <state> (<object>)
  //
  // The name of this state, a symbol.  Not really used once the state
  // machine is built, but we keep it around for debugging purposes.
  slot name :: <symbol>, required-init-keyword: name:;
  //
  // The acceptance result if this state is an accepting state, or #f
  // if it is not.  Symbols are used for magic interal stuff that never
  // makes it out of the lexer (e.g. whitespace), classes for simple
  // tokens that don't need any extra parsing, and functions for more
  // complex tokens.
  slot result :: type-or(<false>, <symbol>, <class>, <function>),
    required-init-keyword: result:;
  //
  // Either #f or a vector of next-states indexed by character code.
  // During construction, vector elements are either state names or #f.
  // After construction, the state names are replaced by the actual
  // state objects.
  slot transitions :: union(<false>, <simple-object-vector>),
    required-init-keyword: transitions:;
end;

define method print-object (state :: <state>, stream :: <stream>) => ();
  pprint-fields(state, stream, name: state.name);
end;

// $Initial-State$ -- internal.
//
// Build the state graph and save the initial state.
// 
define constant $Initial-State$ =
  begin
    local
      method add-transition (table :: <simple-object-vector>,
			     on :: type-or(<integer>, <character>,
					   <byte-string>),
			     new-state :: <symbol>);
	//
	// Make as many entries are necessary to represent the transitions
	// from on to new-state.  On can be either an integer, a character,
	// or a byte-string.  If a byte-string, then it supports ranges
	// as in a-z.
	//
	// We also check to see if this entry classes with any earlier
	// entries.  If so, it means someone messed up editing the
	// state machine.
	// 
	select (on by instance?)
	  <integer> =>
	    if (table[on])
	      error("input %= transitions to both %= and %=",
		    as(<character>, on), table[on], new-state);
	    else
	      table[on] := new-state;
	    end;
	  <character> =>
	    add-transition(table, as(<integer>, on), new-state);
	  <byte-string> =>
	    let last = #f;
	    let range = #f;
	    for (char in on)
	      if (range)
		if (last)
		  for (i from as(<integer>, last) + 1 to as(<integer>, char))
		    add-transition(table, i, new-state);
		  end;
		  last := #f;
		else
		  add-transition(table, as(<integer>, '-'), new-state);
		  add-transition(table, as(<integer>, char), new-state);
		  last := char;
		end;
		range := #f;
	      elseif (char == '-')
		range := #t;
	      else 
		add-transition(table, as(<integer>, char), new-state);
		last := char;
	      end;
	    end;
	end;
      end,
      method state (name :: <symbol>,
		    result :: type-or(<false>, <symbol>, <class>, <function>),
		    #rest transitions)
	//
	// Utility function for making states.  We expand the sequence
	// of transitions into a transition table and make the state object.
	//
	let table = size(transitions) > 0
	              & make(<vector>, size: 128, fill: #f);
	for (transition in transitions)
	  add-transition(table, head(transition), tail(transition));
	end;
	make(<state>,
	     name: name,
	     result: result,
	     transitions: table);
      end;
    //
    // Start out by making a vector of all the states.  The state
    // names are reasonably descriptive of what as already been
    // matched when we are in a particular state.
    // 
    let states = vector(state(#"start", #f,
			      pair(" \t\f\r", #"whitespace"),
			      pair('\n', #"newline"),
			      pair('/', #"slash"),
			      pair('#', #"sharp"),
			      pair('(', #"lparen"),
			      pair(')', #"rparen"),
			      pair(',', #"comma"),
			      pair('.', #"dot"),
			      pair(';', #"semicolon"),
			      pair('[', #"lbracket"),
			      pair(']', #"rbracket"),
			      pair('{', #"lbrace"),
			      pair('}', #"rbrace"),
			      pair(':', #"colon"),
			      pair('-', #"minus"),
			      pair('=', #"equal"),
			      pair('?', #"question"),
			      pair('\\', #"backslash"),
			      pair('+', #"plus"),
			      pair('~', #"tilde"),
			      pair("&*|^", #"operator-graphic"),
			      pair("<>", #"operator-graphic-pre-equal"),
			      pair("!$%@_", #"leading-graphic"),
			      pair("A-Za-z", #"symbol"),
			      pair('\'', #"quote"),
			      pair('"', #"double-quote"),
			      pair("0-9", #"decimal")),
			state(#"whitespace", #"whitespace",
			      pair(" \t\f\r", #"whitespace")),
			state(#"newline", #"newline"),
			state(#"slash", make-binary-operator,
			      pair('/', #"double-slash"),
			      pair('*', #"slash-star")),
			state(#"double-slash", #"end-of-line-comment"),
			state(#"slash-star", #"multi-line-comment"),
			state(#"sharp", #f,
			      pair('(', #"sharp-paren"),
			      pair('[', #"sharp-bracket"),
			      pair("tT", #"true"),
			      pair("fF", #"false"),
			      pair("nN", #"sharp-n"),
			      pair("rR", #"sharp-r"),
			      pair("kK", #"sharp-k"),
			      pair("aA", #"sharp-a"),
			      pair('"', #"sharp-quote"),
			      pair("bB", #"sharp-b"),
			      pair("oO", #"sharp-o"),
			      pair("xX", #"sharp-x")),
			state(#"sharp-paren", <sharp-paren-token>),
			state(#"sharp-bracket", <sharp-bracket-token>),
			state(#"true", <true-token>),
			state(#"false", <false-token>),
			state(#"sharp-n", #f, pair("eE", #"sharp-ne")),
			state(#"sharp-ne", #f, pair("xX", #"sharp-nex")),
			state(#"sharp-nex", #f, pair("tT", #"sharp-next")),
			state(#"sharp-next", <next-token>),
			state(#"sharp-r", #f, pair("eE", #"sharp-re")),
			state(#"sharp-re", #f, pair("sS", #"sharp-res")),
			state(#"sharp-res", #f, pair("tT", #"sharp-rest")),
			state(#"sharp-rest", <rest-token>),
			state(#"sharp-k", #f, pair("eE", #"sharp-ke")),
			state(#"sharp-ke", #f, pair("yY", #"sharp-key")),
			state(#"sharp-key", <key-token>),
			state(#"sharp-a", #f, pair("lL", #"sharp-al")),
			state(#"sharp-al", #f, pair("lL", #"sharp-all")),
			state(#"sharp-all", #f, pair('-', #"sharp-all-")),
			state(#"sharp-all-", #f, pair("kK", #"sharp-all-k")),
			state(#"sharp-all-k", #f, pair("eE", #"sharp-all-ke")),
			state(#"sharp-all-ke", #f,
			      pair("yY", #"sharp-all-key")),
			state(#"sharp-all-key", #f,
			      pair("sS", #"sharp-all-keys")),
			state(#"sharp-all-keys", <all-keys-token>),
			state(#"sharp-quote", #f,
			      pair('"', #"quoted-keyword"), 
			      pair('\\', #"sharp-quote-escape"),
			      pair(" !#-[]-~", #"sharp-quote")),
			state(#"sharp-quote-escape", #f,
			      pair("\\abefnrt0\"", #"sharp-quote")),
			state(#"quoted-keyword", make-quoted-keyword),
			state(#"sharp-b", #f, pair("01", #"binary-integer")),
			state(#"binary-integer", parse-binary-literal,
			      pair("01", #"binary-integer")),
			state(#"sharp-o", #f, pair("0-7", #"octal-integer")),
			state(#"octal-integer", parse-octal-literal,
			      pair("0-7", #"octal-integer")),
			state(#"sharp-x", #f,
			      pair("0-9a-fA-F", #"hex-integer")),
			state(#"hex-integer", parse-hex-literal,
			      pair("0-9a-fA-F", #"hex-integer")),
			state(#"lparen", <left-paren-token>),
			state(#"rparen", <right-paren-token>),
			state(#"comma", <comma-token>),
			state(#"dot", <dot-token>,
			      pair('.', #"dot-dot"),
			      pair("0123456789", #"fp-frac")),
			state(#"dot-dot", #f, pair('.', #"ellipsis")),
			state(#"ellipsis", <ellipsis-token>),
			state(#"semicolon", <semicolon-token>),
			state(#"colon", #f,
			      pair('=', #"colon-equal"),
			      pair(':', #"double-colon")),
			state(#"colon-equal", make-binary-operator),
			state(#"double-colon", <double-colon-token>),
			state(#"lbracket", <left-bracket-token>),
			state(#"rbracket", <right-bracket-token>),
			state(#"lbrace", <left-brace-token>),
			state(#"rbrace", <right-brace-token>),
			state(#"minus", make-minus,
			      pair("0-9", #"signed-decimal")),
			state(#"equal", make-equal,
			      pair('=', #"double-equal"),
			      pair('>', #"arrow"),
			      pair("a-zA-Z", #"symbol"),
			      pair("0-9!&*<|^$%@_-+~?/", #"leading-graphic")),
			state(#"double-equal", make-double-equal,
			      pair("a-zA-Z", #"symbol"),
			      pair("0-9!&*<=>|^$%@_-+~?/",
				   #"leading-graphic")),
			state(#"arrow", <arrow-token>,
			      pair("a-zA-Z", #"symbol"),
			      pair("0-9!&*<=>|^$%@_-+~?/",
				   #"leading-graphic")),
			state(#"question", <question-token>,
			      pair('?', #"double-question")),
			state(#"double-question", <double-question-token>),
			state(#"backslash", #f,
			      pair("-+/", #"backslash-done"),
			      pair('~', #"backslash-pre-equal-done"),
			      pair(':', #"backslash-pre-equal"),
			      pair("a-zA-Z", #"backslash-symbol"),
			      pair("0-9", #"backslash-digit"),
			      pair("!$%@_", #"backslash-graphic"),
			      pair("&*^|", #"backslash-graphic-done"),
			      pair("=<>", #"backslash-graphic-pre-equal")),
			state(#"backslash-done", make-quoted-name),
			state(#"backslash-pre-equal-done", make-quoted-name,
			      pair('=', #"backslash-done")),
			state(#"backslash-pre-equal", #f,
			      pair('=', #"backslash-done")),
			state(#"backslash-graphic", #f,
			      pair("-0-9!&*<=>|^$%@_+~?/",
				   #"backslash-graphic"),
			      pair("a-zA-Z", #"backslash-symbol")),
			state(#"backslash-graphic-done", make-quoted-name,
			      pair("-0-9!&*<=>|^$%@_+~?/",
				   #"backslash-graphic"),
			      pair("a-zA-Z", #"backslash-symbol")),
			state(#"backslash-graphic-pre-equal", make-quoted-name,
			      pair('=', #"backslash-graphic-done"),
			      pair("-0-9!&*<>|^$%@_+~?/",#"backslash-graphic"),
			      pair("a-zA-Z", #"backslash-symbol")),
			state(#"backslash-symbol", make-quoted-name,
			      pair("-+~?/!&*<=>|^$%@_0-9a-zA-Z",
				   #"backslash-symbol")),
			state(#"backslash-digit", #f,
			      pair("-0-9!&*<=>|^$%@_+~?/", #"backslash-digit"),
			      pair("a-zA-Z", #"backslash-digit-alpha")),
			state(#"backslash-digit-alpha", #f,
			      pair("-0-9!&*<=>|^$%@_+~?/", #"backslash-digit"),
			      pair("a-zA-Z", #"backslash-symbol")),
			state(#"plus", make-binary-operator,
			      pair("0-9", #"signed-decimal")),
			state(#"tilde", make-tilde,
			      pair('=', #"tilde-equal")),
			state(#"tilde-equal", make-binary-operator),
			state(#"operator-graphic", make-binary-operator,
			      pair("a-zA-Z", #"symbol"),
			      pair("0-9!&*<=>|^$%@_-+~?/",
				   #"leading-graphic")),
			state(#"operator-graphic-pre-equal",
			      make-binary-operator,
			      pair('=', #"operator-graphic"),
			      pair("a-zA-Z", #"symbol"),
			      pair("0-9!&*<>|^$%@_-+~?/", #"leading-graphic")),
			state(#"leading-graphic", #f,
			      pair("0-9!&*<=>|^$%@_+~?/", #"leading-graphic"),
			      pair('-', #"leading-graphic"),
			      pair("a-zA-Z", #"symbol")),
			state(#"symbol", maybe-reserved-word,
			      pair("a-zA-Z0-9!&*<=>|^$%@_+~?/", #"symbol"),
			      pair('-', #"symbol"),
			      pair(':', #"colon-keyword")),
			state(#"colon-keyword", make-colon-keyword,
			      pair("a-zA-Z", #"cname"),
			      pair("0-9", #"cname-leading-numeric"),
			      pair("!&*<=>|^$%@_", #"cname-leading-graphic")),
			state(#"cname-leading-numeric", #f,
			      pair("0-9!&*<=>|^$%@_+~?/",
				   #"cname-leading-numeric"),
			      pair('-', #"cname-leading-numeric"),
			      pair("a-zA-Z", #"cname-numeric-alpha")),
			state(#"cname-numeric-alpha", #f,
			      pair("0-9!&*<=>|^$%@_+~?/",
				   #"cname-leading-numeric"),
			      pair('-', #"cname-leading-numeric"),
			      pair("a-zA-Z", #"cname")),
			state(#"cname-leading-graphic", #f,
			      pair("0-9!&*<=>|^$%@_+~?/",
				   #"cname-leading-graphic"),
			      pair('-', #"cname-leading-graphic"),
			      pair("a-zA-Z", #"cname")),
			state(#"cname", make-constrained-name,
			      pair("a-zA-Z0-9!&*<=>|^$%@_+~?/", #"cname"),
			      pair('-', #"cname")),
			state(#"quote", #f,
			      pair(" -&(-[]-~", #"quote-char"),
			      pair('\\', #"quote-escape")),
			state(#"quote-char", #f,
			      pair('\'', #"character")),
			state(#"character", make-character-literal),
			state(#"quote-escape", #f,
			      pair("\\abefnrt0'", #"quote-char")),
			state(#"double-quote", #f,
			      pair('"', #"string"), 
			      pair('\\', #"double-quote-escape"),
			      pair(" !#-[]-~", #"double-quote")),
			state(#"string", make-string-literal),
			state(#"double-quote-escape", #f,
			      pair("\\abefnrt0\"", #"double-quote")),
			state(#"decimal", parse-decimal-literal,
			      pair("0-9", #"decimal"),
			      pair('/', #"decimal-slash"),
			      pair('.', #"fp-frac"),
			      pair("eEsSdDxX", #"decimal-e")),
			state(#"decimal-slash", #f,
			      pair("0-9", #"ratio"),
			      pair("a-zA-Z", #"numeric-alpha"),
			      pair("!&*<=>|^$%@_+~?/", #"leading-numeric"),
			      pair('-', #"leading-numeric")),
			state(#"numeric-alpha", #f,
			      pair("a-zA-Z", #"symbol"),
			      pair("0-9!&*<=>|^$%@_+~?/", #"leading-numeric"),
			      pair('-', #"leading-numeric")),
			state(#"leading-numeric", #f,
			      pair("a-zA-Z", #"numeric-alpha"),
			      pair("0-9!&*<=>|^$%@_+~?/", #"leading-numeric"),
			      pair('-', #"leading-numeric")),

			state(#"ratio", parse-ratio-literal,
			      pair("0-9", #"ratio"),
			      pair("a-zA-Z", #"numeric-alpha"),
			      pair("-!&*<=>|^$%@_+~?/", #"leading-numeric")),

			state(#"signed-decimal", parse-decimal-literal,
			      pair("0-9", #"signed-decimal"),
			      pair('/', #"signed-decimal-slash"),
			      pair('.', #"fp-frac")),
			state(#"signed-decimal-slash", #f,
			      pair("0-9", #"signed-ratio")),
			state(#"signed-ratio", parse-ratio-literal,
			      pair("0-9", #"signed-ratio")),
			
			state(#"fp-frac", parse-fp-literal,
			      pair("0-9", #"fp-frac"),
			      pair("eEsSdDxX", #"fp-e")),
			state(#"fp-e", #f,
			      pair('-', #"fp-e-sign"),
			      pair('+', #"fp-e-sign"),
			      pair("0-9", #"fp-exp")),
			state(#"fp-e-sign", #f,
			      pair("0-9", #"fp-exp")),
			state(#"fp-exp", parse-fp-literal,
			      pair("0-9", #"fp-exp")),
	   
			state(#"decimal-e", #f,
			      pair("a-zA-Z", #"symbol"),
			      pair("[0-9]", #"decimal-exp"),
			      pair("!&*<=>|^$%@_~?/", #"leading-numeric"),
			      pair('-', #"decimal-e-sign"),
			      pair('+', #"decimal-e-sign")),
			state(#"decimal-exp", parse-fp-literal,
			      pair("0-9", #"decimal-exp"),
			      pair("a-zA-Z", #"numeric-alpha"),
			      pair("!&*<=>|^$%@_+~?/", #"leading-numeric"),
			      pair("-", #"leading-numeric")),
			state(#"decimal-e-sign", #f,
			      pair("0-9", #"decimal-exp"),
			      pair("a-zA-Z", #"numeric-alpha"),
			      pair("!&*<=>|^$%@_+~?/", #"leading-numeric"),
			      pair("-", #"leading-numeric")));
    //
    // Now that we have a vector of all the states, make a hash table
    // mapping state names to states.
    // 
    let state-table = make(<table>);
    for (state in states)
      if (element(state-table, state.name, default: #f))
	error("State %= multiply defined.", state.name);
      else
	state-table[state.name] := state;
      end;
    end;
    //
    // Now that we have a table mapping state names to states, change the
    // entries in the transition tables to refer to the new state
    // object themselves instead of just to the new state name.
    // 
    for (state in states)
      let table = state.transitions;
      if (table)
	for (i from 0 below 128)
	  let new-state = table[i];
	  if (new-state)
	    table[i] := state-table[new-state];
	  end;
	end;
      end;
    end;
    //
    // Return the start state, 'cause that is what we want
    // $Initial-State$ to hold.
    element(state-table, #"start");
  end;


// lexer

// <lexer> -- exported.
//
// An object holding the current lexer state.
//
define class <lexer> (<tokenizer>)
  //
  // The source file we are currently tokenizing.
  slot source :: <source-file>, required-init-keyword: source:;
  //
  // The position we are currently at in the source file.
  slot posn :: <integer>, required-init-keyword: start-posn:;
  //
  // The line number we are currently working on.
  slot line :: <integer>, required-init-keyword: start-line:;
  //
  // The position that this line started at.
  slot line-start :: <integer>, required-init-keyword: start-posn:;
  //
  // A list of tokens that have been unread.
  slot pushed-tokens :: <list>, init-value: #();
end;

define method print-object (lexer :: <lexer>, stream :: <stream>) => ();
  pprint-fields(lexer, stream,
		source: lexer.source,
		posn: lexer.posn,
		line: lexer.line,
		column: lexer.posn - lexer.line-start + 1);
end;

// skip-multi-line-comment -- internal.
//
// Skip a multi-line comment, taking into account nested comments.
//
// Basically, we just implement a state machine via tail recursive local
// methods.
//
define method skip-multi-line-comment (lexer :: <lexer>,
				       start :: <integer>)
    => result :: union(<integer>, <false>);
  let contents = lexer.source.contents;
  let length = contents.size;
  local
    //
    // Utility function that checks to make sure we haven't run off the
    // end before calling the supplied function.
    //
    method next (func :: <function>, posn :: <integer>, depth :: <integer>)
      if (posn < length)
	func(as(<character>, contents[posn]), posn + 1, depth);
      else
	#f;
      end;
    end next,
    //
    // Seen nothing of interest.  Look for the start of any of /*, //, or */
    //
    method seen-nothing (char :: <character>, posn :: <integer>,
			 depth :: <integer>)
      if (char == '/')
	next(seen-slash, posn, depth);
      elseif (char == '*')
	next(seen-star, posn, depth);
      elseif (char == '\n')
	lexer.line := lexer.line + 1;
	lexer.line-start := posn;
	next(seen-nothing, posn, depth)
      else
	next(seen-nothing, posn, depth);
      end;
    end seen-nothing,
    //
    // Okay, we've seen a slash.  Look to see if it was /*, //, or just a
    // random slash in the source code.
    //
    method seen-slash (char :: <character>, posn :: <integer>,
		       depth :: <integer>)
      if (char == '/')
	next(seen-slash-slash, posn, depth);
      elseif (char == '*')
	next(seen-nothing, posn, depth + 1);
      elseif (char == '\n')
	lexer.line := lexer.line + 1;
	lexer.line-start := posn;
	next(seen-nothing, posn, depth)
      else
	next(seen-nothing, posn, depth);
      end;
    end seen-slash,
    //
    // Okay, we've seen a star.  Look to see if it was */ or a random star.
    // We also have to check to see if this next character is another star,
    // because if so, it might be the start of a */.
    //
    method seen-star (char :: <character>, posn :: <integer>,
		      depth :: <integer>)
      if (char == '/')
	if (depth == 1)
	  posn;
	else
	  next(seen-nothing, posn, depth - 1);
	end;
      elseif (char == '*')
	next(seen-star, posn, depth);
      elseif (char == '\n')
	lexer.line := lexer.line + 1;
	lexer.line-start := posn;
	next(seen-nothing, posn, depth)
      else
	next(seen-nothing, posn, depth);
      end;
    end seen-star,
    //
    // We've seen a //, so skip until the end of the line.
    //
    method seen-slash-slash (char :: <character>, posn :: <integer>,
			     depth :: <integer>)
      if (char == '\n')
	lexer.line := lexer.line + 1;
	lexer.line-start := posn;
	next(seen-nothing, posn, depth);
      else
	next(seen-slash-slash, posn, depth);
      end;
    end seen-slash-slash;
  //
  // Start out not having seen anything.
  //
  next(seen-nothing, start, 1);
end method;

// get-token -- exported.
//
// Tokenize the next token and return it.
//
define method get-token (lexer :: <lexer>) => res :: <token>;
  if (lexer.pushed-tokens ~= #())
    //
    // There are some unread tokens, so extract one of them instead of
    // consuming any more stuff from the source.
    // 
    let result = lexer.pushed-tokens.head;
    lexer.pushed-tokens = lexer.pushed-tokens.tail;
    result;
  else
    //
    // There are no pending unread tokens, so extract the next one.
    // Basically, just record where we are starting, and keep
    // advancing the state machine until there are no more possible
    // advances.  We don't stop at the first accepting state we find,
    // because the longest token is supposed to take precedence.  We
    // just note where the last accepting state we came across was,
    // and then when the state machine jams, we just use that latest
    // accepting state's result.
    // 
    let contents = lexer.source.contents;
    let length = contents.size;
    let result-class = #f;
    let result-start = lexer.posn;
    let result-end = #f;
    local
      method repeat (state, posn)
	if (state.result)
	  //
	  // It is an accepting state, so record the result and where
	  // it ended.
	  // 
	  result-class := state.result;
	  result-end := posn;
	end;
	//
	// Try advancing the state machine once more if possible.
	// 
	if (posn < length)
	  let table = state.transitions;
	  let char = contents[posn];
	  let new-state = table & char < 128 & table[char];
	  if (new-state)
	    repeat(new-state, posn + 1);
	  else
	    maybe-done();
	  end;
	else
	  maybe-done();
	end;
      end,
      method maybe-done ()
	//
	// maybe-done is called when the state machine cannot be
	// advanced any further.  It just checks to see if we really
	// are done or not.
	//
	if (instance?(result-class, <symbol>))
	  //
	  // The result-class is a symbol if this is one of the magic
	  // accepting states.  Instead of returning some token, we do
	  // some special processing depending on exactly what symbol
	  // it is, and then start the state machine over at the
	  // initial state.
	  //
	  select (result-class)
	    #"whitespace" =>
	      #f;
	    #"newline" =>
	      lexer.line := lexer.line + 1;
	      lexer.line-start := result-end;
	    #"end-of-line-comment" =>
	      for (i from result-end below length,
		   until: (contents[i] == as(<integer>, '\n')))
	      finally
		result-end := i;
	      end;
	    #"multi-line-comment" =>
	      result-end := skip-multi-line-comment(lexer, result-end);
	  end;
	  result-class := #f;
	  if (result-end)
	    result-start := result-end;
	    result-end := #f;
	    repeat($Initial-State$, result-start);
	  end;
	end;
      end;
    repeat($Initial-State$, lexer.posn);
    if (~result-class)
      //
      // If result-class is #f, that means we didn't find an accepting
      // state.  Check to see if that means we are at the end of hit
      // an error.
      // 
      if (result-start == length)
	result-class := <eof-token>;
	result-end := result-start;
      else
	result-class := <error-token>;
	result-end := result-start + 1;
      end;
    end;
    //
    // Save the current token's end position so that the next token
    // starts here.
    //
    lexer.posn := result-end;
    //
    // Make a source location for the current token.
    // 
    let source-location
      = make(<file-source-location>,
	     source: lexer.source,
	     start-posn: result-start,
	     start-line: lexer.line,
	     start-column: result-start - lexer.line-start,
	     end-posn: result-end,
	     end-line: lexer.line,
	     end-column: result-end - lexer.line-start);
    //
    // And finally, make and return the actual token.
    // 
    select(result-class by instance?)
      <class> =>
	make(result-class, source-location: source-location);
      <function> =>
	result-class(lexer, source-location);
      otherwise =>
	error("oops");
	#f;
    end;
  end;
end;

// unget-token -- exported.
//
// Pushes token back so that the next call to get-token will return
// it.  Used by the parser when it wants to put back its lookahead
// token.
//
define method unget-token (lexer :: <lexer>, token) => ();
  lexer.pushed-tokens := pair(token, lexer.pushed-tokens);
end;
