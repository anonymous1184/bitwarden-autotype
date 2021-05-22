
loadIni(file)
{
    obj := {}
    IniRead sections, % file
    loop parse, sections, `n, `r
    {
        sect := A_LoopField
        IniRead conts, % file, % sect
        loop parse, conts, `n, `r
            parts := StrSplit(A_LoopField, "=", "`t ", 2)
            , obj[sect, parts[1]] := parts[2]
    }
    return obj
}
