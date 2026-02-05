def IntMatrix (w : Nat) := Fin w → Fin w → Nat

def Fin.sum {α : Type u} {n : Nat} [Zero α] [Add α] (x : Fin n → α) : α :=
  foldr n (x · + ·) 0

noncomputable def MatMul {w} : IntMatrix w → IntMatrix w → IntMatrix w :=
  fun A B i k ↦ Fin.sum (fun j ↦ (A i j) * (B j k))

instance {w : Nat} : Zero (IntMatrix w) where
  zero i j := 0

axiom myFunext :
  ∀ {α : Type} {β : α → Type} {f g : (x : α) → β x},
    (∀ (x : α), f x = g x) → f = g

theorem testThm {w} (A : IntMatrix w) : MatMul A 0 = 0 := by
  apply myFunext
  intro i
  apply myFunext
  intro j
  dsimp [MatMul]
  change (Fin.sum fun k ↦ A i k * 0) = 0
  refine Eq.trans (b := (Fin.sum (n := w) (fun k => 0))) ?_ ?_
  · rfl
  · clear A i j
    induction w
    · rfl
    · rename_i n ih
      dsimp [Fin.sum] at *
      rw [Fin.foldr_succ, ih]
