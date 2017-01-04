(* ==================================================
 *                    VORONOI
 * ==================================================
 *   Manipulation des voronoi indépendamment de toute
 * notion d'affichage, d'interface graphique et de jeu.
 * -------------------------------------------------- *)

open Graphics;;

type seed = {
  c : color option;
  x : int;
  y : int
};;

type voronoi = {
  dim : int * int; 
  seeds : seed array
};;

exception NoVoronoi;;

(* _________________________________________
           FONCTIONS DE DISTANCE
   _________________________________________ *)

let distance_euclide (x1, y1) (x2,y2) : int =
  let x = (x1 - x2) * (x1 - x2) in
  let y = (y1 - y2) * (y1 - y2) in
  (x + y);;

let distance_taxicab (x1, y1) (x2,y2) : int =
  let x = abs (x1 - x2) in
  let y = abs (y1 - y2) in
  x + y;;

(* _________________________________________
            MATRICE DES REGIONS
   _________________________________________ *)

let indice_of_min array : int =
  let l = Array.length array in
  let rec aux i min indiceMin =
    if (i >= l) then indiceMin
    else if (array.(i) < min) then aux (i+1) array.(i) i
    else aux (i+1) min indiceMin
  in aux 1 array.(0) 0;;

let seed_of_pixel (i,j) fonction voronoi : int =
  indice_of_min (Array.map (fun s -> fonction (i,j) (s.x, s.y)) voronoi.seeds);;

let regions_and_pixelList fonction voronoi =
  let (dimX, dimY) = voronoi.dim in
  let m = Array.make_matrix dimX dimY 0 in
  let array_of_list_pixel = Array.make (Array.length voronoi.seeds) [] in
  Array.iteri (fun i line ->
    Array.iteri (fun j _ ->
	    let seed = seed_of_pixel (i,j) fonction voronoi in
	    (line.(j) <- seed;
	    (array_of_list_pixel.(seed) <- (i,j)::array_of_list_pixel.(seed))))
    line)
  m;
  (m, array_of_list_pixel);;

(* _________________________________________
             MATRICE D'ADJACENCE
   _________________________________________ *)

let get_frontieres regions i j : (int * int) list =
  let result = ref [] in
  let v = regions.(i).(j) in
  (if ((i-1 > 0) && (regions.(i-1).(j) <> v)) then
    result := (regions.(i).(j), regions.(i-1).(j)) :: (!result));
  (if ((i+1 < Array.length regions) && (regions.(i+1).(j) <> v)) then
    result := (regions.(i).(j), regions.(i+1).(j)) :: (!result));
  (if ((j-1 > 0) && (regions.(i).(j-1) <> v)) then
    result := (regions.(i).(j), regions.(i).(j-1)) :: (!result));
  (if ((j+1 < Array.length regions.(0)) && (regions.(i).(j+1) <> v)) then
    result := (regions.(i).(j), regions.(i).(j+1)) :: (!result));
  !result;;

let adjacences_voronoi voronoi regions : bool array array =
  let n = Array.length voronoi.seeds in
  let b = Array.make_matrix n n false in
  Array.iteri (fun i line ->
    Array.iteri (fun j _ ->
      let adj = get_frontieres regions i j in
      List.iter (fun (x, y) -> b.(x).(y) <- true) adj) line)
    regions;
  b;;

(* _________________________________________
          SELECTION DE VORONOI
   _________________________________________ *)

let select_voronoi voronoi_list : voronoi =
  let l = List.length (!voronoi_list) in
  if (l = 0) then
     raise NoVoronoi
  else
    begin
      Random.self_init ();
      let e = List.nth !voronoi_list (Random.int l) in
      voronoi_list := List.filter (fun x -> x <> e) !voronoi_list;
      e
    end;;

(* _________________________________________
           FONCTIONS AUXILIAIRES
   _________________________________________ *)

let seeds_to_indices seeds : int list =
  let last_index = (Array.length seeds)-1 in
  Array.fold_left (fun acc s ->
    if (acc = []) then last_index::acc
    else (List.hd acc)-1 :: acc)
  [] seeds;;
  
let getCouleur (c : color option) =
  match c with
  | None -> 0xf0f0f0
  | Some a -> a;;

let rec insert value l =
  match l with
  | [] -> value::[]
  | h::t when h = value -> h::t
  | h::t when value < h -> value::h::t
  | h::t -> h::(insert value t);;

let adjacents_to i adj : int list =
  let l = Array.length adj in
  let rec aux j tab  =
    if (j >= l) then tab
    else if (adj.(i).(j)) then aux (j+1) (j::tab)
    else aux (j+1) tab in
  aux 0 [];;

let rec fill_seeds voronoi list_color =
  match list_color with
  | [] -> voronoi
  | (i, c')::t ->
    voronoi.seeds.(i) <- {c=Some c'; x=voronoi.seeds.(i).x; y=voronoi.seeds.(i).y};
    fill_seeds voronoi t;;

let get_list_couleurs seeds : color list =
  let l = Array.length seeds in
  let rec aux i =
    if (i >= l) then []
    else if (seeds.(i).c <> None) then (getCouleur seeds.(i).c)::(aux (i+1))
    else aux (i+1)
  in aux 0;;

let generator_color_set voronoi : color list =
  let list_color = get_list_couleurs voronoi.seeds in
  let rec supprime_double l =
  match l with
  | [] -> []
  | h::t -> insert h (supprime_double t) in
  supprime_double list_color;;

let is_complete_voronoi voronoi : bool =
  Array.fold_left (fun acc s -> (s.c <> None) && acc) true voronoi.seeds;;
