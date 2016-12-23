open Voronoi;;

module Variables : sig
  type t
  val compare : t -> t -> int
end

exception NoSolution

(* Génère une liste de coloriages valides pour un voronoi donné *)
val generate_coloring : (int * int -> int * int -> int) -> voronoi -> Graphics.color list -> int array array -> bool array array -> (int * Graphics.color) list

(* Vérifie si le coloriage d'un voronoi est valide *)
val check_coloring : voronoi -> bool array array -> bool
