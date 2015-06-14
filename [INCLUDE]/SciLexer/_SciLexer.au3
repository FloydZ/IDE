
#include-once

#include <GUIConstants.au3>
#include "scintilla.h.au3"
#include <string.au3>
#include <array.au3>

Global $user32 = DllOpen("user32.dll")
Global $kernel32 = DllOpen("kernel32.dll")
Global $hlStart, $hlEnd, $sCallTip
Global Enum $MARGIN_SCRIPT_NUMBER = 0, $MARGIN_SCRIPT_ICON, $MARGIN_SCRIPT_FOLD



Func Sci_CreateEditor($Hwnd, $X,$Y,$W,$H) ; The return value is the hwnd of the window, and can be used for Win.. functions
	$Sci = CreateEditor($Hwnd,$X,$Y,$W,$H)
	If @error Then
		Return 0
	EndIf
	InitEditor($Sci)
	If @error Then
		Return 0
	Else
		Return $Sci
	EndIf
EndFunc


; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

Func Sci_DelLines($Sci)
	SendMessage($Sci, $SCI_CLEARALL, 0, 0)
	If @error Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc


Func Sci_AddLines($Sci, $Text,$Line)
	$Oldpos = Sci_GetCurrentLine($Sci)
	If @error Then
		Return 0
	EndIf
	Sci_SetCurrentLine($Sci, $Line)
	If @error Then
		Return 0
	EndIf
	$LineLenght = StringSplit($Text,"")
	If @error Then
		Return 0
	EndIf
	DllCall($user32, "long", "SendMessageA", "long", $Sci, "int", $SCI_ADDTEXT, "int", $LineLenght[0], "str", $Text)
	If @error Then
		Return 0
	EndIf
	Sci_SetCurrentLine($Sci, $Oldpos)
	If @error Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func Sci_GetText($Sci)
	Local $ret, $sText
	$iLen = SendMessage($Sci, $SCI_GETTEXT, 0, 0)
	If @error Then
		Return 0
	EndIf
	$sBuf = DllStructCreate("byte[" & $iLen & "]")
	If @error Then
		Return 0
	EndIf
	$ret = DllCall($user32, "long", "SendMessageA", "long", $Sci, "int", $SCI_GETTEXT, "int", $iLen, "ptr", DllStructGetPtr($sBuf))
	If @error Then
		Return 0
	EndIf
	$sText = BinaryToString(DllStructGetData($sBuf, 1))
	$sBuf = 0
	If @error Then
		Return 0
	Else
		Return $sText
	EndIf
EndFunc

Func Sci_GetLine($Sci, $Line)

	Local $ret, $sText
	$iLen = SendMessage($Sci, $SCI_GETLINE, $Line, 0)
	If @error Then
		Return 0
	EndIf
	$sBuf = DllStructCreate("byte[" & $iLen & "]")
	;If @error Then
	;	Return 0
	;EndIf
	$ret = DllCall($user32, "long", "SendMessageA", "long", $Sci, "int", $SCI_GETLINE, "int", $Line, "ptr", DllStructGetPtr($sBuf))
	If @error Then
		Return 0
	EndIf
	$sText = BinaryToString(DllStructGetData($sBuf, 1))
	$sBuf = 0
	If @error Then
		Return 0
	Else
		Return $sText
	EndIf

EndFunc

Func Sci_InsertText($Sci, $Pos, $Text)
	SendMessageString($Sci, $SCI_INSERTTEXT, $Pos, $Text)
EndFunc

Func Sci_GetLenght($Sci)
	Return SendMessage($Sci, $SCI_GETLENGTH, 0, 0)
EndFunc

Func Sci_SetZoom($Sci, $Zoom)
	SendMessage($Sci, $SCI_SETZOOM, $Zoom-1, 0)
	If @error Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func Sci_GetZoom($Sci)
	$Zoom = SendMessage($Sci, $SCI_GETZOOM, 0, 0)
	Return $Zoom+1
EndFunc

Func Sci_GetCurrentPos($Sci)
	$Pos = SendMessage($Sci, $SCI_GETCURRENTPOS, 0, 0)
	Return $Pos
EndFunc

