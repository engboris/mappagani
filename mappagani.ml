open Graphics;;
open Voronoi;;
open Color_solver;;
open Graphics_plus;;

(* _________________________________________
               PARAMETERS
   _________________________________________ *)

let window_title = "Mappagani";;
let selected_color_label = "Couleur choisie";;

let rightborder : int = 300;;
let generate_voronoi () : voronoi = Examples.select_voronoi ();;

(* _________________________________________
               MAIN FUNCTION
   _________________________________________ *)

type program_state = Play | Quit | End | NewMap;;

let update_current_color c board_pos board_size =
  let rec_y = 20 in
  let (x, y) = board_pos in
  let (l, h) = board_size in
  set_color c;
  fill_rect (x+l) (y-rec_y) (rightborder) rec_y;
  set_color white;
  moveto (x+l+3) (y-rec_y+2);
  draw_string selected_color_label;;

(* A utiliser si necessaire 
   Ne fait rien pour l'instant *)
let adapt_and_get_screen_size voronoi =
  let (x, y) = voronoi.dim in (x + rightborder, y);;

(* ----------- Menu ----------- *)

let create_menu screen_size state voronoi_main colors_set regions =
  let (screen_x, screen_y) = screen_size in
  let default_h = default_height_menu_buttons in
  let topleft_position = (screen_x-250, screen_y-(screen_y/2)-(default_h*5/2)) in
  (* Quit *)
  let button_quit = create_menu_button topleft_position "Quitter" (fun () -> state := Quit) in
  (* Reset *)
  let button_reset = create_menu_button (top_of button_quit) "Recommencer" (fun () -> state := Quit) in
  (* New game *)
  let button_newgame = create_menu_button (top_of button_reset) "Nouvelle carte" (fun () -> state := NewMap) in
  (* Solution *)
  let button_solution =
    let (tpbnx, tpbny) = top_of button_reset in
    let coloring = generate_coloring distance_taxicab voronoi_main colors_set in
    let ac_solution = (fun () -> (draw_voronoi regions (fill_seeds voronoi_main coloring)); state := End) in
    create_menu_button (tpbnx, tpbny+40) "Solution" ac_solution in
  (* Check *)
  let button_check = create_menu_button (top_of button_solution) "Valider coloriage" (fun () -> state := Quit) in
  (* Buttons list *)
  [button_quit; button_reset; button_newgame; button_solution; button_check];;

(* ----------- Game ----------- *)

let rec game voronoi_main regions map_size menu screen_size state =
  let (screen_x, screen_y) = screen_size in
  draw_voronoi regions voronoi_main;
  update_current_color black (0, screen_y) map_size;
  while (!state <> Quit) do
    synchronize ();
    let e = wait_next_event[Button_down] in
    let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
    (* Buttons linking *)
    check_buttons x_mouse y_mouse menu;
    if (coord_in_surface x_mouse y_mouse (0, 0) map_size) then
      let owner = regions.(x_mouse).(y_mouse) in
      let newcolor = voronoi_main.seeds.(owner).c in
      if (newcolor = None) then ()
      else update_current_color (getCouleur newcolor) (0, screen_y) map_size
    else if (!state = NewMap) then
      (state := Play;
       let new_voronoi = Examples.select_voronoi () in
       let new_regions = regions_voronoi distance_taxicab new_voronoi in
       let new_screen_size = adapt_and_get_screen_size new_voronoi in
       let new_colors_set = generator_color_set new_voronoi in
       let menu = create_menu new_screen_size state new_voronoi new_colors_set new_regions in
       resize_window (fst new_screen_size) (snd new_screen_size);
       List.iter draw_button menu;
       game new_voronoi new_regions new_voronoi.dim menu new_screen_size state)
    else
      ()
  done;;

(* ----------- Main ----------- *)
let main () =
  auto_synchronize false;
  (* Working context *)
  let state = ref Play in
  let voronoi_main = generate_voronoi () in
  let regions = regions_voronoi distance_taxicab voronoi_main in
  let colors_set = generator_color_set voronoi_main in
  let (map_x, map_y) = voronoi_main.dim in
  let (screen_x, screen_y) = adapt_and_get_screen_size voronoi_main in
  let screen_size = (screen_x, screen_y) in
  (* Settings *)
  set_window_title window_title;
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  set_color background_color;
  fill_rect 0 0 screen_x screen_y;
  (* Buttons *)
  let menu = create_menu screen_size state voronoi_main colors_set regions in
  List.iter draw_button menu;
  (* Main loop *)
  game voronoi_main regions (map_x, map_y) menu (screen_x, screen_y) state;
  close_graph ();;

main ();;

