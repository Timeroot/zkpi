import Init.Prelude

axiom f : Unit → Unit
axiom myAx4 : f = id

theorem testThm : f = id := by
  exact myAx4
