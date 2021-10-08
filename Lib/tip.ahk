
Tip(txt)
{
	TrayTip
	SetTimer Tip_Hide, Delete
	TrayTip % AppTitle, % txt, 30, 0x20
	SetTimer Tip_Hide, -10000
	fObject := Func("DllCall").Bind("K32EmptyWorkingSet", "Int",-1)
	SetTimer % fObject, -1000
}

Tip_Hide()
{
	TrayTip
}
