type seed = { c : Graphics.color option; x : int; y : int; }
type voronoi = { dim : int * int; seeds : seed array; }

val distance_euclide : int * int -> int * int -> int
val distance_taxicab : int * int -> int * int -> int
val indice_of_min : 'a array -> int
val seed_of_pixel : 'a * 'b -> ('a * 'b -> int * int -> 'c) -> voronoi -> int
val regions_voronoi : (int * int -> int * int -> 'a) -> voronoi -> int array array
val adjacences_voronoi : voronoi -> int array array -> bool array array
val adjacents_to : int -> bool array array -> int list 
val print_matrix : int array array -> unit
(*val frontiere : 'a array array -> int -> int -> bool*)
val getCouleur : Graphics.color option -> Graphics.color
(*val draw_voronoi : int array array -> voronoi -> unit*)
val get_list_couleurs : seed array -> Graphics.color list
val fill_seeds : voronoi -> (int * Graphics.color) list -> voronoi
val generator_color_set : voronoi -> Graphics.color list
