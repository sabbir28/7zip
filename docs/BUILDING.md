# Building 7-Zip from Source

This guide covers building 7-Zip binaries on Windows, Linux, and macOS.

---

## 1. Prerequisites

### Windows
- **Operating System**: Windows 10/11 or Windows Server (x64 / x86 / ARM64).
- **Compiler**: Microsoft Visual C++ (MSVC) from Visual Studio 2022 / 2019 or Build Tools for Visual Studio.
- **Shell**: PowerShell 5.1+ or PowerShell 7 Core.

### Linux / macOS
- **Compiler**: GCC 10+ or Clang / LLVM 12+.
- **Build Utilities**: GNU Make (`make`).

---

## 2. Windows Build

### Method A: One-Click PowerShell Script (Recommended)

The automated script automatically discovers MSVC tools and builds the specified target:

```powershell
# 1. Build unified standalone 7zz CLI (all archive formats)
.\scripts\build.ps1 -Target 7zz -Platform x64

# 2. Build lightweight 7za CLI (7z/zip/cab/gzip/bzip2/tar)
.\scripts\build.ps1 -Target 7za -Platform x64

# 3. Build full suite (7zz, 7za, 7z.dll, 7z.exe, 7zFM.exe)
.\scripts\build.ps1 -Target all -Platform x64

# 4. Clean and rebuild
.\scripts\build.ps1 -Target 7zz -Platform x64 -Clean
```

All compiled binaries are automatically deployed to `bin\<Platform>\` (e.g. `bin\x64\7zz.exe`).

### Method B: Manual MSVC Command Prompt

Open a Developer Command Prompt for Visual Studio (`x64 Native Tools Command Prompt`), navigate to the desired bundle directory, and run `nmake`:

```cmd
# Navigate to bundle directory
cd CPP\7zip\Bundles\Alone2

# Compile 7zz.exe
nmake

# Output binary is produced at:
x64\7zz.exe
```

---

## 3. Linux & macOS Build

To build the standalone `7zz` executable on POSIX systems:

```bash
cd CPP/7zip/Bundles/Alone2

# Build with GCC
make -f ../../cmpl_gcc.mak

# Or build with Clang / Apple Silicon
make -f ../../cmpl_clang.mak

# Output executable:
./b/g/7zz  # or ./b/c/7zz
```

---

## 4. Running Automated Tests

Run the built-in test suite to verify binary integrity, compression, encryption, and benchmark performance:

```powershell
.\scripts\test.ps1 -ExePath "bin\x64\7zz.exe"
```

---

## 5. Creating Release Distribution Packages

Package the compiled binaries, documentation, and SHA256 checksums into distribution ZIP archives:

```powershell
.\scripts\package.ps1 -Version "26.05" -Platform x64
```

The resulting package will be stored in `dist/` (e.g. `dist\7zip-26.05-windows-x64.zip`).
