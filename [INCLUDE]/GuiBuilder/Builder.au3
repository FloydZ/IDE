#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>


Opt("GUIOnEventMode", 1)
$hMainForm = GUICreate("Form1", 610, 74, 269, 274)
GUISetOnEvent(-1, "_Exit")


$Tab1 = GUICtrlCreateTab(0, 0, 609, 73)
GUICtrlCreateTabItem("TabSheet1")

Global $CreateButton[3]
Local $y = 8
For $x = 0 to 2
	$CreateButton[$x] = GUICtrlCreateButton("Button", $y, 32, 75, 25)
	$y += 90
Next

GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)

While 1
	Sleep(25)
WEnd

Func _Exit()
	Exit
EndFunc


Func _OpenForm($File)
	If $File = "" Then

EndFunc
