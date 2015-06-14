; Win2Tray - by Holger Kotsch

#NoTrayIcon

#include <GUIConstants.au3>
#include "ModernMenu.au3"

If Not IsDeclared("GW_OWNER")					Then Global Const $GW_OWNER = 4
If Not IsDeclared("GWL_EXSTYLE")				Then Global Const $GWL_EXSTYLE = -20
If Not IsDeclared("WM_GETICON")					Then Global Const $WM_GETICON = 0x007F
If Not IsDeclared("GCL_HICONSM")				Then Global Const $GCL_HICONSM = -34
If Not IsDeclared("GCL_HICON")					Then Global Const $GCL_HICON = -14
If Not IsDeclared("PROCESS_QUERY_INFORMATION")	Then Global Const $PROCESS_QUERY_INFORMATION = 0x0400
If Not IsDeclared("PROCESS_VM_READ")			Then Global Const $PROCESS_VM_READ = 0x0010 
    
Dim $arTrayWin[500][3] ; TrayIconID, WinTitle, WinHandle
$arTrayWin[0][0] = 0

$nTrayIcon1		= _TrayIconCreate("Win2Tray", "shell32.dll", -13)
_TrayIconSetClick(-1, 16)
_TrayIconSetState() ; Show the tray icon

$TrayAbout		= _TrayCreateItem(-1, "About")
_TrayItemSetIcon(-1, "shell32.dll", -24)
_TrayCreateItem(-1, "")
_TrayItemSetIcon(-1, "", 0)
$TrayExit		= _TrayCreateItem(-1, "Exit")
_TrayItemSetIcon(-1, "shell32.dll", -28)


$nChkStart = TimerInit()

While 1
	If TimerDiff($nChkStart) >= 500 Then
		CheckWindows()
		$nChkStart = TimerInit()
	EndIf
	
	$Msg = GUIGetMsg()
	
	Switch $Msg
		Case $GUI_EVENT_CLOSE, $TrayExit
			ExitLoop
		
		Case $TrayAbout
			MsgBox(0, "About", "Minimize all windows to the tray.")
	EndSwitch
WEnd

_TrayIconDelete($nTrayIcon1)


; Restores all windows before exit
For $i = 1 To $arTrayWin[0][0]
	If $arTrayWin[$i][0] <> 0 Then
		ShowWindow($arTrayWin[$i][2], @SW_RESTORE)
		SetForegroundWindow($arTrayWin[$i][2])
		_TrayIconDelete($arTrayWin[$i][0])
	EndIf
Next
					
Exit


; Own functions
Func TrayCallBack($nID, $nMsg)
	Local $i
	
	If $nMsg = $WM_LBUTTONUP Then
		For $i = 1 To $arTrayWin[0][0]
			If $arTrayWin[$i][0] > 0 And $arTrayWin[$i][0] = $nID Then
				ShowWindow($arTrayWin[$i][2], @SW_RESTORE)
				_TrayIconDelete($arTrayWin[$i][0])
					
				$arTrayWin[$i][0] = 0
				$arTrayWin[$i][1] = 0
				$arTrayWin[$i][2] = 0
								
				ExitLoop
			EndIf
		Next
	EndIf
EndFunc


Func CheckWindows()
	Local $i, $k, $idx, $bFound
	Local $arWin = WinList()
	
	If IsArray($arWin) Then
		For $i = 1 To $arWin[0][0]
			If $arWin[$i][0] <> "" And _
			Not IsToolWnd($arWin[$i][1]) Then
				If IsWindowVisible($arWin[$i][1]) And IsIconic($arWin[$i][1]) Then
					$bFound = FALSE
					For $k = 1 To $arTrayWin[0][0]
						If $arWin[$i][1] = $arTrayWin[$k][2] Then
							$bFound = TRUE
							ExitLoop
						EndIf
					Next

					If Not $bFound Then
						Win2Tray($arWin[$i][0], $arWin[$i][1])
						ShowWindow($arWin[$i][1], @SW_HIDE)
					EndIf
				EndIf
			EndIf
		Next	
	EndIf
	
	For $i = 1 To $arTrayWin[0][0]
		If Not IsWindow($arTrayWin[$i][2]) Then
			_TrayIconDelete($arTrayWin[$i][0])
					
			$arTrayWin[$i][0] = 0
			$arTrayWin[$i][1] = 0
			$arTrayWin[$i][2] = 0
								
			ExitLoop
		EndIf
	Next
EndFunc


