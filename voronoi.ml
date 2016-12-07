open Graphics;;
(*  #load "graphics.cma";; *)

type seed = { c : color option; x : int; y : int };;
type voronoi = { dim : int * int; seeds : seed array };;


(***** Fonction d'affiche mode console pour des tests *****)
(*TODO : supprimer*)
let print_matrix m =
  let maxX = Array.length m in
  let maxY = Array.length m.(0) in
  for i = 0 to maxX -1 do
    for j = 0 to maxY -1 do
      print_int m.(i).(j); print_string " ";
    done;
  print_string "\n";
  done;;

(***** Fonctions de distance *****)
let distance_euclide (x1, y1) (x2,y2) =
  let x = (x1 - x2) * (x1 - x2) in
  let y = (y1 - y2) * (y1 - y2) in
  int_of_float (sqrt (float_of_int (x + y)));;


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


let regions_voronoi fonction voronoi =
  let dimX = fst voronoi.dim in
  let dimY = snd voronoi.dim in
  let m = Array.make_matrix dimX dimY 0 in
  Array.iteri (fun i line ->
     Array.iteri (fun j _ ->
      (line.(j) <- seed_of_pixel (i,j) fonction voronoi)) line) m; m;;


(***** Recuperation des pixels de chaque regions *****)
(*Liste de la forme [idRegions, [listePixel], ...]*)
(*let liste_of_pixel regions =
  let maxX = Array.length regions in 
  let maxY = Array.length regions.(0) in 
  Array.iteri fun i line -> 
  (Array.iteri fun j e -> (insert i j e) line) regions);;
*)
(***** Affichage de la carte depuis un Voronoi *****)


let frontiere m i j =
  let v = m.(i).(j) in
    ((i-1 > 0) && (m.(i-1).(j) <> v))
  || ((i+1 < Array.length m ) && (m.(i+1).(j) <> v))
  || ((j-1 > 0) && (m.(i).(j-1) <> v))
  || ((j+1 < Array.length m.(0)) && (m.(i).(j+1) <> v));;

let getCouleur (c:color option) = match c with
  | None -> 0xf0f0f0
  | Some a -> a;;

let draw_voronoi matrix voronoi =
  auto_synchronize false;
  set_color black;
  let maxY = Array.length matrix.(0) in
  Array.iteri (fun i line ->
   Array.iteri (fun j _ ->
	 let j' = maxY-1-j in
	 if((frontiere matrix i j')) then
	   (set_color black;
	   plot i j')
         else
	   set_color (getCouleur (voronoi.seeds.(matrix.(i).(j')).c));
	   plot i j') line) matrix; synchronize();;



(***** Calcul de la matrice d'adjacences *****)

let frontiere2 k m i j =
  ((i-1 > 0) && (m.(i-1).(j) = k))
  || ((i+1 < Array.length m ) && (m.(i+1).(j) = k))
  || ((j-1 > 0) && (m.(i).(j-1) = k))
  || ((j+1 < Array.length m.(0)) && (m.(i).(j+1) = k));;

let adjacences_voronoi voronoi regions =
  let n = Array.length voronoi.seeds in
  let b = Array.make_matrix n n false in
  let maxI = Array.length regions in
  let maxJ = Array.length regions.(0) in
  for h = 0 to n-1 do
    for k = 0 to n-1 do
      for i = 0 to maxI-1 do
        for j = 0 to maxJ-1 do
          if((regions.(i).(j) = h) && (frontiere2 k regions i j) && h <> k) then
            b.(h).(k) <- true
          else ()
        done;
      done;
    done;
  done; b;;


(***** Autre fonction utile pour la partie logique *****)

let rec insert value list = match list with
  | [] -> value::[]
  | h::t -> if(h = value) then h::t
            else if (value < h) then value::h::t
            else h::(insert value t);;


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
    | h::t -> if(List.length list = 4) then list
              else
              rajoute_couleurs (insert h list) t in
  rajoute_couleurs (supprime_double list_color) color_set;;
