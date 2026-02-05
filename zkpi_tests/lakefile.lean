import Lake
open Lake DSL

package zkpi_tests where
  leanOptions := #[
    ⟨`linter.unusedVariables, false⟩
  ]

lean_lib ZkpiTests where
  -- Keep this project standalone: we only rely on Lean core (`Init`).
