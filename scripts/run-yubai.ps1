param([int]$Port = 7357)
$ErrorActionPreference = 'Stop'
$flutter = 'C:/Users/lenovo/Documents/Codex/tools/flutter-3.22.3/flutter/bin/flutter.bat'
if (-not (Test-Path -LiteralPath $flutter)) { $flutter = (Get-Command flutter -ErrorAction Stop).Source }
Push-Location (Join-Path $PSScriptRoot '../budget')
try {
  & $flutter run -d web-server --web-hostname 127.0.0.1 --web-port $Port --web-renderer html
  if ($LASTEXITCODE -ne 0) { throw 'Flutter web run failed.' }
} finally { Pop-Location }
