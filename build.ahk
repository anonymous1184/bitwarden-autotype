﻿#NoTrayIcon
#Warn All, OutputDebug

if (!A_IsAdmin)
{
	Alert(0x10, "Build error", "Build process needs to run elevated.")
	ExitApp 1
}

SetWorkingDir % A_ScriptDir

gcl := DllCall("Kernel32\GetCommandLine", "Str")
DEBUG := InStr(gcl, " /Debug")

FileRead version, version
version := StrSplit(version, ".")
if (DEBUG)
	version := version[1] "." version[2] "." version[3] ".999"
else
{
	Alert(0x24, "Bump?", "Bump build in version?")
	IfMsgBox Yes
		version[4] += 1
	version := version[1] "." version[2] "." version[3] "." version[4]
	FileOpen("version", 0x1, "CP1252").Write(version)
}

if !FileExist("assets\BinMod.exe")
{
	RunWait % A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe /bin "
		. Quote(A_ProgramFiles "\AutoHotkey\Compiler\Unicode 32*")
		. " /in " Quote(A_ScriptDir "\assets\BinMod.ahk")
}

; Setup
for _,script in ["bw-at", "uninstall", "setup"]
{
	FileRead buffer, % script ".ahk"
	buffer := RegExReplace(buffer, "(SetVersion).*", "$1 " version)
	buffer := RegExReplace(buffer, "(SetProductVersion).*", "$1 " version)
	uia := script = "bw-at" ? 1 : 0
	buffer := RegExReplace(buffer, "(Auto-Type, ).*", "$1" version ", " uia)
	FileOpen(script ".ahk", 0x1, "UTF-8").Write(buffer)
	RunWait % A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe"
		. " /in " Quote(A_ScriptDir "\" script ".ahk")
	RunWait % "PowerShell -ExecutionPolicy Bypass -File .\bw-at.ps1"
			. " " Quote("Auto-Type-Dist")
			. " " Quote(A_ScriptDir "\" script ".exe")
		, % A_ScriptDir, Hide
}
FileMove setup.exe, release, % true

; Portable
FileDelete bw-at.exe
FileRead buffer, bw-at.ahk
buffer := RegExReplace(buffer, "(Auto-Type, ).*", "$1" version ", 0")
FileOpen("bw-at.ahk", 0x1, "UTF-8").Write(buffer)
; ExitApp
RunWait % A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe /in bw-at.ahk"
RunWait % "PowerShell -ExecutionPolicy Bypass -File .\bw-at.ps1 "
		. Quote("Auto-Type-Dist") " " Quote("bw-at.exe")
	, % A_ScriptDir, Hide

FileDelete release\bw-at.zip
Zip("release\bw-at.zip"
	, "assets\bw-at.ini"
	, "bw-at.exe"
	, "CHANGELOG.txt"
	, "LICENSE"
	, "README.txt")

; Clean
FileDelete *.exe
RunWait % "PowerShell -Command " Quote("Get-ChildItem Cert:\LocalMachine\*\*"
		. " | Where-Object {$_.Subject -eq 'CN=Auto-Type-Dist'}"
		. " | Remove-Item")
	,, Hide

if (DEBUG)
{
	OutputDebug Done!
	Run release\setup.exe
}
else
	Alert(0x40, A_Space, "Build Complete!")
