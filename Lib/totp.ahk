
totp(keyUri)
{
    ; Only key URI scheme is recognized
    ; https://github.com/bitwarden/jslib/blob/master/src/services/totp.service.ts#L23
    if InStr(keyUri, "otpauth://totp") != 1
        return
    ; https://github.com/google/google-authenticator/wiki/Key-Uri-Format
    if !RegExMatch(keyUri, "(?<=secret=)\w+", secret)
        return
    RegExMatch(keyUri, "(?<=algorithm=)\w+", algorithm)
    if algorithm not in SHA1,SHA256,SHA512
        algorithm := "SHA1"
    if !RegExMatch(keyUri, "(?<=digits=)\d+", digits)
        digits := 6
    if !RegExMatch(keyUri, "(?<=period=)\d+", period)
        period := 30
    ; https://tools.ietf.org/html/rfc6238
    key := base32toHex(secret)
    counter := Format("{:016x}", epoch() // period)
    hmac := Crypt.Hash.HMAC(algorithm, counter, key, "hex")
    offset := hex2dec(SubStr(hmac, 0)) * 2 + 1
    otp := hex2dec(SubStr(hmac, offset, 8)) & 0x7FFFFFFF
    return SubStr(otp, -1 * digits + 1)
    ; return RegExMatch(otp, "\d{" digits "}") ? otp : "ERROR"
}

#Include <Crypt>
