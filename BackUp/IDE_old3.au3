#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <TreeViewConstants.au3>
#include <ButtonConstants.au3>
#include <GuiStatusBar.au3>
#include <GuiTreeView.au3>
#include <GuiRichEdit.au3>
#include <GuiTab.au3>
#include <GuiToolBar.au3>
#include <File.au3>
#include <Array.au3>
#include <WInAPI.au3>
#include <IE.au3>
#include <Misc.au3>
#include <GDIPlus.au3>
#include <GuiMenu.au3>
#include "[INCLUDE]\ModernMenuLib\ModernMenuRaw.au3"
#include "[INCLUDE]\GuiFrame\GuiFrame.au3"
#include "[INCLUDE]\SciLexer\_SciLexer.au3"

AutoItSetOption("GUIOnEventMode", 1)
_GDIPlus_Startup()

Global Const $TUCNAME = "TUC 0.0.0.1"
Global $hMainForm
Global $hTab
Global $oIE[1]
Global $GUIActiveX[1]

$DLL = DllOpen("user32.dll")


Global $LanguageArray[1][3]
;[n][0] = LanguageName; [n][1] = HeaderdateiExt; [n][2] = SourcedateiExt
$LanguageArray[0][0] = "AutoIt"
$LanguageArray[0][1] = ".au3"
$LanguageArray[0][2] = ".au3"

Global $iSheetCounter = -1;F�r alles Counter
Global $iItem ; Command identifier of the button associated with the notification.
Global $DefaultLanguage = "AutoIt"
Global $DefaultExt = ".au3"
Global $sDrive, $sPath, $sName, $sExt


Global $FileArray[1][4]
;[n][0] = Name
;[n][1] = FileExt
;[n][2] = File
;[n][3] = $iSheetCounter
Global $TabArray[1][4]
;[n][0] = TabId
;[n][1] = TabName
;[n][2] = NR im FileArray
;[n][3] = ID im Current Open Treeview
Global $FileTreeviewArray[1];Damit ich die Daten oben links f�r den ExplorerTreeview Auflisten kann und zwar die die im Explorer stehen
;[0] = Current Dir
;[1] = ItemID
;[2] = File

Global $hProjectViewer ;Treeview f�r das Project rechts oben
Global $hTreeviewExplorer; Treeview F�r die faten rechts oben

Global $XAbstand = 300;Abstand vom edit zum rechten Rand
Global $YAbstand = 300;Abstand vom edit zum unteren Rand


Global $MAINOPTFILE = @ScriptDir & "\Main.ini"
_FirstStartup();wird immer aufgerufen der check finded in der Func statt
#region ### START Koda GUI section ###
$hMainForm = GUICreate($TUCNAME, IniRead($MAINOPTFILE, "MAIN", "W", 0), IniRead($MAINOPTFILE, "MAIN", "H", 0), -1, -1, $WS_SIZEBOX + $WS_MAXIMIZE + $WS_MAXIMIZEBOX + $WS_CAPTION + $WS_MINIMIZEBOX + $WS_CLIPCHILDREN)
Local $aParts[3] = [75, 1000, -1]
$hStatusbar = _GUICtrlStatusBar_Create($hMainForm, $aParts)
$ret = _GUICtrlStatusBar_SetText($hStatusbar, "Hallo", 1)
#endregion ### END Koda GUI section ###
#region Menu
;_SetFlashTimeOut(250)

Global Const $MenuColor = 0xFFFFFF
Global Const $MenuBKColor = 0x921801
Global Const $MenuBKGradColor = 0xFBCE92

$FileMenu = GUICtrlCreateMenu("&File")

$FileNewProjectItem = _GUICtrlCreateODMenuItem("&New Project" & @TAB & "Ctrl+C", $FileMenu)
_GUICtrlCreateODMenuItem("", $FileMenu)
$FileNewFileItem = _GUICtrlCreateODMenuItem("&New...", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -55)
$FileOpenFileItem = _GUICtrlCreateODMenuItem("&Open...", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -5)
GUICtrlSetOnEvent(-1, "_OpenFileDialog")
$FileOpenFileItem = _GUICtrlCreateODMenuItem("&Open Form...", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -5)
GUICtrlSetOnEvent(-1, "_OpenFormDialog")
_GUICtrlCreateODMenuItem("", $FileMenu)

