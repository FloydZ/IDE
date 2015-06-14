#include "Au3SyntaxHighlight.au3"



$sFile = FileOpenDialog("Open Au3 Script File", @ScriptDir, "AutoIt Script (*.au3)")
If @error Then Exit

MsgBox(0,"","")
$sAu3Code = FileRead($sFile)
$sAu3HighlightedCode = _Au3_SyntaxHighlight_Proc($sAu3Code, 0)

GUICreate("",500,500,-1,-1)
GUICtrlCreateEdit($sAu3HighlightedCode,0,0,500,500)

While 1
	Sleep(25)
WEnd