Func Sci_SetCurrentPos($Sci, $Char)
	SendMessage($Sci, $SCI_GOTOPOS, $Char, 0)
	If @error Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func Sci_GetLineFromPos($Sci, $Pos)

	Return SendMessage($Sci, $SCI_LINEFROMPOSITION, $Pos, 0)

EndFunc

Func Sci_GetLineStartPos($Sci, $Line)

	Return SendMessage($Sci, $SCI_POSITIONFROMLINE, $Line, 0)

EndFunc

Func Sci_VisibleFirst($Sci)

	Return SendMessage($Sci, $SCI_GETFIRSTVISIBLELINE, 0, 0)

EndFunc

Func Sci_VisibleLines($Sci)

	Return SendMessage($Sci, $SCI_LINESONSCREEN, 0, 0)

EndFunc

Func Sci_SelectAll($Sci)

	Return SendMessage($Sci, $SCI_SELECTALL, 0, 0)

EndFunc

Func Sci_GetLineEndPos($Sci, $Line)

	Return SendMessage($Sci, $SCI_GETLINEENDPOSITION, $Line, 0)

EndFunc

Func Sci_GetLineLenght($Sci, $Line)

	Return SendMessage($Sci, $SCI_LINELENGTH, $Line, 0)

EndFunc

Func Sci_GetLineCount($Sci)

	Return SendMessage($Sci, $SCI_GETLINECOUNT, 0, 0)

EndFunc

Func Sci_SetCurrentLine($Sci, $Line)
	SendMessage($Sci, $SCI_GOTOLINE, $Line-1, 0)
	If @error Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc

Func Sci_GetCurrentLine($Sci)
	$Pos = SendMessage($Sci, $SCI_GETCURRENTPOS, 0, 0)
	$Line = SendMessage($Sci, $SCI_LINEFROMPOSITION, $Pos, 0)
	Return $Line+1
EndFunc

Func Sci_GetChar($Sci, $Pos)
	Return ChrW(SendMessage($Sci, $SCI_GETCHARAT, $Pos, 0))
EndFunc

Func Sci_SetSelection($Sci, $BeginChar, $EndChar)
	$Pos = SendMessage($Sci, $SCI_SETSEL, $BeginChar, $EndChar)
	Return $Pos
EndFunc

Func Sci_GetSelection($Sci)
	Local $Return[2]
	$Return[0] = SendMessage($Sci, $SCI_GETSELECTIONSTART, 0, 0)
	$Return[1] = SendMessage($Sci, $SCI_GETSELECTIONEND, 0, 0)
	Return $Return
EndFunc

Func Sci_SetSelectionColor($Sci, $Color, $State=True)

	SendMessage($Sci, $SCI_SETSELFORE, $State, $Color)

EndFunc

Func Sci_SetSelectionBkColor($Sci, $Color, $State=True)

	SendMessage($Sci, $SCI_SETSELBACK, $State, $Color)

EndFunc

Func Sci_SetSelectionAlpha($Sci, $Trans)

	SendMessage($Sci, $SCI_SETSELALPHA, $Trans, 0)

EndFunc

Func Sci_Search($Sci, $sSearch, $iStartPos=0, $iEndPos=0)

	If Not $iEndPos Then $iEndPos = Sci_GetLenght($Sci)

	SendMessage($Sci, $SCI_SETTARGETSTART, $iStartPos, 0)
	SendMessage($Sci, $SCI_SETTARGETEND, $iEndPos, 0)

	Return SendMessageString($Sci, $SCI_SEARCHINTARGET, StringLen($sSearch), $sSearch)
EndFunc

Func Sci_Cut($Sci)

	SendMessage($Sci, $SCI_CUT, 0, 0)

EndFunc

Func Sci_Copy($Sci)

	SendMessage($Sci, $SCI_COPY, 0, 0)

EndFunc

Func Sci_Paste($Sci)

	SendMessage($Sci, $SCI_PASTE, 0, 0)

EndFunc

Func Sci_Undo($Sci)

	SendMessage($Sci, $SCI_UNDO, 0, 0)

EndFunc

Func Sci_Redo($Sci)

	SendMessage($Sci, $SCI_REDO, 0, 0)

EndFunc

