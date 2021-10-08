
Lock_Toggle(ShowTip := false)
{
	if (IsLocked)
	{
		; Update Menu
		Menu Tray, Enable, 2&
		Menu Tray, Rename, 2&, Un&Lock
		Menu Tray, Rename, 3&, Log&out

		passwd := ValidateUser("Vault unlock", !!MasterPw)
		if (!passwd)
			return
		IsLocked := false

		; Update Menu
		Menu Tray, Enable, 1&
		Menu Tray, Rename, 2&, &Lock
		Menu Tray, Enable, 7&
		Menu Tray, Icon, % A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\assets\bw-at.ico"
		if (ShowTip)
			Tip("Vault unlocked")
		return passwd
	}
	else
	{
		SESSION := ""
		IsLocked := true
		if (ShowTip)
			Tip("Vault locked")
		; Update menu
		Menu Tray, Disable, 1&
		Menu Tray, Disable, 7&
		Menu Tray, Rename , 2&, Un&Lock
		Menu Tray, Icon, shell32.dll, 48
	}
}
