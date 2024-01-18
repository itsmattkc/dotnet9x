# .NET Framework 2.0 for Windows 95

<p align="center">
  <img src="https://raw.githubusercontent.com/itsmattkc/dotnet95/master/img/screenshot.png" />
</p>

## Introduction

This is a **mostly complete** project to backport .NET Framework 2.0 to Windows 95.

Officially, .NET has never been available on Windows 95. The earliest versions (1.0/1.1) supported NT 4.0 and 98SE, but no earlier, meaning no C#/VB.NET/etc. app has ever been compatible with Windows 95. This project changes that, providing enough connective tissue to allow .NET (and hopefully most applications written for it) to run.

This project targets .NET Framework 2.0 since it was the newest version to support 9x and is still a supported build target in the latest Visual Studio 2022. Since .NET 3.5 uses the same version of the CLR (2.0), it may be possible to extend this further and backport all of 3.5 to 9x too, however there are no current plans to do this.

## Installation

.NET Framework 2.0 requires the following to be installed:

- **Windows 95 B (OSR 2) or newer.** Currently older versions will not work, however I am investigating ways to get around this requirement (see below).
- **Internet Explorer 5.01.** The installer is packaged in this repository at `bin/msie501`. One day I plan to make it an automatic part of the installation process, however for the time being you'll have to run it manually.
- **Microsoft USB Supplement.** The installer is packaged in this repository at `bin/usbsupp` or may be on your Windows 95 install disc at `other/updates/usb`. This is why 95 B is necessary, the USB supplement makes patches to `VMM32.VXD` that allow .NET to work, and it isn't available on RTM/A. I am currently investigating why this is necessary and whether it can be patched out.

Once those are installed, simply download `dotnet95.exe` from the Releases tab and install! After that, applications written for .NET Framework 2.0 should run.

## Known Issues

In my testing, this appears to largely work now, but .NET may still make some calls to missing system functions that need to be patched or reimplemented. If you run into an unexpected exception or error message, feel free to make a thread in the Issues tab.