Func Sci_BeginUndoAction($Sci)

	SendMessage($Sci, $SCI_BEGINUNDOACTION, 0, 0)

EndFunc

Func Sci_EndUndoAction($Sci)

	SendMessage($Sci, $SCI_ENDUNDOACTION, 0, 0)

EndFunc

Func Sci_EmptyUndoBuffer($Sci)

	SendMessage($Sci, $SCI_EMPTYUNDOBUFFER, 0, 0)

EndFunc

Func Sci_GetCurrentWord($Sci)
	Local $Return

	$CurrentPos = Sci_GetCurrentPos($Sci)
	$Line = Sci_GetLineFromPos($Sci, $CurrentPos)
	$Text = Sci_GetLine($Sci, $Line)
	$Return = Sci_GetChar($Sci, $CurrentPos)

	if $Return and $Return <> " " and $Return <> @TAB and $Return <> @LF And $Return <> @CR Then

		$i = 1
		While 1

			$Get = Sci_GetChar($Sci, $CurrentPos-$i)
			$Char = $Get


			If $Get And $Char <> " " and $Char <> @TAB and $Char <> @LF And $Char <> @CR Then
				$Return = $Char & $Return
			Else
				ExitLoop
			EndIf

			$i += 1

		WEnd

		$i = 1

		While 1

			$Get = Sci_GetChar($Sci, $CurrentPos+$i)
			$Char = $Get

			If $Get And $Char <> " " and $Char <> @TAB and $Char <> @LF And $Char <> @CR Then
				$Return &= $Char
			Else
				ExitLoop
			EndIf

			$i += 1

		WEnd

		Return $Return

	Else
		Return ""
	EndIf

EndFunc

Func Sci_StyleApply($Sci, $iStyle, $iStartPos, $iLenght)
	SendMessage($Sci, $SCI_STARTSTYLING, $iStartPos, 0x1f)
	Return SendMessage($Sci, $SCI_SETSTYLING, $iLenght, $iStyle)
EndFunc

Func Sci_StyleSet($Sci, $iStyle, $iColor=-1, $iBkColor=-1, $iBold=-1, $iItalic=-1, $iUnderline=-1, $sFont=-1, $iFontSize=-1, $iHotspot=-1)

	If $iColor <> -1 Then SendMessage($Sci, $SCI_STYLESETFORE, $iStyle, $iColor)
	If $iBkColor <> -1 Then SendMessage($Sci, $SCI_STYLESETBACK, $iStyle, $iBkColor)
	If $iBold <> -1 Then SendMessage($Sci, $SCI_STYLESETBOLD, $iStyle, $iBold)
	If $iItalic <> -1 Then SendMessage($Sci, $SCI_STYLESETITALIC, $iStyle, $iItalic)
	If $iUnderline <> -1 Then SendMessage($Sci, $SCI_STYLESETUNDERLINE, $iStyle, $iUnderline)
	If $sFont <> -1 Then SendMessageString($Sci, $SCI_STYLESETFONT, $iStyle, $sFont)
	If $iFontSize <> -1 Then SendMessage($Sci,$SCI_STYLESETSIZE, $iStyle, $iFontSize)
	If $iHotspot <> -1 Then SendMessage($Sci,$SCI_STYLESETHOTSPOT, $iStyle, $iHotspot)

	Return 1

EndFunc

Func Sci_StyleClearAll($Sci)
	Return SendMessage($Sci, $SCI_STYLECLEARALL, 0, 0)
EndFunc

Func Sci_GetStyleAt($Sci, $iPos)
	Return SendMessage($Sci, $SCI_GETSTYLEAT, $iPos, 0)
EndFunc

Func Sci_SetLexer($Sci, $iLexer)
	Return SendMessage($Sci, $SCI_SETLEXER, $iLexer, 0)
EndFunc

Func Sci_GetLexer($Sci)
	Return SendMessage($Sci, $SCI_GETLEXER, 0, 0)
EndFunc

Func Sci_CalltipShow($Sci, $iPos, $sText)

	Return SendMessageString($Sci, $SCI_CALLTIPSHOW, $iPos, $sText)

EndFunc

Func Sci_CalltipActive($Sci)
	Return SendMessage($Sci, $SCI_CALLTIPACTIVE, 0, 0)
