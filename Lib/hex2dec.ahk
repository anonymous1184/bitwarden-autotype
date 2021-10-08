
hex2dec(Hex)
{
	Hex := LTrim(Hex, "0x")
	return Format("{:d}", "0x" Hex)
}
