module: bruce-robber


define class <bruce-robber> (<robber>)
  slot goal-banks :: <stretchy-object-vector> = make(<stretchy-vector>);
end class <bruce-robber>;


define function find-accessable-banks(robber :: <bruce-robber>, world :: <world>)
 => ();
  if (robber.goal-banks.empty?)
    let nodes-by-id = world.world-skeleton.world-nodes-by-id;

    for (bank :: <bank> in world.world-banks)
      let node = bank.bank-location;
      let reachable = make(<vector>, size: nodes-by-id.size);
      let escape-routes = node.moves-by-foot;
      for (node :: <node> in escape-routes)
        reachable[node.node-id] := #t;
      end;
      let reachable-next = make(<vector>, size: nodes-by-id.size);
      for (i from 0 below reachable.size)
        if (reachable[i])
          for (node :: <node> in nodes-by-id[i].moves-by-foot)
            reachable-next[node.node-id] := #t;
          end;
          reachable-next[i] := #t;
        end;
      end;
      
      let numReachable = 0;
      for (ok in reachable-next)
        if (ok)
          numReachable := numReachable + 1;
        end
      end;

      dbg("bank at %d numreachable in two moves is %d\n", node.node-id, numReachable);
      if (numReachable >= 10)
        add!(robber.goal-banks, bank.bank-location);
      end;
    end;
  end;
end find-accessable-banks;


define constant *cop-probability* = 100000000;

define function count-greater-than(v :: <int-vector>, min :: <integer>)
 => (count :: <integer>, total-prob :: <integer>);
  let count = 0;
  let prob = 0;
  for (i in v)
    if (i > min)
      count := count + 1;
    end;
    prob := prob + i;
  end;
  values(count, prob);
end count-greater-than;


define method choose-move(robber :: <bruce-robber>, world :: <world>)
  find-accessable-banks(robber, world);
  let max-iterations = 4;
  let node-lookup = world.world-skeleton.world-nodes-by-id;
  let num-nodes = node-lookup.size;

  let cop-foot-prob = make(<int-vector>, size: num-nodes, fill: 0);
  let cop-car-prob = make(<int-vector>, size: num-nodes, fill: 0);

  let cop-total-prob = make(<stretchy-vector>);

  local method save-cop-probabilities(cop-foot-prob :: <int-vector>,
                                      cop-car-prob :: <int-vector>)
          let totals = make(<int-vector>, size: num-nodes, fill: 0);
          for (i from 0 below num-nodes)
            totals[i] := cop-foot-prob[i] + cop-car-prob[i];
          end;
          add!(cop-total-prob, totals);
        end method save-cop-probabilities;


  // set up tables, knowing where cops are right now
  for (cop :: <player> in world.world-cops)
    let node-id = cop.player-location.node-id;
    if (cop.player-type = "cop-foot")
      cop-foot-prob[node-id] := cop-foot-prob[node-id] + *cop-probability*;
    else
      cop-car-prob[node-id] := cop-car-prob[node-id] + *cop-probability*;
    end;
  end for;

  for (i from 1 to max-iterations)
    let new-cop-foot-prob = make(<int-vector>, size: num-nodes, fill: 0);
    let new-cop-car-prob = make(<int-vector>, size: num-nodes, fill: 0);

    let hq-node =
      block (return)
        for (node :: <node> in node-lookup)
          if (node.node-tag = "hq")
            return(node);
          end;
        end;
      end;

    local method spread-probs(probs :: <int-vector>,
                              new-probs :: <int-vector>,
                              move-selector) => ();
            for (i from 0 below num-nodes)
              let prob = probs[i];
              if (prob > 0)
                let node = node-lookup[i];
                let curr-node-id = node.node-id;
                if (node == hq-node)
                  let prob = truncate/(prob, node.moves-by-foot.size + node.moves-by-car.size + 2);
                  let foot-moves :: <stretchy-object-vector> = node.moves-by-foot;
                  let car-moves :: <stretchy-object-vector> = node.moves-by-car;
                  for (move :: <node> in foot-moves)
                    let target-id = move.node-id;
                    new-cop-foot-prob[target-id] := new-cop-foot-prob[target-id] + prob;
                  end;
                  for (move :: <node> in car-moves)
                    let target-id = move.node-id;
                    new-cop-car-prob[target-id] := new-cop-car-prob[target-id] + prob;
                  end;
                  new-cop-foot-prob[curr-node-id] := new-cop-foot-prob[curr-node-id] + prob;
                  new-cop-car-prob[curr-node-id] := new-cop-car-prob[curr-node-id] + prob;
                else
                  let moves :: <stretchy-object-vector> = node.move-selector;
                  let prob = truncate/(prob, moves.size + 1);
                  for (move :: <node> in moves)
                    let target-id = move.node-id;
                    new-probs[target-id] := new-probs[target-id] + prob;
                  end for;
                  new-probs[curr-node-id] := new-probs[curr-node-id] + prob;
                end if; //hq
              end if; //prob nonzero
            end for; // all nodes
          end method spread-probs;

    spread-probs(cop-foot-prob, new-cop-foot-prob, moves-by-foot);
    spread-probs(cop-car-prob, new-cop-car-prob, moves-by-car);

    save-cop-probabilities(new-cop-foot-prob, new-cop-car-prob);
    cop-foot-prob := new-cop-foot-prob;
    cop-car-prob := new-cop-car-prob;

    let (foot-places, foot-prob) = count-greater-than(cop-foot-prob, 0);
    let (car-places, car-prob) = count-greater-than(cop-car-prob, 0);
    /*
    dbg("round %d, places cops could be, foot: %d (%d), car: %d (%d)\n",
        i,
        foot-places, foot-prob,
        car-places, car-prob);
    */

  end for; // iterating cop probabilities
  
  /*
  dbg("\n\nby foot probability function: ");
  for (i in cop-foot-prob)
    dbg("%d  ", i);
  end;
  dbg("\n\nby car probability function: ");
  for (i in cop-car-prob)
    dbg("%d  ", i);
  end;
  dbg("\n\n");
  */

  //let goal = world.world-banks[robber.goal-bank].bank-location;
  
  let my-location = world.world-robber.player-location;

  let (distances-to, safest-paths) =
    find-safe-paths(cop-total-prob,
                    my-location);
  
  let shortest-path-len = 2000000001;
  let shortest-path = #();
  let smallest-diff = 1000000;
  for (bank :: <bank> in world.world-banks)    
    if (bank.bank-money > 0 &
          member?(bank.bank-location, robber.goal-banks))
          //cop-total-prob[0][bank.bank-location.node-id] == 0)
      let bank-node-id = bank.bank-location.node-id;
      let path = safest-paths[bank-node-id];
      let dist = distances-to[bank-node-id];
      let diff = dist + dist - path.size;
      if (dist < shortest-path-len)
      //if (diff < smallest-diff)
        smallest-diff := diff;
        shortest-path-len := dist;
        shortest-path := path;
      end;
    end;
  end for;

  let shortest-path = shortest-path.reverse;
  let next-node = shortest-path.head;

  dbg("safest path (len %d, score %d) = %=\n",
      shortest-path.size, shortest-path-len,
      map(node-id, shortest-path));

  if (shortest-path.empty?)
    dbg("too hot for me .. let's get outta here...\n");
    
    // find the safest node we can reach
    let danger :: <int-vector> = cop-total-prob[0];
    let safest-place = my-location;
    let best-safety = danger[safest-place.node-id];
    for (node :: <node> in my-location.moves-by-foot)
      block (next)
        let safety = danger[node.node-id];
        dbg("safety at %d = %d\n", node.node-id, safety);
        if (safety <= best-safety)
          // make sure it's not a bank
          for (bank :: <bank> in world.world-banks)
            let bank-node = bank.bank-location;    
            if (node == bank-node)
              dbg("dont rob that bank!!\n");
              next();
            end;
          end;

          best-safety := safety;
          safest-place := node;
        end if;
      end block;
    end for;
    
    dbg("instead we'll go to %d with safety %d\n", safest-place.node-id, best-safety);
    next-node := safest-place;
  end;


  for (bank :: <bank> in world.world-banks)
    let bank-node = bank.bank-location;    
    if (next-node == bank-node)
      dbg("hey!!! we're about to rob a bank!!\n");
      //robber.goal-bank := next-bank(world, robber.goal-bank);
    end;
  end;

  make(<move>, target: next-node, transport: "robber");

