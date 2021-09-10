
openVault()
{
    Run % "https://"
            . INI.ADVANCED.server ? INI.ADVANCED.server : "vault.bitwarden.com"
        ,, UseErrorLevel
}
