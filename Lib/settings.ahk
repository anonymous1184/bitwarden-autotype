
settings()
{
    SetTimer fileUpdate, 1000
    SplitPath settings, fileName
    if !WinExist(fileName)
        Run % "edit " settings
    WinWait % fileName
    WinWaitClose % fileName
    SetTimer fileUpdate, Delete
}

fileUpdate()
{
    static last := 0
    FileGetTime mTime, % settings
    if !last
        last := mTime
    if (last != mTime)
    {
        MsgBox % 0x4|0x20|0x40000, % appTitle, Application needs to be reloaded for the changes to take effect. Reload now?
        IfMsgBox Yes
            Reload
        last := mTime
    }
}
