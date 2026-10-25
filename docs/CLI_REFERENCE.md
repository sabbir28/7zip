# 7-Zip Command Line Reference Manual

The unified command-line executable (`7zz`) provides high-performance archiving, testing, extracting, hashing, and benchmarking capabilities across all supported formats.

---

## 1. Syntax

```
7zz <command> [<switches>...] <archive_name> [<file_names>...] [@listfile]
```

---

## 2. Commands

| Command | Name | Description |
| ------- | ---- | ----------- |
| `a` | Add | Adds specified files and directories into an archive. |
| `x` | eXtract with Full Paths | Extracts files while restoring the entire directory tree hierarchy. |
| `e` | Extract Flat | Extracts files into the target folder flattening any directory paths. |
| `t` | Test | Verifies internal checksums and structural integrity of an archive without writing to disk. |
| `l` | List | Lists file contents, compressed/uncompressed sizes, and timestamps within an archive. |
| `d` | Delete | Deletes specified files from inside an archive. |
| `u` | Update | Updates newer files from disk into the archive. |
| `rn` | Rename | Renames files inside an existing archive without recompression. |
| `b` | Benchmark | Runs CPU compression and decompression benchmark measuring throughput and MIPS. |
| `h` | Hash | Calculates cryptographic hashes (CRC32, CRC64, SHA-256, SHA-1, BLAKE2sp, xxHash). |
| `i` | Information | Displays supported container formats, codecs, and cryptographic algorithms. |

---

## 3. Essential Switches

### Compression Configuration
- **`-mx[0-9]`**: Compression level:
  - `-mx0`: Copy (no compression)
  - `-mx1`: Fastest
  - `-mx5`: Normal (default)
  - `-mx7`: Maximum
  - `-mx9`: Ultra (highest compression ratio)
- **`-m0={method}`**: Primary compression method (`lzma`, `lzma2`, `ppmd`, `bzip2`, `deflate`, `copy`).
- **`-md={size}[k|m|g]`**: Dictionary size (e.g. `-md=64m`, `-md=512m`).
- **`-mmt[=N]`**: Sets number of CPU threads used for multi-threading (e.g. `-mmt=8` or `-mmt=on`).
- **`-ms=on|off`**: Enables or disables Solid archive block mode.

### Encryption & Security
- **`-p{password}`**: Sets password for archive encryption or decryption.
- **`-mhe=on`**: Enables header encryption (encrypts filenames in 7z archives).
- **`-sni`**: Store NT security information (ACLs).
- **`-sns`**: Store NTFS alternate data streams.

### File Selection & Recursion
- **`-r`**: Recursively search subdirectories for matching patterns.
- **`-xr!{pattern}`**: Exclude files matching wildcard pattern (e.g. `-xr!*.tmp -xr!.git`).
- **`-ir!{pattern}`**: Include files matching wildcard pattern.
- **`-o{dir}`**: Destination output directory for extraction.

### Splitting Multi-Volume Archives
- **`-v{size}[b|k|m|g]`**: Split archive into volumes of specified size (e.g. `-v100m`, `-v4g`).

---

## 4. Practical Examples

### 1. High-Ratio LZMA2 Solid Archive
```powershell
7zz a -t7z -mx=9 -mmt=on -ms=on backup.7z "C:\Data\*"
```

### 2. Encrypted Archive with Hidden Filenames
```powershell
7zz a -t7z -p"MySecretPassword" -mhe=on secure_vault.7z "C:\Confidential\*"
```

### 3. Extract Archive with Mark-of-the-Web Preservation
```powershell
7zz x release.7z -o"C:\Tools\Release" -y
```

### 4. Integrity Test Without Extraction
```powershell
7zz t large_archive.7z
```

### 5. Multi-Threaded CPU Benchmark
```powershell
7zz b -mmt=4
```
