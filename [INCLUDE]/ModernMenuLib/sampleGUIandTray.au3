#include <GUIConstants.au3>
;#include "ModernMenu.au3"
#include "ModernMenuRaw.au3" ; Only unknown constants are declared here

#NoTrayIcon

$hMainGUI		= GUICreate("Sample Menu")

;$bUseAdvMenu		= TRUE ; Global variable to switch on/off advanced menu, default is TRUE
;$bUseAdvTrayMenu	= TRUE ; Global variable to switch on/off advanced tray menu, default is TRUE
;$bUseRGBColors		= FALSE; Global variable to change color mode, set TRUE to use RGB color values, default is FALSE

; Set default color values - BGR-values!
SetGreenMenuColors()
SetBlueTrayColors()
;SetOLBlueColors() ; near blue outlook 2003 style
;SetOLSilverColors() ; near silver outlook 2003 style

; Set flash timeout for tray flashing icons (milliseconds) - default are 750, minimum is 50
_SetFlashTimeOut(250)
;  _SetFlashTimeOut() - set back to default

; To activate flashing use _TrayIconSetState($ID, 4)
; To dactivate flashing use _TrayIconSetState($ID, 8)

; !!! To delete menu items please use:
; _TrayDeleteItem($nID)
; or
; _GUICtrlODMenuItemDelete($nID)
; !!!

; File-Menu
$FileMenu		= GUICtrlCreateMenu("&File")
$nSideItem1		= _CreateSideMenu($FileMenu)
_SetSideMenuText($nSideItem1, "My File Menu")
_SetSideMenuColor($nSideItem1, 0xFFFFFF) ; default color - white
_SetSideMenuBkColor($nSideItem1, 0x921801) ; bottom start color - dark blue
_SetSideMenuBkGradColor($nSideItem1, 0xFBCE92) ; top end color - light blue

; You can also set a side menu bitmap
; !Must be min. 8bppand "bmp"-format
; Samples:
; _SetSideMenuImage($nSideItem1, @ScriptDir & "\test.bmp")
; _SetSideMenuImage($nSideItem1, "test.exe", 178) ; Load the bitmap resource ordinal number 178 from 'test.exe'
; _SetSideMenuImage($nSideItem1, "mydll.dll", "#120") ; Load the bitmap resource with name '120' from 'mydll.dll'

$OpenItem		= _GUICtrlCreateODMenuItem("&Open..." & @Tab & "Ctrl+O", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -4)
_GUICtrlODMenuItemSetSelIcon(-1, "shell32.dll", -5)
$SaveItem		= _GUICtrlCreateODMenuItem("&Save" & @Tab & "Ctrl+S", $FileMenu, "shell32.dll", -7)
_GUICtrlODMenuItemSetSelIcon(-1, "shell32.dll", -79)
_GUICtrlCreateODMenuItem("", $FileMenu) ; Separator
$RecentMenu		= _GUICtrlCreateODMenu("Recent Files", $FileMenu)
_GUICtrlCreateODMenuItem("", $FileMenu) ; Separator
$ExitItem		= _GUICtrlCreateODMenuItem("E&xit", $FileMenu, "shell32.dll", -28)

; Tools-Menu
$ToolsMenu		= GUICtrlCreateMenu("&Tools")
$CalcItem		= _GUICtrlCreateODMenuItem("Calculator", $ToolsMenu, "calc.exe", 0)
$CmdItem		= _GUICtrlCreateODMenuItem("CMD", $ToolsMenu, "cmd.exe", 0)
$EditorItem		= _GUICtrlCreateODMenuItem("Editor", $ToolsMenu, "notepad.exe", 0)
$RegeditItem	= _GUICtrlCreateODMenuItem("Regedit", $ToolsMenu, "regedit.exe", 0)

; View-Menu
$ViewMenu		= GUICtrlCreateMenu("&View")
$ViewColorMenu	= _GUICtrlCreateODMenu("Menu Colors", $ViewMenu, "mspaint.exe", 0)
$nSideItem2		= _CreateSideMenu($ViewColorMenu)
_SetSideMenuText($nSideItem2, "Choose a color")
_SetSideMenuColor($nSideItem2, 0x00FFFF)
_SetSideMenuBkColor($nSideItem2, 0xD00000)

