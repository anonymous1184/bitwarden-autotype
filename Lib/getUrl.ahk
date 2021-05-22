
; Tested with the latest versions as of May, 2021.
; Chrome, Edge, Firefox and Opera (market share above 1%)
; https://en.wikipedia.org/wiki/Usage_share_of_web_browsers#Summary_tables

getUrl(hWnd, force := false)
{
    static addressBar := []
    if !addressBar[hWnd] || force
        addressBar[hWnd] := getUrl_Bar(Acc_ObjectFromWindow(hWnd))
    try
        url := addressBar[hWnd].accValue(0)
    catch e
    {
        url := ""
        if InStr(e.Message, "800401FD")
        {
            addressBar.Delete(hWnd)
            return %A_ThisFunc%(hWnd)
        }
    }
    return url
}

getUrl_Bar(accObj)
{
    if accObj.accValue(0) && InStr(accObj.accName(0), "Address")
        return accObj
    for i,accChild in Acc_Children(accObj)
        if IsObject(accObj := %A_ThisFunc%(accChild))
            return accObj
}
