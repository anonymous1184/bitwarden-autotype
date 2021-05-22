
passwdGen(with, ByRef entropy)
{
    out := from := ""
    if with.lower
        from .= "abcdefghijklmnopqrstuvwxyz"
    if with.upper
        from .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if with.digits
        from .= "0123456789"
    if with.symbols
        from .= "!""#$%&'()*+,-./:;<=>?@[\]^_``{|}~"
    StringCaseSense On
    loop parse, % with.exclude
        from := StrReplace(from, A_LoopField)
    StringCaseSense Off
    dict := StrLen(from)
    from := StrSplit(from)
    loop % with.length
    {
        Random rnd, 1, % dict
        out .= from[rnd]
    }
    return out, entropy := entropy(dict, with.length)
}
