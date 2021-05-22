
getFavicons()
{
    ; First download
    if !FileExist("icons")
        FileCreateDir icons
    else
    {
        ; Once per week
        FileGetTime mTime, icons
        if epoch() < epoch(mTime) + 604800
            return
        ; Delete generics
        loop files, icons\*
            if A_LoopFileSize = 344
                FileDelete % A_LoopFileFullPath
    }

    for i,entry in bwFields
    {
        if !InStr(entry.schema, "http")
            continue

        ; Already Downloaded
        file := "icons\" entry.host "."
        if FileExist(file "*")
            continue

        ; On the host root: 500px.com
        if faviconGet(entry.schema entry.host "/favicon.ico", file)
            continue

        ; Base domain: community.bitwarden.com -> bitwarden.com
        if (entry.host != entry.domain)
        && faviconGet(entry.schema entry.domain "/favicon.ico", file)
            continue

        ; Base domain with www: teamviewer.com -> www.teamviewer.com
        if (entry.host != "www." entry.domain)
        && faviconGet(entry.schema "www." entry.domain "/favicon.ico", file)
            continue

        ; Favicon in HTML: zoom.us -> st1.zoom.us/zoom.ico
        if faviconFromHtml(entry.uri, file)
            continue

        ; Bitwarden as failover: battle.net
        faviconGet("https://icons.bitwarden.net/" entry.host "/icon.png", file)
    }

    ; ListView unsupported
    FileDelete icons\*.webp
}