EndFunc

Func Sci_CalltipCancel($Sci)
	Return SendMessage($Sci, $SCI_CALLTIPCANCEL, 0, 0)
EndFunc

Func Sci_CalltipHighlight($Sci, $iStartPos, $iEndPos)
	Return SendMessage($Sci, $SCI_CALLTIPSETHLT, $iStartPos, $iEndPos)
EndFunc

Func Sci_CalltipPos($Sci)
	Return SendMessage($Sci, $SCI_CALLTIPPOSSTART, 0, 0)
EndFunc

Func Sci_AutoCompleteActive($Sci)
	Return SendMessage($Sci, $SCI_AUTOCACTIVE, 0,0)
EndFunc

Func Sci_AutoCompleteCancel($Sci)
	Return SendMessage($Sci, $SCI_AUTOCCANCEL, 0,0)
EndFunc

Func Sci_AutoCompleteShow($Sci, $iLen, $sWords)
	SendMessageString($Sci, $SCI_AUTOCSHOW, $iLen, $sWords)
EndFunc

Func Sci_LineWrapSetMode($Sci, $iMode)
	Return SendMessage($Sci, $SCI_SETWRAPMODE, $iMode,0)
EndFunc

Func Sci_LineWrapSetIndent($Sci, $iMode)
	Return SendMessage($Sci, $SCI_SETWRAPVISUALFLAGS, $iMode,0)
EndFunc

Func Sci_LineWrapSetIndentLocation($Sci, $iLocation)
	Return SendMessage($Sci, $SCI_SETWRAPVISUALFLAGSLOCATION, $iLocation,0)
EndFunc

Func Sci_SetSavePoint($Sci)
	Return SendMessage($Sci, $SCI_SETSAVEPOINT, 0,0)
EndFunc

Func Sci_GetModify($Sci)
	Return SendMessage($Sci, $SCI_GETMODIFY, 0,0)
EndFunc

Func Sci_SetAnchor($Sci, $iPos)
	Return SendMessage($Sci, $SCI_SETANCHOR, $iPos,0)
EndFunc

Func Sci_SetCurrentPosEx($Sci, $iPos)
	Return SendMessage($Sci, $SCI_SETCURRENTPOS, $iPos,0)
EndFunc

Func Sci_ReplaceSel($Sci, $sText)
	SendMessageString($Sci, $SCI_REPLACESEL, 0, $sText)
EndFunc

Func Sci_CallTipSetHltColor($Sci, $iColor)
	Return SendMessage($Sci, $SCI_CALLTIPSETFOREHLT, $iColor,0)
EndFunc

Func Sci_CallTipSetColor($Sci, $iColor)
	Return SendMessage($Sci, $SCI_CALLTIPSETFORE, $iColor,0)
EndFunc

Func Sci_CallTipSetBkColor($Sci, $iColor)
	Return SendMessage($Sci, $SCI_CALLTIPSETBACK, $iColor,0)
EndFunc

Func Sci_SelectionSetBkColor($Sci, $iColor, $iUse=True)
	Return SendMessage($Sci, $SCI_SETSELBACK, $iUse, $iColor)
EndFunc

Func Sci_SelectionSetColor($Sci, $iColor, $iUse=True)
	Return SendMessage($Sci, $SCI_SETSELFORE, $iUse, $iColor)
EndFunc

Func Sci_SelectionSetAlpha($Sci, $iAlpha)
	Return SendMessage($Sci, $SCI_SETSELALPHA, $iAlpha, 0)
EndFunc

Func Sci_SelectionGetAlpha($Sci)
	Return SendMessage($Sci, $SCI_GETSELALPHA, 0, 0)
EndFunc

Func Sci_CaretSetColor($Sci, $iColor)
	Return SendMessage($Sci, $SCI_SETCARETFORE, $iColor, 0)
EndFunc

Func Sci_CaretGetColor($Sci)
	Return SendMessage($Sci, $SCI_GETCARETFORE, 0, 0)
EndFunc

Func Sci_CaretSetWidth($Sci, $iWidth)
	Return SendMessage($Sci, $SCI_SETCARETWIDTH, $iWidth, 0)
EndFunc

