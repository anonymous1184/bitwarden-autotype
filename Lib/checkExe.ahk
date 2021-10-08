
CheckExe(Path, Version := "")
{
	attribs := FileExist(Path)
	if (!attribs)
		return "file not found"

	if (InStr(attribs, "D") || SubStr(Path, -3) != ".exe")
		return "not an executable"

	FileGetVersion exeVersion, % Path
	if (!exeVersion)
		return "couldn't get version"

	if !CheckVersion(exeVersion, Version)
		return "incompatible version"
}
