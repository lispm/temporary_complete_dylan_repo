module: front


define variable *do-sanity-checks* = #f;

define method enable-sanity-checks () => ();
  *do-sanity-checks* := #t;
end;
define method disable-sanity-checks () => ();
  *do-sanity-checks* := #f;
end;


define method optimize-component (component :: <component>) => ();
  let done = #f;
  until (done)
    if (*do-sanity-checks*)
      check-sanity(component);
    end;
    if (component.initial-definitions)
      let init-defn = component.initial-definitions;
      component.initial-definitions := init-defn.next-initial-definition;
      init-defn.next-initial-definition := #f;
      maybe-convert-to-ssa(init-defn);
    elseif (component.reoptimize-queue)
      let dependent = component.reoptimize-queue;
      component.reoptimize-queue := dependent.queue-next;
      dependent.queue-next := #"absent";
      optimize(component, dependent);
    else
      add-type-checks(component);
      unless (component.initial-definitions | component.reoptimize-queue)
	done := #t;
      end;
    end;
  end;
end;


define method maybe-convert-to-ssa (defn :: <initial-definition>) => ();
  let var :: <initial-variable> = defn.definition-of;
  if (var.definitions.size == 1)
    let assign = defn.definer;
    let ssa = make(<ssa-variable>,
		   dependents: var.dependents,
		   derived-type: var.var-info.asserted-type,
		   var-info: var.var-info,
		   definer: assign,
		   definer-next: defn.definer-next);
    for (other = assign.defines then other.definer-next,
	 prev = #f then other,
	 until: other == defn)
    finally
      if (prev)
	prev.definer-next := ssa;
      else
	assign.defines := ssa;
      end;
    end;
    for (dep = var.dependents then dep.source-next,
	 while: dep)
      if (dep.source-exp == var)
	dep.source-exp := ssa;
      else
	error("The dependent's source-exp wasn't the var we were trying "
		"to replace?");
      end;
    end;
  end;
end;



define method optimize (component :: <component>,
			dependent :: <dependent-mixin>)
    => ();
  // By default, do nothing.
end;

define constant <side-effect-free-expr>
  = type-or(<ssa-variable>, <constant>, <function-literal>);

