# .NET Framework 2.0 for Windows 95

## Introduction

This is a **work-in-progress** project to backport .NET Framework 2.0 to Windows 95.

Officially, .NET has never been available on Windows 95. The earliest versions supported NT 4.0 and 98SE, but no earlier. This has meant Windows 95 has been deprived of applications written in C#. This project aims to change that, backporting .NET and several applications written in it in the process.

This project backports .NET Framework 2.0 specifically since it's the latest version to support 9x at all and is still a supported build target in the latest Visual Studio to this day.

## Installation

.NET Framework 2.0 requires the following to be installed:

- **Windows 95 B (OSR 2) or newer.** Currently older versions will not work, however I am investigating ways to get around this requirement.
- **Internet Explorer 5.01.** The installer is packaged in this repository at `bin/msie501`. One day I plan to make it an automatic part of the installation process, however for the time being you'll have to run it manually.
- **Microsoft USB Supplement.** The installer is packaged in this repository at `bin/usbsupp` or may be on your Windows 95 install disc at `other/updates/usb`. This is why 95 B is necessary, the USB supplement makes patches to `VMM32.VXD` that allow .NET to work, and it isn't available on RTM/A. I am currently investigating why this is necessary and whether it can be patched out.

Once those are installed, simply download `dotnet95.exe` from the Releases tab and install! After that, applications written for .NET Framework 2.0 should run.

## Known Issues

This is a work-in-progress and it is known that .NET still makes some calls to missing system functions that need to be patched or reimplemented. If you run into an unexpected exception or error message, feel free to make a thread in the Issues tab.
