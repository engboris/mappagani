open Graphics;;

module Voronoi = Voronoi.VoronoiModule;;
open Voronoi;;
open Color_solver;;
open Graphics_plus;;

(* Parameters *)

let window_title = "Mappagani";;
let selected_color_label = "Couleur choisie";;

let border_x : int = 300;;
let generate_voronoi () : voronoi = Examples.select_voronoi ();;

(* _________________________________________
               MAIN FUNCTION
   _________________________________________ *)

type program_state = Play | Quit | End;;

let rec check_buttons x y buttons =
  match buttons with
  | [] -> ()
  | h::t ->
     if (coord_in_button x y h) then
       (h.action (); check_buttons x y t)
     else
       (check_buttons x y t);;

let update_current_color c board_pos board_size =
  let rec_y = 20 in
  let (x, y) = board_pos in
  let (l, h) = board_size in
  set_color c;
  fill_rect (x+l) (y-rec_y) (border_x) rec_y;
  set_color white;
  moveto (x+l+3) (y-rec_y+2);
  draw_string selected_color_label;;

let print_coord x y =
  moveto 100 100;
  set_color white;
  fill_rect 100 100 50 50;
  set_color black;
  draw_string (""^(string_of_int x)^";"^(string_of_int y));;

(* ----------- Main ----------- *)
let main () =
  auto_synchronize false;
  (* Settings *)
  let state = ref Play in
  let voronoi_main = generate_voronoi () in
  let regions = regions_voronoi distance_taxicab voronoi_main in
  let colors_set = generator_color_set voronoi_main in
  let (map_x, map_y) = voronoi_main.dim in
  let screen_x = map_x + border_x in
  let screen_y = map_y in
  set_window_title window_title;
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  (* Buttons *)
  let button_quit =
    create_menu_button (screen_x-250, 10) "Quitter" (fun () -> state := Quit) in
  draw_button button_quit;
  let button_reset =
    create_menu_button (top_of button_quit) "Recommencer" (fun () -> state := Quit) in
  draw_button button_reset;
  let button_newgame =
    create_menu_button (top_of button_reset) "Nouvelle carte" (fun () -> state := Quit) in
  draw_button button_newgame;
  let button_solution =
    let (tpbnx, tpbny) = top_of button_reset in
    let coloring = generate_coloring distance_euclide voronoi_main colors_set in
    let action_solution = (fun () -> (draw_voronoi regions (fill_seeds voronoi_main coloring)); state := End) in
    create_menu_button (tpbnx, tpbny+40) "Solution" action_solution in
  draw_button button_solution;
  let button_valider =
    create_menu_button (top_of button_solution) "Valider coloriage" (fun () -> state := Quit) in
  draw_button button_valider;
  (* Main loop *)
  draw_voronoi regions voronoi_main;
  update_current_color black (0, screen_y) (map_x, map_y);
  while (!state <> Quit) do
    synchronize ();
    let e = wait_next_event[Button_down] in
    let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
    check_buttons x_mouse y_mouse [button_quit; button_solution];
    if (coord_in_surface x_mouse y_mouse (0, 0) (map_x, map_y)) then
      let owner = regions.(x_mouse).(y_mouse) in
      let newcolor = voronoi_main.seeds.(owner).c in
      if (newcolor = None) then ()
      else update_current_color (getCouleur newcolor) (0, screen_y) (map_x, map_y)
    else
      ()
  done;
  (* let coloring = generate_coloring distance_euclide voronoi_main colors_set in
  draw_voronoi regions (fill_seeds voronoi_main coloring); *)
  close_graph ();;

main ();;

