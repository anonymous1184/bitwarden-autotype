
getData()
{
    Menu Tray, Icon, shell32.dll, 239
    bwFields := bw("list items")
    bwFields := JSON.Load(bwFields)
    bwFields := parseItems(bwFields)
    Menu Tray, Icon, % A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\assets\bw-at.ico"
}
