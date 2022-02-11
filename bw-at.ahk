/**
 *
 *                             CODE IPSA LOQUITUR
 *
 *            The code speaks for itself! Or at least it should...
 *            I'm very sorry about my poor code-commenting skills.
 */

; Defaults
ListLines Off
SetKeyDelay 50
SetBatchLines -1
SetTitleMatchMode 2
DetectHiddenWindows On

; For startup
Process Priority,, High

DebuggerCheck()
/*@Ahk2Exe-Keep
FileGetVersion version, % A_ScriptFullPath
if (version ~= "999$")
	Alert(0x30, "DEBUG", "This is a DEBUG version!")
*/

; Environment
global SESSION := ""
	, IsLocked := ""
	, IsLogged := ""
	, BwFields := []
	, BwStatus := {}
	, MasterPw := ""
	, UserSeed := ""
	, ClipData := ""
	, AppTitle := "Bitwarden Auto-Type"

; For VSCode only
EnvGet DEBUG, AHK_DEBUG

; Settings:
; Dev > Portable > Installation
SplitPath A_ScriptFullPath,, dir,, name
for _,file in [dir "\dev\.ini", dir "\" name ".ini"
	, A_AppData "\Auto-Type\settings.ini"]
{
	if (FileExist(file) ~= "[^D]+")
		break
	file := false
}

if (!file)
{
	; Portable > Installation
	file := dir "\" name ".ini"
	if InStr(A_ScriptDir, A_ProgramFiles)
	{
		FileCreateDir % A_AppData "\Auto-Type"
		file := A_AppData "\Auto-Type\settings.ini"
	}
	/*TODO: Move into assets\ after the bug is fixed:
	* https://www.autohotkey.com/boards/viewtopic.php?f=14&t=94956
	*/
	FileInstall bw-at.ini, % file
}

; Working Directory
SplitPath file,, cwd
SetWorkingDir % cwd

; CLI path
bwCli := "bw.exe"
if !FileExist(bwCli)
	bwCli := A_ProgramFiles "\Auto-Type\bw.exe"
out := CheckExe(bwCli, 1.11)
if (out)
{
	Alert(0x10, "Bitwarden CLI: " out)
	ExitApp 1
}

; Load settings
global INI := Ini(file, true)

; Manually
JSON._init()

; Reporting
Error(!DEBUG)

; Check for errors
if (!DEBUG)
	Settings_Validate(file)

Menu() ; On the tray
if (A_Args[1] = "-settings")
	Settings()
else
	Bind() ; Hotkeys check

; Updates at startup
if (INI.GENERAL.updates)
	Update()

; Automatic actions
Timeout(INI.GENERAL.timeout, INI.GENERAL.action)

; Scheduled sync
Bitwarden_SyncAuto(INI.GENERAL.sync)

; Active vault information
IsLocked := IsLogged := false
BwStatus := FileOpen("data.json", 0x3).Read()
BwStatus := BwStatus ? JSON.Load(BwStatus) : {}
;          v1.11 to v1.20        ||        v1.21+
if (StrLen(BwStatus.accessToken) || StrLen(BwStatus.activeUserId))
		IsLocked := IsLogged := true

if (IsLocked)
{
	Bitwarden_Status()
	MasterPw := Lock_Toggle(false)
}
else
{
	MasterPw := Login_Toggle(false)
	Bitwarden_Status()
}

if (!IsLogged || IsLocked)
	ExitApp 1

; Decrypt data
Bitwarden_Data()

; Acknowledge
Tip("Auto-Type Ready")

; For TCATO when enabled
UserSeed := DllCall("Ntdll\RtlComputeCrc32"
	, "Ptr",0
	, "AStr",BwStatus.userId
	, "Ptr",StrLen(BwStatus.userId)
	, "UInt")

; Restore
Process Priority,, Normal

; Setup PIN/code unlock
if (INI.GENERAL.pin && !INI.DATA.pin)
{
	switch INI.GENERAL.pin
	{
		case 1: Pin_Setup()
		case 2: Aac_Setup()
	}
}

; Favicons
if (INI.GENERAL.favicons)
	Async("Favicons")


return ; End of auto-execute thread


#NoEnv
#NoTrayIcon
#KeyHistory 0
#MenuMaskKey vkE8
#WinActivateForce
#HotkeyInterval -1
;@Ahk2Exe-IgnoreBegin
#SingleInstance Force
#Warn All, OutputDebug
;@Ahk2Exe-IgnoreEnd
/*@Ahk2Exe-Keep
#SingleInstance Ignore
*/

; Includes
#Include %A_ScriptDir%
#Include <Crypt>
#Include <JSON>
#Include <Match>

;@Ahk2Exe-Base %A_ScriptDir%\assets\bw-at.bin, bw-at.exe, CP65001
;@Ahk2Exe-SetCompanyName u/anonymous1184
;@Ahk2Exe-SetCopyright Copyleft 2020
;@Ahk2Exe-SetDescription Bitwarden Auto-Type
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\assets\bw-at.ico
;@Ahk2Exe-SetName Bitwarden Auto-Type
;@Ahk2Exe-SetOrigFilename bw-at.ahk
;@Ahk2Exe-SetProductVersion 1.1.3.1
;@Ahk2Exe-SetVersion 1.1.3.1
;@Ahk2Exe-UpdateManifest 0, Auto-Type, 1.1.3.1, 0
; BinMod
;@Ahk2Exe-PostExec "%A_ScriptDir%\assets\BinMod.exe" "%A_WorkFileName%"
;@Ahk2Exe-Cont  "2.AutoHotkeyGUI.Auto-Type-GUI"
;@Ahk2Exe-PostExec "%A_ScriptDir%\assets\BinMod.exe" "%A_WorkFileName%"
;@Ahk2Exe-Cont  "22.>AUTOHOTKEY SCRIPT<.$APPLICATION SOURCE"
;@Ahk2Exe-PostExec "%A_ScriptDir%\assets\BinMod.exe" "%A_WorkFileName%" /SetUTC
