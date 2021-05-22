
bw(params)
{
    global bwCli
    hPipeRead := hPipeWrite := "", cmd := bwCli " " params
        , DllCall("Kernel32\CreatePipe", "UInt*",hPipeRead, "UInt*",hPipeWrite, "UInt",0, "UInt",0)
        , DllCall("Kernel32\SetHandleInformation", "UInt",hPipeWrite, "UInt",1, "UInt",1)
        , VarSetCapacity(STARTUPINFO, 104, 0)
        , NumPut(68, STARTUPINFO, 0)
        , NumPut(256, STARTUPINFO, 60)
        , NumPut(hPipeWrite, STARTUPINFO, 88)
        , NumPut(hPipeWrite, STARTUPINFO, 96)
        , VarSetCapacity(PROCESS_INFORMATION, 32)
    ;TODO: use lpEnvironment
    EnvSet BW_SESSION, % SESSION
    DllCall("Kernel32\CreateProcess", "UInt",0, "UInt",&cmd, "UInt",0, "UInt",0, "UInt",1, "UInt",0x08000000, "UInt",0, "UInt",0, "UInt",&STARTUPINFO, "UInt",&PROCESS_INFORMATION)
    EnvSet BW_SESSION
    hProcess := NumGet(PROCESS_INFORMATION, 0)
        , hThread := NumGet(PROCESS_INFORMATION, 8)
        , DllCall("Kernel32\CloseHandle", "UInt",hPipeWrite)
        , VarSetCapacity(buffer, 4096, 0)
        , exitCode := out := size := ""
    while DllCall("Kernel32\ReadFile", "UInt",hPipeRead, "UInt",&buffer, "UInt",4096, "UInt*",size, "Int",0)
        out .= StrGet(&buffer, size, "CP0")
    return out
        , DllCall("Kernel32\GetExitCodeProcess", "UInt",hProcess, "UInt*",exitCode)
        , DllCall("Kernel32\CloseHandle", "UInt",hProcess)
        , DllCall("Kernel32\CloseHandle", "UInt",hThread)
        , DllCall("Kernel32\CloseHandle", "UInt",hPipeRead)
        , VarSetCapacity(STARTUPINFO, 0)
        , VarSetCapacity(PROCESS_INFORMATION, 0)
        , ErrorLevel := exitCode
}
