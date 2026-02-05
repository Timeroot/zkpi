axiom em' : ∀ (p : Prop), p ∨ ¬p

theorem em'_ok : (type_of% em') := Classical.em

def em := em' --Classical.em works too, but we need to avoid Quot.sound.

theorem testThm {p q : Prop} : (¬(p ∨ q) ↔ (¬p ∧ ¬q)) ∧  (¬(p ∧ q) ↔ (¬p ∨ ¬q)) :=
  let demorganAndForward {p q : Prop} : ¬(p ∧ q) → (¬p ∨ ¬q) := by
    intros h
    apply Or.elim (em p)
    intro hp
    let nq := λ hq => h (And.intro hp hq)
    exact Or.intro_right _ nq
    intro hnp
    exact Or.intro_left _ hnp
  let demorganAndBackward {p q : Prop} : (¬p ∨ ¬q) → ¬(p ∧ q) := by
    intro h
    apply Or.elim h
    intro np
    exact (λ hpq => np (And.left hpq))
    intro nq
    exact (λ hpq => nq (And.right hpq))
  let demorganAnd := Iff.intro demorganAndForward demorganAndBackward
  let demorganOrForward {p q : Prop} : ¬(p ∨ q) → (¬p ∧ ¬q) := by
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
  let demorganOrBackward {p q : Prop} : (¬p ∧ ¬q) → ¬(p ∨ q) := by
    intro h
    let np := And.left h
    let nq := And.right h
    exact (λ porq => Or.elim porq (λ hp => absurd hp np) (λ hq => absurd hq nq))
  let demorganOr := Iff.intro demorganOrForward demorganOrBackward
  And.intro demorganOr demorganAnd
