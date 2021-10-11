
Bind()
{
	bound := 0
	for field,key in INI.HOTKEYS
		bound += Bind_To(field, key)
	if (bound = 0)
	{
		Alert(0x10, "No hotkeys provided.")
		Settings()
	}
}

Bind_To(Field, Key)
{
	static fObjects := {}, keys := {}
		, pid := DllCall("GetCurrentProcessId")

	Hotkey IfWinNotActive, % "ahk_pid" pid
	if (!Field && !Key)
	{
		for field,fObject in fObjects
			Hotkey % keys[field], % fObject, Off
		keys := {}
		return
	}

	if !StrLen(INI.SEQUENCES[Field])
	{
		Alert(0x10, "No " Quote(Field) " sequence defined. Open the settings file and fix the issue.")
		ExitApp 1
	}

	if fObjects.HasKey(field)
		fObject := fObjects[Field]
	else
	{
		fObject := Func("Match").Bind(Field)
		fObjects[Field] := fObject
	}

	keys[Field] := Key
	Hotkey % Key, % fObject, UseErrorLevel
	if (ErrorLevel)
	{
		Alert(0x10, "Invalid hotkey for " Quote(Field) " sequence.")
		Exit
	}
	Hotkey IfWinNotActive

	return 1
}
