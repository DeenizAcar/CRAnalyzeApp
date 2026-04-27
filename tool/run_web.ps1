# Flutter web'i .env'den token okuyarak baslatir.
# Calistirma:  pwsh tool/run_web.ps1
# veya         powershell -ExecutionPolicy Bypass -File tool/run_web.ps1

param(
    [string]$Port = "8765",
    [string]$UserDataDir = ""
)

if ($UserDataDir -eq "") {
    $stamp = Get-Date -Format "HHmmss"
    $UserDataDir = "C:\temp\cr-flutter-$stamp"
}
New-Item -ItemType Directory -Force -Path $UserDataDir | Out-Null

$ErrorActionPreference = "Stop"

if (-not (Test-Path ".env")) {
    Write-Error ".env dosyasi bulunamadi. .env.example'i .env olarak kopyala ve token'i yapistir."
    exit 1
}

$envVars = @{}
Get-Content ".env" | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }
    $eq = $line.IndexOf("=")
    if ($eq -lt 0) { return }
    $key = $line.Substring(0, $eq).Trim()
    $value = $line.Substring($eq + 1).Trim()
    if ($value -ne "") { $envVars[$key] = $value }
}

if (-not $envVars.ContainsKey("CR_API_TOKEN")) {
    Write-Error "CR_API_TOKEN .env icinde tanimli degil."
    exit 1
}

$args = @(
    "run", "-d", "chrome",
    "--web-port=$Port",
    "--web-browser-flag=--disable-web-security",
    "--web-browser-flag=--user-data-dir=$UserDataDir"
)

foreach ($key in $envVars.Keys) {
    $args += "--dart-define=$key=$($envVars[$key])"
}

Write-Host "Flutter run baslatiliyor (port $Port, $($envVars.Count) env var)..." -ForegroundColor Cyan
& flutter @args
