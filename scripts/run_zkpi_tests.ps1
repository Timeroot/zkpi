param(
  [string]$Configuration = "release"
)

$ErrorActionPreference = "Stop"

function Exec([string]$label, [scriptblock]$action) {
  Write-Host ">> $label"
  & $action
  if ($LASTEXITCODE -ne 0) {
    throw ("Command failed with exit code {0}: {1}" -f $LASTEXITCODE, $label)
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$testsDir = Join-Path $repoRoot "zkpi_tests"
$exporterExe = Join-Path $repoRoot "lean4export\.lake\build\bin\lean4export.exe"
$zkpiExe = Join-Path $repoRoot "target\$Configuration\zkpi.exe"

if (!(Test-Path $exporterExe)) {
  throw "lean4export not built. Expected: $exporterExe. Build it with: cd lean4export; lake build"
}
if (!(Test-Path $zkpiExe)) {
  throw "zkpi not built. Expected: $zkpiExe. Build it with: cargo build --release"
}

$tests = @(
  "ZkpiTests.Tests.Test1",
  "ZkpiTests.Tests.Test2",
  "ZkpiTests.Tests.Test3",
  "ZkpiTests.Tests.Test4",
  "ZkpiTests.Tests.Test5",
  "ZkpiTests.Tests.Test6",
  "ZkpiTests.Tests.Test7",
  "ZkpiTests.Tests.Test8",
  "ZkpiTests.Tests.Test9",
  "ZkpiTests.Tests.Test10",
  "ZkpiTests.Tests.AndComm",
  "ZkpiTests.Tests.DedupList"
)

Push-Location $testsDir
try {
  $results = @()
  foreach ($m in $tests) {
    Write-Host ""
    Write-Host "=== $m ==="

    # 1) Lean compile (quit early if Lean is broken)
    try {
      Exec "lake build $m" { & lake build $m }
    } catch {
      Write-Host "LEAN FAIL: $m"
      throw
    }

    # 2) Export only testThm
    $outFile = Join-Path $testsDir ("out\" + ($m -replace "\.","_") + ".out")
    New-Item -Force -ItemType Directory (Split-Path -Parent $outFile) | Out-Null
    $errFile = $outFile + ".stderr.txt"
    # IMPORTANT: Do NOT use PowerShell text redirection here (can add BOM / re-encode).
    # Use process-level stdout redirection to preserve the exact bytes from lean4export.
    Exec "lean4export $m -- testThm > $outFile" {
      if (Test-Path $outFile) { Remove-Item -Force $outFile }
      if (Test-Path $errFile) { Remove-Item -Force $errFile }
      $p = Start-Process -FilePath "lake" -ArgumentList @("env", $exporterExe, $m, "--", "testThm") -NoNewWindow -Wait -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
      $global:LASTEXITCODE = $p.ExitCode
    }

    # 3) Run zkpi exporter on testThm
    $zkpiOk = $true
    try {
      Exec "zkpi export testThm ($m)" { & $zkpiExe $outFile export testThm | Out-Null }
    } catch {
      $zkpiOk = $false
      Write-Host "RUST FAIL: $m"
    }
    $results += [pscustomobject]@{ Module = $m; Zkpi = $(if ($zkpiOk) { "PASS" } else { "FAIL" }); OutFile = $outFile }
  }
} finally {
  Pop-Location
}

Write-Host ""
Write-Host "=== Summary ==="
$results | Format-Table -AutoSize | Out-String | Write-Host

$failCount = ($results | Where-Object { $_.Zkpi -eq "FAIL" }).Count
if ($failCount -gt 0) {
  throw ("{0} test(s) failed in zkpi export." -f $failCount)
}

Write-Host "All tests passed."

