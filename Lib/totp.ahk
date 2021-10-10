
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
	SetTimer % fObject, % 900
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

; https://github.com/google/google-authenticator/wiki/Key-Uri-Format
Totp_Parse(KeyUri, Mode)
{
	if (InStr(KeyUri, "otpauth://totp") != 1)
		return Totp_Tip("Invalid Key Uri")
	if !RegExMatch(KeyUri, "secret=\K\w+", secret)
		return Totp_Tip("Missing secret")
	RegExMatch(KeyUri, "digits=\K\d+", digits)
	digits := digits > 6 ? 8 : 6
	RegExMatch(KeyUri, "period=\K\d+", period)
	period := period > 30 ? period : 30
	RegExMatch(KeyUri, "algorithm=\K\w+", algorithm)
	if !(algorithm ~= "i)(SHA1|SHA256|SHA512)")
		algorithm := "SHA1"
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
