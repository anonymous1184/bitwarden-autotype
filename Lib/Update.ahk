
Update()
{
	epoch := Epoch()
	period := 86400 ; 1 day
	period += INI.DATA.update
	period *= INI.ADVANCED["update-frequency"]
	if (epoch < period)
		return
	if !Update_IsLatest()
	{
		Alert(0x24, "Version is outdated, open GitHub to download the latest?")
		IfMsgBox Yes
			Run https://github.com/anonymous1184/bitwarden-autotype/releases/latest
	}
	INI.DATA.update := epoch
}

Update_IsLatest()
{
	url := "https://raw.githubusercontent.com/anonymous1184/bitwarden-autotype/master/version"
	if !DllCall("Wininet\InternetCheckConnection", "Str",url, "Ptr",1, "Ptr",0)
		return true
	if (A_IsCompiled)
		FileGetVersion offline, % A_ScriptFullPath
	else
		FileRead offline, % A_ScriptDir "\version"
	UrlDownloadToFile % url, % A_Temp "\bw-at-version"
	FileRead online, % A_Temp "\bw-at-version"
	FileDelete % A_Temp "\bw-at-version"
	online := RTrim(online, "`r`n")
	if StrLen(online)
		return CheckVersion(offline, online)
	return true ; Error while checking
}
