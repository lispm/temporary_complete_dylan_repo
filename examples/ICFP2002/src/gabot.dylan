module: client

define constant <path> = <point-list>;


// ##################
// ## <strategy>
define abstract class <strategy>(<object>)
  slot strategy-robot :: <robot>;
  slot strategy-agent :: <robot-agent>;
end;

// ## valid?
define generic valid?(s :: <strategy>, s :: <state>) => valid :: <boolean>;
// ## safe?
define generic safe?(strategy :: <strategy>, me :: <gabot>, s :: <state>) => safe :: <boolean>;
// ## create-command
define generic create-command(s :: <strategy>) => command :: <command>;
// ## create-terminal-command
define generic create-terminal-command(s :: <strategy>, state :: <state>) => command :: <command>;


// ##################
// ## <gabot>
define class <gabot> (<dumbot>)
  slot decided :: <strategy>.false-or = #f;
end class <gabot>;

define method punt(me :: <gabot>)
 => punt :: <drop>;
  debug("GB: punting...\n");
  me.decided := #f;
  me.visited-bases := #();
  next-method();
end;


// ##################
// ## <path-strategy>
define abstract class <path-strategy>(<strategy>)
  slot approach :: <point>, required-init-keyword: approach:;
  /* virtual*/ slot strategy-path :: <path>, required-init-keyword: path:;
end;

/* ### not yet
define method strategy-path(strategy :: <path-strategy>) => way :: <path>;
  find-path(agent-pos(strategy.strategy-agent), strategy.approach, state.board)
end;
*/

define class <state-query>(<condition>)
end;

// ## create-command{<path-strategy>}
define method create-command(s :: <path-strategy>) => command :: <command>;
  let robot = s.strategy-robot;
  let path = s.strategy-path;
  let path = path.head = robot.location
             & path.tail
             | path;
  let path = s.strategy-path := path;
  
  let dir = points-to-direction(robot.location, path.first);
  let path = dir & path
                 | begin
                     let state = <state-query>.make.signal;
                     s.strategy-path := find-path(agent-pos(s.strategy-agent, state), s.approach, state.board)
                   end begin;
  
  make(<move>, direction: points-to-direction(robot.location, path.first), 
       bid: 1, id: robot.id);
end;

// ## safe?{<path-path>}
define method safe?(strategy :: <path-strategy>, me :: <gabot>, s :: <state>)
 => safe :: <boolean>;
  #t;
end method safe?;


// ##################
// ## <drop-strategy>
define concrete class <drop-strategy>(<path-strategy>)
end;

define function drop-strategy(drop-path :: <path>)
  make(<drop-strategy>, path: drop-path, approach: drop-path.last);
end;

define method valid?(dropping :: <drop-strategy>, s :: <state>) => valid :: <boolean>;
  // did we arrive?
  if (dropping.strategy-path.size < 2)
    debug("arrived!\n"); // TODO: if neihbor robots, bid more...
    #f
  else
    ~empty?(agent-packages(dropping.strategy-agent, s));
  end;
end;

// ## safe?{<drop-strategy>}
define method safe?(dropping :: <drop-strategy>, me :: <gabot>, s :: <state>)
 => safe :: <boolean>;
  // any bots around?
  //
  let position = agent-pos(me, s);
  
  local around(other :: <robot>)
          distance-cost(position, other.location) < 10;
        end;
      
  let bots = choose(around, as(<vector>, s.robots));

  local method nearer(a  :: <robot>, b :: <robot>) => nearer :: <boolean>;
          distance-cost(position, a.location) < distance-cost(position, b.location);
        end;

  let sorted-other-bots = as(<list>, sort!(bots, test: nearer)).tail; // sort, and let me out

  if (sorted-other-bots.empty?)
    #t
  else
    let nearest-bot = sorted-other-bots.first;

    distance-cost(position, dropping.approach) < distance-cost(position, nearest-bot.location)
    & distance-cost(position, dropping.approach) < distance-cost(dropping.approach, nearest-bot.location)
    //;/// TODO: all?(s.robots x path piints out-of-reach?)
  end if;
end method safe?;

// ## create-command{<drop-strategy>}
define method create-terminal-command(dropping :: <drop-strategy>, state :: <state>) => command :: <command>;
  debug("GB: Dropping in create-terminal-command\n");

// STOPGAP measure until   at-destination? works reliably
  let pos = agent-pos(dropping.strategy-agent, state);
  
  local method destined?(p :: <package>) => here :: <boolean>;
          p.dest == pos;
        end;
// END STOPGAP
        
        
  let destined-packages = choose(destined?, agent-packages(dropping.strategy-agent, state));
//  let destined-packages = choose(at-destination?, agent-packages(dropping.strategy-agent, state));
  make(<drop>, package-ids: map(id, destined-packages), bid: 1, id: dropping.strategy-robot.id);
end;



// ##################
// ## <pick-strategy>
define concrete class <pick-strategy>(<path-strategy>)
end;

define function pick-strategy(pick-path :: <path>)
  make(<pick-strategy>, path: pick-path, approach: pick-path.last);
end;



define function pick-compare(p1 :: <package>, p2 :: <package>)
 => better :: <boolean>;
  p1.weight > p2.weight // for now... TODO
end;

// ## create-command{<pick-strategy>}
define method create-terminal-command(picking :: <pick-strategy>, state :: <state>) => command :: <command>;
  debug("GB: Picking in create-terminal-command\n");
  let packs = load-packages(picking.strategy-agent, state, compare: pick-compare);
  packs.empty? & maybe-mark-base-visited(picking.strategy-agent, state, picking.approach);
  make(<pick>, package-ids: map(id, packs), bid: 1, id: picking.strategy-robot.id);
