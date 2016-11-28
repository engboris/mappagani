open Graphics;;
open Voronoi;;

module Variables = struct
  type t = (int * Graphics.color)
  let compare (i1, c1) (i2, c2) = if i1 > i2 then 1 else if i1 = i2 then 0 else -1
end;;

module Sat = Sat_solver.Make(Variables);;

(* ----------- Exceptions ----------- *)
exception NoSolution;;

(* _________________________________________
                 GENERATION
   _________________________________________ *)

let seeds_to_indices seeds : int list =
  let l = Array.length seeds in
  let rec aux i =
    if (i >= l) then []
    else i :: (aux (i+1))
  in aux 0;;

(* ----------- Existence ----------- *)
let clause_existence seeds colors_set : Sat.literal list list =
  let aux i = (List.map (fun c -> (true, (i, c))) colors_set)
  in (List.map (fun i -> aux i) (seeds_to_indices seeds));;

(* ----------- Unicity ----------- *)
let clausal_distribution c (cs : Sat.literal list) : Sat.literal list list =
  List.map (fun x -> c::[x]) cs;;
 
let clause_unicity seeds colors_set : Sat.literal list list =
  let psi i c =
    let other_colors = List.filter (fun x -> x <> c) colors_set in
    clausal_distribution (false, (i, c)) (List.map (fun c -> (false, (i, c))) other_colors)
  in let big_psi i = List.flatten (List.map (fun c -> psi i c) colors_set)
  in List.flatten (List.map big_psi (seeds_to_indices seeds));;

(* ----------- Adjacence ----------- *)
let clause_adjacence seeds (adj : bool array array) colors_set : Sat.literal list list =
  let psi i c =
    let adj_to_i = adjacents_to i adj in
    clausal_distribution (false, (i, c)) (List.map (fun v -> (false, (v, c))) adj_to_i)
  in let big_psi i = List.flatten (List.map (fun c -> psi i c) colors_set)
  in List.flatten (List.map big_psi (seeds_to_indices seeds));;

(* ----------- Presence ----------- *)
let clause_presence seeds : Sat.literal list list =
  let l = Array.length seeds in
  let rec aux i =
    if (i >= l) then []
    else 
      match seeds.(i).c with
      | None -> aux (i+1)
      | Some c -> [(true, (i, getCouleur seeds.(i).c))] :: (aux (i+1))
  in aux 0;;

let produce_constraints seeds adj colors_set : Sat.literal list list =
  (clause_existence seeds colors_set) @
  (clause_unicity seeds colors_set) @
  (clause_adjacence seeds adj colors_set) @
  (clause_presence seeds);;

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

let generate_coloring distanceF voronoi colors_set : Variables.t list =
  let adj = adjacences_voronoi voronoi (regions_voronoi distanceF voronoi) in
  let solving = Sat.solve (produce_constraints voronoi.seeds adj colors_set) in
  match solving with
  | None -> raise NoSolution
  | Some results ->
    let extraction = extract_coloring results in
    match extraction with
    | [] -> raise NoSolution
    | _ -> extraction;;
    
