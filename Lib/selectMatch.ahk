
selectMatch(matches, mode)
{
    global matchId := 0
        , matchObj := matches
        , matchMode := mode
    labels := { "default": "Default"
             , "username": "Username-only"
             , "password": "Password-only"
                 , "totp": "TOTP" }
    total := matches.Count()

    Gui New, +AlwaysOnTop +LabelMatchGui +LastFound +ToolWindow
    Gui Font, s10
    Gui Add, ListView, AltSubmit Grid gSelectMatch_Row, % "|#|Entry|User" (mode = "totp" ? "" : "|TOTP")
    Gui Add, Button, Default gSelectMatch_Use x-50 y-50

    LV_SetImageList(iconList := IL_Create(total))
    for i,match in matches
    {
        if SubStr(match.host, -3) = ".exe"
        {
            WinGet exe, ProcessPath, % "ahk_exe" match.host
            exe ? IL_Add(iconList, exe)
                : IL_Add(iconList, "shell32.dll", 3)
        }
        else
        {
            img := ""
            loop files, % "icons\" match.host ".*"
                img := A_LoopFileFullPath
            loop files, % "icons\" match.domain ".*"
                img := A_LoopFileFullPath
            img ? IL_Add(iconList, img, 0xFFFFFF, 1)
                : IL_Add(iconList, "imageres.dll", 300)
        }
        if (mode = "totp")
            LV_Add("Icon" i,, i, match.name, match.username)
        else
            LV_Add("Icon" i,, i, match.name, match.username, match.otpauth ? "✔" : "✘")
    }

    ; Auto-size
    LV_ModifyCol()
    LV_ModifyCol(2, "Center")
    if (mode != "totp")
        LV_ModifyCol(5, "AutoHdr Center")
    cols := LV_GetCount("Column")
    listViewWidth := cols * cols
    Loop % cols
    {
        SendMessage 0x101D, % A_Index - 1, 0x0, SysListView321 ; LVM_GETCOLUMNWIDTH
        listViewWidth += ErrorLevel
    }
    GuiControl Move, SysListView321, % "w" listViewWidth
    Gui Show, AutoSize, % " Select Entry (" labels[mode] " sequence)"
}

selectMatch_Row(ctrlHwnd, guiEvent, eventInfo, errLevel := "")
{
    global matchId := EventInfo
    if (GuiEvent = "DoubleClick")
        selectMatch_Use()
}

selectMatch_Use()
{
    global
    Gosub MatchGuiClose
    autoType(matchObj[matchId], matchMode)
}

MatchGuiClose:
MatchGuiEscape:
    Gui %A_Gui%:Destroy
    WinActivate % "ahk_id" autoTypeWindow
return
