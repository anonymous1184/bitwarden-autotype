
ExitApp(Parameters*)
{
	if (Parameters.Count() > 1)
		code := 0
	else
		code := Parameters[1]
	ExitApp % code
}
