
; Improved version of Acc.ahk
; https://www.autohotkey.com/boards/viewtopic.php?t=26201
; https://gist.github.com/anonymous1184/58d2b141be2608a2f7d03a982e552a71

Acc_Init(function) ; Private
{
    static hModule := DllCall("Kernel32\LoadLibrary", "Str","oleacc.dll", "Ptr")
    return DllCall("Kernel32\GetProcAddress", "Ptr",hModule, "AStr",function, "Ptr")
}

Acc_ObjectFromEvent(ByRef _ChildId_, hWnd, ObjectId, ChildId)
{
    static fn := Acc_Init("AccessibleObjectFromEvent")
    VarSetCapacity(ChildVar, A_PtrSize * 2 + 8, 0)
    if !DllCall(fn, "Ptr",hWnd, "UInt",ObjectId, "UInt",ChildId, "Ptr*",pAcc := 0, "Ptr",&ChildVar)
    {
        _ChildId_ := NumGet(ChildVar, 8, "UInt")
        return ComObjEnwrap(9, pAcc, 1)
    }
}

Acc_ObjectFromPoint(ByRef _ChildId_ := "", x := 0, y := 0)
{
    static fn := Acc_Init("AccessibleObjectFromPoint")
    if (x || y)
        point := x & 0xFFFFFFFF | y << 32
    else
        DllCall("User32\GetCursorPos", "Int64*",point := 0)
    VarSetCapacity(ChildVar, A_PtrSize * 2 + 8, 0)
    if !DllCall(fn, "Int64",point, "Ptr*",pAcc := 0, "Ptr",&ChildVar)
    {
        _ChildId_ := NumGet(ChildVar, 8, "UInt")
        return ComObjEnwrap(9, pAcc, 1)
    }
}

Acc_ObjectFromWindow(hWnd, ObjectId := -4)
{
    static fn := Acc_Init("AccessibleObjectFromWindow")
    ObjectId &= 0xFFFFFFFF
    VarSetCapacity(IID, 16, 0)
    _iid := NumPut(ObjectId = 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID, "Int64")
    riid := NumPut(ObjectId = 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, _iid + 0, "Int64") - 16
    if !DllCall(fn, "Ptr",hWnd, "UInt",ObjectId, "Ptr",riid, "Ptr*",pAcc := 0)
        return ComObjEnwrap(9, pAcc, 1)
}

Acc_WindowFromObject(pAcc)
{
    static fn := Acc_Init("WindowFromAccessibleObject")
    pAcc := IsObject(pAcc) ? ComObjValue(pAcc) : pAcc
    if !DllCall(fn, "Ptr",pAcc, "Ptr*",hWnd := 0)
        return hWnd
}

Acc_GetRoleText(nRole)
{
    static fn := Acc_Init("GetRoleTextW")
    nSize := DllCall(fn, "UInt",nRole, "Ptr",0, "UInt",0)
    VarSetCapacity(sRole, nSize * 2, 0)
    DllCall(fn, "UInt",nRole, "Str",sRole, "UInt",nSize + 1)
    return sRole
}

Acc_GetStateText(nState)
{
    static fn := Acc_Init("GetStateTextW")
    nSize := DllCall(fn, "UInt",nState, "Ptr",0, "UInt",0)
    VarSetCapacity(sState, nSize * 2, 0)
    DllCall(fn, "UInt",nState, "Str",sState, "UInt",nSize + 1)
    return sState
}

Acc_SetWinEventHook(EventMin, EventMax, pCallback)
{
    return DllCall("User32\SetWinEventHook", "Ptr",EventMin, "Ptr",EventMax, "Ptr",0, "Ptr",pCallback, "Ptr",0, "Ptr",0, "Ptr",0)
}

Acc_UnhookWinEvent(hHook)
{
    return DllCall("User32\UnhookWinEvent", "Ptr",hHook)
}

