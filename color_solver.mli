open Voronoi;;

module Variables : sig
  type t
  val compare : t -> t -> int
end

val generate_coloring : (int * int -> int * int -> int) -> voronoi -> int array array -> Graphics.color list -> (int * Graphics.color) list
