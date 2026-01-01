$ErrorActionPreference = "Stop"

$flutterPath = "$env:USERPROFILE\flutter"
$zipPath = "$env:USERPROFILE\flutter_sdk.zip"

if (!(Test-Path $flutterPath)) {
    Write-Host "Downloading Flutter SDK (this may take a few minutes)..." -ForegroundColor Cyan

    $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $zipPath

    Write-Host "Extracting Flutter SDK to $env:USERPROFILE..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $env:USERPROFILE -Force

    Remove-Item $zipPath -Force

    Write-Host "Flutter installed to $flutterPath" -ForegroundColor Green
} else {
    Write-Host "Flutter folder already exists at $flutterPath" -ForegroundColor Yellow
}

Write-Host "`nFlutter path: $flutterPath\bin" -ForegroundColor Cyan
