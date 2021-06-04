
quote(str)
{
    return """" str """"
}

quote_remove(str)
{
    str := Trim(str)
    if SubStr(str, 1, 1) = """"
    && SubStr(str,    0) = """"
        str := SubStr(str, 2, -1)
    return str
}
