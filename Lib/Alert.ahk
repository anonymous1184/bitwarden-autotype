
Alert(Parameters*)
{
	txt := Parameters.Pop()
	opt := Parameters.RemoveAt(1)
	opt |= 0x40000
	if Parameters.Count()
		title := Parameters[1]
	else
		title := AppTitle
	MsgBox % opt, % title, % txt
}

Alert_Labels(ButtonList*)
{
	static fObject := ""
		, pid := DllCall("GetCurrentProcessId")

	if !IsObject(fObject)
	{
		fObject := Func(A_ThisFunc).Bind(ButtonList*)
		SetTimer % fObject, 1
		return
	}

	if !WinExist("ahk_pid" pid " ahk_class#32770")
		return
	SetTimer ,, Delete
	for i,lbl in ButtonList
	{
		if StrLen(lbl)
			ControlSetText % "Button" i, % lbl
	}
	fObject := ""
}
