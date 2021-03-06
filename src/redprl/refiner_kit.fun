structure LcfLanguage = LcfAbtLanguage (RedPrlAbt)

structure Lcf :
sig
  include LCF_UTIL
  val prettyState : jdg state -> PP.doc
  val stateToString : jdg state -> string
end =
struct
  structure Def = LcfUtil (structure Lcf = Lcf (LcfLanguage) and J = RedPrlJudgment)
  open Def
  infix |>

  fun prettyGoal (x, jdg) =
    PP.concat
      [PP.text "Goal ",
       PP.text (RedPrlAbt.Metavar.toString x),
       PP.text ".",
       PP.nest 2 (PP.concat [PP.line, RedPrlSequent.pretty TermPrinter.toString jdg]),
       PP.line]

  val prettyGoals : jdg Tl.telescope -> PP.doc =
    Tl.foldl
      (fn (x, jdg, r) => PP.concat [r, prettyGoal (x, jdg), PP.line])
      PP.empty

  fun prettyValidation vld =
    let
      open RedPrlAbt infix \
      val _ \ m = outb vld
    in
      PP.text (TermPrinter.toString m)
    end

  fun prettyState (psi |> vld) =
    PP.concat
      [prettyGoals psi,
       PP.newline,
       PP.rule #"-",
       PP.newline,
       PP.text "Current Proof Extract:",
       PP.newline,
       PP.rule #"-",
       PP.newline, PP.newline,
       prettyValidation vld]

  val stateToString : jdg state -> string =
    PP.toString 80 false o prettyState
end

functor RefinerKit (Sig : MINI_SIGNATURE) =
struct
  structure E = RedPrlError and O = RedPrlOpData and T = TelescopeUtil (Lcf.Tl) and Abt = RedPrlAbt and Syn = Syntax and Seq = RedPrlSequent and J = RedPrlJudgment
  structure Env = RedPrlAbt.Metavar.Ctx
  structure Machine = AbtMachineUtil (RedPrlMachine (Sig))
  local structure TeleNotation = TelescopeNotation (T) in open TeleNotation end
  open RedPrlSequent

  fun @> (H, (x, j)) = Hyps.snoc H x j
  infix @>

  structure P = struct open RedPrlParameterTerm RedPrlParamData end
  structure CJ = RedPrlCategoricalJudgment

  exception todo
  fun ?e = raise e

  fun @@ (f, x) = f x
  infixr @@

  local
    val counter = ref 0
  in
    fun newMeta str =
      let
        val i = !counter
      in
        counter := i + 1;
        Metavar.named @@ "?" ^ str ^ Int.toString i
      end
  end

  fun makeGoal jdg =
    let
      open Abt infix 1 $#
      val x = newMeta ""
      val vl as (_, tau) = J.sort jdg
      fun hole ps ms = check (x $# (ps, ms), tau)
    in
      ((x, jdg), hole)
    end


  fun lookupHyp H z =
    Hyps.lookup H z
    handle _ =>
      raise E.error [E.% @@ "Found nothing in context for hypothesis `" ^ Sym.toString z ^ "`"]

  fun assertAlphaEq (m, n) =
    if Abt.eq (m, n) then
      ()
    else
      raise E.error [E.% "Expected", E.! m, E.% "to be alpha-equivalent to", E.! n]

  fun assertVarEq (x, y) =
    if Var.eq (x, y) then
      ()
    else
      raise E.error [E.% @@ "Expected variable `" ^ Var.toString x ^ "` to be equal to variable `" ^ Var.toString y ^ "`"]

end


