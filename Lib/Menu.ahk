
Menu()
{
	; Settings sub-menu
	Menu sub1, Add, &Open, Settings ;-------------------- 1
	Menu sub1, Add
	Menu sub1, Add, &Autorun, Autorun ;------------------ 3
	Menu sub1, Add, &Authenticator codes, Totp_toggle ;-- 4
	Menu sub1, Add, Auto-&Type Obfuscation, Tcato_Menu ;- 5

	; Tray menu
	Menu Tray, Icon
	Menu Tray, Icon, shell32.dll, 48
	Menu Tray, NoStandard
	Menu Tray, Tip, % AppTitle " (Loading...)"
	Menu Tray, Add, &Sync, Bitwarden_Sync ;- 1
	Menu Tray, Add, &Lock, Lock_Toggle ;---- 2
	Menu Tray, Add, Log&in, Login_Toggle ;-- 3
	Menu Tray, Add
	Menu Tray, Add, &Generator, Generator
	Menu Tray, Add, &Open Vault, OpenVault
	Menu Tray, Add, &Settings, :sub1 ;------ 7
	Menu Tray, Add
	Menu Tray, Add, &Exit, ExitApp

	Menu Tray, Disable, 1&
	Menu Tray, Disable, 2&
	Menu Tray, Disable, 7&

	if Autorun_Get()
		Menu sub1, Check, 3&
	if (INI.GENERAL.totp)
		Menu sub1, Check, 4&
	if (INI.GENERAL.tcato)
		Menu sub1, Check, 5&
}

#Include <ExitApp>
#Include <Generator>
#Include <OpenVault>
#Include <Tcato>
