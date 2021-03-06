module: client

/*
define method deliverable?(robot :: <robot>, s :: <state>, p :: <package>, 
			   #key capacity = robot.capacity-left)
  p.weight <= capacity & find-path(robot.location, p.location, s.board);
end method deliverable?;
*/

define method package-value(robot :: <robot>, s :: <state>, p :: <package>)
 => (v :: <integer>);
  if (deliverable?(robot, s, p))
    p.weight;
  else
    0;
  end if;
  
end method package-value;

define method try-pickup-many2(robot :: <robot>, s :: <state>, #key
                               package-list = packages-at(s, robot.location,
                                                          available-only: #t),
                               value-function = package-value,
                               capacity = robot.capacity,
                               return-function)
 => (c :: false-or(<command>));

  let packages = sort(package-list, 
                      test: method (a :: <package>, b :: <package>)
                              a.weight > b.weight;
                            end method);
                                            

  let table = make(<equal-table>);
  local method lookup(w, i)
   => (v, p :: <collection>);
    let e = element(table, cons(w, i), default: #"not-found");
//    debug("lookup(%=, %=)... ", w, i);
    if (e ~= #"not-found")
//      debug("cached\n");
      values(car(e), cdr(e));
    elseif (w = 0 | i = 0)
//      debug("0\n");
      values(0, #());
    elseif (packages[i - 1].weight > w)
      debug("too heavy\n");
      /*
        let good-keys = choose(method (a :: <pair>)
                                 a.head = w & a.tail < i;
                               end method, key-sequence(table));
        if (empty?(good-keys))
          0;
        else
          table[sort(good-keys, test: method (a :: <pair>, b :: <pair>)
                                        a.tail < b.tail;
                                      end method).last];                       
        end if;
      */
      let (value, pkgs) = lookup(w, i - 1);
      table[cons(w, i)] := cons(value, pkgs);
      values(value, pkgs);
    else
 //     debug("Evaluating...\n");
      if (value-function(robot, s, packages[i - 1]) + lookup(w - packages[i - 1].weight, i - 1)
            > lookup(w, i - 1))
        // Take it...
        let (rest-value, rest-pkgs) = lookup(w - packages[i - 1].weight, i - 1);
        let value = value-function(robot, s, packages[i - 1]) + rest-value;
        let pkgs = add(rest-pkgs, packages[i - 1]);
        table[cons(w, i)] := cons(value, pkgs);
        values(value, pkgs);
      else
        // Don't take it...
        let (value, pkgs) = lookup(w, i - 1);
        table[cons(w, i)] := cons(value, pkgs);
        values(value, pkgs);
      end if;
    end if;
  end method;

  let (value, take-these) = lookup(capacity, packages.size);
  if (~empty?(take-these))
    let pick = make(<pick>, 
                    bid: 1, 
                    package-ids: map(id, take-these),
                    id: robot.id);
    if (return-function)
      return-function(pick);
    end if;
    pick;
  else
    #f;
  end if;
end method try-pickup-many2;
