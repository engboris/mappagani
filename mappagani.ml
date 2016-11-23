open Graphics;;

module Voronoi = Voronoi.VoronoiModule;;
open Voronoi;;
open Color_solver;;
open Graphics_plus;;

let v1 = {
  dim = 200,200;
  seeds = [|
    {c=Some red; x=50; y=100};
    {c=Some green; x=100; y=50};
    {c=Some blue; x=100; y=150};
    {c=None; x=150; y=100};
    {c=None; x=100; y=100}   (*square's seed*)
  |]
};;

(* Parameters *)

let border_x : int = 300;;

let generate_voronoi () : voronoi = v1;;

(* _________________________________________
               MAIN FUNCTION
   _________________________________________ *)

type program_state = Play | Quit;;

let rec check_buttons x y buttons =
  match buttons with
  | [] -> ()
  | h::t ->
    if coord_in_button x y h then
      (h.action (); check_buttons x y t)
    else
      (check_buttons x y t);;

let update_current_color c board_pos board_size =
  let rec_y = 20 in
  let (x, y) = board_pos in
  let (l, h) = board_size in
  set_color c;
  fill_rect (x+l) (y-rec_y) (border_x) rec_y;;

let print_coord x y =
  moveto 100 100;
  set_color white;
  fill_rect 100 100 50 50;
  set_color black;
  draw_string (""^(string_of_int x)^";"^(string_of_int y));;

(* ----------- Main ----------- *)
let main () =
  (* Settings *)
  let state = ref Play in
  let voronoi_main = generate_voronoi () in
  let colors_set = get_list_couleurs voronoi_main.seeds in
  let (map_x, map_y) = voronoi_main.dim in
  let screen_x = map_x + border_x in
  let screen_y = map_y in
  set_window_title "Mappagani";
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  (* Buttons *)
  let button_quit =
    create_menu_button (screen_x-250, 50) "Quitter" (fun () -> state := Quit) in
  draw_button button_quit;
  (* Main loop *)
  let regions = regions_voronoi distance_euclide voronoi_main in
  draw_voronoi regions voronoi_main;
  update_current_color black (0, screen_y) (map_x, map_y);
  while (!state <> Quit) do 
    let e = wait_next_event[Button_down] in
    let m = wait_next_event[Mouse_motion] in
    let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
    print_coord m.mouse_x m.mouse_y;
    check_buttons x_mouse y_mouse [button_quit];
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

