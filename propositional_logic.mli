module type VARIABLES_FORMULA = sig
  type t
  val compare : t -> t -> int
end

module Make (V : VARIABLES_FORMULA) : sig

  type literal = bool * V.t
  type formula =
    | Var of V.t
    | Not of formula
    | And of (formula * formula)
    | Or of (formula * formula);;

  val nnf : formula -> formula
  val cnf : formula -> formula
  val (=>) : formula -> formula -> formula
  val disj_to_clause : formula -> literal list
  val formula_to_clauses : formula -> literal list list

end
