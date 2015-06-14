#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#Include <GuiStatusBar.au3>
#Include <GuiRichEdit.au3>
#Include <GuiTab.au3>
#Include <GuiToolBar.au3>
#Include <GuiRebar.au3>;ma schauen
#include "[INCLUDE]\ModernMenuLib\ModernMenuRaw.au3"

	;$hInfoWindow = GUICreate("Info Window",@DesktopWidth - 200,100,$0X  ,$0Y + 500,$WS_SIZEBOX + $WS_POPUP ,$WS_EX_MDICHILD ,$hMainForm )
	;GUICtrlCreateEdit("Test", 10,10,250,50)
	;_WinAPI_SetParent($hInfoWindow, $hMainForm)
	
Global Const $NAME = "TUC 0.0.0.1"
Global Const $MAININI = @ScriptDir & "\MAIN.ini"
Global $hMainForm
Global $hToolBox[1], $hProjectViewer[1], $hInfoWindow[1], $hOutputWindow[1], $hPropertiesWIndow[1], $hDebugWindow[1], $hEdit[1], $hTab[1]
Global $iSheetCounter = 0
#Region ### START Koda GUI section ### 
$hMainForm = GUICreate($NAME, 1000, 1000, -1, -1,$WS_MAXIMIZEBOX + $WS_CAPTION + $WS_MAXIMIZE + $WS_MINIMIZEBOX )
GUISetState(@SW_SHOW)
Local $aParts[3] = [75, 1000, -1]
$hStatusbar = _GUICtrlStatusBar_Create($hMainForm, $aParts)
$ret = _GUICtrlStatusBar_SetText($hStatusbar, "Hallo",1)
;MsgBox(0,"",$ret)
#EndRegion ### END Koda GUI section ###
#region Menu

SetGreenMenuColors()

;_SetFlashTimeOut(250)

Global Const $MenuColor = 0xFFFFFF
Global Const $MenuBKColor = 0x921801
Global Const $MenuBKGradColor = 0xFBCE92


$FileMenu		= GUICtrlCreateMenu("&File")
$nSideItem1		= _CreateSideMenu($FileMenu)
	_SetSideMenuText($nSideItem1, "File Menu")
	_SetSideMenuColor($nSideItem1, $MenuColor) ; default color - white
	_SetSideMenuBkColor($nSideItem1, $MenuBKColor) ; bottom start color - dark blue
	_SetSideMenuBkGradColor($nSideItem1, $MenuBKGradColor) ; top end color - light blue

$FileNewProjectItem		= _GUICtrlCreateODMenuItem("&Create Project" & @Tab & "Ctrl+C", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -4)
$FileSaveProjectItem		= _GUICtrlCreateODMenuItem("&Save Project" & @Tab & "Ctrl+S", $FileMenu, "shell32.dll", -7)
_GUICtrlODMenuItemSetSelIcon(-1, "shell32.dll", -79)
$FileOpenProjectItem		= _GUICtrlCreateODMenuItem("&Open Project", $FileMenu)
$FileCloseProjectItem		= _GUICtrlCreateODMenuItem("C&lose Project", $FileMenu)
_GUICtrlCreateODMenuItem("", $FileMenu) ; Separator

$FileCreateFileMenu		= _GUICtrlCreateODMenu("Create File", $FileMenu)
	$FileCreateFileHeaderItem		= _GUICtrlCreateODMenuItem("Header", $FileCreateFileMenu)
	$FileCreateFileSourceItem		= _GUICtrlCreateODMenuItem("Source", $FileCreateFileMenu)
	$FileCreateFileResourceItem		= _GUICtrlCreateODMenuItem("Resource", $FileCreateFileMenu)
	
$FileOpenFileItem		= _GUICtrlCreateODMenuItem("Open File", $FileMenu)	
$FileSaveFileItem		= _GUICtrlCreateODMenuItem("Save File", $FileMenu)	
$FileSaveUnderFileItem		= _GUICtrlCreateODMenuItem("Save File as", $FileMenu)	
$FileSaveAllFileItem		= _GUICtrlCreateODMenuItem("Save all Files", $FileMenu)	
_GUICtrlCreateODMenuItem("", $FileMenu) ; Separator

