open Graphics

(* ==================================================
 *                 		STYLE
 * ==================================================
 *   Simple définition du style du programme : c'est
 * à dire les couleurs utilisées. Ce fichier peut être
 * vu comme une extension (ou masquage) des couleurs
 * du module Graphics d'OCaml.
 * -------------------------------------------------- *)

(* _________________________________________
                  GENERAL
   _________________________________________ *)

let black : color = 0x4b4848;;
let blue : color  = 0x94cbe3;;
let red : color  = 0xe88091;;
let green : color  = 0x9ded87;;
let yellow : color  = 0xf7fc8b;;
let cyan : color  = 0xc0ffff;;
let magenta : color  = 0xc975bb;;
let white : color  = 0x808080;;

let background_color : color  = 0x333536;;

(* _________________________________________
                  BOUTONS
   _________________________________________ *)

let button_background : color  = 0x333536;;
let button_textcolor : color  = 0xffffff;;
let button_inactive_textcolor : color  = 0x5a5a5a;;
let button_bordercolor : color  = 0x57cdff;;
let button_hovercolor : color  = white;;

let default_width_menu_buttons : int = 200;;
let default_height_menu_buttons : int = 30;;
