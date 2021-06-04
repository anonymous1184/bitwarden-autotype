
checkVersion(base, main)
{
    base := StrSplit(base, ".")
    main := StrSplit(main, ".")
    loop % main.Count()
    {
        nBase := Format("{:d}", base[A_Index])
        nMain := Format("{:d}", main[A_Index])
        if (nBase > nMain)
            return true
        if (nBase < nMain)
            return false
    }
    return true
}
