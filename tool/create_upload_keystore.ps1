# Creates android/upload-keystore.jks + android/key.properties (both gitignored).
# Usage: powershell -ExecutionPolicy Bypass -File tool/create_upload_keystore.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$androidDir = Join-Path $root "android"
$jks = Join-Path $androidDir "upload-keystore.jks"
$props = Join-Path $androidDir "key.properties"

$keytoolCandidates = @(
    "$env:LOCALAPPDATA\Android\Sdk\jbr\bin\keytool.exe",
    "${env:ProgramFiles}\Android\Android Studio\jbr\bin\keytool.exe",
    "${env:ProgramFiles}\Android\Android Studio1\jbr\bin\keytool.exe",
    "$env:JAVA_HOME\bin\keytool.exe"
)
$keytool = $keytoolCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $keytool) { throw "keytool.exe not found. Install Android Studio JDK." }

if (Test-Path $jks) {
    Write-Host "Already exists: $jks"
    Write-Host "Delete it first if you want to regenerate."
    exit 1
}

$pass = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })

& $keytool -genkeypair -v `
    -keystore $jks `
    -storetype PKCS12 `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias upload `
    -storepass $pass `
    -keypass $pass `
    -dname "CN=DragonsBlock, OU=Mobile, O=DragonsBlock, L=Istanbul, ST=Istanbul, C=TR"

@"
storePassword=$pass
keyPassword=$pass
keyAlias=upload
storeFile=upload-keystore.jks
"@ | Set-Content -Path $props -Encoding UTF8

Write-Host ""
Write-Host "Created:"
Write-Host "  $jks"
Write-Host "  $props"
Write-Host ""
Write-Host "BACKUP the .jks and passwords offline. Losing them blocks Play updates."
Write-Host "Both files are gitignored — do not commit them."
