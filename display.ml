(* ==================================================
 *                    DISPLAY
 * ==================================================
 *   Gère l'affichage de la carte et d'autres affichages
 * auxiliaires sur le jeu (repère des seeds originaux,
 * coloriage de la carte en noir pour signifier la fin
 * d'une partie etc)
 * -------------------------------------------------- *)

open Graphics;;
open Voronoi;;
open Style;;

let draw_graph voronoi adj =
  set_color black;
  Array.iteri (fun i line ->
    Array.iteri (fun j _ ->
      if adj.(i).(j) then
        begin
          moveto voronoi.seeds.(i).x voronoi.seeds.(i).y;
          lineto voronoi.seeds.(j).x voronoi.seeds.(j).y
        end
    ) line
  ) adj;;

let frontiere regions i j =
  let v = regions.(i).(j) in
     ((i-1 > 0) && (regions.(i-1).(j) <> v))
  || ((i+1 < Array.length regions) && (regions.(i+1).(j) <> v))
  || ((j-1 > 0) && (regions.(i).(j-1) <> v))
  || ((j+1 < Array.length regions.(0)) && (regions.(i).(j+1) <> v));;

let draw_seedmark voronoi =
  auto_synchronize false;
  set_color black;
  Array.iter (fun s ->
    if (s.c <> None) then fill_circle s.x s.y 5) voronoi.seeds;
  synchronize ();;

let draw_voronoi regions voronoi =
  auto_synchronize false;
  set_color black;
  let maxY = Array.length regions.(0) in
  Array.iteri (fun i line ->
    Array.iteri (fun j _ ->
      let j' = maxY-1-j in
      if (frontiere regions i j') then
        (set_color black; plot i j')
      else
        set_color (getCouleur (voronoi.seeds.(regions.(i).(j')).c));
        plot i j')
    line)
  regions;
  synchronize ();;

let draw_regions regions voronoi (array_of_list : (int * int) list array) indice =
  auto_synchronize false;
  let color_region = getCouleur (voronoi.seeds.(indice).c) in
  List.iter (fun e ->
    let (i, j) = e in
    if (frontiere regions i j) then
      (set_color black; plot i j)
    else
      set_color color_region;
      plot i j)
  array_of_list.(indice);
  synchronize ();;

let draw_blackscreen voronoi (liste_pixel : (int * int) list array) regions =
  List.iter (fun i ->
    let seedtmp = {c=Some black; x=voronoi.seeds.(i).x; y=voronoi.seeds.(i).y} in
    (voronoi.seeds.(i) <- seedtmp);
    draw_regions regions voronoi liste_pixel i)
  (seeds_to_indices voronoi.seeds);;