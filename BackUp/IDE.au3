#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

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
#include "[INCLUDE]\GuiFrame\GuiFrame.au3"
#include <Array.au3>
#include <WInAPI.au3>
AutoItSetOption ("GUIOnEventMode", 1)

Global Const $TUCNAME = "TUC 0.0.0.1"
Global $hMainForm
Global $hTab

Global $LanguageArray[1][3]
;[n][0] = LanguageName; [n][1] = HeaderdateiExt; [n][2] = SourcedateiExt
$LanguageArray[0][0] = "AutoIt"
$LanguageArray[0][1] = ".au3"
$LanguageArray[0][2] = ".au3"


Global $SourceFile[1][5][4]
#cs SourceFiles
[n][0][0] = Projekt Name
[n][0][1] = Projekt Version
[n][0][2] = Compiler Optionen -> Haupdatei oder eine IncludeDatei 0/1


[n][1][0] = TabID
[n][1][1] = Name des Tab
[n][1][2] =
[n][1][3] =

[n][2][0] = EdidID
[n][2][1] = Stand des Editfeldes gleich zum speicherpunkt oder geändert 0/1

[n][3][0] = TreeviewChild Handle
[n][3][1]

[n][4][0] = Dateipfad
[n][4][1] = Verwendete Language
[n][4][2] = Header oder Source file 0/1
[n][4][3] = Version
#ce
Global $hProjectViewer ;Treeview für das Project rechts oben

Global $iSheetCounter = 0;Für alles Counter
Global $DefaultLanguage = "AutoIt"
Global $DefaultExt = ".au3"

Global $XAbstand = 300;Abstand vom edit zum rechten Rand
Global $YAbstand = 300;Abstand vom edit zum unteren Rand


Global $MAINOPTFILE = @ScriptDir & "\Main.ini"
_FirstStartup();wird immer aufgerufen der check finded in der Func stat

#Region ### START Koda GUI section ###
$hMainForm = GUICreate($TUCNAME, IniRead($MAINOPTFILE, "MAIN", "W", 0), IniRead($MAINOPTFILE, "MAIN", "H", 0), -1, -1,$WS_MAXIMIZE + $WS_MAXIMIZEBOX + $WS_CAPTION + $WS_MINIMIZEBOX + $WS_CLIPCHILDREN)
Local $aParts[3] = [75, 1000, -1]
$hStatusbar = _GUICtrlStatusBar_Create($hMainForm, $aParts)
$ret = _GUICtrlStatusBar_SetText($hStatusbar, "Hallo", 1)
;MsgBox(0,"",$ret)
#EndRegion ### END Koda GUI section ###
#Region Menu
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


;======
#Region Controles
$iFrame_MID = _GUIFrame_Create($hMainForm, 0,@DesktopWidth - $XAbstand);MAin
_GUIFrame_SetMin($iFrame_MID, 100, 100)

$iFrame_MID_RIGHT = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_MID, 2), 1);Rechts
_GUIFrame_SetMin($iFrame_MID_RIGHT, 300, 300)


$iFrame_MID_LEFT = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_MID, 1), 1,@DesktopHeight - $YAbstand + 30,5);links
_GUIFrame_SetMin($iFrame_MID_RIGHT, 100, 100)

$iFrame_MID_MID = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_MID_LEFT, 2));Linksunten
_GUIFrame_SetMin($iFrame_MID_RIGHT, 100, 100)
_GUIFrame_ResizeSet(0)




_GUIFrame_Switch($iFrame_MID_LEFT, 1);links oben
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_LEFT, 1))
$iTab = GUICtrlCreateTab(0, 27, $aWinSize[0], $aWinSize[1] - 10, $TCS_BUTTONS +$TCS_FLATBUTTONS)
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
$hTab = GUICtrlGetHandle($iTab)
_CreateNewBlankPage()


_GUIFrame_Switch($iFrame_MID_RIGHT, 1);rechts oben
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_RIGHT, 1))
GUICtrlCreateTab(0, 50, $aWinSize[0], $aWinSize[1] - 50, $TCS_BOTTOM, $TCS_FLATBUTTONS)
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Project Viewer", 0, 30, 100, 15)
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 30, 15, 15)
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateTabItem("File Explorer")
GUICtrlCreateTreeView(1, 51, $aWinSize[0] , $aWinSize[1] - 71)
GUICtrlCreateTreeViewItem("Test1", -1)

