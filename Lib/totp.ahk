
; https://tools.ietf.org/html/rfc6238
Totp(Secret, Digits := 6, Period := 30, Algorithm := "SHA1")
{
	if !key := Base32_Hex(Secret)
		return
	counter := Format("{:016x}", Epoch() // Period)
	hmac := Crypt.Hash.HMAC(Algorithm, counter, key, "HEX")
	offset := hex2dec(SubStr(hmac, 0)) * 2 + 1
	totp := hex2dec(SubStr(hmac, offset, 8)) & 0x7FFFFFFF
	return SubStr(totp, -1 * Digits + 1)
}

Totp_Format(Totp)
{
	mid := StrLen(Totp) // 2
	return SubStr(Totp, 1, mid) " " SubStr(Totp, ++mid)
}

; https://github.com/google/google-authenticator/wiki/Key-Uri-Format
Totp_Parse(KeyUri, Mode)
{
	if (InStr(KeyUri, "otpauth://totp") != 1)
		return
	if !RegExMatch(KeyUri, "secret=\K\w+", secret)
		return
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
			Clipboard := totp
		if (INI.GENERAL.totp = 1)
			Tip("TOTP: " TOTP_Format(totp))
	}
	return totp
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
