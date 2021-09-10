; Defaults
ListLines Off
SetBatchLines -1
DetectHiddenWindows On

; Arguments
verbose := !quiet := DEBUG := false
if A_Args[1] ~= "i)[-|\/]quiet"
    verbose := !quiet := true
FileGetVersion version, % A_ScriptFullPath
if StrSplit(version, ".")[1] > 2020
    DEBUG := true

; Check if latest version
if !DEBUG && !update_isLatest()
{
    SetTimer retry2yes, 1
    MsgBox % 0x5|0x40|0x40000, Download?, The version included with this installer is outdated`, do you want to go to GitHub and download the current release?
    IfMsgBox Retry
        Run https://github.com/anonymous1184/bitwarden-autotype/releases/latest
    ExitApp
}

; Ask
if verbose
{
    SetTimer retry2yes, 1
    MsgBox % 0x5|0x20|0x40000, Install?, Do you want to install Bitwarden Auto-Type?
    IfMsgBox Cancel
        ExitApp
}

; Pre-load
latest := ""
SetTimer Preload, -1

; Close if running
while WinExist("ahk_exe bw-at.exe")
    RunWait taskkill.exe /F /IM bw-at.exe /T,, Hide UseErrorLevel

/*
If installing after a un-install that couldn't remove directories, those directories
are queued for deletion on the next reboot. The entries contain a double line-ending
that AHK can't handle, thus reg.exe is used to query the values and then are parsed.
*/
clipBackup := ClipboardAll
RunWait % ComSpec " /C " quote("reg query " quote("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager") " /v PendingFileRenameOperations /se * | clip"),, Hide
operations := StrSplit(Clipboard, "\??\", "*`r`n"), operations.Delete(1)
data := "", Clipboard := clipBackup
for i,file in operations
    data .= InStr(file, "\Auto-Type") ?: "\??\" file "`n`n"
RegWrite REG_MULTI_SZ, HKLM\SYSTEM\CurrentControlSet\Control\Session Manager, PendingFileRenameOperations, % data

; Settings
FileCreateDir % A_AppData "\Auto-Type"
FileInstall assets\bw-at.ini, % A_AppData "\Auto-Type\settings.ini", % false

; App
FileCreateDir % A_ProgramFiles "\Auto-Type"
FileInstall bw-at.exe, % A_ProgramFiles "\Auto-Type\bw-at.exe", % true

; Uninstaller
FileGetVersion version, % A_ScriptFullPath
FileInstall uninstall.exe, % A_ProgramFiles "\Auto-Type\uninstall.exe", % true
key := "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Auto-Type"
RegWrite REG_SZ, % key, DisplayIcon         , % quote(A_ProgramFiles "\Auto-Type\bw-at.exe")
RegWrite REG_SZ, % key, DisplayName         , Bitwarden Auto-Type
RegWrite REG_SZ, % key, DisplayVersion      , % version
RegWrite REG_SZ, % key, NoModify            , 1
RegWrite REG_SZ, % key, Publisher           , anonymous1184
RegWrite REG_SZ, % key, QuietUninstallString, % quote(A_ProgramFiles "\Auto-Type\uninstall.exe") " /quiet"
RegWrite REG_SZ, % key, UninstallString     , % quote(A_ProgramFiles "\Auto-Type\uninstall.exe")
RegWrite REG_SZ, % key, URLInfoAbout        , https://github.com/anonymous1184/bitwarden-autotype/

; Signature
ps1 =
(
if (!($cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -eq "CN=Auto-Type" })) {
    $cert = New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -HashAlgorithm SHA256 -NotAfter (Get-Date).AddMonths(120) -Subject Auto-Type -Type CodeSigning
    foreach ($i in @('TrustedPublisher', 'Root')) {
        $store = [System.Security.Cryptography.X509Certificates.X509Store]::new($i, 'LocalMachine')
        $store.Open('ReadWrite')
        $store.Add($cert)
        $store.Close()
    }
}
Set-AuthenticodeSignature -Certificate $cert -FilePath "%A_ProgramFiles%\Auto-Type\bw-at.exe" -HashAlgorithm SHA256 -TimeStampServer http://timestamp.sectigo.com
)
FileOpen(A_Temp "\bw-at.ps1", 0x1).Write(ps1)
Run PowerShell -ExecutionPolicy Bypass -File .\bw-at.ps1, % A_Temp, Hide, psPid

; Start Menu
FileCreateDir % start := A_AppDataCommon "\Microsoft\Windows\Start Menu\Programs\Auto-Type"
FileCreateShortcut % A_ProgramFiles "\Auto-Type\bw-at.exe", % start "\Auto-Type.lnk"
FileCreateShortcut % A_ProgramFiles "\Auto-Type\uninstall.exe", % start "\Uninstall.lnk"
FileCreateShortcut % A_ProgramFiles "\Auto-Type\bw-at.exe", % A_DesktopCommon "\Auto-Type.lnk"
IniWrite https://github.com/anonymous1184/bitwarden-autotype, % start "\Project Page.url", InternetShortcut, URL
IniWrite C:\Windows\System32\shell32.dll, % start "\Project Page.url", InternetShortcut, IconFile
IniWrite 14, % start "\Project Page.url", InternetShortcut, IconIndex

; bw.exe
if verbose
{
    MsgBox % 0x4|0x20|0x40000, Download?, Do you want to download Bitwarden CLI?
    IfMsgBox No
        Goto Settings
}

; Progress
Gui New, +AlwaysOnTop +HwndHwnd -SysMenu
Gui Font, s11 q5, Consolas
Gui Add, Text,, Getting version...
Gui Show,, > Download
Hotkey IfWinActive, % "ahk_id" hWnd
Hotkey !F4, WinExist

; Latest
while !latest
    Sleep -1
if !IsObject(latest)
{
    Gui Destroy
    MsgBox % 0x1|0x10|0x40000, Error, Cannot retrieve file version information
    Goto Settings
}

; Download
SetTimer Percentage, 1
tmpZipFile := A_Temp "\" A_Now ".zip"
UrlDownloadToFile % asset.browser_download_url, % tmpZipFile
SetTimer Percentage, Delete
Gui Destroy

; Unzip
unzip(tmpZipFile, A_AppData "\Auto-Type")

; Cleanup
FileDelete % tmpZipFile

; Open Settings
Settings:
    MsgBox % 0x40|0x40000, Complete!, Installation complete`, please update the seatings accordingly.
    Run edit settings.ini, % A_AppData "\Auto-Type", UseErrorLevel, settingsPid
    WinWait % "ahk_pid" settingsPid
    WinActivate % "ahk_pid" settingsPid
ExitApp

Preload:
    UrlDownloadToFile https://api.github.com/repos/bitwarden/cli/releases/latest, % A_Temp "\bw-releases.json"
    FileRead buffer, % A_Temp "\bw-releases.json"
    latest := JSON.Load(buffer)
    FileDelete % A_Temp "\bw-releases.json"
    for i,asset in latest.assets
        if InStr(asset.name, "windows")
            break
return

Percentage:
    FileGetSize current, % tmpZipFile
    GuiControl % hWnd ":", Static1, % "Downloaded: " Round(current / asset.size * 100, 2) "%"
return

#NoEnv
#NoTrayIcon
#KeyHistory 0
#SingleInstance force

; Includes
#Include %A_ScriptDir%
;@Ahk2Exe-IgnoreBegin
#Include *i dev\warn.ahk
;@Ahk2Exe-IgnoreEnd
#Include <JSON>
#Include <retry2yes>

;@Ahk2Exe-SetCopyright Copyleft 2020
;@Ahk2Exe-SetDescription Bitwarden Auto-Type Installer
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\bw-at.ico
;@Ahk2Exe-SetName Bitwarden Auto-Type
;@Ahk2Exe-SetOrigFilename setup.ahk
;@Ahk2Exe-SetVersion 1.0.1.1
;@Ahk2Exe-SetProductVersion 1.0.1.1
;@Ahk2Exe-UpdateManifest 1
