
Base32_Hex(Base32)
{
	dict := "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

	bin := ""
	loop parse, % RTrim(Base32, "=")
	{
		pos := InStr(dict, A_LoopField)
		if (pos = 0)
			return
		bin .= Format("{:05}", dec2bin(pos - 1))
	}

	hex := ""
	loop % StrLen(bin) / 4
	{
		start := A_Index * 4 - 3
		chunk := SubStr(bin, start, 4)
		hex .= Format("{:x}", bin2dec(chunk))
	}

	if Mod(StrLen(hex), 2)
		hex .= 0

	return hex
}

Base32_Rand()
{
	dict := StrSplit("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
	rand := ""
	loop 8
	{
		Random r, 1, dict.Count()
		rand .= dict.RemoveAt(r)
	}
	return rand
}
