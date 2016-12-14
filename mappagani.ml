open Graphics;;
open Voronoi;;
open Color_solver;;

module GraphicsPlus = Graphics_plus.MakeStyle(Style);;
open GraphicsPlus;;
open Style;;

(* _________________________________________
                PARAMETRES
   _________________________________________ *)

let window_title = "Mappagani";;
let selected_color_label = "Couleur choisie";;

let rightborder : int = 300;;
let generate_voronoi () : voronoi = Examples.select_voronoi ();;

(* _________________________________________
            AFFICHAGE DE LA CARTE
   _________________________________________ *)

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
  let color_region = getCouleur (voronoi.seeds.(indice).c) in
  List.iter (fun e ->
       let i = fst e in
       let j = snd e in
       if((frontiere matrix i j)) then
     (set_color black;
     plot i j)
         else
     set_color color_region;
     plot i j) array_of_list.(indice); synchronize();;

let draw_black voronoi_main liste_pixel regions =
  List.iter (fun i ->
        let seedtmp = {c=Some black; x=voronoi_main.seeds.(i).x; y=voronoi_main.seeds.(i).y} in
        (voronoi_main.seeds.(i) <- seedtmp);
        draw_regions regions voronoi_main liste_pixel i) (seeds_to_indices voronoi_main.seeds);;