/* Win Events:

    pCallback := RegisterCallback("WinEventProc")
    WinEventProc(hHook, Event, hWnd, ObjectId, ChildId, EventThread, EventTime)
    {
        Critical
        Acc := Acc_ObjectFromEvent(_ChildId_, hWnd, ObjectId, ChildId)
        ; Code Here:

    }

*/

; Written by jethrow

Acc_Role(oAcc, ChildId := 0)
{
    try
        return Acc_GetRoleText(oAcc.accRole(ChildId))
    return "invalid object"
}

Acc_State(oAcc, ChildId := 0)
{
    try
        return Acc_GetStateText(oAcc.accState(ChildId))
    return "invalid object"
}

Acc_Location(oAcc, ChildId := 0, ByRef Position := "")
{
    try
    {
        ; VT_BYREF|VT_I4 = Ptr to 32-bit signed Int
        oAcc.accLocation(ComObj(0x4000 | 3, &x := 0)
                       , ComObj(0x4000 | 3, &y := 0)
                       , ComObj(0x4000 | 3, &w := 0)
                       , ComObj(0x4000 | 3, &h := 0)
                       , ChildId)
        x := NumGet(x, 0, "Int")
        y := NumGet(y, 0, "Int")
        w := NumGet(w, 0, "Int")
        h := NumGet(h, 0, "Int")
        return { "x":x, "y":y, "w":w, "h":h, "pos":Position := "x" x " y" y " w" w " h" h }
    }
}

Acc_Parent(oAcc)
{
    try
    {
        if (oAcc.accParent)
            return Acc_Query(oAcc.accParent)
    }
}

Acc_Child(oAcc, ChildId := 0)
{
    try
    {
        if Child := oAcc.AccChild(ChildId)
            return Acc_Query(Child)
    }
}

