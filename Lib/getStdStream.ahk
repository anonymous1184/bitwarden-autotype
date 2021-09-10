
getStdStream(CommandLine, Environment := "")
{
    DllCall("Kernel32\CreatePipe", "Ptr*",hPipeRead := "", "Ptr*",hPipeWrite := "", "Ptr",0, "Ptr",0)
    DllCall("Kernel32\SetHandleInformation", "Ptr",hPipeWrite, "Ptr",0x00000001, "Ptr",0x00000001) ; HANDLE_FLAG_INHERIT
    DllCall("Kernel32\SetNamedPipeHandleState", "Ptr",hPipeRead, "Ptr",0x00000001, "Ptr",0, "Ptr",0) ; PIPE_NOWAIT

    VarSetCapacity(lpStartupInfo,       104, 0)
    VarSetCapacity(lpProcessInformation, 24, 0)
    NumPut(104       , lpStartupInfo)     ; STARTUPINFO size
    NumPut(0x100     , lpStartupInfo, 60) ; dwFlags = STARTF_USESTDHANDLES
    NumPut(hPipeWrite, lpStartupInfo, 88) ; hStdOutput
    NumPut(hPipeWrite, lpStartupInfo, 96) ; hStdError

    lpEnvironment := 0
    if IsObject(Environment)
    {
        n := 0, size := 0
        for var,val in Environment
            size += StrLen(var "=" val)
        VarSetCapacity(buffer, size * 2, 0)
        for var,val in Environment
            n += StrPut(var "=" val, &buffer + n, "CP1252")
        lpEnvironment := &buffer
    }

    ret := DllCall("Kernel32\CreateProcess"
        , "Ptr",0
        , "Ptr",&CommandLine
        , "Ptr",0
        , "Ptr",0
        , "Ptr",true
        , "Ptr",0x08000000|0x00000080 ; CREATE_NO_WINDOW|HIGH_PRIORITY_CLASS
        , "Ptr",lpEnvironment
        , "Ptr",0
        , "Ptr",&lpStartupInfo
        , "Ptr",&lpProcessInformation)
    err := A_LastError
    DllCall("Kernel32\CloseHandle", "Ptr",hPipeWrite)

    if !ret
    {
        DllCall("Kernel32\CloseHandle", "Ptr",hPipeRead)
        return "Cannot create process: " err, ErrorLevel := -1
    }

    output := ""
    buffer := FileOpen(hPipeRead, "h", "UTF-8")
    while line := buffer.ReadLine()
        output .= line
    DllCall("Kernel32\CloseHandle", "Ptr",hPipeRead)

    hThread := NumGet(lpProcessInformation, A_PtrSize)
    DllCall("Kernel32\CloseHandle", "Ptr",hThread)

    hProcess := NumGet(lpProcessInformation, 0)
    DllCall("Kernel32\GetExitCodeProcess", "Ptr",hProcess, "Ptr*",exitCode := "")
    DllCall("Kernel32\CloseHandle", "Ptr",hProcess)

    return output, ErrorLevel := exitCode
}
