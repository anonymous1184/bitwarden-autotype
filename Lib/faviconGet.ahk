
faviconGet(url, file)
{
    ; Download
    if !curl(url, file)
        return
    /* If the downloaded file has an
      unrecognized extension, delete
      the file, else add extension.
    */
    if !ext := iconExtension(file)
        FileDelete % file
    FileMove % file, % file ext, % true
    return !ErrorLevel
}