$SetDefClrItem	= _GUICtrlCreateODMenuItem("Default", $ViewColorMenu, "", 0, 1)
_GUICtrlCreateODMenuItem("", $ViewColorMenu) ; Separator
$SetRedClrItem	= _GUICtrlCreateODMenuItem("Red", $ViewColorMenu, "", 0, 1)
$SetGrnClrItem	= _GUICtrlCreateODMenuItem("Green", $ViewColorMenu, "", 0, 1)
GUICtrlSetState(-1, $GUI_CHECKED)
$SetBlueClrItem	= _GUICtrlCreateODMenuItem("Blue", $ViewColorMenu, "", 0, 1)
_GUICtrlCreateODMenuItem("", $ViewColorMenu) ; Separator
$SetOLBlueItem	= _GUICtrlCreateODMenuItem("Outlook-Blue", $ViewColorMenu, "", 0, 1)
$SetOLSlvItem	= _GUICtrlCreateODMenuItem("Outlook-Silver", $ViewColorMenu, "", 0, 1)
$ViewStateItem	= _GUICtrlCreateODMenuItem("Enable Config", $ViewMenu)
GUICtrlSetState(-1, $GUI_CHECKED)

; Help-Menu
$HelpMenu		= GUICtrlCreateMenu("&?")
$HelpItem		= _GUICtrlCreateODMenuItem("Help Topics" & @Tab & "F1", $HelpMenu, "shell32.dll", -24)
_GUICtrlCreateODMenuItem("", $HelpMenu) ; Separator
$AboutItem		= _GUICtrlCreateODMenuItem("About...", $HelpMenu)

; You can also the same things on context menus
$GUIContextMenu	= GUICtrlCreateContextMenu(-1)
$ConAboutItem	= _GUICtrlCreateODMenuItem("About...", $GUIContextMenu, "explorer.exe", -8)
_GUICtrlCreateODMenuItem("", $GUIContextMenu) ; Separator
$ConExitItem	= _GUICtrlCreateODMenuItem("Exit", $GUIContextMenu, "shell32.dll", -28)

GUICtrlCreateButton("Test", 100, 200, 70, 20)
GUISetState()

; *** Create the tray icon ***
$nTrayIcon1		= _TrayIconCreate("Tools", "shell32.dll", -13)
_TrayIconSetClick(-1, 16)
_TrayIconSetState() ; Show the tray icon

; *** Create the tray context menu ***
$nTrayMenu1		= _TrayCreateContextMenu() ; is the same like _TrayCreateContextMenu(-1) or _TrayCreateContextMenu($nTrayIcon1)
$nSideItem3		= _CreateSideMenu($nTrayMenu1)
_SetSideMenuText($nSideItem3, "My Tray Menu")
_SetSideMenuColor($nSideItem3, 0x00FFFF) ; yellow; default color - white
_SetSideMenuBkColor($nSideItem3, 0x802222) ; bottom start color - dark blue
_SetSideMenuBkGradColor($nSideItem3, 0x4477AA) ; top end color - orange
;_SetSideMenuImage($nSideItem3, "shell32.dll", 309, TRUE)

$MenuMenu		= _TrayCreateMenu("Menu") ; is the same like _TrayCreateMenu("Menu", -1) or _TrayCreateMenu("Menu", $nTrayMenu1)
_TrayCreateItem("")
_TrayItemSetIcon(-1, "", 0)
$MenuDrives		= _TrayCreateMenu("Driveinfo")
_TrayCreateItem("")
_TrayItemSetIcon(-1, "", 0); Force changing to ownerdrawn sometimes needed, i.e. in mixed menu
$MenuTools		= _TrayCreateMenu("Tools")
_TrayCreateItem("")
_TrayItemSetIcon(-1, "", 0)
$TrayHelp		= _TrayCreateItem("Help")
$TrayRun		= _TrayCreateItem("Run...")
_TrayCreateItem("")
_TrayItemSetIcon(-1, "", 0)
$TrayExit		= _TrayCreateItem("Exit")

_TrayItemSetIcon($MenuMenu, "", 0)
_TrayItemSetIcon($MenuDrives, "shell32.dll", -9)
_TrayItemSetIcon($MenuTools, "shell32.dll", -20)
_TrayItemSetSelIcon($MenuTools, "shell32.dll", -44)
_TrayItemSetIcon($TrayHelp, "shell32.dll", -24)
_TrayItemSetIcon($TrayRun, "shell32.dll", -25)
_TrayItemSetIcon($TrayExit, "shell32.dll", -28)

GUICtrlSetState($TrayHelp, $GUI_DEFBUTTON)

; *** Sub menu items ***
$TrayAdvanced	= _TrayCreateItem("Modern", $MenuMenu, -1, 1)
$TraySimple		= _TrayCreateItem("Classic", $MenuMenu, -1, 1)

_TrayItemSetIcon($TrayAdvanced, "", 0)
_TrayItemSetIcon($TraySimple, "", 0)

GUICtrlSetState($TrayAdvanced, $GUI_CHECKED)

$TrayCalc		= _TrayCreateItem("Calculator", $MenuTools)
$TrayCMD		= _TrayCreateItem("CMD", $MenuTools)
$TrayNotepad	= _TrayCreateItem("Notepad", $MenuTools)
$TrayRegedit	= _TrayCreateItem("Regedit", $MenuTools)