$FileExitItem		= _GUICtrlCreateODMenuItem("E&xit", $FileMenu, "shell32.dll", -28)
;================================
$EditMenu		= GUICtrlCreateMenu("&Edit")
$nSideItem1		= _CreateSideMenu($EditMenu)
	_SetSideMenuText($nSideItem1, "Edit Menu")
	_SetSideMenuColor($nSideItem1, $MenuColor) ; default color - white
	_SetSideMenuBkColor($nSideItem1, $MenuBKColor) ; bottom start color - dark blue
	_SetSideMenuBkGradColor($nSideItem1, $MenuBKGradColor) ; top end color - light blue

$EditUndoItem		= _GUICtrlCreateODMenuItem("&Undo" & @Tab & "Ctrl+C", $EditMenu)
$EditRedoItem		= _GUICtrlCreateODMenuItem("&Redo" & @Tab & "Ctrl+C", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu) ; Separator
$EditCutItem		= _GUICtrlCreateODMenuItem("&Cut", $EditMenu)
$EditCopyItem		= _GUICtrlCreateODMenuItem("&Copy", $EditMenu)
$EditPasteItem		= _GUICtrlCreateODMenuItem("&Paste", $EditMenu)
$EditDeleteItem		= _GUICtrlCreateODMenuItem("&Delete", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu) ; Separator
$EditSelectAllItem		= _GUICtrlCreateODMenuItem("&Select All", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu) ; Separator
$EditFindItem		= _GUICtrlCreateODMenuItem("&Find", $EditMenu)
$EditFindNextItem		= _GUICtrlCreateODMenuItem("&Find Next", $EditMenu)
$EditFindPreviousItem		= _GUICtrlCreateODMenuItem("&Find Previous", $EditMenu)
$EditReplaceItem		= _GUICtrlCreateODMenuItem("&Replace", $EditMenu)
;=======================================
$ViewMenu		= GUICtrlCreateMenu("&View")
$nSideItem1		= _CreateSideMenu($ViewMenu)
	_SetSideMenuText($nSideItem1, "View Menu")
	_SetSideMenuColor($nSideItem1, $MenuColor) ; default color - white
	_SetSideMenuBkColor($nSideItem1, $MenuBKColor) ; bottom start color - dark blue
	_SetSideMenuBkGradColor($nSideItem1, $MenuBKGradColor) ; top end color - light blue
	
$ViewToolBarItem		= _GUICtrlCreateODMenuItem("&ToolBar", $ViewMenu)
$ViewToolBoxItem		= _GUICtrlCreateODMenuItem("&ToolBox", $ViewMenu)
$ViewToolBoxItem		= _GUICtrlCreateODMenuItem("&Project Viewer", $ViewMenu)
$ViewToolBoxItem		= _GUICtrlCreateODMenuItem("&Output Window", $ViewMenu)
$ViewToolBoxItem		= _GUICtrlCreateODMenuItem("&Info Window", $ViewMenu)
$ViewToolBoxItem		= _GUICtrlCreateODMenuItem("&Properties Window", $ViewMenu)
#endregion



#region ToolBar

	;$hReBar = _GUICtrlReBar_Create($hMainForm, BitOR($CCS_TOP, $RBS_VARHEIGHT, $RBS_AUTOSIZE))


	; create a toolbar to put in the rebar
	$hToolbar = _GUICtrlToolBar_Create($hMainForm)
	
	; Add standard system bitmaps
	_GUICtrlToolbar_AddBitmap($hToolbar, 1, -1, $IDB_STD_SMALL_COLOR)


	; Add buttons
	Global Enum $idNew = 1000, $idOpen, $idSave, $idHelp
	_GUICtrlToolbar_AddButton($hToolbar, $idNew, $STD_FILENEW)
	_GUICtrlToolbar_AddButton($hToolbar, $idOpen, $STD_FILEOPEN)
	_GUICtrlToolbar_AddButton($hToolbar, $idSave, $STD_FILESAVE)
	_GUICtrlToolbar_AddButtonSep($hToolbar)
	_GUICtrlToolbar_AddButton($hToolbar, $idHelp, $STD_HELP)
  ; Fügt eine Gruppe mit der Toolbar am Anfang der Rebar ein
    ;_GUICtrlRebar_AddToolBarBand($hReBar, $hToolbar, "", 0)



#endregion

#region Ctrl
Local $0X = 0; Standartwert für alle CTRL
Local $0Y = 50

