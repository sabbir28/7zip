# Changelog

All notable changes to the 7-Zip project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [26.05] - 2026-10-21

### Changed
- Improved code for unpacking `Z` archives (LZW) and Mach-O binary files.

### Fixed
- Fixed internal edge-case bugs and vulnerability mitigations in archive parsing.

---

## [26.04] - 2026-10-05

### Fixed
- Multiple bug fixes and stability improvements across standard archive extraction routines.

---

## [26.03] - 2026-09-03

### Added
- Improved support for Joliet ISO filesystem images and Compound document archives.

### Security
- **CVE-2026-58052**: Fixed issue where 7-Zip failed to preserve the Mark-of-the-Web (Zone.Identifier) when extracting crafted archives.

---

## [26.02] - 2026-06-25

### Security
- **CVE-2026-14266**: Resolved XZ decompression heap-based buffer overflow vulnerability.
- General safety hardening against malformed compressed input streams.

---

## [26.01] - 2026-04-27

### Added
- **Huge Pages Support**: Linux version of 7-Zip can now utilize 2 MB transparent huge pages, resulting in ~10% compression speedup for 7z / xz / LZMA / LZMA2 operations.
- **New Path Modes Switch `-spo[d|c|r]`**:
  - `-spod`: Direct output directory mode (Posix/Linux/macOS) without replacing asterisk wildcard.
  - `-spoc`: Concatenates output path with archive name into the final destination directory.
  - `-spor`: Replaces wildcard `*` in `-o{dir}` path with archive name (default).

### Security
- Fixed multiple memory safety vulnerabilities identified in handlers:
  - **CVE-2026-48092**: Heap memory disclosure via SquashFS fragment offset integer overflow (32-bit).
  - **CVE-2026-48095**: Heap buffer overflow in NTFS filesystem archive handler.
  - **CVE-2026-48101**: Uninitialized memory disclosure vulnerability in UEFI archive handler.
  - **CVE-2026-48102**: Heap out-of-bounds read in UDF archive handler.
  - **CVE-2026-48103**: Heap out-of-bounds read in WIM archive handler.
  - **CVE-2026-48104**: Uninitialized heap read in SquashFS archive handler.
  - **CVE-2026-48111**: Out-of-bounds read vulnerability in UEFI archive handler.
  - **CVE-2026-48112**: Heap out-of-bounds read in Ar archive handler.

---

## [26.00] - 2026-02-12

### Added
- High-core thread scalability: 7-Zip File Manager and benchmark engine improved to seamlessly support systems with >64 CPU logical cores.
- File Manager list sorting improvements: secondary sorting key automatically defaults to filename.

### Changed
- Refined archive handling for ZIP, CPIO, RAR, UDF, QCOW, and Compound formats.

### Fixed
- Fixed bug where TAR archives containing sparse files could not be correctly unpacked.

---

## [25.01] - 2025-08-03

### Added
- ARM64 hardware-accelerated CRC-32 and AES instructions optimization.
- Improved decompression speed for Brotli and Zstandard streams.

---

## [24.09] - 2024-11-29

### Added
- Enhanced extraction performance for multi-volume 7z archives.
- Improved memory management during extreme dictionary (1GB+) LZMA2 compression.