$FileSaveFileItem = _GUICtrlCreateODMenuItem("&Save...", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -79)
$FileSaveAsItem = _GUICtrlCreateODMenuItem("&Save As", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -79)
$FileSaveAllItem = _GUICtrlCreateODMenuItem("&Save All", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", -79)
_GUICtrlCreateODMenuItem("", $FileMenu)

$FileCloseFileItem = _GUICtrlCreateODMenuItem("&Close Current Page", $FileMenu)
$FileCloseProjectItem = _GUICtrlCreateODMenuItem("&Close Current Project", $FileMenu)
_GUICtrlCreateODMenuItem("", $FileMenu)

$FileExitItem = _GUICtrlCreateODMenuItem("&Exit" & @TAB & "Esc", $FileMenu)
_GUICtrlODMenuItemSetIcon(-1, "shell32.dll", 28)
GUICtrlSetOnEvent(-1, "_Exit")

$EditMenu = GUICtrlCreateMenu("&Edit")
_GUICtrlCreateODMenuItem("&Redo", $EditMenu)
_GUICtrlCreateODMenuItem("&Undo", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu)
_GUICtrlCreateODMenuItem("&Cut", $EditMenu)
_GUICtrlCreateODMenuItem("&Copy", $EditMenu)
_GUICtrlCreateODMenuItem("&Paste", $EditMenu)
_GUICtrlCreateODMenuItem("", $EditMenu)
_GUICtrlCreateODMenuItem("&Delete", $EditMenu)
_GUICtrlCreateODMenuItem("&Duplicate", $EditMenu)
_GUICtrlCreateODMenuItem("&Select All", $EditMenu)

$ViewMenu = GUICtrlCreateMenu("&View")
_GUICtrlCreateODMenuItem("Project Viewer", $ViewMenu)
_GUICtrlCreateODMenuItem("Properties Viewer", $ViewMenu)
_GUICtrlCreateODMenuItem("Debug Window", $ViewMenu)
_GUICtrlCreateODMenuItem("Output Viewer", $ViewMenu)


$ProjectMenu = GUICtrlCreateMenu("&Search")

$ProjectMenu = GUICtrlCreateMenu("&Project")

$OptionsMenu = GUICtrlCreateMenu("&Options")
_GUICtrlCreateODMenuItem("Directions", $OptionsMenu)
GUICtrlSetOnEvent(-1, "_OptionsOpenDirections")




;$FileSaveProjectItem = _GUICtrlCreateODMenuItem("&Save Project" & @TAB & "Ctrl+S", $FileMenu, "shell32.dll", -7)
;_GUICtrlODMenuItemSetSelIcon(-1, "shell32.dll", -79)

#endregion Menu



#region ToolBar
$hToolbar = _GUICtrlToolbar_Create($hMainForm)

$hImage = _GUIImageList_Create(16, 16, 6, 1)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 110)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 131)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 165)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 168)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 137)
    _GUIImageList_AddIcon($hImage, "shell32.dll", 146)

;_GUIImageList_AddIcon($hImage, @SystemDir & "\shell32.dll", 54);New Paper
;_GUICtrlToolbar_SetImageList($hToolbar, $hImage)


_GUICtrlToolbar_AddBitmap($hToolbar, 1, -1, $IDB_STD_SMALL_COLOR)

Global Enum $idNew = 1000, $idOpen, $idSave, $idDelete, $idPrint, $idCut, $idCopy, $idPaste, $idRedow, $idUndo, $idFind, $idReplace
_GUICtrlToolbar_AddButton($hToolbar, $idNew, $STD_FILENEW)
_GUICtrlToolbar_AddButton($hToolbar, $idOpen, $STD_FILEOPEN)
_GUICtrlToolbar_AddButton($hToolbar, $idSave, $STD_FILESAVE)
_GUICtrlToolbar_AddButton($hToolbar, $idDelete, $STD_DELETE)
_GUICtrlToolbar_AddButtonSep($hToolbar)
_GUICtrlToolbar_AddButton($hToolbar, $idPrint, $STD_PRINT)
_GUICtrlToolbar_AddButtonSep($hToolbar)
_GUICtrlToolbar_AddButton($hToolbar, $idCut, $STD_CUT)
_GUICtrlToolbar_AddButton($hToolbar, $idCopy, $STD_COPY)
_GUICtrlToolbar_AddButton($hToolbar, $idPaste, $STD_PASTE)
_GUICtrlToolbar_AddButtonSep($hToolbar)
_GUICtrlToolbar_AddButton($hToolbar, $idUndo, $STD_UNDO)
_GUICtrlToolbar_AddButton($hToolbar, $idRedow, $STD_REDOW)
_GUICtrlToolbar_AddButtonSep($hToolbar)
_GUICtrlToolbar_AddButton($hToolbar, $idFind, $STD_FIND)
_GUICtrlToolbar_AddButton($hToolbar, $idReplace, $STD_REPLACE)
#endregion ToolBar


