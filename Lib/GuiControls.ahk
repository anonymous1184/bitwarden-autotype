
GuiControls()
{
	global GuiControls := []
	WinGet cList, ControlList
	cList := StrSplit(cList, "`n")
	WinGet hList, ControlListHwnd
	loop parse, hList, `n
		GuiControls[A_LoopField] := cList[A_Index]
}
