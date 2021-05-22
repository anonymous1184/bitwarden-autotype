
pinSetup()
{
    pin1 := pin("PIN Setup")
    if StrLen(pin1) != 6
        return
    pin2 := pin("PIN Repeat")
    if StrLen(pin2) != 6
        return
    if (pin1 = pin2)
        return pin2
    return %A_ThisFunc%()
}
