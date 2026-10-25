# Security Policy & Vulnerability Reporting

The 7-Zip project takes security, memory safety, and archive parsing integrity very seriously.

Because 7-Zip is responsible for decompressing untrusted inputs from the internet across dozens of complex, historical, and deeply nested container formats, extensive defensive programming and fuzzing practices are applied.

---

## Supported Versions

Only the latest release versions receive security patches and backported updates:

| Version | Supported          |
| ------- | ------------------ |
| 26.05+  | :white_check_mark: |
| 26.00+  | :white_check_mark: |
| < 26.00 | :x:                |

---

## Reporting a Security Vulnerability

If you discover a potential security vulnerability (e.g. out-of-bounds read/write, heap overflow, directory traversal, code execution via crafted archive), please do **NOT** open a public issue.

Instead, please report it privately:
1. Provide a detailed description of the flaw, including:
   - Archive container format and compression method involved.
   - Exact 7-Zip version, compiler flags, and target architecture.
   - Proof of Concept (PoC) archive file or minimal reproduction generator.
   - Crash dump or AddressSanitizer (ASan) / Valgrind report.
2. Submit your report directly via the GitHub Security Advisory tab or email the project maintainers.
3. Allow reasonable coordinated disclosure time (typically up to 90 days) for a patch to be reviewed, verified, and released.

---

## Defensive Engineering & Mitigation Flags

Official release binaries of 7-Zip are compiled with industry-standard exploit mitigation mechanisms:

- **Data Execution Prevention (DEP / NX)**: Prohibits code execution from stack/heap memory pages.
- **Address Space Layout Randomization (ASLR / High-Entropy VA)**: Randomizes memory offsets for executables and DLLs.
- **SafeSEH / Control Flow Guard (CFG)**: Enforces indirect call integrity.
- **Mark of the Web (Zone.Identifier)**: Preserved during archive extraction to ensure operating system security prompts remain intact.
- **Directory Traversal Mitigation (Zip Slip)**: Canonicalizes relative paths and strips leading slashes or `..` traversals during extraction unless explicitly authorized.

---

## Vulnerability Disclosure History

Recent security advisories addressed in 7-Zip 26.x:

- **CVE-2026-58052**: Mark-of-the-Web preservation vulnerability during crafted archive extraction (Resolved in 26.03).
- **CVE-2026-14266**: XZ decompression heap-based buffer overflow (Resolved in 26.02).
- **CVE-2026-48092**: SquashFS fragment offset integer overflow (Resolved in 26.01).
- **CVE-2026-48095**: NTFS filesystem archive handler heap buffer overflow (Resolved in 26.01).
- **CVE-2026-48101 / 48104**: UEFI and SquashFS uninitialized memory disclosures (Resolved in 26.01).
