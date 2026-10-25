# Contributing to 7-Zip

Thank you for your interest in contributing to 7-Zip!

7-Zip is a high-performance open-source file archiver known for its high compression ratio (LZMA/LZMA2), rock-solid reliability, and broad format compatibility.

---

## Code of Conduct

Please read and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md) in all interactions within this project.

---

## How to Contribute

### 1. Reporting Bugs
- Verify that the issue has not already been reported by searching the issue tracker.
- Test against the latest release (v26.05+).
- Include:
  - Exact 7-Zip build/version and architecture (x64, x86, ARM64).
  - Operating system and kernel/build version.
  - Command line invocation or GUI actions taken.
  - Reproducible sample archive or synthetic test case (ensure no proprietary or sensitive data).
  - Stack trace or crash dump if applicable.

### 2. Proposing New Features or Format Support
- Open an Issue with the `feature_request` label.
- Clearly describe the archive format or compression algorithm specifications.
- Provide links to official standards or reference implementations (e.g. RFCs, ISO specifications).

### 3. Code Contributions & Pull Requests
- Keep changes focused and atomic.
- Respect the existing coding style:
  - 2-space or tab consistency matching target module.
  - Maintain portable C/C++ practices across MSVC, GCC, and Clang.
  - Preserve COM-like `IInStream`, `ISequentialOutStream`, and `ICompressCoder` interface rules.
  - Ensure fast path SIMD optimizations (AVX2, AVX-512, NEON) retain fallback scalar implementations.
- Verify your changes build cleanly without warnings under `/Wall /WX` (MSVC) or `-Wall -Wextra` (GCC/Clang).
- Run benchmarks (`7zz b`) to ensure no regression in throughput or memory footprint.

---

## Building Locally

### Quick Build with PowerShell
```powershell
# Build standalone 7zz.exe (all formats CLI)
.\scripts\build.ps1 -Target 7zz -Platform x64

# Build all core binaries (7zz, 7za, 7zFM, 7z.dll)
.\scripts\build.ps1 -Target all -Platform x64
```

### Manual MSVC Build
```cmd
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
cd CPP\7zip\Bundles\Alone2
nmake
```

---

## License Attribution
By submitting a Pull Request, you agree that your contributions will be licensed under the project's [LICENSE](LICENSE) (GNU LGPL v2.1+ / BSD 3-Clause).
