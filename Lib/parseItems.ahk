
parseItems(items)
{
    out := []
    for i,entry in items
    {
        ; Logins only
        if entry.type != 1
            continue

        ; 2FA unlock
        if (INI.PIN.use = entry.name)
        {
            if totp(entry.login.totp) ~= "\d{6}"
                INI.PIN.key := entry.login.totp
            else
                INI.PIN.use := false
        }

        ; Item definition
        base := {  "name": entry.name
            ,   "otpauth": entry.login.totp
            ,  "username": entry.login.username
            ,  "password": entry.login.password }

        ; Custom auto-type
        for j,field in entry.fields
            switch field.name
            {
                case "TCATO": base.TCATO := field.value
                case INI.SEQUENCES["field"]: base.field := field.value
            }

        ; Parse each URI
        for j,uri in entry.login.uris
        {
            ; Avoid references
            item := base.Clone()
            item.match := uri.match
            splitUrl(uri.uri, host, domain, schema, resource)
            item.host := host ; .exe name as host for icon
            if InStr(schema, "http")
                item.schema := schema
                , item.domain := domain
                , item.uri := uri.match = 4 ? uri.uri : host resource ; match 4 is a RegEx, don't modify
            else if InStr(schema, "app")
                item.schema := "app://"
                , item.uri := host resource
            else
                item.uri := uri.uri
            out.Push(item)
        }
    }
    return out
}
