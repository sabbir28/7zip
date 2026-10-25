# 7-Zip Deep Clean Script
[CmdletBinding()]
param()

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

Write-Host "Cleaning 7-Zip repository artifacts at $RepoRoot..." -ForegroundColor Yellow

$foldersToRemove = @(
    "bin",
    "dist",
    "build",
    "release_dist"
)

foreach ($f in $foldersToRemove) {
    $p = Join-Path $RepoRoot $f
    if (Test-Path $p) {
        Write-Host "Removing $f..." -ForegroundColor DarkGray
        Remove-Item -Recurse -Force $p -ErrorAction SilentlyContinue
    }
}

# Remove intermediate build folders in bundles
$bundleObjs = Get-ChildItem -Path (Join-Path $RepoRoot "CPP\7zip") -Recurse -Directory | Where-Object {
    $_.Name -in @("x64", "x86", "arm64", "b", "O", "`$O")
}

foreach ($d in $bundleObjs) {
    Write-Host "Removing build folder: $($d.FullName)" -ForegroundColor DarkGray
    Remove-Item -Recurse -Force $d.FullName -ErrorAction SilentlyContinue
}

# Remove stray object/lib files
$filesToRemove = Get-ChildItem -Path $RepoRoot -Recurse -Include @("*.obj", "*.res", "*.pch", "*.idb", "*.pdb", "*.ilk", "*.exp")
foreach ($file in $filesToRemove) {
    Remove-Item -Force $file.FullName -ErrorAction SilentlyContinue
}

Write-Host "Repository clean complete." -ForegroundColor Green
