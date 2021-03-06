module: stupid-predicting-cop

define class <stupid-predicting-cop> (<predicting-cop>)
  slot my-target-move :: <move>;
end class;

define method choose-move(cop :: <stupid-predicting-cop>, world :: <world>)
  cop.my-target-move;
end method choose-move;

define method make-plan(cop :: <stupid-predicting-cop>, world :: <world>) => (plan)
  let sorted-nodes
    = copy-sequence(sort(range(size: maximum-node-id()),
                         test: method(x, y)
                                   cop.probability-map[x] > cop.probability-map[y]
                               end), end: 5);

  let players = world.world-cops;
  let sorted-players = make(<stretchy-vector>);

  let transports = #();

  if(world.world-number = 1)
    let trans = list("cop-foot", "cop-car");
    for (i from 0 below players.size)
      transports := add!(transports, trans[modulo(i, trans.size)]);
    end for;
  end if;

  for(target in sorted-nodes)
    let remaining-players 
      = sort(players,
             test: method(x, y)
                       distance(x, target.find-node-by-id) 
                         < distance(y, target.find-node-by-id)
                   end method);
    add!(sorted-players, remaining-players[0]);
    players := remove!(players, remaining-players[0]);
  end for;
  
  let plan = make(<stretchy-vector>);

  let move-suggestions = make(<vector>);

  for (other-cop in sorted-players,
       my-target in sorted-nodes,
       i from 0)

    if(cop.probability-map[my-target] = 0.0s0)
      my-target := sorted-nodes[0];
    end;

    let moves = generate-moves-in-direction
      (other-cop, my-target,
       transport-type: if (world.world-number = 1)
                         transports[i];
                       end);

    moves := sort(moves, test: method(x,y)
                                   cop.probability-map[x.target.node-id] >
                                   cop.probability-map[y.target.node-id]
                               end);

    move-suggestions := add(move-suggestions, moves);

  end for;
  
  let generated-moves = #();
  for (move in move-suggestions,
       player in sorted-players)
    let target-move = block(return)
                        for (genmove in move)
                          for (occupied-moves in generated-moves)
                            if ((genmove.target ~= occupied-moves.target)
                                  & (genmove.transport ~= occupied-moves.transport))
                              return(genmove);
                            end if;
                          end for;
                        end for;
                      end block;
    unless (target-move)
      target-move := move[random(move.size)];
    end unless;
    if(player = cop.agent-player)
      cop.my-target-move := target-move;
    end if;
    generated-moves := add!(generated-moves, target-move);
    add!(plan, generate-plan(world,
                             player,
                             target-move));
  end for;


/*  for (p in plan)
    dbg("WORLD %s PLAN %s %s %s\n", world.world-number, p.plan-bot, p.plan-location.node-name, p.plan-type);
  end;*/
  plan
end method make-plan;

define method perceive-vote (vote,
                             cop :: <stupid-predicting-cop>,
                             world :: <world>);
  if (vote)
    //we'll just look whether the move is valid and do it, if it is.
    unless (vote = cop.agent-player.player-name)
      let plan-move =
        block(return)
          for (player in world.world-cops)
            if (player.player-name = vote)
              for (move in cop.planned-moves)
                if (head(move) = vote)
                  return(tail(move))
                end if;
              end for;
            end if
          end for;
        end block;
      if (plan-move)
        //dbg("change away from move %s ", cop.my-target-move.target.node-name);
        cop.my-target-move := plan-move;
        /*dbg("changed move: from %s to %s by %s\n",
            cop.agent-player.player-location.node-name,
            plan-move.target.node-name,
            plan-move.transport);*/
      end if;
    end unless;
    //dbg("WINNER: %s\n", vote);
  end if;
end method perceive-vote;
