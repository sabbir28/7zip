# Supported Container Formats & Compression Algorithms

7-Zip provides comprehensive support for a vast array of container formats, compression methods, and cryptographic ciphers.

---

## 1. Supported Formats Matrix

### Full Packing & Unpacking Support
These formats can be both created (packed) and extracted (unpacked):

| Format | Extension | Default Algorithm | Encryption | Notes |
| ------ | --------- | ----------------- | ---------- | ----- |
| **7z** | `.7z` | LZMA / LZMA2 | AES-256 (Headers + Data) | Flagship format with highest compression ratio, 64-bit file sizes, and Unicode. |
| **XZ** | `.xz` | LZMA2 | SHA-256 Checksums | Modern POSIX compression format. |
| **BZIP2** | `.bz2`, `.tbz2` | BWT (Burrows-Wheeler) | - | UNIX streaming compression. |
| **GZIP** | `.gz`, `.tgz` | Deflate | - | Standard web and POSIX compression. |
| **TAR** | `.tar` | Uncompressed | - | Standard POSIX archive container. |
| **ZIP** | `.zip` | Deflate / LZMA | ZipCrypto / AES-256 | Ubiquitous archive format. |
| **WIM** | `.wim` | LZX / XPRESS | - | Windows Imaging Format container. |

---

### Unpacking & Extraction Only Support
7-Zip can inspect, browse, test, and extract from the following formats:

- **Disk Images & Virtual Machines**:
  - `ISO`, `UDF`, `VHD`, `VHDX`, `VMDK`, `VDI`, `QCOW`, `QCOW2`, `DMG`, `HFS`, `APFS`, `FAT`, `NTFS`, `EXT2/3/4`, `GPT`, `MBR`
- **Installer & Package Formats**:
  - `MSI`, `MSP`, `CAB`, `RPM`, `DEB`, `CPIO`, `AR`, `NSIS`, `CHM`
- **Embedded & Firmware Containers**:
  - `SquashFS`, `CramFS`, `UEFI`, `PE` (Portable Executable resources), `ELF`, `Mach-O`
- **Proprietary & Legacy Archives**:
  - `RAR` (v1.5 to v5.x), `ARJ`, `LZH`, `LHA`, `Z` (compress), `Zstandard` (`.zst`), `LZFSE`, `Base64`

---

## 2. Compression Algorithms

| Method ID | Algorithm | Typical Compression Ratio | RAM Usage (Encode) | RAM Usage (Decode) |
| --------- | --------- | ------------------------- | ------------------ | ------------------ |
| `LZMA` | Lempel-Ziv-Markov chain | Very High | Dict Size x 11.5 | Dict Size + 2 MB |
| `LZMA2` | Chunked LZMA with MT | Very High | Dict Size x 11.5 | Dict Size + 2 MB |
| `PPMd` | Prediction by Partial Matching | Extremely High on Text | Model Size (up to 1 GB) | Equal to Model Size |
| `BZip2` | Burrows-Wheeler Transform | High on Text | 8 MB | 4 MB |
| `Deflate` | LZ77 + Huffman | Moderate (Fast) | < 1 MB | < 1 MB |
| `Delta` | Byte Delta Filter | Special (Audio/Images) | Negligible | Negligible |
| `BCJ` / `BCJ2` | Branch Call Jump Converter | Pre-filter for x86/ARM | Negligible | Negligible |

---

## 3. Cryptographic Standards

- **AES-256 (Rijndael)**:
  - Key length: 256 bits.
  - Key derivation: PBKDF2 with SHA-256 (up to $2^{19}$ iterations for high resistance against brute-force attacks).
  - Cipher mode: CBC (Cipher Block Chaining).
  - Optional Header Encryption (`-mhe=on`) encrypts all file metadata, folder names, and sizes.
- **ZipCrypto**:
  - Traditional PKZIP stream cipher supported for legacy compatibility.
