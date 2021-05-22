
splitUrl(url, ByRef host, ByRef domain, ByRef schema := "", ByRef resource := "")
{
    RegExMatch(url, "S)(?<Schema>.+:\/\/)?(?<Host>[^\/]+)(?<Resource>.*)", $)
    schema := $Schema, host := $Host, resource := $Resource

    ; TLDs now are just stupid (because IDN)
    ; http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    ; https://en.wikipedia.org/wiki/Internationalized_domain_name
    ; No way around 3 letter domains (eg, "foo.git.io" should be "git.io", interpreted like example.com.mx)
    RegExMatch($Host, "S)(?<Domain>[^\.\/]+\.(?:[^\.\/]{2,24}|[^\.\/]{2,3}\.[^\.\/]{2}))(?:\/|$)", $)
    domain := $Domain
}
