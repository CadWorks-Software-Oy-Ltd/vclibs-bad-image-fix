# Elevate to admin if not already
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process -FilePath PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Starting Command Prompt as TrustedInstaller..." -ForegroundColor Cyan

# Create a temporary directory for our files
$tempDir = "$env:TEMP\TI_Launcher"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# PsExec download URL and path
$psExecUrl = "https://download.sysinternals.com/files/PSTools.zip"
$psToolsZip = "$tempDir\PSTools.zip"
$psExecPath = "$tempDir\PsExec.exe"

# Check if PsExec is already downloaded, if not download it
if (-not (Test-Path $psExecPath)) {
    Write-Host "Downloading PsExec tool..." -ForegroundColor Yellow
    
    try {
        # Create a WebClient object
        $webClient = New-Object System.Net.WebClient
        
        # Download the file
        $webClient.DownloadFile($psExecUrl, $psToolsZip)
        
        # Extract the zip file
        Write-Host "Extracting PsTools..." -ForegroundColor Yellow
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($psToolsZip, $tempDir)
        
        # Clean up the zip file
        Remove-Item $psToolsZip -Force
    }
    catch {
        Write-Host "Failed to download PsExec: $_" -ForegroundColor Red
        Write-Host "Please download PsExec manually from: https://docs.microsoft.com/en-us/sysinternals/downloads/psexec" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
}

# Create a batch file that will be executed by the TrustedInstaller
$batchPath = "$tempDir\TICmd.bat"
@"
@echo off
title Command Prompt (TrustedInstaller)
color 4F
echo You now have TrustedInstaller privileges. Use with caution!
echo.
echo Type 'exit' to close this window when finished.
echo.
echo.
echo *** INSTRUCTIONS ON HOW TO FIX THE VCLibs UWPDesktop 14.0.33728.0 x64 “Bad Image” Error ***
echo *** (https://www.winhelponline.com/blog/vclibs-uwpdesktop-33728-x64-bad-image/) ***
echo.
echo 1. Rename the problematic folder with these commands:
echo ** cd /d C:\Program Files\WindowsApps\
echo ** ren Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe VCLibs140UWP.OLD
echo.
echo 2. Restart Windows and run this program again!
echo.
echo 3. Create a new folder to C root called Appx and download the working package
echo ** mkdir C:\Appx
echo ** Download the new package file from https://www.winhelponline.com/apps/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx
echo ** Save file to the newly created folder
echo.
echo ** These commands may or may not work:
echo **** curl -o "C:\Appx\Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.appx" https://www.winhelponline.com/apps/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx
echo **** Invoke-WebRequest -OutFile "C:\Appx\Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.appx" -Uri https://www.winhelponline.com/apps/Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx
echo.
echo 5. Open PowerShell as admin and run Add-AppxPackage
echo ** powershell Start-Process powershell -Verb RunAs
echo ** Add-AppxPackage "C:\Appx\Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.appx"
echo.
echo 6. Restart Windows!
echo *********************
cmd /k
"@ | Out-File -FilePath $batchPath -Encoding ASCII

# Start TrustedInstaller service if not already running
$tiService = Get-Service -Name TrustedInstaller -ErrorAction SilentlyContinue
if ($tiService -and $tiService.Status -ne 'Running') {
    Write-Host "Starting TrustedInstaller service..." -ForegroundColor Yellow
    Start-Service -Name TrustedInstaller
    Start-Sleep -Seconds 2
}

# Run command as TrustedInstaller
Write-Host "Launching Command Prompt as TrustedInstaller using PsExec..." -ForegroundColor Green

try {
    # Accept the EULA with -accepteula
    # -s runs the command as System account
    # -i makes it interactive
    # Then we specify the path to cmd.exe and the batch file
    Start-Process -FilePath $psExecPath -ArgumentList "-accepteula -s -i $env:SystemRoot\System32\cmd.exe /c `"$batchPath`"" -NoNewWindow
    Write-Host "PsExec launched successfully." -ForegroundColor Green
    Write-Host "If successful, you should see a Command Prompt window with System privileges." -ForegroundColor Cyan
    Write-Host "Note: This is running as SYSTEM, which has similar privileges to TrustedInstaller for most operations." -ForegroundColor Yellow
}
catch {
    Write-Host "Failed to run PsExec: $_" -ForegroundColor Red
}

Write-Host "`nPowerShell window will remain open." -ForegroundColor Yellow
Write-Host "Press Enter to exit when you're finished with the elevated Command Prompt." -ForegroundColor Yellow
Read-Host