
menu()
{
    ; Settings sub-menu
    Menu sub1, Add, &TCATO  , tcato_menu  ; 1
    Menu sub1, Add, &Autorun, autorun     ; 2
    Menu sub1, Add, &Updates, update_menu ; 3
    ; Tray menu
    Menu Tray, Icon
    Menu Tray, Icon, shell32.dll, 48
    Menu Tray, NoStandard
    Menu Tray, Tip, % appTitle " (Loading...)"
    Menu Tray, Add, &Sync , sync        ; 1
    Menu Tray, Add, &Lock , toggleLock  ; 2
    Menu Tray, Add, Log&in, toggleLogin ; 3
    Menu Tray, Add
    Menu Tray, Add, &Generator , generator
    Menu Tray, Add, &Open Vault, openVault
    Menu Tray, Add, &Settings  , :sub1
    Menu Tray, Add
    Menu Tray, Add, &Exit, menuExit
    Menu Tray, Disable, 1&
    Menu Tray, Disable, 2&
    if INI.TCATO.use
        Menu sub1, Check, 1&
    if autorun()
        Menu sub1, Check, 2&
    if INI.GENERAL.updates
        Menu sub1, Check, 3&
}

#Include <generator>
#Include <menuExit>
#Include <openVault>
#Include <settings>
