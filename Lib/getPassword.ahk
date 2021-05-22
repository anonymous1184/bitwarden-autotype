
getPassword()
{
    ; Ask for password
    InputBox bwPass, % appTitle, Master Password:, HIDE, 190, 125,,, Locale
    if !bwPass
        return
    return quote(bwPass) ; Enclose in quotes to avoid escaping
}
