Update windows

install chrome

wsl --install

wsl --export Ubuntu c:\Temp\UbuntuBackup.tar
wsl --unregister Ubuntu
wsl --import Ubuntu c:\Linux c:\Temp\UbuntuBackup.tar


/etc/wsl.conf
[user]
default=apham


old context menu 


HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID
new key
{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}
in there new key
InprocServer32
double default value click and set blank as key

install in microsoft store
KATE

Whatsapp

Install installers
OBS
Openjdk windows
VSCODE
Zoom
SLACK
MultiMonitorTool Nirsoft
vlc
notepadd ++
focusrite 3rd gen driver
dbeaver
voicemeeter banana
gimp

https://github.com/winfsp/sshfs-win?tab=readme-ov-file


for dell g 15 : Ethernet driver to avoid drops. deactivate killer priorituzation engine


make hyperv and wsl communicate
```
Get-NetIPInterface | select ifIndex,InterfaceAlias,AddressFamily,ConnectionState,Forwarding | Sort-Object -Property IfIndex | Format-Table

Get-NetIPInterface | `
where {$_.InterfaceAlias -eq 'vEthernet (Default Switch)'} | `
Set-NetIPInterface -Forwarding Enabled -Verbose

Get-NetIPInterface | `
where {$_.InterfaceAlias -eq 'vEthernet (std)'} | `
Set-NetIPInterface -Forwarding Enabled -Verbose

Get-NetIPInterface | `
where {$_.InterfaceAlias -eq 'vEthernet (WSL (Hyper-V firewall))'} | `
Set-NetIPInterface -Forwarding Enabled -Verbose



Get-NetIPInterface | where {$_.InterfaceAlias -eq 'vEthernet (WSL)' -or $_.InterfaceAlias -eq 'vEthernet (Default Switch)' -or $_.InterfaceAlias -eq 'vEthernet (std)'} | Set-NetIPInterface -Forwarding Enabled -Verbose

```
add windows route to route metallb inside hyperv

route -p add 192.168.199.0 mask 255.255.255.0 192.168.199.100 if 3

Set-NetConnectionProfile -InterfaceAlias "vEthernet (std)" -NetworkCategory  Private

set frewall to private

Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex 5 -NetworkCategory Private

Nat gateway

New-VMSwitch -SwitchName "std" -SwitchType Internal

netsh interface ipv4 show interface

New-NetIPAddress -InterfaceAlias "vEthernet (std)" -IPAddress 192.168.199.1 -PrefixLength 24

New-NetNat -Name stdnat -InternalIPInterfaceAddressPrefix 192.168.199.0/24

reg delete "HKEY_CLASSES_ROOT\*\shell\WSLVSCode" /f
reg delete "HKEY_CLASSES_ROOT\Directory\shell\WSLVSCode" /f
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\WSLVSCode" /f


reg add "HKEY_CLASSES_ROOT\*\shell\WSLVSCode\command" /t REG_EXPAND_SZ /d "wsl.exe --cd \"%V\" code ."
reg add "HKEY_CLASSES_ROOT\*\shell\WSLVSCode" /t REG_EXPAND_SZ /d "Open in WSL VSCode"
reg add "HKEY_CLASSES_ROOT\*\shell\WSLVSCode" /v Icon /t REG_EXPAND_SZ /d "C:\Program Files\Microsoft VS Code\Code.exe"

reg add "HKEY_CLASSES_ROOT\Directory\shell\WSLVSCode\command" /t REG_EXPAND_SZ /d "wsl.exe --cd \"%V\" code ."
reg add "HKEY_CLASSES_ROOT\Directory\shell\WSLVSCode" /t REG_EXPAND_SZ /d "Open in WSL VSCode"
reg add "HKEY_CLASSES_ROOT\Directory\shell\WSLVSCode" /v Icon /t REG_EXPAND_SZ /d "C:\Program Files\Microsoft VS Code\Code.exe"


reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WSLVSCode\command" /t REG_EXPAND_SZ /d "wsl.exe --cd \"%V\" code ."
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WSLVSCode" /t REG_EXPAND_SZ /d "Open in WSL VSCode"
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\WSLVSCode" /v Icon /t REG_EXPAND_SZ /d "C:\Program Files\Microsoft VS Code\Code.exe"






create a bat file
powershell.exe -Command "D:\workdrive-win\windows-startup-scripts\wsl-hyperv-network.ps1"


how to set hyper v switch ip on host machine

list all stuff with predefined ip addresses.
hnsdiag list networks

```
 netsh interface ipv4 show addresses
 netsh interface ip set address name="vEthernet (std)" static 192.168.199.1 255.255.255.0 none
Set-NetConnectionProfile -InterfaceAlias "vEthernet (std)" -NetworkCategory  Private
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory  Private

```
 set std to private


 Windows Firewall ping enable 
Search for and open Windows Firewall.
Select Advanced Settings on the left.
From the left pane of the resulting window, select Inbound Rules.
In the right pane, find the rules titled File and Printer Sharing (Echo Request - ICMPv4-In).
Right-click each rule and choose Enable Rule.