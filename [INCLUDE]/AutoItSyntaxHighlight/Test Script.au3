#OnAutoItStartRegister "MyStartFunc"
#include-once
#NoTrayIcon
#RequireAdmin
#NoAutoIt3Execute

#AutoIt3Wrapper_Au3Check_Parameters= -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <GUIConstantsEx.au3>
#include "String.au3"

;MsgBox(64, 'Title', 'Text	{f1}')

$vVar = 22
$vVar_Hex1 = 0x00000
$vVar_Hex2 = 0XaBcDeF00
$vVar_Hex3 = 0X0aBcDeF0

If ($vVar >= 20 And StringRight($vVar, 1) == 2) Or _
	($vVar < 20 And $vVar >= 2) Then $vVar = 10

If $vVar = 10 Then
	$vVar += $vVar_Hex2
	
	If $vVar = 100 Then
		$vVar = $vVar_Hex3
	EndIf
EndIf

#Region - GUICreate

$hGUI = GUICreate("My GUI v" & _StringRepeat("0.1", 2))

#EndRegion - GUICreate

GUISetState(@SW_SHOW)

#Region - GUI SelectLoop

While 1
	$nMsg = GUIGetMsg()
	
	;Switch GUIGetMsg()
	Select
		Case $nMsg = -3 ; $GUI_EVENT_CLOSE
			Exit
		Case $nMsg = 0 ; No special event
			
	EndSelect
	;EndSwitch
WEnd

#EndRegion - GUI SelectLoop

#cs
Comment block start

#comments-start
	Sub comment block start
	
	#CS Sub Sub Comment block start
	
	#CE Sub Sub Comment block end
	
	Sub comment block end
#comments-end

Comment block end
#ce

MsgBox(64, 'Title', $vVar.COM_Object.Method.Number())

Func MyStartFunc()
	ConsoleWrite("Hi, press ^{f1} or {f 1} (but not {f I}) for help!" & @LF)
EndFunc
