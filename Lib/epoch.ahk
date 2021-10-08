
Epoch(Timestamp := "")
{
	epoch := (Timestamp ? Timestamp : A_NowUTC)
	epoch -= 19700101000000, Seconds
	return epoch
}

; Default to `FullDateTime`
Epoch_Date(Epoch, Format := "dddd, MMMM dd, yyyy h:mm:ss tt")
{
	timestamp := 19700101000000
	timestamp += Epoch, Seconds
	FormatTime str, % timestamp, % Format
	return str
}
