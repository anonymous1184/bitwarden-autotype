
Aac_Generate()
{
	secret := Base32_Rand()
	GuiControl ,, Edit1, % secret
	;TODO: Generate QR codes with GDI+
	UrlDownloadToFile % "https://chart.apis.google.com/chart"
			. "?cht=qr&chs=370x370&chld=L|0&chl="
			; otpauth://totp/Auto-Type%20Unlock?issuer=Bitwarden&secret=
			. "otpauth%3A%2F%2Ftotp%2FAuto-Type%2520Unlock%3Fissuer%3DBitwarden%26secret%3D" secret
		, % A_Temp "\bw-at-qr"
	GuiControl ,, Static1, % A_Temp "\bw-at-qr"
	FileDelete % A_Temp "\bw-at-qr"
	return secret
}

Aac_GuiMove()
{
	PostMessage 0xA1, 0x2,,, A
}

Aac_Secret()
{
	GuiControlGet secret,, Edit1
	Gui Aac_Secret:New, +AlwaysOnTop +LastFound -SysMenu
	Gui Aac_Secret:Font, s15 q5 w1000, Consolas
	loop parse, secret
		Gui Aac_Secret:Add, Text, % "Border Center w30 y10 x" A_Index * 40 - 20, % A_LoopField
	Gui Aac:Hide
	Gui Aac_Secret:Show,, Secret (Click to copy)
	Hotkey IfWinActive
	Hotkey !F4, Aac_SecretGuiEscape
	Hotkey IfWinActive
	OnMessage(0x0201, "Aac_SecretCopy") ; WM_LBUTTONDOWN
}

Aac_SecretCopy()
{
	secret := ""
	loop 8
	{
		GuiControlGet val,, % "Static" A_Index
		secret .= val
	}
	if (secret && secret != Clipboard)
	{
		Clipboard := secret
		Aac_SecretGuiEscape()
	}
}

Aac_SecretGuiEscape()
{
	Gui Aac_Secret:Destroy
	Gui Aac:Show
}

Aac_Setup()
{
	Random ,, % Epoch()
	Gui Aac:New, +AlwaysOnTop +LastFound
	Gui Aac:Font, s11 q5, Consolas
	Gui Aac:Add, Picture, gAac_GuiMove w370 h370 x0 y0
	Gui Aac:Add, Edit, Section w0 h0, % Aac_Generate()
	Gui Aac:Add, Button, gAac_Secret x+9 ys, Show secret
	Gui Aac:Add, Button, gAac_Generate ys, Generate new
	Gui Aac:Add, Button, Default gAac_Verify ys, Verification
	Gui Aac:Show, w370 h415, Setup authenticator unlock
	WinWaitClose
}

Aac_Verify()
{
	Gui Aac:Hide
	GuiControlGet secret,, Edit1
	tries := 3
	while tries--
	{
		code := Pin("Authenticator code")
		if !StrLen(code)
			break
		if (code != Totp(secret))
			continue
		hash := Crypt.Hash.String("SHA512", MasterPw)
		INI.DATA.pin := Crypt.Encrypt.String("AES", "CBC", secret, hash)
		Alert(0x40, "Application will unlock using Authenticator codes")
		Gui Aac:Destroy
		return
	}
	Gui Aac:Show
}

AacGuiEscape()
{
	Gui Aac:Destroy
}
