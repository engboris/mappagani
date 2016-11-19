(* _____________________________________
			  TESTING ENGINE
   _____________________________________ *)

type result = Success | Fail;;
type 'a testcase = ('a * 'a) list;;

let test name testcases =
  (print_string "__________________\n");
  (print_string (name^"\n"));
  (print_string "__________________\n");
  let rec aux testcases = 
    match testcases with
    | [] -> []
    | (i, e)::t ->
      if i = e then
      	((print_string "SUCCESS");
      	(print_string "\n");
        (aux t))
      else
        ((print_string "FAIL");
        (print_string "\n");
      	((i, e) :: (aux t)))
  in
  let l = List.length testcases in
  let fails = aux testcases in
  let (successes, total) = (l-(List.length fails), l) in
  print_string ("("^(string_of_int successes)^"/"^(string_of_int total)^")\n");
  fails;;
  
(* Example *)

let f x y z = x+y+z;;

(* (input, expected) *)
let cases_f = [
  (f 0 0 0, 0);
  (f 1 0 0, 1);
  (f 1 1 1, 2);
  (f 0 0 0, 5);
  (f 10 10 10, 30);
];;