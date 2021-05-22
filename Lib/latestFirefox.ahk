
latestFirefox()
{
    UrlDownloadToFile https://formulae.brew.sh/api/cask/firefox.json, % A_Temp "\json"
    FileRead json, % A_Temp "\json"
    FileDelete, % A_Temp "\json"
    if !RegExMatch(json, "(?<=version.:.)[\d\.]+", version)
        version := "88.0.1" ; May, 2021
    return version
}