;======
#region Controles
$iFrame_MID = _GUIFrame_Create($hMainForm, 0, @DesktopWidth - $XAbstand);MAin
_GUIFrame_SetMin($iFrame_MID, 100, 100)

$iFrame_MID_RIGHT = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_MID, 2), 1);Rechts
_GUIFrame_SetMin($iFrame_MID_RIGHT, 300, 300)


$iFrame_MID_LEFT = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_MID, 1), 1, @DesktopHeight - $YAbstand + 30, 5);links
_GUIFrame_SetMin($iFrame_MID_RIGHT, 100, 100)

$iFrame_MID_MID = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_MID_LEFT, 2));Linksunten
_GUIFrame_SetMin($iFrame_MID_RIGHT, 100, 100)
_GUIFrame_ResizeSet(0)





_GUIFrame_Switch($iFrame_MID_RIGHT, 1);rechts oben
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_RIGHT, 1))
GUICtrlCreateTab(0, 50, $aWinSize[0], $aWinSize[1] - 50, $TCS_BOTTOM, $TCS_FLATBUTTONS)
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Project Viewer", 0, 30, 100, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 30, 15, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)

GUICtrlCreateTabItem("File Explorer")
$TreeviewExplorer = GUICtrlCreateTreeView(1, 51, $aWinSize[0], $aWinSize[1] - 71, BitOR($TVS_EDITLABELS, $TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS))
$hTreeviewExplorer = GUICtrlGetHandle($TreeviewExplorer)
_GUICtrlTreeView_SetNormalImageList($hTreeviewExplorer, $hImage)


Global $TreeviewFileExplorer, $TreeviewFileCurrent
$TreeviewFileCurrent = _GUICtrlTreeView_Add($hTreeviewExplorer, 0, "Current Open")
$TreeviewFileExplorer = _GUICtrlTreeView_Add($hTreeviewExplorer, 0, "Explorer")

$Search = FileFindFirstFile(@ScriptDir & "\*.*")
While 1
    $File = FileFindNextFile($Search)
    If @error Then ExitLoop

	$ID = GUICtrlCreateTreeViewItem($File, $TreeviewFileExplorer)
	_ArrayAdd($FileTreeviewArray, $ID)
	_ArrayAdd($FileTreeviewArray, @ScriptDir & "\" & $File)
WEnd
$FileTreeviewArray[0] = @ScriptDir & "\"

GUICtrlCreateTabItem("Project Explorer")
$hProjectViewer = GUICtrlCreateTreeView(1, 51, $aWinSize[0], $aWinSize[1] - 71, $TVS_DISABLEDRAGDROP)


GUICtrlCreateTabItem("Functions")
GUICtrlCreateTabItem("")


_GUIFrame_Switch($iFrame_MID_RIGHT, 2);rechts unten
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_RIGHT, 2))
GUICtrlCreateListView("Property |Value ", 0, 16, $aWinSize[0], $aWinSize[1])
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Properties Viewer", 0, 0, 100, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 0, 15, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)


_GUIFrame_Switch($iFrame_MID_MID, 2);links unten rechts
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_MID, 2))
GUICtrlCreateEdit("", 0, 16, $aWinSize[0], $aWinSize[1])
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Output Viewer", 0, 0, 100, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 0, 15, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
GUICtrlSetOnEvent(-1, "_ShowArray2")

_GUIFrame_Switch($iFrame_MID_MID, 1);links unten links
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_MID, 1))
GUICtrlCreateEdit("", 0, 15, $aWinSize[0], $aWinSize[1])
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

GUICtrlCreateLabel("Debug Viewer", 0, 0, 100, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
GUICtrlCreateButton("X", $aWinSize[0] - 15, 0, 15, 15)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
GUICtrlSetOnEvent(-1, "_ShowArray")


_GUIFrame_Switch($iFrame_MID_LEFT, 1);links oben
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_MID_LEFT, 1))
$iTab = GUICtrlCreateTab(0, 27, $aWinSize[0], $aWinSize[1] - 10, $TCS_BUTTONS + $TCS_FLATBUTTONS)
GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
$hTab = GUICtrlGetHandle($iTab)

#endregion Controles

;
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit", $hMainForm)
GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
GUIRegisterMsg($WM_SIZE, "_WM_SIZE")
_IEErrorHandlerRegister()
GUISetState(@SW_SHOW, $hMainForm)
_OpenFile("")
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

EndFunc   ;==>_FirstStartup

Func _ShowArray()
	_ArrayDisplay($FileArray)
	_ArrayDisplay($FileTreeviewArray)
EndFunc   ;==>_ShowArray
Func _ShowArray2()
	_ArrayDisplay($TabArray)
