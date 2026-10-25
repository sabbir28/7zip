<div align="center">

# 📦 7-Zip

**High-performance, open-source file archiver with ultra-high compression ratios and broad multi-format compatibility.**

[![CI - Build & Test Matrix](https://github.com/sabbir28/7zip/actions/workflows/ci.yml/badge.svg)](https://github.com/sabbir28/7zip/actions/workflows/ci.yml)
[![Publish Official Release](https://github.com/sabbir28/7zip/actions/workflows/release.yml/badge.svg)](https://github.com/sabbir28/7zip/actions/workflows/release.yml)
[![Latest Release](https://img.shields.io/badge/release-v26.05-blue.svg)](CHANGELOG.md)
[![License: GNU LGPL 2.1](https://img.shields.io/badge/License-LGPL_v2.1-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)](docs/BUILDING.md)
[![Standards](https://img.shields.io/badge/standard-C11%20%7C%20C%2B%2B17-blueviolet.svg)](CMakeLists.txt)

[Official Website](https://7-zip.org) • [Documentation](docs/ARCHITECTURE.md) • [Build Guide](docs/BUILDING.md) • [CLI Manual](docs/CLI_REFERENCE.md) • [OS Integration](docs/OS_INTEGRATION.md) • [Changelog](CHANGELOG.md)

</div>

---

## 🚀 Overview

**7-Zip** is a world-renowned, open-source file compression utility recognized for delivering the highest data compression ratios through its signature **LZMA** and **LZMA2** algorithms. 7-Zip provides a powerful standalone command-line interface (`7zz`), a lightweight CLI (`7za`), a Windows Explorer shell extension, and the classic dual-pane 7-Zip File Manager (`7zFM`).

### Key Highlights
- **Exceptional Compression Ratio**: LZMA/LZMA2 solid compression achieves 30–70% better compression than standard ZIP (Deflate).
- **Format Versatility**: Packs and unpacks 7z, XZ, BZIP2, GZIP, TAR, ZIP, and WIM. Unpacks over 40 container formats including RAR, ISO, VHD, VMDK, SquashFS, UEFI, DMG, and NTFS images.
- **Hardware Acceleration**: Optimized vector assembly routines (AES-NI, AVX2, ARM64 NEON) for AES encryption, SHA hashing, and CRC calculations.
- **High-Core Thread Scalability**: Seamless multi-threaded compression scaling efficiently across systems with 64+ CPU hardware threads.
- **Enterprise-Grade Cryptography**: Strong **AES-256** encryption in CBC mode for data and archive headers (file names and metadata).
- **Platform Agnostic**: Native support for Windows (x64, x86, ARM64), Linux, and macOS.

---

## 🗂️ Repository Structure

This repository is organized into a clean, modular hierarchy conforming to professional C/C++ development standards:

```
7zip/
├── .github/                 # Automated CI/CD workflows and community issue templates
│   ├── workflows/           # GitHub Actions (ci.yml, release.yml)
│   └── ISSUE_TEMPLATE/      # Structured issue and feature request templates
├── Asm/                     # Hand-crafted assembly kernels (x86, x64, ARM)
├── C/                       # Core algorithms (LZMA/LZMA2, AES, SHA, CRC, Alloc, Threads)
├── CPP/                     # C++ Object-Oriented Component Architecture
│   ├── 7zip/
│   │   ├── Archive/         # Format parsers (7z, Zip, Rar, Tar, Iso, Wim, etc.)
│   │   ├── Bundles/         # Target deliverables (Alone2=7zz, Alone=7za, Fm=7zFM, Format7zF=7z.dll)
│   │   ├── Common/          # Core interfaces (ICoder.h, IStream.h, CWrappers)
│   │   ├── Compress/        # Encoders, decoders, and branch filters (BCJ, BCJ2)
│   │   ├── Crypto/          # Cipher implementations (7zAes, RarAes, WzAes)
│   │   └── UI/              # Console CLI engines and Win32 GUI managers
│   ├── Common/              # Cross-platform foundation classes (String, Vector, Stream)
│   └── Windows/             # Win32 subsystem wrappers (FileIO, Threading, Registry)
├── DOC/                     # Upstream technical notes and specification files
├── docs/                    # Professional documentation hub
│   ├── ARCHITECTURE.md      # Detailed system architecture and interface model
│   ├── BUILDING.md          # Multi-platform build manual (MSVC, GCC, Clang, CMake)
│   ├── CLI_REFERENCE.md     # Comprehensive command and switch reference
│   └── FORMATS.md           # Supported containers, codecs, and ciphers matrix
├── scripts/                 # Automated developer tools
│   ├── build.ps1            # 1-Click PowerShell MSVC build orchestrator
│   ├── package.ps1          # Release distribution zip packager with SHA256 checksums
│   ├── test.ps1             # Functional test suite (compression, encryption, benchmark)
│   └── clean.ps1            # Repository deep cleaning utility
├── CMakeLists.txt           # Modern CMake build configuration
├── CHANGELOG.md             # Semantic version history (up to v26.05)
├── CONTRIBUTING.md          # Contribution guidelines and workflow
├── CODE_OF_CONDUCT.md       # Contributor Covenant Code of Conduct
├── LICENSE                  # Comprehensive project license (GNU LGPL v2.1+)
├── SECURITY.md              # Security policy, fuzzing practices, and CVE tracker
└── ROADMAP.md               # Vision, milestones, and development roadmap
```

---

## ⚡ Quick Start

### 1. Building from Source

#### Automated 1-Click Build (PowerShell)
To compile the standalone unified `7zz.exe` binary:
```powershell
.\scripts\build.ps1 -Target 7zz -Platform x64
```

To build the full Windows GUI Suite (`7zFM.exe`, `7zG.exe`, `7z.dll`, `7z.sfx`):
```powershell
.\scripts\build.ps1 -Target gui -Platform x64
```

To build all deliverables (CLI, GUI, DLLs, and SFX modules):
```powershell
.\scripts\build.ps1 -Target all -Platform x64
```
Compiled binaries are output to `bin\x64\`:
- `7zFM.exe` (7-Zip File Manager GUI)
- `7zG.exe` (7-Zip Compression/Extraction GUI Dialogs)
- `7z.dll` (Full Archive Engine Library)
- `7zz.exe` (Unified Multi-Format CLI)
- `7z.sfx` / `7zCon.sfx` (Self-Extracting Modules)

#### Modern CMake Build
```powershell
cmake -B build -S .
cmake --build build --config Release
```

#### POSIX (Linux / macOS)
```bash
cd CPP/7zip/Bundles/Alone2
make -f ../../cmpl_gcc.mak    # Or make -f ../../cmpl_clang.mak
```

---

### 2. 🎁 Converting ZIP / Folders into Self-Extracting `.EXE` Files

Convert any `.zip`, `.7z`, or directory into a standalone `.exe` that recipients can double-click to unzip without needing 7-Zip, WinRAR, or any software installed:

```powershell
# Convert any .zip into an auto-extracting .exe
.\scripts\zip_to_exe.ps1 -InputPath "C:\MyFiles\archive.zip"

# Convert with custom extraction window title & prompt
.\scripts\zip_to_exe.ps1 -InputPath "release.zip" -OutputPath "MyAppSetup.exe" -Title "Setup Wizard" -BeginPrompt "Extract files to destination?"

# Convert a folder directly into an .exe
.\scripts\zip_to_exe.ps1 -InputPath "C:\MyProject\dist" -OutputPath "ProjectPackage.exe"
```
**End-User Experience**:
- Double-clicking `archive.exe` opens a clean native Windows GUI dialog with progress indicator and `Extract` button.
- Command-line silent extraction: `archive.exe -o"C:\TargetFolder" -y`

---

### 3. 🪟 Windows OS Integration & Right-Click Context Menu

Integrate 7-Zip directly into Windows Explorer to extract and inspect `.exe`, `.zip`, `.7z`, and other containers from the right-click menu:

```powershell
# Install context menu actions (Current User - No Administrator prompt required)
.\scripts\integrate_os.ps1

# Check current integration status
.\scripts\integrate_os.ps1 -Status

# Uninstall context menus cleanly
.\scripts\integrate_os.ps1 -Uninstall
```

**Enabled Shell Features**:
- **Right-click any archive or `.exe` installer**:
  - `Extract with 7-Zip...` (launches GUI extraction dialog with folder picker)
  - `Inspect in 7-Zip Archive Manager` (browse inside installers or archives safely)
  - `7-Zip` cascading sub-menu (*Extract Here*, *Extract to \<Name>\\*, *Test archive*, *Compress*, *Convert to EXE*)
- **Right-click any folder**:
  - `7-Zip` -> *Add to archive...*, *Add to \<Folder>.7z*, *Add to \<Folder>.zip*, *Package as Self-Extracting (.EXE)*

For full technical specifications, see the [OS Integration Guide](docs/OS_INTEGRATION.md).

---

### 4. Running Automated Tests

Run the integrated functional test suite to validate archive generation, extraction integrity, AES-256 cryptography, and CPU benchmarks:
```powershell
.\scripts\test.ps1
```

---

### 4. Packaging Releases

To package the built binaries and documentation into a release ZIP with SHA256 checksums:
```powershell
.\scripts\package.ps1 -Version "26.05" -Platform x64
```
Distribution archives will be generated in `dist/`.

---

## 💻 Command Line Quick Reference

```powershell
# Create an Ultra-compressed 7z archive with multi-threading
7zz a -t7z -mx=9 -mmt=on backup.7z "C:\MyFiles\*"

# Create an AES-256 encrypted archive with hidden file names
7zz a -t7z -p"SecretPass" -mhe=on vault.7z "C:\Confidential\*"

# Extract archive preserving directory hierarchy
7zz x backup.7z -o"C:\Restored" -y

# Test archive structural and checksum integrity
7zz t backup.7z

# Calculate cryptographic hashes (SHA-256, CRC-32, etc.)
7zz h "installer.exe"

# Run internal CPU performance benchmark
7zz b -mmt=4
```
For full switch documentation, see the [CLI Reference Manual](docs/CLI_REFERENCE.md).

---

## 📊 Performance Benchmarks

*Benchmarked on Intel Core i3 / 4 logical threads with 7-Zip v26.05 (x64):*

| Operation | Method / Dictionary | Speed | Rating |
| --------- | ------------------- | ----- | ------ |
| **Compression** | LZMA2 (Dict: 32MB) | **5,184 KiB/s** | **5,433 MIPS** |
| **Decompression** | LZMA2 (Dict: 32MB) | **66,041 KiB/s** | **5,753 MIPS** |

---

## 🔒 Security & Vulnerability Reporting

Please review our [Security Policy](SECURITY.md) for details on:
- Exploit mitigations (DEP, ASLR, CFG, Mark-of-the-Web preservation)
- Private vulnerability disclosure instructions
- Historical CVE mitigations (CVE-2026-58052, CVE-2026-14266, CVE-2026-48092)

---

## 📜 License

7-Zip source code is distributed under the **GNU Lesser General Public License (LGPL) version 2.1 or later**, with specific subcomponents licensed under the BSD 3-Clause and unRAR license terms.

For details, refer to the [LICENSE](LICENSE) file and [DOC/License.txt](DOC/License.txt).
