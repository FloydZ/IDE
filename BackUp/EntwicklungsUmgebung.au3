#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <TreeViewConstants.au3>
#include <GuiStatusBar.au3>
#Include <GuiTreeView.au3>
#include <GuiRichEdit.au3>
#include <GuiTab.au3>
#include <GuiToolBar.au3>
#Include <File.au3>
#include "[INCLUDE]\ModernMenuLib\ModernMenuRaw.au3"
#include "[INCLUDE]\Scientilla\test.au3"
#include <Array.au3>
AutoItSetOption ("GUIOnEventMode", 1)
;$hInfoWindow = GUICreate("Info Window",@DesktopWidth - 200,100,$0X  ,$0Y + 500,$WS_SIZEBOX + $WS_POPUP ,$WS_EX_MDICHILD ,$hMainForm )
;GUICtrlCreateEdit("Test", 10,10,250,50)
;_WinAPI_SetParent($hInfoWindow, $hMainForm)

Global Const $TUCNAME = "TUC 0.0.0.1"
Global Const $MAININI = @ScriptDir & "\MAIN.ini"
Global $hMainForm
Global $hToolBox, $hProjectViewer, $hInfoWindow, $hOutputWindow, $hPropertiesWIndow, $hDebugWindow, $hEdit, $hLineCounter, $LineCounter, $hTabItem[1], $hTab

Global $hTabFiles[1][2];Damit man neben dem Ctrl aucg file und Data speichern kann

Global $SourceFiles[1][1]; um die Datei + Pfad zu speichern + nur für Projecte
Global $iItem;index für die IDTabs
Global $iSheetCounter = 0;Für alles Counter
Global $iCurrentTab = 0, $iOldTab = 0


Global $DefaultLanguage = "AutoIt"
Global $DefaultExt = ".au3"

#Region ### START Koda GUI section ###
$hMainForm = GUICreate($TUCNAME, 1000, 1000, -1, -1, $WS_MAXIMIZEBOX + $WS_CAPTION + $WS_MAXIMIZE + $WS_MINIMIZEBOX)
GUISetState(@SW_SHOW)
Local $aParts[3] = [75, 1000, -1]
$hStatusbar = _GUICtrlStatusBar_Create($hMainForm, $aParts)
$ret = _GUICtrlStatusBar_SetText($hStatusbar, "Hallo", 1)
;MsgBox(0,"",$ret)
#EndRegion ### END Koda GUI section ###
#Region Menu

SetGreenMenuColors()

;_SetFlashTimeOut(250)

Global Const $MenuColor = 0xFFFFFF
Global Const $MenuBKColor = 0x921801
Global Const $MenuBKGradColor = 0xFBCE92


$FileMenu = GUICtrlCreateMenu("&File")
$nSideItem1 = _CreateSideMenu($FileMenu)
_SetSideMenuText($nSideItem1, "File Menu")
_SetSideMenuColor($nSideItem1, $MenuColor) ; default color - white
_SetSideMenuBkColor($nSideItem1, $MenuBKColor) ; bottom start color - dark blue
_SetSideMenuBkGradColor($nSideItem1, $MenuBKGradColor) ; top end color - light blue

$FileNewWorkSpaceItem = _GUICtrlCreateODMenuItem("&Create WorkSpace" & @TAB & "Ctrl+C", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -4)

$FileNewProjectItem = _GUICtrlCreateODMenuItem("&Create Project" & @TAB & "Ctrl+C", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -4)
GUICtrlSetOnEvent(-1, "_CreateNewProjectForm")
$FileSaveProjectItem = _GUICtrlCreateODMenuItem("&Save Project" & @TAB & "Ctrl+S", $FileMenu, "shell32.dll", -7)
_GUICtrlODMenuItemSetSelIcon(-1, "shell32.dll", -79)
$FileOpenProjectItem = _GUICtrlCreateODMenuItem("&Open Project", $FileMenu)
GUICtrlSetOnEvent(-1, "_OpenNewProjectDialog")
$FileCloseProjectItem = _GUICtrlCreateODMenuItem("C&lose Project", $FileMenu)
_GUICtrlCreateODMenuItem("", $FileMenu) ; Separator

