# vclibs-bad-image-fix

A script that guides the user to fix VcLibs "Bad Image" errors in Windows 11.

> **:warning: The script elevates itself to TrustedInstaller, which can be used to create serious damage to your system. Use with caution!**

## What?

After upgrading Windows 10 to 11 or just applying updates to Windows 11 from Windows update, you might sometimes be introduced to the following error screen when trying to launch native Windows applications (Notepad, Photos etc.):

![Error message](error.png)

Error status 0xc0000020 (“STATUS_INVALID_FILE_FOR_SECTION”) means “The attributes of the specified mapping file for a section of memory cannot be read”. This means that the DLL files that are required to execute the applications are corrupted.

This script is built based on a guide provided by [WinHelpOnline](https://www.winhelponline.com/blog/vclibs-uwpdesktop-33728-x64-bad-image/).

## Usage

1. Download the script
2. Right-click on the script -> Properties
3. Click on the "Unblock" field to allow the execution and click on "Apply" -> "OK"
4. Open Powershell and execute the following command:
   - `Set-ExecutionPolicy Unrestricted`
5. Reopen Powershell and run the script
