
Pin(title, mask := false, length := 6)
{
	static
	Gui Pin:New, +AlwaysOnTop +LastFound +ToolWindow -SysMenu
	Gui Pin:Font, s15 q5 w1000, Consolas
	opt := "Center Limit1 Number w30 y10 " (mask ? "Password " : "")
	loop % length
		Gui Pin:Add, Edit, % opt "vD" A_Index " x" A_Index * 40 - 20
	Gui Pin:Show,, % title
	Gui Pin:Submit, NoHide
	GuiControls()
	Pin_Type(length, 0, 0, 0)
	OnMessage(0x101, "Pin_Type") ; WM_KEYUP
	WinWaitClose
	out := ""
	loop % length
		out .= d%A_Index%
	return out
}

Pin_Setup()
{
	length := INI.ADVANCED["pin-length"]
	pin1 := Pin("PIN Setup", true, length)
	if !StrLen(pin1)
		return
	pin2 := Pin("Repeat PIN", true, length)
	if !StrLen(pin2)
		return
	if (pin1 != pin2)
		return Pin_Setup()
	hash := Crypt.Hash.String("SHA512", MasterPw)
	INI.DATA.pin := Crypt.Encrypt.String("AES", "CBC", pin1, hash)
	Alert(0x40, "Application will now unlock using a PIN code.")
}

Pin_Type(wParam, lParam, msg, hWnd)
{
	static pin, size
	global GuiControls

	if (!msg && !hWnd)
	{
		pin := []
		size := wParam
	}

	/*
	key := GetKeyName(Format("sc{:X}", lParam >> 16 & 255))
	if (key ~= "Shift|Tab" || GetKeyState("Shift", "P"))
		return
	if (key ~= "^[^0-9]" ; Digits and Numpad-digits only
	&& (key ~= "^[^Num]" && GetKeyState("NumLock", "T")))
		return
	*/
	; Faster than retrieve key names and regex-compare
	if !({ 0xC0020001:1, 0xC0030001:2, 0xC0040001:3, 0xC0050001:4, 0xC0060001:5, 0xC0070001:6, 0xC0080001:7, 0xC0090001:8, 0xC00A0001:9, 0xC00B0001:"zero" }[lParam])
	&& !({ 0xC0470001:7, 0xC0480001:8, 0xC0490001:9, 0xC04B0001:4, 0xC04C0001:5, 0xC04D0001:6, 0xC04F0001:1, 0xC0500001:2, 0xC0510001:3, 0xC0520001:"zero" }[lParam] && GetKeyState("NumLock", "T"))
		return ; if not Digits or Numpad numbers with NumLock enabled

	controlId := GuiControls[hWnd]
	GuiControlGet value,, % controlId
	if !StrLen(value)
		return
	pin[controlId] := value
	if (pin.Count() = size)
	{
		Sleep 250
		Gui Pin:Submit
		Gui Pin:Destroy
	}
	else
		Send {Tab}
}


PinGuiClose:
PinGuiEscape:
	Gui Pin:Destroy
return
