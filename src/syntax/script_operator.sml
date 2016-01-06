structure ScriptOperator : OPERATOR =
struct
  open ScriptOperatorData SortData

  structure Arity = Arity

  type 'i t = 'i script_operator

  local
    fun * (a, b) = (a, b) (* symbols sorts, variable sorts *)
    fun <> (a, b) = (a, b) (* valence *)
    fun ->> (a, b) = (a, b) (* arity *)
    fun ^ (x, n) = List.tabulate (n, fn _ => x)
    infix 5 <> ->>
    infix 6 * ^
  in
    fun arity (THEN {bindings}) =
          [ [] * [] <> TAC
          , (EXP ^ bindings) * [] <> TAC
          ] ->> TAC
      | arity (THENF {bindings,...}) =
          [ [] * [] <> TAC
          , (EXP ^ bindings) * [] <> TAC
          ] ->> TAC
      | arity (THENL {length}) =
          ([] * [] <> TAC) ^ (length + 1)
            ->> TAC
      | arity (INTRO ({hasTerm,...}, _)) =
          (if hasTerm then [[] * [] <> EXP] else [])
            ->> TAC
      | arity (ELIM ({hasTerm,...}, _)) =
          (if hasTerm then [[] * [] <> EXP] else [])
            ->> TAC
      | arity (HYP _) =
          [] ->> TAC
  end

  fun support (ELIM ({target,...}, _)) = [(target, EXP)]
    | support (HYP ({target}, _)) = [(target, EXP)]
    | support _ = []

  structure Presheaf =
  struct
    type 'i t = 'i t
    fun map f (THEN p) = THEN p
      | map f (THENF p) = THENF p
      | map f (THENL p) = THENL p
      | map f (INTRO p) = INTRO p
      | map f (ELIM ({target, hasTerm}, m)) =
          ELIM ({target = f target, hasTerm = hasTerm}, m)
      | map f (HYP ({target}, m)) =
          HYP ({target = f target}, m)
  end

  structure Eq =
  struct
    type 'i t = 'i t
    fun eq f (THEN p1, THEN p2) = p1 = p2
      | eq f (THENF p1, THENF p2) = p1 = p2
      | eq f (THENL p1, THENL p2) = p1 = p2
      | eq f (INTRO (p1, _), INTRO (p2, _)) = p1 = p2
      | eq f (ELIM (p1, _), ELIM (p2, _)) =
          f (#target p1, #target p2) andalso
            #hasTerm p1 = #hasTerm p2
      | eq f (HYP (p1, _), HYP (p2, _)) =
          f (#target p1, #target p2)
      | eq _ _ = false
  end

  structure Show =
  struct
    type 'i t = 'i t
    fun toString f (THEN _) = "then"
      | toString f (THENL _) = "thenl"
      | toString f (THENF {focus,...}) = "thenf{" ^ Int.toString focus ^ "}"
      | toString f (INTRO _) = "intro"
      | toString f (ELIM ({target,...}, _)) = "elim[" ^ f target ^ "]"
      | toString f (HYP ({target}, _)) = "hyp[" ^ f target ^ "]"
  end
end
