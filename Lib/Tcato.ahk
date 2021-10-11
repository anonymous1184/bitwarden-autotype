
; Two-Channel Auto-Type Obfuscation
; https://keepass.info/help/v2/autotype_obfuscation.html

Tcato(str, seed := 0, wait := 250, ksps := 10)
{
	clipPart := ""
	sendPart := []
	clipBack := ClipboardAll
	Clipboard := ""
	Random ,, % Format("{:d}", seed)
	loop parse, str
	{
		Random rnd, 0, 1
		if (rnd)
			clipPart .= A_LoopField
		else
			sendPart[A_Index] := A_LoopField
	}
	Clipboard := clipPart
	ClipWait
	Send ^v
	Sleep % wait
	Clipboard := clipBack
	SendInput % "{Left " StrLen(clipPart) "}"
	loop parse, str
	{
		Sleep % 1000 / ksps
		chr := sendPart[A_Index]
		SendInput % StrLen(chr) ? "{Text}" chr : "{Right}"
	}
}

Tcato_Menu()
{
	INI.GENERAL.tcato := !INI.GENERAL.tcato
	Menu sub1, ToggleCheck, 5&
}
