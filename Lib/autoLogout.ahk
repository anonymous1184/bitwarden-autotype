
autoLogout(idle)
{
    if !mins := 1000 * 60 * idle
        return
    fn := Func("autoLogout_timer").Bind(mins)
    SetTimer % fn, % 1000 * 30
}

autoLogout_timer(mins)
{
    if isLogged && (A_TimeIdle >= mins)
        toggleLogin()
}
