
generator()
{
    Gui Generator:New, +AlwaysOnTop +LabelGenerator +LastFound +ToolWindow
    Gui Font, s9 q5, Consolas
    Gui Add, CheckBox, % (INI.GENERATOR.lower   ? "Checked" : "") " x10 y10" , Lower
    Gui Add, CheckBox, % (INI.GENERATOR.upper   ? "Checked" : "") " xp+70 yp", Upper
    Gui Add, CheckBox, % (INI.GENERATOR.digits  ? "Checked" : "") " xp+70 yp", Digits
    Gui Add, CheckBox, % (INI.GENERATOR.symbols ? "Checked" : "") " xp+70 yp", Symbols
    Gui Add, Text, x10 yp+30, Length:
    Gui Add, Edit, w50 xp+70 yp-5
    Gui Add, UpDown, Range1-999, % INI.GENERATOR.length
    Gui Add, Text, xp+70 yp+6, Exclude:
    Gui Add, Edit, gGenerator_filter r1 w70 xp+70 yp-5, % INI.GENERATOR.exclude
    Gui Add, Text, x10 yp+35, Password:
    Gui Add, Edit, w210 xp+70 yp-5
    Gui Add, Text, x10 yp+35, % "Entropy: 0 bits   "
    Gui Add, Button, x170 yp-6, Copy
    Gui Add, Button, Default x222 yp, Generate
    Gui Show,, Secure Password Generator
    if INI.TCATO.use
        Random ,, % epoch()
    getControls()
    OnMessage(0x0101, "generator_monitor") ; WM_KEYUP
    OnMessage(0x0202, "generator_monitor") ; WM_LBUTTONUP
    OnMessage(0x020A, "generator_monitor") ; WM_MOUSEWHEEL
    WinWaitClose
}

generator_filter(ctrlHwnd)
{
    GuiControlGet value,, % ctrlHwnd
    filtered := ""
    loop parse, value
        if !InStr(filtered, A_LoopField)
            filtered .= A_LoopField
    GuiControl ,, % ctrlHwnd, % filtered
    Send {End}
}

generator_monitor(wParam, lParam, msg, hWnd)
{
    global guiControls
    controlID := guiControls[hWnd]
    if msg = 0x20A ; Scroll
    {
        if update := (controlID = "Edit1")
        {
            GuiControlGet value,, Edit1
            value += wParam = 7864320 ? 1 : -1
            INI.GENERATOR.length := value
        }
    }
    else ; Click/Type
    {
        lParam := lParam >> 16 & 255
        if lParam = 15 ; Tab
            return
        else if lParam in 72,80 ; Up,Down
        {
            GuiControlGet focused, Focus
            if (focused != "Edit1")
                return
        }
        update := true
        ; Checkboxes
        if controlID ~= "Button[1-4]"
        {
            GuiControlGet isChecked,, % controlID
            INI.GENERATOR[A_GuiControl] := !isChecked
        }
        ; Length
        else if controlID ~= "Edit1|updown"
        {
            GuiControlGet value,, Edit1
            INI.GENERATOR.length := value
        }
        ; Exclude
        else if (controlID = "Edit2")
        {
            GuiControlGet value,, Edit2
            INI.GENERATOR.exclude := value
        }
        else if (A_GuiControl = "Copy")
        {
            GuiControlGet Clipboard,, Edit3
            return
        }
        else if (A_GuiControl != "Generate")
            update := false
    }
    if update
    {
        GuiControl Text, Edit3, % passwdGen(INI.GENERATOR, entropy)
        GuiControl Text, Static4, % "Entropy: " entropy " bits"
    }
}


GeneratorClose:
GeneratorEscape:
    Gui Destroy
    for key,val in INI.GENERATOR
        IniWrite % " " val, % settings, GENERATOR, % key
        ;          ↑↑↑  https://i.imgur.com/i2CZlQR.jpg
return
