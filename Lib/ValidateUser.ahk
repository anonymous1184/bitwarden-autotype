
ValidateUser(Title, UsePin := true)
{
	if (UsePin && INI.GENERAL.pin && INI.DATA.pin)
	{
		hash := Crypt.Hash.String("SHA512", MasterPw)
		data := Crypt.Decrypt.String("AES", "CBC", INI.DATA.pin, hash)
		if (INI.GENERAL.pin = 1)
			valid := ValidateUser_Pin(Title, data)
		else
			valid := ValidateUser_Aac(Title, data)
		if (valid)
			return MasterPw
	}

	tries := 3
	while tries--
	{
		passwd := ValidateUser_Password()
		if (!passwd)
			continue
		out := Bitwarden("unlock --passwordenv BW_PASSWORD", passwd)
		if !ErrorLevel
		{
			SESSION := out
			return passwd
		}
		Alert(0x10, out)
	}
	return false
}

ValidateUser_Aac(Title, Secret)
{
	tries := 3
	while tries--
	{
		code := Pin(Title ": Authenticator code")
		if (code = Totp(Secret))
			return true
	}
	return false
}

ValidateUser_Password()
{
	evalExit := false
	;TODO: Create a UI
	InputBox passwd, % AppTitle, Master Password:, HIDE, 190, 125,,, Locale
	if (!passwd)
	{
		Alert(0x34, "No password was entered, do you want to continue?")
		IfMsgBox No
			evalExit := true
	}
	if (evalExit && MasterPw)
		Exit
	else if (evalExit && !MasterPw)
		ExitApp
	return passwd
}

ValidateUser_Pin(Title, UnlockPin)
{
	tries := 3
	while tries--
	{
		pin := Pin(Title ": PIN", true, INI.ADVANCED["pin-length"])
		if (pin = UnlockPin)
			return true
	}
	return false
}
