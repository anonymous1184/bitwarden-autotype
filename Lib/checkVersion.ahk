
checkVersion(base, required)
{
    base := StrSplit(base, ".")
    required := StrSplit(required, ".")
    for i,part in required
    {
        part := Format("{:d}", part)
        base[i] := Format("{:d}", base[i])
        if (base[i] < part)
            return false
    }
    return true
}