EndFunc   ;==>_ShowArray2
;==============================FileFunctions===========================================
Func _OpenFileDialog()
	$file = FileOpenDialog("Select a File", "", "All Files(*.*)")
	_OpenFile($file)
EndFunc   ;==>_OpenFileDialog
Func _NewFileDialog();Nicht fertig

EndFunc   ;==>_NewFileDialog
Func _OpenFile($file)
	If $file = "" Then
		$sName = "Untitled"
		$sExt = ".au3"
	Else
		_PathSplit($file, $sDrive, $sPath, $sName, $sExt)
	EndIf

	_CreateTabItem($sName & $sExt)

	$FileArray[$iSheetCounter][0] = $sName
	$FileArray[$iSheetCounter][1] = $sExt
	$FileArray[$iSheetCounter][2] = $file

	$TabArray[$iSheetCounter][3] = _GUICtrlTreeView_AddChild($hTreeviewExplorer,$TreeviewFileCurrent,$sName & $sExt, 2)

	_LoadFile($file)
	_FileExplorerTreeviewSet($sDrive & $sPath)
EndFunc   ;==>_OpenFile
Func _SaveFile($NR)
	If $FileArray[$NR][2] = "" Then $FileArray[$NR][2] = FileSaveDialog("Please Select a File", "", "AutoIt (*.au3)")
	If $FileArray[$NR][2] = "" Then Return -1

	FileWrite($FileArray[$NR][2], _IEBodyReadText($oIE[$NR]))
