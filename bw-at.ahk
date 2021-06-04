/*                   CODE IPSA LOQUITUR
    The code speaks for itself! Or at least, it should...
    (I'm very sorry about my poor code-commenting skills)
*/

; Defaults
ListLines Off
SetBatchLines -1
SetTitleMatchMode 2
DetectHiddenWindows On

; Environment
global SESSION := ""
    , settings := ""
    , isLocked := ""
    , isLogged := ""
    , bwFields := []
    , bwStatus := {}
    , appTitle := "Bitwarden Auto-Type"

/*@Ahk2Exe-Keep
FileGetVersion version, % A_ScriptFullPath
if StrSplit(version, ".")[1] > 2020
{
    MsgBox % 0x4|0x30|0x100|0x40000, DEBUG, This is a DEBUG version`, continue?
    IfMsgBox No
        ExitApp 1
}
*/

; Settings
SplitPath A_ScriptFullPath,, dir,, name
for i,file in [A_AppData "\Auto-Type\settings.ini", dir "\" name ".ini", dir "\dev\.ini"]
    if FileExist(file) ~= "[^D]+"
        settings := file
if !settings
{
    MsgBox % 0x10|0x40000, % appTitle, Settings file not found.
    ExitApp 1
} else if InStr(DllCall("Kernel32\GetCommandLine", "Str"), "/restart")
    settings() ; Application was reloaded, look for changes

; Load settings
global INI := loadIni(settings)

; Error report
OnError("errorReport")

; Updates at startup
opt := INI.GENERAL.updates
if opt in 1,true,yes
    update()

; Current Working Directory
SplitPath settings,, cwd
SetWorkingDir % cwd

; Bitwarden CLI path
bwCli := A_WorkingDir "\bw.exe"
if !FileExist(bwCli)
if err := checkExe(bwCli, "1.11.0")
    bwCli := INI.ADVANCED.bw
{
    MsgBox % 0x10|0x40000, % appTitle, % "Bitwarden CLI: " err
    ExitApp 1
}

; TOTP in Clipboard
opt := INI.GENERAL.totp
if opt not in 1,true,yes,hide
    INI.GENERAL.totp := false

; Auto-lock
autoLock(INI.GENERAL["auto-lock"])

; Auto-logout
autoLogout(INI.GENERAL["auto-logout"])

; Auto-sync
sync_auto(INI.GENERAL["auto-sync"])

; Favicons
opt := INI.GENERAL.favicons
if opt not in 1,true,yes
    INI.GENERAL.favicons := false

; Username
if !INI.CREDENTIALS.user
{
    MsgBox % 0x10|0x40000, % appTitle, No username provided.
    ExitApp 1
}

; Hotkeys
if !INI.HOTKEYS.Count()
{
    MsgBox % 0x10|0x40000, % appTitle, No hotkeys provided.
    ExitApp 1
}
for field,key in INI.HOTKEYS
    bind(field, key)

; Two-Channel Auto-Type Obfuscation
opt := INI.TCATO.use
if opt not in 1,true,yes
    INI.TCATO.use := false

; PIN / 2fa
if !opt := INI.PIN.use
    INI.PIN.use := false
else if opt in 1,true,yes
    INI.PIN.use := -1
if INI.PIN.use != -1
{
    INI.PIN.hex := false
    IniWrite % "", % settings, PIN, hex
}

menu() ; Tray options
init() ; Login/unlock and parse
return ; End of auto-execute


#NoEnv
#NoTrayIcon
#KeyHistory 0
#WinActivateForce
#HotkeyInterval -1
#SingleInstance force

; Includes
#Include %A_ScriptDir%
#Include <errorReport>
;@Ahk2Exe-IgnoreBegin
#Include *i dev\warn.ahk
;@Ahk2Exe-IgnoreEnd

;@Ahk2Exe-SetCopyright Copyleft 2020
;@Ahk2Exe-SetDescription Bitwarden Auto-Type Executable
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\bw-at.ico
;@Ahk2Exe-SetName Bitwarden Auto-Type
;@Ahk2Exe-SetOrigFilename bw-at.ahk
;@Ahk2Exe-SetVersion 1.0.1.1
;@Ahk2Exe-SetProductVersion 1.0.1.1
