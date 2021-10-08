
; Improved version of Acc.ahk
; https://gist.github.com/anonymous1184/58d2b141be2608a2f7d03a982e552a71

; Original:
; https://www.autohotkey.com/boards/viewtopic.php?t=26201

Acc_Init(Function) ; Private
{
	; Kernel32\LoadLibrary, Kernel32\GetProcAddress
	static hModule := DllCall("LoadLibrary", "Str","oleacc.dll", "Ptr")
	return DllCall("GetProcAddress", "Ptr",hModule, "AStr",Function, "Ptr")
}

Acc_ObjectFromEvent(ByRef _ChildId_, hWnd, ObjectId, ChildId)
{
	static address := Acc_Init("AccessibleObjectFromEvent")

	pAcc := 0
	VarSetCapacity(varChild, A_PtrSize * 2 + 8, 0)
	hResult := DllCall(address, "Ptr",hWnd, "UInt",ObjectId, "UInt",ChildId
		, "Ptr*",pAcc, "Ptr",&varChild)
	if (!hResult)
	{
		_ChildId_ := NumGet(varChild, 8, "UInt")
		return ComObj(9, pAcc, 1)
	}
}

Acc_ObjectFromPoint(ByRef _ChildId_ := "", x := 0, y := 0)
{
	static address := Acc_Init("AccessibleObjectFromPoint")

	if (x || y)
	{
		point := x & 0xFFFFFFFF
		point |= y << 32
	}
	else
	{
		point := 0
		DllCall("User32\GetCursorPos", "Int64*",point)
	}
	pAcc := 0
	VarSetCapacity(varChild, A_PtrSize * 2 + 8, 0)
	hResult := DllCall(address, "Int64",point, "Ptr*",pAcc, "Ptr",&varChild)
	if (!hResult)
	{
		_ChildId_ := NumGet(varChild, 8, "UInt")
		return ComObj(9, pAcc, 1)
	}
}

Acc_ObjectFromWindow(hWnd, ObjectId := -4)
{
	static address := Acc_Init("AccessibleObjectFromWindow")

	if !WinExist("ahk_id" hWnd)
		throw Exception("Window handle not found.", -1, hWnd)

	ObjectId &= 0xFFFFFFFF
	VarSetCapacity(IID, 16, 0)
	addr := ObjectId = 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0
	aiid := NumPut(addr, IID, "Int64")
	addr := ObjectId = 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81
	riid := NumPut(addr, aiid + 0, "Int64") - 16
	pAcc := 0
	hResult := DllCall(address, "Ptr",hWnd, "UInt",ObjectId, "Ptr",riid
		, "Ptr*",pAcc)
	if (!hResult)
		return ComObj(9, pAcc, 1)
}

Acc_WindowFromObject(pAcc)
{
	static address := Acc_Init("WindowFromAccessibleObject")

	if IsObject(pAcc)
		pAcc := ComObjValue(pAcc)
	hWnd := 0
	hResult := DllCall(address, "Ptr",pAcc, "Ptr*",hWnd)
	if (!hResult)
		return hWnd
}

Acc_GetRoleText(nRole)
{
	static address := Acc_Init("GetRoleTextW")

	nSize := DllCall(address, "UInt",nRole, "Ptr",0, "UInt",0)
	nSize += 1
	VarSetCapacity(sRole, nSize * 2, 0)
	DllCall(address, "UInt",nRole, "Str",sRole, "UInt",nSize)
	return sRole
}

Acc_GetStateText(nState)
{
	static address := Acc_Init("GetStateTextW")

	nSize := DllCall(address, "UInt",nState, "Ptr",0, "UInt",0)
	nSize += 1
	VarSetCapacity(sState, nSize * 2, 0)
	DllCall(address, "UInt",nState, "Str",sState, "UInt",nSize)
	return sState
}

Acc_SetWinEventHook(EventMin, EventMax, Callback)
{
	return DllCall("User32\SetWinEventHook", "Ptr",EventMin, "Ptr",EventMax
		, "Ptr",0, "Ptr",Callback, "Ptr",0, "Ptr",0, "Ptr",0)
}

Acc_UnhookWinEvent(hHook)
{
	return DllCall("User32\UnhookWinEvent", "Ptr",hHook)
}

