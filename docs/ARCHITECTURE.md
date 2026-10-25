# 7-Zip System Architecture

This document provides a technical walkthrough of the architectural design, code organization, and execution flow of 7-Zip.

---

## 1. Architectural Layers

7-Zip is engineered as a highly modular, multi-tier system combining high-speed native C algorithms with an extensible C++ COM-like component model:

```
+------------------------------------------------------------------+
|                          User Interfaces                         |
|  7zFM.exe (File Manager)  |  7zG.exe (GUI)  |  7-zip.dll (Shell) |
|  7zz.exe (Unified CLI)    |  7z.exe (CLI)   |  7za.exe (Lite CLI)|
+------------------------------------------------------------------+
                                  |
+------------------------------------------------------------------+
|                   COM-like Abstraction Layer                     |
|      IInStream | IOutStream | ICoder | IProgress | IPassword     |
+------------------------------------------------------------------+
                                  |
         +------------------------+------------------------+
         |                                                 |
+--------------------------+                     +-----------------+
|     Archive Handlers     |                     | Coder & Filter  |
| (7z, Zip, Rar, Tar, Iso, |                     | (LZMA, LZMA2,   |
|  Wim, Squashfs, Vhd, etc)|                     |  PPMd, BCJ, etc)|
+--------------------------+                     +-----------------+
         |                                                 |
         +------------------------+------------------------+
                                  |
+------------------------------------------------------------------+
|                      Core C Algorithm Engine                     |
|  LZMA/LZMA2 match finders | Threads & Multiprocessing primitives |
|  Hardware SIMD (AES-NI, AVX2, NEON) | System Memory Allocation   |
+------------------------------------------------------------------+
```

---

## 2. Directory Layout & Module Responsibilities

| Path | Primary Language | Description |
| ---- | ---------------- | ----------- |
| `C/` | C | High-performance low-level compression/decompression algorithms (LZMA, LZMA2, PPMd7/8, BCJ, BCJ2, BwtSort, Huffman), cryptographic hashing (CRC32, CRC64, SHA-1, SHA-256, SHA-512, Blake2s, xxHash), CPU feature detection, and thread pooling. |
| `Asm/` | Assembly (x86/x64/ARM) | Hand-crafted vector assembly kernels for CRC32, AES, SHA, and LZMA match finding. |
| `CPP/Common/` | C++ | Platform-independent fundamental utilities: strings, dynamic buffers, vectors, XML parsing, and command line tokenization. |
| `CPP/Windows/` | C++ | Windows-specific Win32 API wrappers: file I/O, registry, system power events, security descriptors, and DLL loading. |
| `CPP/7zip/Common/` | C++ | Core interfaces (`ICoder.h`, `IStream.h`, `PropID.h`), stream adapters, and thread coordinator bridges (`CWrappers.cpp`). |
| `CPP/7zip/Archive/` | C++ | Container formats and filesystem parsers (over 40 archive formats including 7z, ZIP, TAR, RAR, ISO, VHD, PE, ELF). |
| `CPP/7zip/Compress/` | C++ | High-level encoder/decoder adapters wrapping C compression algorithms and branch filters. |
| `CPP/7zip/Crypto/` | C++ | Encryption handlers (7z AES-256, WzAES, ZipStrong, RarAES). |
| `CPP/7zip/Bundles/` | C++ / nmake | Compilation bundles for target deliverables (`Alone2` -> `7zz.exe`, `Alone` -> `7za.exe`, `Format7zF` -> `7z.dll`, `Fm` -> `7zFM.exe`). |
| `CPP/7zip/UI/` | C++ | Front-end console parsers, progress bars, benchmark routines, and Win32 GUI dialogs. |

---

## 3. The Stream & Coder Interface Model

7-Zip employs a lightweight COM-like interface standard without depending on the heavy Windows COM runtime or ATL:

- **`ISequentialInStream` / `ISequentialOutStream`**: Basic streaming read/write operations with partial transfer support.
- **`IInStream` / `IOutStream`**: Random-access streams with standard 64-bit `Seek()` mechanics.
- **`ICompressCoder`**: Unified compression/decompression interface:
  ```cpp
  STDMETHOD(Code)(ISequentialInStream *inStream,
                  ISequentialOutStream *outStream,
                  const UInt64 *inSize,
                  const UInt64 *outSize,
                  ICompressProgressInfo *progress) PURE;
  ```
- **`IInArchive` / `IOutArchive`**: Interfaces implemented by archive container parsers to query archive metadata, test signatures, and extract/update items.

---

## 4. Solid Compression & Filter Chaining

7-Zip achieves exceptional compression density via:
1. **Branch Instruction Filters (BCJ / BCJ2)**: Converts relative jump and call targets in x86/ARM executables into absolute addresses, creating repetitive patterns that compress drastically better.
2. **Solid Archive Blocks**: Multiple files are concatenated into a single contiguous stream before passing to the LZMA encoder, allowing the dictionary match finder to reference redundancy across thousands of files.
3. **Multi-threaded Block Partitioning**: LZMA2 chunks the uncompressed stream into independent blocks processed concurrently across CPU cores without destroying cross-block deduplication.
