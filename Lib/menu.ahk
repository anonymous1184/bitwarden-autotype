
menu()
{
    ; Tray menu
    Menu Tray, Icon
    Menu Tray, Icon, shell32.dll, 48
    Menu Tray, NoStandard
    Menu Tray, Tip, % appTitle " (Loading...)"
    Menu Tray, Add, &Sync , sync        ; 1
    Menu Tray, Add, &Lock , toggleLock  ; 2
    Menu Tray, Add, Log&in, toggleLogin ; 3
    Menu Tray, Add
    Menu Tray, Add, &TCATO     , tcato_menu ; 5
    Menu Tray, Add, &Autorun   , autorun    ; 6
    Menu Tray, Add, &Settings  , settings
    Menu Tray, Add, &Generator , generator
    Menu Tray, Add, &Open Vault, openVault
    Menu Tray, Add
    Menu Tray, Add, &Exit, menuExit
    Menu Tray, Disable, 1&
    Menu Tray, Disable, 2&
    if INI.TCATO.use
        Menu Tray, Check, 5&
    if autorun()
        Menu Tray, Check, 6&
}

#Include <generator>
#Include <menuExit>
#Include <openVault>
#Include <settings>
#Include <sync>
