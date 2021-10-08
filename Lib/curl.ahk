
; Makes a request like a browser
; when refreshing without cache.
Curl(Url, File)
{
	static ffVersion := false

	if (!ffVersion)
		ffVersion := LatestFirefox()

	size := 0
	curl := "curl -fLk"
	; f = Fails for non-200
	; L = Follows redirects
	; k = Ignore SSL errors
	headers := { "DNT": 1
		; No compression/decompression
		, "Accept-Encoding": "identity"
		, "Accept-Language": "en-US,en;q=0.9"
		; Don't list aPNG or WebP as accepted formats in favor of regular .ico files
		, "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
		, "Cache-Control": "no-cache"
		, "Connection": "keep-alive"
		, "Pragma": "no-cache"
		, "Referer": Url
		, "Upgrade-Insecure-Requests": 1
		; User Agent set to latest Firefox, obtained dynamically
		, "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:" ffVersion ") Gecko/20100101 Firefox/" ffVersion }
	for header,value in headers
		curl .= " -H " Quote(header ": " value)
	; Set & overwrite target
	curl .= " -o " Quote(File)
	RunWait % curl " " Quote(Url), % A_WorkingDir, Hide UseErrorLevel
	if !ErrorLevel
		FileGetSize size, % File
	return size
}
