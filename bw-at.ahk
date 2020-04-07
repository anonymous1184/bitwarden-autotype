; File: UTF-8 no BOM
; Style: Allman + OTBS

#NoEnv
#SingleInstance, force

; Versioning: YY.MM.DD.build
;@Ahk2Exe-SetVersion 20.03.24.1

; Defaults
ListLines, Off
DetectHiddenWindows, On
SetWorkingDir, % A_ScriptDir

; Environment
global bwCli   := ""
    , oathtool := ""
    , iniFname := ""
    , isLocked := ""
    , isLogged := ""
    , atFields := []
    , atWTitle := "Bitwarden Auto-Type"

; Same-name config file
SplitPath, A_ScriptFullPath,,,, iniFname
iniFname .= ".ini"

; Bitwarden CLI path
bwCli := A_ScriptDir "\bw.exe"
if (!FileExist(bwCli))
{
    IniRead, bwCli, % iniFname, GENERAL, bw
}
if (err := checkExe(bwCli, "1.9.0"))
{
    MsgBox, 0x2010, % atWTitle, % "Bitwarden CLI " err
    ExitApp
}
bwCli .= " --nointeraction"

; oathtool
IniRead, oathtool, % iniFname, GENERAL, oathtool
if (err := checkExe(oathtool))
{
    oathtool := false
}

; Matching mode
IniRead, titleMatching, % iniFname, GENERAL, mode
if titleMatching not in 1,2,3,RegEx
{
    titleMatching := 2
}
SetTitleMatchMode, % titleMatching

; Auto-lock
IniRead, atAutoLock, % iniFname, GENERAL, autolock
if atAutoLock in 1,true
{
    IniRead, atIdleTime, % iniFname, GENERAL, idletime
    atIdleTime := toMs(atIdleTime)
    if (atIdleTime)
    {
        SetTimer, autoLock, % 60 * 1000
    }
    else
    {
        MsgBox, 0x2010, % atWTitle, Invalid idle time.
        ExitApp
    }
}

; Hotkeys
IniRead, hk1, % iniFname, HOTKEYS, default, 0
IniRead, hk2, % iniFname, HOTKEYS, password, 0
if ((!hk1 || hk1 = "ERROR") && (!hk2 || hk2 = "ERROR"))
{
    MsgBox, 0x2010, % atWTitle, No hotkeys provided.
    ExitApp
}
if (hk1)
{
    IniRead, sequenceDefault, % iniFname, AUTOTYPE, default
    if (!sequenceDefault || sequenceDefault = "ERROR")
    {
        MsgBox, 0x2010, % atWTitle, No "default" sequence.
        ExitApp
    }
    autoTypeDefault := Func("autoType").Bind(sequenceDefault)
    Hotkey, % hk1, % autoTypeDefault, UseErrorLevel
    if (ErrorLevel)
    {
        MsgBox, 0x2010, % atWTitle, Invalid "default" hotkey.
        ExitApp
    }
}
if (hk2)
{
    IniRead, sequencePassword, % iniFname, AUTOTYPE, password
    if (!sequencePassword || sequencePassword = "ERROR")
    {
        MsgBox, 0x2010, % atWTitle, No "password" sequence.
        ExitApp
    }
    autoTypePassword := Func("autoType").Bind(sequencePassword)
    Hotkey, % hk2, % autoTypePassword, UseErrorLevel
    if (ErrorLevel)
    {
        MsgBox, 0x2010, % atWTitle, Invalid "password" hotkey.
        ExitApp
    }
}

; Custom sequence field
IniRead, sequenceField, % iniFname, AUTOTYPE, field

; Tray menu
Menu, Tray, NoStandard
Menu, Tray, Icon, imageres.dll, 225
Menu, Tray, Tip, Bitwarden Auto-Type
Menu, Tray, Add, &Sync, sync
Menu, Tray, Add, Loc&k, toggleLock
Menu, Tray, Add, &Logout, toggleLogin
Menu, Tray, Add
Menu, Tray, Add, &Exit, bye

; Cleanup
bw("logout", 1)

login()

return

autoLock()
{
    global atIdleTime
    if (A_TimeIdlePhysical >= atIdleTime && !isLocked)
    {
        bw("lock", 1)
        TrayTip, % atWTitle, Inactivity lock, 10, 0x20
        Menu, Tray, Rename, Loc&k, Unloc&k
        isLocked := 1
    }
}

autoType(sequence)
{
    if (!isLogged || isLocked)
    {
        return
    }
    active := WinExist("A")
    for k,field in atFields
    {
        ; by .exe name
        if (SubStr(field.uri, -3) = ".exe")
        {
            WinGet, match, ProcessName, % "ahk_id " active
            match := (match = field.uri)
        }
        else ; by Window properties
        {
            if (RegExMatch(field.uri, "title=(.+)", match))
            {
                WinGet, match, ID, % match1
            }
            else if (RegExMatch(field.uri, "class=(.+)", match))
            {
                WinGet, match, ID, % "ahk_class " match1
            }
            else ; Title in plain form
            {
                WinGet, match, ID, % field.uri
            }
            match := (match = active)
        }

        if (match)
        {
            sequence := (field.sequence ? field.sequence : sequence)
            sequence := StrReplace(sequence, "%username%", field.username)
            sequence := StrReplace(sequence, "%password%", field.password)
            Send, % sequence
            if (oathtool && field.totp)
            {
                totp(field.totp)
            }
            return ; Stop at first match
        }
    }
}

