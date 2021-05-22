
getControls()
{
    global guiControls := []
    WinGet types, ControlList
    types := StrSplit(types, "`n")
    WinGet hWndList, ControlListHwnd
    loop parse, hWndList, `n
        guiControls[A_LoopField] := types[A_Index]
    return guiControls
}
