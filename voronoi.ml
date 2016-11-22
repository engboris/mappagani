open Graphics;;

module VoronoiModule =
struct

type seed = { c : color option; x : int; y : int };;
type voronoi = { dim : int * int; seeds : seed array };;

let distance_euclide (x1, y1) (x2,y2) =
  let x = (x1 - x2) * (x1 - x2) in
  let y = (y1 - y2) * (y1 - y2) in
  int_of_float (sqrt (float_of_int (x + y)));;


let distance_taxicab (x1, y1) (x2,y2) =
  let x = abs (x1 - x2) in
  let y = abs (y1 - y2) in
  x + y;;

(*
Param :
f = fonction de calcul de distance (euclide ou texilab)
v = type voronoi
m = la matrice résultat
(i,j) couple des coordonnées du pixel

Renvoi une matrice de taille v.dim qui a, pour chaque valeurs l'indice du seed
le plus proche dans v.array
*)

let indice_of_min array =
  let l = Array.length array in
  let rec aux i min indiceMin =
    if(i >= l) then indiceMin
    else if (array.(i) < min) then aux (i+1) array.(i) i
    else aux (i+1) min indiceMin in
  aux 1 array.(0) 0;;


let seed_of_pixel (i,j) f v =
  indice_of_min (Array.map (fun s -> f (i,j) (s.x, s.y)) v.seeds);;


let regions_voronoi f v =
  let m = Array.make_matrix (fst v.dim) (snd v.dim) 0 in
  for i = 0 to (fst v.dim -1) do
    for j = 0  to (snd v.dim -1) do
      m.(i).(j) <- seed_of_pixel (i,j) f v
    done
  done;m;;

let print_matrix m =
  let maxX = Array.length m in
  let maxY = Array.length m.(0) in
  for i = 0 to maxX -1 do
    for j = 0 to maxY -1 do
      print_int m.(i).(j); print_string " ";
    done;
  print_string "\n";
  done;;


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


let draw_voronoi m v =
  auto_synchronize false;
  set_color black;
  let maxX = Array.length m in
  let maxY = Array.length m.(0) in
  for i = 0 to maxX - 1 do
    for j = maxY-1 downto 0 do
      let b = try (frontiere m i j) with | Invalid_argument "index out of bounds" -> true in
      if(b) then
	(set_color black;
	plot i j)
      else
	set_color (getCouleur (v.seeds.(m.(i).(j)).c));
        plot i j
    done;
  done; synchronize ();;





  (************************************)

let adjacences_voronoi voronoi regions =
  let n = Array.length voronoi.seeds in 
  let b = Array.make_matrix n n false in 
  let maxI = Array.length regions in 
  let maxJ = Array.length regions.(0) in 
  for h = 0 to n-1 do 
    for k = 0 to n-1 do 
      for i = 0 to maxI-1 do 
        for j = 0 to maxJ-1 do
          if(regions.(i).(j) = h && (k = regions.(i-1).(j) ||
       k = regions.(i+1).(j) ||
      k = regions.(i).(j-1) ||
       k = regions.(i).(j+1))) then 
          b.(h).(k) <- true
        done
      done
    done
  done; b;;

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


let get_list_couleurs seeds = 
  let l = Array.length seeds in
  let rec aux i = 
    if (i >= l) then []
    else if (seeds.(i).c <> None) then (getCouleur seeds.(i).c)::(aux (i+1))
  else aux (i+1)
  in aux 0;;   

end
