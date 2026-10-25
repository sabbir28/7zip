# 7-Zip OS Integration & Windows Shell Guide

This document describes how 7-Zip integrates natively with the Windows operating system to provide context-menu archive extraction, archive inspection, and management across supported file types and executables.

---

## 1. Overview & Shell Capabilities

By integrating 7-Zip into the Windows Shell (`explorer.exe`), users can interact with compressed containers, archive files, and executable installers (`.exe`) directly through Windows Explorer right-click menus.

```
+-------------------------------------------------------------------------+
| Windows Explorer Right-Click Menu                                       |
+-------------------------------------------------------------------------+
| Open                                                                    |
| Extract with 7-Zip...                 -> Native GUI Extraction Dialog   |
| Inspect in 7-Zip Archive Manager      -> Browse inside .exe / .zip / .7z|
|                                                                         |
| > 7-Zip                           --> [Cascading Submenu]               |
|                                       |-- Open in Archive Manager       |
|                                       |-- Extract files...              |
|                                       |-- Extract Here                  |
|                                       |-- Extract to *\"                |
|                                       |-- Test archive                  |
|                                       |-- Add to archive...             |
|                                       |-- Add to *.7z / *.zip           |
|                                       `-- Convert to Self-Extract (.EXE)|
+-------------------------------------------------------------------------+
```

---

## 2. Right-Click Actions on Files & Executables

When right-clicking supported files (including `.exe`, `.zip`, `.7z`, `.rar`, `.tar`, `.gz`, `.xz`, `.iso`, `.wim`, `.cab`):

| Action | Executable Invoked | Description |
| ------ | ------------------ | ----------- |
| **Extract with 7-Zip...** | `7zG.exe x "%1"` | Prompts the user with a native Windows GUI dialog to choose the destination folder, specify password, and extract contents. |
| **Inspect in 7-Zip Archive Manager** | `7zFM.exe "%1"` | Opens the file directly in the 7-Zip File Manager, allowing inspection of internal file structure, resources, certificates, and metadata without unpacking to disk. |
| **Extract Here** | `7zG.exe x "%1" -spe` | Unpacks all archive contents directly into the current directory. |
| **Extract to `*\"`** | `7zG.exe x "%1" -o"%1*" -spe` | Creates a new subfolder matching the archive filename and extracts all files inside it. |
| **Test archive** | `7zG.exe t "%1"` | Performs CRC32/SHA-256 block checksum verification to confirm archive integrity without extracting files. |
| **Add to archive...** | `7zG.exe a "%1"` | Opens the GUI compression wizard to configure compression level, dictionary size, and encryption. |
| **Convert to Self-Extracting (.EXE)** | `zip_to_exe.ps1` | Converts the selected archive or folder into an auto-extracting `.exe` that unzips on double-click. |

---

## 3. Extracting and Inspecting `.EXE` Installers

Executable files (`.exe`) often contain embedded archive containers (e.g. InnoSetup, NSIS, Wise, SFX, PE resources, UEFI firmware, or CAB payloads).

With 7-Zip OS integration:
1. **Right-Click any `.exe`** -> Select **"Extract with 7-Zip..."**:
   - 7-Zip automatically parses the PE executable binary headers.
   - Detects overlay archives (NSIS, 7z SFX, ZIP SFX, CAB).
   - Extracts all embedded setup files and drivers directly to a designated folder.
2. **Right-Click any `.exe`** -> Select **"Inspect in 7-Zip Archive Manager"**:
   - Safely explore the executable payload, inspect embedded DLLs, manifests, and version resources without executing the installer!

---

## 4. Supported Formats for Context Menu Actions

| Category | File Extensions |
| -------- | --------------- |
| **Native Archives** | `.zip`, `.7z`, `.rar`, `.tar`, `.gz`, `.tgz`, `.bz2`, `.tbz2`, `.xz`, `.txz` |
| **Disk Images & VM Files** | `.iso`, `.wim`, `.dmg`, `.vhd`, `.vhdx`, `.vmdk`, `.fat`, `.ntfs` |
| **Package & Installer Formats** | `.exe`, `.cab`, `.arj`, `.cpio`, `.rpm`, `.deb`, `.msi` |

---

## 5. Managing OS Integration

The integration is managed via [`scripts/integrate_os.ps1`](file:///f:/Project/7zip/scripts/integrate_os.ps1):

### Install Context Menus (Current User - No Admin Required)
```powershell
.\scripts\integrate_os.ps1
```

### Install System-Wide (All Users - Elevated Prompt)
```powershell
.\scripts\integrate_os.ps1 -Scope AllUsers
```

### Check Integration Status
```powershell
.\scripts\integrate_os.ps1 -Status
```

### Cleanly Uninstall Context Menus
```powershell
.\scripts\integrate_os.ps1 -Uninstall
```

---

## 6. Architecture & Future Roadmap

### Current Architecture
- **Dual Registration**:
  1. **Registry Shell Verbs**: High-performance, instant Windows Explorer integration via `HKCU:\Software\Classes` / `HKLM:\Software\Classes`.
  2. **COM In-Proc Server (`7-zip.dll`)**: Implements `IContextMenu`, `IShellExtInit`, and Windows 11 `IExplorerCommand` interfaces registered via `regsvr32.exe`.

### Future Evolution — Unified Archive Manager
- **Windows 11 Modern Context Menu**: Integration with modern Windows 11 AppX/sparse package extension model.
- **Tabbed Explorer GUI**: Enhanced 7-Zip File Manager interface with multi-tab browsing and dark mode.
- **Virtual Cloud & Drive Mounting**: Real-time read-only drive letter mounting for ISO, VHD, and large 7z archives.