_TrayItemSetIcon($TrayCalc, "calc.exe", 0)
_TrayItemSetIcon($TrayCMD, "cmd.exe", 0)
_TrayItemSetIcon($TrayNotepad, "notepad.exe", 0)
_TrayItemSetIcon($TrayRegedit, "regedit.exe", 0)

GUICtrlSetState($TrayNotepad, $GUI_DISABLE)

_TrayCreateItem("Free Space:", $MenuDrives)
_TrayCreateItem("", $MenuDrives)

$arDrives = DriveGetDrive("FIXED")
For $i = 1 To $arDrives[0]
	_TrayCreateItem(StringUpper($arDrives[$i]) & " -> " & _
		StringFormat("%.2f GB", DriveSpaceFree($arDrives[$i])), $MenuDrives)
Next

; WM_MEASUREITEM and WM_DRAWITEM are registered in 
; "ModernMenu.au3" so they don"t need to registered here
; Also OnAutoItExit() is in "ModernMenu.au3" to cleanup the
; menu imagelist and font

Dim $nTrayIcon2 = 0

; Create an icon which demonstrates how to use click event - see the function 'MyTrayTipCallBack'
Dim $nTrayIcon3 = _TrayIconCreate("Click me", "shell32.dll", -16, "MyTrayTipCallBack")
_TrayIconSetState()

; Main GUI Loop



While 1
	$Msg = GUIGetMsg()
	
	Switch $Msg
		Case $GUI_EVENT_CLOSE, $ExitItem, $ConExitItem, $TrayExit
			ExitLoop
		
		Case $AboutItem, $ConAboutItem
			Msgbox(64, "About", "Menu color sample by Holger Kotsch")
			_GUICtrlODMenuItemSetText($OpenItem, "Open thisone or not..." & @Tab & "Ctrl+O")
			_GUICtrlODMenuItemSetText($ConAboutItem, "About this demo")
			
		Case $ViewStateItem
			If BitAnd(GUICtrlRead($ViewStateItem), $GUI_CHECKED) Then
				GUICtrlSetState($ViewStateItem, $GUI_UNCHECKED)
				GUICtrlSetState($ViewColorMenu, $GUI_DISABLE)
			Else
				GUICtrlSetState($ViewStateItem, $GUI_CHECKED)
				GUICtrlSetState($ViewColorMenu, $GUI_ENABLE)
			EndIf
		
		Case $SetDefClrItem
			SetCheckedItem($SetDefClrItem)
			SetDefaultMenuColors()
			
		Case $SetRedClrItem
			SetCheckedItem($SetRedClrItem)
			SetRedMenuColors()
			
		Case $SetGrnClrItem
			SetCheckedItem($SetGrnClrItem)
			SetGreenMenuColors()
			
		Case $SetBlueClrItem
			SetCheckedItem($SetBlueClrItem)
			SetBlueMenuColors()
			
		Case $SetOLBlueItem
			SetCheckedItem($SetOLBlueItem)
			SetOLBlueColors()
		
		Case $SetOLSlvItem
			SetCheckedItem($SetOLSlvItem)
			SetOLSilverColors()
		
		Case $TrayAdvanced, $TraySimple
			If BitAnd(GUICtrlRead($TraySimple), $GUI_CHECKED) Then
				GUICtrlSetState($TraySimple, $GUI_UNCHECKED)
				GUICtrlSetState($TrayAdvanced, $GUI_CHECKED)
				$bUseAdvTrayMenu = TRUE
			Else
				GUICtrlSetState($TraySimple, $GUI_CHECKED)
				GUICtrlSetState($TrayAdvanced, $GUI_UNCHECKED)
				$bUseAdvTrayMenu = FALSE
			EndIf
			
		Case $TrayHelp
			If $nTrayIcon2 = 0 Then
				$nTrayIcon2 = _TrayIconCreate("New message", "shell32.dll", -14, "MyTrayTipCallBack")
				_TrayIconSetState(-1, 5) ; Show icon and start flashing -> 1 + 4
			Else
				_TrayIconSetState($nTrayIcon2, 5) ; Show icon and start flashing -> 1 + 4
			EndIf
			
			_TrayTip($nTrayIcon2, "New message", "A new message has arrived." & @CRLF & "Please click here to read...", 15, $NIIF_INFO)
	EndSwitch
WEnd

_TrayIconDelete($nTrayIcon1)
_TrayIconDelete($nTrayIcon3)

If $nTrayIcon2 > 0 Then _TrayIconDelete($nTrayIcon2)

Exit


