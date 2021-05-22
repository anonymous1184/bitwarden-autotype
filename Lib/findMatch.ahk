
findMatch(mode)
{
    if !isLogged && !toggleLogin()
        return
    if isLocked && !toggleLock()
        return

    ; Early fail if Clipboard unaccessible for TCATO
    if INI.TCATO.use && DllCall("User32\GetOpenClipboardWindow", "Ptr")
    {
        MsgBox % 0x10|0x40000, % appTitle, TCATO cannot access the Clipboard.
        return
    }

    url := ""
    global autoTypeWindow
    hWnd := WinExist("A")
    autoTypeWindow := hWnd
    WinGetClass activeClass
    WinGetTitle activeTitle
    WinGet exe, ProcessName

    ; Browsers only
    if exe contains chrome,msedge,firefox,iexplore,opera
        if url := getUrl(hWnd, InStr(exe, "ie"))
            splitUrl(url, host, domain)

    atMatches := []
    ; Loop through the JSON
    for i,entry in bwFields
    {
        if (mode = "totp" && !entry.otpauth)
            continue
        isMatch := false
        if url ; by URL
        {
            switch entry.match
            {
                ; Never
                case 5: continue
                ; RegEx
                case 4: isMatch := RegExMatch(url, entry.uri)
                ; Exact
                case 3: isMatch := InStr(url, entry.uri, true)
                ; Start
                case 2: isMatch := InStr(url, entry.uri)
                ; Host
                case 1: isMatch := (host = entry.host)
                ; Base Domain
                default: ; case 0 and NULL
                    isMatch := (domain = entry.domain)
            }
        }
        ; by .exe
        else if SubStr(entry.uri, -3) = ".exe"
            isMatch := (exe = entry.uri)
        ; by class
        else if RegExMatch(entry.uri, "class=(.+)", $)
            isMatch := ($1 = activeClass)
        ; by window title, exact match
        else if RegExMatch(entry.uri, "title=(.+)", $)
            isMatch := ($1 == activeTitle)
        ; by window title, partial match
        else if !entry.schema
            isMatch := InStr(activeTitle, entry.uri)

        if isMatch
        {
            ; Add a typing sequence
            if (entry.HasKey("field") && mode = "default")
                entry.sequence := entry.field
            else
                entry.sequence := INI.SEQUENCES[mode]
            atMatches.Push(entry)
        }
    }

    ; End if no matches
    if !total := atMatches.Count()
    {
        MsgBox % 0x10|0x40000, % appTitle, No auto-type match found.
        return
    }

    ; Multiple matches
    if total = 1
        autoType(atMatches[1], mode)
    else
        selectMatch(atMatches, mode)

}
