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

(* ----------- Parameters ----------- *)
let button_background = white;;
let button_textcolor = black;;
let button_bordercolor = black;;
let button_hovercolor = cyan;; 

(* ----------- Functions ----------- *)
let create_menu_button c s a =
  {coord = c; size = (200, 30); text = s; action = a};;

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
  draw_string button.text;;

let draw_button = draw_button_primitive button_background;;

let hover_on = draw_button_primitive button_hovercolor;;
let hover_off = draw_button;;
  
