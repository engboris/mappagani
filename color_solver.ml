#load "sat_solver.cmo";;
#load "propositional_logic.cmo";;
#load "graphics.cma";;

module Variables = struct
  type t = (int * Graphics.color)
  let compare (i1, c1) (i2, c2) = if i1 > i2 then 1 else if i1 = i2 then 0 else -1   
end;;

module Sat = Sat_solver.Make(Variables);;
module Logic = Propositional_logic.Make(Variables);;

(* _________________________________________ 
	    CONTRAINTS FORMULA GENERATION
   _________________________________________ *)

(* TODO : change colors *)
let c0 = Graphics.green;;
let c1 = Graphics.blue;;
let c2 = Graphics.red;;
let c3 = Graphics.black;;
let colors_set : Graphics.color list = [c0; c1; c2; c3];;

let list_to_indices (ls : 'a list) : int list =
  let rec aux ls' i =
  match ls' with
  | [] -> []
  | _::t -> i :: (aux t (i+1))
  in aux ls 0;;

let clause_existence seeds : Logic.literal list list = 
  let aux i = List.map (fun c -> (true, (i, c))) colors_set
  in (List.map (fun i -> aux i) (list_to_indices seeds));;

let clausal_or_distribution c (cs : Logic.literal list) : Logic.literal list list =
  List.map (fun x -> c::[x]) cs;;
 
let clause_unicity seeds : Logic.literal list list =
  let phi i c =
    let other_colors = List.filter (fun x -> x <> c) colors_set in
    clausal_or_distribution (false, (i, c)) (List.map (fun c -> (false, (i, c))) other_colors)
  in let big_psy i = List.flatten (List.map (fun c -> phi i c) colors_set)
  in List.flatten (List.map big_psy (list_to_indices seeds));;

let clause_adjacence : Logic.literal list list = [];;

let produce_contraints seeds adj : Logic.literal list list =
  (clause_existence seeds @ clause_unicity seeds @ clause_adjacence);;