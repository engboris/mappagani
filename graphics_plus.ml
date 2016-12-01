open Graphics;;

(* _________________________________________
                  BUTTONS
   _________________________________________ *)

type button = {
  coord : (int * int);
  size : (int * int);
  text : string;
  action : unit -> unit
};;

(* ----------- Style ----------- *)
let background_color = 0x333536;;
let button_background = 0x333536;;
let button_textcolor = white;;
let button_bordercolor = 0x57cdff;;
let button_hovercolor = cyan;;

let default_width_menu_buttons = 200;;
let default_height_menu_buttons = 30;;

(* ----------- Functions ----------- *)
let create_menu_button c s a =
  {coord = c;
   size = (default_width_menu_buttons, default_height_menu_buttons);
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
  set_color button_bordercolor;
  draw_rect blx bly l h;
  set_color button_textcolor;
  let (string_x, string_y) = text_size button.text in
  moveto (blx+(l/2)-(string_x/2)) (bly+(h/2)-(string_y/2));
  draw_string button.text;
  synchronize ();;

let top_of button : (int * int) =
  let (px, py) = button.coord in
  let (l, h) = button.size in
  (px, py+h);;

let draw_button = draw_button_primitive button_background;;

let rec check_buttons x y buttons =
match buttons with
| [] -> ()
| h::t ->
   if (coord_in_button x y h) then
     (h.action (); check_buttons x y t)
   else
     (check_buttons x y t);;