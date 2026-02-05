axiom Fin.sum {α : Type u} {n : Nat} [Add α] (x : Fin n → α) : α

noncomputable def MatMul {w} : (Fin w → Nat) → (Fin w → Nat) :=
  fun A i ↦ Fin.sum (A)

axiom myAx4 : ∀ (w : Nat), MatMul (w := w) = id

theorem testThm {w} : MatMul (w := w) = id := by
  exact myAx4 w
