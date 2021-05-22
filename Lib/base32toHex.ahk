
base32toHex(base32)
{
    static b32dict := "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    bits := hex := "" ;, base32 := RTrim(base32, "=")

    Loop parse, base32
        val := InStr(b32dict, A_LoopField) - 1
        , bits .= Format("{:05}", dec2bin(val))

    loop % StrLen(bits) / 4
        start := 1 + A_Index * 4 - 4
        , chunk := SubStr(bits, start, 4)
        , hex .= Format("{:x}", bin2dec(chunk))

    return hex .= Mod(StrLen(hex), 2) ? 0 : ""
}
