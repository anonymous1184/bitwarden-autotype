
tip(txt)
{
    TrayTip % appTitle, % txt, 10, 0x20
    fn := Func("DllCall").Bind("K32EmptyWorkingSet", "Int",-1)
    SetTimer % fn, -1000
}
