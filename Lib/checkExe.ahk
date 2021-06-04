
checkExe(path, version := "")
{
    if !attribs := FileExist(path)
        return "file not found"

    if InStr(attribs, "D") || SubStr(path, -3) != ".exe"
        return "not an executable"

    FileGetVersion exeVersion, % path
    if !exeVersion
        return "couldn't get version"

    if !checkVersion(exeVersion, version)
        return "incompatible version"
}
