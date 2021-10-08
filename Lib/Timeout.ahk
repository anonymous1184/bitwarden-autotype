
Timeout(Timeout, Action)
{
	static fObject := ""
	if IsObject(fObject)
	{
		SetTimer % fObject, Delete
		fObject := ""
	}
	if (!Timeout || !Action)
		return
	Timeout := 1000 * 60 * Timeout
	fObject := Func("Timeout_Auto").Bind(Timeout, Action)
	SetTimer % fObject, % 1000 * 29
}

Timeout_Auto(Timeout, Action)
{
	if (A_TimeIdlePhysical < Timeout)
		return
	if OnMessage(0x02B1)
		return
	if (Action = 1 && !IsLocked)
		Lock_Toggle(true)
	if (Action = 2)
		Workstation_Lock()
	if (Action = 3 && IsLogged)
		Login_Toggle()
}
