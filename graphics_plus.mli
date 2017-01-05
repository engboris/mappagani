open Graphics;;

module type STYLE = sig
    val blue : color;;
    val red : color;;
    val green : color;;
    val yellow : color;;
    val button_background : color;;
    val button_textcolor : color;;
    val button_inactive_textcolor : color;;
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
  action : unit -> unit;
  mutable active : bool
}

type menu = button list;;

(* _________________________________________
              AFFICHAGE GLOBAL
   _________________________________________ *)

(* Colorie l'ensemble de la fenêtre en noir *)
val set_blackscreen : unit -> unit

(* _________________________________________
                  BUTTONS
   _________________________________________ *)

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

(* Desactive / Active un bouton *)
val disable_button : button -> unit
val enable_button : button -> unit

(* Change l'apparence des boutons si le curseur est dessus *)
val check_hover : int -> int -> button list -> unit

(* _________________________________________
                  MENU
   _________________________________________ *)

(* Dessine les boutons d'un menu *)
val draw_menu : menu -> unit

(* Desactive / Active les boutons d'un menu *)
val disable_menu : menu -> unit
val enable_menu : menu -> unit

(* _________________________________________
                  IMAGES
   _________________________________________ *)

(* Affiche une image à l'écran selon les coordonnées indiquées *)
val draw_picture : string -> (int * int) -> (int * int) -> unit

end
