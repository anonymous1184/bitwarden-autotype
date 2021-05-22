
; Improved Core of the Acc.ahk Standard Library
; http://autohotkey.com/board/topic/77303-/?p=491516
; https://gist.github.com/tmplinshi/2d3a1deb693e72789d8f

Acc_ObjectFromWindow(hWnd, idObject := -4)
{
	static h := DllCall("Kernel32\LoadLibrary", "Str","oleacc.dll", "Ptr")
    pAcc := ""
	if !DllCall("oleacc\AccessibleObjectFromWindow"
            , "Ptr" ,hWnd
            , "UInt",idObject &= 0xFFFFFFFF
            , "Ptr" ,-VarSetCapacity(IID, 16) + NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64"), "Int64")
            , "Ptr*",pAcc)
        return ComObjEnwrap(9, pAcc, 1)
}

Acc_Children(Acc)
{
    static procAddr := DllCall("Kernel32\GetProcAddress"
        , "Ptr" ,DllCall("Kernel32\GetModuleHandle", "Str","oleacc.dll", "Ptr")
        , "AStr","AccessibleChildren"
        , "Ptr" )
	if ComObjType(Acc, "Name") != "IAccessible"
		throw Exception("Invalid IAccessible Object", -1)
    children := []
    cChildren := Acc.accChildCount
    VarSetCapacity(varChildren, cChildren * (8 + 2 * A_PtrSize), 0)
    if DllCall(procAddr
        , "Ptr" ,ComObjValue(Acc)
        , "Int" ,0
        , "Int" ,cChildren
        , "Ptr" ,&varChildren
        , "Int*",cChildren)
    throw Exception("AccessibleChildren DllCall Failed", -1)
    loop % cChildren
        i := (A_Index - 1) * (A_PtrSize * 2 + 8) + 8
        , child := NumGet(varChildren, i)
        , children.Insert(NumGet(varChildren, i - 8) = 9 ? Acc_Query(child) : child)
    return children.MaxIndex() ? children : false
}

Acc_Query(Acc)
{
	try return ComObj(9, ComObjQuery(Acc, "{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}