bw(params, quick := 0)
{
    if (quick)
    {
        RunWait, % bwCli " " params,, Hide UseErrorLevel
        return
    }
    Run, % A_ComSpec,, Hide, cmdPid
    WinWait, % "ahk_pid " cmdPid
    DllCall("AttachConsole", "UInt",cmdPid)
    objShell := ComObjCreate("WScript.Shell")
    objExec := objShell.Exec(bwCli " " params)
    out := objExec.StdOut.ReadAll()
    if (!out)
    {
        err := objExec.StdErr.ReadAll()
        MsgBox, 0x2010, % atWTitle, There was an error:`n`n%err%
        ExitApp
    }
    DllCall("FreeConsole")
    Process Close, % cmdPid
    return out
}

bye()
{
    ExitApp
}

checkExe(path, version := 0)
{
    attribs := FileExist(path)
    if (InStr(attribs, "D") || SubStr(path, -3) != ".exe")
    {
        return "not an executable"
    }

    FileGetVersion, exeVersion, % path
    if (version && !checkVersion(exeVersion, version))
    {
        return "incompatible version"
    }

    return false
}

checkVersion(base, required)
{
    base := StrSplit(base, ".")
    required := StrSplit(required, ".")
    for i,n in required
    {
        n += 0
        base[i] += 0
        if (base[i] > n)
        {
            return true
        }
        else if (base[i] < n)
        {
            return false
        }
    }
    return false
}

login()
{
    ; Credentials
    IniRead, bwUser, % iniFname, CREDENTIALS, user
    InputBox, bwPass, % atWTitle, Master Password, HIDE, 250, 125
    if (ErrorLevel)
    {
        ExitApp
    }
    login := "login " bwUser " " bwPass

    ; OTP
    IniRead, bwOTP, % iniFname, CREDENTIALS, otp, no
    if bwOTP in A,E,Y
    {
        if (bwOTP = "E")
        {
            ; Trigger email
            bw(login " --method 1", 1)
        }
        InputBox, bwOTPcode, % atWTitle, Two-step Login,, 250, 125
        if (ErrorLevel)
        {
            ExitApp
        }
        methods := {A: "0", E: "1", Y: "3"}
        login .= " --method " methods[bwOTP] " --code " bwOTPcode
    }

    ; Store session
    EnvSet, BW_SESSION, % bw(login " --raw")
    isLogged := 1
    isLocked := 0

    ; init
    parseItems()

    ; Acknowledge
    TrayTip, % atWTitle, Auto-Type ready, 10, 0x20
}

parseItems()
{
    global sequenceField

    items := bw("list items")
    items := Jxon_Load(items)

    atFields := []
    for i,item in items
    {
        ; Logins
        if (item.type = 1)
        {
            uri := item.login.uris[1].uri
            if (RegExMatch(uri, "^(win)?app://(.+)", match))
            {
                atFields[i] := { uri: match2
                    , totp: item.login.totp
                    , username: item.login.username
                    , password: item.login.password }
                ; Custom sequence
                for j,field in item.fields
                {
                    if (field.name = sequenceField)
                    {
                        atFields[i]["sequence"] := field.value
                    }
                }
            }
        }
    }
}

sync()
{
    if (!isLogged)
    {
        MsgBox, 0x2010, % atWTitle, Login first.
        return
    }
    if (isLocked)
    {
        MsgBox, 0x2010, % atWTitle, Vault locked.
        return
    }
    bw("sync")
    parseItems()
    TrayTip, % atWTitle, Sync complete, 10, 0x20
}

totp(key)
{
    ; Only key URI scheme is recognized
    ; https://github.com/bitwarden/jslib/blob/master/src/services/totp.service.ts#L25
    if (SubStr(key, 1, 14) = "otpauth://totp")
    {
        params := "--base32 --totp"
        if (RegExMatch(key, "algorithm=(\w+)", match))
        {
            params .= Format("={:l}", match1)
        }
        if (RegExMatch(key, "secret=(\w+)", match))
        {
            params .= " " match1
        }
        else ; Invalid, no secret
        {
            return
        }
        if (RegExMatch(key, "period=(\d+)", match))
        {
            params .= " --time-step-size=" match1
        }
        if (RegExMatch(key, "digits=(\d+)", match))
        {
            params .= " --digits=" match1
        }
        RunWait, % A_ComSpec " /c " oathtool " " params " | clip",, Hide UseErrorLevel
        Clipboard := RTrim(Clipboard, "`r`n")
    }
}

