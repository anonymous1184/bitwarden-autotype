
OpenVault()
{
	server := "vault.bitwarden.com"
	if (INI.ADVANCED.server)
		server := INI.ADVANCED.server
	Run % "https://" server,, UseErrorLevel
}