end method choose-move;


        

define function find-safe-paths
    (danger :: <stretchy-object-vector>,
     from-node :: <node>)
 => (distance-to :: <int-vector>, shortest-paths :: <simple-object-vector>)

  let immediate-danger :: <int-vector> = danger[0];
  let smell-range :: <int-vector> = danger[2];
  let cop-density :: <int-vector> = danger[danger.size - 1];

  let distance-to =
    make(<int-vector>, size: maximum-node-id(), fill: 2000000000);
  distance-to[from-node.node-id] := 0;
  let shortest-path :: <simple-object-vector> =
    make(<vector>, size: maximum-node-id(), fill: #());

  let todo-nodes = make(<deque>);
  let fudge :: <integer> = truncate/(*cop-probability*, 100);

  local method search (start :: <node>) => ();
          let start-id = start.node-id;
          let path-to-start = shortest-path[start-id];
          let distance-to-start = distance-to[start-id];  // increment distance is now variable
          block (return)
            let moves :: <stretchy-object-vector> = start.moves-by-foot;
            for (next :: <node> in moves)
              let next-id = next.node-id;
              
              let imminent-danger-level = immediate-danger[next-id];
              let smell-level = smell-range[next-id];
              let cop-probability = cop-density[next-id];
              let cost = 1 +
                case
                  imminent-danger-level > 0 => 999999;
                  smell-level > 0 => 5;
                  cop-probability == 0 => 0;
                  //cop-probability >= *cop-probability* => 999999;
                  otherwise => round/(cop-probability, fudge);
                end;

              if (distance-to[next-id] > distance-to-start)
                distance-to[next-id] := distance-to-start + cost;
                shortest-path[next-id] := add!(path-to-start, next);
                push-last(todo-nodes, next);
              end if;
            end for;
            if (todo-nodes.size = 0)
              return();
              //error("Graph not connected");
            end if;
            search(todo-nodes.pop);
          end;
        end method;

  search(from-node);
  values(distance-to, shortest-path);
end;
