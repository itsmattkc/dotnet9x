# Binary/unmanaged DLL patches

These are `bdiff` patches that the installer applies to .NET's machine code DLLs (e.g. `mscoree.dll`, `mscorwks.dll`, `mscorjit.dll`, etc.) after they're installed on the user's computer.

For the most part, the patches just redirect imports from system DLLs (e.g. `KERNEL32.DLL`) to our wrappers (e.g. `CORKEL32.DLL`), except in the case of `mscorwks.dll` which also requires a patch to disable SSE2 since those instructions do not work on Windows 95 (even if the CPU supports them).
