open Voronoi;;

module Variables : sig
  type t
  val compare : t -> t -> int
end

val generate_coloring : (int * int -> int * int -> int) -> voronoi -> Graphics.color list -> int array array -> (int * Graphics.color) list
