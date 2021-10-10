
Error(e)
{
	if !IsObject(e)
		return OnError(A_ThisFunc, e)
	err := {}
	SplitPath % e.File, Filename
	e.File := Filename
	FileGetVersion version, % A_ScriptFullPath
	err.A_Error := e
	err.A_Info := { ""
		. "locked": IsLocked
		, "logged": IsLogged
		, "portable": !InStr(A_ScriptFullPath, A_ProgramFiles)
		, "session": !!SESSION
		, "status": BwStatus.status
		, "sync": BwStatus.lastSync
		, "version": version ? version : "AHK: " A_AhkVersion
		, "windows": A_OSVersion }
	for sect,data in INI
	{
		o := {}
		for key,val in data
			o[key] := val
		err[sect] := o
	}
	if (err.CREDENTIALS.user)
		err.CREDENTIALS.user := "Present"
	if (err.ADVANCED.server)
		err.ADVANCED.server := "Present"
	if (err.ADVANCED.NODE_EXTRA_CA_CERTS)
		err.ADVANCED.NODE_EXTRA_CA_CERTS := "Present"
	if (err.DATA.pin)
		err.DATA.pin := "Present"
	FileOpen("debug.txt", 0x1).Write(JSON.Dump(err, true))
	Alert(0x14, "An error has ocurred debug information was dumped into a file, please include it when reporting the bug. Do you want to open it and review it?")
	IfMsgBox Yes
		Run edit debug.txt,, UseErrorLevel
	return -1 ; Don't let the call stack unwind
}
