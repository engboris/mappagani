(* ==================================================
 *                    MAPPAGANI
 * ==================================================
 *   Fichier principal gérant la boucle d'intéraction
 * avec l'utilisateur et définissant le jeu en lui-même
 * et son interface graphique.
 *
 * --------------------------------------------------
 * Auteurs :
 * - Kostia CHARDONNET
 * - Sambo Boris ENG
 *
 * Créer dans le cadre du projet de PF5 de L3 Informatique
 * à l'Université Paris 7 (Diderot)
 *
 * 2016 -- 2017
 * -------------------------------------------------- *)

open Graphics;;
open Voronoi;;
open Color_solver;;
open Examples;;
module GraphicsPlus = Graphics_plus.MakeStyle(Style);;
open GraphicsPlus;;
open Style;;
open Display

(* _________________________________________
                TYPES
   _________________________________________ *)

type program_state =
  | Play
  | Quit
  | End
  | Win
  | NewMap
  | Reset
  | GameOver;;

type flags = {
  mutable seedmark : bool;
  mutable graph : bool
};;

exception NoValue;;

(* _________________________________________
         PARAMETRES ET INITIALISATION
   _________________________________________ *)

let window_title = "Mappagani";;
let selected_color_label = "Couleur choisie";;
let rightborder : int = 300;;

let init_flags () : flags = {
  seedmark = false;
  graph = false
};;

(* ----------- Dimensions des images ----------- *)
let logo_size : (int * int) = (245, 115);;
let bravo_size : (int * int) = (300, 300);;
let nosolution_size : (int * int) = (300, 300);;
let jeutermine_size : (int * int) = (300, 300);;

(* _________________________________________
            SELECTION DE CARTE
   _________________________________________ *)

let voronoi_list = ref [v1;v2;v3;v4];;