$FileCreateFileMenu = _GUICtrlCreateODMenu("Create File", $FileMenu)
$FileCreateFileHeaderItem = _GUICtrlCreateODMenuItem("Header", $FileCreateFileMenu)
$FileCreateFileSourceItem = _GUICtrlCreateODMenuItem("Source", $FileCreateFileMenu)
$FileCreateFileResourceItem = _GUICtrlCreateODMenuItem("Resource", $FileCreateFileMenu)

$FileOpenFileItem = _GUICtrlCreateODMenuItem("Open File", $FileMenu)
GUICtrlSetOnEvent(-1, "_OpenFileDialog")
$FileSaveFileItem = _GUICtrlCreateODMenuItem("Save File", $FileMenu)
$FileSaveUnderFileItem = _GUICtrlCreateODMenuItem("Save File as", $FileMenu)
$FileSaveAllFileItem = _GUICtrlCreateODMenuItem("Save all Files", $FileMenu)
_GUICtrlCreateODMenuItem("", $FileMenu) ; Separator

$FileExitItem = _GUICtrlCreateODMenuItem("E&xit", $FileMenu, "shell32.dll", -28)
;================================
$EditMenu = GUICtrlCreateMenu("&Edit")
$nSideItem1 = _CreateSideMenu($EditMenu)
_SetSideMenuText($nSideItem1, "Edit Menu")
_SetSideMenuColor($nSideItem1, $MenuColor) ; default color - white
_SetSideMenuBkColor($nSideItem1, $MenuBKColor) ; bottom start color - dark blue
_SetSideMenuBkGradColor($nSideItem1, $MenuBKGradColor) ; top end color - light blue

$EditUndoItem = _GUICtrlCreateODMenuItem("&Undo" & @TAB & "Ctrl+C", $EditMenu)
$EditRedoItem = _GUICtrlCreateODMenuItem("&Redo" & @TAB & "Ctrl+C", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu) ; Separator
$EditCutItem = _GUICtrlCreateODMenuItem("&Cut", $EditMenu)
$EditCopyItem = _GUICtrlCreateODMenuItem("&Copy", $EditMenu)
$EditPasteItem = _GUICtrlCreateODMenuItem("&Paste", $EditMenu)
$EditDeleteItem = _GUICtrlCreateODMenuItem("&Delete", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu) ; Separator
$EditSelectAllItem = _GUICtrlCreateODMenuItem("&Select All", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu) ; Separator
$EditFindItem = _GUICtrlCreateODMenuItem("&Find", $EditMenu)
$EditFindNextItem = _GUICtrlCreateODMenuItem("&Find Next", $EditMenu)
$EditFindPreviousItem = _GUICtrlCreateODMenuItem("&Find Previous", $EditMenu)
$EditReplaceItem = _GUICtrlCreateODMenuItem("&Replace", $EditMenu)
;=======================================
$ViewMenu = GUICtrlCreateMenu("&View")
$nSideItem1 = _CreateSideMenu($ViewMenu)
_SetSideMenuText($nSideItem1, "View Menu")
_SetSideMenuColor($nSideItem1, $MenuColor) ; default color - white
_SetSideMenuBkColor($nSideItem1, $MenuBKColor) ; bottom start color - dark blue
_SetSideMenuBkGradColor($nSideItem1, $MenuBKGradColor) ; top end color - light blue

$ViewToolBarItem = _GUICtrlCreateODMenuItem("&ToolBar", $ViewMenu)
$ViewToolBoxItem = _GUICtrlCreateODMenuItem("&ToolBox", $ViewMenu)
$ViewToolBoxItem = _GUICtrlCreateODMenuItem("&Project Viewer", $ViewMenu)
$ViewToolBoxItem = _GUICtrlCreateODMenuItem("&Output Window", $ViewMenu)
$ViewToolBoxItem = _GUICtrlCreateODMenuItem("&Info Window", $ViewMenu)
$ViewToolBoxItem = _GUICtrlCreateODMenuItem("&Properties Window", $ViewMenu)
#EndRegion Menu



