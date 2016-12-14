open Graphics;;

type seed = { c : color option; x : int; y : int };;
type voronoi = { dim : int * int; seeds : seed array };;

(***** Fonctions de distance *****)
let distance_euclide (x1, y1) (x2,y2) =
  let x = (x1 - x2) * (x1 - x2) in
  let y = (y1 - y2) * (y1 - y2) in
  (x + y);;

let distance_taxicab (x1, y1) (x2,y2) =
  let x = abs (x1 - x2) in
  let y = abs (y1 - y2) in
  x + y;;


(***** Calcul de la matrice des regions *****)
let indice_of_min array =
  let l = Array.length array in
  let rec aux i min indiceMin =
    if(i >= l) then indiceMin
    else if (array.(i) < min) then aux (i+1) array.(i) i
    else aux (i+1) min indiceMin in
  aux 1 array.(0) 0;;

let seed_of_pixel (i,j) fonction voronoi =
  indice_of_min (Array.map (fun s -> fonction (i,j) (s.x, s.y)) voronoi.seeds);;

let regions_and_pixelList fonction voronoi =
  let dimX = fst voronoi.dim in
  let dimY = snd voronoi.dim in
  let m = Array.make_matrix dimX dimY 0 in
  let array_of_list_pixel = Array.make (Array.length voronoi.seeds) [] in
  Array.iteri (fun i line ->
       Array.iteri (fun j _ ->
	  let seed = seed_of_pixel (i,j) fonction voronoi in
	  (line.(j) <- seed;
	  (array_of_list_pixel.(seed) <- (i,j)::array_of_list_pixel.(seed)))) line) m;
  (m, array_of_list_pixel);;

let liste_pixels fonction voronoi =
  snd (regions_and_pixelList fonction voronoi);;
let regions_voronoi fonction voronoi =
  fst (regions_and_pixelList fonction voronoi);;


(***** Calcul de la matrice d'adjacences *****)
let get_frontieres regions i j =
  let result = ref [] in
  let v = regions.(i).(j) in
  (if ((i-1 > 0) && (regions.(i-1).(j) <> v)) then
    result := (regions.(i).(j), regions.(i-1).(j)) :: (!result)
  else if ((i+1 < Array.length regions) && (regions.(i+1).(j) <> v)) then
    result := (regions.(i).(j), regions.(i+1).(j)) :: (!result)
  else if ((j-1 > 0) && (regions.(i).(j-1) <> v)) then
    result := (regions.(i).(j), regions.(i).(j-1)) :: (!result)
  else if ((j+1 < Array.length regions.(0)) && (regions.(i).(j+1) <> v)) then
    result := (regions.(i).(j), regions.(i).(j+1)) :: (!result));
  !result;;

let adjacences_voronoi voronoi regions =
  let n = Array.length voronoi.seeds in
  let b = Array.make_matrix n n false in
  Array.iteri (fun i line ->
    Array.iteri (fun j _ ->
      let adj = get_frontieres regions i j in
      List.iter (fun (x, y) -> b.(x).(y) <- true) adj) line) regions;
  b;;


(***** Autre fonction utile pour la partie logique *****)
let getCouleur (c:color option) = match c with
  | None -> 0xf0f0f0
  | Some a -> a;;

let rec insert value list = match list with
  | [] -> value::[]
  | h::t when h = value -> h::t
  | h::t when value < h -> value::h::t
  | h::t -> h::(insert value t);;

let adjacents_to i adj =
  let l = Array.length adj in
  let rec aux j tab  =
    if(j >= l) then tab
    else if (adj.(i).(j)) then aux (j+1) (j::tab)
    else aux (j+1) tab in
  aux 0 [];;

let rec fill_seeds voronoi list_color = match list_color with
| [] -> voronoi
| (i, c')::t ->
  voronoi.seeds.(i) <- {c=Some c'; x=voronoi.seeds.(i).x; y=voronoi.seeds.(i).y};
  fill_seeds voronoi t;;

let get_list_couleurs seeds =
  let l = Array.length seeds in
  let rec aux i =
    if (i >= l) then []
    else if (seeds.(i).c <> None) then (getCouleur seeds.(i).c)::(aux (i+1))
  else aux (i+1)
  in aux 0;;

let generator_color_set voronoi =
  let list_color = get_list_couleurs voronoi.seeds in
  let color_set = [yellow; magenta; cyan; red; blue; green;black; white;] in
  let rec supprime_double list =
  match list with
  | [] -> []
  | h::t -> insert h (supprime_double t) in
  let rec rajoute_couleurs list color_set = match color_set with
    | [] -> failwith "plus de 4 couleurs"
    | h::t when List.length list = 4 -> list
    | h::t -> rajoute_couleurs (insert h list) t in
  rajoute_couleurs (supprime_double list_color) color_set;;
