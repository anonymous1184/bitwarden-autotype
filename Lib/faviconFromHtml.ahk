
faviconFromHtml(url, file)
{
    link := ""
    if !curl(url, A_Temp "\html")
        return

    ; Unicode chars
    ; Example: icons8.com
    FileRead html, % "*P65001 " A_Temp "\html"
    FileDelete % A_Temp "\html"

    ; Create a DOM
    document := ComObjCreate("HTMLFile")
    ; Only <link> tags, otherwise sites like live.com, battle.net
    ; and figma.com pop cookie warnings and "Open With" requests.
    p := 1, links := ""
    while p := RegExMatch(html, "m)<link[^>]+>", match, p)
        links .= match, p += StrLen(match)
    document.Write(links)
    links := document.getElementsByTagName("link")

    ; Size matrix to pickup default (or smallest)
    icons := {}
    loop % links.Length
        try
        {
            tag := links[A_Index - 1]
            if !(tag.rel ~= "i)icon")
                continue
            size := 0
            try RegExMatch(tag.sizes, "\d+", size)
            icons[size, tag.rel] := tag.href
        }

    precedence := ["icon"    ; 16, 32, 96 || Android: 192
        , "shortcut icon"    ; Old IE
        , "alternate-icon"   ; Usually png
        , "apple-touch-icon" ; 120, 152, 167, 180 || Deprecated: 57, 60, 72, 76, 114, 144
        , "fluid-icon"       ; macOS Dock
        , "mask-icon" ]      ; If svg, is deleted
    ; Apple App Icon Sizes (Android defaults to them):
    ; https://developer.apple.com/ios/human-interface-guidelines/icons-and-images/app-icon/

    for size,icon in icons
        for i,type in precedence
        {
            if icons[size].HasKey(type)
            {
                link := icons[size][type]
                break 2
            }
        }

    if !link
        return

    ; Inline icon
    ; Example: canny.io
    if InStr(link, ";base64,")
        return

    ; Vue.js returns this
    ; Example: privalia.com
    link := RegExReplace(link, "^about:")

    ; Same protocol, different domain
    ; Example: noip.com
    if link ~= "^\/\/"
        link := SubStr(url, 1, InStr(url, "://")) link
    ; Relative
    ; Example: assembla.com
    else if !(link ~= "^http")
    {
        path := url
        while SubStr(path, 0) != "/"
            path := SubStr(path, 1, StrLen(path)-1)
        link := path LTrim(link, "/")
    }

    return faviconGet(link, file)
}