Func Sci_CaretGetWidth($Sci)
	Return SendMessage($Sci, $SCI_GETCARETWIDTH, 0, 0)
EndFunc

Func Sci_FoldingShowLines($Sci, $iStart, $iEnd)
	Return SendMessage($Sci, $SCI_SHOWLINES, $iStart, $iEnd)
EndFunc

Func Sci_FoldingHideLines($Sci, $iStart, $iEnd)
	Return SendMessage($Sci, $SCI_HIDELINES, $iStart, $iEnd)
EndFunc

Func Sci_FoldingToggleFold($Sci, $iLine)
	Return SendMessage($Sci, $SCI_TOGGLEFOLD, $iLine, 0)
EndFunc

; -----------------------------------------------------------------------------------------------------------------------------------------------
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;================================================================================================================================================
;  SciLexer Functions	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;================================================================================================================================================
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;------------------------------------------------------------------------------------------------------------------------------------------------


Func CreateWindowEx($dwExStyle, $lpClassName, $lpWindowName = "", $dwStyle = -1, $X = 0, $Y = 0, $nWidth = 0, $nHeight = 0, $hwndParent = 0, $hMenu = 0, $hInstance = 0, $lParm = 0)
	Local $ret
	If $hInstance = 0 Then
		$ret = DllCall($user32, "long", "GetWindowLong", "hwnd", $hwndParent, "int", -6)
		$hInstance = $ret[0]
	EndIf
	$ret = DllCall($user32, "hwnd", "CreateWindowEx", "long", $dwExStyle, _
			"str", $lpClassName, "str", $lpWindowName, _
			"long", $dwStyle, "int", $X, "int", $Y, "int", $nWidth, "int", $nHeight, _
			"hwnd", $hwndParent, "hwnd", $hMenu, "long", $hInstance, "ptr", $lParm)
	If @error Then Return 0
	Return $ret[0]
EndFunc   ;==>CreateWindowEx

Func LoadLibrary($lpFileName)
	Local $ret
	$ret = DllCall($kernel32, "int", "LoadLibrary", "str", $lpFileName)

	If @error Then Return 0

	$hLib = $ret[0]

	Return $ret[0]
EndFunc   ;==>LoadLibrary

Func SendMessage($hwnd, $msg, $wp, $lp)
	Local $ret
	$ret = DllCall($user32, "long", "SendMessageA", "long", $hwnd, "int", $msg, "int", $wp, "int", $lp)
	If @error Then
		SetError(1)
		Return 0
	Else
		SetError(0)
		Return $ret[0]
	EndIf

EndFunc   ;==>SendMessage

Func SendMessageString($hwnd, $msg, $wp, $str)
	Local $ret
	$ret = DllCall($user32, "int", "SendMessageA", "hwnd", $hwnd, "int", $msg, "int", $wp, "str", $str)
	Return $ret[0]
EndFunc   ;==>SendMessageString

Func CreateEditor($Hwnd, $X,$Y,$W,$H)
	Local $GWL_HINSTANCE = -6
	Local $hLib = LoadLibrary(@ScriptDir & "\[INCLUDE]\SciLexer\SciLexer.DLL")
	If @error Then
		Return 0
	EndIf

	Global $Sci
	$Sci = CreateWindowEx(0, "Scintilla", _
			"SciLexer", BitOR($WS_CHILD, $WS_VISIBLE, $WS_HSCROLL, $WS_VSCROLL, $WS_TABSTOP, $WS_CLIPCHILDREN),  $X,$Y,$W,$H, _
			$Hwnd, 0, 0, 0)
	;If @error Then
	;	Return 0
	;EndIf
	;$aiSize = WinGetClientSize($Hwnd)
	If @error Then
		Return 0
	Else

		If not IsHWnd($Sci) Then $Sci = HWnd($Sci)

		Return $Sci
	EndIf
EndFunc   ;==>CreateEditor

