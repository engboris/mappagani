(* _________________________________________ 
		    PROPOSITIONAL LOGIC
   _________________________________________ *)

module type VARIABLES_FORMULA = sig
  type t
  val compare : t -> t -> int
end

module Make (V : VARIABLES_FORMULA) = struct

  type literal = bool * V.t

  (* ----------- Syntax ----------- *)
  type formula =
    | Var of V.t
    | Not of formula
    | And of (formula * formula)
    | Or of (formula * formula);;

  (* ----------- Operators ----------- *)
  let (=>) p q : formula = Or ((Not p), q);; (* Implication *)

  (* ----------- Normal forms ----------- *)

  (* NNF conversion *)
  let rec nnf p : formula =
    match p with
    | Var x | Not (Var x) -> p
    | Not (Not p) -> nnf p
    | Not (And (p, q)) -> Or (nnf (Not p), nnf (Not q))
    | Not (Or (p, q)) -> And (nnf (Not p), nnf (Not q))
    | And (p, q) -> And (nnf p, nnf q)
    | Or (p, q) -> Or (nnf p, nnf q);;

  (* CNF conversion *)
  let rec distribute_step p q : formula =
    match p, q with
    | And (p, q), r -> And (distribute_step p r, distribute_step q r)
    | p, And (q, r) -> And (distribute_step p q, distribute_step p r)
    | p, q -> Or (p, q);;

  let rec distribute p : formula =
    match p with
    | And (p, q) -> And (distribute p, distribute q)
    | Or (p, q) -> distribute_step (distribute p) (distribute q)
    | _ -> p;;

  let cnf p : formula = distribute (nnf p);;

  (* ----------- Clausal form ----------- *)

  let rec disj_to_clause p : literal list =
    match p with
    | Var x -> [(true, x)]
    | Not (Var x) -> [(false, x)]
    | Or (p, q) -> (disj_to_clause p) @ (disj_to_clause q)
    | _ -> [];;

  let rec cnf_to_clauses p : literal list list =
    match p with
    | Var x -> [[(true, x)]]
    | Not (Var x) -> [[(false, x)]]
    | And (p, q) -> (cnf_to_clauses p) @ (cnf_to_clauses q)
    | Or (r, s) as p -> [disj_to_clause p] 
    | _ -> [];;

  let formula_to_clauses p : literal list list = cnf_to_clauses (cnf p);;

end