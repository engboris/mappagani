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

let border_x map_x : int = 300;;

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
      (check_buttons x y t)

(* ----------- Main ----------- *)
let main () =
  (* Settings *)
  let state = ref Play in
  let voronoi_main = generate_voronoi () in
  let colors_set = get_list_couleurs voronoi_main.seeds in
  let (map_x, map_y) = voronoi_main.dim in
  let screen_x = map_x + (border_x map_x) in
  let screen_y = map_y in
  set_window_title "Mappagani";
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  (* Buttons *)
  let button_quit =
    create_menu_button (screen_x-250, 50) "Quitter" (fun () -> state := Quit) in
  draw_button button_quit;
  (* Program *)
  let regions = regions_voronoi distance_euclide voronoi_main in
  draw_voronoi regions voronoi_main;
  while (!state <> Quit) do 
    let e = wait_next_event[Button_down] in
    let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
    check_buttons x_mouse y_mouse [button_quit]
  done;
  (* let coloring = generate_coloring distance_euclide voronoi_main colors_set in
  draw_voronoi regions (fill_seeds voronoi_main coloring); *)
  close_graph ();;

main ();;

