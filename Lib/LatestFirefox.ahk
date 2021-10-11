
LatestFirefox()
{
	UrlDownloadToFile https://www.mozilla.org/en-US/, % A_Temp "\bw-at-ff"
	FileRead html, % "*m4096 " A_Temp "\bw-at-ff" ; Only 4kb
	FileDelete % A_Temp "\bw-at-ff"
	if !RegExMatch(html, "firefox=.\K[\d\.]+", version)
		version := "92.0.1" ; October 2021
	return version
}
