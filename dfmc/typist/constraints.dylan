module: dfmc-typist

define abstract class <constraint> (<object>)
  constant slot left-hand-side :: <node>,
    required-init-keyword: left:;
  constant slot right-hand-side :: <node>,
    required-init-keyword: right:;
end;

define class <equality-constraint> (<constraint>)
end;

define method make (class :: subclass(<constraint>), #rest init-args, #key, #all-keys) => (res :: <constraint>)
  let c = next-method();
  constraint-connect(c.left-hand-side, c.right-hand-side);
  c;
end;

define function solve (graph :: <graph>, constraints :: <collection>, type-env :: <type-environment>)
 => ()
  let cs = copy-dynamic(constraints);
  constraints.size := 0;
  local method push-cs (l :: <node>, r :: <node>)
          let new-constraint = make(<equality-constraint>, left: l, right: r);
          push-last(cs, new-constraint);
        end;
  for (node in graph.nodes)
    node.contains-variables? := #t;
  end;
  while (~cs.empty?)
    debug-types(#"relayouted");
    let constraint = cs.pop;
    debug-types(#"highlight-constraint", constraint.left-hand-side, constraint.right-hand-side);
    let u = find(constraint.left-hand-side);
    let v = find(constraint.right-hand-side);
    if (u ~= v)
      let (u, v, flag) = order(u, v);
      let ute = u.node-value;
      let vte = v.node-value;
      graph-union(u, v, flag);
      block()
        solve-constraint(ute, vte, u, v, push-cs)
          & disconnect(constraint.left-hand-side, constraint.right-hand-side);
      exception (e :: <error>)
        error("constraint %= cannot be satisfied", constraint);
      end;
    end;
    debug-types(#"unhighlight-constraint", constraint.left-hand-side, constraint.right-hand-side);
  end;
  let quotient-graph = create-quotient-graph(graph);
  if (acyclic?(quotient-graph))
    do(method(x)
         if (instance?(x.node-value, <&type-variable>))
           let rep-type = x.find.node-value;
           if (instance?(rep-type, <&type>) & ~instance?(rep-type, <&type-variable>))
             format-out("changed TV %= to contain type %= now\n", x.node-value.get-id, rep-type);
             x.node-value.^type-variable-contents := rep-type;
           end
         end
       end, graph.nodes);
  else
    error("type graph %= contains cycles!", quotient-graph)
  end;
end;

define generic solve-constraint
 (t1 :: <&type>, t2 :: <&type>, u :: <node>, v :: <node>, push-constraint :: <function>)
 => (disconnect? :: <boolean>);

define method solve-constraint
 (t1 :: <&arrow-type>, t2 :: <&arrow-type>, u :: <node>, v :: <node>, push-constraint :: <function>)
 => (disconnect? :: <boolean>)
  for (u1 in u.successors, v1 in v.successors)
    push-constraint(u1, v1);
  end;
  #t;
end;

define method solve-constraint
 (t1 :: <&arrow-type>, t2 :: <&top-type>, u :: <node>, v :: <node>, push-constraint :: <function>)
 => (disconnect? :: <boolean>)
  if (u.contains-variables?)
    u.contains-variables? := #f;
    for (u1 in u.successors)
      let w1 = make(<node>, graph: u.graph, value: make(<&top-type>));
      push-constraint(w1, u1);
    end;
    #t;
  end;
end;

define method solve-constraint
 (t1 :: <&tuple-type>, t2 :: <&tuple-type>, u :: <node>, v :: <node>, push-constraint :: <function>)
 => (disconnect? :: <boolean>)
  for (u1 in u.successors, v1 in v.successors)
    //need to take care that required and rest parameters are correct
    if ((instance?(u1.node-value, <&rest-type>) & instance?(v1.node-value, <&rest-type>)) |
        (~instance?(u1.node-value, <&rest-type>) & ~instance?(v1.node-value, <&rest-type>)))
      push-constraint(u1, v1);
    end;
  end;
  if (u.successors.size ~= v.successors.size)
    let (larger, shorter)
      = if (u.successors.size > v.successors.size) values(u, v) else values(v, u) end;
    if (instance?(shorter.successors.last.node-value, <&rest-type>))
      for (i from shorter.successors.size - 1 below larger.successors.size)
        let t = make(<node>, graph: u.graph, value: make(<&top-type>));
        push-constraint(larger.successors[i], t);
      end;
    end;
  end;
  #t;
end;

define method solve-constraint
 (t1 :: <&tuple-type>, t2 :: <&top-type>, u :: <node>, v :: <node>, push-constraint :: <function>)
 => (disconnect? :: <boolean>)
  if (u.contains-variables?)
    format-out("solving tuple == top\n");
    u.contains-variables? := #f;
    for (u1 in u.successors)
      let w1 = make(<node>, graph: u.graph, value: make(<&top-type>));
      push-constraint(u1, w1);
    end;
    #t;
  end;
end;

define method solve-constraint
 (t1 :: <&type>,
  t2 :: type-union(<&type-variable>, <&top-type>, <&rest-type>),
  u :: <node>, v :: <node>, push-constraint :: <function>)
 => (disconnect? :: <boolean>)
  //move along
end;

define method solve-constraint
 (t1 :: <&type>, t2 :: <&type>, u :: <node>, v :: <node>, push-constraint :: <function>)
 => (disconnect? :: <boolean>)
  if (^subtype?(t2, t1) | ^subtype?(t1, t2))
    //move along
  else
    error("constraint cannot be satisfied");
  end;
end;

define function copy-dynamic (constraints :: <collection>)
 => (res :: <deque>)
  let to-remove = make(<stretchy-vector>);
  let res =
  as(<deque>,
     map(method(x)
           let left = copy-dyn(x.left-hand-side.node-value, x.left-hand-side);
           let right = copy-dyn(x.right-hand-side.node-value, x.right-hand-side);
           if (left ~= x.left-hand-side | right ~= x.right-hand-side)
             disconnect(x.left-hand-side, x.right-hand-side);
             if (left ~= x.left-hand-side)
               //remove-node(x.left-hand-side);
               unless (member?(x.left-hand-side, to-remove))
                 add!(to-remove, x.left-hand-side);
               end;
             end;
             if (right ~= x.right-hand-side)
               //remove-node(x.right-hand-side);
               unless (member?(x.right-hand-side, to-remove))
                 add!(to-remove, x.right-hand-side);
               end;
             end;
             make(<equality-constraint>, left: left, right: right)
           else
             x
           end;
         end, constraints));
  do(remove-node, to-remove);
  res;
end;

define method copy-dyn (t :: <&top-type>, n :: <node>) => (node :: <node>)
  make(<node>, graph: n.graph, value: n.node-value);
end;

define method copy-dyn (t :: <&arrow-type>, n :: <node>) => (node :: <node>)
  let args = copy-dyn(t.^arguments.node-value, t.^arguments);
  let values = copy-dyn(t.^values.node-value, t.^values);
  if (args ~= t.^arguments | values ~= t.^values)
    //retract old arrow node?
    make(<node>, graph: n.graph,
         value: make(<&arrow-type>,
                     arguments: args,
                     values: values));
  else
    n
  end;
end;

define method copy-dyn (t :: <&tuple-type>, n :: <node>) => (node :: <node>)
  let tt = map(method(x) copy-dyn(x.node-value, x) end, t.^tuple-types);
  let need-copy? = #f;
  for (t1 in tt, t2 in t.^tuple-types)
    unless (t1 = t2)
      need-copy? := #t;
    end;
  end;
  if (need-copy?)
    make(<node>, graph: n.graph,
         value: make(<&tuple-type>,
                     tuples: tt))
  else
    n
  end;
end;

define method copy-dyn (t :: <&type>, n :: <node>) => (node :: <node>)
  n
end;

define function order (u :: <node>, v :: <node>)
 => (first :: <node>, second :: <node>, order-matters? :: <boolean>)
  let tu = node-value(u);
  let tv = node-value(v);
  if (dynamic?(tu)) 
    if (instance?(tv, <&type-variable>))
      values(u, v, #t);
    else
      values(v, u, #t);
    end;
  elseif (instance?(tu, <&type-variable>))
    values(v, u, #t);
  elseif (instance?(tv, <&type-variable>))
    values(u, v, #t);
  else
    values(u, v, #f);
  end;
end;

