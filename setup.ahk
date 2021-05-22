; Defaults
ListLines Off
SetBatchLines -1
DetectHiddenWindows On

; Arguments
verbose := !quiet := DEBUG := false
for i,arg in A_Args
{
    if arg ~= "i)[-|\/]quiet"
        verbose := !quiet := true
    else if arg ~= "i)[-|\/]debug"
        DEBUG := true
}

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

; Signatures
signExe(A_ProgramFiles "\Auto-Type\bw-at.exe", "Auto-Type", true)
signExe(A_ProgramFiles "\Auto-Type\uninstall.exe", "Auto-Type")

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
Gui New, +AlwaysOnTop +HwndHwnd +ToolWindow
Gui Font, s11 q5, Consolas
Gui Add, Text,, Getting version...
Gui Show,, > Download
Hotkey IfWinActive, % "ahk_id" hWnd
Hotkey !F4, WinExist
hMenu := DllCall("User32\GetSystemMenu", "UInt",hWnd, "UInt",0)
for i,uPosition in { SC_MINIMIZE: 0xF020, SC_CLOSE: 0xF060 }
    DllCall("User32\DeleteMenu", "UInt",hMenu, "UInt",uPosition, "UInt",0)

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
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    url := "https://api.github.com/repos/bitwarden/cli/releases/latest"
    whr.Open("GET", url, false), whr.Send()
    latest := JSON.Load(whr.ResponseText)
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
;@Ahk2Exe-SetVersion 1.0.0.1
;@Ahk2Exe-SetProductVersion 1.0.0.1
;@Ahk2Exe-UpdateManifest 1