GUICtrlCreateTabItem("Project Explorer")
$hProjectViewer = GUICtrlCreateTreeView(1, 51, $aWinSize[0] , $aWinSize[1] - 71, $TVS_DISABLEDRAGDROP)


GUICtrlCreateTabItem("Functions")
GUICtrlCreateTabItem("")



_GUIFrame_Switch($iFrame_MID_RIGHT, 2);rechts unten
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_RIGHT, 2))
GUICtrlCreateListView("Property |Value ", 0, 16, $aWinSize[0], $aWinSize[1])
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Properties Viewer", 0, 0, 100, 15)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 0, 15, 15)


_GUIFrame_Switch($iFrame_MID_MID, 2);links unten rechts
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_MID, 2))
GUICtrlCreateEdit("", 0, 16, $aWinSize[0], $aWinSize[1])
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Output Viewer", 0, 0, 100, 15)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 0, 15, 15)


_GUIFrame_Switch($iFrame_MID_MID, 1);links unten links
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_MID, 1))
GUICtrlCreateEdit("", 0, 15, $aWinSize[0], $aWinSize[1])
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Debug Viewer", 0, 0, 100, 15)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 0, 15, 15)
#endregion

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit", $hMainForm)
GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
GUIRegisterMsg($WM_SIZE, "_WM_SIZE")
GUISetState(@SW_SHOW, $hMainForm)
_OpenNewProject(@ScriptDir & "\Test\TUC.tpf")
While 1
	Sleep(25)


WEnd


Func _FirstStartup()
	;If FileExists($MAINOPTFILE) then Return -1

	IniWrite($MAINOPTFILE, "MAIN", "LastProject", "")


	IniWrite($MAINOPTFILE, "MAIN", "X", 0)
	IniWrite($MAINOPTFILE, "MAIN", "Y", 0)
	IniWrite($MAINOPTFILE, "MAIN", "W", @DesktopWidth)
	IniWrite($MAINOPTFILE, "MAIN", "H", @DesktopHeight)

EndFunc
;============================Gui Functions=============================================
Func _CreateNewPage($NR = -1)

	Local $sDrive, $sPath, $sName, $sExt
	If $NR = -1 Then Return -1
	If $SourceFile[$NR][1][0] <> 0 Then Return -1


	If $SourceFile[$NR][4][0] = "" Then
		$SourceFile[$NR][1][1] = "Untiteld"
	Else
		_PathSplit($SourceFile[$NR][4][0], $sDrive, $sPath, $sName, $sExt)
		$SourceFile[$NR][1][1] = $sName & $sExt
	EndIf

	GUISwitch($hMainForm, $hTab)
	$SourceFile[$NR][1][0] = GUICtrlCreateTabItem($SourceFile[$NR][1][1])
	GUICtrlSetState($SourceFile[$NR][1][0], $GUI_SHOW)
	$SourceFile[$NR][2][0] = GUICtrlCreateEdit("Test" & $NR, 100 + $NR * 100,100,500,500)
	GUICtrlCreateTabItem("")

	_WinAPI_RedrawWindow($hTab)
EndFunc
Func _CreateNewBlankPage()
	$pos = _GUICtrlTab_GetItemCount($hTab)
	$SourceFile[$iSheetCounter][1][0] = _GUICtrlTab_InsertItem($hTab, $pos, "untiteld")
	;GUISwitch($hMainForm, $SourceFile[$NR][1][0])
	$SourceFile[$iSheetCounter][2][0] = GUICtrlCreateEdit("Test" & $iSheetCounter, 100,100,500,500)
	_RedimCounter()
EndFunc
Func _RedimCounter()
	$iSheetCounter += 1
	Redim $SourceFile[$iSheetCounter + 1][5][4]
EndFunc
;==============================FileFunctions==========================================
Func _OpenFile($NR = 0)



