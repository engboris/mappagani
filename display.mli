open Graphics;;
open Voronoi;;
open Style;;

(* Dessine un graphe de connexion entre les regions *)
val draw_graph : voronoi -> bool array array -> unit

(* Determine si le case (i, j) est une frontiere *)
val frontiere : seed array array -> int -> int -> bool

(* Dessine les reperes de seeds orignalement colories d'un voronoi *)
val draw_seedmark : voronoi -> unit

(* Dessine la carte correspondant au voronoi en argument *)
val draw_voronoi : int array array -> voronoi -> unit

(* Met a jour la couleur de l'unique region du seed d'indice i *)
val draw_regions : int array array -> voronoi -> (int * int) list array -> int -> unit

(* Dessine un ecran noir a la place de la carte de facon progressive *)
val draw_blackscreen : voronoi -> (int * int) list array -> int array array -> unit