# .NET Framework 2.0 - 3.5 for Windows 9x

<p align="center">
  <img src="https://raw.githubusercontent.com/itsmattkc/dotnet95/master/img/screenshot.png" />
</p>

## Introduction

This project is a work-in-progress backport of .NET Framework 2.0 - 3.5 to Windows 9x. Currently 2.0 is believed to be largely functional while work on 3.5 has just begun.

Officially, .NET Framework 3.5 never supported anything below XP, and .NET in general never supported 95. This project changes that, backporting CLR 2.0 to 95 and Framework 3.5 to 9x.


## Installation

### Windows 95

.NET CLR 2.0 requires the following to be installed:

- **Windows 95 B (OSR 2) or newer.** Currently older versions will not work, however I am investigating ways to get around this requirement (see below).
- **Internet Explorer 5.01.** The installer is packaged in this repository at `bin/msie501`. One day I plan to make it an automatic part of the installation process, however for the time being you'll have to run it manually.
- **Microsoft USB Supplement.** The installer is packaged in this repository at `bin/usbsupp` or may be on your Windows 95 install disc at `other/updates/usb`. This is why 95 B is necessary, the USB supplement makes patches to `VMM32.VXD` that allow .NET to work, and it isn't available on RTM/A. I am currently investigating why this is necessary and whether it can be patched out.
- **Optional:**
  - To allow sockets, install the Microsoft [Windows Socket 2 Update](https://web.archive.org/web/20040320073520/http://download.microsoft.com/download/0/e/0/0e05231b-6bd1-4def-a216-c656fbd22b4e/W95ws2setup.exe).

Once those are installed, simply download `dotnet9x.exe` from the Releases tab and install! After that, applications written for .NET Framework 2.0 - 3.5 should run.

## Known Issues

In my testing, this appears to largely work now, but .NET may still make some calls to missing system functions that need to be patched or reimplemented. If you run into an unexpected exception or error message, feel free to make a thread in the Issues tab.
