import Init.Prelude

axiom f : Unit → Unit
axiom myAx4 : f = (fun x ↦ x)

theorem testThm : f = id := by
  exact myAx4