Acc_Query(oAcc) ; Private
{
    try return ComObj(9, ComObjQuery(oAcc, "{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
} ; Thanks Lexikos - www.autohotkey.com/forum/viewtopic.php?t=81731&p=509530#509530

Acc_Error(Previous := "") ; Private
{
    static setting := 0
    return Previous = "" ? setting : setting := Previous
}

Acc_Children(oAcc)
{
    static fn := Acc_Init("AccessibleChildren")
    if (ComObjType(oAcc, "Name") != "IAccessible")
        ErrorLevel := "Invalid IAccessible Object"
    else
    {
        ChildrenIn := oAcc.AccChildCount
        VarSetCapacity(ChildrenVar, ChildrenIn * (A_PtrSize * 2 + 8), 0)
        if !DllCall(fn, "Ptr",ComObjValue(oAcc), "Int",0, "Int",ChildrenIn, "Ptr",&ChildrenVar, "Int*",ChildrenOut := "")
        {
            Children := []
            loop % ChildrenOut
            {
                i := (A_Index - 1) * (A_PtrSize * 2 + 8) + 8
                Child := NumGet(ChildrenVar, i)
                isCOM := NumGet(ChildrenVar, i - 8) = 9
                Children.Push(isCOM ? Acc_Query(Child) : Child)
                if (isCOM)
                    ObjRelease(Child)
            }
            return Children.Count() ? Children : false
        }
        else
            ErrorLevel := "AccessibleChildren DllCall Failed"
    }
    if Acc_Error()
        throw Exception(ErrorLevel, -1)
}

Acc_ChildrenByRole(oAcc, RoleText)
{
    static fn := Acc_Init("AccessibleChildren")
    if (ComObjType(oAcc, "Name") != "IAccessible")
        ErrorLevel := "Invalid IAccessible Object"
    else
    {
        ChildrenIn := oAcc.AccChildCount
        VarSetCapacity(ChildrenVar, ChildrenIn * (A_PtrSize * 2 + 8), 0)
        if !DllCall(fn, "Ptr",ComObjValue(oAcc), "Int",0, "Int",ChildrenIn, "Ptr",&ChildrenVar, "Int*",ChildrenOut := "")
        {
            Children := []
            loop % ChildrenOut
            {
                i := (A_Index - 1) * (A_PtrSize * 2 + 8) + 8
                Child := NumGet(ChildrenVar, i)
                if (NumGet(ChildrenVar, i - 8) = 9)
                {
                    AccChild := Acc_Query(Child), ObjRelease(Child)
                    Acc_Role(AccChild) = RoleText ? Children.Push(AccChild) : false
                }
                else
                    Acc_Role(oAcc, Child) = RoleText ? Children.Push(Child) : false
            }
            return Children.Count() ? Children : ErrorLevel := false
        }
        else
            ErrorLevel := "AccessibleChildren DllCall Failed"
    }
    if Acc_Error()
        throw Exception(ErrorLevel, -1)
}

/* Cmd:
    Object
    -
    Child
    ChildCount
    DefaultAction / Action
    Description
    DoDefaultAction / DoAction
    Focus
    Help
    HelpTopic
    HitTest
    KeyboardShortcut / Keyboard
    Location
    Name
    Navigate
    Parent
    Role (Text)
    Select
    Selection
    State (Text)
    Value
*/
Acc_Get(Cmd, ChildPath := "", ChildId := 0, WinTitle := "", WinText := "", ExcludeTitle := "", ExcludeText := "")
{
    static Properties := { Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut" }
    oAcc := IsObject(WinTitle) ? WinTitle : Acc_ObjectFromWindow(WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0)
    if (ComObjType(oAcc, "Name") != "IAccessible")
        ErrorLevel := "Could not access an IAccessible Object"
    else
    {
        ChildPath := StrReplace(ChildPath, "_", " ")
        AccError := Acc_Error(), Acc_Error(true)
        loop parse, ChildPath, ., % A_Space
        {
            try
            {
                if (A_LoopField ~= "^\d+$")
                {
                    Children := Acc_Children(oAcc)
                    m2 := A_LoopField
                }
                else
                {
                    RegExMatch(A_LoopField, "(\D*)(\d*)", m)
                    Children := Acc_ChildrenByRole(oAcc, m1)
                    m2 := (m2 ? m2 : 1)
                }
                if !Children.HasKey(m2)
                    throw
                oAcc := Children[m2]
            }
            catch
            {
                ErrorLevel := "Cannot access ChildPath Item #" A_Index " -> " A_LoopField
                Acc_Error(AccError)
                if Acc_Error()
                    throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
                return
            }
        }
        Acc_Error(AccError)
        Cmd := StrReplace(Cmd, " ")
        Properties.HasKey(Cmd) ? Cmd := Properties[Cmd] : false
        try
        {
            if (Cmd = "Location")
            {
                ; VT_BYREF|VT_I4 = Ptr to 32-bit signed Int
                oAcc.accLocation(ComObj(0x4000 | 3, &x := 0)
                               , ComObj(0x4000 | 3, &y := 0)
                               , ComObj(0x4000 | 3, &w := 0)
                               , ComObj(0x4000 | 3, &h := 0)
                               , ChildId)
                out := "x" NumGet(x, 0, "Int") " "
                     . "y" NumGet(y, 0, "Int") " "
                     . "w" NumGet(w, 0, "Int") " "
                     . "h" NumGet(h, 0, "Int")
            }
            else if (Cmd = "Object")
                out := oAcc
            else if (Cmd ~= "i)Role|State") ; Both return text
                out := Func("Acc_" Cmd).Call(oAcc, ChildId + 0)
            else if (Cmd ~= "i)ChildCount|Selection|Focus")
                out := oAcc["acc" Cmd]
            else
                out := oAcc["acc" Cmd](ChildId + 0)
        }
        catch
        {
            ErrorLevel := "<" Cmd "> Command not implemented"
            if Acc_Error()
                throw Exception("Command not implemented", -1, Cmd)
            return
        }
        ErrorLevel := false
        return out
    }
    if Acc_Error()
        throw Exception(ErrorLevel, -1)
}
