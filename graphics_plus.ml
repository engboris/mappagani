(* ==================================================
 *                 GRAPHICS PLUS
 * ==================================================
 *   Super-ensemble de la bibliothèque Graphics d'Ocaml
 * permettant de gérer des boutons simples, un menu de
 * boutons et l'affichage d'images bitmap (.bmp).
 * Les boutons créer peuvent être stylisés et apparaître
 * comme actifs ou inactifs pour le programme.
 * -------------------------------------------------- *)

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

module MakeStyle (Style : STYLE) = struct

(* _________________________________________
              AFFICHAGE GLOBAL
   _________________________________________ *)

let set_blackscreen () =
  auto_synchronize false;
  set_color black;
  let size_X = size_x () and size_Y = size_y () in
  fill_rect 0 0 size_X size_Y;
  synchronize ();;

(* _________________________________________
                  BOUTONS
   _________________________________________ *)

(* ----------- Types ----------- *)
type button = {
  coord : (int * int);
  size : (int * int);
  text : string;
  action : unit -> unit;
  mutable active : bool
};;

type menu = button list;;

(* ----------- Fonctions ----------- *)
let create_menu_button c s a : button =
  {coord = c;
   size = (Style.default_width_menu_buttons, Style.default_height_menu_buttons);
   text = s;
   action = a;
   active = true};;

let coord_in_surface x y pos size : bool =
  let (blx, bly) = pos and (l, h) = size in
  (x > blx && x < blx+l && y > bly && y < bly+h);;

let coord_in_button x y button : bool =
  coord_in_surface x y button.coord button.size;;

let draw_button_primitive background foreground button =
  let (blx, bly) = button.coord and (l, h) = button.size in
  set_color background;
  fill_rect blx bly l h;
  set_color Style.button_bordercolor;
  draw_rect blx bly l h;
  set_color foreground;
  let (string_x, string_y) = text_size button.text in
  moveto (blx+(l/2)-(string_x/2)) (bly+(h/2)-(string_y/2));
  draw_string button.text;
  synchronize ();;

let top_of button : (int * int) =
  let (px, py) = button.coord in
  let (l, h) = button.size in
  (px, py+h);;

let draw_button button =
  if (button.active) then
    draw_button_primitive Style.button_background Style.button_textcolor button
  else
    draw_button_primitive Style.button_background Style.button_inactive_textcolor button;;

let hover button : unit =
  if (button.active) then
    draw_button_primitive Style.button_hovercolor Style.button_textcolor button
  else
    draw_button_primitive Style.button_hovercolor Style.button_inactive_textcolor button;;

let unhover = draw_button;;

let check_hover x y buttons : unit =
  List.iter (fun b -> if coord_in_button x y b then hover b else unhover b) buttons;;

let rec check_buttons x y buttons : unit =
  List.iter (fun b -> if coord_in_button x y b then b.action ()) buttons;;

let disable_button button : unit = button.active <- false;;

let enable_button button : unit = button.active <- true;;

(* _________________________________________
                  MENU
   _________________________________________ *)

let draw_menu menu =
  List.iter (fun b -> if b.active then draw_button b else draw_button b) menu;;

let disable_menu menu = List.iter disable_button menu;;

let enable_menu menu = List.iter enable_button menu;;

(* _________________________________________
                  IMAGES
   _________________________________________ *)

let green_to_exclude : int = 0x00FF21;;

let make_picture filename (w, h) : image =
  let m = Array.make_matrix h w transp in
  let channel = open_in_bin filename in
  try (
    seek_in channel 54;
    for i = 0 to h-1 do
      for j = 0 to w-1 do
        let b = input_byte channel in
        let g = input_byte channel in
        let r = input_byte channel in
        let pixel = rgb r g b in
        (m.(h-1-i).(j) <- (if pixel = green_to_exclude then transp else pixel))
      done;
      if w <> h then let _ = input_byte channel in ();
    done;
    close_in channel;
    make_image m)
  with End_of_file ->
  close_in channel;
  make_image m;;

let draw_picture filename (imageH, imageW) (screen_x, screen_y) =
  let logo = make_picture filename (imageH, imageW) in
  draw_image logo screen_x screen_y;
  synchronize ();;

end
