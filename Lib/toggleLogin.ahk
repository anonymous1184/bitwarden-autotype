
toggleLogin(showTip := true)
{
    async("bw", "logout")
    if isLogged
    {
        isLogged := false
        tip("Logged out")
        ; Update Menu
        Menu Tray, Disable, 1&
        Menu Tray, Disable, 2&
        Menu Tray, Rename , 3&, Log&in
        Menu Tray, Icon, shell32.dll, 48
    }
    else
    {
        ; Custom login server
        if INI.ADVANCED.server
            async("bw", "config server " INI.ADVANCED.server)
        if !passwd := getPassword()
            return
        cmd := "login " INI.CREDENTIALS.user " " passwd
        bw2FA := SubStr(INI.CREDENTIALS.2fa, 1, 1)
        if bw2FA in A,E,Y
        {
            if (bw2FA = "E") ; Trigger email
            {
                global bwCli
                Run % bwCli " " cmd " --method 1",, Hide UseErrorLevel
            }
            if (bw2FA = "Y") ; Yubikey methods
                InputBox code, % appTitle, YubiKey Code,, 190, 125,,, Locale
            else
            {
                code := pin("2FA Code")
                if StrLen(code) != 6
                    return
            }
            methods := { "A":0, "E":1, "Y":3 }
            cmd .= " --method " methods[bw2FA] " --code " code
        }

        ; Store session information
        out := bw(cmd)
        if ErrorLevel
        {
            MsgBox % 0x10|0x40000, % appTitle, % out
            Exit
        }
        SESSION := out

        isLogged := true
        isLocked := false
        ; Update Menu
        Menu Tray, Enable, 1&
        Menu Tray, Enable, 2&
        Menu Tray, Rename, 2&, &Lock
        Menu Tray, Rename, 3&, Log&out
        Menu Tray, Icon, % A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\assets\bw-at.ico"
        if showTip
            tip("Logged In")
        return passwd
    }
}
