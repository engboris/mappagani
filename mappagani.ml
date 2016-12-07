open Graphics;;
open Voronoi;;
open Color_solver;;

module GraphicsPlus = Graphics_plus.MakeStyle(Style);;
open GraphicsPlus;;
open Style;;

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

type program_state = Play | Quit | End | NewMap | Reset;;

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

(* ----------- Affichage Carte ----------- *)

let frontiere m i j =
  let v = m.(i).(j) in
    ((i-1 > 0) && (m.(i-1).(j) <> v))
  || ((i+1 < Array.length m ) && (m.(i+1).(j) <> v))
  || ((j-1 > 0) && (m.(i).(j-1) <> v))
  || ((j+1 < Array.length m.(0)) && (m.(i).(j+1) <> v));;

let draw_voronoi matrix voronoi =
  auto_synchronize false;
  set_color black;
  let maxY = Array.length matrix.(0) in
  Array.iteri (fun i line ->
   Array.iteri (fun j _ ->
   let j' = maxY-1-j in
   if((frontiere matrix i j')) then
     (set_color black;
     plot i j')
         else
     set_color (getCouleur (voronoi.seeds.(matrix.(i).(j')).c));
     plot i j') line) matrix; synchronize();;

let draw_regions matrix voronoi array_of_list indice =
  auto_synchronize false;
  let color_region = getCouleur(voronoi.seeds.(indice).c) in
  List.iter (fun e ->
	     let i = fst e in
	     let j = snd e in
	     if((frontiere matrix i j)) then
     (set_color black;
     plot i j)
         else
     set_color color_region;
     plot i j) array_of_list.(indice); synchronize();;

(* ----------- Logo ----------- *)

let logo_size : (int * int) = (245, 115);;
let green_to_exclude : int = 0x00FF00;;

(* let make_logo () : image =
  let (w, h) = logo_size in
  let m = Array.make_matrix h w transp in
  let channel = open_in_bin "images/mappagani_logo.bmp" in
  try (
    seek_in channel 54;
    Array.iteri (fun i line ->
      Array.iteri (fun j _ ->
	let b = input_byte channel in
	let g = input_byte channel in
	let r = input_byte channel in
	let pixel = rgb r g b in
        (line.(j) <- (if pixel = green_to_exclude then pixel else pixel))) line) m;
  close_in channel;
  make_image m
  ) with End_of_file ->
  close_in channel;
  make_image m;; *)

let make_logo () : image =
  let (w, h) = logo_size in
  let m = Array.make_matrix h w transp in
  let channel = open_in_bin "images/mappagani_logo.bmp" in
  try
  ( seek_in channel 54;
    for i = 0 to h-1 do
      for j = 0 to w-1 do
        let r = input_byte channel in
        let g = input_byte channel in
        let b = input_byte channel in
        let pixel = rgb r g b in
              (m.(h-1-i).(j) <- (if pixel = green_to_exclude then transp else pixel))
        done;
    done;
    close_in channel;
    make_image m)
  with End_of_file ->
  close_in channel;
  make_image m;;

(* ----------- Menu ----------- *)

let create_menu screen_size state voronoi_main colors_set regions =
  let (screen_x, screen_y) = screen_size in
  let default_h = default_height_menu_buttons in
  let topleft_position = (screen_x-250, screen_y-(screen_y/2)-(default_h*5/2)) in
  (* Quit *)
  let button_quit = create_menu_button topleft_position "Quitter" (fun () -> state := Quit) in
  (* Reset *)
  let button_reset = create_menu_button (top_of button_quit) "Recommencer" (fun () -> state := Reset) in
  (* New game *)
  let button_newgame = create_menu_button (top_of button_reset) "Nouvelle carte" (fun () -> state := NewMap) in
  (* Solution *)
  let button_solution =
    let (tpbnx, tpbny) = top_of button_reset in
    let coloring () = generate_coloring distance_taxicab voronoi_main colors_set regions in
    let ac_solution = (fun () -> (draw_voronoi regions (fill_seeds voronoi_main (coloring ()))); state := End) in
    create_menu_button (tpbnx, tpbny+40) "Solution" ac_solution in
  (* Check *)
  let button_check = create_menu_button (top_of button_solution) "Valider coloriage" (fun () -> state := Quit) in
  (* Buttons list *)
  [button_quit; button_reset; button_newgame; button_solution; button_check];;

(* ----------- Game ----------- *)

let rec game voronoi_main regions map_size menu screen_size state liste_pixel =
  let (screen_x, screen_y) = screen_size in
  let newcolor = ref None in
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
      let colortmp = voronoi_main.seeds.(owner).c in
      if (colortmp = None) then
	let seedtmp = {c= !newcolor; x=voronoi_main.seeds.(owner).x; y=voronoi_main.seeds.(owner).y} in
	(voronoi_main.seeds.(owner) <- seedtmp;
        draw_regions regions voronoi_main liste_pixel owner;
        synchronize ())
      else
	(newcolor := voronoi_main.seeds.(owner).c;
	update_current_color (getCouleur !newcolor) (0, screen_y) map_size)
    else if (!state = NewMap) then
      (state := Play;
       let new_voronoi = Examples.select_voronoi () in
       let regions_list = regions_and_pixelList distance_taxicab new_voronoi in
       let new_regions = fst regions_list in
       let new_liste_pixel = snd regions_list in
       let new_screen_size = adapt_and_get_screen_size new_voronoi in
       let new_colors_set = generator_color_set new_voronoi in
       let menu = create_menu new_screen_size state new_voronoi new_colors_set new_regions in
       resize_window (fst new_screen_size) (snd new_screen_size);
       set_color background_color;
       fill_rect 0 0 (fst new_screen_size) (snd new_screen_size);
       List.iter draw_button menu;
       game new_voronoi new_regions new_voronoi.dim menu new_screen_size state new_liste_pixel)
  done;;

(* ----------- Main ----------- *)
let main () =
  auto_synchronize false;
  (* Working context *)
  let state = ref Play in
  let voronoi_main = generate_voronoi () in
     let regions_list = regions_and_pixelList distance_taxicab voronoi_main in
  let list_pixel = snd regions_list in
  let regions = fst regions_list in
  let colors_set = generator_color_set voronoi_main in
  let (map_x, map_y) = voronoi_main.dim in
  let (screen_x, screen_y) = adapt_and_get_screen_size voronoi_main in
  let screen_size = (screen_x, screen_y) in
  (* Settings *)
  set_window_title window_title;
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  set_color background_color;
  fill_rect 0 0 screen_x screen_y;
  (* Logo *)
  let logo = make_logo () in
  let logo_position = (screen_x-280, screen_y-175) in
  let (logo_x, logo_y) = logo_position in
  draw_image logo logo_x logo_y;
  synchronize ();
  (* Buttons *)
  let menu = create_menu screen_size state voronoi_main colors_set regions in
  List.iter draw_button menu;
  (* Main loop *)
  game voronoi_main regions (map_x, map_y) menu (screen_x, screen_y) state list_pixel;
  close_graph ();;

main ();;

