#Variables
$os_user="alert"
$os_password= "123"
$os_securePassword = ConvertTo-SecureString "$os_password" -AsPlainText -Force
$filesrv_user = 'distrib'
$filesrv_pass = 'parol_Zaq'
$ubuntu_address = '192.168.10.51'

#Modules
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name Nuget -Force
Install-Module -Name PowershellGet -Force
Install-Module -Name NTFSSecurity -Force
Import-Module -Name PowershellGet -Force
Import-Module -Name NTFSSecurity -Force


#Adding new user

New-LocalUser $os_user -Password $os_securePassword -FullName "$os_user" -Description "alert for app" -WarningAction SilentlyContinue
Add-LocalGroupMember -Group "Администраторы" -Member $os_user -WarningAction SilentlyContinue


#1)Create folder for alert1300
New-Item C:\alert1300 -ItemType directory -ErrorAction SilentlyContinue

#2)Download the archive from file server



$pair = "$($filesrv_user):$($filesrv_pass)"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

#CHANGE THE NAME OF DOWNLOADED ARCHIVE
Invoke-WebRequest -Uri 'https://files.bit-tech.io/1/bit-alert-client-win-x64-v1.3.0.0.zip' -Headers $Headers -UseBasicParsing -OutFile C:\alert1300\bit-alert-client-win-x64-v1.3.0.0.zip 

#3)Expand the archive with alert 1300

Expand-Archive -LiteralPath C:\alert1300\bit-alert-client-win-x64-v1.3.0.0.zip -DestinationPath C:\alert1300

#4)Copy and edit config json file from C:\tmp\alert1300\ to C:\ProgramData\bit-settings\bit-alert-client-settings.json
New-Item C:\ProgramData\bit-settings -ItemType directory -ErrorAction SilentlyContinue
Copy-Item C:\alert1300\bit-alert-client-win-x64-v1.3.0.0\win-x64\bit-alert-client-settings.json -Destination C:\ProgramData\bit-settings\bit-alert-client-settings.json

(Get-Content C:\ProgramData\bit-settings\bit-alert-client-settings.json) -replace 'http://localhost:5477/hub/visit','http://192.168.1.51:5477/hub/visit' | Set-Content C:\ProgramData\bit-settings\bit-alert-client-settings.json

#5)Launch new bit-alert

C:\alert1300\bit-alert-client-win-x64-v1.3.0.0\win-x64\bit-alert-client.exe



#6)Remove old alert from autolaunch and add the new one by using symlink
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\bit-alert-client.exe" -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Target 'C:\alert1300\bit-alert-client-win-x64-v1.3.0.0\win-x64\bit-alert-client.exe' -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\bit-alert-client.exe" -Force -ErrorAction SilentlyContinue
   

Write-Output "SERVER TO CONNECT:  $ubuntu_address"
