
bwStatus()
{
    bwStatus := bw("status")
    bwStatus := JSON.Load(bwStatus)
    lastSync := RegExReplace(bwStatus.lastSync, "\D|.{4}$")
    ts := epoch(lastSync) + epoch(A_Now) - epoch()
    Menu Tray, Tip, % appTitle "`n" epoch_date(ts, "'Sync:' MM/dd/yy h:mm tt")
}

#Include <JSON>
