$ErrorActionPreference = 'Stop'
$raizLira = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $raizLira
try {
    python tool/verificar_supabase.py env.json
    if ($LASTEXITCODE -ne 0) { throw 'La verificación de Supabase ha fallado.' }
    flutter build web --release --no-wasm-dry-run --dart-define-from-file=env.json --dart-define=REQUIRE_REMOTE_BACKEND=true
    if ($LASTEXITCODE -ne 0) { throw 'La compilación web ha fallado.' }
    Write-Output "Web lista para publicar: $raizLira\build\web"
} finally {
    Pop-Location
}
