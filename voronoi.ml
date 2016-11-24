open Graphics;;

module VoronoiModule =
struct

type seed = { c : color option; x : int; y : int };;
type voronoi = { dim : int * int; seeds : seed array };;


(***** Fonction d'affiche mode console pour des tests *****)

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
  let m = Array.make_matrix (fst voronoi.dim) (snd voronoi.dim) 0 in
  for i = 0 to (fst voronoi.dim -1) do
    for j = 0  to (snd voronoi.dim -1) do
      m.(i).(j) <- seed_of_pixel (i,j) fonction voronoi
    done
  done;m;;


(***** Affichage de la carte depuis un Voronoi *****)


let frontiere m i j =
  let v = m.(i).(j) in
	  if(v != m.(i-1).(j) ||
	     v != m.(i+1).(j) ||
	     v != m.(i).(j-1) ||
	     v != m.(i).(j+1)) then
	    true
	  else
	    false;;

let getCouleur (c:color option) = match c with
  | None -> white
  | Some a -> a;;


(*TODO : fixme*)
let draw_voronoi matrix voronoi =
  auto_synchronize false;
  set_color black;
  let maxX = Array.length matrix in
  let maxY = Array.length matrix.(0) in
  for i = 0 to maxX - 1 do
    for j = maxY-1 downto 0 do
      let b = try (frontiere matrix i j) with | Invalid_argument "index out of bounds" -> true in
      if(b) then
	(set_color black;
	plot i j)
      else
	set_color (getCouleur (voronoi.seeds.(matrix.(i).(j)).c));
        plot i j
    done;
  done; synchronize ();;





  (***** Calcul de la matrice d'adjacences *****)

  let frontiere2 k m i j =
    if(k = m.(i-1).(j) ||
       k = m.(i+1).(j) ||
       k = m.(i).(j-1) ||
       k = m.(i).(j+1)) then
      true
    else
      false;;

let adjacences_voronoi voronoi regions =
  let n = Array.length voronoi.seeds in 
  let b = Array.make_matrix n n false in 
  let maxI = Array.length regions in 
  let maxJ = Array.length regions.(0) in 
  for h = 0 to n-1 do 
    for k = 0 to n-1 do 
      for i = 0 to maxI-1 do 
        for j = 0 to maxJ-1 do
          let tmp = try (frontiere2 k regions i j) with | Invalid_argument "index out of bounds" -> false in 
          if((regions.(i).(j) = h) && (tmp)) then 
           b.(h).(k) <- true
        done
      done
    done
  done; b;;


(***** Autre fonction utile pour la partie logique *****)

let adjacents_to i adj = 
  let l = Array.length adj in
  let rec aux j tab  =
    if(j >= l) then tab
    else if (adj.(i).(j)) then j::tab
    else aux (i+1) tab in
  aux 0 [];;


let rec fill_seeds voronoi list_color = match list_color with
| [] -> voronoi
| (i, c')::t ->
  voronoi.seeds.(i) <- {c=Some c'; x=voronoi.seeds.(i).x; y=voronoi.seeds.(i).y};
  fill_seeds voronoi t;;


let generator_color_set listColor = 
  let color_set = [black; white; red; green; blue; yellow; cyan; magenta] in
  print_string "TODO";;

let get_list_couleurs seeds = 
  let l = Array.length seeds in
  let rec aux i = 
    if (i >= l) then []
    else if (seeds.(i).c <> None) then (getCouleur seeds.(i).c)::(aux (i+1))
  else aux (i+1)
  in aux 0;;   



end
