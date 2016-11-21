#load "graphics.cma";;

open Graphics;;

type seed = { c : color option; x : int; y : int }
type voronoi = {dim : int * int; seeds : seed array}



let euclide (x1, y1) (x2,y2) =
  let x = (x1 - x2) * (x1 - x2) in
  let y = (y1 - y2) * (y1 - y2) in
  int_of_float (sqrt (float_of_int (x + y)));;


let texilab (x1, y1) (x2,y2) =
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

indice_of_min [|5; 5; 5; 5|];;
indice_of_min [|3; 5; 0; 2|];;
indice_of_min [|0; 2; 3; 9|];;
indice_of_min [|40; 12; 4; 0|];;



let seed_of_pixel (i,j) f v =
  indice_of_min (Array.map (fun s -> f (i,j) (s.x, s.y)) v.seeds);;


let regions_voronoi f v =
  let m = Array.make_matrix (fst v.dim) (snd v.dim) 0 in
  for i = 0 to (fst v.dim -1) do
    for j = 0  to (snd v.dim -1) do
      m.(i).(j) <- seed_of_pixel (i,j) f v
    done
  done;;


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

fst v1.dim;;
regions_voronoi euclide v1;;





