
autoLock(idle)
{
    if !mins := 1000 * 60 * idle
        return
    fn := Func("autoLock_timer").Bind(mins)
    SetTimer % fn, % 1000 * 30
}

autoLock_timer(mins)
{
    if !isLocked && A_TimeIdle >= mins
        toggleLock(true)
}
