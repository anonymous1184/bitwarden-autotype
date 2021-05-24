
settings()
{
    SplitPath settings, filename
    Run % "edit " settings
    WinWait % filename
    SetTimer settings_update, 1000
}

settings_update()
{
    static last := 0
    FileGetTime mTime, % settings
    if !last || WinExist("Secure Password Generator")
        last := mTime
    else if (last != mTime)
    {
        MsgBox % 0x4|0x20|0x40000, % appTitle, Application needs to be reloaded for the changes to take effect. Reload now?
        IfMsgBox Yes
            Reload
        last := mTime
    }
    SplitPath settings, filename
    if !WinExist(filename)
        SetTimer % A_ThisFunc, Delete
}
