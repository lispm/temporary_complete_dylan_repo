Module: front
Description: implementation of Front-End-Representation builder
rcs-header: $Header: /home/housel/work/rcs/gd/src/d2c/compiler/front/fer-builder.dylan,v 1.42 1995/11/14 14:17:33 ram Exp $
copyright: Copyright (c) 1994  Carnegie Mellon University
	   All rights reserved.

// The actual implementation slots of all builders, which we mix in to actual
// instantiable builder classes.
//
define abstract class <internal-builder> (<flow-builder>)
  //
  // The component we're building for.
  slot component :: <component>, init-keyword: component:;
  //
  // Entries are either #"else" or a region.
  slot region-stack :: <list>, init-value: #();

  // A list of lists of the bodies being built.  Each sublist is in reverse
  // order.
  slot body-stack :: <list>,
    init-function: method () list(#()) end;
end class;


// Internal utilities:

// Finish up a body that we've been building, making a compound region to hold
// the result if necessary.
//
define method pop-canonical-body(builder, p-region)
 => res :: <region>;
  let stack = builder.body-stack;
  if (stack == #())
    error("Stack empty?");
  end;

  let body = stack.head;
  builder.body-stack := stack.tail;
  if (pair?(body) & (body.tail == #()))
    let res = body.head;
    res.parent := p-region;
    res;
  else
    let regions = reverse!(body);
    let res = make(<compound-region>, regions: regions, parent: p-region,
                   source-location: if (p-region) p-region.source-location
			       else make(<source-location>)
			       end);
    for (reg in regions)
      reg.parent := res;
    end;
    res;
  end;
end method;


// Add a region to the body we're building.
//
define method add-body-region(builder, region) => ();
  let bstack = builder.body-stack;
  bstack.head := pair(region, bstack.head);
end method;


// Add an assignment to the body we're building.  If the last region is
// currently a simple-region, just tack it on.  If not, make a new
// simple-region.
// 
define method add-body-assignment(builder, assign) => ();
  let bstack = builder.body-stack;
  let current = bstack.head;
  let simple
    = if (instance?(current.head, <simple-region>))
        current.head;
      else
        let new = make(<simple-region>,
		       source-location: assign.source-location);
	bstack.head := pair(new, current);
	new;
      end if;

  assign.region := simple;

  let l-assign = simple.last-assign;
  if (l-assign == #f)
    simple.first-assign := assign;
    simple.last-assign := assign;
  else
    l-assign.next-op := assign;
    assign.prev-op := l-assign;
    simple.last-assign := assign;
  end;
end method;


// Given an operation and a list of operands, set up the <dependency> objects
// marking the operands.  The result is returned.
//
define method make-operand-dependencies(builder :: <internal-builder>,
					result :: <dependent-mixin>,
					ops :: <list>)
    => res :: <dependent-mixin>;

  // Add this dependent to the reoptimize queue.
  let component = builder.component;
  add-to-queue(component, result);

  // Build the dependencies.
  let prev = #f;
  for (op in ops)
    let dep = make(<dependency>, source-exp: op, source-next: op.dependents,
    		   dependent: result);
    if (prev)
      prev.dependent-next := dep;
    else
      result.depends-on := dep;
    end;
    prev := dep;
    op.dependents := dep;
  end;
  // ### This shouldn't be necessary, but there is apparently a bug in
  // Mindy's instance initialization.
  unless (prev)
    result.depends-on := #f;
  end;

  // return the dependent for convenience.
  result;
end method;

define method make-operand-dependencies(builder :: <internal-builder>,
					result :: <dependent-mixin>,
					op :: <expression>)
    => res :: <dependent-mixin>;
  // Add this dependent to the reoptimize queue.
  let component = builder.component;
  add-to-queue(component, result);

  // Build the dependency.
  let dep = make(<dependency>, source-exp: op, source-next: op.dependents,
		 dependent: result);
  result.depends-on := dep;
  op.dependents := dep;

  // return the dependent for convenience.
  result;
end;

// Push new entries on region and body stacks (prepare to append to sub-body.)
//
define method push-body(builder, region) => ();
  builder.region-stack := pair(region, builder.region-stack);
  builder.body-stack := pair(#(), builder.body-stack);
end method;


// All-builder (theoretically non-FER specific) interface methods:

// Check if we've ended all of the enclosing regions, and reinitialize.
//
define method builder-result(builder :: <internal-builder>) => res :: <region>;
  let res = pop-canonical-body(builder, #f);
  unless (empty?(builder.region-stack))
    error("Still in the middle of building.")
  end;

  builder.body-stack := list(#());
  res;
end method;


define method build-region(builder :: <internal-builder>, region :: <region>)
    => ();
  add-body-region(builder, region);
end method;

define method build-region
    (builder :: <internal-builder>, region :: <compound-region>)
    => ();
  for (region in region.regions)
    build-region(builder, region);
  end;
end method;

define method build-region
    (builder :: <internal-builder>, region :: <simple-region>)
    => ();
  let current = builder.body-stack.head;
  if (instance?(current, <simple-region>))
    let cur-last = current.last-assign;
    let reg-first = region.first-assign;
    cur-last.next-op := reg-first;
    reg-first.prev-op := cur-last;
    current.last-assign := region.last-assign;
    for (assign = reg-first then assign.next-op,
	 while: assign)
      assign.region := current;
    end;
  else
    add-body-region(builder, region);
  end;
end;


// If "else", pop both bodies, otherwise a body-region with one body.  If the
// region is a function-region, set its parent to the component, otherwise
// append it to the parent body.
//
define method end-body(builder :: <internal-builder>)
 => res :: <region>;
  let region = builder.region-stack.head;
  builder.region-stack := builder.region-stack.tail;

  if (region == #"else")
    let region = builder.region-stack.head;
    builder.region-stack := builder.region-stack.tail;
    region.else-region := pop-canonical-body(builder, region);
    region.then-region := pop-canonical-body(builder, region);
    add-body-region(builder, region);
    region;
  else    
    region.body := pop-canonical-body(builder, region);
    if (instance?(region, <function-region>))
      region.parent := builder.component;
    else
      add-body-region(builder, region);
    end;
    region;
  end;
end method;


define method build-if-body
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>,  predicate-leaf :: <leaf>)
 => ();
  ignore(policy);
  push-body(builder,
	    make-operand-dependencies(builder,
				      make(<if-region>,
					   source-location: source),
				      predicate-leaf));
end method;


define method build-else
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>)
 => ();
  ignore(source, policy);
  push-body(builder, #"else");
end method;


define method build-block-body
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>)
 => res :: <block-region>;
  ignore(policy);
  let res = make(<block-region>, source-location: source);
  push-body(builder, res);
  res;
end method;


define method build-exit
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>, target :: false-or(<block-region-mixin>))
 => ();
  ignore(policy);
  let target = target | builder.component;
  let res = make(<exit>, source-location: source,
		 block: target, next: target.exits);
  target.exits := res;
  add-body-region(builder, res);
  res;
end method;


define method build-return
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>, target :: <function-region>,
     operands :: union(<list>, <leaf>))
 => ();
  ignore(policy);
  let res = make-operand-dependencies(builder,
				      make(<return>, source-location: source,
					   block: target, next: target.exits),
				      operands);
  target.exits := res;
  add-body-region(builder, res);
  res;
end method;


define method build-loop-body
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>)
 => ();
  ignore(policy);
  push-body(builder, make(<loop-region>, source-location: source));
end method;

define method definition-site-for
    (component :: <component>, var :: <initial-variable>)
    => res :: <initial-definition>;
  make(<initial-definition>, var-info: var.var-info, definition: var,
       derived-type: var.var-info.asserted-type);
end;

define method definition-site-for
    (component :: <component>, var :: <definition-site-variable>)
    => res :: <definition-site-variable>;
  var;
end;

define method build-assignment-aux
    (res :: <assignment>, builder :: <internal-builder>,
     target-vars :: type-or(<leaf>, <list>),
     expr :: <expression>)

  let component = builder.component;
  make-operand-dependencies(builder, res, expr);
		 
  if (list?(target-vars))
    let prev = #f;
    for (var in target-vars)
      let new = definition-site-for(component, var);
      new.definer := res;
      if (prev)
        prev.definer-next := new;
      else
        res.defines := new;
      end;
      prev := new;
    end;
  else
    let new = definition-site-for(component, target-vars);
    new.definer := res;
    res.defines := new;
  end;

  add-body-assignment(builder, res);
end method;		


define method build-assignment
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>,
     target-vars :: type-or(<leaf>, <list>),
     expr :: <expression>)
 => ();
  build-assignment-aux
    (make(<set-assignment>, source-location: source, policy: policy),
     builder, target-vars, expr);
end method;

// Make a join operation and a join assignment.  Add the assignment to the
// builder.
//
define method build-join
    (builder :: <internal-builder>, policy :: <policy>,
     source :: <source-location>,
     target-var :: <ssa-variable>,
     source1 :: <leaf>,
     source2 :: <leaf>)
 => ();
  let exp = make-operand-dependencies(builder,
				      make(<join-operation>),
  				      list(source1, source2));
  let res = make(<join-assignment>, source-location: source, policy: policy,
  		 defines: target-var);

  let dep = make(<dependency>, source-exp: exp, source-next: #f,
		 dependent: res);
  exp.dependents := dep;
  res.depends-on := dep;

  target-var.definer := res;
  add-body-assignment(builder, res);
end method;


// We've kind of deprecated this operation, since we want to support creating
// operations with make to make load/dump easier.  make-operation is kept
// around, but just calls make.  Nobody actually dispatches off of the
// builder, but knowledge of which class to instantiate is explictly passed in,
// so there is no need for the builder to imply it.
//  
define method make-operation
    (builder :: <flow-builder>, class :: <class>, operands :: <list>,
     #rest additional-make-arguments)
 => res :: <operation>;
  apply(make, class, operands: operands, builder: builder,
        additional-make-arguments); 
end method;

define method initialize
    (op :: <operation>, #next next-method, #key builder, operands) => ();
  next-method();
  if (operands)
    make-operand-dependencies(builder, op, operands);
  end if;
end method;



// Actual FER specific stuff:

define class <internal-fer-builder> (<fer-builder>, <internal-builder>)
end;

define method make-builder(wot :: <fer-component>)
 => res :: <internal-fer-builder>;
  make(<internal-fer-builder>, component: wot);
end method;

define method make-builder(wot :: <internal-fer-builder>)
 => res :: <internal-fer-builder>;
  make(<internal-fer-builder>, component: wot.component);
end method;


define method make-unknown-call
    (builder :: <fer-builder>, function :: <leaf>,
     next-method-info :: false-or(<leaf>), arguments :: <list>)
    => res :: <operation>;
  let operands = pair(function,
		      if (next-method-info)
			pair(next-method-info, arguments);
		      else
			arguments;
		      end);
  make-operation(builder, <unknown-call>, operands,
		 use-generic-entry: next-method-info & #t);
end;


define method build-let
    (builder :: <fer-builder>, policy :: <policy>,
     source :: <source-location>,
     target-vars :: type-or(<leaf>, <list>),
     expr :: <expression>)
 => ();
  let component = builder.component;
  let l = make(<let-assignment>, source-location: source, policy: policy,
	       next: component.all-lets);
  component.all-lets := l;
  build-assignment-aux(l, builder, target-vars, expr);
end method;


define method constant-derived-type (value :: <ct-value>)
    => res :: <ctype>;
  ct-value-cclass(value);
end;

define method constant-derived-type (value :: <eql-ct-value>)
    => res :: <ctype>;
  make-canonical-singleton(value)
end;

define method make-literal-constant
    (builder :: <fer-builder>, value :: <ct-value>)
 => res :: <literal-constant>;
  let constants = builder.component.constants;
  element(constants, value, default: #f)
    | (element(constants, value)
	 := make(<literal-constant>,
		 derived-type: constant-derived-type(value),
		 value: value));
end method;

define method make-definition-constant
    (builder :: <fer-builder>, defn :: <abstract-constant-definition>)
 => res :: <leaf>;
  let value = ct-value(defn);
  unless (value)
    error("%s doesn't have a ct-value, so it can be represented as a "
	    "<definition-constant-leaf>",
	  defn.defn-name);
  end;
  make(<definition-constant-leaf>,
       derived-type: ct-value-cclass(value), const-defn: defn);
end method;


define method make-initial-var
    (builder :: <fer-builder>, of-type :: <values-ctype>,
     var-info :: <variable-info>)
    => var :: <initial-variable>;
  let comp = builder.component;
  let var = make(<initial-variable>, derived-type: of-type, var-info: var-info,
		 next-initial-variable: comp.initial-variables,
		 component: comp);
  comp.initial-variables := var;
  var;
end;

define method make-lexical-var
    (builder :: <fer-builder>, name :: <symbol>, source :: <source-location>,
     of-type :: <ctype>)
 => res :: <initial-variable>;
  make-initial-var(builder, of-type, 
		   make(<lexical-var-info>,
			debug-name: name,
			asserted-type: of-type,
			source-location: source));
end method;


define method make-local-var
    (builder :: <fer-builder>, name :: <symbol>, of-type :: <ctype>)
 => res :: <initial-variable>;
  make-initial-var(builder, of-type,
		   make(<local-var-info>,
			asserted-type: of-type,
			debug-name: name));
end method;

define method make-ssa-var
    (builder :: <fer-builder>, name :: <symbol>, of-type :: <ctype>)
 => res :: <ssa-variable>;
  make(<ssa-variable>,
       derived-type: of-type,
       var-info: make(<local-var-info>, asserted-type: of-type,
       		      debug-name: name));
end method;


define method make-values-cluster
    (builder :: <fer-builder>, name :: <symbol>, of-type :: <values-ctype>)
 => res :: <initial-variable>;
  make-initial-var(builder, of-type,
		   make(<values-cluster-info>,
			asserted-type: of-type,
			debug-name: name));
end method;


define method copy-variable
    (builder :: <fer-builder>, var :: <initial-variable>)
 => res :: <initial-variable>;
  make-initial-var(builder, var.var-info.asserted-type, var.var-info);
end method;


define method make-exit-function
    (builder :: <fer-builder>, nlx-info :: <nlx-info>,
     catcher :: <abstract-variable>)
 => res :: <leaf>;
  make-operand-dependencies(builder,
			    make(<exit-function>, nlx-info: nlx-info),
			    list(catcher));
end;



// Starts building an unwind-protect body.
// 
define method build-unwind-protect-body
    (builder :: <fer-builder>, policy :: <policy>, source :: <source-location>,
     cleanup-function :: <function-literal>)
    => res :: <unwind-protect-region>;
  ignore(policy);
  let res = make(<unwind-protect-region>, source-location: source,
		 cleanup-function: cleanup-function);
  push-body(builder, res);
  res;
end;


// Make the region and add it to the component's all-function-regions.
//
define method build-function-body
    (builder :: <fer-builder>, policy :: <policy>, source :: <source-location>,
     lambda? :: <boolean>, name :: <byte-string>, arg-vars :: <list>,
     result-type :: <values-ctype>, hidden-references? :: <boolean>)
 => res :: <fer-function-region>;
  ignore(policy);
  let region = make(if (lambda?) <lambda> else <fer-function-region> end,
		    source-location: source, name: name,
		    argument-types: map(derived-type, arg-vars),
		    result-type: result-type,
		    hidden-references: hidden-references?);
  push-body(builder, region);
  build-let(builder, policy, source, arg-vars, region.prologue);
  add!(builder.component.all-function-regions, region);
  region;
end method;

define method make-function-literal
    (builder :: <fer-builder>, ctv :: false-or(<ct-function>),
     method? :: <boolean>, visibility :: <function-visibility>,
     signature :: <signature>, main-entry :: <fer-function-region>)
 => res :: <leaf>;
  let leaf = make(if (method?) <method-literal> else <function-literal> end,
		  visibility: visibility, signature: signature,
		  ct-function: ctv, main-entry: main-entry);
  add!(builder.component.all-function-literals, leaf);
  leaf;
end;

define method make-function-literal
    (builder :: <fer-builder>, ctv :: false-or(<ct-function>),
     method? :: <boolean>, visibility :: <function-visibility>,
     signature :: <signature>, main-entry :: <lambda>,
     #next next-method)
    => res :: <leaf>;
  let leaf = next-method();
  main-entry.literal := leaf;
  leaf;
end;