EndFunc   ;==>_SaveFile
Func _LoadFile($sFilename = "")
	If IniRead($MAINOPTFILE, "Main", "EditorMode", 1) = 0 Then
		$sSelected_Language_Name = ""
		$sSelected_Language_File = ""
		;$sCombo_Selected = GUICtrlRead($c_Combo_LanguageDef)
		;For $i = 0 To UBound($aLanguageDef) - 1
		;	If $sCombo_Selected = $aLanguageDef[$i][1] Then
		;		$sSelected_Language_File = $aLanguageDef[$i][0]
		;		$sSelected_Language_Name = $aLanguageDef[$i][1]
		;	EndIf
		;Next

		;If Not $sSelected_Language_Name Or Not FileExists(@ScriptDir & "\GeSHI-GUI\geshi\" & $sSelected_Language_File) Then
		;	MsgBox(16 + 262144, $sTitle & " - Error", "Error selecting language.")
		;	Return
		;EndIf
		$sSelected_Language_File = "autoit"
		$sSelected_Language_Name = "AutoIt"

		;If Not FileExists($sFilename) Then
		;	$sFilename = FileOpenDialog($sTitle & " - Select """ & $sSelected_Language_Name & """ source file...", @ScriptDir, "All (*.*)")
		;	If @error Then Return
		;EndIf
		$sFilename_Save = $sFilename

		Local $sHTML
		Local $sHTML_FontFamily = "Arial"
		Local $sHTML_FontSize = "12px"
		Local $sHTML_Height = "16px"
		Local $sHTML_Class = "autoit"

		$timer = TimerInit()
		_IENavigate($oIE[$iSheetCounter], "about:blank")
		If @error Then MsgBox(0, "1", @error)

		$oBody = _IETagNameGetCollection($oIE[$iSheetCounter], "body", 0)
		If @error Then MsgBox(0, "2", @error)

		$sFilename_display = StringRight($sFilename, StringLen($sFilename) - StringInStr($sFilename, "\", 0, -1))
		;WinSetTitle($hGui, "", $sTitle & " - Syntax: " & $sSelected_Language_Name & ", File: " & $sFilename_display)

		$hFile = FileOpen($sFilename)
		$sFile = FileRead($hFile)
		FileClose($hFile)

		$iFileSize = FileGetSize($sFilename)
		;WinSetTitle($hGui, "", $sTitle & " - Syntax: " & $sSelected_Language_Name & ", File: " & $sFilename_display & " (" & _StringAddThousandsSepEx($iFileSize) & " bytes)")

		$aFile = StringSplit($sFile, @CR)
		;GUICtrlSetState($c_Button_ClipPut, $GUI_ENABLE)

		$GESHIDir = @ScriptDir & "\[INCLUDE]\Geshi\GeSHI-GUI\"

		$sFileCunk = ""
		$iChunkNum = 0
		For $i = 1 To $aFile[0]

			$sFileCunk &= $aFile[$i]

			If Not Mod($i, 500) Then
				$iChunkNum += 1

				$hFileChunk = FileOpen($GESHIDir & "chunk.tmp", 2)
				FileWrite($hFileChunk, $sFileCunk)
				FileClose($hFileChunk)
				$sFileCunk = ""

				$sHTML = ""
				$sPHP = """include('" & $GESHIDir & "geshi.php'); $source = file_get_contents('" & $GESHIDir & "chunk.tmp" & "'); $language = '" & $sSelected_Language_Name & "'; $path = '[INCLUDE]\GeSHI-GUI/geshi/'; $geshi = new GeSHi($source, $language, $path); echo $geshi->parse_code();"""
				$foo = Run($GESHIDir & "php.exe -r " & $sPHP, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
				If @error Then MsgBox(0, "3", @error)

				While 1
					$sHTML &= StdoutRead($foo)
					If @error Then ExitLoop
				WEnd

				$sHTML = StringReplace($sHTML, '<pre class="autoit" style="font-family:monospace;">', '')
				$sHTML = StringReplace($sHTML, '</pre>', '')
				$sHTML = StringReplace($sHTML, '&nbsp;', '')
				If $iChunkNum < 2 Then
					$sHTML = '<pre class="' & $sHTML_Class & '" style=''margin-top:-10px;font-family:"' & $sHTML_FontFamily & '";font-size:' & $sHTML_FontSize & ';line-height:' & $sHTML_Height & ';''>' & $sHTML & "</pre>"
				Else
					$sHTML = '<pre class="' & $sHTML_Class & '" style=''margin-top:-35px;font-family:"' & $sHTML_FontFamily & '";font-size:' & $sHTML_FontSize & ';line-height:' & $sHTML_Height & ';''>' & $sHTML & "</pre>"
				EndIf

				_IEDocInsertHTML($oBody, $sHTML, "beforeend")

			EndIf

		Next

		If $sFileCunk Then

			$hFileChunk = FileOpen($GESHIDir & "chunk.tmp", 2)
			FileWrite($hFileChunk, $sFileCunk)
			FileClose($hFileChunk)
			$sFileCunk = ""

			$sHTML = ""
			$sPHP = """include('" & $GESHIDir & "geshi.php'); $source = file_get_contents('" & $GESHIDir & "chunk.tmp" & "'); $language = '" & StringReplace($sSelected_Language_File, ".php", "") & "'; $path = '[INCLUDE]GeSHI-GUI/geshi/'; $geshi = new GeSHi($source, $language, $path); echo $geshi->parse_code();"""
			$foo = Run(@ScriptDir & "\GeSHI-GUI\php.exe -r " & $sPHP, @ScriptDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

			While 1
				$sHTML &= StdoutRead($foo)
				If @error Then ExitLoop
			WEnd

			$sHTML = StringReplace($sHTML, '<pre class="autoit" style="font-family:monospace;">', '')
			$sHTML = StringReplace($sHTML, '</pre>', '')
			$sHTML = StringReplace($sHTML, '&nbsp;', '')
			If $iChunkNum < 2 Then
				$sHTML = '<pre class="' & $sHTML_Class & '" style=''margin-top:-10px;font-family:' & $sHTML_FontFamily & ';font-size:' & $sHTML_FontSize & ';line-height:' & $sHTML_Height & ';''>' & $sHTML & "</pre>"
			Else
				$sHTML = '<pre class="' & $sHTML_Class & '" style=''margin-top:-35px;font-family:"' & $sHTML_FontFamily & '";font-size:' & $sHTML_FontSize & ';line-height:' & $sHTML_Height & ';''>' & $sHTML & "</pre>"
			EndIf

			_IEDocInsertHTML($oBody, $sHTML, "beforeend")

		EndIf
	ElseIf IniRead($MAINOPTFILE, "Main", "EditorMode", 1) = 1 Then

		$hFile = FileOpen($sFilename, 0)
		Sci_AddLines($GUIActiveX[$iSheetCounter], FileRead($hFile), 0)
		FileClose($hFile)
	ElseIf IniRead($MAINOPTFILE, "Main", "EditorMode", 1) = 2 Then

		$hFile = FileOpen($sFilename, 0)
		GUICtrlSetData($GUIActiveX[$iSheetCounter], FileRead($hFile))
		FileClose($hFile)
	EndIf


EndFunc   ;==>_LoadFile
Func _FileExplorerTreeviewSet($Dir)
		_GUICtrlTreeView_BeginUpdate($hTreeviewExplorer)

		$Search = FileFindFirstFile($Dir & "*.*")
		_GUICtrlTreeView_Delete($hTreeviewExplorer, $TreeviewFileExplorer)
		$TreeviewFileExplorer = _GUICtrlTreeView_Add($hTreeviewExplorer, 0, "Explorer")

		For $x = UBound($FileTreeviewArray) to 2 Step -1
			_ArrayDelete($FileTreeviewArray, $x)
		Next

		While 1
			$File = FileFindNextFile($Search)
			If @error Then ExitLoop

			_PathSplit($File, $sDrive, $sPath, $sName, $sExt)
			Switch $sExt
				Case ".au3"
					$ID = _GUICtrlTreeView_AddChild($hTreeviewExplorer, $TreeviewFileExplorer, $File, 1)
				Case ""
					$ID = _GUICtrlTreeView_AddChild($hTreeviewExplorer, $TreeviewFileExplorer, $File, 2)
				Case Else

			EndSwitch

			_ArrayAdd($FileTreeviewArray, $ID)
			_ArrayAdd($FileTreeviewArray, $Dir & $File)
		WEnd

		_GUICtrlTreeView_EndUpdate($hTreeviewExplorer)
		If $Dir <> "" Then $FileTreeviewArray[0] = $Dir
EndFunc
Func _RunScript($Compiler, $CMD, $File)


EndFunc
;=============================FormFunctions============================================
Func _OpenFormDialog();Nichtfertig
	$file = FileOpenDialog("Select a File", "", "All Files(*.form)")
	If $file = "" Then Return -1
	_OpenForm($file)
EndFunc   ;==>_OpenFormDialog
Func _OpenForm($file);Nicht fertig
	$Name = IniRead($file, "Main Form", "Name", "Form1")
	$W = IniRead($file, "Main Form", "W", 500)
	$H = IniRead($file, "Main Form", "H", 500)
	$X = IniRead($file, "Main Form", "X", -1)
	$Y = IniRead($file, "Main Form", "Y", -1)
	$Styles = IniRead($file, "Main Form", "Styles", -1)
	$ExStyles = IniRead($file, "Main Form", "ExStyles", -1)

	_CreateTabItem($Name, True)

	_GUIFrame_Switch($iFrame_MID_LEFT, 1);links oben
	$Edit = GUICtrlCreateEdit("",0,50,@DesktopWidth - $XAbstand,@DesktopHeight - $YAbstand)
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)

	$DrawGui = GUICreate($Name, $W, $H, $X, $Y, $Styles + 0x00040000, $ExStyles)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_GUIMsgLoop", $DrawGui)
	;GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "_GUIMsgLoop", $DrawGui)

	$style = DllCall("user32.dll", "int", "GetWindowLong", "hwnd", $DrawGui, "int", 236)
	DllCall("user32.dll", "int", "SetWindowLong", "hwnd", $DrawGui, "int", 236, "int", BitOR($style[0], $WS_EX_MDICHILD))
	DllCall("user32.dll", "int", "SetParent", "hwnd", $DrawGui, "hwnd", GUICtrlGetHandle($Edit))
	GUISetState(@SW_SHOW, $DrawGui)

	_CreateToolBox(GUICtrlGetHandle($Edit))
	_GenerateCodeFromForm($File)
EndFunc   ;==>_OpenForm
Func _CreateToolBox($hWnd)
	;Ich lagere diese Funktion aus, damit ich sp�ter keine proble habe die Buttons zu identifizieren
	$ToolBox = GUICreate("ToolBox", 55, @DesktopHeight - $YAbstand, 0, 27, 0x90000000, -1)
	GUISetBkColor(0xFFFFFF)
	$style = DllCall("user32.dll", "int", "GetWindowLong", "hwnd", $ToolBox, "int", 236)
	DllCall("user32.dll", "int", "SetWindowLong", "hwnd", $ToolBox, "int", 236, "int", BitOR($style[0], $WS_EX_MDICHILD))
	DllCall("user32.dll", "int", "SetParent", "hwnd", $ToolBox, "hwnd", $hWnd)
	GUISetState(@SW_SHOW, $ToolBox)

	Local $LEFT = 0, $TOP = 5, $ButtonArray
	For $X = 0 to 10
		GUICtrlCreateButton("", $LEFT, $TOP, 25, 25, $BS_ICON)
		If $LEFT = 25 Then $TOP += 25
		If $LEFT = 0 Then
			$LEFT = 25
		Else
			$LEFT = 0
		EndIf
	Next
EndFunc
Func _GUIMsgLoop();Nicht fertig
	Select
		Case @GUI_CtrlId = $GUI_EVENT_CLOSE
			MsgBox(0,"","")
    EndSelect
EndFunc
Func _GenerateCodeFromForm($File)
	Local $code
	$Code  = ";This File is coded by " & IniRead($File, "Main Form", "Programmer", "Unknown") & @CRLF

	$Name = IniRead($file, "Main Form", "Name", "Form1")
	$W = IniRead($file, "Main Form", "W", 500)
	$H = IniRead($file, "Main Form", "H", 500)
	$X = IniRead($file, "Main Form", "X", -1)
	$Y = IniRead($file, "Main Form", "Y", -1)
	$Styles = IniRead($file, "Main Form", "Styles", -1)
	$ExStyles = IniRead($file, "Main Form", "ExStyles", -1)
	$Parent = IniRead($file, "Main Form", "Parent", 0)

	$Code &= "GuiCreate('" & $Name & "', " & $W & ", " & $H & ", " & $X & ", " & $Y & ", " & $Styles & ", " & $ExStyles& ", " & $Parent & ")" & @CRLF


	$Code &= @CRLF & "While 1" & @CRLF
	$Code &= "	Sleep(25)" & @CRLF
	$Code &= "Wend" & @CRLF
	_OpenFile($Name & ".au3")
	GUICtrlSetData($GUIActiveX[$iSheetCounter], $Code)
EndFunc
;=================================TAB==================================================
Func _CreateTabItem($Text, $GUI = False)
	$iSheetCounter += 1
	ReDim $FileArray[$iSheetCounter + 1][4]
	ReDim $TabArray[$iSheetCounter + 1][4]

	ReDim $oIE[$iSheetCounter + 1]
	ReDim $GUIActiveX[$iSheetCounter + 1]

	_GUIFrame_Switch($iFrame_MID_LEFT, 1);links oben

	$TabArray[$iSheetCounter][1] = $Text
	$TabArray[$iSheetCounter][2] = $iSheetCounter
	If $GUI = False Then
		If IniRead($MAINOPTFILE, "Main", "EditorMode", 1) = 0 Then
			$TabArray[$iSheetCounter][0] = GUICtrlCreateTabItem($Text)
			$oIE[$iSheetCounter] = _IECreateEmbedded()
			$GUIActiveX[$iSheetCounter] = GUICtrlCreateObj($oIE[$iSheetCounter], 0, 50, @DesktopWidth - $XAbstand, @DesktopHeight - $YAbstand + 30)
			GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
		Elseif IniRead($MAINOPTFILE, "Main", "EditorMode", 1) = 1 Then
			$TabArray[$iSheetCounter][0] = GUICtrlCreateTabItem($Text)
			$GUIActiveX[$iSheetCounter] = Sci_CreateEditor($hMainForm, 0, 50, @DesktopWidth - $XAbstand - 100, @DesktopHeight - $YAbstand - 100)
			GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
		Elseif IniRead($MAINOPTFILE, "Main", "EditorMode", 1) = 2 Then
			$TabArray[$iSheetCounter][0] = GUICtrlCreateTabItem($Text)
			$GUIActiveX[$iSheetCounter] = GUICtrlCreateEdit("", 0, 50, @DesktopWidth - $XAbstand, @DesktopHeight - $YAbstand )
			GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
		EndIf
	Else
		$TabArray[$iSheetCounter][0] = GUICtrlCreateTabItem($Text)
	EndIf
	$FileArray[$iSheetCounter][3] = $iSheetCounter

	GUICtrlCreateTabItem("")
EndFunc   ;==>_CreateTabItem
Func _DeleteTabItem($NR);Geht  Nicht
	If _IsTabSaved($NR) = False Then
		GUICtrlDelete($TabArray[$NR][0])
		_ArrayDelete($TabArray, $NR)
		_ArrayDelete($FileArray, $NR)
		;jetzt M�ssen die Beiden Arrays nach Unten verschoben werden
		If $NR <> $iSheetCounter Then
			For $X = 0 To $NR - 1
				$TabArray[$X][0] = $TabArray[$X + 1][0]
				$TabArray[$X][1] = $TabArray[$X + 1][1]

				$FileArray[$X][0] = $FileArray[$X + 1][0]
				$FileArray[$X][1] = $FileArray[$X + 1][1]
				$FileArray[$X][2] = $FileArray[$X + 1][2]
				$FileArray[$X][3] = $FileArray[$X + 1][3]
			Next
		EndIf
		$iSheetCounter -= 1
	EndIf
EndFunc   ;==>_DeleteTabItem
Func _IsTabSaved($NR);Geht Nicht
	Return False
EndFunc   ;==>_IsTabSaved
;===============================MENU===================================================
Func _MenuSaveFile($NR)
	_SaveFile($NR)
EndFunc   ;==>_MenuSaveFile
Func _MenuLoadFile()
	_OpenFileDialog()
EndFunc   ;==>_MenuLoadFile
;=============================Options==================================================
Func _OptionsOpenDirections()
$Form1 = GUICreate("Form1", 549, 256, 426, 369)
$Form1_GUICtrlTab_InsertItem($List1, 0, "Tab 1")
_GUICtrlTab_InsertItem($List1, 1, "Tab 2")
_GUICtrlTab_InsertItem($List1, 2, "Tab 3")

$ListView1 = GUICtrlCreateListView("", 160, 40, 386, 182)
$Button1 = GUICtrlCreateButton("Add", 272, 8, 75, 25)
$Button2 = GUICtrlCreateButton("Remove", 368, 8, 75, 25)
$Button3 = GUICtrlCreateButton("Edit", 464, 8, 75, 25)
GUISetState(@SW_SHOW)
EndFunc
;=================================EXIT=================================================
Func _Exit()
	Exit
EndFunc   ;==>_Exit
;=======================Registered Functions===========================================
Func _WM_SIZE($hWnd, $iMsg, $wParam, $lParam)

	; Just call the GUIFrame resizing function here - do NOT use the _GUIFrame_ResizeReg function in the script
	_GUIFrame_SIZE_Handler($hWnd, $iMsg, $wParam, $lParam)

	Return "GUI_RUNDEFMSG"

EndFunc   ;==>_WM_SIZE
Func _WM_NOTIFY($hWndGUI, $MsgID, $wParam, $lParam)
	#forceref $hWndGUI, $MsgID, $wParam
	Local $tNMHDR, $event, $hwndFrom, $code, $i_idNew, $dwFlags, $lResult, $idFrom, $i_idOld
	Local $tNMTOOLBAR, $tNMTBHOTITEM
	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hwndFrom = DllStructGetData($tNMHDR, "hWndFrom")
	$idFrom = DllStructGetData($tNMHDR, "IDFrom")
	$code = DllStructGetData($tNMHDR, "Code")
	Switch $hwndFrom
		Case $hToolbar
			Switch $code
				Case $NM_LDOWN
					;----------------------------------------------------------------------------------------------
					Switch $iItem
						Case $idNew
							_OpenFile("")
						Case $idOpen
							_MenuLoadFile()
						Case $idSave
							_MenuSaveFile(_GUICtrlTab_GetCurFocus($hTab))
						Case $idDelete
							_DeleteTabItem(_GUICtrlTab_GetCurFocus($hTab))
					EndSwitch
					;----------------------------------------------------------------------------------------------
				Case $TBN_HOTITEMCHANGE
					$tNMTBHOTITEM = DllStructCreate($tagNMTBHOTITEM, $lParam)
					$i_idNew = DllStructGetData($tNMTBHOTITEM, "idNew")
					$iItem = $i_idNew
			EndSwitch
		Case $hTab
			Switch $code
				Case $NM_CLICK
					$Focus = _GUICtrlTab_GetCurFocus($hTab)
					If $FileArray[$TabArray[$Focus][2]][2] Then
						_PathSplit($FileArray[$TabArray[$Focus][2]][2], $sDrive, $sPath, $sName, $sExt)
						_FileExplorerTreeviewSet($sDrive & $sPath)
					EndIf
				EndSwitch
		Case $hTreeviewExplorer
			Switch $code
				Case $NM_DBLCLK
					$Focus = _GUICtrlTreeView_GetSelection($hTreeviewExplorer)

					Dim $z = 1, $y = 0
					For $x = 0 To UBound($FileTreeviewArray);Checkt ob ein neues Fenster ge�ffnet werden soll
						$y = $x + $z
						If $y < UBound($FileTreeviewArray) Then
							If $Focus = $FileTreeviewArray[$y] Then
								_PathSplit($FileTreeviewArray[$y + 1], $sDrive, $sPath, $sName, $sExt)

								If $sExt = ".au3" Then _OpenFile($FileTreeviewArray[$y + 1])
								If $sExt = ".form" Then _OpenForm($FileTreeviewArray[$y + 1])
								If $sExt = "" Then _FileExplorerTreeviewSet($FileTreeviewArray[0] & $sName & "\")

							ElseIf $Focus = $TreeviewFileExplorer Then;Wenn man zur�ck clickt
								$Found = StringInStr($FileTreeviewArray[0], "\", 0 , -2)
								$Dir = StringTrimRight($FileTreeviewArray[0], StringLen($FileTreeviewArray[0]) - $Found)
								_FileExplorerTreeviewSet($Dir)
							EndIf

						EndIf
						$z += 1
					Next

					For $x = 0 To UBound($TabArray) - 1
						If $Focus = GUICtrlGetHandle($TabArray[$x][3]) Then GUICtrlSetState($TabArray[$x][0], $GUI_FOCUS)
					Next
				EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
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
EndFunc   ;==>_7ZIPExtract0