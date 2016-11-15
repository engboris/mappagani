#load "sat_solver.cmo";;
#load "propositional_logic.cmo";;
#load "graphics.cma";;

open Graphics

module Variables = struct
  type t = (int * Graphics.color)
  let compare (i1, c1) (i2, c2) = if i1 > i2 then 1 else if i1 = i2 then 0 else -1   
end;;

module Sat = Sat_solver.Make(Variables);;
module Logic = Propositional_logic.Make(Variables);;

