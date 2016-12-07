open Graphics;;
open Voronoi;;

module Variables = struct
  type t = (int * Graphics.color)
  let compare (i1, c1) (i2, c2) = Pervasives.compare i1 i2
end;;

module Sat = Sat_solver.Make(Variables);;

(* ----------- Exceptions ----------- *)
exception NoSolution;;

(* _________________________________________
                 GENERATION
   _________________________________________ *)

let seeds_to_indices seeds : int list =
  let last_index = (Array.length seeds)-1 in
  Array.fold_left (fun acc s ->
    if (acc = []) then last_index::acc
    else (List.hd acc)-1 :: acc)
  [] seeds;;

let add_to_all e ls = List.map (fun x -> e::[x]) ls;;

let make_pairs e ls = List.map (fun x -> (e, x)) ls;;

let all_color_pairs colors_set =
  let colors_set_copy = colors_set in
  let rec aux cs =
  match cs with
  | [] -> []
  | h::t -> (make_pairs h colors_set_copy) @ (aux t)
  in List.filter (fun (x, y) -> x <> y) (aux colors_set);;

(* ----------- Existence ----------- *)
let clause_existence seeds colors_set acc : Sat.literal list list =
  (* Le seed d'identifiant i a au moins une couleur *)
  let seed_has_color i = (List.map (fun c -> (true, (i, c))) colors_set)
  (* Cette regle s'applique a tout seed, on ajoute chaque contrainte a l'accumulateur *)
  in List.fold_left (fun a i -> seed_has_color i :: a) acc (seeds_to_indices seeds);;

(* ----------- Unicity ----------- *)
let clause_unicity seeds_indices colors_pairs acc : Sat.literal list list =
  (* Pour tout couple c1,c2 de couleurs possible soit le seed i ne peut avoir qu'un des deux *)
  let seed_choice i (c1, c2) = [(false, (i, c1)); (false, (i, c2))] in
  (* On applique ce choix pour tous les couples de couleurs *)
  List.fold_left (fun a color_pair ->
    List.fold_left (fun a' seed_index ->
      seed_choice seed_index color_pair :: a') a seeds_indices) acc colors_pairs;;

(* ----------- Adjacence ----------- *)
let clause_adjacence seeds_indices (adj : bool array array) colors_set acc : Sat.literal list list =
  (* Si le seed i a une couleur c, soit i n'a pas la couleur c soit son voisin j ne l'a pas *)
  let seed_adj_exclusion i j c = [(false, (i, c)); (false, (j, c))] in
  (* La restriction s'applique a toute couleur et tout seed *)
  List.fold_left (fun a index ->
    let adj_to_i = adjacents_to index adj in
    List.fold_left (fun a' neighbour -> 
      List.fold_left (fun a'' color ->
        seed_adj_exclusion index neighbour color :: a'') a' colors_set) a adj_to_i) acc seeds_indices

(* ----------- Presence ----------- *)
let clause_presence seeds acc : Sat.literal list list =
  let l = Array.length seeds in
  let rec aux i acc =
    if (i >= l) then acc
    else 
      match seeds.(i).c with
      | None -> aux (i+1) acc
      | Some c -> aux (i+1) ([(true, (i, getCouleur seeds.(i).c))]::acc)
  in aux 0 acc;;

let produce_constraints seeds adj colors_set : Sat.literal list list =
  let seeds_indices = seeds_to_indices seeds in
  let colors_pairs = all_color_pairs colors_set in
  (clause_presence seeds
    (clause_existence seeds colors_set
      (clause_unicity seeds_indices colors_pairs
        (clause_adjacence seeds_indices adj colors_set []))));;

(* _________________________________________
                 RESOLUTION
   _________________________________________ *)

let rec extract_coloring results : Variables.t list =
  List.fold_left (fun acc (b, v) -> if b then v::acc else acc) [] results;;

let generate_coloring distanceF voronoi colors_set regions : (int * Graphics.color) list =
  let adj = adjacences_voronoi voronoi regions in
  let solving = Sat.solve (produce_constraints voronoi.seeds adj colors_set) in
  match solving with
  | None -> raise NoSolution
  | Some results ->
    let extraction = extract_coloring results in
    match extraction with
    | [] -> raise NoSolution
    | _ -> extraction;;
