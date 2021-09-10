
errorReport(e)
{
    fileName := e.File
    SplitPath fileName, fileName
    err := INI.Clone()
    err.A_Error := { "": ""
        , "e.File": fileName
        , "e.Line": e.Line
        , "e.Message": e.Message
        , "e.What": e.What
        , "isLocked": isLocked
        , "isLogged": isLogged
        , "isPortable": !!InStr(A_ScriptFullPath, A_ProgramFiles)
        , "session": StrLen(SESSION)
        , "status": bwStatus.status
        , "sync": bwStatus.lastSync }
    err.CREDENTIALS.Delete("user")
    if err.TCATO.num
        err.TCATO.num := "Redacted"
    if err.PIN.use && err.PIN.use != -1
        err.PIN.use := StrLen(err.PIN.use)
    if err.PIN.key
        RegExMatch(err.PIN.key, "(?<=secret=)\w+", secret)
        , err.PIN.key := StrLen(secret)
    if err.PIN.hex
        err.PIN.hex := "Redacted"
    if err.PIN.passwd
        err.PIN.Delete("passwd")
    if err.ADVANCED.server
        err.ADVANCED.server := "Redacted"
    if err.ADVANCED.NODE_EXTRA_CA_CERTS
        err.ADVANCED.NODE_EXTRA_CA_CERTS := "Redacted"
    FileOpen("debug.txt", 0x1).Write(JSON.Dump(err, true))
    MsgBox % 0x4|0x10|0x40000, % appTitle, An error has ocurred and a debug file was generated`, please include it when reporting the bug. Do you want to open it and review it?
    IfMsgBox Yes
        Run edit debug.txt,, UseErrorLevel
    return true
}
