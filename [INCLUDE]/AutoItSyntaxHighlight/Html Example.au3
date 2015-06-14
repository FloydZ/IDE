#include "Au3SyntaxHighlight.au3"

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <IE.au3>
#Include <GuiRichEdit.au3>

$iAu3SH_AddURLs = 1

$sInitDir = ""
$sFilter = "*.au3"

$sMRUList = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU\au3", "MRUList")
$sLastFileOpenPath = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU\au3", StringLeft($sMRUList, 1))

If Not FileExists($sLastFileOpenPath) Then
	$sInitDir = @ScriptDir
	$sFilter = "Test Script.au3"
EndIf

$sFile = FileOpenDialog("Open Au3 Script File", $sInitDir, "AutoIt Script (" & $sFilter & ")")
If @error Then Exit

$sAu3Code = FileRead($sFile)
$sAu3Syntax_HighlightedCode = _Au3_SyntaxHighlight_Proc($sAu3Code, 0)


$hWnd = GUICreate("AutoIt Syntax Highlighter [" & $sFile & "]", @DesktopWidth-10, @DesktopHeight-70, 0, 0, $WS_OVERLAPPEDWINDOW + $WS_VISIBLE + $WS_CLIPSIBLINGS + $WS_CLIPCHILDREN)

$GUIActiveX = _GUICtrlRichEdit_Create($hWnd, $sAu3Syntax_HighlightedCode, 10, 20, @DesktopWidth-5-20, @DesktopHeight-200-40)

$GUI_Button_Back = GUICtrlCreateButton("Back", 10, @DesktopHeight-200, 100, 30)
$GUI_Button_Forward = GUICtrlCreateButton("Forward", 120, @DesktopHeight-200, 100, 30)
$GUI_Button_Home = GUICtrlCreateButton("Home", 230, @DesktopHeight-200, 100, 30)
$GUI_Button_Stop = GUICtrlCreateButton("Stop", 340, @DesktopHeight-200, 100, 30)

GUISetState()

While 1
	Sleep(25)
WEnd
