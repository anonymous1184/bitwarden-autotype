
; https://tools.ietf.org/html/rfc6238
Totp(Secret, Digits := 6, Period := 30, Algorithm := "SHA1")
{
	key := Base32_Hex(Secret)
	if (!key)
		return Totp_Tip("Invalid Secret")
	counter := Format("{:016x}", Epoch() // Period)
	hmac := Crypt.Hash.HMAC(Algorithm, counter, key, "HEX")
	offset := hex2dec(SubStr(hmac, 0)) * 2 + 1
	totp := hex2dec(SubStr(hmac, offset, 8)) & 0x7FFFFFFF
	return SubStr(totp, -1 * Digits + 1)
}

Totp_Clipboard(Totp, Period)
{
	static fObject := ""
	if IsObject(fObject)
	{
		SetTimer % fObject, Delete
		fObject := ""
	}
	if (!ClipData)
	{
		ClipData := ClipboardAll
		Clipboard := Totp
	}
	fObject := Func("Totp_ClipboardReset").Bind(Period)
	SetTimer % fObject, % 1000
}

Totp_ClipboardReset(Period)
{
	if (A_Sec = 0 || A_Sec = Period)
	{
		Clipboard := ClipData
		ClipData := ""
		SetTimer ,, Delete
	}
}

Totp_Parse(String, Mode)
{
	RegExMatch(String, "algorithm=\K\w+", algorithm)
	if !(algorithm ~= "i)(SHA1|SHA256|SHA512)")
		algorithm := "SHA1"
	RegExMatch(String, "digits=\K\d+", digits)
	digits := digits ? digits : 6
	RegExMatch(String, "period=\K\d+", period)
	period := period ? period : 30
	secret := String
	if (InStr(String, "otpauth://totp") = 1)
	{
		if !RegExMatch(String, "secret=\K\w+", secret)
			secret := String
	}
	else if (InStr(String, "steam://") = 1)
	{
		digits := 5
		secret := SubStr(String, 9)
	}
	totp := Totp(secret, digits, period, algorithm)
	if (Mode = "default")
	{
		if (INI.GENERAL.totp)
			Totp_Clipboard(totp, period)
		if (INI.GENERAL.totp = 1)
			Totp_Tip(totp)
	}
	return totp
}

Totp_Tip(Message)
{
	timeout := 10
	if (Message ~= "^\d+$")
	{
		mid := StrLen(Message) // 2
		Message := SubStr(Message, 1, mid) " " SubStr(Message, ++mid)
		timeout := 30
	}
	Tip("TOTP: " Message, timeout)
}

Totp_Toggle()
{
	if (INI.GENERAL.totp)
		INI.GENERAL.totp := 0
	else
	{
		Alert(0x24, "Show toast notifications?")
		IfMsgBox Yes
			INI.GENERAL.totp := 1
		IfMsgBox No
			INI.GENERAL.totp := 2
	}
	Menu sub1, ToggleCheck, 4&
}
