# 7-Zip Automated Build Script
[CmdletBinding()]
param(
    [ValidateSet("7zz", "7za", "7zFM", "7z", "7z.dll", "all")]
    [string]$Target = "7zz",

    [ValidateSet("x64", "x86", "arm64")]
    [string]$Platform = "x64",

    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$BinDir = Join-Path $RepoRoot "bin\$Platform"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 7-Zip Build Automation Tool" -ForegroundColor Cyan
Write-Host " Target:   $Target" -ForegroundColor Yellow
Write-Host " Platform: $Platform" -ForegroundColor Yellow
Write-Host " Root:     $RepoRoot" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan

# Locate vcvarsall.bat
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vcVarsPath = $null

if (Test-Path $vswhere) {
    $installPath = & $vswhere -latest -prerelease -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($installPath -and (Test-Path "$installPath\VC\Auxiliary\Build\vcvarsall.bat")) {
        $vcVarsPath = "$installPath\VC\Auxiliary\Build\vcvarsall.bat"
    }
}

if (-not $vcVarsPath) {
    $candidatePaths = @(
        "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat",
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    )
    foreach ($p in $candidatePaths) {
        if (Test-Path $p) {
            $vcVarsPath = $p
            break
        }
    }
}

if (-not $vcVarsPath) {
    Write-Error "Could not locate Visual Studio vcvarsall.bat environment initializer."
    exit 1
}

Write-Host "Using VC Environment: $vcVarsPath" -ForegroundColor Green

if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}

$TargetMap = @{
    "7zz"    = @{ SubDir = "CPP\7zip\Bundles\Alone2"; Output = "7zz.exe" }
    "7za"    = @{ SubDir = "CPP\7zip\Bundles\Alone"; Output = "7za.exe" }
    "7zFM"   = @{ SubDir = "CPP\7zip\Bundles\Fm"; Output = "7zFM.exe" }
    "7z.dll" = @{ SubDir = "CPP\7zip\Bundles\Format7zF"; Output = "7z.dll" }
    "7z"     = @{ SubDir = "CPP\7zip\UI\Console"; Output = "7z.exe" }
}

$TargetsToBuild = if ($Target -eq "all") {
    @("7zz", "7za", "7z.dll", "7z", "7zFM")
} else {
    @($Target)
}

foreach ($t in $TargetsToBuild) {
    $info = $TargetMap[$t]
    $dir = Join-Path $RepoRoot $info.SubDir
    $outName = $info.Output

    Write-Host "`n>>> Building $t ($outName) in $dir..." -ForegroundColor Yellow

    if ($Clean) {
        $objDir = Join-Path $dir $Platform
        if (Test-Path $objDir) {
            Write-Host "Cleaning $objDir..." -ForegroundColor DarkGray
            Remove-Item -Recurse -Force $objDir
        }
    }

    $cmd = "call `"$vcVarsPath`" $Platform && cd /d `"$dir`" && nmake"
    cmd /c $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed for target: $t (Exit code: $LASTEXITCODE)"
        exit $LASTEXITCODE
    }

    # Copy output binary to bin directory
    $builtBin = Join-Path $dir "$Platform\$outName"
    if (Test-Path $builtBin) {
        Copy-Item -Path $builtBin -Destination (Join-Path $BinDir $outName) -Force
        Write-Host "Successfully compiled and deployed $outName -> bin\$Platform\$outName" -ForegroundColor Green
    } else {
        Write-Warning "Expected binary not found at $builtBin"
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Build Complete! Binaries deployed to: $BinDir" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
