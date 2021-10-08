
Workstation_Lock()
{
	DllCall("User32\LockWorkStation")
	OnMessage(0x02B1, "WM_WTSSESSION_CHANGE")
	DllCall("Wtsapi32\WTSRegisterSessionNotification", "Ptr",A_ScriptHwnd, "Ptr",0x1)
}

Workstation_UnLock()
{
	OnMessage(0x02B1, "")
	DllCall("Wtsapi32\WTSUnRegisterSessionNotification", "Ptr",A_ScriptHwnd)
}

WM_WTSSESSION_CHANGE(wParam, lParam)
{
	; On session Unlock
	if (wParam = 0x8)
		Workstation_UnLock()
}