Func InitEditor($Sci)
	;SendMessage($Sci, $SCI_SETLEXER, $SCLEX_AU3, 0)
	$bits = SendMessage($Sci, $SCI_GETSTYLEBITSNEEDED, 0, 0)
	SendMessage($Sci, $SCI_SETSTYLEBITS, $bits, 0)

	SendMessage($Sci, $SCI_SETTABWIDTH, 4, 0)
	SendMessage($Sci, $SCI_SETINDENTATIONGUIDES, True, 0)


	SendMessage($Sci, $SCI_SETMARGINTYPEN, $MARGIN_SCRIPT_NUMBER, $SC_MARGIN_NUMBER)
	SendMessage($Sci, $SCI_SETMARGINWIDTHN, $MARGIN_SCRIPT_NUMBER, SendMessageString($Sci, $SCI_TEXTWIDTH, $STYLE_LINENUMBER, "_99999"))

	SendMessage($Sci, $SCI_SETMARGINWIDTHN, $MARGIN_SCRIPT_ICON, 16)

	SendMessage($Sci, $SCI_AUTOCSETSEPARATOR, Asc(@CR), 0)
	SendMessage($Sci, $SCI_AUTOCSETIGNORECASE, True, 0)


	SetProperty($Sci, "fold", "1")
	SetProperty($Sci, "fold.compact", "1")
	SetProperty($Sci, "fold.comment", "1")
	SetProperty($Sci, "fold.preprocessor", "1")

	SendMessage($Sci, $SCI_SETMARGINWIDTHN, $MARGIN_SCRIPT_FOLD, 0); fold margin width=0

	SendMessage($Sci, $SCI_SETMARGINTYPEN, $MARGIN_SCRIPT_FOLD, $SC_MARGIN_SYMBOL)
	SendMessage($Sci, $SCI_SETMARGINMASKN, $MARGIN_SCRIPT_FOLD, $SC_MASK_FOLDERS)
	SendMessage($Sci, $SCI_SETMARGINWIDTHN, $MARGIN_SCRIPT_FOLD, 20)
	SendMessage($Sci, $SCI_MARKERDEFINE, $SC_MARKNUM_FOLDER, $SC_MARK_ARROW)
	SendMessage($Sci, $SCI_MARKERDEFINE, $SC_MARKNUM_FOLDEROPEN, $SC_MARK_ARROWDOWN)
	SendMessage($Sci, $SCI_MARKERDEFINE, $SC_MARKNUM_FOLDEREND, $SC_MARK_ARROW)
	SendMessage($Sci, $SCI_MARKERDEFINE, $SC_MARKNUM_FOLDERMIDTAIL, $SC_MARK_TCORNER)
	SendMessage($Sci, $SCI_MARKERDEFINE, $SC_MARKNUM_FOLDEROPENMID, $SC_MARK_ARROWDOWN)
	SendMessage($Sci, $SCI_MARKERDEFINE, $SC_MARKNUM_FOLDERSUB, $SC_MARK_VLINE)
	SendMessage($Sci, $SCI_MARKERDEFINE, $SC_MARKNUM_FOLDERTAIL, $SC_MARK_LCORNER)
	SendMessage($Sci, $SCI_SETFOLDFLAGS, 16, 0)
	SendMessage($Sci, $SCI_MARKERSETFORE, $SC_MARKNUM_FOLDER, 0xFFFFFF)
	SendMessage($Sci, $SCI_MARKERSETBACK, $SC_MARKNUM_FOLDERSUB, 0x808080)
	SendMessage($Sci, $SCI_MARKERSETBACK, $SC_MARKNUM_FOLDEREND, 0x808080)
	SendMessage($Sci, $SCI_MARKERSETFORE, $SC_MARKNUM_FOLDEREND, 0xFFFFFF)
	SendMessage($Sci, $SCI_MARKERSETBACK, $SC_MARKNUM_FOLDERTAIL, 0x808080)
	SendMessage($Sci, $SCI_MARKERSETBACK, $SC_MARKNUM_FOLDERMIDTAIL, 0x808080)
	SendMessage($Sci, $SCI_MARKERSETBACK, $SC_MARKNUM_FOLDER, 0x808080)
	SendMessage($Sci, $SCI_MARKERSETFORE, $SC_MARKNUM_FOLDEROPEN, 0xFFFFFF)
	SendMessage($Sci, $SCI_MARKERSETBACK, $SC_MARKNUM_FOLDEROPEN, 0x808080)
	SendMessage($Sci, $SCI_MARKERSETFORE, $SC_MARKNUM_FOLDEROPENMID, 0xFFFFFF)
	SendMessage($Sci, $SCI_MARKERSETBACK, $SC_MARKNUM_FOLDEROPENMID, 0x808080)
	SendMessage($Sci, $SCI_SETMARGINSENSITIVEN, $MARGIN_SCRIPT_FOLD, 1)

	SendMessage($Sci, $SCI_MARKERSETBACK, 0, 0x0000FF)

	;GUIRegisterMsg(0x004E, "WM_NOTIFY")

	If @error Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>InitEditor