Func Win2Tray($sTitle, $hWnd)
	Local $i, $nFound = 0, $nID, $nResult
	
	For $i = 1 To $arTrayWin[0][0]
		If $arTrayWin[$i][0] = 0 Then
			$nFound = $i
			ExitLoop
		EndIf
	Next
	
	Local $sFile = ""
	Local $hIcon = DllCall("user32.dll", "hwnd", "SendMessage", _
												"hwnd", $hWnd, _
												"int", $WM_GETICON, _
												"long", 2, _
												"long", 0)
	$hIcon = $hIcon[0]
	If $hIcon = 0 Then
		$hIcon = DllCall("user32.dll", "hwnd", "SendMessage", _
												"hwnd", $hWnd, _
												"int", $WM_GETICON, _
												"long", 0, _
												"long", 0)
		$hIcon = $hIcon[0]
	EndIf
	
	If $hIcon = 0 Then GetClassLong($hWnd, $GCL_HICONSM)
	If $hIcon = 0 Then GetClassLong($hWnd, $GCL_HICON)
	If $hIcon = 0 Then $sFile = @AutoItExe
	If $hIcon = 0 Then
		Local $nPID = WinGetProcess($hWnd)
		If $nPID <> -1 Then
			Local $hProc = OpenProcess(BitOR($PROCESS_QUERY_INFORMATION, $PROCESS_VM_READ), 0, $nPID)
			If $hProc <> 0 Then
				Local $stMod = DllStructCreate("int[1024]")
				Local $stSize = DllStructCreate("dword")
				
				$nResult = EnumProcessModules($hProc, _
											DllStructGetPtr($stMod), _
											DllStructGetSize($stMod), _
											DllStructGetPtr($stSize))
				If $nResult <> 0 Then
					Local $stPath = DllStructCreate("char[260]")
					
					If GetModuleFileNameExA($hProc, _
											DllStructGetData($stMod, 1), _
											DllStructGetPtr($stPath), _
											DllStructGetSize($stPath)) <> 0 Then $sFile = DllStructGetData($stPath, 1)
				EndIf
			EndIf
		EndIf
	EndIf
	
	$nID = _TrayIconCreate($sTitle, $sFile, 0, "TrayCallBack", 0, $hIcon)
	_TrayIconSetState()
	
	If $nFound = 0 Then
		$arTrayWin[0][0] += 1
		$nFound = $arTrayWin[0][0]
	EndIf
	
	$arTrayWin[$nFound][0] = $nID
	$arTrayWin[$nFound][1] = $sTitle
	$arTrayWin[$nFound][2] = $hWnd
EndFunc


Func IsToolWnd($hWnd)
	Local $nExStyle = DllCall("user32.dll", "int", "GetWindowLong", _
													"hwnd", $hWnd, _
													"int", $GWL_EXSTYLE)
	Local $bResult = FALSE
	If BitAnd($nExStyle[0], $WS_EX_TOOLWINDOW) Then $bResult = TRUE
	Return $bResult
EndFunc


; Dll functions
Func IsWindow($hWnd)
	Local $nResult = DllCall("user32.dll", "int", "IsWindow", _
													"hwnd", $hWnd)
	Return $nResult[0]
EndFunc


Func IsIconic($hWnd)
	Local $nResult = DllCall("user32.dll", "int", "IsIconic", _
													"hwnd", $hWnd)
	Return $nResult[0]
EndFunc


Func IsWindowVisible($hWnd)
	Local $nResult = DllCall("user32.dll", "int", "IsWindowVisible", _
													"hwnd", $hWnd)
	Return $nResult[0]
EndFunc


Func GetClassLong($hWnd, $nIdx)
	Local $hResult = DllCall("user32.dll", "hwnd", "GetClassLong", _
													"hwnd", $hWnd, _
													"int", $nIdx)
	Return $hResult[0]
EndFunc


Func OpenProcess($nAccess, $nHandle, $nPID)
	Local $hResult = DllCall("kernel32.dll", "hwnd", "OpenProcess", _
													"dword", $nAccess, _
													"int", $nHandle, _
													"dword", $nPID)
	Return $hResult[0]
EndFunc


Func EnumProcessModules($hProc, $pModule, $nSize, $pReqSize)
	Local $nResult = DllCall("psapi.dll", "dword", "EnumProcessModules", _
													"hwnd", $hProc, _
													"ptr", $pModule, _
													"dword", $nSize, _
													"ptr", $pReqSize)
	Return $nResult[0]
EndFunc


Func GetModuleFileNameExA($hProc, $hModule, $pFileName, $nSize)
	Local $nResult = DllCall("psapi.dll", "dword", "GetModuleFileNameExA", _
													"hwnd", $hProc, _
													"hwnd", $hModule, _
													"ptr", $pFileName, _
													"dword", $nSize)
	Return $nResult[0]
EndFunc