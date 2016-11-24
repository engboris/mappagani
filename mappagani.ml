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

let v2 = {
  dim = 600,600;
  seeds = [|
    {c = None; x=100; y=100};
    {c = Some red; x=125; y=550};
    {c = None; x=250; y=50};
    {c = Some blue; x=150; y=250};
    {c = None; x=250; y=300};
    {c = None; x=300; y=500};
    {c = Some red; x=400; y=100};
    {c = None; x=450; y=450};
    {c = None; x=500; y=250};
    {c = Some yellow; x=575; y=350};
    {c = Some green; x=300; y=300};
    {c = None; x=75; y=470};
  |]};;

let v3 = {
  dim = 600,600;
  seeds = [|
    {c = None; x=100; y=100};
    {c = Some red; x=125; y=550};
    {c = None; x=250; y=50};
    {c = Some blue; x=150; y=250};
    {c = None; x=250; y=300};
    {c = None; x=300; y=500};
    {c = Some red; x=400; y=100};
    {c = None; x=450; y=450};
    {c = None; x=500; y=250};
    {c = None; x=575; y=350};
    {c = Some green; x=300; y=300};
    {c = None; x=75; y=470};
    {c = None; x=10; y=14};
    {c = Some red; x=122; y=55};
    {c = None; x=25; y=345};
    {c = Some blue; x=23; y=550};
    {c = None; x=25; y=30};
    {c = None; x=367; y=530};
    {c = None; x=434; y=10};
    {c = None; x=45; y=50};
    {c = None; x=50; y=25};
    {c = Some yellow; x=578; y=550};
    {c = Some green; x=30; y=350};
    {c = None; x=375; y=47};
  |]}

let v4 =  {
    dim = 800,800;
    seeds = [|
              {c = None; x=100; y=75};
              {c = None; x=125; y=225};
              {c = Some red; x=25; y=255};
              {c = None; x=60; y=305};
              {c = Some blue; x=50; y=400};
              {c = Some green; x=100; y=550};
              {c = Some green; x=150; y=25};
              {c = Some red; x=200; y=55};
              {c = None; x=200; y=200};
              {c = None; x=250; y=300};
              {c = None; x=300; y=450};
              {c = None; x=350; y=10};
              {c = None; x=357; y=75};
              {c = Some yellow; x=450; y=80};
              {c = Some blue; x=400; y=150};
              {c = None; x=550; y=350};
              {c = None; x=400; y=450};
              {c = None; x=400; y=500};
              {c = Some red; x=500; y=75};
              {c = Some green; x=600; y=100};
              {c = Some red; x=700; y=75};
              {c = None; x=578; y=175};
              {c = None; x=750; y=205};
              {c = None; x=520; y=345};
              {c = None; x=678; y=420};
              {c = None; x=600; y=480};
              {c = Some blue; x=650; y=480};
              {c = None; x=750; y=500};
              {c = None; x=600; y=550};
              {c = Some red; x=700; y=550};
            |]
    }

(* Parameters *)

let border_x : int = 300;;

let generate_voronoi () : voronoi = v4;;

(* _________________________________________
               MAIN FUNCTION
   _________________________________________ *)

type program_state = Play | Quit;;

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
  draw_string "Couleur choisie";;

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
  let colors_set = generator_color_set voronoi_main in
  let (map_x, map_y) = voronoi_main.dim in
  let screen_x = map_x + border_x in
  let screen_y = map_y in
  set_window_title "Mappagani";
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
    create_menu_button (tpbnx, tpbny+40) "Solution" (fun () -> state := Quit) in
  draw_button button_solution;
  let button_valider =
    create_menu_button (top_of button_solution) "Valider coloriage" (fun () -> state := Quit) in
  draw_button button_valider;
  (* Main loop *)
  let regions = regions_voronoi distance_taxicab voronoi_main in
  draw_voronoi regions voronoi_main;
  update_current_color black (0, screen_y) (map_x, map_y);
  let coloring = generate_coloring distance_euclide voronoi_main colors_set in
  draw_voronoi regions (fill_seeds voronoi_main coloring);
  while (!state <> Quit) do
    synchronize ();
    let e = wait_next_event[Button_down] in
    let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
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

