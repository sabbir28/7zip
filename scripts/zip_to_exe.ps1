# 7-Zip: Convert ZIP / Archive / Folder to Self-Extracting Executable (.EXE)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Path to the .zip, .7z archive or folder to convert")]
    [string]$InputPath,

    [Parameter(Position = 1, HelpMessage = "Destination .exe path")]
    [string]$OutputPath = "",

    [ValidateSet("GUI", "Console")]
    [string]$Type = "GUI",

    [string]$Title = "",
    [string]$BeginPrompt = "",
    [string]$DefaultExtractPath = "",
    [string]$Password = "",
    [switch]$Overwrite,
    [switch]$Test
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$BinDir = Join-Path $RepoRoot "bin\x64"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 7-Zip Archive-to-EXE (SFX) Converter" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Verify 7zz executable
$7zzPath = Join-Path $BinDir "7zz.exe"
if (-not (Test-Path $7zzPath)) {
    Write-Host "7zz.exe not found in $BinDir. Compiling..." -ForegroundColor Yellow
    & (Join-Path $ScriptDir "build.ps1") -Target 7zz -Platform x64
}

# Determine SFX module
$sfxName = if ($Type -eq "GUI") { "7z.sfx" } else { "7zCon.sfx" }
$sfxPath = Join-Path $BinDir $sfxName

if (-not (Test-Path $sfxPath)) {
    Write-Host "$sfxName not found in $BinDir. Compiling..." -ForegroundColor Yellow
    $sfxTarget = if ($Type -eq "GUI") { "7z.sfx" } else { "7zCon.sfx" }
    & (Join-Path $ScriptDir "build.ps1") -Target $sfxTarget -Platform x64
}

if (-not (Test-Path $sfxPath)) {
    Write-Error "Required SFX module $sfxPath could not be located or compiled."
    exit 1
}

# Resolve input path
if (-not (Test-Path $InputPath)) {
    Write-Error "Input file or directory does not exist: $InputPath"
    exit 1
}
$resolvedInput = (Resolve-Path $InputPath).Path
$item = Get-Item $resolvedInput

# Determine output path
if (-not $OutputPath) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedInput)
    $parentDir = Split-Path -Parent $resolvedInput
    $OutputPath = Join-Path $parentDir "$baseName.exe"
}

if ((Test-Path $OutputPath) -and (-not $Overwrite)) {
    Write-Error "Output file already exists: $OutputPath. Use -Overwrite to replace."
    exit 1
}

Write-Host "Input Source:  $resolvedInput" -ForegroundColor White
Write-Host "Output Target: $OutputPath" -ForegroundColor White
Write-Host "SFX Mode:      $Type ($sfxName)" -ForegroundColor Yellow

