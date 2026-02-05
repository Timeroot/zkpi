universe u

def IsEven : Nat → Prop :=
  fun n ↦ @Nat.rec (fun _ ↦ Prop) true (fun np prev ↦ ¬ prev) n

inductive Graph (V : Type u) : Type u
| empty : Graph V
| vertex : (v : V) → (g : Graph V) → Graph V
| edge : (e : V × V) → Graph V → Graph V

noncomputable def totalDegree {V : Type u} (g: Graph V) : Nat :=
  Graph.recOn g 0 (fun v g p ↦ p) (fun e g p ↦ p + 2)

/-- totalDegree_is_even -/
theorem testThm (V : Type u) (g : Graph V) : IsEven (totalDegree g) :=
by
  induction g with
  | empty => exact rfl
  | vertex v g ih => exact ih
  | edge e g ih => exact not_not_intro ih
