open Graphics;;

module type STYLE = sig
    val blue : color;;
    val red : color;;
    val green : color;;
    val yellow : color;;
    val button_background : color;;
    val button_textcolor : color;;
    val button_bordercolor : color;;
    val button_hovercolor : color;;
    val default_width_menu_buttons : color;;
    val default_height_menu_buttons : color;;
end

module MakeStyle (Style : STYLE) : sig

type button = {
  coord : (int * int);
  size : (int * int);
  text : string;
  action : unit -> unit
}

(* Génère les boutons du menu *)
val create_menu_button : (int * int) -> string -> (unit -> unit) -> button

(* Vérifie si les coordonnées sont dans une surface *)
val coord_in_surface : int -> int -> (int * int) -> (int * int) -> bool

(* Renvoi la position juste au dessus d'un bouton *)
val top_of : button -> (int * int)

(* Dessine un bouton à l'écran *)
val draw_button : button -> unit

(* Vérifie si on appuie sur un bouton *)
val check_buttons : int -> int -> button list -> unit

(* Affiche une image à l'écran selon les coordonnées indiquées *)
val draw_picture : string -> (int * int) -> (int * int) -> unit

end
