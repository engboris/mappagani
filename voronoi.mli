type seed = { c : Graphics.color option; x : int; y : int; }
type voronoi = { dim : int * int; seeds : seed array; }

exception NoVoronoi
                 
(* Distance euclidienne *)
val distance_euclide : int * int -> int * int -> int

(* Distance taxicab *)
val distance_taxicab : int * int -> int * int -> int

(* Renvoi la matrices des régions ainsi qu'une liste  *)
val regions_and_pixelList : (int * int -> int * int -> 'a) -> voronoi -> (int array array * (int*int) list array)

(* Génère la matrice d'adjacence *)
val adjacences_voronoi : voronoi -> int array array -> bool array array

(* Renvoi la liste des voisins d'un seed *)
val adjacents_to : int -> bool array array -> int list

(* Transforme un tableau de seeds en tableau d'indices *)
val seeds_to_indices : seed array -> int list

(* Transforme un color option en color *)
val getCouleur : Graphics.color option -> Graphics.color

(* Si il y a moins de 4 couleurs sur le voronoi de base, rajoute des couleurs jusqu'à en avoir 4 *)
val generator_color_set : voronoi -> Graphics.color list

(* Vérification du voronoi *)
val is_complete_voronoi : voronoi -> bool

(* Sélection voronoi *)
val select_voronoi : voronoi list ref -> voronoi
