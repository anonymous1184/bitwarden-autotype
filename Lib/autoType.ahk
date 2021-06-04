
autoType(entry, mode)
{

    ; Generate TOTP
    if entry.otpauth && mode ~= "default|totp"
    {
        entry.totp := totp(entry.otpauth)
        if (entry.totp && mode = "default" && INI.GENERAL.totp != "Hide")
        {
            if INI.GENERAL.totp
                Clipboard := entry.totp
            tip("TOTP: " formatOtp(entry.totp))
        }
    }

    ; TCATO
    switch entry.tcato
    {
        case "on" : useTCATO := true
        case "off": useTCATO := false
        default:
            useTCATO := INI.TCATO.use
    }
    entry.Delete("tcato") ; To be used as placeholder

    ; Perform
    BlockInput On ; Only works with UI Access.
    p := 1
    while p := RegExMatch(entry.sequence, "[^{}]+|{[^{}]+}", match, p)
        p += autoType_part(match, entry, useTCATO)
    BlockInput Off
}

autoType_part(part, entry, ByRef useTCATO)
{
    regex := "iS){(?<PH>\w+)(\s)?(?<ARGS>(?<ARG1>(\s)?[^ }]*)(\s)?(?<ARG2>(\s+)?[^}]*)?)}"
    RegExMatch(part, regex, $)

    if ($ph = "AppActivate")
    {
        if SubStr($args, -3) = ".exe"
            $args := "ahk_exe " $args
        w := WinExist($args), i := 1
        while w && !WinActive() && i++ < 5
            WinActivate
    }
    else if ($ph = "Beep")
    {
        test := $arg1 $arg2
        if test is digit
            SoundBeep % $arg1, % $arg2
    }
    else if ($ph = "Clipboard")
    {
        if StrLen($args)
            Clipboard := $args
        else
            Send % "{Raw}" Clipboard
    }
    else if ($ph = "ClearField")
    {
        Send ^a{Delete}
    }
    else if ($ph = "Delay")
    {
        delay := Trim($arg1)
        if delay is number
            Sleep % delay
    }
    else if ($ph = "SmartTab")
    {
        if !A_CaretX || !A_CaretY
            Send {Tab}
        else
        {
            loop 5
            {
                Send {Tab}{Right}
                Sleep 250
                if A_CaretX || A_CaretY
                    break
            }
            if !A_CaretX || !A_CaretY ; Not found
            {
                Send {Shift Down}{Tab 4}{Shift Up}
                Exit ; Stop auto-typing
            }
        }
    }
    else if ($ph = "TCATO")
    {
        if ($arg1 = "on")
            useTCATO := 1
        else if ($arg1 = "off")
            useTCATO := 0
        else if !$arg1
            useTCATO ^= 1
    }
    else if GetKeySC($ph) ; Normal Keys
        Send % part
    else ; Auto-type placeholders / text
    {
        txt := entry.HasKey($ph) ? entry[$ph] : part
        if useTCATO && ($ph != "TOTP")
            tcato(txt, INI.TCATO.num, INI.TCATO.wait, INI.TCATO.kps)
        else if (txt != "{TOTP}")
            SendRaw % txt
    }
    return StrLen(part)
}
