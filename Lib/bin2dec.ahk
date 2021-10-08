
bin2dec(Num)
{
	out := 0
	len := StrLen(Num)
	loop parse, Num
		out |= A_LoopField << --len
	return out
}
