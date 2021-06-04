
bw(params, pass := "")
{
    global bwCli
    env := {} ; Environment variables for bw.exe
    if INI.ADVANCED.NODE_EXTRA_CA_CERTS
        env.NODE_EXTRA_CA_CERTS := INI.ADVANCED.NODE_EXTRA_CA_CERTS
    env.BITWARDENCLI_APPDATA_DIR := A_WorkingDir
    env.BW_NOINTERACTION := "true"
    if pass
        env.BW_PASS := quote_remove(pass)
    env.BW_RAW := "true"
    if SESSION
        env.BW_SESSION := SESSION
    EnvGet SystemRoot, SystemRoot
    env.SystemRoot := SystemRoot
    return getStdStream(bwCli " " params, env)
}
