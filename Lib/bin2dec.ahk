
bin2dec(n)
{
    r := 0
    , b := StrLen(n)
    loop parse, n
        r |= A_LoopField << --b
    return r
}
