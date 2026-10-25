# 7-Zip Automated Packaging Script
[CmdletBinding()]
param(
    [string]$Version = "26.05",
    [ValidateSet("x64", "x86", "arm64")]
    [string]$Platform = "x64"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$BinDir = Join-Path $RepoRoot "bin\$Platform"
$DistDir = Join-Path $RepoRoot "dist"
$StagingDir = Join-Path $DistDir "7zip-$Version-windows-$Platform"
$ZipName = "7zip-$Version-windows-$Platform.zip"
$ZipPath = Join-Path $DistDir $ZipName

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 7-Zip Release Packaging Utility" -ForegroundColor Cyan
Write-Host " Version:  $Version" -ForegroundColor Yellow
Write-Host " Platform: $Platform" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

if (-not (Test-Path $BinDir)) {
    Write-Error "Binary directory $BinDir does not exist. Please run .\scripts\build.ps1 first."
    exit 1
}

# Clean and recreate staging directories
if (Test-Path $StagingDir) {
    Remove-Item -Recurse -Force $StagingDir
}
New-Item -ItemType Directory -Path $StagingDir -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $StagingDir "docs") -Force | Out-Null

# Copy binaries
$binaries = Get-ChildItem -Path $BinDir -Filter "*.*" | Where-Object { $_.Extension -in @(".exe", ".dll") }
if ($binaries.Count -eq 0) {
    Write-Error "No executables or DLLs found in $BinDir!"
    exit 1
}

foreach ($b in $binaries) {
    Copy-Item -Path $b.FullName -Destination $StagingDir -Force
    Write-Host "Added binary: $($b.Name)" -ForegroundColor Green
}

# Copy documentation and licenses
Copy-Item (Join-Path $RepoRoot "README.md") -Destination $StagingDir -Force
Copy-Item (Join-Path $RepoRoot "LICENSE") -Destination $StagingDir -Force
Copy-Item (Join-Path $RepoRoot "CHANGELOG.md") -Destination $StagingDir -Force
if (Test-Path (Join-Path $RepoRoot "DOC")) {
    Copy-Item (Join-Path $RepoRoot "DOC\*") -Destination (Join-Path $StagingDir "docs") -Recurse -Force
}

# Create Zip Archive
if (Test-Path $ZipPath) {
    Remove-Item -Force $ZipPath
}

Write-Host "Compressing archive to: $ZipName..." -ForegroundColor Cyan
Compress-Archive -Path "$StagingDir\*" -DestinationPath $ZipPath -CompressionLevel Optimal

# Compute SHA256 hash
$hash = (Get-FileHash -Path $ZipPath -Algorithm SHA256).Hash
$hashFile = Join-Path $DistDir "SHA256SUMS.txt"
"$hash  $ZipName" | Out-File -FilePath $hashFile -Encoding utf8 -Append

# Clean staging directory
Remove-Item -Recurse -Force $StagingDir

Write-Host "`nRelease archive created successfully:" -ForegroundColor Green
Write-Host "  File:   $ZipPath" -ForegroundColor White
Write-Host "  SHA256: $hash" -ForegroundColor Yellow
