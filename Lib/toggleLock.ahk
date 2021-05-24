
toggleLock(showTip := false)
{
    if isLocked
    {
        ; Use PIN
        tries := 0
        passwd := ""
        while !passwd
            && tries++ < 3
            && INI.PIN.use
            && (INI.PIN.hex || INI.PIN.key)
            && StrLen(pin := pin("Vault Unlock"))
        {
            if INI.PIN.hex
            {
                hex := INI.PIN.hex, pin .= bwStatus.userId, iv := bwStatus.userEmail
                try passwd := Crypt.Decrypt.String("AES", "CBC", hex, pin, iv,, "HEXRAW")
            }
            else if totp(INI.PIN.key) = pin
                passwd := INI.PIN.passwd
        }
        if !passwd && !passwd := getPassword()
            return

        out := bw("unlock " passwd)
        if ErrorLevel
        {
            MsgBox % 0x10|0x40000, % appTitle, % out
            Exit
        }
        SESSION := out

        ; Update Menu
        Menu Tray, Enable, 1&
        Menu Tray, Enable, 2&
        Menu Tray, Rename, 2&, &Lock
        Menu Tray, Rename, 3&, Log&out
        Menu Tray, Icon, % A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\assets\bw-at.ico"
        isLocked := false
        if showTip
            tip("Vault unlocked")
        return passwd
    }
    else
    {
        Menu Tray, Disable, 1&
        Menu Tray, Rename , 2&, Un&Lock
        if showTip
            tip("Vault locked")
        Menu Tray, Icon, shell32.dll, 48
        isLocked := true
    }
}
