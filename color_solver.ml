#load "sat_solver.cmo";;
#load "graphics.cma";;

module Variables = struct
  type t = (int * Graphics.color)
  let compare (i1, c1) (i2, c2) = if i1 > i2 then 1 else if i1 = i2 then 0 else -1   
end;;

module Sat = Sat_solver.Make(Variables);;

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

(* ----------- Existence ----------- *)
let clause_existence seeds : Logic.literal list list = 
  let aux i = (List.map (fun c -> (true, (i, c))) colors_set)
  in (List.map (fun i -> aux i) (list_to_indices seeds));;

(* ----------- Unicity ----------- *)
let clausal_distribution c (cs : Logic.literal list) : Logic.literal list list =
  List.map (fun x -> c::[x]) cs;;
 
let clause_unicity seeds : Logic.literal list list =
  let psi i c =
    let other_colors = List.filter (fun x -> x <> c) colors_set in
    clausal_distribution (false, (i, c)) (List.map (fun c -> (false, (i, c))) other_colors)
  in let big_psi i = List.flatten (List.map (fun c -> psi i c) colors_set)
  in List.flatten (List.map big_psi (list_to_indices seeds));;

(* ----------- Adjacence ----------- *)
let adjacents_regions i seeds = [5];;

let clause_adjacence seeds : Logic.literal list list =
  let psi i c = clausal_distribution 
    (false, (i, c)) (List.map (fun v -> (false, (v, c))) (adjacents_regions i seeds))
  in let big_psi i = List.flatten (List.map (fun c -> psi i c) colors_set)
  in List.flatten (List.map big_psi (list_to_indices seeds));;

let produce_constraints seeds adj : Logic.literal list list =
  (clause_existence seeds @ clause_unicity seeds @ clause_adjacence seeds);;

(* _________________________________________ 
	    		RESOLUTION
   _________________________________________ *)

let rec extract_coloring results : Variables.t list =
  match results with
  | [] -> []
  | (b, v)::rs ->
    if b then
      v :: (extract_coloring rs)
    else
      extract_coloring rs;;

let generate_coloring seeds adj : Variables.t list option =
  let solving = Sat.solve (produce_constraints seeds adj) in
  match solving with
  | None -> None
  | Some results ->
    let extraction = extract_coloring results in
    match extraction with
    | [] -> None
    | _ -> Some extraction;;