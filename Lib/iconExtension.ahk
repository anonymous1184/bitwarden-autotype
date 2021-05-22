
iconExtension(file)
{
    ; With just a byte jpg clashes with
    ; text encoded in UTF-16 with BOM.
    VarSetCapacity(bytes, 2, 0)
    ; Read just 2 bytes from the header
    ; as BMP changes from the 3rd byte.
    FileOpen(file, 0x0).RawRead(bytes, 2)
    if ErrorLevel
        return
    header := NumGet(bytes, 0, "UChar")
        . "," NumGet(bytes, 1, "UChar")
    return { ""     : ""
        , "66,77"   : "bmp"
        , "71,73"   : "gif"
        , "0,0"     : "ico"
        , "255,216" : "jpg"
        , "137,80"  : "png"
        , "82,73"   : "webp" }[header]
}
