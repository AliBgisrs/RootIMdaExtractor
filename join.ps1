# Rebuilds ForAliyah.7z from its parts. Run with:  powershell -ExecutionPolicy Bypass -File join.ps1
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$Name = 'ForAliyah.7z'
$Expected = 96326898
$Sha = 'f0d639f680c9319c83c44171d13e554617cfffeb30f05df103bda72d3b9e4c85'
Write-Host "Joining parts of $Name ..."
Remove-Item -LiteralPath $Name -ErrorAction SilentlyContinue
$pattern = '^' + [regex]::Escape($Name) + '\.\d{3}$'
$parts = Get-ChildItem -LiteralPath . -File | Where-Object { $_.Name -match $pattern } | Sort-Object Name
if (-not $parts) { throw "No parts found next to this script." }
$out = [IO.File]::Create((Join-Path $PSScriptRoot $Name))
try {
  foreach ($p in $parts) { $in = [IO.File]::OpenRead($p.FullName); try { $in.CopyTo($out) } finally { $in.Dispose() } }
} finally { $out.Dispose() }
Write-Host "Joined $($parts.Count) parts."
$size = (Get-Item -LiteralPath $Name).Length
if ($size -ne $Expected) { throw "SIZE MISMATCH: got $size bytes, expected $Expected. A part is missing or damaged." }
Write-Host "Size OK: $size bytes."
if ($Sha) {
  Write-Host "Checking SHA-256 (this can take a while)..."
  $got = (Get-FileHash -LiteralPath $Name -Algorithm SHA256).Hash.ToLower()
  if ($got -ne $Sha) { throw "CHECKSUM MISMATCH. The rebuilt file is damaged." }
  Write-Host "Checksum OK. $Name is complete and intact."
}
Write-Host "Done: $Name"
