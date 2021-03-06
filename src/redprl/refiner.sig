signature REFINER =
sig
  type sign
  type abt
  type catjdg
  type rule
  type hyp

  val Lift : rule -> rule
  val Lemma : abt -> 'n -> Lcf.jdg Lcf.tactic
  val Cut : catjdg -> rule
  val Elim : sign -> hyp -> rule
  val AutoStep : sign -> rule

  structure Equality :
  sig
    val Symmetry : rule
    val HeadExpansion : sign -> rule
  end

  structure Truth :
  sig
    val Witness : abt -> rule
  end

  structure Hyp :
  sig
    val Project : hyp -> rule
  end

  structure CEquiv :
  sig
    val Refl : rule
    val EvalGoal : sign -> rule
  end
end
