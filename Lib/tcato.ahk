
; Two-Channel Auto-Type Obfuscation
; https://keepass.info/help/v2/autotype_obfuscation.html

tcato(str, seed := 0, wait := 500, kps := 10)
{
    sendPart := []
    clipPart := ""
    Clipboard := ""
    Random ,, % seed
    loop parse, str
    {
        Random rnd, 0, 1
        if rnd
            clipPart .= A_LoopField
        else
            sendPart[A_Index] := A_LoopField
    }
    Clipboard := clipPart
    ClipWait
    Send ^v
    Sleep % wait
    Clipboard := ""
    Send % "{Left " StrLen(clipPart) "}"
    SetKeyDelay % 1000 / kps
    loop parse, str
    {
        chr := sendPart[A_Index]
        Send % StrLen(chr) ? "{Raw}" chr : "{Right}"
    }
}

tcato_menu()
{
    if INI.TCATO.use := !INI.TCATO.use
        IniWrite % " " 1, % settings, TCATO, use
    else
        IniWrite % "", % settings, TCATO, use
    Menu Tray, % INI.TCATO.use ? "Check" : "UnCheck", 5&
}
