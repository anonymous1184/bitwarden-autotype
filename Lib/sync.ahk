
sync(showTip := false)
{
    if !isLogged || isLocked
        return
    Menu Tray, Icon, shell32.dll, 239
    bw("sync")
    SetTimer bwStatus, -1
    getData()
    if showTip
        TrayTip % appTitle, Sync complete, 10, 0x20
}

sync_auto(mins)
{
    if !period := 1000 * 60 * mins
        return
    SetTimer sync, % period
}
