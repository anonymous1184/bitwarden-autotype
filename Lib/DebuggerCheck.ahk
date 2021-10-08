
DebuggerCheck()
{
	remoteDebugger := false
	DllCall("CheckRemoteDebuggerPresent"
		, "Ptr",DllCall("GetCurrentProcess", "Ptr")
		, "Int*",remoteDebugger)
	if (DllCall("IsDebuggerPresent") || remoteDebugger)
		ExitApp 1
}
