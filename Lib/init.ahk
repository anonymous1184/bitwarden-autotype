
init()
{
    ; Active vault
    EnvSet BW_RAW, % "true"
    EnvSet BW_NOINTERACTION, % "true"
    EnvSet BITWARDENCLI_APPDATA_DIR, % A_WorkingDir
    isLocked := isLogged := FileOpen("data.json", 0x2).Length > 512

    if isLocked
    {
        bwStatus()
        passwd := toggleLock(false)
    }
    else
    {
        passwd := toggleLogin(false)
        SetTimer bwStatus, -1 ; Async
    }

    if isLocked
        ExitApp 1

    ; Decrypt data
    getData()

    ; Acknowledge
    Menu Tray, Icon, % A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\assets\bw-at.ico"
    tip("Auto-Type Ready")

    ; Setup PIN
    if INI.PIN.use = -1 && !INI.PIN.hex && pin := pinSetup()
    {
        pin .= bwStatus.userId, iv := bwStatus.userEmail
        INI.PIN.hex := Crypt.Encrypt.String("AES", "CBC", passwd, pin, iv,, "HEXRAW")
        IniWrite % " " INI.PIN.hex, % settings, PIN, hex
    }
    else if INI.PIN.use && INI.PIN.use != -1
        INI.PIN.passwd := passwd

    ; TCATO
    if INI.TCATO.use
        RegExMatch(bwStatus.userId, "\w+", num)
        , INI.TCATO.num := "0x" num

    ; Favicons
    if !INI.GENERAL.favicons
        return

    /* UrlDownloadToFile is way too primitive thus file
    download rely on cURL, shipped with W10 from builds
    1803 onwards (April 2018), check for availability.
    */
    if !FileExist("C:\Windows\System32\curl.exe")
    {
        MsgBox % 0x10|0x40000, % appTitle, cURL is not available.
        IniWrite % "", % settings, GENERAL, favicons
        return
    }
    getFavicons()
}