end;

define method valid?(picking :: <pick-strategy>, state :: <state>) => valid :: <boolean>;
  // did we arrive?
  let still-to-go = picking.strategy-path.size;
  
  if (still-to-go < 2)
    debug("GB: arrived!\n");
    #f
  else
    let nonsense
      = logand(still-to-go, 8) == 3
        & empty?(choose(curry(deliverable?,
                              agent-robot(picking.strategy-agent, state),
                              state),
                        packages-at(state,
                                    picking.approach)));
     
     nonsense & maybe-mark-base-visited(picking.strategy-agent, state, picking.approach);
     ~nonsense
  end;
end;



define function check-packages-around(me :: <gabot>, s :: <state>)
  => (thing, way :: <path>.false-or);
  let position = agent-pos(me, s);
block (return)
  local try(near-point :: <point>)
  	let packs = packages-at(s, near-point);
  	debug("try: %=, packages: %=\n", near-point, packs);
  	unless (packs.empty?)
  	  let path = find-path(position, near-point, s.board, cutoff: 3);
  	  return(path & packs.first, path)
  	end unless;
      end;

  let S = point(x: position.x, y: position.y - 1);
  try(S);

  let N = point(x: position.x, y: position.y + 1);
  try(N);

  let W = point(x: position.x - 1, y: position.y);
  try(W);

  let E = point(x: position.x + 1, y: position.y);
  try(E);

  let SE = point(x: position.x + 1, y: position.y - 1);
  try(SE);

  let NE = point(x: position.x + 1, y: position.y + 1);
  try(NE);

  let SW = point(x: position.x - 1, y: position.y - 1);
  try(SW);

  let NW = point(x: position.x - 1, y: position.y + 1);
  try(NW);
  
  let EE = point(x: position.x + 2, y: position.y);
  try(EE);

  let NN = point(x: position.x, y: position.y + 2);
  try(NN);

  if (position.y > 1)
    let SS = point(x: position.x, y: position.y - 2);
    try(SS);
  end;
  
  if (position.x > 1)
    let WW = point(x: position.x - 2, y: position.y);
    try(WW);
  end;
end block;

end;



define generic find-safest(me :: <gabot>, coll :: <sequence>, locator :: <function>, s :: <state>, #key weighting :: <function> = identity)
  => (thing, way :: <path>.false-or);

define method find-safest(me :: <gabot>, coll :: <sequence>, locator :: <function>, s :: <state>, #key weighting :: <function> = identity)
  => (thing, way :: <path>.false-or);

  let position = agent-pos(me, s);

    local find-near-safe-place(best-thing, best-path :: <path>)
         => (better-thing, better-path :: <path>);
         
         let distance = best-path == #()
                        & s.board.height + s.board.width + 1
                        | distance-cost(position, best-path.last);

          block (found)
            for (thing in coll)
              let thing-location = thing.locator;
              let path = find-path(position, thing-location, s.board, cutoff: best-thing & distance);
              debug("find-near-safe-place: thing: %=, path: %=\n", thing, path);
              if (path & ~path.empty?)
                if (~best-thing
                    | distance-cost(position, thing-location) < distance) // # FISHY TODO we should compare paths
                  let (better-thing, nearer-path)
                    = find-near-safe-place(thing, path);
                  found(better-thing, nearer-path)
                end if;
              end if;
            end for;
            values(best-thing, best-path)
          end block;
        end method;
  
  
  find-near-safe-place(#f, #());
end method find-safest;



// overall strategy:

// if we have an already cooked-up strategy, try to follow that if still safe 
// (possibly find a better strategy instead?)
// look for safe destinations where I can drop packets
// look for safe bases to pick up packets, or safe forgotten packets in the space
//   accounting for maybe-mark-base-visited
// look for vulnerable robots and I am not vulnerable then attack
// try escape from attackers
// unless empty and others run to a base, then push them (but not if there is water behind me)

define method generate-next-move(me :: <gabot>, s :: <state>)
  => c :: <command>;

  let bot = find-robot(s, me.agent-id);

block (return)
  let handler <state-query> = s.always;

  local method follow(strategy :: <strategy>)
          me.decided := strategy;
          strategy.strategy-robot := bot;
          strategy.strategy-agent := me;
          strategy.create-command.return;
        end;

  local method finish(strategy :: <strategy>)
          me.decided := #f;
          strategy.strategy-robot := bot;
          create-terminal-command(strategy, s).return;
        end;

debug("check\n");
  me.decided
    & (valid?(me.decided, s) | me.decided.finish)
    & safe?(me.decided, me, s)
    & me.decided.follow;
debug("check1\n");
  let (safe-drop, drop-path) = find-safest(me, choose(method(p :: <package>) debug("examining %=\n",p); p.dest & p.carrier & p.carrier.id == bot.id end, s.packages), dest, s, weighting: weight);
debug("check11\n");
  safe-drop & drop-path.drop-strategy.follow;
  
//  find-robot(state, agent).inventory
//  reduce(map(weight, packages), 0, \+)
  
debug("check111a\n");
  let (safe-pick, pick-path) = check-packages-around(me, s);
  safe-pick & pick-path.pick-strategy.follow;
  
  
  let (safe-pick, pick-path) = find-safest(me, unvisited-bases(me, s), identity, s, weighting: weight /* my payload */);
debug("check1111b\n");
  safe-pick & pick-path.pick-strategy.follow;
  
/*  ; not yet
  let safe-vulnerable = find-safest(me, s.robots, location, s, weighting: identity);
  safe-vulnerable & safe-vulnerable.kill-strategy.follow;
  */
  
debug("check11111\n");
  next-method()
end block;
end;