Func SetProperty($hwnd, $property, $value, $int1 = False, $int2 = False)
	Local $ret
	If $int1 And $int2 Then
		$ret = DllCall($user32, "int", "SendMessageA", "hwnd", $hwnd, "int", $SCI_SETPROPERTY, "int", $property, "int", $value)
	ElseIf Not $int1 And Not $int2 Then
		$ret = DllCall($user32, "int", "SendMessageA", "hwnd", $hwnd, "int", $SCI_SETPROPERTY, "str", $property, "str", $value)
	ElseIf $int1 And Not $int2 Then
		$ret = DllCall($user32, "int", "SendMessageA", "hwnd", $hwnd, "int", $SCI_SETPROPERTY, "int", $property, "str", $value)
	ElseIf Not $int1 And $int2 Then
		$ret = DllCall($user32, "int", "SendMessageA", "hwnd", $hwnd, "int", $SCI_SETPROPERTY, "str", $property, "int", $value)
	EndIf
	Return $ret[0]
EndFunc   ;==>SetProperty

Func WM_NOTIFY($hWndGUI, $MsgID, $wParam, $lParam)

	Local $tagNMHDR = DllStructCreate("int;int;int;int;int;int;int;ptr;int;int;int;int;int;int;int;int;int;int;int", $lParam)

	$hWndFrom = DllStructGetData($tagNMHDR, 1)
	$IdFrom = DllStructGetData($tagNMHDR, 2)
	$Event = DllStructGetData($tagNMHDR, 3)
	$Position = DllStructGetData($tagNMHDR, 4)
	$Ch = DllStructGetData($tagNMHDR, 5)
	$Modifiers = DllStructGetData($tagNMHDR, 6)
	$ModificationType = DllStructGetData($tagNMHDR, 7)
	$Char = DllStructGetData($tagNMHDR, 8)
	$Length = DllStructGetData($tagNMHDR, 9)
	$LinesAdded = DllStructGetData($tagNMHDR, 10)
	$Message = DllStructGetData($tagNMHDR, 11)
	$uptr_t = DllStructGetData($tagNMHDR, 12)
	$sptr_t = DllStructGetData($tagNMHDR, 13)
	$Line = DllStructGetData($tagNMHDR, 14)
	$FoldLevelNow = DllStructGetData($tagNMHDR, 15)
	$FoldLevelPrev = DllStructGetData($tagNMHDR, 16)
	$Margin = DllStructGetData($tagNMHDR, 17)
	$ListType = DllStructGetData($tagNMHDR, 18)
	$X = DllStructGetData($tagNMHDR, 19)
	$Y = DllStructGetData($tagNMHDR, 20)

	Return $GUI_RUNDEFMSG

EndFunc   ;==>WM_NOTIFY


Func SetStyle($Sci, $style, $fore, $back, $size = 0, $font = "", $bold = 0, $italic = 0, $underline = 0)
	SendMessage($Sci, $SCI_STYLESETFORE, $style, $fore)
	SendMessage($Sci, $SCI_STYLESETBACK, $style, $back)
	If $size >= 1 Then
		SendMessage($Sci, $SCI_STYLESETSIZE, $style, $size)
	EndIf
	If $font <> '' Then
		SendMessageString($Sci, $SCI_STYLESETFONT, $style, $font)
	EndIf


	SendMessage($Sci, $SCI_STYLESETBOLD, $style, $bold)
	SendMessage($Sci, $SCI_STYLESETITALIC, $style, $italic)
	SendMessage($Sci, $SCI_STYLESETUNDERLINE, $style, $underline)
EndFunc   ;==>SetStyle