toggleLock()
{
    if (!isLogged)
    {
        MsgBox, 0x2010, % atWTitle, Login first.
        return
    }
    if (isLocked)
    {
        InputBox, bwPass, % atWTitle, Master Password, HIDE, 250, 125
        if (ErrorLevel)
        {
            ExitApp
        }
        EnvSet, BW_SESSION, % bw("unlock " bwPass " --raw")
        TrayTip, % atWTitle, Vault unlocked, 10, 0x20
        Menu, Tray, Rename, Unloc&k, Loc&k
        isLocked := 0
    }
    else
    {
        bw("lock", 1)
        TrayTip, % atWTitle, Vault locked, 10, 0x20
        Menu, Tray, Rename, Loc&k, Unloc&k
        isLocked := 1
    }
}

toggleLogin()
{
    if (isLogged)
    {
        bw("logout", 1)
        TrayTip, % atWTitle, Logged out, 10, 0x20
        Menu, Tray, Rename, &Logout, &Login
        isLogged := 0
    }
    else
    {
        login()
        Menu, Tray, Rename, &Login, &Logout
    }
}

toMs(str)
{
    mult := 0
    r := SubStr(str, 0)
    l := SubStr(str, 1, -1)
    if (r = "m")
    {
        mult := 1000 * 60
    }
    else if (r = "h")
    {
        mult := 1000 * 60 * 60
    }
    return (l * mult)
}

/**
 * From JSON lib for AutoHotkey
 * https://github.com/cocobelgica/AutoHotkey-JSON
*/
Jxon_Load(ByRef src, args*)
{
    static q := Chr(34)

    key := "", is_key := false
    stack := [ tree := [] ]
    is_arr := { (tree): 1 }
    next := q . "{[01234567890-tfn"
    pos := 0
    while ( (ch := SubStr(src, ++pos, 1)) != "" )
    {
        if InStr(" `t`n`r", ch)
            continue
        if !InStr(next, ch, true)
        {
            ln := ObjLength(StrSplit(SubStr(src, 1, pos), "`n"))
            col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

            msg := Format("{}: line {} col {} (char {})"
            ,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
              : (next == "'")     ? "Unterminated string starting at"
              : (next == "\")     ? "Invalid \escape"
              : (next == ":")     ? "Expecting ':' delimiter"
              : (next == q)       ? "Expecting object key enclosed in double quotes"
              : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
              : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
              : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
              : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
                , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
            , ln, col, pos)

            throw Exception(msg, -1, ch)
        }

        is_array := is_arr[obj := stack[1]]

        if i := InStr("{[", ch)
        {
            val := (proto := args[i]) ? new proto : {}
            is_array? ObjPush(obj, val) : obj[key] := val
            ObjInsertAt(stack, 1, val)

            is_arr[val] := !(is_key := ch == "{")
            next := q . (is_key ? "}" : "{[]0123456789-tfn")
        }

        else if InStr("}]", ch)
        {
            ObjRemoveAt(stack, 1)
            next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
        }

        else if InStr(",:", ch)
        {
            is_key := (!is_array && ch == ",")
            next := is_key ? q : q . "{[0123456789-tfn"
        }

        else ; string | number | true | false | null
        {
            if (ch == q) ; string
            {
                i := pos
                while i := InStr(src, q,, i+1)
                {
                    val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
                    static end := A_AhkVersion<"2" ? 0 : -1
                    if (SubStr(val, end) != "\")
                        break
                }
                if !i ? (pos--, next := "'") : 0
                    continue

                pos := i ; update pos

                  val := StrReplace(val,    "\/",  "/")
                , val := StrReplace(val, "\" . q,    q)
                , val := StrReplace(val,    "\b", "`b")
                , val := StrReplace(val,    "\f", "`f")
                , val := StrReplace(val,    "\n", "`n")
                , val := StrReplace(val,    "\r", "`r")
                , val := StrReplace(val,    "\t", "`t")

                i := 0
                while i := InStr(val, "\",, i+1)
                {
                    if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                        continue 2

                    ; \uXXXX - JSON unicode escape sequence
                    xxxx := Abs("0x" . SubStr(val, i+2, 4))
                    if (A_IsUnicode || xxxx < 0x100)
                        val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
                }

                if is_key
                {
                    key := val, next := ":"
                    continue
                }
            }

            else ; number | true | false | null
            {
                val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)

            ; For numerical values, numerify integers and keep floats as is.
            ; I'm not yet sure if I should numerify floats in v2.0-a ...
                static number := "number", integer := "integer"
                if val is %number%
                {
                    if val is %integer%
                        val += 0
                }
            ; in v1.1, true,false,A_PtrSize,A_IsUnicode,A_Index,A_EventInfo,
            ; SOMETIMES return strings due to certain optimizations. Since it
            ; is just 'SOMETIMES', numerify to be consistent w/ v2.0-a
                else if (val == "true" || val == "false")
                    val := %val% + 0
            ; AHK_H has built-in null, can't do 'val := %value%' where value == "null"
            ; as it would raise an exception in AHK_H(overriding built-in var)
                else if (val == "null")
                    val := ""
            ; any other values are invalid, continue to trigger error
                else if (pos--, next := "#")
                    continue

                pos += i-1
            }

            is_array? ObjPush(obj, val) : obj[key] := val
            next := obj==tree ? "" : is_array ? ",]" : ",}"
        }
    }

    return tree[1]
}
