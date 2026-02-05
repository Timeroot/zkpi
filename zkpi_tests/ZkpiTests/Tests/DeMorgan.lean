axiom em' : ∀ (p : Prop), p ∨ ¬p

theorem em'_ok : (type_of% em') := Classical.em

def em := em' --Classical.em works too, but we need to avoid Quot.sound.

variable {p q : Prop}
theorem demorganAndForward : ¬(p ∧ q) → (¬p ∨ ¬q) := by
  intros h
  apply Or.elim (em p)
  intro hp
  let nq := λ hq => h (And.intro hp hq)
  exact Or.intro_right _ nq
  intro hnp
  exact Or.intro_left _ hnp

theorem demorganAndBackward : (¬p ∨ ¬q) → ¬(p ∧ q) := by
  intro h
  apply Or.elim h
  intro np
  exact (λ hpq => np (And.left hpq))
  intro nq
  exact (λ hpq => nq (And.right hpq))

theorem demorganAnd : (¬(p ∧ q) ↔ (¬p ∨ ¬q)) :=
  Iff.intro demorganAndForward demorganAndBackward

theorem demorganOrForward : ¬(p ∨ q) → (¬p ∧ ¬q) := by
  intros h
  apply Or.elim (em p)
  intro hp
  exact absurd (Or.intro_left _ hp) h
  intro np
  apply Or.elim (em q)
  intro hq
  exact absurd (Or.intro_right _ hq) h
  intro nq
  exact And.intro np nq

theorem demorganOrBackward : (¬p ∧ ¬q) → ¬(p ∨ q) := by
  intro h
  let np := And.left h
  let nq := And.right h
  exact (λ porq => Or.elim porq (λ hp => absurd hp np) (λ hq => absurd hq nq))

theorem demorganOr : (¬(p ∨ q) ↔ (¬p ∧ ¬q)) :=
  Iff.intro demorganOrForward demorganOrBackward

theorem testThm : (¬(p ∨ q) ↔ (¬p ∧ ¬q)) ∧  (¬(p ∧ q) ↔ (¬p ∨ ¬q)) :=
  And.intro demorganOr demorganAnd
