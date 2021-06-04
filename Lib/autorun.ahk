
autorun()
{
    static state := -1
        , keyDir := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    if state = -1
    {
        RegRead state, % keyDir, % appTitle
        return state := !!state
    }
    if state ^= 1
        RegWrite REG_SZ, % keyDir, % appTitle, % quote(A_ScriptFullPath)
    else
        RegDelete % keyDir, % appTitle
    Menu sub1, % state ? "Check" : "UnCheck", 2&
}
