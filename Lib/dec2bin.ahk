
dec2bin(Num)
{
	out := ""
	while Num
	{
		out := (1 & Num) out
		Num >>= 1
	}
	return out
}
