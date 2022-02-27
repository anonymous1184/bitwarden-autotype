; Defaults
ListLines Off
SetBatchLines -1
DetectHiddenWindows On
Process Priority,, High

; Arguments
verbose := !quiet := false
if (A_Args[1] ~= "i)-quiet")
	verbose := !quiet := true

if (verbose)
{
	Alert_Labels("", "&Exit")
	msg := "Do you want to uninstall Bitwarden Auto-Type?"
	Alert(0x134, "Uninstall?", msg)
	IfMsgBox No ; Relabeled as `Exit`
		ExitApp
}

WinKill ahk_exe bw-at.exe

remove := 1
if (verbose)
{
	Alert(0x24, "Remove?", "Do you want to remove the stored Settings?")
	IfMsgBox No
		remove := 0
}

; Execute from %TEMP%
if (A_IsCompiled && !InStr(A_ScriptDir, A_Temp))
{
	tmp := A_Temp "\bw-at-uninstall.tmp"
	FileCopy % A_ScriptFullPath, % tmp, % true
	Run % tmp " -quiet:" remove
	ExitApp
}

; User settings
if (A_Args[1] ~= ":1")
{
	EnvGet public, PUBLIC
	loop files, % public "\..\*", D
	{
		dir := A_LoopFileLongPath "\AppData\Roaming\Auto-Type"
		FileRemoveDir % dir, % true
	}
}

; Application and start menu
for i,dir in [ A_ProgramFiles "\Auto-Type"
	, A_AppDataCommon "\Microsoft\Windows\Start Menu\Programs\Auto-Type"]
{
	FileRemoveDir % dir, % true
	if (ErrorLevel)
		DllCall("Kernel32\MoveFileEx", "Str",dir, "Ptr",0, "UInt",0x4)
}

; Desktop shortcut
FileDelete % A_DesktopCommon "\Auto-Type.lnk"

; Autorun
users := []
loop reg, HKU, K
	users.Push(A_LoopRegName)
for i,user in users
{
	RegDelete % "HKU\" user "\Software\Microsoft\Windows\CurrentVersion\Run"
		, Bitwarden Auto-Type
}

; Uninstall info
RegDelete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Auto-Type

; Remove certificate
Run % "PowerShell -Command " Quote("Get-ChildItem Cert:\LocalMachine\*\* | "
	. "Where-Object {$_.Subject -like 'CN=Auto-Typ*'} | Remove-Item"),, Hide

; Acknowledge
if (verbose)
	Alert(0x40, "Complete!", "Bitwarden Auto-Type has been uninstalled.")

; Self-destruct
if (A_IsCompiled)
{
	Run % A_ComSpec " /C " Quote("timeout /t 1 & del "
		. Quote(A_ScriptFullPath)),, Hide ErrorLevel
	if (ErrorLevel)
	{
		DllCall("Kernel32\MoveFileEx"
			, "Str",A_ScriptFullPath
			, "Ptr",0
			, "UInt",0x4)
	}
}


ExitApp


#NoEnv
#NoTrayIcon
#KeyHistory 0
;@Ahk2Exe-IgnoreBegin
#SingleInstance Force
#Warn All, OutputDebug
;@Ahk2Exe-IgnoreEnd
/*@Ahk2Exe-Keep
#SingleInstance Ignore
*/

; Includes
#Include %A_ScriptDir%


;@Ahk2Exe-Base %A_ScriptDir%\assets\bw-at.bin, uninstall.exe, CP65001
;@Ahk2Exe-SetCompanyName u/anonymous1184
;@Ahk2Exe-SetCopyright Copyleft 2020
;@Ahk2Exe-SetDescription Bitwarden Auto-Type Uninstaller
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\uninstall.ico
;@Ahk2Exe-SetName Bitwarden Auto-Type
;@Ahk2Exe-SetOrigFilename uninstall.ahk
;@Ahk2Exe-SetProductVersion 1.1.4.2
;@Ahk2Exe-SetVersion 1.1.4.2
;@Ahk2Exe-UpdateManifest 1, Auto-Type, 1.1.4.2, 0
; BinMod
;@Ahk2Exe-PostExec "%A_ScriptDir%\assets\BinMod.exe" "%A_WorkFileName%"
;@Ahk2Exe-Cont  "22.>AUTOHOTKEY SCRIPT<.$APPLICATION SOURCE"
;@Ahk2Exe-PostExec "%A_ScriptDir%\assets\BinMod.exe" "%A_WorkFileName%" /SetUTC
