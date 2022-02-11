
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
	RegExMatch(String, "i)algorithm=\K\w+", algorithm)
	if !(algorithm ~= "i)(SHA1|SHA256|SHA512)")
		algorithm := "SHA1"
	if RegExMatch(String, "i)digits=\K\d+", digits)
		digits := Max(1, Min(10, digits))
	else
		digits := 6
	RegExMatch(String, "i)period=\K\d+", period)
	period := period ? period : 30
	if RegExMatch(String, "i)^steam:\/\/\K.+", secret)
		digits := 0
	else if !RegExMatch(String, "i)secret=\K\w+", secret)
		secret := StrReplace(String, " ")
	totp := Totp(secret, digits, period, algorithm)
	if (digits = 0)
		totp := Totp_Steam(totp)
	if (Mode = "default")
	{
		if (INI.GENERAL.totp)
			Totp_Clipboard(totp, period)
		if (INI.GENERAL.totp = 1)
			Totp_Tip(totp)
	}
	return totp
}

Totp_Steam(Totp)
{
	otp := ""
	dict := StrSplit("23456789BCDFGHJKMNPQRTVWXY")
	size := dict.Count()
	loop 5
	{
		idx := Mod(Totp, size)
		otp .= dict[idx + 1]
		Totp /= size
	}
	return otp
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
