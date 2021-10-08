
KeysWait()
{
	hk := StrReplace(A_ThisHotkey, " UP")
	mods := ["<", ">", "*", "~", "$"]
	keys := { "#":"Win", "!":"Alt", "^":"Ctrl", "+":"Shift" }

	for _,mod in mods
	{
		for key in keys
			hk := StrReplace(hk, mod key, key)
	}

	for key,name in keys
	{
		KeyWait % "L" name
		KeyWait % "R" name
		hk := StrReplace(hk, key)
	}

	if GetKeyName(hk)
		KeyWait % hk

}