Func MyTrayTipCallBack($nID, $nMsg)
	Switch $nID
		Case $nTrayIcon2
			Switch $nMsg
				Case $NIN_BALLOONUSERCLICK, $NIN_BALLOONTIMEOUT
					_TrayIconSetState($nTrayIcon2, 8) ; Stop icon flashing
					If $nMsg = $NIN_BALLOONUSERCLICK Then MsgBox(64, "Information", "This could be your message.")
					_TrayIconSetState($nTrayIcon2, 2) ; Hide icon
			EndSwitch
			
		Case $nTrayIcon3
			Switch $nMsg
			;;;	Case $WM_LBUTTONDOWN
					; Put your stuff here
			;;;	case $WM_LBUTTONUP
					; Put your stuff here ; One click and double click to put together is difficult
				case $WM_LBUTTONDBLCLK
					MsgBox(0, "Info", "You left double clicked on TrayIcon3.")
					GUISetState(@SW_RESTORE, $hMainGUI) ; Restore/put focus back to our main GUI
			;;;	case $WM_RBUTTONDOWN
					; Put your stuff here
				case $WM_RBUTTONUP
					MsgBox(0, "Info", "You right clicked on TrayIcon3.")
					GUISetState(@SW_RESTORE, $hMainGUI) ; Restore/put focus back to our main GUI
			;;;	case $WM_RBUTTONDBLCLK
					; Put your stuff here
			;;;	case $WM_MOUSEMOVE
					; Put your stuff here
			EndSwitch
	EndSwitch
EndFunc


Func SetCheckedItem($DefaultItem)
	GUICtrlSetState($SetDefClrItem, $GUI_UNCHECKED)
	GUICtrlSetState($SetRedClrItem, $GUI_UNCHECKED)
	GUICtrlSetState($SetGrnClrItem, $GUI_UNCHECKED)
	GUICtrlSetState($SetBlueClrItem, $GUI_UNCHECKED)
	GUICtrlSetState($SetOLBlueItem, $GUI_UNCHECKED)
	GUICtrlSetState($SetOLSlvItem, $GUI_UNCHECKED)
	
	GUICtrlSetState($DefaultItem, $GUI_CHECKED)
EndFunc


Func SetDefaultMenuColors()
	_SetMenuBkColor(0xFFFFFF)
	_SetMenuIconBkColor(0xDBD8D8)
	_SetMenuSelectBkColor(0xD2BDB6)
	_SetMenuSelectRectColor(0x854240)
	_SetMenuSelectTextColor(0x000000)
	_SetMenuTextColor(0x000000)
EndFunc


Func SetRedMenuColors()
	_SetMenuBkColor(0xAADDFF)
	_SetMenuIconBkColor(0x5566BB)
	_SetMenuSelectBkColor(0x70A0C0)
	_SetMenuSelectRectColor(0x854240)
	_SetMenuSelectTextColor(0x000000)
	_SetMenuTextColor(0x000000)
EndFunc


Func SetGreenMenuColors()
	_SetMenuBkColor(0xAAFFAA)
	_SetMenuIconBkColor(0x66BB66)
	_SetMenuSelectBkColor(0xBBCC88)
	_SetMenuSelectRectColor(0x222277)
	_SetMenuSelectTextColor(0x770000)
	_SetMenuTextColor(0x000000)
EndFunc


Func SetBlueMenuColors()
	_SetMenuBkColor(0xFFB8B8)
	_SetMenuIconBkColor(0xBB8877)
	_SetMenuSelectBkColor(0x662222)
	_SetMenuSelectRectColor(0x4477AA)
	_SetMenuSelectTextColor(0x66FFFF)
	_SetMenuTextColor(0x000000)
EndFunc


Func SetBlueTrayColors()
	_SetTrayBkColor(0xFFD8C0)
	_SetTrayIconBkColor(0xEE8877)
	_SetTrayIconBkGrdColor(0x703330)
	_SetTraySelectBkColor(0x662222)
	_SetTraySelectRectColor(0x4477AA)
	_SetTraySelectTextColor(0x66FFFF)
	_SetTrayTextColor(0x000000)
EndFunc


Func SetOLBlueColors()
	_SetMenuBkColor(0xFFFFFF)
	_SetMenuIconBkColor(0xFFEFE3)
	_SetMenuIconBkGrdColor(0xE4AD87)
	_SetMenuSelectBkColor(0xC2EEFF)
	_SetMenuSelectRectColor(0x800000)
	_SetMenuSelectTextColor(0x000000)
	_SetMenuTextColor(0x000000)
EndFunc


Func SetOLSilverColors()
	_SetMenuBkColor(0xF9F9F9)
	_SetMenuIconBkColor(0xFDFDFD)
	_SetMenuIconBkGrdColor(0xC0A0A0)
	_SetMenuSelectBkColor(0xC2EEFF)
	_SetMenuSelectRectColor(0x800000)
	_SetMenuSelectTextColor(0x000000)
	_SetMenuTextColor(0x000000)
EndFunc