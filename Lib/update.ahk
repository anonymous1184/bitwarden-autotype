
update()
{
    if epoch := epoch() < INI.UPDATES["last-check"] + 86400
        return
    if !update_isLatest()
    {
        MsgBox % 0x4|0x20|0x40000, % appTitle, Version is outdated`, open GitHub to download the latest?
        IfMsgBox Yes
            Run https://github.com/anonymous1184/bitwarden-autotype/releases/latest
    }
    IniWrite % " " epoch, % settings, UPDATES, last-check
}

update_isLatest()
{
    if A_IsCompiled
        FileGetVersion current, % A_ScriptFullPath
    else
        FileRead current, % A_ScriptDir "\version"
    try
    {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET"
            , "https://raw.githubusercontent.com/anonymous1184/bitwarden-autotype/master/version"
            , false), whr.Send()
        online := RTrim(whr.ResponseText, "`r`n")
        return checkVersion(current, online)

    }
    return true ; Error while checking
}

update_menu()
{
    if INI.GENERAL.updates := !INI.GENERAL.updates
        IniWrite % " " 1, % settings, GENERAL, updates
    else
        IniWrite % "", % settings, GENERAL, updates
    Menu sub1, % INI.GENERAL.updates ? "Check" : "UnCheck", 3&
}
