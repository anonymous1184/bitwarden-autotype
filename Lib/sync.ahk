
sync(showTip := false)
{
    if !isLogged || isLocked
        return
    Menu Tray, Icon, shell32.dll, 239
    bw("sync")
    async("bwStatus")
    getData()
    if showTip
        tip("Sync complete")
}

sync_auto(mins)
{
    if !period := 1000 * 60 * mins
        return
    SetTimer sync, % period
}
