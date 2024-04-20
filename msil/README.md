# Patched MSIL/managed code DLLs

This folder contains patches for managed code DLLs to redirect or remove references to Win32 APIs that do not exist on Windows 95. They are applied to the MSIL that can be generated using `ildisasm` (in the `bin` folder) and reassembled with `ilasm` (in `bin/dotnetfx20/URTInstallPath`). For ease of use, a `patch.bat` script is provided which should automate this process.

.NET appears to use a hashing/signing system that will prevent these DLLs from getting installed into the Global Assembly Cache (GAC) by any normal means. Instead, the installer installs the original DLLs into the GAC and then clobbers them with these patched DLLs at the end. The hash/signing check is never done again so this ends up working, even though it is a hacky solution. There may be a better one I'm not aware of.
