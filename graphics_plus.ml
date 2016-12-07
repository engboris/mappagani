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

module MakeStyle (Style : STYLE) = struct

(* _________________________________________
                  BUTTONS
   _________________________________________ *)

type button = {
  coord : (int * int);
  size : (int * int);
  text : string;
  action : unit -> unit
};;

(* ----------- Functions ----------- *)
let create_menu_button c s a =
  {coord = c;
   size = (Style.default_width_menu_buttons, Style.default_height_menu_buttons);
   text = s;
   action = a};;

let coord_in_surface x y pos size : bool =
  let (blx, bly) = pos and (l, h) = size in
  (x > blx && x < blx+l && y > bly && y < bly+h);;

let coord_in_button x y button : bool =
  coord_in_surface x y button.coord button.size;;

let draw_button_primitive background button =
  let (blx, bly) = button.coord and (l, h) = button.size in
  set_color background;
  fill_rect blx bly l h;
  set_color Style.button_bordercolor;
  draw_rect blx bly l h;
  set_color Style.button_textcolor;
  let (string_x, string_y) = text_size button.text in
  moveto (blx+(l/2)-(string_x/2)) (bly+(h/2)-(string_y/2));
  draw_string button.text;
  synchronize ();;

let top_of button : (int * int) =
  let (px, py) = button.coord in
  let (l, h) = button.size in
  (px, py+h);;

let draw_button = draw_button_primitive Style.button_background;;

let rec check_buttons x y buttons =
match buttons with
| [] -> ()
| h::t ->
   if (coord_in_button x y h) then
     (h.action (); check_buttons x y t)
   else
     (check_buttons x y t);;

end
