# 7-Zip Automated Functional Test Suite
[CmdletBinding()]
param(
    [string]$ExePath = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

if (-not $ExePath) {
    $candidates = @(
        (Join-Path $RepoRoot "bin\x64\7zz.exe"),
        (Join-Path $RepoRoot "CPP\7zip\Bundles\Alone2\x64\7zz.exe")
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) {
            $ExePath = $c
            break
        }
    }
}

if (-not $ExePath -or -not (Test-Path $ExePath)) {
    Write-Error "7zz.exe executable not found. Please run .\scripts\build.ps1 first."
    exit 1
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 7-Zip Functional Test Suite" -ForegroundColor Cyan
Write-Host " Executable: $ExePath" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan

$TestDir = Join-Path $RepoRoot "build\test_workspace"
if (Test-Path $TestDir) {
    Remove-Item -Recurse -Force $TestDir
}
New-Item -ItemType Directory -Path $TestDir -Force | Out-Null

try {
    # 1. Version and Help Verification
    Write-Host "`n[Test 1/5] Verifying 7zz identification and CLI output..." -ForegroundColor Yellow
    $out = & $ExePath
    if ($out -match "7-Zip") {
        Write-Host "PASS: 7zz identified successfully." -ForegroundColor Green
    } else {
        throw "Failed to verify 7-Zip identification output."
    }

    # 2. Benchmark Execution
    Write-Host "`n[Test 2/5] Running LZMA Multi-Threaded Benchmark (1 iteration)..." -ForegroundColor Yellow
    & $ExePath b 1 -mmt=2
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PASS: Benchmark completed successfully." -ForegroundColor Green
    } else {
        throw "Benchmark failed with exit code $LASTEXITCODE"
    }

    # 3. Create Sample Files & Archive
    Write-Host "`n[Test 3/5] Testing Archive Creation (7z format, LZMA2)..." -ForegroundColor Yellow
    $srcDir = Join-Path $TestDir "input"
    New-Item -ItemType Directory -Path $srcDir -Force | Out-Null
    "Hello 7-Zip World 2026!" | Out-File (Join-Path $srcDir "file1.txt") -Encoding utf8
    "Another text file with repeated contents for compression test." * 50 | Out-File (Join-Path $srcDir "file2.txt") -Encoding utf8

    $archivePath = Join-Path $TestDir "test.7z"
    & $ExePath a $archivePath "$srcDir\*" -mx=9
    if ($LASTEXITCODE -eq 0 -and (Test-Path $archivePath)) {
        Write-Host "PASS: Created archive $archivePath (Size: $((Get-Item $archivePath).Length) bytes)." -ForegroundColor Green
    } else {
        throw "Archive creation failed."
    }

    # 4. Integrity Test and Extraction
    Write-Host "`n[Test 4/5] Testing Archive Integrity and Path Extraction..." -ForegroundColor Yellow
    & $ExePath t $archivePath
    if ($LASTEXITCODE -ne 0) {
        throw "Archive integrity test failed!"
    }

    $extractDir = Join-Path $TestDir "extracted"
    & $ExePath x $archivePath -o"$extractDir" -y
    if ($LASTEXITCODE -eq 0 -and (Test-Path (Join-Path $extractDir "file1.txt"))) {
        Write-Host "PASS: Extracted contents and verified integrity." -ForegroundColor Green
    } else {
        throw "Extraction test failed."
    }

    # 5. Password Protection (AES-256)
    Write-Host "`n[Test 5/5] Testing AES-256 Encryption & Decryption..." -ForegroundColor Yellow
    $encArchive = Join-Path $TestDir "encrypted.7z"
    $pass = "SuperSecretPassword2026!"
    & $ExePath a $encArchive "$srcDir\*" -p"$pass" -mhe=on
    if ($LASTEXITCODE -ne 0) {
        throw "Encrypted archive creation failed."
    }

    $encExtractDir = Join-Path $TestDir "extracted_enc"
    & $ExePath x $encArchive -o"$encExtractDir" -p"$pass" -y
    if ($LASTEXITCODE -eq 0 -and (Test-Path (Join-Path $encExtractDir "file1.txt"))) {
        Write-Host "PASS: AES-256 Encrypted archive extracted and verified." -ForegroundColor Green
    } else {
        throw "AES-256 extraction test failed."
    }

    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host " ALL TESTS PASSED SUCCESSFULLY! (5/5)" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
}
finally {
    if (Test-Path $TestDir) {
        Remove-Item -Recurse -Force $TestDir -ErrorAction SilentlyContinue
    }
}
