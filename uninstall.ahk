; Defaults
ListLines Off
SetBatchLines -1
DetectHiddenWindows On

; Level
if A_Args[1] ~= "i)[-|\/]quiet"
    verbose := !quiet := true

if verbose
{
    SetTimer retry2yes, 1
    MsgBox % 0x5|0x30|0x40000, Uninstall?, Do you want to uninstall Bitwarden Auto-Type?
    IfMsgBox Cancel
        ExitApp
}

while WinExist("ahk_exe bw-at.exe")
{
    if verbose
    {
        SetTimer retry2yes, 1
        MsgBox % 0x5|0x20|0x40000, Close?, Application is running`, close it before continuing?
        IfMsgBox Cancel
            ExitApp
    }
    RunWait taskkill /F /IM bw-at.exe /T,, Hide UseErrorLevel
}

settings := 1
if verbose
{
    MsgBox % 0x4|0x20|0x40000, Remove?, Do you want to remove the stored settings?
    IfMsgBox No
        settings := 0
}

; Execute from %Temp%
if !InStr(A_ScriptFullPath, A_Temp)
{
    tmp := A_Temp "\" A_Now ".exe"
    FileCopy % A_ScriptFullPath, % tmp, % true
    Run % tmp " /quiet /s:" settings
    ExitApp
}

; Folders to remove
dirs := [ A_AppData "\Auto-Type"
    , A_ProgramFiles "\Auto-Type"
    , A_AppDataCommon "\Microsoft\Windows\Start Menu\Programs\Auto-Type"]

if A_Args[2] ~= "s:0"
    dirs.RemoveAt(1)

for i,dir in dirs
{
    FileRemoveDir % dir, % true
    if ErrorLevel
        DllCall("Kernel32\MoveFileEx", "Str",dir, "Int",0, "UInt",0x4)
}
FileDelete % A_DesktopCommon "\Auto-Type.lnk"

signExe_DeleteCert("Auto-Type")
RegDelete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Auto-Type
RegDelete HKCU\Software\Microsoft\Windows\CurrentVersion\Run, Bitwarden Auto-Type

MsgBox % 0x40|0x40000, Success!, Bitwarden Auto-Type has been successfully uninstalled.
Run % ComSpec " /C " quote("timeout /t 1 & del " quote(A_ScriptFullPath)),, Hide

#NoEnv
#NoTrayIcon
#KeyHistory 0
#SingleInstance force

; Includes
#Include %A_ScriptDir%
;@Ahk2Exe-IgnoreBegin
#Include *i dev\warn.ahk
;@Ahk2Exe-IgnoreEnd
#Include <retry2yes>

;@Ahk2Exe-SetCopyright Copyleft 2020
;@Ahk2Exe-SetDescription Bitwarden Auto-Type Uninstaller
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\uninstall.ico
;@Ahk2Exe-SetName Bitwarden Auto-Type
;@Ahk2Exe-SetOrigFilename uninstall.ahk
;@Ahk2Exe-SetVersion 1.0.1.1
;@Ahk2Exe-SetProductVersion 1.0.1.1
;@Ahk2Exe-UpdateManifest 1
