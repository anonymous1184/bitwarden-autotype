
bind(field, key)
{
    if !INI.SEQUENCES[field]
    {
        MsgBox % 0x10|0x40000, % appTitle, % "No " quote(field) " sequence defined."
        ExitApp 1
    }
    fn := Func("findMatch").Bind(field)
    Hotkey % key, % fn, UseErrorLevel
    if ErrorLevel
    {
        MsgBox % 0x10|0x40000, % appTitle, % "Invalid hotkey for " quote(field) " field."
        ExitApp 1
    }
}

#Include <findMatch>
