# 7-Zip Development Roadmap

This document outlines architectural targets, modern development priorities, and planned improvements for future releases of 7-Zip.

---

## Strategic Goals

1. **Modern Build System Integration**
   - Provide first-class CMake integration alongside the legacy nmake and gcc makefiles.
   - Simplify cross-compilation for embedded platforms, Linux distributions, macOS (Apple Silicon), and Windows ARM64.
   - Enable unified Ninja build orchestration for rapid iterative development.

2. **Performance & Hardware Acceleration**
   - Expand AVX-512 and ARM64 NEON vectorized implementations for LZMA match finding and Adler32/CRC64 calculation.
   - Optimize multi-threaded memory allocation pipelines for high-core processors (>64 logical cores).
   - Leverage OS-level direct I/O and asynchronous buffer streaming to saturate NVMe PCIe 5.0 storage speeds.

3. **Security Hardening & Fuzzing**
   - Integrate continuous OSS-Fuzz workflows for all parser modules (SquashFS, UDF, WIM, ISO, TAR, ZIP, RAR).
   - Harden legacy format decoders with explicit buffer boundary assertions and sanitizers (AddressSanitizer, UndefinedBehaviorSanitizer).

4. **Developer Experience & Tooling**
   - Modernize CLI options with unified long options (e.g. `--output-dir`, `--threads`, `--format`).
   - Provide official GitHub Actions automated multi-platform release artifacts.
   - Comprehensive API and architecture documentation for embedding LZMA and 7z handlers into third-party applications.

---

## Version Milestones

### Phase 1 — v26.0x Maintenance & Infrastructure (Current)
- [x] High-performance CLI standalone executable (`7zz`) supporting all formats.
- [x] Huge pages memory optimization on Linux (2MB pages).
- [x] Automated PowerShell build and packaging scripts.
- [x] GitHub CI/CD workflows and automated release generation.
- [x] Comprehensive documentation hub (`docs/ARCHITECTURE.md`, `docs/BUILDING.md`, `docs/CLI_REFERENCE.md`).

### Phase 2 — v26.1x Modernization
- [ ] Root-level standard CMake build configuration.
- [ ] Automated continuous fuzz testing harness (`tests/fuzz`).
- [ ] Native VS Code and Visual Studio 2022 project integration.
- [ ] Pre-commit validation scripts and sanitizers.

### Phase 3 — v27.0 Architecture Evolution
- [ ] Modular C/C++ public shared library interface (`lib7z`).
- [ ] Async stream API with non-blocking progress notification callbacks.
- [ ] Modernized dark-mode support for 7-Zip File Manager on Windows 11.
