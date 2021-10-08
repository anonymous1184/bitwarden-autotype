
Zip(Archive, Files*)
{
	if !FileExist(Archive)
	{
		VarSetCapacity(zHeader, 18, 0)
		file := FileOpen(Archive, 0x1)
		file.Write("PK" Chr(5) Chr(6))
		file.RawWrite(zHeader, 18)
		file.Close()
	}
	Archive := Zip_LongPath(Archive)
	shell := ComObjCreate("Shell.Application").Namespace(Archive)
	for _,file in Files
		Zip_AddFile(Archive, file, shell)
}

Zip_AddFile(Archive, File, Shell := "")
{
	if (!Shell)
	{
		Archive := Zip_LongPath(Archive)
		Shell := ComObjCreate("Shell.Application").Namespace(Archive)
	}
	mode := "F"
	isDir := InStr(FileExist(File), "D")
	if (isDir)
	{
		File .= RTrim(File, "\") "\*"
		mode .= "R"
	}
	loop files, % File, % mode
	{
		newCount := Shell.items().Count + 1
		Shell.CopyHere(A_LoopFileLongPath, 4 | 16)
		while (Shell.items().Count != newCount)
			Sleep 15
	}
}

Zip_Extract(Archive, Destination := "")
{
	Archive := Zip_LongPath(Archive)
	if (!Destination)
		SplitPath Archive,, Destination
	else
	{
		attr := FileExist(Destination)
		if (!attr)
			FileCreateDir % Destination
		else if !InStr(attr, "D")
			throw Exception("Destination not a directory", -1)
		Destination := Zip_LongPath(Destination)
	}
	shell := ComObjCreate("Shell.Application")
	items := shell.Namespace(Archive).Items
	shell.Namespace(Destination).CopyHere(items, 4 | 16)
}

Zip_LongPath(Path)
{
	loop files, % Path, DF
		return A_LoopFileLongPath
}
