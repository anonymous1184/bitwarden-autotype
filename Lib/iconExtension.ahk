
IconExtension(File)
{
	; With just a byte jpg clashes with
	; text encoded as UTF-16 with BOM.
	VarSetCapacity(bytes, 2, 0)
	; Read 2 bytes only from the header
	; as BMP changes from the 3rd byte.
	FileOpen(File, 0x0).RawRead(bytes, 2)
	if (ErrorLevel)
		return
	header := Format("{:03d}", NumGet(bytes, 0, "UChar")) ","
		. Format("{:03d}", NumGet(bytes, 1, "UChar"))

	return { ""
		. "066,077": "bmp"
		, "071,073": "gif"
		, "000,000": "ico"
		, "255,216": "jpg"
		, "137,080": "png"
		, "082,073": "webp" }[header]
}
