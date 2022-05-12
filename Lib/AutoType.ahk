
AutoType(Entry, Mode)
{

	; Reprompt
	if (Entry.reprompt)
		&& !ValidateUser("Re-prompt", INI.ADVANCED["reprompt-with-pin"])
		Exit

	; Generate TOTP
	if StrLen(Entry.otpauth)
	{
		totp := TOTP_Parse(Entry.otpauth, Mode)
		if StrLen(totp)
			Entry.totp := totp
	}

	; TCATO
	switch Entry.tcato
	{
		case "on" : obfuscate := true
		case "off": obfuscate := false
		default:
			obfuscate := INI.GENERAL.tcato
	}
	Entry.Delete("tcato") ; To be used as placeholder

	; Perform
	BlockInput On ; Only works with UI Access.
	p := 1
	while p := RegExMatch(Entry.sequence, "[^{}]+|{[^{}]+}", match, p)
		p += AutoType_Part(match, Entry, obfuscate)
	BlockInput Off
}

AutoType_Part(part, Entry, ByRef obfuscate)
{
	regex := "Si){(?<PLACEHOLDER>\w+)(?:\s*)(?<PARAMETERS>(?<PARAMETER1>[^"
		. " }]*)(?:\s*)(?<PARAMETER2>[^}]*))}"
	RegExMatch(part, regex, $)

	if ($Placeholder = "AppActivate")
	{
		if (SubStr($Parameters, -3) = ".exe")
			$Parameters := "ahk_exe" $Parameters
		i := 1
		w := WinExist($Parameters)
		while (w && !WinActive() && i++ < 5)
			WinActivate
	}
	else if ($Placeholder = "Beep")
	{
		if ($Parameter1 $Parameter2 ~= "\d+")
			SoundBeep % $Parameter1, % $Parameter2
	}
	else if ($Placeholder = "Clipboard")
	{
		if StrLen($Parameters)
			Clipboard := $Parameters
		else
			Send ^v
	}
	else if ($Placeholder = "ClearField")
	{
		Send ^a{Delete}
	}
	else if ($Placeholder ~= "i)(Delay|Sleep|Wait)")
	{
		if ($Parameter1 ~= "\d+")
			Sleep % $Parameter1
	}
	else if ($Placeholder = "SmartTab")
	{
		AutoType_SmartTab()
	}
	else if ($Placeholder = "TCATO")
	{
		if (!$Parameter1)
			obfuscate := !obfuscate
		else
			obfuscate := ($Parameter1 = "on")
	}
	else if GetKeySC($Placeholder) ; Named Keys
		Send % part
	else ; Auto-type placeholders / free text
	{
		txt := Entry.HasKey($Placeholder) ? Entry[$Placeholder] : part
		if (obfuscate && $Placeholder != "TOTP")
		{
			wait := INI.ADVANCED["tcato-wait"]
			ksps := INI.ADVANCED["tcato-ksps"]
			Tcato(txt, UserSeed, wait, ksps)
		}
		else if (txt != "{TOTP}") ; TOTP placeholder but no code
			Send % "{Blind}{Raw}" txt
	}
	return StrLen(part)
}

AutoType_SmartTab()
{
	if (!A_CaretX || !A_CaretY)
	{
		Send {Tab}
		return
	}
	loop 5
	{
		Send {Tab}{Right}
		Sleep 250
		if (A_CaretX || A_CaretY)
			break
	}
	if (!A_CaretX || !A_CaretY) ; Not found
	{
		Send +{Tab 4}
		Exit ; Stop auto-type
	}
}
