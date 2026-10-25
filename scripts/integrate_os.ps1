# 7-Zip OS Integration & Windows Explorer Context Menu Manager
[CmdletBinding(DefaultParameterSetName = "Install")]
param(
    [Parameter(ParameterSetName = "Install")]
    [switch]$Install,

    [Parameter(ParameterSetName = "Uninstall")]
    [switch]$Uninstall,

    [Parameter(ParameterSetName = "Status")]
    [switch]$Status,

    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser",

    [string]$BinPath = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

if (-not $BinPath) {
    $BinPath = Join-Path $RepoRoot "bin\x64"
}

$7zFM = Join-Path $BinPath "7zFM.exe"
$7zG  = Join-Path $BinPath "7zG.exe"
$7zz  = Join-Path $BinPath "7zz.exe"
$sfx  = Join-Path $BinPath "7z.sfx"
$dll  = Join-Path $BinPath "7-zip.dll"

$Hive = if ($Scope -eq "CurrentUser") {
    [Microsoft.Win32.Registry]::CurrentUser
} else {
    [Microsoft.Win32.Registry]::LocalMachine
}
$Prefix = "Software\Classes"

$ZipToExeScript = Join-Path $ScriptDir "zip_to_exe.ps1"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " 7-Zip Windows OS Integration Manager" -ForegroundColor Cyan
Write-Host " Scope:     $Scope" -ForegroundColor Yellow
Write-Host " Target:    $($Hive.Name)\$Prefix" -ForegroundColor Gray
Write-Host " Binaries:  $BinPath" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan

function Set-RegData {
    param(
        [string]$SubKeyPath,
        [string]$DefaultValue = $null,
        [hashtable]$Properties = @{}
    )
    $fullPath = "$Prefix\$SubKeyPath"
    $k = $Hive.CreateSubKey($fullPath)
    if ($null -ne $DefaultValue) {
        $k.SetValue("", $DefaultValue)
    }
    foreach ($prop in $Properties.Keys) {
        $k.SetValue($prop, $Properties[$prop])
    }
    $k.Close()
}

function Remove-RegTree {
    param([string]$SubKeyPath)
    $fullPath = "$Prefix\$SubKeyPath"
    try {
        $Hive.DeleteSubKeyTree($fullPath)
    } catch {
        # Ignore if does not exist
    }
}

# Archive extensions for top-level direct 'Extract' & 'Inspect' actions
$ArchiveExtensions = @(
    ".zip", ".7z", ".rar", ".tar", ".gz", ".tgz",
    ".bz2", ".tbz2", ".xz", ".txz", ".iso", ".wim",
    ".cab", ".arj", ".cpio", ".rpm", ".deb", ".dmg",
    ".vhd", ".vhdx", ".vmdk", ".exe"
)

# 1. STATUS
if ($Status) {
    $checkKey = "$Prefix\*\shell\7-Zip"
    $k = $Hive.OpenSubKey($checkKey)
    if ($k) {
        $k.Close()
        Write-Host "`nSTATUS: 7-Zip OS Integration is currently INSTALLED ($Scope)." -ForegroundColor Green
    } else {
        Write-Host "`nSTATUS: 7-Zip OS Integration is NOT installed in $Scope." -ForegroundColor Yellow
    }
    exit 0
}

# 2. UNINSTALL
if ($Uninstall) {
    Write-Host "`nRemoving 7-Zip Explorer integration from $Scope..." -ForegroundColor Yellow

    # Remove cascading menus
    Remove-RegTree "*\shell\7-Zip"
    Remove-RegTree "Directory\shell\7-Zip"
    Remove-RegTree "Directory\Background\shell\7-Zip"

    # Remove top-level direct verbs on extensions
    foreach ($ext in $ArchiveExtensions) {
        Remove-RegTree "$ext\shell\7zip_extract"
        Remove-RegTree "$ext\shell\7zip_inspect"
    }

    # Unregister COM shell extension if registered
    if (Test-Path $dll) {
        cmd /c "regsvr32.exe /u /s `"$dll`""
    }

    Write-Host "7-Zip OS Integration successfully uninstalled from $Scope." -ForegroundColor Green
    exit 0
}

# 3. INSTALLATION
if (-not (Test-Path $7zFM) -or -not (Test-Path $7zG)) {
    Write-Host "`nRequired binaries missing in $BinPath. Running automated build..." -ForegroundColor Yellow
    & (Join-Path $ScriptDir "build.ps1") -Target gui -Platform x64
}

if (-not (Test-Path $7zFM)) {
    Write-Error "Could not locate 7zFM.exe at $7zFM."
    exit 1
}

Write-Host "`nRegistering Windows Explorer context menu actions..." -ForegroundColor Cyan

# 3.1 Cascading Context Menu for All Files: *\shell\7-Zip
Set-RegData -SubKeyPath "*\shell\7-Zip" -DefaultValue "7-Zip" -Properties @{
    "MUIVerb"     = "7-Zip"
    "Icon"        = "`"$7zFM`",0"
    "SubCommands" = ""
}

$sub = "*\shell\7-Zip\shell"

# Open in Archive Manager
Set-RegData -SubKeyPath "$sub\01_inspect" -DefaultValue "Open in 7-Zip Archive Manager" -Properties @{
    "MUIVerb" = "Open in 7-Zip Archive Manager"
    "Icon"    = "`"$7zFM`",0"
}
Set-RegData -SubKeyPath "$sub\01_inspect\command" -DefaultValue "`"$7zFM`" `"%1`""

# Extract files... (GUI Dialog)
Set-RegData -SubKeyPath "$sub\02_extract_gui" -DefaultValue "Extract files..." -Properties @{
    "MUIVerb" = "Extract files..."
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$sub\02_extract_gui\command" -DefaultValue "`"$7zG`" x `"%1`""

# Extract Here
Set-RegData -SubKeyPath "$sub\03_extract_here" -DefaultValue "Extract Here" -Properties @{
    "MUIVerb" = "Extract Here"
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$sub\03_extract_here\command" -DefaultValue "`"$7zG`" x `"%1`" -spe"

# Extract to *\"
Set-RegData -SubKeyPath "$sub\04_extract_to" -DefaultValue "Extract to *\" -Properties @{
    "MUIVerb" = "Extract to *\"
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$sub\04_extract_to\command" -DefaultValue "`"$7zG`" x `"%1`" -o`"%1*`" -spe"

# Test archive
Set-RegData -SubKeyPath "$sub\05_test" -DefaultValue "Test archive" -Properties @{
    "MUIVerb" = "Test archive"
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$sub\05_test\command" -DefaultValue "`"$7zG`" t `"%1`""

# Add to archive...
Set-RegData -SubKeyPath "$sub\06_add_gui" -DefaultValue "Add to archive..." -Properties @{
    "MUIVerb" = "Add to archive..."
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$sub\06_add_gui\command" -DefaultValue "`"$7zG`" a `"%1`""

# Add to %1.7z
Set-RegData -SubKeyPath "$sub\07_add_7z" -DefaultValue "Add to *\.7z" -Properties @{
    "MUIVerb" = "Add to *\.7z"
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$sub\07_add_7z\command" -DefaultValue "`"$7zG`" a -t7z `"%1.7z`" `"%1`""

# Add to %1.zip
Set-RegData -SubKeyPath "$sub\08_add_zip" -DefaultValue "Add to *\.zip" -Properties @{
    "MUIVerb" = "Add to *\.zip"
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$sub\08_add_zip\command" -DefaultValue "`"$7zG`" a -tzip `"%1.zip`" `"%1`""

# Convert to Self-Extracting (.EXE)
Set-RegData -SubKeyPath "$sub\09_convert_exe" -DefaultValue "Convert to Self-Extracting (.EXE)..." -Properties @{
    "MUIVerb" = "Convert to Self-Extracting (.EXE)..."
    "Icon"    = "`"$7zFM`",0"
}
Set-RegData -SubKeyPath "$sub\09_convert_exe\command" -DefaultValue "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ZipToExeScript`" -InputPath `"%1`""

# 3.2 Cascading Context Menu for Folders / Directories: Directory\shell\7-Zip
Set-RegData -SubKeyPath "Directory\shell\7-Zip" -DefaultValue "7-Zip" -Properties @{
    "MUIVerb"     = "7-Zip"
    "Icon"        = "`"$7zFM`",0"
    "SubCommands" = ""
}
$dirSub = "Directory\shell\7-Zip\shell"

Set-RegData -SubKeyPath "$dirSub\01_add_gui" -DefaultValue "Add to archive..." -Properties @{
    "MUIVerb" = "Add to archive..."
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$dirSub\01_add_gui\command" -DefaultValue "`"$7zG`" a `"%1`""

Set-RegData -SubKeyPath "$dirSub\02_add_7z" -DefaultValue "Add to *\.7z" -Properties @{
    "MUIVerb" = "Add to *\.7z"
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$dirSub\02_add_7z\command" -DefaultValue "`"$7zG`" a -t7z `"%1.7z`" `"%1`""

Set-RegData -SubKeyPath "$dirSub\03_add_zip" -DefaultValue "Add to *\.zip" -Properties @{
    "MUIVerb" = "Add to *\.zip"
    "Icon"    = "`"$7zG`",0"
}
Set-RegData -SubKeyPath "$dirSub\03_add_zip\command" -DefaultValue "`"$7zG`" a -tzip `"%1.zip`" `"%1`""

Set-RegData -SubKeyPath "$dirSub\04_convert_exe" -DefaultValue "Package as Self-Extracting (.EXE)..." -Properties @{
    "MUIVerb" = "Package as Self-Extracting (.EXE)..."
    "Icon"    = "`"$7zFM`",0"
}
Set-RegData -SubKeyPath "$dirSub\04_convert_exe\command" -DefaultValue "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ZipToExeScript`" -InputPath `"%1`""

# 3.3 Top-Level Direct Verbs on Supported Archive & Executable Formats
foreach ($ext in $ArchiveExtensions) {
    # Extract with 7-Zip...
    Set-RegData -SubKeyPath "$ext\shell\7zip_extract" -DefaultValue "Extract with 7-Zip..." -Properties @{
        "MUIVerb" = "Extract with 7-Zip..."
        "Icon"    = "`"$7zG`",0"
    }
    Set-RegData -SubKeyPath "$ext\shell\7zip_extract\command" -DefaultValue "`"$7zG`" x `"%1`""

    # Inspect in 7-Zip Archive Manager
    Set-RegData -SubKeyPath "$ext\shell\7zip_inspect" -DefaultValue "Inspect in 7-Zip Archive Manager" -Properties @{
        "MUIVerb" = "Inspect in 7-Zip Archive Manager"
        "Icon"    = "`"$7zFM`",0"
    }
    Set-RegData -SubKeyPath "$ext\shell\7zip_inspect\command" -DefaultValue "`"$7zFM`" `"%1`""
}

# 3.4 Register COM Shell Extension if 7-zip.dll exists
if (Test-Path $dll) {
    try {
        cmd /c "regsvr32.exe /s `"$dll`""
        Write-Host "Registered COM shell extension: $dll" -ForegroundColor DarkGray
    } catch {}
}

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " 7-Zip OS Integration Completed Successfully!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host " Context menu actions enabled in Windows Explorer:" -ForegroundColor Yellow
Write-Host "   1. Right-click any file (.exe, .zip, .7z, .rar, .tar, etc.):" -ForegroundColor White
Write-Host "      - 'Extract with 7-Zip...' (direct top-level verb)" -ForegroundColor Cyan
Write-Host "      - 'Inspect in 7-Zip Archive Manager' (direct top-level verb)" -ForegroundColor Cyan
Write-Host "      - '7-Zip' cascading sub-menu (Extract Here, Extract to, Test, Compress, SFX)" -ForegroundColor Cyan
Write-Host "   2. Right-click any folder:" -ForegroundColor White
Write-Host "      - '7-Zip' -> Add to archive, Add to .7z, Add to .zip, Package as EXE" -ForegroundColor Cyan
Write-Host "`n To check status:   .\scripts\integrate_os.ps1 -Status" -ForegroundColor DarkGray
Write-Host " To uninstall:      .\scripts\integrate_os.ps1 -Uninstall" -ForegroundColor DarkGray