(* _________________________________________
                FONCTION MAIN
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

(* Non exploité : permet d'adapter la taille des fenêtres *)
let adapt_and_get_screen_size voronoi =
  let (x, y) = voronoi.dim in (x + rightborder, y);;

(* ----------- Dimension des images ----------- *)

let logo_size : (int * int) = (245, 115);;
let bravo_size : (int * int) = (300, 300);;
let perdu_size  : (int * int) = (300, 300);;
let nosolution_size : (int * int) = (300, 300);;

(* ----------- Menu ----------- *)

let create_menu screen_size state voronoi_main colors_set regions liste_pixel distance_f =
  let (screen_x, screen_y) = screen_size in
  let (voronoi_x, voronoi_y) = voronoi_main.dim in
  let default_h = default_height_menu_buttons in
  let topleft_position = (screen_x-250, screen_y-(screen_y/2)-(default_h*5/2)) in
  let adj = adjacences_voronoi voronoi_main regions in
  (* Quitter le jeu *)
  let ac_quit = (fun () -> state := Quit) in
  let button_quit = create_menu_button topleft_position "Quitter" ac_quit in
  (* Recommencer le jeu *)
  let ac_reset = (fun () -> if !state <> End then state := Reset) in
  let button_reset =
    create_menu_button (top_of button_quit) "Recommencer" ac_reset in
  (* Nouvelle partie *)
  let ac_newgame = (fun () -> state := NewMap) in
  let button_newgame =
    create_menu_button (top_of button_reset) "Nouvelle carte" ac_newgame in
  (* Affichage de la solution *)
  let button_solution =
    let (tpbnx, tpbny) = top_of button_reset in
    let ac_solution () =
      try  let coloring () = generate_coloring distance_f voronoi_main colors_set regions adj in
      let coloring_list = coloring () in
      List.iter (fun (i, k) -> if (voronoi_main.seeds.(i).c = None) then
        let seedtmp = {c= Some k; x=voronoi_main.seeds.(i).x; y=voronoi_main.seeds.(i).y} in
        (voronoi_main.seeds.(i) <- seedtmp); draw_regions regions voronoi_main liste_pixel i) coloring_list;
        (state := End)
        with NoSolution ->
          (draw_black voronoi_main liste_pixel regions;
		      draw_picture "images/nosolution.bmp" nosolution_size (voronoi_x/2-150, voronoi_y/2-150);
		      (state := End))
    in
    create_menu_button (tpbnx, tpbny+40) "Solution" ac_solution in
  (* Vérification du coloriage *)
  let ac_check () =
    let checking = check_coloring voronoi_main adj in
      draw_black voronoi_main liste_pixel regions;
       if (checking) then
	 (draw_picture "images/bravo.bmp" bravo_size (voronoi_x/2-150, voronoi_y/2-150))
       else
	 draw_picture "images/perdu.bmp" perdu_size (voronoi_x/2-150, voronoi_y/2-150);
      (state := End)
    in let button_check = create_menu_button (top_of button_solution) "Valider coloriage" ac_check in
  (* Liste des boutons actifs *)
  [button_quit; button_reset; button_newgame; button_solution; button_check];;

let draw_menu menu = List.iter draw_button menu;;

(* ----------- Boucle de jeu ----------- *)

let rec game voronoi_main regions map_size menu screen_size state liste_pixel distance_f =
  let original = {dim=voronoi_main.dim; seeds=Array.copy voronoi_main.seeds} in
  let (screen_x, screen_y) = screen_size in
  let newcolor = ref None in
  draw_voronoi regions voronoi_main;
  update_current_color black (0, screen_y) map_size;
  while (!state <> Quit) do
    synchronize ();
    let e = wait_next_event[Key_pressed; Button_down] in
    (* Appui souris / Coloriage de couleurs *)
    if (button_down ()) then
      (let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
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
	      update_current_color (getCouleur !newcolor) (0, screen_y) map_size));
    (* Appui clavier / Suppression de couleur *)
    if (e.keypressed && e.key = ' ') then
      (let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
      if (coord_in_surface x_mouse y_mouse (0, 0) map_size) then
	    let owner = regions.(x_mouse).(y_mouse) in
	    let colortmp = voronoi_main.seeds.(owner).c in
	    if (colortmp <> None && original.seeds.(owner).c = None && !state <> End) then
	      let seedtmp = {c= None; x=voronoi_main.seeds.(owner).x; y=voronoi_main.seeds.(owner).y} in
	      (voronoi_main.seeds.(owner) <- seedtmp;
        draw_regions regions voronoi_main liste_pixel owner;
      synchronize ()));
    (* Nouvelle carte *)
    if (!state = NewMap) then
      (state := Play;
      let new_voronoi = Examples.select_voronoi () in
      let regions_list = regions_and_pixelList distance_f new_voronoi in
      let new_regions = fst regions_list in
      let new_liste_pixel = snd regions_list in
      let new_screen_size = adapt_and_get_screen_size new_voronoi in
      let new_colors_set = generator_color_set new_voronoi in
      let new_menu = create_menu new_screen_size state new_voronoi new_colors_set new_regions new_liste_pixel distance_f in
      resize_window (fst new_screen_size) (snd new_screen_size);
      set_color background_color;
      fill_rect 0 0 (fst new_screen_size) (snd new_screen_size);
      let (new_screen_x, new_screen_y) = new_screen_size in
      if (new_screen_x > 300 && new_screen_y > 300) then
        draw_picture "images/mappagani_logo.bmp" logo_size (new_screen_x-280, new_screen_y-175);
      draw_menu new_menu;
      Array.iteri (fun i _ -> voronoi_main.seeds.(i) <- original.seeds.(i)) voronoi_main.seeds;
      game new_voronoi new_regions new_voronoi.dim new_menu new_screen_size state new_liste_pixel distance_f)
    (* Remise à zéro de la carte *)
    else if (!state = Reset) then
     (state := Play;
      let new_voronoi = original in
      let new_colors_set = generator_color_set new_voronoi in
      let new_menu = create_menu screen_size state new_voronoi new_colors_set regions liste_pixel distance_f in
      draw_menu new_menu;
      game new_voronoi regions new_voronoi.dim new_menu screen_size state liste_pixel distance_f)
  done;;

(* ----------- Main ----------- *)
let main () =
  auto_synchronize false;
  (* Contexte de travail *)
  let state = ref Play in
  let distance_f = distance_taxicab in
  let voronoi_main = generate_voronoi () in
  let regions_list = regions_and_pixelList distance_f voronoi_main in
  let list_pixel = snd regions_list in
  let regions = fst regions_list in
  let colors_set = generator_color_set voronoi_main in
  let (map_x, map_y) = voronoi_main.dim in
  let (screen_x, screen_y) = adapt_and_get_screen_size voronoi_main in
  let screen_size = (screen_x, screen_y) in
  (* Initialisation graphique *)
  set_window_title window_title;
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  set_color background_color;
  fill_rect 0 0 screen_x screen_y;
  (* Logo *)
  if (screen_x > 300 && screen_y > 300) then
    draw_picture "images/mappagani_logo.bmp" logo_size (screen_x-280, screen_y-175);
  (* Création du menu *)
  let menu = create_menu screen_size state voronoi_main colors_set regions list_pixel distance_f in
  draw_menu menu;
  (* Lancement de la boucle principale *)
  try (game voronoi_main regions (map_x, map_y) menu screen_size state list_pixel distance_f)
  with Graphic_failure("fatal I/O error") -> ();
  close_graph ();;

main ();;


