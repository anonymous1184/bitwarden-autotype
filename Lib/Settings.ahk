
Settings()
{
	static

	Menu Tray, NoIcon
	Gui Settings:New, +AlwaysOnTop +LastFound -SysMenu ;-Theme
	Gui Settings:Font, s11 q5, Consolas
	;
	Gui Settings:Add, GroupBox, Section xm w235 h60, Unlock via:   ; +2
	; Gui Settings:Add, Link, gSettings_Link -TabStop xp+102 yp, <a id="pin">?</a>
	lbl := " Master Password" (!INI.GENERAL.pin ? "||" : "|")
		. " Custom PIN number" (INI.GENERAL.pin = 1 ? "||" : "|")
		. " Authenticator code" (INI.GENERAL.pin = 2 ? "||" : "|")
	Gui Settings:Add, DropDownList, AltSubmit vPin xs+10 w215 yp+23, % lbl
	;
	c := INI.GENERAL.totp = 2 ? -1 : INI.GENERAL.totp
	Gui Settings:Add, Checkbox, % "Check3 Checked" c " vTotp xs", Add TOTP to the Clipboard
	Gui Settings:Add, Link, gSettings_Link -TabStop xp+225 yp, <a id="totp">?</a>
	Gui Settings:Add, Checkbox, % (INI.GENERAL.tcato ? " Checked " : "") "vTcato xm", Use Auto-Type Obfuscation
	Gui Settings:Add, Link, gSettings_Link -TabStop xp+225 yp, <a id="tcato">?</a>
	Gui Settings:Add, Checkbox, % (INI.GENERAL.updates ? " Checked " : "") "vUpdates xm", Application update checks
	Gui Settings:Add, Link, gSettings_Link -TabStop xp+225 yp, <a id="updates">?</a>
	Gui Settings:Add, Checkbox, % (INI.GENERAL.favicons ? " Checked " : "") "vFavicons xm", Download favicon of sites
	Gui Settings:Add, Link, gSettings_Link -TabStop xp+225 yp, <a id="favicons">?</a>
	Gui Settings:Add, Checkbox, % (Autorun_Get() ? "Checked " : "") "vAutorun xm", Auto-run at session start
	Gui Settings:Add, Link, gSettings_Link -TabStop xp+225 yp, <a id="autorun">?</a>
	;
	Gui Settings:Add, GroupBox, Section xm w235 h60, Vault timeout:   ; +2
	Gui Settings:Add, Link, gSettings_Link -TabStop xp+125 yp, <a id="timeout">?</a>
	Gui Settings:Add, Edit, w55 xs+10 yp+23
	Gui Settings:Add, UpDown, % "Range0-240 vTimeout", % INI.GENERAL.timeout
	lbl := " None" (!INI.GENERAL.action ? "||" : "|")
		. " Lock app" (INI.GENERAL.action = 1 ? "||" : "|")
		. " Lock Windows" (INI.GENERAL.action = 2 ? "||" : "|")
		. " Logout app" (INI.GENERAL.action = 3 ? "||" : "|")
	Gui Settings:Add, DropDownList, AltSubmit vAction xp+70 w145 yp, % lbl
	;
	Gui Settings:Add, GroupBox, Section xm w235 h60, Synchronization:   ; +2
	Gui Settings:Add, Link, gSettings_Link -TabStop xp+140 yp, <a id="sync">?</a>
	Gui Settings:Add, Edit, w55 xs+10 yp+23
	Gui Settings:Add, UpDown, % "Range0-999 vSync", % INI.GENERAL.sync
	Gui Settings:Add, Text, xp+65 yp+5, Interval in minutes
	;
	hkLabels := new Object_Sortable()
	hkLabels.default := "Default sequence"
	hkLabels.username := "Username only"
	hkLabels.password := "Password only"
	hkLabels.totp := "TOTP sequence"
	for field,lbl in hkLabels
	{
		Gui Settings:Add, GroupBox, Section w235 h55 xm, % lbl ":"
		hk := StrReplace(INI.HOTKEYS[field], "#",, c)
		Gui Settings:Add, Checkbox, % (c ? "Checked " : "") "vWK"
			. A_Index " xs+10 ys+24", Win +
		Gui Settings:Add, Hotkey, % "gSettings_Check vHK" A_Index
			. " w145 xs+80 ys+20", % hk
	}
	Gui Settings:Add, Button, gSettingsGuiClose w105 xm, &Cancel
	Gui Settings:Add, Button, Default gSettings_Submit w105 xp+129, &Save

	Settings_Check()
	Gui Settings:Add, Edit, Hidden vSaved x0 y0, % Saved := 0
	Gui Settings:Show, % "x" A_ScreenWidth - 350, Settings

	WinWaitClose
	Menu Tray, Icon
	if (!Saved)
		return

	INI.GENERAL.totp := Totp = -1 ? 2 : Totp
	Menu sub1, % Totp ? "Check" : "UnCheck", 4&
	INI.GENERAL.tcato := Tcato
	Menu sub1, % Tcato ? "Check" : "UnCheck", 5&
	INI.GENERAL.updates := Updates
	if (Updates)
		Update()
	INI.GENERAL.favicons := Favicons
	if (Favicons)
		Favicons()
	Autorun_Set(Autorun)
	INI.GENERAL.timeout := Timeout
	INI.GENERAL.action := --Action
	Timeout(Timeout, Action)
	INI.GENERAL.sync := Sync
	Bitwarden_SyncAuto(Sync)

	Bind_To("", "")
	for field in hkLabels
	{
		hk := ""
		if (hk%A_Index%)
			hk := (wk%A_Index% ? "#" : "") hk%A_Index%
		if Bind_To(field, hk)
			INI.HOTKEYS[field] := hk
	}

	Pin--
	if (INI.GENERAL.pin != Pin && INI.DATA.pin)
	{
		Alert(0x34, "Existing unlock method will be overridden, continue?")
		IfMsgBox No
			return
		INI.DATA.pin := ""
	}
	INI.GENERAL.pin := Pin
	if (!MasterPw)
		return
	switch Pin
	{
		case 1: Pin_Setup()
		case 2: Aac_Setup()
	}
}

