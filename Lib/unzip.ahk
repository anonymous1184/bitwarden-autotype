
unzip(zipFile, destination := "")
{
    loop files, % zipFile
        zipFile := A_LoopFileLongPath
    if !destination
        SplitPath zipFile,, destination
    else
    {
        if !attr := FileExist(destination)
            FileCreateDir % destination
        else if !InStr(attr, "D")
            throw Exception("Destination not a directory", -1)
        loop files, % destination
            destination := A_LoopFileLongPath
    }
    shell := ComObjCreate("Shell.Application")
    items := shell.Namespace(zipFile).Items
    shell.Namespace(destination).CopyHere(items, 4|16)
}