EndFunc
Func _AddFile($File);Funktion damit man eine Datei in den array hinzufügen kann
Endfunc
;=========================ProjectFunction==============================================
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
Return -1
EndFunc
Func _CreateNewProject($Language, $Name, $Direction, $Discription, $Type = "Win32", $Template = "Win32");nicht benutzen ungenaue erstellung
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

				FileCopy($SourceCodeDir & $Type & "Form.form", $ResourcesDir & $Name & ".form" )
				FileDelete($SourceCodeDir & $Type & "Form.form")

				FileCopy($SourceCodeDir & "\" & $Type & ".au3", $TemplateDestination)
				FileDelete($SourceCodeDir & "\" & $Type & ".au3")

				IniWrite($ProjectFile, "SourceFiles", $Name, $TemplateDestination)
				IniWrite($ProjectFile, "Forms", $Name, $ResourcesDir & $Name & ".form")
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
_GUICtrlTreeView_BeginUpdate($hProjectViewer)

	$PName = IniRead($TPFFile, "MAIN", "Name", "")
	$PVersion = IniRead($TPFFile, "MAIN", "Version", "")

	$ProjectTreeViewItem = _GUICtrlTreeView_Add($hProjectViewer, 0, $PName);Project TreeviewItem erstellen
	GUICtrlSetColor(-1, 0x323232)

	$FilesTreeViewItem = _GUICtrlTreeView_AddChild($hProjectViewer, $ProjectTreeViewItem, "Files");Files Treeview
	$Files = IniReadSection($TPFFile, "SourceFiles")
	If Not IsArray($Files) Then Return 0

	;ConsoleWrite("$Files[0][0]:" & $Files[0][0] & @lf)

	Local $y = 1, $iExt
	For $x = 1 To $Files[0][0] / 3
		$y = $x * 4
		$SourceFile[$iSheetCounter][3][0] = _GUICtrlTreeView_AddChild($hProjectViewer, $FilesTreeViewItem, $Files[$y - 3][0])


		$SourceFile[$iSheetCounter][4][0] = $Files[$y - 3][1];Pfad
		$SourceFile[$iSheetCounter][4][1] = $Files[$y - 2][1];Language
		$SourceFile[$iSheetCounter][4][2] = $Files[$y - 1][1];Include oder Header
		$SourceFile[$iSheetCounter][4][3] = $Files[$y    ][1];Version
		$SourceFile[$iSheetCounter][0][0] = $PName;PName
		$SourceFile[$iSheetCounter][0][1] = $PVersion ;PVersion
		_RedimCounter()
	Next

	#cs
	$ResourcesTreeViewItem = _GUICtrlTreeView_AddChild($hProjectViewer, $ProjectTreeViewItem, "Resources")
	$FormFiles = IniReadSection($TPFFile, "Forms")
	If Not IsArray($FormFiles) Then Return 0

	For $x = 1 To $FormFiles[0][0]
		_GUICtrlTreeView_AddChild($hProjectViewer, $ResourcesTreeViewItem, $FormFiles[$x][0] & ".form")
	Next
	#ce
	$BackupTreeViewItem = _GUICtrlTreeView_AddChild($hProjectViewer, $ProjectTreeViewItem, "Backup")

_GUICtrlTreeView_EndUpdate($hProjectViewer)

EndFunc
;=================================EXIT=================================================
Func _Exit()
	;FileDelete($MAINOPTFILE)

	;For $x = 0 to $iSheetCounter
;		MsgBox(0,"",$SourceFile[$x][2][0])
;	Next

	Exit
EndFunc
;=======================Registered Functions===========================================
Func _WM_SIZE($hWnd, $iMsg, $wParam, $lParam)

    ; Just call the GUIFrame resizing function here - do NOT use the _GUIFrame_ResizeReg function in the script
    _GUIFrame_SIZE_Handler($hWnd, $iMsg, $wParam, $lParam)

    Return "GUI_RUNDEFMSG"

EndFunc
Func _WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    Local $hWndFrom, $iCode, $tNMHDR
    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam) ; Informationen aus $ilParam filtern
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom")) ; Handle von dem das Event kommt
    $iCode = DllStructGetData($tNMHDR, "Code") ; Event herauslesen

    Switch $hWndFrom ; Event kam von ...
        Case GUICtrlGetHandle($hProjectViewer) ; Treeview ?
            Switch $iCode ; Welches Event?!
                Case $NM_DBLCLK  ; Ein klick?
                    Local $hSel = _GUICtrlTreeView_GetSelection($hProjectViewer)
					For $x = 0 to $iSheetCounter
						If $SourceFile[$x][3][0] = $hSel Then
							_CreateNewPage($x)
						EndIf

					Next

					;_FileOpen($hSel)
				EndSwitch
		Case GUICtrlGetHandle($hProjectViewer)

    EndSwitch
EndFunc   ;==>_WM_NOTIFY
;=========================Irgendwas====================================================
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