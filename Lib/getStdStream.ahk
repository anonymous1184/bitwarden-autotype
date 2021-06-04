
getStdStream(lpCommandLine, oEnvironment := "")
{
    hPipeRead := hPipeWrite := output := ""
    DllCall("Kernel32\CreatePipe", "Ptr*",hPipeRead, "Ptr*",hPipeWrite, "Ptr",0, "Ptr",0)
    DllCall("Kernel32\SetHandleInformation", "Ptr",hPipeWrite, "Ptr",0x00000001, "Ptr",0x00000001) ; HANDLE_FLAG_INHERIT
    DllCall("Kernel32\SetNamedPipeHandleState", "Ptr",hPipeRead, "Ptr",0x00000001, "Ptr",0, "Ptr",0) ; PIPE_NOWAIT

    VarSetCapacity(lpStartupInfo,       104)
    VarSetCapacity(lpProcessInformation, 24)
    NumPut(0x100     , lpStartupInfo, 60) ; dwFlags = STARTF_USESTDHANDLES
    NumPut(hPipeWrite, lpStartupInfo, 88) ; hStdOutput
    NumPut(hPipeWrite, lpStartupInfo, 96) ; hStdError

    lpEnvironment := 0
    if IsObject(oEnvironment)
    {
        n := 0, size := 0
        for var,val in oEnvironment
            size += StrLen(var "=" val)
        buffer:=""
        VarSetCapacity(buffer, size)
        for var,val in oEnvironment
            n += StrPut(var "=" val, &buffer + n, "CP0")
        lpEnvironment := &buffer
    }

    if !DllCall("Kernel32\CreateProcess"
            , "Ptr",0
            , "Ptr",&lpCommandLine
            , "Ptr",0
            , "Ptr",0
            , "Ptr",true
            , "Ptr",0x08000000|0x00000080 ; CREATE_NO_WINDOW|HIGH_PRIORITY_CLASS
            , "Ptr",lpEnvironment
            , "Ptr",0
            , "Ptr",&lpStartupInfo
            , "Ptr",&lpProcessInformation), DllCall("Kernel32\CloseHandle", "Ptr",hPipeWrite)
        return "Couldn't run", DllCall("Kernel32\CloseHandle", "Ptr",hPipeRead), ErrorLevel := -1

    buffer := FileOpen(hPipeRead, "h", "UTF-8")
    while line := buffer.ReadLine()
        output .= line

    return output
        , DllCall("Kernel32\GetExitCodeProcess", "Ptr",NumGet(lpProcessInformation), "Ptr*",ErrorLevel)
}