let get (v : 'a option) : 'a =
  match v with
  | Some a -> a
  | None -> raise NoValue;;

let check_and_set_gameover state voronoi : unit =
  match voronoi with
  | None ->
     set_blackscreen ();
     let size_X = size_x () and size_Y = size_y () in
     draw_picture "images/jeutermine.bmp" nosolution_size (size_X/2-150, size_Y/2-150);
     (state := GameOver);
  | Some a -> ();;

let generate_voronoi state : voronoi option =
  try Some (select_voronoi voronoi_list)
  with NoVoronoi -> None;;

(* _________________________________________
           FONCTIONS AUXILIAIRES
   _________________________________________ *)

let draw_voronoi_with_flags adj regions voronoi original flags =
  auto_synchronize false;
  draw_voronoi regions voronoi;
  if (flags.seedmark) then
    (draw_seedmark original; synchronize ());
  if (flags.graph) then
    (draw_graph voronoi adj; synchronize ());;

let update_current_color c board_pos board_size =
  let rec_y = 20 in
  let (x, y) = board_pos in
  let (l, h) = board_size in
  set_color c;
  fill_rect (x+l) (y-rec_y) (rightborder) rec_y;
  set_color white;
  moveto (x+l+3) (y-rec_y+2);
  draw_string selected_color_label;;

(* Adapte la fenêtre selon un voronoi *)
let adapt_and_get_screen_size voronoi : (int * int) =
  let (x, y) = voronoi.dim in (x + rightborder, y);;

(* _________________________________________
             MENU LATERAL DE JEU
   _________________________________________ *)
(* Creer et affiche les boutons du menu *)

let rec create_menu screen_size state voronoi_main colors_set regions liste_pixel distance_f adj : menu =
  let (screen_x, screen_y) = screen_size in
  let (voronoi_x, voronoi_y) = voronoi_main.dim in
  let default_h = default_height_menu_buttons in
  let topleft_position = (screen_x-250, screen_y-(screen_y/2)-(default_h*5/2)-15) in
  (* ----- Quitter le jeu ----- *)
  let ac_quit = (fun () -> state := Quit) in
  let button_quit = create_menu_button topleft_position "Quitter" ac_quit in
  (* ----- Recommencer le jeu ----- *)
  let ac_reset = (fun () -> if !state <> End then state := Reset) in
  let button_reset =
    create_menu_button (top_of button_quit) "Recommencer" ac_reset in
  (* ----- Nouvelle partie ----- *)
  let ac_newgame = (fun () -> state := NewMap) in
  let button_newgame =
    create_menu_button (top_of button_reset) "Nouvelle carte" ac_newgame in
  (* ----- Affichage de la solution ----- *)
  let button_solution =
    let (tpbnx, tpbny) = top_of button_reset in
    let ac_solution () =
      try  let coloring () = generate_coloring distance_f voronoi_main colors_set regions adj in
      let coloring_list = coloring () in
      List.iter (fun (i, k) -> if (voronoi_main.seeds.(i).c = None) then
        let seedtmp = {c= Some k; x=voronoi_main.seeds.(i).x; y=voronoi_main.seeds.(i).y} in
        (voronoi_main.seeds.(i) <- seedtmp); draw_regions regions voronoi_main liste_pixel i) coloring_list;
        (state := End);
        refresh_menu screen_size state voronoi_main colors_set regions liste_pixel distance_f adj
      with NoSolution ->
        (draw_blackscreen voronoi_main liste_pixel regions;
	      draw_picture "images/nosolution.bmp" nosolution_size (voronoi_x/2-150, voronoi_y/2-150);
	  (state := End);
    refresh_menu screen_size state voronoi_main colors_set regions liste_pixel distance_f adj)
  in create_menu_button (tpbnx, tpbny+40) "Solution" ac_solution in
  (* Liste des boutons actifs *)
  let menu = [button_newgame; button_reset; button_solution; button_quit] in
  (* Gestion de l'activite des boutons *)
  if (!state = End || !state = Win) then
    (disable_menu menu; List.iter enable_button [button_quit; button_newgame]);
  (* Envoi du menu *)
  menu
(* Actualisation du menu *)
and refresh_menu screen_size state voronoi_main colors_set regions liste_pixel distance_f adj : unit =
  let menu = create_menu screen_size state voronoi_main colors_set regions liste_pixel distance_f adj in
  draw_menu menu;;

(* _________________________________________
               BOUCLE DE JEU
   _________________________________________ *)

let rec game voronoi_main regions map_size menu screen_size state liste_pixel distance_f adj flags =
  let original = {dim=voronoi_main.dim; seeds=Array.copy voronoi_main.seeds} in
  let (map_x, map_y) = map_size in
  let (screen_x, screen_y) = screen_size in
  let newcolor = ref None in
  let colors_set = generator_color_set voronoi_main in
  draw_voronoi_with_flags adj regions voronoi_main original flags;
  update_current_color black (0, screen_y) map_size;
  while (!state <> Quit) do
    synchronize ();
    let e = wait_next_event[Key_pressed; Button_down; Mouse_motion] in
    (* ----- Appui souris / Coloriage de couleurs ----- *)
    if (!state <> GameOver && button_down ()) then
      begin
        let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
        check_buttons x_mouse y_mouse menu;
        if (coord_in_surface x_mouse y_mouse (0, 0) map_size) then
          let owner = regions.(x_mouse).(y_mouse) in
          if (!newcolor <> None && voronoi_main.seeds.(owner).c = None && !state <> End) then
  	        let seedtmp = {c=(!newcolor); x=voronoi_main.seeds.(owner).x; y=voronoi_main.seeds.(owner).y} in
  	        (voronoi_main.seeds.(owner) <- seedtmp;
            draw_regions regions voronoi_main liste_pixel owner;
            synchronize ();
            if is_complete_voronoi voronoi_main && check_coloring voronoi_main adj then
              state := Win)
          else
            (newcolor := voronoi_main.seeds.(owner).c;
  	      update_current_color (getCouleur !newcolor) (0, screen_y) map_size);
      end;
    (* ----- Appui clavier / Suppression de couleur ----- *)
    if (!state <> GameOver && e.keypressed && e.key = ' ') then
      begin
        let x_mouse = e.mouse_x and y_mouse = e.mouse_y in
        check_hover x_mouse y_mouse menu;
        if (coord_in_surface x_mouse y_mouse (0, 0) map_size) then
  	    let owner = regions.(x_mouse).(y_mouse) in
  	    let colortmp = voronoi_main.seeds.(owner).c in
  	    if (colortmp <> None && original.seeds.(owner).c = None && !state <> End) then
  	      let seedtmp = {c=None; x=voronoi_main.seeds.(owner).x; y=voronoi_main.seeds.(owner).y} in
  	      (voronoi_main.seeds.(owner) <- seedtmp;
          draw_regions regions voronoi_main liste_pixel owner;
        synchronize ());
      end;
    if (!state <> GameOver && e.keypressed && e.key = 'o') then
      (flags.seedmark <- not flags.seedmark; draw_voronoi_with_flags adj regions voronoi_main original flags);
    if (!state <> GameOver && e.keypressed && e.key = 'g') then
      begin
        if flags.graph then flags.graph <- false
        else flags.graph <- true;
        draw_voronoi_with_flags adj regions voronoi_main original flags;
      end;
    (* ----- Requete de nouvelle carte ----- *)
    if (!state = NewMap) then
      begin
        state := Play;
        Array.iteri (fun i _ -> voronoi_main.seeds.(i) <- original.seeds.(i)) voronoi_main.seeds;
        let new_voronoi = generate_voronoi () in
        if (new_voronoi <> None) then
          begin
            let new_voronoi = get new_voronoi in
            let regions_list = regions_and_pixelList distance_f new_voronoi in
            let (new_regions, new_liste_pixel) = regions_list in
            let new_adj = adjacences_voronoi new_voronoi new_regions in
            let new_screen_size = adapt_and_get_screen_size new_voronoi in
            let (new_screen_x, new_screen_y) = new_screen_size in
            let new_colors_set = generator_color_set new_voronoi in
            let new_menu = create_menu new_screen_size state new_voronoi new_colors_set new_regions new_liste_pixel distance_f new_adj in
            resize_window new_screen_x new_screen_y;
            set_color background_color;
            fill_rect 0 0 new_screen_x new_screen_y;
            draw_menu new_menu;
            if (new_screen_x > 300 && new_screen_y > 300) then
              draw_picture "images/mappagani_logo.bmp" logo_size (new_screen_x-280, new_screen_y-175);
            game new_voronoi new_regions new_voronoi.dim new_menu new_screen_size state new_liste_pixel distance_f new_adj flags;
          end
        else
          check_and_set_gameover state new_voronoi
      end
    (* ----- Requete de remise à zéro de la carte ----- *)
    else if (!state = Reset) then
      begin
        state := Play;
        let new_voronoi = original in
        let new_colors_set = generator_color_set new_voronoi in
        let new_menu = create_menu screen_size state new_voronoi new_colors_set regions liste_pixel distance_f adj in
        draw_menu new_menu;
        game new_voronoi regions new_voronoi.dim new_menu screen_size state liste_pixel distance_f adj flags;
      end
    (* ----- Victoire du joueur ----- *)
    else if (!state = Win) then
      begin
        (draw_blackscreen voronoi_main liste_pixel regions;
        draw_picture "images/bravo.bmp" bravo_size (map_x/2-150, map_y/2-150);
        state := End;
        refresh_menu screen_size state voronoi_main colors_set regions liste_pixel distance_f adj);
      end
  done;;

(* _________________________________________
                FONCTION MAIN
   _________________________________________ *)

let main () =
  auto_synchronize false;
  (* Contexte de travail *)
  let state = ref Play in
  let distance_f = distance_taxicab in
  let voronoi_main = get (generate_voronoi state) in
  let regions_list = regions_and_pixelList distance_f voronoi_main in
  let (regions, list_pixel) = regions_list in
  let adj = adjacences_voronoi voronoi_main regions in
  let colors_set = generator_color_set voronoi_main in
  let (map_x, map_y) = voronoi_main.dim in
  let (screen_x, screen_y) = adapt_and_get_screen_size voronoi_main in
  let screen_size = (screen_x, screen_y) in
  let flags = init_flags () in
  (* Initialisation graphique *)
  set_window_title window_title;
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  set_color background_color;
  fill_rect 0 0 screen_x screen_y;
  (* Logo *)
  if (screen_x > 300 && screen_y > 300) then
    draw_picture "images/mappagani_logo.bmp" logo_size (screen_x-280, screen_y-175);
  (* Création du menu *)
  let menu = create_menu screen_size state voronoi_main colors_set regions list_pixel distance_f adj in
  draw_menu menu;
  (* Lancement de la boucle principale *)
  try (game voronoi_main regions (map_x, map_y) menu screen_size state list_pixel distance_f adj flags)
  with Graphic_failure("fatal I/O error") -> ();
  close_graph ();;

(* Lancement du programme *)
main ();;
