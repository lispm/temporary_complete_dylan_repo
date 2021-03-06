module:  pidigits
use-libraries: common-dylan, io, transcendental, dylan
use-modules: common-dylan, standard-io, streams, format-out, extensions

/*
 *  Based on Christopher Neufeld's  <shootout0000@cneufeld.ca>
 *  SBCL implementation.
 */

define constant $digits-per-line = 10;

define function compose-val (a1, a2)
  vector( 
          ( a1[0] * a2[0] ) + ( a1[1] * a2[2] ),
          ( a1[0] * a2[1] ) + ( a1[1] * a2[3] ),
          ( a1[2] * a2[0] ) + ( a1[3] * a2[2] ),
          ( a1[2] * a2[1] ) + ( a1[3] * a2[3] ) );
end function compose-val;

define function compute-pi ( *stop-digits*)
  let z = vector(#e1, #e0, #e0, #e1);
  let $curstate = vector( #e0, #e2, #e0, #e1 );

  local method extract-digit (state, x :: <integer> ) => result :: <extended-integer>;
        let numerator :: <extended-integer> = x * state[0] + state[1];
        let denominator :: <extended-integer> = x * state[2] + state[3];
        floor/ ( numerator, denominator );
      end method extract-digit;

  local method safe?( val, n ) => result :: <boolean>;
        n = extract-digit(val, 4);
      end method safe?;

  local method produce (val, n)
        compose-val( vector( 10, (n * -10), 0, 1 ), val );
      end method produce;

  local method next-digit (val)
        extract-digit( val, 3 );
      end method next-digit;

  local method consume (val, val-prime)
        compose-val(val, val-prime);
      end method consume;

  local method next-state () 
      $curstate[0] := ( $curstate[0] + 1 );
      $curstate[1] := ( $curstate[1] + 4 );
      $curstate[3] := ( $curstate[3] + 2 );  
      $curstate;
    end method next-state;

  let digits-out = 0;

  while ( digits-out < *stop-digits* )
    let y = next-digit( z );

    if ( safe?(z, y) )
      begin
        format-out( "%d", y );
        digits-out := digits-out + 1;
        if ( zero?( modulo( digits-out, $digits-per-line ) ) )
          format-out( "\t:%d\n", digits-out );
        end if;
        z := produce( z, y );
      end;
    else
        z := consume( z, next-state() );
    end if;
  end while;
end function compute-pi;
        
begin
  let *stop-digits* = 
    string-to-integer( element( application-arguments(), 0, default: "300"));

  compute-pi( *stop-digits* );
end;

