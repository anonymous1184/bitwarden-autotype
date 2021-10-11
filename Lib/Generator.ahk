
Generator()
{
	Gui Generator:New, +AlwaysOnTop +LabelGenerator +LastFound +ToolWindow
	Gui Generator:Font, s11 q5, Consolas
	Gui Generator:Add, CheckBox, % (INI.GENERATOR.lower ? "Checked" : "") " x10 y10" , Lower
	Gui Generator:Add, CheckBox, % (INI.GENERATOR.upper ? "Checked" : "") " xp+70 yp", Upper
	Gui Generator:Add, CheckBox, % (INI.GENERATOR.digits ? "Checked" : "") " xp+65 yp", Digits
	Gui Generator:Add, CheckBox, % (INI.GENERATOR.symbols ? "Checked" : "") " xp+75 yp", Symbols
	Gui Generator:Add, Text, x10 yp+30, Length:
	Gui Generator:Add, Edit, w50 xp+75 yp-5
	Gui Generator:Add, UpDown, Range1-999, % INI.GENERATOR.length
	Gui Generator:Add, Text, xp+70 yp+6, Exclude:
	Gui Generator:Add, Edit, gGenerator_filter r1 w70 xp+70 yp-5, % INI.GENERATOR.exclude
	Gui Generator:Add, Text, x10 yp+35, Password:
	Gui Generator:Add, Edit, w210 xp+75 yp-5
	Gui Generator:Add, Text, x10 yp+35, Entropy: 0 bits    ; +3
	Gui Generator:Add, Button, x160 yp-6, Copy
	Gui Generator:Add, Button, Default xp+57 yp, Generate
	Gui Generator:Show,, Secure Password Generator
	GuiControls()
	Random ,, % Epoch()
	INI.GENERATOR.AtomicSet(0)
	OnMessage(0x0101, "Generator_Monitor") ; WM_KEYUP
	OnMessage(0x0202, "Generator_Monitor") ; WM_LBUTTONUP
	OnMessage(0x020A, "Generator_Monitor") ; WM_MOUSEWHEEL
}

Generator_Filter(ctrlHwnd)
{
	filtered := ""
	GuiControlGet value,, % ctrlHwnd
	loop parse, % StrReplace(value, " ")
		filtered .= InStr(filtered, A_LoopField) ? "" : A_LoopField
	GuiControl ,, % ctrlHwnd, % filtered
	Send {End}
}

Generator_Monitor(wParam, lParam, msg, hWnd)
{
	global GuiControls
	controlId := GuiControls[hWnd]
	; Scroll
	if (msg = 0x20A)
	{
		update := false
		if (controlId = "Edit1")
		{
			update := true
			GuiControlGet value,, Edit1
			value += wParam = 7864320 ? 1 : -1
			INI.GENERATOR.length := value ? value : 1
		}
	}
	else ; Click/Type
	{
		; Tab
		if (lParam = 3222208513)
			return

		; Up|Down
		GuiControlGet focused, Focus
		if (lParam ~= "(3242721281|3243245569)" && focused != "Edit1")
			return

		update := true

		; Checkboxes
		if (controlId ~= "Button[1-4]")
		{
			GuiControlGet isChecked,, % controlId
			INI.GENERATOR[A_GuiControl] := !isChecked
		}
		; Length
		else if (controlId ~= "Edit1|updown")
		{
			GuiControlGet value,, Edit1
			INI.GENERATOR.length := value
		}
		; Exclude
		else if (controlId = "Edit2")
		{
			GuiControlGet value,, Edit2
			INI.GENERATOR.exclude := value
		}
		else if (A_GuiControl = "Copy")
		{
			GuiControlGet Clipboard,, Edit3
			return
		}
		else if (A_GuiControl != "Generate")
			update := false
	}
	if (update)
	{
		GuiControl Text, Edit3, % Generator_Password(INI.GENERATOR, entropy)
		GuiControl Text, Static4, % "Entropy: " entropy " bits"
	}
}

Generator_Password(Options, ByRef Entropy)
{
	out := from := ""
	if (Options.lower)
		from .= "abcdefghijklmnopqrstuvwxyz"
	if (Options.upper)
		from .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	if (Options.digits)
		from .= "0123456789"
	if (Options.symbols)
		from .= "!""#$%&'()*+,-./:;<=>?@[\]^_``{|}~"
	StringCaseSense On
	loop parse, % Options.exclude
		from := StrReplace(from, A_LoopField)
	StringCaseSense Off
	dict := StrLen(from)
	from := StrSplit(from)
	loop % Options.length
	{
		Random rnd, 1, % dict
		out .= from[rnd]
	}
	return out, Entropy := Entropy(dict, Options.length)
}


GeneratorClose:
GeneratorEscape:
	Gui Generator:Destroy
	INI.GENERATOR.Commit()
return