/* Win Events:

Callback := RegisterCallback("WinEventProc")
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
		return Acc_GetRoleText(oAcc.accRole(ChildId + 0))
	return "invalid object"
}

Acc_State(oAcc, ChildId := 0)
{
	try
		return Acc_GetStateText(oAcc.accState(ChildId + 0))
	return "invalid object"
}

Acc_Location(oAcc, ChildId := 0, ByRef Position := "")
{
	out := {}
	Position := ""
	x := y := w := h := 0
	; VT_BYREF | VT_I4
	x := ComObject(0x4003, &x)
	y := ComObject(0x4003, &y)
	w := ComObject(0x4003, &w)
	h := ComObject(0x4003, &h)
	try
	{
		oAcc.accLocation(x, y, w, h, ChildId + 0)
		x := NumGet(x, 0, "Int")
		y := NumGet(y, 0, "Int")
		w := NumGet(w, 0, "Int")
		h := NumGet(h, 0, "Int")
		Position := "x" x " y" y " w" w " h" h
		out := { "x":x, "y":y, "w":w, "h":h, "pos":Position }
	}
	return out
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
		Child := oAcc.AccChild(ChildId + 0)
		if (Child)
			return Acc_Query(Child)
	}
}

Acc_Query(oAcc) ; Private
{
	iid := "{618736E0-3C3D-11CF-810C-00AA00389B71}"
	try
	{
		query := ComObjQuery(oAcc, iid)
		return ComObj(9, query, 1)
	}
} ; Thanks Lexikos - autohotkey.com/forum/viewtopic.php?t=81731&p=509530#509530

Acc_Error(Previous := "") ; Private, no longer needed
{
	static setting := 0

	if StrLen(Previous)
		setting := Previous
	return setting
}

Acc_Children(oAcc)
{
	static address := Acc_Init("AccessibleChildren")

	if (ComObjType(oAcc, "Name") != "IAccessible")
		throw Exception("Invalid IAccessible Object", -1, oAcc)

	pAcc := ComObjValue(oAcc)
	size := A_PtrSize * 2 + 8
	VarSetCapacity(varChildren, oAcc.accChildCount * size, 0)
	obtained := ""
	hResult := DllCall(address
		, "Ptr",pAcc
		, "Int",0
		, "Int",oAcc.accChildCount
		, "Ptr",&varChildren
		, "Int*",obtained)
	if (hResult)
		throw Exception("AccessibleChildren DllCall Failed", -1)

	children := []
	loop % obtained
	{
		i := (A_Index - 1) * size
		child := NumGet(varChildren, i + 8)
		if (NumGet(varChildren, i) = 9)
		{
			child := Acc_Query(child)
			ObjRelease(child)
		}
		children.Push(child)
	}
	if children.Count()
		return children
}

Acc_ChildrenByRole(oAcc, RoleText)
{
	children := []
	for _,child in Acc_Children(oAcc)
	{
		if (Acc_Role(child) = RoleText)
			children.Push(child)
	}
	if children.Count()
		return children
}

/* Commands:
	-
	Object
	- Aliases
	Action
	DoAction
	Keyboard
	- Properties
	Child
	ChildCount
	DefaultAction
	Description
	Focus
	Help
	HelpTopic
	KeyboardShortcut
	Name
	Parent
	Role
	Selection
	State
	Value
	- Methods
	DoDefaultAction
	Location
*/
Acc_Get(Command, ChildPath, ChildId := 0, WinTitleOrAccObj*)
{
	if RegExMatch(Command, "i)^(HitTest|Navigate|Select)$")
		throw Exception("Command not implemented", -1, Command)

	ChildPath := StrReplace(ChildPath, "_", " ")

	ChildId := Format("{:d}", ChildId)

	if IsObject(WinTitleOrAccObj[1])
		oAcc := WinTitleOrAccObj[1]
	else
	{
		hWnd := WinExist(WinTitleOrAccObj*)
		oAcc := Acc_ObjectFromWindow(hWnd, 0)
	}
	if (ComObjType(oAcc, "Name") != "IAccessible")
		throw Exception("Cannot access an IAccessible Object", -1, oAcc)

	ChildPath := StrSplit(ChildPath, ".")
	for level,item in ChildPath
	{
		RegExMatch(item, "(?<Role>\D+)(?<Index>\d*)", match)
		if (matchRole)
		{
			item := matchIndex ? matchIndex : 1
			children := Acc_ChildrenByRole(oAcc, matchRole)
		}
		else
			children := Acc_Children(oAcc)
		if children.HasKey(item)
		{
			oAcc := children[item]
			continue
		}

		what := matchRole
			? "Role: " matchRole ", Index: " item
			: "Item: " item ", Level: " level
		throw Exception("Cannot access ChildPath Item", -1, what)
	}

	if (Command = "Object")
		return oAcc

	switch Command ; Aliases
	{
		case "Action": Command := "DefaultAction"
		case "DoAction": Command := "DoDefaultAction"
		case "Keyboard": Command := "KeyboardShortcut"
	}

	switch Command
	{
		case "Location":
			out := Acc_Location(oAcc, ChildId).pos
		case "Parent":
			out := Acc_Parent(oAcc)
		case "Role", "State":
			out := Func("Acc_" Command).Call(oAcc, ChildId)
		case "ChildCount", "Focus", "Selection":
			out := oAcc["acc" Command]
		default:
			out := oAcc["acc" Command](ChildId + 0)
	}
	return out
}