$tempWorkingDir = Join-Path $env:TEMP ("7z_sfx_work_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempWorkingDir -Force | Out-Null

try {
    $sourceFilesDir = ""
    $hasSfxConfig = ($Title -or $BeginPrompt -or $DefaultExtractPath)

    if ($item.PSIsContainer) {
        # Input is a directory
        $sourceFilesDir = $resolvedInput
    }
    elseif ($item.Extension -ieq ".7z" -and (-not $hasSfxConfig) -and (-not $Password)) {
        # Input is already a .7z file and no custom config needed: fast binary append
        Write-Host "Attaching $sfxName header to existing 7z archive..." -ForegroundColor Cyan
        cmd /c "copy /b `"$sfxPath`" + `"$resolvedInput`" `"$OutputPath`"" | Out-Null
    }
    else {
        # Input is a ZIP (or RAR, TAR, GZ, etc.) - extract first to staging area
        Write-Host "Extracting archive contents from $($item.Name)..." -ForegroundColor Cyan
        $stageDir = Join-Path $tempWorkingDir "stage"
        New-Item -ItemType Directory -Path $stageDir -Force | Out-Null
        
        $extractArgs = @("x", $resolvedInput, "-o$stageDir", "-y")
        if ($Password) {
            $extractArgs += "-p$Password"
        }
        
        $p = Start-Process -FilePath $7zzPath -ArgumentList $extractArgs -NoNewWindow -PassThru -Wait
        if ($p.ExitCode -ne 0) {
            throw "Failed to extract input archive: $resolvedInput (Exit code: $($p.ExitCode))"
        }
        $sourceFilesDir = $stageDir
    }

    if ($sourceFilesDir) {
        Write-Host "Compressing contents with LZMA2 and embedding $sfxName..." -ForegroundColor Cyan
        $archiveArgs = @(
            "a",
            "-sfx$sfxPath",
            "-mx=9",
            "-mmt=on",
            $OutputPath,
            "$sourceFilesDir\*"
        )
        if ($Password) {
            $archiveArgs += "-p$Password"
            $archiveArgs += "-mhe=on"
        }

        # Build custom SFX config if requested
        if ($hasSfxConfig) {
            $cfgFile = Join-Path $tempWorkingDir "config.txt"
            $cfgContent = ";!@Install@!UTF-8!`r`n"
            if ($Title) { $cfgContent += "Title=`"$Title`"`r`n" }
            if ($BeginPrompt) { $cfgContent += "BeginPrompt=`"$BeginPrompt`"`r`n" }
            if ($DefaultExtractPath) { $cfgContent += "InstallPath=`"$DefaultExtractPath`"`r`n" }
            $cfgContent += ";!@InstallEnd@!`r`n"
            [System.IO.File]::WriteAllText($cfgFile, $cfgContent, [System.Text.Encoding]::UTF8)
            
            # Temporary 7z archive to concatenate with config
            $temp7z = Join-Path $tempWorkingDir "payload.7z"
            $packArgs = @("a", "-mx=9", "-mmt=on", $temp7z, "$sourceFilesDir\*")
            if ($Password) { $packArgs += "-p$Password"; $packArgs += "-mhe=on" }
            
            $p = Start-Process -FilePath $7zzPath -ArgumentList $packArgs -NoNewWindow -PassThru -Wait
            if ($p.ExitCode -ne 0) { throw "Payload compression failed." }
            
            # Merge SFX + Config + Payload
            cmd /c "copy /b `"$sfxPath`" + `"$cfgFile`" + `"$temp7z`" `"$OutputPath`"" | Out-Null
        } else {
            $p = Start-Process -FilePath $7zzPath -ArgumentList $archiveArgs -NoNewWindow -PassThru -Wait
            if ($p.ExitCode -ne 0) {
                throw "Failed to create SFX executable. (Exit code: $($p.ExitCode))"
            }
        }
    }

    if (-not (Test-Path $OutputPath)) {
        throw "Failed to produce output executable: $OutputPath"
    }

    $outItem = Get-Item $OutputPath
    $hash = (Get-FileHash -Path $OutputPath -Algorithm SHA256).Hash

    Write-Host "`n==================================================" -ForegroundColor Green
    Write-Host " SFX Executable Generated Successfully!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host " Executable: $OutputPath" -ForegroundColor White
    Write-Host " File Size:  $([Math]::Round($outItem.Length / 1KB, 2)) KB ($($outItem.Length) bytes)" -ForegroundColor Yellow
    Write-Host " SHA-256:    $hash" -ForegroundColor DarkGray
    Write-Host "`n>>> Any user can now double-click '$($outItem.Name)' on Windows to unzip!" -ForegroundColor Cyan
    Write-Host "    (No 7-Zip, WinRAR, or external unzip software required on the target machine)" -ForegroundColor Gray

    # Optional test verification
    if ($Test) {
        Write-Host "`n[Verifying Self-Extraction Test]..." -ForegroundColor Yellow
        $testOutDir = Join-Path $tempWorkingDir "test_extract"
        $testArgs = @("-o$testOutDir", "-y")
        if ($Password) { $testArgs += "-p$Password" }
        
        $p = Start-Process -FilePath $OutputPath -ArgumentList $testArgs -NoNewWindow -PassThru -Wait
        if ($p.ExitCode -eq 0 -and (Test-Path $testOutDir)) {
            $extractedCount = (Get-ChildItem -Recurse $testOutDir).Count
            Write-Host "PASS: Self-extraction test verified! ($extractedCount items extracted successfully)" -ForegroundColor Green
        } else {
            Write-Warning "Self-extraction verification exited with code $($p.ExitCode)"
        }
    }
}
finally {
    if (Test-Path $tempWorkingDir) {
        Remove-Item -Recurse -Force $tempWorkingDir -ErrorAction SilentlyContinue
    }
}
