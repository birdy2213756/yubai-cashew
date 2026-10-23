param([string]$BaseHref = '/')
$ErrorActionPreference = 'Stop'
if (-not ($BaseHref.StartsWith('/') -and $BaseHref.EndsWith('/'))) { throw 'BaseHref must start and end with /.' }
$flutter = 'C:/Users/lenovo/Documents/Codex/tools/flutter-3.22.3/flutter/bin/flutter.bat'
if (-not (Test-Path -LiteralPath $flutter)) { $flutter = (Get-Command flutter -ErrorAction Stop).Source }
Push-Location (Join-Path $PSScriptRoot '../budget')
try {
  & $flutter build web --release --web-renderer html --pwa-strategy=none --no-web-resources-cdn --base-href $BaseHref
  if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
} finally { Pop-Location }
