
epoch(ts := "")
{
    epoch := (ts ? ts : A_NowUTC)
    epoch -= 19700101000000, Secs
    return epoch
}

epoch_date(epoch, format := "dddd MMMM d, yyyy h:mm:ss tt")
{
    ts := 19700101
    ts += epoch, S
    FormatTime str, % ts, % format
    return str
}
