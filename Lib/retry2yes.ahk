
retry2yes()
{
    if !WinActive("ahk_pid " DllCall("Kernel32\GetCurrentProcessId"))
        return
    ControlSetText Button1, &Yes
    SetTimer retry2yes, Delete
}
