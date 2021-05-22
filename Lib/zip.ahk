
zip(archive, files*)
{
    if !FileExist(archive)
        VarSetCapacity(zHeader, 18, 0)
        , file := FileOpen(archive, 0x1)
        , file.Write("PK" Chr(5) Chr(6))
        , file.RawWrite(zHeader, 18)
        , file.Close()
    loop files, % archive
        archive := A_LoopFileLongPath
    shell := ComObjCreate("Shell.Application").Namespace(archive)
    for i,file in files
    {
        total := shell.items().Count, filter := "F"
        if isDir := InStr(FileExist(file), "D")
            file .= RTrim(file, "\") "\*", filter .= "R"
        loop files, % file, % filter
        {
            total++
            shell.CopyHere(A_LoopFileLongPath, 4|16)
            while shell.items().Count != total
                Sleep 10
        }
    }
}
