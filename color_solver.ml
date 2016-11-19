#load "sat_solver.cmo";;
#load "graphics.cma";;

open Graphics

module Variables = struct
  type t = (int * Graphics.color)
  let compare (i1, c1) (i2, c2) = if i1 > i2 then 1 else if i1 = i2 then 0 else -1   
end;;

module Sat = Sat_solver.Make(Variables);;

(*Temporary *)
type seed = { c : color option; x : int; y : int }
type voronoi = {dim : int * int; seeds : seed array};;
let v1 = {
  dim = 200,200;
  seeds = [|
    {c=Some red; x=50; y=100};
    {c=Some green; x=100; y=50};
    {c=Some blue; x=100; y=150};
    {c=None; x=150; y=100};
    {c=None; x=100; y=100}   (*square's seed*)
  |]
};;

(* _________________________________________ 
	    CONTRAINTS FORMULA GENERATION
   _________________________________________ *)

(* TODO : change colors *)
let c0 = Graphics.green;;
let c1 = Graphics.blue;;
let c2 = Graphics.red;;
let c3 = Graphics.black;;
let colors_set : Graphics.color list = [c0; c1; c2; c3];;

let seeds_to_indices seeds : int list =
  let l = Array.length seeds in
  let rec aux i =
    if (i >= l) then []
    else i :: (aux (i+1))
  in aux 0;;

(* ----------- Existence ----------- *)
let clause_existence seeds : Sat.literal list list = 
  let aux i = (List.map (fun c -> (true, (i, c))) colors_set)
  in (List.map (fun i -> aux i) (seeds_to_indices seeds));;

(* ----------- Unicity ----------- *)
let clausal_distribution c (cs : Sat.literal list) : Sat.literal list list =
  List.map (fun x -> c::[x]) cs;;
 
let clause_unicity seeds : Sat.literal list list =
  let psi i c =
    let other_colors = List.filter (fun x -> x <> c) colors_set in
    clausal_distribution (false, (i, c)) (List.map (fun c -> (false, (i, c))) other_colors)
  in let big_psi i = List.flatten (List.map (fun c -> psi i c) colors_set)
  in List.flatten (List.map big_psi (seeds_to_indices seeds));;

(* ----------- Adjacence ----------- *)
let adjacences_voronoi voronoi regions : bool array array = [||];;
let regions_voronoi distance voronoi : int array array = [||];;
let adjacents_to i adj : int list = [];;

let clause_adjacence seeds (adj : bool array array) : Sat.literal list list =
  let psi i c =
    let adj = adjacents_to i adj in
    clausal_distribution (false, (i, c)) (List.map (fun v -> (false, (v, c))) adj)
  in let big_psi i = List.flatten (List.map (fun c -> psi i c) colors_set)
  in List.flatten (List.map big_psi (seeds_to_indices seeds));;

let produce_constraints seeds (adj : bool array array) : Sat.literal list list =
  (clause_existence seeds) @ (clause_unicity seeds) @ (clause_adjacence seeds adj);;

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

let generate_coloring voronoi : Variables.t list option =
  let adj = adjacences_voronoi voronoi (regions_voronoi voronoi) in
  let solving = Sat.solve (produce_constraints voronoi.seeds adj) in
  match solving with
  | None -> None
  | Some results ->
    let extraction = extract_coloring results in
    match extraction with
    | [] -> None
    | _ -> Some extraction;;