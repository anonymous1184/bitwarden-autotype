
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
	c := INI.CREDENTIALS["api-key"] ? "Checked " : ""
	Gui Login:Add, Checkbox, % c "gLogin_Api_Toggle", &Use Personal API Key
	Gui Login:Add, Link, gLogin_Link -TabStop xp+185, <a>?</a>
	Gui Login:Add, Text, w225 xm, &Email Address:
	Gui Login:Add, Edit, gLogin_Check w225, % INI.CREDENTIALS.user
	Gui Login:Add, Text, w225, Master &Password:
	Gui Login:Add, Edit, gLogin_Check Password w225
	Gui Login:Add, Text, w225, &Two-step Login:
	Gui Login:Add, DropDownList, gLogin_Check AltSubmit w225, % tsl
	GuiControlGet last, Pos, ComboBox1
	Gui Login:Add, Edit, % "gLogin_Check Password w225 x" lastX " y" lastY
	Gui Login:Add, Button, w110 gExitApp, E&xit
	Gui Login:Add, Button, w110 xp+115 Default gLogin_Ok, &OK
	GuiControl Focus, % "Edit" !!INI.CREDENTIALS.user + 1

	Login_Api_Toggle()
	Gui Login:Add, Edit, Hidden vPasswd x0 y0
	Gui Login:Show,, Bitwarden Auto-Type

	WinWaitClose
	return Passwd
}

Login_Api(Passwd)
{
	out := Bitwarden("login --apikey")
	if (ErrorLevel)
	{
		ALert(0x10, out)
		Exit
	}
	return "unlock --passwordenv BW_PASSWORD"
}

Login_Api_Toggle()
{
	GuiControlGet apiEnabled,, Button1
	if (apiEnabled)
	{
		GuiControl Text, Static1, Client &ID:
		GuiControl ,, Edit1, % INI.CREDENTIALS["client-id"]
		GuiControl Text, Static2, Client &Secret:
		GuiControl ,, Edit2, % INI.CREDENTIALS["client-secret"]
		GuiControl Text, Static3, Master &Password:
		GuiControl Hide, ComboBox1
		GuiControl Show, Edit3
	}
	else
	{
		GuiControl Text, Static1, &Email Address:
		GuiControl ,, Edit1, % INI.CREDENTIALS.user
		GuiControl Text, Static2, Master &Password:
		GuiControl ,, Edit2
		GuiControl Text, Static3, &Two-step Login:
		GuiControl Show, ComboBox1
		GuiControl Hide, Edit3
	}
}

Login_Check()
{
	edits := []
	loop 3
	{
		GuiControlGet value,, % "Edit" A_Index
		if Trim(value)
			edits[A_Index] := true
	}
	valid := false
	GuiControlGet apiEnabled,, Button1
	if (apiEnabled && edits.Count() = 3)
		|| (!apiEnabled && edits[1] && edits[2])
	{
		valid := true
	}
	GuiControl % valid ? "Enable" : "Disable", &OK
}

Login_Credentials(Passwd)
{
	code := ""
	commandLine := "login " Quote(INI.CREDENTIALS.user)
		. " --passwordenv BW_PASSWORD"

	tsl := INI.CREDENTIALS.tsl
	if (tsl = 1) ; Email, trigger password
	{
		Async("Bitwarden", commandLine " --method 1", Passwd)
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

	return commandLine
}

Login_Link()
{
	Alert(0x24, "Logging with a Personal API Key is the preferred method.`n"
		. "`nYou need to use this method if you get the following error"
		. ":`n`n>Your authentication request appears to be coming from "
		. "a bot <`n`nDo you want further instructions on how to get a "
		. "Personal API Key to use instead of username/password?")
	IfMsgBox Yes
		Run % "https://bitwarden.com/help/article/personal-api-key/"
			. "#get-your-personal-api-key"
}

Login_Ok()
{
	GuiControlGet apiEnabled,, Button1
	loop 3
	{
		GuiControlGet edit%A_Index%,, % "Edit" A_Index
		edit%A_Index% := Trim(edit%A_Index%)
	}
	INI.CREDENTIALS["api-key"] := apiEnabled
	if (apiEnabled)
	{
		INI.CREDENTIALS["client-id"] := edit1
		INI.CREDENTIALS["client-secret"] := edit2
		GuiControl ,, Edit4, % edit3
	}
	else
	{
		INI.CREDENTIALS.user := edit1
		GuiControlGet tsl,, ComboBox1
		tsl -= 1
		INI.CREDENTIALS.tsl := tsl
		GuiControl ,, Edit4, % edit2
	}
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

		if (INI.CREDENTIALS["api-key"]
			&& INI.CREDENTIALS["client-id"]
			&& INI.CREDENTIALS["client-secret"])
			commandLine := Login_Api(passwd)
		else
			commandLine := Login_Credentials(passwd)

		; Store session information
		out := Bitwarden(commandLine, passwd)
		if (ErrorLevel)
		{
			ALert(0x10, out)
			Exit
		}
		else if (FileOpen("data.json", 0).Length < 512)
		{
			Alert(0x10, "The server is misidentifying the application with a bot.`n`nLogin via Personal API Key is required to circumvent the issue.")
			Reload
			ExitApp 1
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
