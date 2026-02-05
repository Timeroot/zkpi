axiom MatMul (w : Type) : w → w

axiom myAx4 : ∀ (w : Type), MatMul w = id

theorem testThm (w : Type) : MatMul w = id := by
  exact myAx4 w
