open Graphics;;

module Voronoi = Voronoi.VoronoiModule;;
open Voronoi;;

let v4 : voronoi = {
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
};;

(* Parameters *)

let border_x map_x : int = map_x / 2;;

let generate_voronoi () : voronoi = v4;;

(* _______________________
       MAIN FUNCTION
   _______________________ *)

let main () =
  let voronoi_main = generate_voronoi () in
  let (map_x, map_y) = voronoi_main.dim in
  let screen_x = map_x + (border_x map_x) in
  let screen_y = map_y in
  open_graph (" "^(string_of_int screen_x)^"x"^(string_of_int screen_y));
  let regions = regions_voronoi distance_euclide v4 in
  draw_voronoi regions voronoi_main;
  read_line ();;

main ();;

