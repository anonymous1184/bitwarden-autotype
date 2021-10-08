
CheckVersion(Current, Minimal)
{
	Current := StrSplit(Current, ".")
	Minimal := StrSplit(Minimal, ".")
	loop % Minimal.Count()
	{
		c := Format("{:d}", Current[A_Index])
		m := Format("{:d}", Minimal[A_Index])
		if (c = m)
			continue
		return (c > m)
	}
	return true
}
