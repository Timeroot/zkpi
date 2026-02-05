def IntMatrix (w : Nat) := Fin w → Fin w → Nat

axiom Fin.sum {α : Type u} {n : Nat} [Zero α] [Add α] (x : Fin n → α) : α

noncomputable def MatMul {w} : IntMatrix w → IntMatrix w → IntMatrix w :=
  fun A B i k ↦ Fin.sum (fun j ↦ (A i j) * (B j k))

instance {w : Nat} : Zero (IntMatrix w) where
  zero i j := 0

axiom myFunext :
  ∀ {α : Type} {β : α → Type} {f g : (x : α) → β x},
    (∀ (x : α), f x = g x) → f = g

axiom myAx5 :
  ∀ (w : Nat) (A : IntMatrix w) (i : Fin w),
    (Fin.sum fun k => A i k * 0) = 0

theorem testThm {w} (A : IntMatrix w) : MatMul A 0 = 0 := by
  apply myFunext
  intro i
  apply myFunext
  intro j
  dsimp [MatMul]
  change (Fin.sum fun k ↦ A i k * 0) = 0
  apply myAx5