Settings_Check()
{
	valid := {}
	loop 4
	{
		GuiControlGet value,, % "msctls_hotkey32" A_Index
		if (!value)
			continue
		if valid.HasKey(value)
		{
			GuiControl ,, % "msctls_hotkey32" A_Index
			continue
		}
		valid[value] := true
	}
	GuiControl % valid.Count() ? "Enable" : "Disable", &Save
}

Settings_Submit()
{
	; Toggle saved
	GuiControl Text, Edit3, 1
	Gui Settings:Submit
	Gui Settings:Destroy
}

Settings_Link(CtrlHwnd, GuiEvent, LinkIndex, HrefOrID)
{
	help := {}
	help.autorun := "Automatically start the application when Windows starts."
	help.favicons := "Download and update favicons to show if there are multiple matches for an entry when invoking auto-type in browsers."
	help.sync := "Manual synchronization from server at a specified interval."
	help.tcato := "Two-Channel Auto-Type Obfuscation as designed by KeePass."
	help.timeout := "Action to perform after idle time in minutes, max 240 minutes."
	help.totp := "If the box is greyed-out notifications will be suppressed."
	help.updates := "Application will check once per day for updates versions."
	Alert(0x40, help[HrefOrID])
}

Settings_Validate(Path)
{
	if (!INI.DATA.version)
	{
		/*TODO: Move into assets\ after the bug is fixed:
		* https://www.autohotkey.com/boards/viewtopic.php?f=14&t=94956
		*/
		FileInstall bw-at.ini, % Path, % true
		INI := Ini(Path)
		return
	}

	if !(INI.CREDENTIALS.tsl ~= "^(0|1|2|3)$")
		INI.CREDENTIALS.tsl := 0

	if !(INI.CREDENTIALS["api-key"] ~= "^(0|1)$")
		INI.CREDENTIALS["api-key"] := 0

	if !(INI.GENERAL.pin ~= "^(0|1|2)$")
		INI.GENERAL.pin := 0

	if !(INI.GENERAL.totp ~= "^(0|1|2)$")
		INI.GENERAL.totp := 0

	if !(INI.GENERAL.tcato ~= "^(0|1)$")
		INI.GENERAL.tcato := 0

	if !(INI.GENERAL.updates ~= "^(0|1)$")
		INI.GENERAL.updates := 1

	if !(INI.GENERAL.favicons ~= "^(0|1)$")
		INI.GENERAL.favicons := 0

	if (INI.GENERAL.timeout < 0)
		INI.GENERAL.timeout := 0
	else if (INI.GENERAL.timeout > 240)
		INI.GENERAL.timeout := 240

	if !(INI.GENERAL.action ~= "^(0|1|2|3)$")
		INI.GENERAL.action := 0

	if (INI.GENERAL.sync < 0)
		INI.GENERAL.sync := 0
	else if (INI.GENERAL.sync > 999)
		INI.GENERAL.sync := 999

	if !(INI.ADVANCED["reprompt-with-pin"] ~= "^(0|1)$")
		INI.ADVANCED["reprompt-with-pin"] := 1

	if (INI.ADVANCED["update-frequency"] < 0)
		INI.ADVANCED["update-frequency"] := 1

	if (INI.ADVANCED["pin-length"] < 4)
		INI.ADVANCED["pin-length"] := 6
	else if (INI.ADVANCED["pin-length"] > 24)
		INI.ADVANCED["pin-length"] := 24

	if (INI.ADVANCED.field = "")
		INI.ADVANCED.field := "auto-type"

	if (INI.ADVANCED["tcato-ksps"] < 10)
		INI.ADVANCED["tcato-ksps"] := 10
	if (INI.ADVANCED["tcato-wait"] < 250)
		INI.ADVANCED["tcato-wait"] := 250
}

SettingsGuiClose:
SettingsGuiEscape:
	Gui Settings:Destroy
return
