
Login()
{
	static Passwd
	tsl := INI.CREDENTIALS.tsl
	tsl := "None" (!tsl ? "||" : "|")
		. "Email codes" (tsl = 1 ? "||" : "|")
		. "Authenticator app" (tsl = 2 ? "||" : "|")
		. "Yubico security key" (tsl = 3 ? "||" : "|")
	Gui Login:New, +LastFound -SysMenu
	Gui Login:Font, s11 q5, Consolas
	Gui Login:Add, Text, w175, &Email Address:
	Gui Login:Add, Edit, w175, % INI.CREDENTIALS.user
	Gui Login:Add, Text, w175, Master &Password:
	Gui Login:Add, Edit, Password vPasswd w175, % ""
	Gui Login:Add, Text, w175, &Two-step Login:
	Gui Login:Add, DropDownList, AltSubmit w175, % tsl
	Gui Login:Add, Button, w86 gExitApp, E&xit
	Gui Login:Add, Button, w86 xp+90 Default gLogin_Ok, &OK
	GuiControl Focus, % "Edit" !!INI.CREDENTIALS.user + 1
	Gui Login:Show,, Bitwarden Auto-Type

	WinWaitClose
	return Passwd
}

Login_Ok()
{
	GuiControlGet user,, Edit1
	INI.CREDENTIALS.user := user
	GuiControlGet tsl,, ComboBox1
	INI.CREDENTIALS.tsl := --tsl
	GuiControlGet passwd,, Edit2
	if !StrLen(passwd)
		return
	Gui Login:Submit
	Gui Login:Destroy
}

Login_Toggle(ShowTip := true)
{
	if (IsLogged)
	{
		SESSION := ""
		IsLogged := false
		Tip("Logged out")
		Async("Bitwarden", "logout")
		; Update Menu
		Menu Tray, Disable, 1&
		Menu Tray, Disable, 2&
		Menu Tray, Disable, 7&
		Menu Tray, Rename, 3&, Log&in
		Menu Tray, Icon, shell32.dll, 48
	}
	else
	{
		; Custom login server
		if (INI.ADVANCED.server)
			Async("Bitwarden", "config server " INI.ADVANCED.server)

		passwd := Login()

		code := ""
		commandLine := "login " Quote(INI.CREDENTIALS.user)
			. " --passwordenv BW_PASSWORD"

		tsl := INI.CREDENTIALS.tsl
		if (tsl = 1) ; Email, trigger password
		{
			Async("Bitwarden", commandLine " --method 1", passwd)
			code := Pin("Email verification")
		}
		else if (tsl = 2) ; Authenticator app
			code := Pin("Authenticator code")
		else if (tsl = 3) ; Yubikey, text input
		{
			msg := "YubiKey OTP Security Key:"
			InputBox code, % AppTitle, % msg,, 190, 125,,, Locale
		}

		if StrLen(code)
		{
			methods := [1, 0, 3] ; Email, Authenticator, Yubikey
			commandLine .= " --method " methods[tsl] " --code " code
		}

		; Store session information
		out := Bitwarden(commandLine, passwd)
		if (ErrorLevel)
		{
			ALert(0x10, out)
			Exit
		}
		SESSION := out
		IsLogged := true
		IsLocked := false

		; Update Menu
		Menu Tray, Enable, 1&
		Menu Tray, Enable, 2&
		Menu Tray, Enable, 7&
		Menu Tray, Rename, 2&, &Lock
		Menu Tray, Rename, 3&, Log&out
		Menu Tray, Icon, % A_IsCompiled ? A_ScriptFullPath : A_ScriptDir "\assets\bw-at.ico"
		if (ShowTip)
			Tip("Logged In")
		return passwd
	}
}

LoginGuiClose:
LoginGuiEscape:
	Gui Login:Destroy
	ExitApp
return