#Region ToolBar

;$hReBar = _GUICtrlReBar_Create($hMainForm, BitOR($CCS_TOP, $RBS_VARHEIGHT, $RBS_AUTOSIZE))


; create a toolbar to put in the rebar
$hToolbar = _GUICtrlToolbar_Create($hMainForm)

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



#EndRegion ToolBar

#Region Ctrl
Local $0X = 0; Standartwert für alle CTRL
Local $0Y = 50

;$hTab[$iSheetCounter] = 5($hMainForm, 0, 25, @DesktopWidth -50 , @DesktopHeight)

#cs
$hToolBox[$iSheetCounter] = GUICtrlCreateGroup("ToolBox", $0X, $0Y - 5, 55, @DesktopHeight - $0Y)
GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Properties WindowColor", 0xffffd9))
If IniRead($MAININI, "CTRL", "ToolBox", -1) <> 1 Then GUICtrlSetState($hToolBox[$iSheetCounter], @SW_HIDE)
$0X += 60
;GUICtrlSetResizing(
#ce

$hProjectViewer = _GUICtrlTreeView_Create($hMainForm, @DesktopWidth - 300 + $0X, $0Y, 300, (@DesktopHeight / 2) - $0Y,BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Project WindowColor", 0xffffd9))
If IniRead($MAININI, "CTRL", "Project Viewer", -1) <> 1 Then GUICtrlSetState($hProjectViewer, @SW_HIDE)

Global $WM_NOTIFY_DUMMY = GUICtrlCreateDummy()
GUICtrlSetOnEvent($WM_NOTIFY_DUMMY, "_TreeViewClick")



$hPropertiesWIndow = GUICtrlCreateListView("Properties", @DesktopWidth - 300 + $0X, (@DesktopHeight / 2), 300, (@DesktopHeight / 2) - $0Y, 0x50450000)
GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Properties WindowColor", 0xffffd9))
If IniRead($MAININI, "CTRL", "Properties Window", -1) <> 1 Then GUICtrlSetState($hPropertiesWIndow, @SW_HIDE)


#cs
$hInfoWindow = GUICtrlCreateEdit("Info Window", $0X, $0Y, @DesktopWidth - 300, 50, 0x50450000)
GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Info WindowColor", 0xffffd9))
If IniRead($MAININI, "CTRL", "Info Window", -1) <> 1 Then GUICtrlSetState($hInfoWindow, @SW_HIDE)
$0Y += 50
#ce

$hDebugWindow = GUICtrlCreateEdit("Debug Window", $0X + (@DesktopWidth / 2), @DesktopHeight - 200, (@DesktopWidth / 2) - 300, 200, 0x50450000)
GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Debug WindowColor", 0xffffd9))
If IniRead($MAININI, "CTRL", "Output Window", -1) <> 1 Then GUICtrlSetState($hDebugWindow, @SW_HIDE)

$hOutputWindow = GUICtrlCreateEdit("Output Window", $0X, @DesktopHeight - 200, (@DesktopWidth / 2), 200, 0x50450000)
GUICtrlSetBkColor(-1, IniRead($MAININI, "CTRL", "Output WindowColor", 0xffffd9))
If IniRead($MAININI, "CTRL", "Debug Window", -1) <> 1 Then GUICtrlSetState($hDebugWindow, @SW_HIDE)



Dim $iWidth, $iHeight
If $hOutputWindow <> 0 Then
	$iHeight = @DesktopHeight - $0Y - 200
Else
	$iHeight = @DesktopHeight - $0Y
EndIf

If $hProjectViewer <> 0 Then
	$iWidth = @DesktopWidth - 300
Else
	$iWidth = @DesktopWidth - $0X
EndIf

;$hTab = 0; GUICtrlCreateTab($0X, $0Y - 25, $iWidth, $iHeight + 25)
;$hTabItem[$iSheetCounter] = _GUICtrlTab_InsertItem($hTab, $iSheetCounter, "Test Untitled")
;GUICtrlSetState(-1, $GUI_SHOW); will be display first

$hEdit = CreateSciTE($hMainForm, 100,100,100,100)
If @error Then MsgBox(0,"",@error)
GUICtrlCreateTabItem("")
#EndRegion Ctrl
;======
GUISetState(@SW_SHOW)
GUIRegisterMsg(0x0111, "_WM_COMMAND")
;GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
;AdlibRegister("_RedrawRichEdit",10)

;#cs  DEBUG
	$File = @ScriptDir & "\test.au3"



	Global $sDrive, $sPath, $sName, $sExt
	_PathSplit($File, $sDrive, $sPath, $sName, $sExt)
	GUICtrlSetData($hTabItem[$iSheetCounter], $sName & $sExt)

	$hTabFiles[$iSheetCounter][0] = $File
	$hTabFiles[$iSheetCounter][1] = (FileRead(FileOpen($File)))

	_OpenNewProject(@ScriptDir & "\Test\TUC.tpf")
;#ce END
_MainLoop()
Func _MainLoop()
While 1
	;==========================CalcMouse============================================
	Sleep(25)
WEnd
EndFunc
Func SetGreenMenuColors()
	_SetMenuBkColor(0xAAFFAA)
	_SetMenuIconBkColor(0x66BB66)
	_SetMenuSelectBkColor(0xBBCC88)
	_SetMenuSelectRectColor(0x222277)
	_SetMenuSelectTextColor(0x770000)
	_SetMenuTextColor(0x000000)
EndFunc   ;==>SetGreenMenuColors

Func _RedrawRichEdit()
	If _GUICtrlRichEdit_IsModified($hEdit) = True Then
		$Sel = _GUICtrlTab_GetCurSel($hTab)


	EndIf
EndFunc



Func _Exit()
	Exit
EndFunc

Func _CheckIfTabIsAlreadeOpen($Name)

EndFunc

Func _OpenFileDialog()
	$File = FileOpenDialog("Please select a File", "", "AutoIt Source Code (*.au3)")
	_OpenFile($File)
EndFunc
Func _OpenFile($File)
	$iSheetCounter += 1
	ReDim $hTabItem[$iSheetCounter + 1]
	ReDim $hTabFiles[$iSheetCounter + 1][2]

	_PathSplit($File, $sDrive, $sPath, $sName, $sExt)

	$hTabItem[$iSheetCounter] = _GUICtrlTab_InsertItem($hTab, $iSheetCounter, $sName & $sExt)
	_GUICtrlTab_SetCurSel($hTab, $iSheetCounter)

	$hTabFiles[$iSheetCounter][0] = $File

	Local $String = FileRead(FileOpen($File))
	Switch $DefaultLanguage
		Case "AutoIt"
			$hTabFiles[$iSheetCounter][1] = ($String)

	EndSwitch

EndFunc

;===========================================================================================
Func _CreateNewProjectForm()
#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Create a New Project", 625, 358, 585, 446)
$Group1 = GUICtrlCreateGroup("Language", 8, 0, 401, 49)
$Combo1 = GUICtrlCreateCombo("AutoIt", 16, 16, 385, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Project Type ", 8, 56, 401, 49)
$Combo2 = GUICtrlCreateCombo("Combo2", 16, 72, 385, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Informations ", 8, 112, 401, 129)
$Input1 = GUICtrlCreateInput("TUC", 128, 128, 273, 21)
$Button1 = GUICtrlCreateButton("...", 376, 208, 25, 25, 0)
$Label1 = GUICtrlCreateLabel("Project Name: ", 16, 128, 74, 17)
$Label2 = GUICtrlCreateLabel("Project Beschreibung:", 16, 152, 108, 17)
$Input3 = GUICtrlCreateInput(@ScriptDir & "\TEST", 128, 208, 241, 21)
$Edit1 = GUICtrlCreateEdit("", 128, 152, 273, 49, $ES_WANTRETURN)
GUICtrlSetData(-1, "Edit1")
$Label3 = GUICtrlCreateLabel("Project Direction:", 16, 208, 85, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("Vorlage", 8, 248, 401, 105)
$Edit2 = GUICtrlCreateEdit("", 16, 264, 385, 73)
GUICtrlSetData(-1, "Edit2")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group5 = GUICtrlCreateGroup("Versionierung ", 416, 0, 201, 321)
$Checkbox1 = GUICtrlCreateCheckbox("Use", 424, 16, 97, 17)
$Label4 = GUICtrlCreateLabel("Project Version Format:", 424, 40, 113, 17)
$Input2 = GUICtrlCreateInput("z.B 0.0.0.1", 424, 56, 185, 21)
$Label5 = GUICtrlCreateLabel("File Version Format:", 424, 80, 96, 17)
$Input4 = GUICtrlCreateInput("zB. 0.0.0.1", 424, 96, 185, 21)
$Label6 = GUICtrlCreateLabel("Milestone Settings", 424, 128, 90, 17)
$Radio1 = GUICtrlCreateRadio("On every # Build", 424, 144, 105, 17)
$Combo3 = GUICtrlCreateCombo("10", 536, 144, 73, 25)
$Radio2 = GUICtrlCreateRadio("Time", 424, 168, 49, 17)
$Radio3 = GUICtrlCreateRadio("Date", 424, 192, 113, 17)
$Radio4 = GUICtrlCreateRadio("Open/Close Project", 424, 216, 113, 17)
$Label7 = GUICtrlCreateLabel("Options:", 424, 248, 43, 17)
$Checkbox2 = GUICtrlCreateCheckbox("Do not Update on Build Error", 424, 264, 177, 17)
$Checkbox3 = GUICtrlCreateCheckbox("Do not Update in Debug Error", 424, 280, 161, 17)
$Checkbox4 = GUICtrlCreateCheckbox("weitere werden folgen", 424, 296, 153, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Button2 = GUICtrlCreateButton("OK", 464, 328, 75, 25, 0)
$Button3 = GUICtrlCreateButton("Cancel", 544, 328, 75, 25, 0)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
AutoItSetOption ("GUIOnEventMode", 0)

While 1
	;ConsoleWrite("AA")
$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button2
			$ret = _CreateNewProject(GUICtrlRead($Combo1), GUICtrlRead($Input1), GUICtrlRead($Input3), GUICtrlRead($Input2))
			If $ret <> True Then MsgBox(0,"Error",$ret)
				Exit

	EndSwitch
WEnd

AutoItSetOption ("GUIOnEventMode", 1)
_MainLoop()
EndFunc
Func _CreateNewProject($Language, $Name, $Direction, $Discription, $Type = "Win32", $Template = "Win32")
	If $Name = "" Then Return "Please tip in a Name"
	If $Language = "" Then Return "Please select a Programming Language"
	If $Discription = "" Then Return "Please tip in a discription"
	If $Direction = "" Then Return "Please tip in a Direction"

	Switch $Language
		Case "AutoIt"
			DirCreate( $Direction)
			$ProjectFile = $Direction & "\" & $Name & ".tpf";TUC Project File

			MsgBox(0,"$ProjectFile", $ProjectFile)

			IniWrite($ProjectFile, "Main", "Name", $Name)
			IniWrite($ProjectFile, "Main", "Language", $Language)
			IniWrite($ProjectFile, "Main", "Direction", $Direction)
			IniWrite($ProjectFile, "Main", "CompleteDirection", $Direction & "\" & $Name & ".tpf")
			IniWrite($ProjectFile, "Main", "Discription", $Discription)

			If Not $Type = "" Then
				$Template = @ScriptDir & "\template\" & $Type & ".7z"
				$SourceCodeDir = $Direction & "\Files\"
				$ResourcesDir = $Direction & "\Resources\"
				$BackupDir = $Direction & "\Backup\"

				$TemplateDestination7z = $SourceCodeDir & $Name & ".7z"
				$TemplateDestination = StringTrimRight($TemplateDestination7z, 3)
				$TemplateDestination &= ".au3"

				DirCreate($SourceCodeDir)
				DirCreate($ResourcesDir)
				DirCreate($BackupDir)

				FileCopy($Template, $TemplateDestination7z)

				Do
					Sleep(25)
				Until FileExists($TemplateDestination7z) = True

				_7ZIPExtract($hMainForm, $TemplateDestination7z, $SourceCodeDir)
				If @error Then MsgBox(0,"",@error)
				FileDelete($TemplateDestination7z)

				FileCopy($SourceCodeDir & $Type & "Form.form", $ResourcesDir)
				FileDelete($SourceCodeDir & $Type & "Form.form")

				FileCopy($SourceCodeDir & "\" & $Type & ".au3", $TemplateDestination)
				FileDelete($SourceCodeDir & "\" & $Type & ".au3")

				IniWrite($ProjectFile, "SourceFiles", $Name, $TemplateDestination)
			EndIf

	EndSwitch


	Return True
EndFunc
Func _OpenNewProjectDialog()
	$TPFFile = FileOpenDialog("Please select a Project", "", "Project File (*.tpf)")
	If $TPFFile = "" Then Return -1
	_OpenNewProject($TPFFile)
EndFunc

Func _OpenNewProject($TPFFile = "")

	$Language = IniRead($TPFFile, "MAIN", "Language", "AutoIt")
	$Direction = IniRead($TPFFile, "MAIN", "Direction", "")
	$Name = IniRead($TPFFile, "MAIN", "Name", "")
	$Discription = IniRead($TPFFile, "MAIN", "Discription", "")

	_GUICtrlTreeView_BeginUpdate($hProjectViewer)

	$ProjectTreeViewItem = _GUICtrlTreeView_Add($hProjectViewer, 0, $Name)
	GUICtrlSetColor(-1, 0x323232)

	$FilesTreeViewItem = _GUICtrlTreeView_AddChild($hProjectViewer, $ProjectTreeViewItem, "Files")
	$SourceFiles = IniReadSection($TPFFile, "SourceFiles")

	If $Language = "AutoIt" Then $iExt = ".au3"
	For $x = 1 To $SourceFiles[0][0]
		_GUICtrlTreeView_AddChild($hProjectViewer, $FilesTreeViewItem, $SourceFiles[$x][0] & $iExt)
	Next

	$ResourcesTreeViewItem = _GUICtrlTreeView_AddChild($hProjectViewer, $ProjectTreeViewItem, "Resources")

	$BackupTreeViewItem = _GUICtrlTreeView_AddChild($hProjectViewer, $ProjectTreeViewItem, "Backup")

_GUICtrlTreeView_EndUpdate($hProjectViewer)

EndFunc
;=============================================================================================
Func _CreateFormCreator()
		GUICtrlSetState($hEdit, @sw_Hide)
		GUICtrlSetState($hLineCounter, @sw_Hide)
		GUICtrlSetState($hTab, @sw_Hide)
EndFunc
Func _DrawFormForCreator()
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _7ZIPExtract
; Description ...: Extracts files from archive to the current directory or to the output directory
; Syntax.........: _7ZIPExtract($hWnd, $sArcName[, $sOutput = 0[, $sHide = 0[, $sOverwrite = 0[, $sRecurse = 1[, _
;				   				$sIncludeArc[, $sExcludeArc[, $sIncludeFile = 0[, $sExcludeFile = 0[, $sPassword = 0[, _
;								$sYes = 0]]]]]]]]]])
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;				   $sOutput      - Output directory
;				   $sHide        - Use this switch if you want the CallBack function to be called
;				   $sOverwrite   - Overwrite mode:   0 - Overwrite All existing files without prompt, _
;												     1 - Skip extracting of existing files, _
;												     2 - Auto rename extracting file, _
;												     3 - auto rename existing file
;				   $sRecurse     - Recursion method: 0 - Disable recursion
;													 1 - Enable recursion
;													 2 - Enable recursion only for wildcard names
;				   $sIncludeArc  - Include archive filenames
;				   $sExcludeArc  - Exclude archive filenames
;				   $sIncludeFile - Include filenames, specifies filenames and wildcards or list file that specify processed files
;				   $sExcludeFile - Exclude filenames, specifies what filenames or (and) wildcards must be excluded from operation
;				   $sPassword    - Specifies password
;				   $Yes          - assume Yes on all queries
; Return values .: Success       - Returns the string with results
;                  Failure       - Returns 0 and and sets the @error flag to 1
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================
Func _7ZIPExtract($hWnd, $sArcName, $sOutput = 0, $sHide = 0, $sOverwrite = 0, $sRecurse = 1, $sIncludeArc = 0, $sExcludeArc = 0, _
		$sIncludeFile = 0, $sExcludeFile = 0, $sPassword = 0, $sYes = 0)

	$sArcName = '"' & $sArcName & '"'

	Local $iSwitch = ""

	If $sOutput Then $iSwitch = ' -o"' & $sOutput & '"'
	If $sHide Then $iSwitch &= " -hide"

	If $sPassword Then $iSwitch &= " -p" & $sPassword
	If $sYes Then $iSwitch &= " -y"

	Local $tOutBuffer = DllStructCreate("char[32768]")

	Local $hDLL_7ZIP = DllOpen(@ScriptDir & "\7-zip32.dll");verbessern

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
			"hwnd", $hWnd, _
			"str", "e " & $sArcName & " " & $iSwitch, _
			"ptr", DllStructGetPtr($tOutBuffer), _
			"int", DllStructGetSize($tOutBuffer))

	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_7ZIPExtract

Func _WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
    $nNotifyCode = BitShift($wParam, 16)
    $nID = BitAND($wParam, 0x0000FFFF)
    $hCtrl = $lParam
    Switch $hCtrl
        Case $hLineCounter
;~             GUICtrlSetState($nEdit, $GUI_FOCUS)
        Case $hEdit
            Local $nline = _GUICtrlRichEdit_GetLineCount($hEdit)
            Local $sCounter
            For $i = _GUICtrlRichEdit_GetNumberOfFirstVisibleLine($hEdit) To $nline
                $sCounter &= $i & @CRLF
            Next
            If GUICtrlRead($LineCounter) <> $sCounter Then GUICtrlSetData($LineCounter, $sCounter)
    EndSwitch
EndFunc   ;==>_WM_COMMAND
; WM_NOTIFY event handler
Func _WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    #forceref $hWnd, $iMsg, $iwParam
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndTab
    $hWndTab = $hTab
    If Not IsHWnd($hTab) Then $hWndTab = GUICtrlGetHandle($hTab)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
    Switch $hWndFrom
        Case $hWndTab
            Switch $iCode
                Case $NM_CLICK ; The user has clicked the left mouse button within the control
                    $Sel = _GUICtrlTab_GetCurSel($hTab)

					$iCurrentTab = $Sel
					If $iCurrentTab = -1 Then Exit

					;$hTabFiles[$iOldTab][1]	= _GUICtrlRichEdit_GetText($hEdit)

					;_UpdateTextRichEdit($hTabFiles[$iCurrentTab][1], $iCurrentTab)

					$iOldTab = $iCurrentTab

                Case $NM_DBLCLK ; The user has double-clicked the left mouse button within the control

                Case $NM_RCLICK ; The user has clicked the right mouse button within the control

                Case $NM_RDBLCLK ; The user has clicked the right mouse button within the control

                Case $NM_RELEASEDCAPTURE ; control is releasing mouse capture

            EndSwitch
		Case $hProjectViewer
            Switch $iCode
                Case $NM_CLICK
                    GUICtrlSendToDummy($WM_NOTIFY_DUMMY)
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func _TreeViewClick()
	Local $hSel = _GUICtrlTreeView_GetSelection($hProjectViewer)
	Switch $DefaultLanguage
		Case "AutoIt"
			$sText = _GUICtrlTreeView_GetText($hProjectViewer, $hSel)
			If StringRight($sText, 4) = $DefaultExt Then
				$sNameOfFile = StringTrimRight($sText, 4)

				For $x = 1 to $SourceFiles[0][0]
					If $sNameOfFile = $SourceFiles[$x][0] Then
						_OpenFile($SourceFiles[$x][1])
					EndIf
				Next
			EndIf

		Case Else

	EndSwitch

    ;MsgBox(0, 'Item - Text', _GUICtrlTreeView_GetText($hProjectViewer, $hTVItem) )
EndFunc

