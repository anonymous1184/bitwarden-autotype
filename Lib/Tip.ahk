
Tip(Message, Timeout := 10)
{
	TrayTip
	SetTimer Tip_Hide, Delete
	TrayTip % AppTitle, % Message, 30, 0x20
	SetTimer Tip_Hide, % -1000 * Timeout
	fObject := Func("DllCall").Bind("K32EmptyWorkingSet", "Int",-1)
	SetTimer % fObject, -1000
}

Tip_Hide()
{
	TrayTip
}
