
pin(title)
{
    INI.PIN.pin := ""
    Gui New, +AlwaysOnTop +LastFound +ToolWindow
    Gui Font, s15 q5 w1000, Consolas
    loop 6
        Gui Add, Edit, % "Center Limit1 Number w30 y10 x" A_Index * 40 - 20
    Gui Show,, % title
    getControls()
    OnMessage(0x101, "pin_type") ; WM_KEYUP
    WinWaitClose
    return INI.PIN.pin
}

pin_type(wParam, lParam, msg, hWnd)
{
    static pin := []
    global guiControls

    key := GetKeyName(Format("sc{:X}", lParam >> 16 & 0xFF))
    if key ~= "Shift|Tab" || GetKeyState("Shift", "P")
        return
    if  key ~= "^[^0-9]" ; Digits and Numpad-digits only
    && (key ~= "^[^Num]" && GetKeyState("NumLock", "T"))
        return

    value := ""
    controlID := guiControls[hWnd]
    GuiControlGet value,, % controlID
    if StrLen(value)
    {
        pin[controlID] := value
        if pin.Count() = 6
        {
            for i,num in pin
                INI.PIN.pin .= num
            pin := []
            Gui Destroy
        }
        else
            Send {Tab}
    }
    else
        pin.Delete(controlID)
}


GuiClose:
GuiEscape:
    Gui Destroy
return
