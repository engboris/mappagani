open Voronoi;;

module Variables : sig
  type t
  val compare : t -> t -> int
end
 
exception NoSolution
val seeds_to_indices : seed array -> int list
val generate_coloring : (int * int -> int * int -> int) -> voronoi -> Graphics.color list -> int array array -> bool array array -> (int * Graphics.color) list
val check_coloring : voronoi -> bool array array -> bool
