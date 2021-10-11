
UIAccess(File, Mode)
{
	try
	{
		xml := ComObjCreate("Msxml2.DOMDocument")
		xml.async := false
		xml.setProperty("SelectionLanguage", "XPath")
		xml.setProperty("SelectionNamespaces", "xmlns:v1='urn:schemas-microsoft-com:asm.v1' xmlns:v3='urn:schemas-microsoft-com:asm.v3'")
		if !xml.load("res://" File "/#24/#1")
			throw
		if !node := xml.selectSingleNode("/v1:assembly/v3:trustInfo/v3:security/v3:requestedPrivileges/v3:requestedExecutionLevel")
			throw
		node.setAttribute("uiAccess", Mode ? "true" : "false")
		xml := RTrim(xml.xml, "`r`n")
		size := StrPut(xml, "UTF-8") - 1
		VarSetCapacity(data, size, 0)
		StrPut(xml, &data, "UTF-8")
		if !hRes := DllCall("Kernel32\BeginUpdateResource", "Str",File, "Int",false)
			throw
		r := DllCall("Kernel32\UpdateResource", "Ptr",hRes, "Ptr",24, "Ptr",1, "UShort",0x0409, "Ptr",&data, "UInt",size)
		if !DllCall("Kernel32\EndUpdateResource", "Ptr",hRes, "Int",!r) && r
			throw
		return true
	}
	catch
	{
		MsgBox 0x40010, Error, % "Couldn't update " File
	}
}
