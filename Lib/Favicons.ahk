
Favicons()
{
/* UrlDownloadToFile is way too primitive thus file
download rely on cURL, shipped with W10 from builds
1803 onwards (April 2018), check for availability.
	*/
	GetStdStream("curl --version")
	if (ErrorLevel)
	{
		Alert(0x10, "cURL is not available, can't download Favicons.")
		INI.GENERAL.favicons := 0
		return ;TODO: Fallback to `UrlDownloadToFile`
	}

	; First download
	attributes := FileExist("icons")
	if !InStr(attributes, "D")
	{
		FileDelete icons
		FileCreateDir icons
	}
	else
	{
		; Once per week
		FileGetTime mTime, icons
		mTime := Epoch(mTime)
		mTime += 604800
		if (Epoch() < mTime)
			return
	}

	; Delete generics
	loop files, icons\*
	{
		if (A_LoopFileSize = 344)
			FileDelete % A_LoopFileFullPath
	}

	for i,entry in BwFields
	{
		if !InStr(entry.schema, "http")
			continue

		; Already Downloaded
		file := "icons\" entry.host "."
		if FileExist(file "*")
			continue

		; Base domain: community.bitwarden.com
		if (entry.host != entry.domain) && Favicons_Get(entry.schema
			. entry.domain "/favicon.ico", file)
		continue

		; On the host root: 500px.com
		if Favicons_Get(entry.schema entry.host "/favicon.ico", file)
			continue

		; Base domain with www: teamviewer.com -> www.teamviewer.com
		if (entry.host != "www." entry.domain) && Favicons_Get(""
			. entry.schema "www." entry.domain "/favicon.ico", file)
		continue

		; Favicon in HTML: zoom.us -> st1.zoom.us/zoom.ico
		if Favicons_Html(entry.uri, file)
			continue

		; Bitwarden as failover: battle.net
		Favicons_Get("https://icons.bitwarden.net/" entry.host
		. "/icon.png", file)
	}

	; ListView unsupported
	FileDelete icons\*.webp
}

Favicons_Get(Url, File)
{
	; Download
	if !Curl(Url, File)
		return
	; If the downloaded file has an unrecognized extension, delete the file,
	; else add the appropriate extension.
	ext := IconExtension(File)
	if (!ext)
		FileDelete % File
	FileMove % File, % File ext, % true
	return !ErrorLevel
}

Favicons_Html(Url, File)
{
	link := ""
	if !Curl(Url, A_Temp "\bw-at-favicon")
		return

	; Unicode chars
	; Example: icons8.com
	FileRead html, % "*P65001 " A_Temp "\bw-at-favicon"
	FileDelete % A_Temp "\bw-at-favicon"

	; Create a DOM
	document := ComObjCreate("HTMLFile")
	; Only <link> tags, otherwise sites like live.com, battle.net
	; and figma.com pop cookie warnings and "Open With" requests.
	p := 1
	links := ""
	while p := RegExMatch(html, "m)<link[^>]+>", match, p)
	{
		links .= match
		p += StrLen(match)
	}
	document.Write(links)
	links := document.getElementsByTagName("link")

	; Size matrix to pickup default/smallest
	icons := {}
	loop % links.Length
	{
		tag := {}
		try
		tag := links[A_Index - 1]
		if !(tag.rel ~= "i)icon")
			continue
		size := 0
		try
		RegExMatch(tag.sizes, "\d+", size)
		icons[size, tag.rel] := tag.href
	}
	links := tag := ""

	; Smallest to largest
	for size,ico in icons
	{
		if Favicons_Precedence(link, size, ico)
			break
	}

	if (!link)
	{
		document := ""
		return false
	}

	; Inline icon
	; Example: canny.io
	;TODO: Save as binary
	if InStr(link, ";base64,")
	{
		document := ""
		return false
	}

	; Vue.js returns this
	; Example: privalia.com
	link := RegExReplace(link, "^about:")

	; Same protocol, different domain
	; Example: noip.com
	if (link ~= "^\/\/")
		link := SubStr(Url, 1, InStr(Url, "://")) link
	; Relative
	; Example: assembla.com
	else if !(link ~= "^http")
	{
		path := Url
		while (SubStr(path, 0) != "/")
			path := SubStr(path, 1, StrLen(path)-1)
		link := path LTrim(link, "/")
	}

	document := ""
	return Favicons_Get(link, File)
}

Favicons_Precedence(ByRef Link, Size, Ico)
{
	precedence := [ "icon" ; 16, 32, 96 || Android: 192
		, "shortcut icon" ; Old IE
		, "alternate-icon" ; Usually png, if webp not supported
		, "apple-touch-icon" ; 120, 152, 167, 180
		; Deprecated touch sizes: 57, 60, 72, 76, 114, 144
		, "fluid-icon" ; macOS Dock
		, "mask-icon" ] ; If svg not supported
	; Apple App Icon Sizes (Android defaults to them):
	; https://developer.apple.com/ios/human-interface-guidelines/icons-and-images/app-icon/

	for _,type in precedence
	{
		if Ico.HasKey(type)
		{
			Link := Ico[type]
			return true
		}
	}

	return false
}
