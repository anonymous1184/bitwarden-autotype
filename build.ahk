#Warn All
#SingleInstance force

SetWorkingDir % A_ScriptDir

if DEBUG := InStr(DllCall("Kernel32\GetCommandLine", "Str"), "debug")
    version := A_YYYY "." A_MM "." A_DD "." A_Hour A_Min
else
{
    version := FileOpen("version", 0x0).Read()
    MsgBox % 0x4|0x20|0x100|0x40000, Bump?, Bump build in version?
    IfMsgBox Yes
    {
        version := StrSplit(version, ".")
        version := version[1] "." version[2] "." version[3] "." ++version[4]
        FileOpen("version", 0x1, "CP0").Write(version)
    }
}

for each,script in ["bw-at", "uninstall", "setup"]
{
    buffer := FileOpen(script ".ahk", 0x0, "UTF-8").Read()
    buffer := RegExReplace(buffer, "(SetVersion ).+", "$1" version)
    buffer := RegExReplace(buffer, "(SetProductVersion ).+", "$1" version)
    FileOpen(script ".ahk", 0x1, "UTF-8").Write(buffer)
    RunWait % A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe /bin assets\bw-at.bin /in " script ".ahk", % A_WorkingDir
}

; Portable
FileDelete release\bw-at.zip
zip("release\bw-at.zip"
    , "*.txt", "LICENSE" ; Documents
    , "assets\bw-at.ini" ; Template
    , "bw-at.exe") ; Main Executable

; Cleanup
FileMove setup.exe, release, % true
FileDelete *.exe

if DEBUG
    OutputDebug Done!
else
    MsgBox % 0x40|0x40000, % A_Space, Build Complete!
