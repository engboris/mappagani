open Graphics;;
open Voronoi;;
open Style;;

let draw_graph voronoi adj =
  set_color black;
  let maxX = Array.length adj - 1 in
  let maxY = Array.length adj.(0) - 1 in
  for i = 0 to maxX do 
     for j = 0 to maxY do 
        if(adj.(i).(j)) then(
          moveto voronoi.seeds.(i).x voronoi.seeds.(i).y;
          lineto voronoi.seeds.(j).x voronoi.seeds.(j).y)
      done;
  done;;

let frontiere m i j =
  let v = m.(i).(j) in
    ((i-1 > 0) && (m.(i-1).(j) <> v))
  || ((i+1 < Array.length m ) && (m.(i+1).(j) <> v))
  || ((j-1 > 0) && (m.(i).(j-1) <> v))
  || ((j+1 < Array.length m.(0)) && (m.(i).(j+1) <> v));;

let draw_seedmark voronoi =
  auto_synchronize false;
  set_color black;
  Array.iter (fun s -> if s.c <> None then fill_circle s.x s.y 5) voronoi.seeds;
  synchronize ();;

let draw_voronoi matrix voronoi =
  auto_synchronize false;
  set_color black;
  let maxY = Array.length matrix.(0) in
  Array.iteri (fun i line ->
    Array.iteri (fun j _ ->
      let j' = maxY-1-j in
      if ((frontiere matrix i j')) then
        (set_color black; plot i j')
      else
        set_color (getCouleur (voronoi.seeds.(matrix.(i).(j')).c)); plot i j') line) matrix;
  synchronize ();;

let draw_regions matrix voronoi array_of_list indice =
  auto_synchronize false;
  let color_region = getCouleur (voronoi.seeds.(indice).c) in
  List.iter (fun e ->
    let i = fst e in
    let j = snd e in
    if((frontiere matrix i j)) then
      (set_color black; plot i j)
    else
      set_color color_region; plot i j) array_of_list.(indice);
  synchronize();;

let draw_blackscreen voronoi_main liste_pixel regions =
  List.iter (fun i ->
    let seedtmp = {c=Some black; x=voronoi_main.seeds.(i).x; y=voronoi_main.seeds.(i).y} in
    (voronoi_main.seeds.(i) <- seedtmp);
    draw_regions regions voronoi_main liste_pixel i) (seeds_to_indices voronoi_main.seeds);;