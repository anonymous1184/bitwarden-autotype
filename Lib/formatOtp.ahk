
formatOtp(otp)
{
    mid := StrLen(otp) // 2
    return SubStr(otp, 1, mid) " " SubStr(otp, ++mid)
}
