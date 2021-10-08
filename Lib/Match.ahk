
Match(Mode)
{
	KeysWait() ; Until released

	; Unlock/Login if needed
	if (IsLocked && !Lock_Toggle())
		return
	if (!IsLogged && !Login_Toggle())
		return

	; Early fail if Clipboard unaccessible for TCATO
	hWnd := DllCall("User32\GetOpenClipboardWindow", "Ptr")
	if (INI.GENERAL.tcato && hWnd)
	{
		WinGet exe, ProcessName, % "ahk_id" hWnd
		Alert(0x10, "TCATO cannot access the Clipboard. "
			. (exe ? Quote(exe) " is currently blocking it." : ""))
		return
	}

	; Increase
	Process Priority,, High

	hWnd := WinExist("A")
	WinGetClass activeClass
	WinGetTitle activeTitle
	WinGet exe, ProcessName

	; Get Url and it parts if browser
	url := Match_ParseUrl(hWnd, exe)

	matches := []
	; Loop through the JSON
	for _,entry in BwFields
	{
		if (Mode = "totp" && !entry.otpauth)
			continue

		isMatch := false
		if (url) ; by URL
			isMatch := Match_ByUrl(url, entry)
		; by .exe
		else if (SubStr(entry.uri, -3) = ".exe")
			isMatch := (exe = entry.uri)
		; by class
		else if RegExMatch(entry.uri, "class=(.+)", $)
			isMatch := ($1 = activeClass)
		; by window title, exact match
		else if RegExMatch(entry.uri, "title=(.+)", $)
			isMatch := ($1 == activeTitle)
		; by window title, partial match
		else if (!entry.schema)
			isMatch := InStr(activeTitle, entry.uri)

		if (!isMatch)
			continue

		; Add a typing sequence
		if (entry.HasKey("field") && Mode = "default")
			entry.sequence := entry.field
		else
			entry.sequence := INI.SEQUENCES[Mode]
		matches.Push(entry)
	}

	; Back to normal
	Process Priority,, Normal

	matchId := matches.Count()
	if (!matchId)
	{
		;TODO: Create a UI for entry selection
		; Fixes:
		; Add TOTP Copy button | https://community.bitwarden.com/t/7041
		Alert(0x10, "No auto-type match found.")
	}
	else if (matchId > 1)
		matchId := Match_Select(matches, Mode)
	WinActivate % "ahk_id" hWnd
	if (matchId)
		AutoType(matches[matchId], Mode)
}

Match_ByUrl(Url, Entry)
{
	switch Entry.match
	{
		; Never
		case 5: return
		; RegEx
		case 4: return RegExMatch(Url.Url, Entry.uri)
		; Exact
		case 3: return InStr(Url.Url, Entry.uri, true)
		; Start
		case 2: return InStr(Url.Url, Entry.uri) ; at 1,8,9
		; Host
		case 1: return (Url.Host = Entry.host)
		; Base Domain
		default:
			return (Url.Domain = Entry.domain)
	}
}

Match_ParseUrl(hWnd, Exe)
{
	if !(Exe ~= "i)chrome|msedge|firefox|iexplore|opera")
		return
	Url := Url_Get(hWnd, InStr(Exe, "ie"))
	if (url)
	{
		Url_Split(url, host, domain)
		return {Url:url, Host:host, Domain:domain}
	}
	Alert(0x134, "Couldn't get the URL from " Quote(Exe) ". Continue?")
	IfMsgBox No
		Exit
}

Match_Row(CtrlHwnd, GuiEvent, EventInfo)
{
	GuiControl ,, Edit1, % EventInfo
	if (GuiEvent = "DoubleClick")
		Match_Use()
}

Match_Select(Matches, Mode)
{
	static MatchId

	Gui Match:New, +AlwaysOnTop +LastFound +ToolWindow
	Gui Match:Font, s11
	Gui Match:Add, ListView, AltSubmit Grid gMatch_Row
		, % "|#|Entry|User" (Mode = "totp" ? "" : "|TOTP")
	Gui Match:Add, Button, Default gMatch_Use x-50 y-50

	total := Matches.Count()
	iconList := IL_Create(total)
	LV_SetImageList(iconList)
	for i,match in Matches
	{
		; Row
		LV_Add("Icon" i,, i, match.name, match.username
			, Mode = "totp" ? "" : (match.otpauth ? "✔" : "✘"))
		; Icon
		if (SubStr(match.host, -3) = ".exe")
		{
			WinGet exe, ProcessPath, % "ahk_exe" match.host
			IL_Add(iconList, exe ? exe : "consent.exe")
			continue
		}
		img := ""
		loop files, % "icons\" match.domain ".*"
			img := A_LoopFileFullPath
		loop files, % "icons\" match.host ".*"
			img := A_LoopFileFullPath
		if (img)
			IL_Add(iconList, img, 0xFFFFFF, 1)
		else
			IL_Add(iconList, "imageres.dll", 300)
	}

	; Auto-size
	LV_ModifyCol()
	LV_ModifyCol(2, "Center")
	if (Mode != "totp")
		LV_ModifyCol(5, "AutoHdr Center")
	cols := LV_GetCount("Column")
	listViewWidth := cols * cols
	Loop % cols
	{
		; 0x101D = LVM_GETCOLUMNWIDTH
		SendMessage 0x101D, % A_Index - 1, 0, SysListView321
		listViewWidth += ErrorLevel
	}
	GuiControl Move, SysListView321, % "w" listViewWidth

	Mode := { "default": "Default"
		, "username": "Username-only"
		, "password": "Password-only"
		, "totp": "TOTP" }[Mode]
	Gui Match:Add, Edit, Hidden vMatchId x0 y0, % MatchId := ""
	Gui Match:Show, AutoSize, % " Select Entry (" Mode " sequence)"

	WinWaitClose
	return MatchId
}

Match_Use()
{
	Gui Match:Submit
	Gosub MatchGuiClose
}


MatchGuiClose:
MatchGuiEscape:
	Gui Match:Destroy
return