define method optimize (component :: <component>,
			assignment :: <assignment>)
    => ();
  block (return)
    local
      method trim-unused-definitions (defn, new-tail) => ();
	if (~defn)
	  local method flush-definers (var)
		  if (var)
		    var.definer := #f;
		    flush-definers(var.definer-next);
		  end;
		end;
	  if (new-tail)
	    flush-definers(new-tail.definer-next);
	    new-tail.definer-next := #f;
	  else
	    flush-definers(assignment.defines);
	    assignment.defines := #f;
	  end;
	elseif (~defn.dependents & ~defn.needs-type-check?
		  & instance?(defn, <ssa-variable>))
	  trim-unused-definitions(defn.definer-next, new-tail);
	else
	  trim-unused-definitions(defn.definer-next, defn);
	end;
      end;
    trim-unused-definitions(assignment.defines, #f);

    let dependency = assignment.depends-on;
    let source = dependency.source-exp;
    let source-type = source.derived-type;
    let defines = assignment.defines;

    if (instance?(source, <side-effect-free-expr>))
      if (~defines)
	remove-dependency(component, dependency);
	let next = assignment.next-op;
	let prev = assignment.prev-op;
	if (next | prev)
	  if (next)
	    next.prev-op := prev;
	  else
	    assignment.region.last-assign := prev;
	  end;
	  if (prev)
	    prev.next-op := next;
	  else
	    assignment.region.first-assign := next;
	  end;
	else
	  let region = assignment.region;
	  replace-subregion(region.parent, region, make(<empty-region>));
	end;
	assignment.region := #f;
	  
	return();
      elseif (instance?(defines.var-info, <values-cluster-info>))
	if (instance?(source, <ssa-variable>)
	      & instance?(source.var-info, <values-cluster-info>))
	  maybe-propagate-copy(component, defines, source);
	end;
      else
	unless (instance?(source, <ssa-variable>)
		  & instance?(source.var-info, <values-cluster-info>))
	  maybe-propagate-copy(component, defines, source);
	  let next = defines.definer-next;
	  if (next)
	    let false =
	      make-literal-constant(make-builder(component),
				    make(<literal-false>));
	    for (var = next then var.definer-next,
		 while: var)
	      maybe-propagate-copy(component, var, false);
	    end;
	  end;
	end;
      end;
    end;

    if (defines & instance?(defines.var-info, <values-cluster-info>))
      maybe-restrict-type(component, defines, source-type);
    else
      for (var = defines then var.definer-next,
	   index from 0 below source-type.min-values,
	   positionals = source-type.positional-types then positionals.tail,
	   while: var)
	maybe-restrict-type(component, var, positionals.head);
      finally
	if (var)
	  let false-type = dylan-value(#"<false>");
	  for (var = var then var.definer-next,
	       positionals = positionals then positionals.tail,
	       while: var)
	    let type = if (positionals == #())
			 source-type.rest-value-type;
		       else
			 positionals.head;
		       end;
	    maybe-restrict-type(component, var, ctype-union(type, false-type));
	  end;
	end;
      end;
    end;
  end;
end;

define method maybe-propagate-copy (component :: <component>,
				    var :: <ssa-variable>,
				    value :: <expression>)
    => ();
  unless (var.needs-type-check?)
    // Change all references to this variable to be references to value
    // instead.
    let next = #f;
    let prev = #f;
    for (dep = var.dependents then next,
	 while: dep)
      next := dep.source-next;

      let dependent = dep.dependent;
      if (okay-to-propagate?(dependent, value))
	// Remove the dependency from the source.
	if (prev)
	  prev.source-next := next;
	else
	  var.dependents := next;
	end;

	// Link it into the new value.
	dep.source-exp := value;
	dep.source-next := value.dependents;
	value.dependents := dep;

	// Queue the dependent for reoptimization.
	queue-dependent(component, dependent);
      else
	prev := dep;
      end;
    end;
    
    // If we removed all the uses of var, queue var's defn for reoptimization.
    unless (var.dependents)
      queue-dependent(component, var.definer);
    end;
  end;
end;

define method okay-to-propagate? (dependent :: <dependent-mixin>,
				  value :: <expression>)
    => res :: <boolean>;
  #f;
end;

define method okay-to-propagate? (dependent :: <assignment>,
				  value :: <expression>)
    => res :: <boolean>;
  #t;
end;

define method okay-to-propagate? (dependent :: union(<operation>, <if-region>),
				  value :: <leaf>)
    => res :: <boolean>;
  #t;
end;

define method okay-to-propagate? (dependent :: <lambda>,
				  value :: <abstract-variable>)
    => res :: <boolean>;
  #t;
end;



define method maybe-propagate-copy (component :: <component>,
				    var :: <abstract-variable>,
				    value :: <expression>)
    => ();
end;


define method optimize (component :: <component>, call :: <unknown-call>)
    => ();
  let func-dep = call.depends-on;
  unless (func-dep)
    error("No function in a call?");
  end;
  let assign = call.dependents.dependent;
  assert-type(component, assign, func-dep, function-ctype());
  let func = func-dep.source-exp;
  if (instance?(func, <lambda>))
    // Calling a lambda.  Convert it into either a known or an error call.
    for (arg-dep = func-dep.dependent-next then arg-dep.dependent-next,
	 var = func.prologue.dependents.dependent.defines
	   then var.definer-next,
	 while: arg-dep & var)
      assert-type(component, assign, arg-dep, var.var-info.asserted-type);
    finally
      if (arg-dep | var)
	compiler-warning("Wrong number of arguments.");
	change-call-kind(component, call, <error-call>);
      else
	change-call-kind(component, call, <known-call>);
      end;
    end;
  end;
end;

define method assert-type
    (component :: <component>, before :: <assignment>,
     dependent :: <dependency>, type :: <ctype>)
    => ();
  let source = dependent.source-exp;
  unless (csubtype?(source.derived-type, type))
    let builder = make-builder(component);
    let temp = make-ssa-var(builder, #"temp", type);
    build-assignment(builder, before.policy, before.source-location,
		     temp, source);
    for (dep = source.dependents then dep.source-next,
	 prev = #f then dep,
	 until: dep == dependent)
    finally
      if (prev)
	prev.source-next := dep.source-next;
      else
	source.dependents := dep.source-next;
      end;
    end;
    dependent.source-exp := temp;
    temp.dependents := dependent;
    dependent.source-next := #f;
    insert-before(before, builder-result(builder));
  end;
end;

define method change-call-kind
    (component :: <component>, call :: <abstract-call>, new-kind :: <class>)
    => ();
  let new = make(new-kind, dependents: call.dependents,
		 depends-on: call.depends-on);
  for (dep = call.depends-on then dep.dependent-next,
       while: dep)
    dep.dependent := new;
  end;
  for (dep = call.dependents then dep.source-next,
       while: dep)
    dep.source-exp := new;
  end;
  queue-dependent(component, new);
end;

define method optimize (component :: <component>, call :: <known-call>) => ();
  maybe-restrict-type(component, call, call.depends-on.source-exp.result-type);
end;


define method optimize (component :: <component>, primitive :: <primitive>)
    => ();
  let deriver = element($primitive-type-derivers, primitive.name, default: #f);
  if (deriver)
    let type = deriver(component, primitive);
    maybe-restrict-type(component, primitive, type);
  end;
end;

define method optimize (component :: <component>, prologue :: <prologue>)
    => ();
  let types = make(<stretchy-vector>);
  for (var = prologue.dependents.dependent.defines then var.definer-next,
       while: var)
    add!(types, var.var-info.asserted-type);
  end;
  maybe-restrict-type(component, prologue,
		      make-values-ctype(as(<list>, types), #f));
end;

define method optimize (component :: <component>, lambda :: <lambda>)
    => ();
  let results = lambda.depends-on;
  if (results & instance?(results.source-exp.var-info, <values-cluster-info>))
    // We have to restrict the result type first, otherwise the single
    // values cluster might be expanded away and we would end up just using
    // the first value's type.
    maybe-restrict-result-type(component, lambda,
			       results.source-exp.derived-type);
    if (maybe-expand-cluster(component, results.source-exp))
      queue-dependents(component, lambda);
    end;
  else
    let types = make(<stretchy-vector>);
    for (dep = results then dep.dependent-next,
	 while: dep)
      add!(types, dep.source-exp.derived-type);
    end;
    maybe-restrict-result-type(component, lambda,
			       make-values-ctype(as(<list>, types), #f));
  end;
end;

define method maybe-restrict-result-type
    (component :: <component>, lambda :: <lambda>, type :: <values-ctype>)
    => ();
  let old-type = lambda.result-type;
  unless (old-type == type)
    unless (values-subtype?(type, old-type))
      error("result type became more general?");
    end;
    lambda.result-type := type;
    queue-dependents(component, lambda);
  end;
end;    

define method maybe-expand-cluster
    (component :: <component>, cluster :: <ssa-variable>)
    => did-anything? :: <boolean>;
  let return-type = cluster.derived-type;
  if (return-type.min-values == return-type.positional-types.size
	& return-type.rest-value-type == empty-ctype())
    let cluster-dependency = cluster.dependents;
    unless (cluster-dependency & cluster-dependency.source-next == #f)
      error("Values cluster used in more than one place?");
    end;
    let target = cluster-dependency.dependent;
    let assign = cluster.definer;
    let new-defines = #f;
    let new-depends-on = #f;
    for (index from return-type.min-values - 1 to 0 by -1)
      let debug-name = as(<symbol>, format-to-string("result%d", index));
      let var-info = make(<local-var-info>, debug-name: debug-name,
			  asserted-type: object-ctype());
      let var = make(<ssa-variable>, var-info: var-info,
		     definer: assign, definer-next: new-defines);
      let dep = make(<dependency>, source-exp: var, source-next: #f,
		     dependent: target, dependent-next: new-depends-on);
      var.dependents := dep;
      new-defines := var;
      new-depends-on := dep;
    end;
    assign.defines := new-defines;
    target.depends-on := new-depends-on;
    queue-dependent(component, assign);
    #t;
  else
    #f;
  end;
end;



// Type utilities.

define method queue-dependent
    (component :: <component>, dependent :: <dependent-mixin>) => ();
  if (dependent.queue-next == #"absent")
    dependent.queue-next := component.reoptimize-queue;
    component.reoptimize-queue := dependent;
  end;
end;

define method queue-dependents
    (component :: <component>, expr :: <expression>) => ();
  for (dependency = expr.dependents then dependency.source-next,
       while: dependency)
    queue-dependent(component, dependency.dependent);
  end;
end;

define method maybe-restrict-type
    (component :: <component>, expr :: <expression>, type :: <values-ctype>)
    => ();
  let old-type = expr.derived-type;
  unless (old-type == type)
    unless (values-subtype?(type, old-type))
      error("derived type became more general?");
    end;
    expr.derived-type := type;
    queue-dependents(component, expr);
  end;
end;

define method maybe-restrict-type
    (component :: <component>, var :: <abstract-variable>,
     type :: <values-ctype>, #next next-method)
    => ();
  next-method(component, var,
	      values-type-intersection(type,
				       var.var-info.asserted-type));
end;

define method maybe-restrict-type (component :: <component>,
				   var :: <definition-site-variable>,
				   type :: <values-ctype>,
				   #next next-method)
    => ();
  if (var.needs-type-check?
	& values-subtype?(type, var.var-info.asserted-type))
    var.needs-type-check? := #f;
    queue-dependent(component, var.definer);
  end;
  next-method();
end;


// Type derivers for various primitives.

define constant $primitive-type-derivers = make(<object-table>);

define method define-primitive-deriver
    (name :: <symbol>, deriver :: <function>)
    => ();
  $primitive-type-derivers[name] := deriver;
end;

define method boolean-result
    (component :: <component>, primitive :: <primitive>)
    => res :: <values-ctype>;
  dylan-value(#"<boolean>");
end;

define-primitive-deriver(#"fixnum-=", boolean-result);
define-primitive-deriver(#"fixnum-<", boolean-result);

define method fixnum-result
    (component :: <component>, primitive :: <primitive>)
    => res :: <values-ctype>;
  dylan-value(#"<fixed-integer>");
end;

for (name in #[#"fixnum-+", #"fixnum-*", #"fixnum--", #"fixnum-negative",
		 #"fixnum-logior", #"fixnum-logxor", #"fixnum-logand",
		 #"fixnum-lognot", #"fixnum-ash"])
  define-primitive-deriver(name, fixnum-result);
end;

define method two-fixnums-result
    (component :: <component>, primitive :: <primitive>)
    => res :: <values-ctype>;
  let fi = dylan-value(#"<fixed-integer>");
  make-values-ctype(list(fi, fi), #f);
end;

for (name in #[#"fixnum-floor/", #"fixnum-ceiling/", #"fixnum-round/",
		 #"fixnum-truncate/"])
  define-primitive-deriver(name, two-fixnums-result);
end;



// Cheesy type check stuff.


define method add-type-checks (component :: <component>) => ();
  for (lambda in component.all-methods)
    add-type-checks-aux(component, lambda);
  end;
end;

define method add-type-checks-aux
    (component :: <component>, region :: <simple-region>) => ();
  let next-assign = #f;
  for (assign = region.first-assign then next-assign,
       while: assign)
    let builder = #f;
    next-assign := assign.next-op;
    for (defn = assign.defines then defn.definer-next,
	 prev = #f then defn,
	 while: defn)
      if (defn.needs-type-check?)
	// Make a temp to hold the unchecked value.
	let temp = if (instance?(defn.var-info, <values-cluster-info>))
		     error("values cluster needs a type check?");
		   else
		     make(<ssa-variable>,
			  definer: assign,
			  definer-next: defn.definer-next,
			  var-info: make(<local-var-info>,
					 debug-name: defn.var-info.debug-name,
					 asserted-type: object-ctype()));
		   end;
	// Link the temp in in place of this definition.
	if (prev)
	  prev.definer-next := temp;
	else
	  assign.defines := temp;
	end;
	// Make the builder if we haven't already.
	unless (builder)
	  builder := make-builder(component);
	end;
	// Make the check type operation.
	let asserted-type = defn.var-info.asserted-type;
	let check = make-check-type-operation(builder, temp,
					      make-literal-constant
						(builder, asserted-type));
	// Assign the type checked value to the real var.
	defn.definer-next := #f;
	build-assignment(builder, assign.policy, assign.source-location,
			 defn, check);
	// Seed the derived type of the check-type call.
	let (checked-type, precise?)
	  = ctype-intersection(asserted-type,
			       assign.depends-on.source-exp.derived-type);
	maybe-restrict-type(component, check,
			    if (precise?)
			      checked-type;
			    else
			      asserted-type;
			    end);
	// Queue the assignment for reoptimization.
	queue-dependent(component, assign);
	// Change defn to temp so that the loop steps correctly.
	defn := temp;
      end;
    end;
    if (builder)
      insert-after(assign, builder-result(builder));
    end;
  end;
end;

// duplicated from fer-convert because I don't want to figure out how to
// import them from there.
// 
define method dylan-defn-leaf (builder :: <fer-builder>, name :: <symbol>)
    => res :: <leaf>;
  make-definition-leaf(builder, dylan-defn(name))
    | error("%s undefined?", name);
end;

define method make-check-type-operation (builder :: <fer-builder>,
					 value-leaf :: <leaf>,
					 type-leaf :: <leaf>)
    => res :: <operation>;
  make-operation(builder,
		 list(dylan-defn-leaf(builder, #"check-type"),
		      value-leaf,
		      type-leaf));
end method;


define method add-type-checks-aux
    (component :: <component>, region :: <compound-region>) => ();
  for (subregion in region.regions)
    add-type-checks-aux(component, subregion);
  end;
end;

define method add-type-checks-aux
    (component :: <component>, region :: <if-region>) => ();
  add-type-checks-aux(component, region.then-region);
  add-type-checks-aux(component, region.else-region);
end;

define method add-type-checks-aux
    (component :: <component>, region :: <body-region>) => ();
  add-type-checks-aux(component, region.body);
end;



// FER editing stuff.


define method remove-dependency
    (component :: <component>, dependency :: <dependency>) => ();

  // Remove the dependency from the source exp.
  let source = dependency.source-exp;
  for (dep = source.dependents then dep.source-next,
       prev = #f then dep,
       until: dep == dependency)
  finally
    if (prev)
      prev.source-next := dep.source-next;
    else
      source.dependents := dep.source-next;
    end;
  end;

  // If there are no more dependents on the source note that the source itself
  // can maybe go away.
  unless (source.dependents)
    maybe-forget-source(component, source);
  end;

  // Remove the dependency from the dependent.
  for (dep = dependency.dependent.depends-on then dep.dependent-next,
       prev = #f then dep,
       until: dep == dependency)
  finally
    if (prev)
      prev.dependent-next := dep.dependent-next;
    else
      dep.dependent.depends-on := dep.dependent-next;
    end;
  end;
end;


define method maybe-forget-source
    (component :: <component>, var :: <ssa-variable>) => ();
  queue-dependent(component, var.definer);
end;

define method maybe-forget-source
    (component :: <component>, expr :: <expression>) => ();
end;


define method combine-regions
    (first :: <simple-region>, second :: <simple-region>)
    => res :: <simple-region>;
  let last-of-first = first.last-assign;
  let first-of-second = second.first-assign;

  last-of-first.next-op := first-of-second;
  first-of-second.prev-op := last-of-first;

  first.last-assign := second.last-assign;

  for (assign = first-of-second then assign.next-op,
       while: assign)
    assign.region := first;
  end;

  first;
end;

define method combine-regions
    (first :: <compound-region>, second :: <compound-region>)
    => res :: <compound-region>;
  let new-regions = second.regions;
  first.regions := concatenate(first.regions, new-regions);
  for (reg in new-regions)
    reg.parent := first;
  end;
  first;
end;

define method combine-regions
    (first :: <compound-region>, second :: <region>)
    => res :: <compound-region>;
  first.regions := concatenate(first.regions, list(second));
  second.parent := first;
  first;
end;

define method combine-regions
    (first :: <region>, second :: <compound-region>)
    => res :: <compound-region>;
  second.regions := pair(first, second.regions);
  first.parent := second;
  second;
end;


define method combine-regions
    (first :: <empty-region>, second :: <empty-region>)
    => res :: <empty-region>;
  make(<empty-region>);
end;

define method combine-regions
    (first :: <empty-region>, second :: <region>)
    => res :: <region>;
  second;
end;

define method combine-regions
    (first :: <region>, second :: <empty-region>)
    => res :: <region>;
  first;
end;


define method split-after (assign :: <abstract-assignment>)
    => (before :: <linear-region>, after :: <linear-region>);
  let next = assign.next-op;
  let region = assign.region;
  if (next)
    let last = region.last-assign;
    assign.next-op := #f;
    region.last-assign := assign;
    let new = make(<simple-region>);
    new.first-assign := next;
    next.prev-op := #f;
    new.last-assign := last;
    values(region, new);
  else
    values(region, make(<empty-region>));
  end;
end;

define method split-before (assign :: <abstract-assignment>)
    => (before :: <linear-region>, after :: <linear-region>);
  let prev = assign.prev-op;
  if (prev)
    split-after(prev);
  else
    values(make(<empty-region>), assign.region);
  end;
end;


define method insert-after (assign :: <abstract-assignment>,
			    insert :: <region>)
    => ();
  let region = assign.region;
  let parent = region.parent;
  let (before, after) = split-after(assign);
  let new = combine-regions(combine-regions(before, insert), after);
  new.parent := parent;
  replace-subregion(parent, region, new);
end;
    
define method insert-after (assign :: <abstract-assignment>,
			    insert :: <empty-region>)
    => ();
end;

define method insert-before (assign :: <abstract-assignment>,
			     insert :: <region>)
    => ();
  let region = assign.region;
  let parent = region.parent;
  let (before, after) = split-before(assign);
  let new = combine-regions(combine-regions(before, insert), after);
  new.parent := parent;
  replace-subregion(parent, region, new);
end;
    
define method insert-before (assign :: <abstract-assignment>,
			     insert :: <empty-region>)
    => ();
end;


define method replace-subregion
    (region :: <body-region>, old :: <region>, new :: <region>)
    => ();
  unless (region.body == old)
    error("Replacing unknown region");
  end;
  region.body := new;
end;

define method replace-subregion
    (region :: <if-region>, old :: <region>, new :: <region>)
    => ();
  if (region.then-region == old)
    region.then-region := new;
  elseif (region.else-region == old)
    region.else-region := new;
  else
    error("Replacing unknown region");
  end;
end;

define method replace-subregion
    (region :: <compound-region>, old :: <region>, new :: <region>)
    => ();
  for (regions = region.regions then regions.tail,
       until: regions == #() | regions.head == old)
  finally
    if (regions == #())
      error("Replacing unknown region");
    end;
    regions.head := new;
  end;
end;

define method replace-subregion
    (region :: <compound-region>, old :: <region>, new :: <empty-region>)
    => ();
  for (regions = region.regions then regions.tail,
       prev = #f then regions,
       until: regions == #() | regions.head == old)
  finally
    if (regions == #())
      error("Replacing unknown region");
    end;
    if (prev)
      prev.tail = regions.tail;
    elseif (regions.tail == #())
      let region-parent = region.parent;
      new.parent := region-parent;
      replace-subregion(region-parent, region, new);
    else
      parent.regions := regions.tail;
    end;
  end;
end;


// Sanity checking code.

define method check-sanity (component :: <component>) => ();
  //
  // Make sure the component's parent is #f.
  if (component.parent)
    error("Component %= has non-#f parent %=",
	  component, component.parent);
  end;
  //
  // Check the lambdas.
  for (lambda in component.all-methods)
    check-sanity(lambda);
  end;
end;

define method check-sanity (reg :: <simple-region>) => ();
  for (assign = reg.first-assign then assign.next-op,
       prev = #f then assign,
       while: assign)
    //
    // Check that the assigment has the correct region.
    unless (assign.region == reg)
      error("assignment %s claims %= as its region instead of %=",
	    assign, assign.region, reg);
    end;
    //
    // Check that the assignment is linked correctly.
    unless (assign.prev-op == prev)
      error("assignment %s claims %s as its predecessor instead of %s",
	    assign, assign.prev-op, prev);
    end;
    //
    // Check the defines.
    for (defn = assign.defines then defn.definer-next,
	 while: defn)
      unless (defn.definer == assign)
	error("assignment %s's result %s claims its definer is %s",
	      assign, defn, defn.definer);
      end;
    end;
    //
    // Check the dependent aspect of this assignment.
    check-dependent(assign);
  end;
end;

define method check-sanity (region :: <compound-region>) => ();
  for (subregion in region.regions)
    //
    // Check to make sure the subregion's parent is correct.
    unless (subregion.parent == region)
      error("%= claims %= for its parent instead of %=",
	    subregion, subregion.parent, region);
    end;
    //
    // Check the subregion.
    check-sanity(subregion);
  end;
end;

define method check-sanity (lambda :: <lambda>) => ();
  //
  // Check the expression aspects of the lambda.
  check-expression(lambda);
  //
  // Check the dependent aspects of the lambda.
  check-dependent(lambda);
  //
  // Check the lambda's body.
  unless (lambda.body.parent == lambda)
    error("%='s body %= claims %= as its parent",
	  lambda, lambda.body, lambda.body.parent);
  end;
  check-sanity(lambda.body);
end;


define method check-expression (expr :: <expression>) => ();
  //
  // Make sure all the dependents refer to this source.
  for (dep = expr.dependents then dep.source-next,
       while: dep)
    unless (dep.source-exp == expr)
      error("%s's dependent %= claims %s for its source-exp",
	    expr, dep, dep.source-exp);
    end;
  end;
end;

define method check-expression (op :: <operation>, #next next-method) => ();
  //
  // Check the expression aspects of an operation.
  next-method();
  //
  // Check the dependent aspects of an operation.
  check-dependent(op);
end;

define method check-dependent (dep :: <dependent-mixin>) => ();
  for (dependency = dep.depends-on then dependency.dependent-next,
       while: dependency)
    //
    // Make sure everything we depend on agrees.
    unless (dependency.dependent == dep)
      error("%s's dependency %= claims %s for its dependent",
	    dep, dependency, dep.dependent);
    end;
    //
    // Make make sure that source is okay.
    check-expression(dependency.source-exp);
  end;
end;



define method print-message
    (thing :: union(<expression>, <dependent-mixin>),
     stream :: <stream>)
    => ();
  dump(thing, stream);
end;
