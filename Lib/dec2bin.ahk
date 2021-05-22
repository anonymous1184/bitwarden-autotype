
dec2bin(n)
{
    r := ""
    while n
        r := 1 & n r
        , n >>= 1
    return r
}