;$hTab[$iSheetCounter] = 5($hMainForm, 0, 25, @DesktopWidth -50 , @DesktopHeight)


	$hToolBox[$iSheetCounter] = GUICtrlCreateGroup("ToolBox",$0X,$0Y - 5,55,@DesktopHeight - $0Y)
	GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Properties WindowColor", 0xffffd9))
	If IniRead($MAININI, "CTRL", "ToolBox", -1) <> 1 Then GUICtrlSetState($hToolBox[$iSheetCounter],@SW_HIDE)
	$0X += 60



	$hProjectViewer[$iSheetCounter] = GUICtrlCreateTreeView(@DesktopWidth - 300 + $0X,$0Y,300,(@DesktopHeight / 2) - $0Y ,0x50450000 )
	GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Project WindowColor", 0xffffd9))
	If IniRead($MAININI, "CTRL", "Project Viewer", -1) <> 1 Then GUICtrlSetState($hProjectViewer[$iSheetCounter],@SW_HIDE)
		
	$hPropertiesWindow[$iSheetCounter] = GUICtrlCreateListView("Properties",@DesktopWidth - 300 + $0X,(@DesktopHeight / 2),300,(@DesktopHeight / 2)-$0Y, 0x50450000)
	GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Properties WindowColor", 0xffffd9))
	If IniRead($MAININI, "CTRL", "Properties Window", -1) <> 1 Then GUICtrlSetState($hPropertiesWindow[$iSheetCounter],@SW_HIDE)
	
	

	$hInfoWindow[$iSheetCounter] = GUICtrlCreateEdit("Info Window", $0X,$0Y,@DesktopWidth - 300,50,0x50450000)
	GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Info WindowColor", 0xffffd9))
	If IniRead($MAININI, "CTRL", "Info Window", -1) <> 1 Then  GUICtrlSetState($hInfoWindow[$iSheetCounter],@SW_HIDE)
	$0Y += 50


	$hDebugWindow[$iSheetCounter] = GUICtrlCreateEdit("Debug Window", $0X + (@DesktopWidth/2),@DesktopHeight - 200,(@DesktopWidth/2) -300,200,0x50450000)
	GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Debug WindowColor", 0xffffd9))
	If IniRead($MAININI, "CTRL", "Output Window", -1) <> 1 Then GUICtrlSetState($hDebugWindow[$iSheetCounter],@SW_HIDE)
		
	$hOutputWindow[$iSheetCounter] = GUICtrlCreateEdit("Output Window", $0X,@DesktopHeight - 200,(@DesktopWidth/2) ,200,0x50450000)
	GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Output WindowColor", 0xffffd9))
	If IniRead($MAININI, "CTRL", "Debug Window", -1) <> 1 Then GUICtrlSetState($hDebugWindow[$iSheetCounter],@SW_HIDE)



	Dim $iWidth, $iHeight
	If $hOutputWindow[$iSheetCounter] <> 0 Then 
		$iHeight = @DesktopHeight - $0Y - 200
	Else
		$iHeight = @DesktopHeight - $0Y
	EndIf

	If $hProjectViewer[$iSheetCounter] <> 0 Then 
		$iWidth = @DesktopWidth - 300
	Else
		$iWidth = @DesktopWidth - $0X
	EndIf

	$hEdit = _GUICtrlRichEdit_Create($hMainForm, "Edit", $0X, $0Y, $iWidth, $iHeight, 0x50040000)
	GUICtrlSetBkColor($hEdit,  0xffffd9)
#endregion
;======
GUISetState(@SW_SHOW)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE 
			Exit
	EndSwitch
;==========================CalcMouse============================================
$Cursor = MouseGetCursor()
$pos = GUIGetCursorInfo($hMainForm)
Switch $Cursor
	Case 10 ;Pfeil oben recht unten links
		
EndSwitch

WEnd


Func SetGreenMenuColors()
	_SetMenuBkColor(0xAAFFAA)
	_SetMenuIconBkColor(0x66BB66)
	_SetMenuSelectBkColor(0xBBCC88)
	_SetMenuSelectRectColor(0x222277)
	_SetMenuSelectTextColor(0x770000)
	_SetMenuTextColor(0x000000)
EndFunc


Func _DebugPrint($s_text, $line = @ScriptLineNumber)
    ConsoleWrite( _
            "!===========================================================" & @LF & _
            "+======================================================" & @LF & _
            "-->Zeile(" & StringFormat("%04d", $line) & "):" & @TAB & $s_text & @LF & _
            "+======================================================" & @LF)
EndFunc   ;==>_DebugPrint

