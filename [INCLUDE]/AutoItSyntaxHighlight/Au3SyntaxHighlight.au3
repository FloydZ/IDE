#Region Header

#CS

    Title:          Syntax Highlighter for AutoIt v3 Code
    Filename:       Au3SyntaxHighlight.au3
    Description:    Allows to highlight AutoIt v3 syntax to html/bbcode format.
    Author:         G.Sandler (a.k.a (Mr)CreatoR), www.creator-lab.ucoz.ru, www.autoit-script.ru
    Version:        0.4
    Requirements:   AutoIt v3.3 +, Developed/Tested on WindowsXP (Service Pack 3)
    Uses:
    Notes:          *Idea* based on similar old project: http://www.autoitscript.com/forum/index.php?showtopic=34236


	History:
					[0.4]
					* Fixed bug with (re)highlighting keywords and functions inside COM object methods.
					* Docs updated.

					[0.3]
					* Fixed bug when strings and send keys was highlighted inside commented lines.
					* Few optimizations to the code.

					[0.2]
					+ Added Global parameter ($iAu3SH_AbortHighlight) to abort the highlighting process (break the function execution).
					   - If this variable set to 1, the function will return the original Au3 Code and set @error to -1.
					+ Added "#White space" style support (now you can set it in the au3.styles.properties file).
					+ Added "#Background" style support, used only for highlighting with Html tags mode (now you can set it in the au3.styles.properties file).
					* Styles header classes renamed with "au3_" prefix.
					* Fixed bug with highlighting COM objects.
					* Fixed bug with highlighting keywords inside variables.
					* Fixed bug with highlighting more than one preprocessor when instead of <Include.au3> used double/single qoutes ("Include.au3").
					* Fixed bug with highlighting commented lines/comment blocks inside literal strings.
					* Fixed bug with not (properly) highlighting commented lines.
					* Fixed issue with converting to BBCode format.
					* Now the PreProcessor and Special keywords are correctly highlighted (all included tags removed).

					[0.1]
					First public release.

================ ToDo: ================

#CE

#CS Example script
#include <Au3SyntaxHighlight.au3>

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <IE.au3>

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

$sTmp_File = @TempDir & "\Au3_HighlightSyntax.htm"

$hFile = FileOpen($sTmp_File, 2)
FileWrite($hFile, $sAu3Syntax_HighlightedCode)
FileClose($hFile)

_IEErrorHandlerRegister()

$oIE = _IECreateEmbedded()
GUICreate("AutoIt Syntax Highlighter [" & $sFile & "]", @DesktopWidth-10, @DesktopHeight-70, 0, 0, $WS_OVERLAPPEDWINDOW + $WS_VISIBLE + $WS_CLIPSIBLINGS + $WS_CLIPCHILDREN)

$GUIActiveX = GUICtrlCreateObj($oIE, 10, 20, @DesktopWidth-5-20, @DesktopHeight-200-40)

$GUI_Button_Back = GUICtrlCreateButton("Back", 10, @DesktopHeight-200, 100, 30)
$GUI_Button_Forward = GUICtrlCreateButton("Forward", 120, @DesktopHeight-200, 100, 30)
$GUI_Button_Home = GUICtrlCreateButton("Home", 230, @DesktopHeight-200, 100, 30)
$GUI_Button_Stop = GUICtrlCreateButton("Stop", 340, @DesktopHeight-200, 100, 30)

GUISetState()

_IENavigate($oIE, $sTmp_File)

While 1
    Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			GUIDelete()
            Exit
		Case $GUI_Button_Home
            _IENavigate($oIE, $sTmp_File)
        Case $GUI_Button_Back
            _IEAction($oIE, "back")
        Case $GUI_Button_Forward
            _IEAction($oIE, "forward")
        Case $GUI_Button_Stop
            _IEAction($oIE, "stop")
    EndSwitch
WEnd

#CE Example script

If Not @Compiled Then
	ConsoleWrite('+ =============================================================' & @LF)
	ConsoleWrite('(' & 5 & ') : Syntax Highlighter for AutoIt (double-click on this line for details)' & @LF)
	ConsoleWrite('(' & @ScriptLineNumber - 69 & ') : Example included (double-click on this line to see the example)' & @LF)
	ConsoleWrite('+ =============================================================' & @LF & @LF)
EndIf

#include-once

Global $iAu3SH_MDV_Opt = Opt("MustDeclareVars", 1)

#EndRegion Header

#Region Global Variables

Global $iDebug_RegExp_Patterns 		= 0
Global $iDebug_RegExp_Step 			= 1
Global $iDebug_RegExp_WriteLog 		= 0
Global $sDebug_RegExp_LogContent 	= ""
Global $sDebug_RegExp_LogFile 		= @ScriptDir & "\Debug_RegExp.log"

Global $sAu3_Keywords_File 			= @ScriptDir & "\Resources\au3.keywords.properties"
Global $sAu3_Styles_File 			= @ScriptDir & "\Resources\au3.styles.properties"

Global $iAu3SH_AddURLs 				= 1

;Abort _Au3_SyntaxHighlight_Proc
;ATTENTION: If this is set to 1, then it's should be reset to 0 after the "_Au3_SyntaxHighlight_Proc" function returns.
Global $iAu3SH_AbortHighlight 		= 0

Global $sAu3SH_Funcs_URL 			=  __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, _
	"au3.keywords.functions.url", "http://www.autoitscript.com/autoit3/docs/functions/%s.htm", 0)
Global $sAu3SH_UDFs_URL 			= __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, _
	"au3.keywords.udfs.url", "http://dundats.mvps.org/help/html/libfunctions/%s.htm", 0)
Global $sAu3SH_Keywords_URL 		= __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, _
	"au3.keywords.keywotds.url", "http://www.autoitscript.com/autoit3/docs/keywords.htm#%s", 0)
Global $sAu3SH_Macros_URL 			= __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, _
	"au3.keywords.macros.url", "http://www.autoitscript.com/autoit3/docs/macros.htm#%s", 0)
Global $sAu3SH_PreProcessor_URL 	= __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, _
	"au3.keywords.preprocessor.url", "http://www.autoitscript.com/autoit3/docs/keywords.htm#%s", 0)

Global Enum _
	$iAu3SH_WSpace_Style = 0, $iAu3SH_Cmnt_Style, $iAu3SH_CmntBlck_Style, $iAu3SH_Nmbr_Style, $iAu3SH_Fnc_Style, $iAu3SH_Kwd_Style, $iAu3SH_Mcro_Style, $iAu3SH_Str_Style, _
	$iAu3SH_Oprtr_Style, $iAu3SH_Var_Style, $iAu3SH_SntKys_Style, $iAu3SH_PrPrc_Style, $iAu3SH_Spec_Style, $iAu3SH_Abrv_Style, $iAu3SH_COM_Style, $iAu3SH_Udf_Style

Global $aAu3SH_Styles[$iAu3SH_Udf_Style+1]

For $i = $iAu3SH_WSpace_Style To $iAu3SH_Udf_Style
	$aAu3SH_Styles[$i] 			= '<span class="au3_S' & $i & '">'
Next

Global $sAu3SH_CloseTag 		= '</span>'

#EndRegion Global Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name...........:	_Au3_SyntaxHighlight_Proc
; Description....:	Allows to highlight AutoIt v3 syntax to html/bbcode format.
; Syntax.........:	_Au3_SyntaxHighlight_Proc($sAu3Code, $iOutput = -1)
; Parameters.....:	$sAu3Code - AutoIt v3 plain code.
;					$iOutput  - [Optional] Sets the output format:
;					                                      -1 - (Default) Return CSS classes header and the AutoIt Syntax Highlighted code as string (wrapped with code tags)
;					                                       1 - Return CSS classes header and AutoIt Syntax Highlighted code as array, where...
;					                                            [0] = CSS styles.
;					                                            [1] = AutoIt Syntax Highlighted code.
;					                                       2 - Return the result as Html formatted string.
;					                                       3 - Return the result as BBCode formatted string (html tags replaced with bbcode tags).
;
; Return values..:	Success - Returns AutoIt Syntax Highlighted code (see $iOutput parameter above for more details).
;					Failure - Sets @error to:
;												1 	- The $sAu3Code is empty string.
;											   -1 	- The process is aborted by global parameter $iAu3SH_AbortHighlight, and the return value is the original $sAu3Code.
;												2 	- Keywords or styles file not found (check the @ScriptDir & "\Resources").
;
; Author.........:	G.Sandler (a.k.a (Mr)CreatoR), www.creator-lab.ucoz.ru, www.autoit-script.ru
; Modified.......:
; Remarks........:	*Idea* based on similar old project: http://www.autoitscript.com/forum/index.php?showtopic=34236
; Related........:
; Link...........:
; Example........:	Yes (see #Region Header).
; ===============================================================================================================
Func _Au3_SyntaxHighlight_Proc($sAu3Code, $iOutput = -1)
	;************************** I M P O R T A N T *************************
	;   Highlighting elements order must be preserved (DO NOT CHANGE IT)
	;************************** I M P O R T A N T *************************

	Local $sOrigin_Au3Code = $sAu3Code

	If StringStripWS($sAu3Code, 8) = '' Then
		Return SetError(1, 0, 0)
	EndIf

	If Not FileExists($sAu3_Keywords_File) Or Not FileExists($sAu3_Styles_File) Then
		Return SetError(2, 0, 0)
	EndIf

	Local $sPattern1, $sPattern2, $sPattern3
	Local $sReplace1, $sReplace2, $sReplace3

	Local $sUnique_Str_Quote = '%@~@%'
	Local $sUnique_Str_Include = '!~@%@~!' ; "!" must be the first character

	While StringInStr($sAu3Code, $sUnique_Str_Quote)
		$sUnique_Str_Quote &= Random(10000, 99999)

		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1, 0, $sOrigin_Au3Code)
		EndIf
	WEnd

	While StringInStr($sAu3Code, $sUnique_Str_Include)
		$sUnique_Str_Include &= Random(10000, 99999)

		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1, 0, $sOrigin_Au3Code)
		EndIf
	WEnd

	; Get all strings to array (all between "", '' and <> chars), so we can replace later with unique marks
	$sPattern1 = '(?m)(("|'')[^\2\r\n]*?\2)' ;'(?s).*?(("|'')[^\2]*\2).*?'
	$sPattern2 = "(?si)#include\s+?(<[^\>]*>).*?"

	Local $aQuote_Strings = StringRegExp($sAu3Code, $sPattern1, 3)
	Local $aInclude_Strings = StringRegExp($sAu3Code, $sPattern2, 3)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("a", $sPattern1, 3, "", $sAu3Code, @ScriptLineNumber - 3)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("b", $sPattern2, 3, "Get all strings to array (all between """", '' and <> chars)", $sAu3Code, @ScriptLineNumber - 3)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	; Replace all the strings with unique marks
	$sPattern1 = '(?s)("|'')([^\1\r\n])*?(\1)'
	$sPattern2 = "(?si)(#include\s+?)<[^\>]*>(.*?)"

	$sReplace1 = $sUnique_Str_Quote
	$sReplace2 = '\1' & $sUnique_Str_Include & '\2'

	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern2, $sReplace2)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("a", $sPattern1, $sReplace1, "", $sAu3Code, @ScriptLineNumber - 3)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("b", $sPattern2, $sReplace2, "Replace all the strings with unique marks", $sAu3Code, @ScriptLineNumber - 3)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	$sPattern1 = '([\(\)\[\]\<\>\.\*\+\-\=\&\^\,\/])'
	$sReplace1 = $aAu3SH_Styles[$iAu3SH_Oprtr_Style] & '\1' & $sAu3SH_CloseTag

	; Highlight the operators, brakets, commas (must be done before all other parsers)
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("a", $sPattern1, $sReplace1, "Highlight the operators, brakets, commas", $sAu3Code, @ScriptLineNumber - 2)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	$sPattern1 = '(\W+)(_)(\W+)'
	$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_Oprtr_Style] & '\2' & $sAu3SH_CloseTag & '\3'

	; Highlight the line braking character, wich is the underscore (must be done before all other parsers)
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, "Highlight the line braking character ( _ )", $sAu3Code, @ScriptLineNumber - 2)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	$sPattern1 = '((?:\s+)?' & $aAu3SH_Styles[$iAu3SH_Oprtr_Style] & '\.' & $sAu3SH_CloseTag & '|(?:\s+)?\.)([^\d\$<]\w+)'
	$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_COM_Style] & '\2' & $sAu3SH_CloseTag

	; Highlight the COM Objects (must be done before all other parsers)
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, _
		"Highlight the COM Objects (""S8"" is the highlight for operators, here it is a dot (.) char)", $sAu3Code, @ScriptLineNumber - 2)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	$sPattern1 = '([^\w#@])(\d+)([^\w])'
	$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_Nmbr_Style] & '\2' & $sAu3SH_CloseTag & '\3'

	; Highlight the number
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, "Highlight the numbers", $sAu3Code, @ScriptLineNumber - 2)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	; Highlight the function
	$sAu3Code = __Au3_SyntaxHighlight_ParseFunctions($sAu3Code)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	; Highlight the UDFs
	$sAu3Code = __Au3_SyntaxHighlight_ParseUDFs($sAu3Code)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	; Highlight the keyword
	$sAu3Code = __Au3_SyntaxHighlight_ParseKeywords($sAu3Code)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	; Highlight the macros
	$sAu3Code = __Au3_SyntaxHighlight_ParseMacros($sAu3Code)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	; Highlight the PreProcessor
	$sAu3Code = __Au3_SyntaxHighlight_ParsePreProcessor($sAu3Code)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	; Highlight special keywords
	$sAu3Code = __Au3_SyntaxHighlight_ParseSpecial($sAu3Code)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	$sPattern1 = '([^\w#@])((?i)0x[abcdef\d]+)([^abcdef\d])'
	$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_Nmbr_Style] & '\2' & $sAu3SH_CloseTag & '\3'

	; Highlight the hexadecimal number
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, "Highlight the hexadecimal number", $sAu3Code, @ScriptLineNumber - 2)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	$sPattern1 = '\$(\w+)?'
	$sReplace1 = $aAu3SH_Styles[$iAu3SH_Var_Style] & '$\1' & $sAu3SH_CloseTag

	; Highlight variables (also can be just the dollar sign)
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, "Highlight variables", $sAu3Code, @ScriptLineNumber - 2)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	; Highlight send keys (must be done before the strings been restored, because send keys should be highlighted inside the strings)
	$aQuote_Strings = __Au3_SyntaxHighlight_ParseSendKeys($aQuote_Strings)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	$sPattern1 = '(\w+)(\h*' & $aAu3SH_Styles[$iAu3SH_Oprtr_Style] & '\()'
	$sReplace1 = $aAu3SH_Styles[$iAu3SH_WSpace_Style] & '\1' & $sAu3SH_CloseTag & '\2'

	; Highlight finaly the '#White space' (only user defined functions)
	$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, "Highlight '#White space' (only user defined functions)", $sAu3Code, @ScriptLineNumber - 2)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	; Highlight commented lines / comment block (plus extra parsers due to need of the loop, see the function's body)
	$sAu3Code = __Au3_SyntaxHighlight_ParseComments($sAu3Code)

	If @error = -1 Then
		Return SetError(-1, 0, $sOrigin_Au3Code)
	EndIf

	; Replace back the unique marks with the original one and wrap them with "string" tags
	For $i = 0 To UBound($aQuote_Strings)-1 Step 2
		$sAu3Code = StringReplace($sAu3Code, $sUnique_Str_Quote, $aAu3SH_Styles[$iAu3SH_Str_Style] & $aQuote_Strings[$i] & $sAu3SH_CloseTag, 1)

		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1, 0, $sOrigin_Au3Code)
		EndIf
	Next

	For $i = 0 To UBound($aInclude_Strings)-1
		$aInclude_Strings[$i] = StringReplace($aInclude_Strings[$i], '<', '&lt;')
		$aInclude_Strings[$i] = StringReplace($aInclude_Strings[$i], '>', '&gt;')

		$sAu3Code = StringReplace($sAu3Code, $sUnique_Str_Include, $aAu3SH_Styles[$iAu3SH_Str_Style] & $aInclude_Strings[$i] & $sAu3SH_CloseTag, 1)

		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1, 0, $sOrigin_Au3Code)
		EndIf
	Next

	; Strip tags from "string" inside commented lines
	Do
		$sAu3Code = StringRegExpReplace($sAu3Code, _
			'(.*?' & $aAu3SH_Styles[$iAu3SH_Cmnt_Style] & ';.*?)' & _
			'(?:' & $aAu3SH_Styles[$iAu3SH_Str_Style] & '|' & $aAu3SH_Styles[$iAu3SH_SntKys_Style] & ')(.*?)' & $sAu3SH_CloseTag & '(.*?)', _
			'\1\2\3')
	Until @extended = 0

	; Replace tabs with 4 spaces, in IE the tabs not looking good :(.
	$sAu3Code = StringReplace($sAu3Code, @TAB, '    ') ;'&nbsp;&nbsp;&nbsp;&nbsp;'

	; Output debug data to log file
	If $iDebug_RegExp_WriteLog Then
		Local $hFile = FileOpen($sDebug_RegExp_LogFile, 1)

		FileWrite($hFile, StringFormat('_Au3_SyntaxHighlight Debug RegExp Log started at: %.2i/%.2i/%i, %.2i:%.2i:%.2i\r\n' & _
			'~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~\r\n%s\r\n', _
			@MDAY, @MON, @YEAR, @HOUR, @MIN, @SEC, $sDebug_RegExp_LogContent) & _
			'~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~' & @CRLF)

		FileClose($hFile)
	EndIf

	; Get the CSS styles header (to use on return)
	Local $sStyles_Header = __Au3_SyntaxHighlight_GetKeywordStylesHeader()

	; Check the $iOutput flag
	Switch $iOutput
		; Return CSS classes header and AutoIt Syntax Highlighted code as array ([0] = CSS styles, [1] = Au3 Code)
		Case 1
			Local $aRet[2] = [$sStyles_Header, $sAu3Code]
			Return $aRet
		; Return AutoIt Syntax Highlighted code as string
		Case 2
			Return $sAu3Code
		; Return the result as BBCode formatted string
		Case 3
			$sAu3Code = __Au3_SyntaxHighlight_ConvertHtmlToBBCodeTags($sAu3Code)

			If @error = -1 Then
				Return SetError(-1, 0, $sOrigin_Au3Code)
			EndIf

			Return $sAu3Code
		; Return CSS classes header and the AutoIt Syntax Highlighted code as Html formatted string
		Case Else
			Return $sStyles_Header & @CRLF & '<pre class="au3_codebox"><span>' & $sAu3Code & '</span></pre>'
	EndSwitch
EndFunc

#EndRegion Public Functions

#Region Internal Functions

Func __Au3_SyntaxHighlight_ParseFunctions($sAu3Code)
	Local $aFuncs = __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, "au3.keywords.functions")
	Local $sPattern1, $sReplace1, $iLineNum

	If $iAu3SH_AddURLs Then
		For $i = 1 To $aFuncs[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '([^\w\$]+|\A)(?<!' & $aAu3SH_Styles[$iAu3SH_COM_Style] & ')((?i)' & $aFuncs[$i] & ')(\W+|$)'
			$sReplace1 = '\1<a href="' & StringFormat($sAu3SH_Funcs_URL, $aFuncs[$i]) & '">' & $aAu3SH_Styles[$iAu3SH_Fnc_Style] & '\2' & $sAu3SH_CloseTag & '</a>\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	Else
		For $i = 1 To $aFuncs[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '([^\w\$]+|\A)(?<!' & $aAu3SH_Styles[$iAu3SH_COM_Style] & ')((?i)' & $aFuncs[$i] & ')(\W+|$)'
			$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_Fnc_Style] & '\2' & $sAu3SH_CloseTag & '\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	EndIf

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", _
		$sPattern1, $sReplace1, _
		"Highlight built-in functions - The function name/url in the <Search/Replace Pattern> is the last found name/url in the functions list (after the loop ends)", _
		$sAu3Code, $iLineNum)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	Return $sAu3Code
EndFunc

Func __Au3_SyntaxHighlight_ParseUDFs($sAu3Code)
	Local $aUDFs = __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, "au3.keywords.udfs")
	Local $sPattern1, $sReplace1, $iLineNum

	If $iAu3SH_AddURLs Then
		For $i = 1 To $aUDFs[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '([^\w\$]+|\A)(?<!' & $aAu3SH_Styles[$iAu3SH_COM_Style] & ')((?i)' & $aUDFs[$i] & ')(\W+|$)'
			$sReplace1 = '\1<a href="' & StringFormat($sAu3SH_UDFs_URL, $aUDFs[$i]) & '">' & $aAu3SH_Styles[$iAu3SH_Udf_Style] & '\2' & $sAu3SH_CloseTag & '</a>\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	Else
		For $i = 1 To $aUDFs[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '([^\w\$]+|\A)(?<!' & $aAu3SH_Styles[$iAu3SH_COM_Style] & ')((?i)' & $aUDFs[$i] & ')(\W+|$)'
			$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_Udf_Style] & '\2' & $sAu3SH_CloseTag & '\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	EndIf

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, _
		"Highlight the UDFs - The UDF name/url in the <Search/Replace Pattern> is the last found name/url in the UDFs list (after the loop ends)", $sAu3Code, $iLineNum)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	Return $sAu3Code
EndFunc

Func __Au3_SyntaxHighlight_ParseKeywords($sAu3Code)
	Local $aKeywords = __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, "au3.keywords.keywords")
	Local $sPattern1, $sReplace1, $iLineNum

	If $iAu3SH_AddURLs Then
		For $i = 1 To $aKeywords[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '([^\w\$@]|\A)(?<!' & $aAu3SH_Styles[$iAu3SH_COM_Style] & ')((?i)' & $aKeywords[$i] & ')(\W|$)'
			$sReplace1 = '\1<a href="' & StringFormat($sAu3SH_Keywords_URL, $aKeywords[$i]) & '">' & $aAu3SH_Styles[$iAu3SH_Kwd_Style] & '\2' & $sAu3SH_CloseTag & '</a>\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	Else
		For $i = 1 To $aKeywords[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '([^\w\$@]|\A)(?<!' & $aAu3SH_Styles[$iAu3SH_COM_Style] & ')((?i)' & $aKeywords[$i] & ')(\W|$)'
			$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_Kwd_Style] & '\2' & $sAu3SH_CloseTag & '\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	EndIf

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", _
		$sPattern1, $sReplace1, _
		"Highlight the Keywords - The Keyword name/url in the <Search/Replace Pattern> is the last found name/url in the Keywords list (after the loop ends)", _
		$sAu3Code, $iLineNum)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	Return $sAu3Code
EndFunc

Func __Au3_SyntaxHighlight_ParseMacros($sAu3Code)
	Local $aMacros = __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, "au3.keywords.macros")
	Local $sPattern1, $sReplace1, $iLineNum

	If $iAu3SH_AddURLs Then
		For $i = 1 To $aMacros[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '(\W+|\A)((?i)' & $aMacros[$i] & ')(\W+|$)'
			$sReplace1 = '\1<a href="' & StringFormat($sAu3SH_Macros_URL, $aMacros[$i]) & '">' & $aAu3SH_Styles[$iAu3SH_Mcro_Style] & '\2' & $sAu3SH_CloseTag & '</a>\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	Else
		For $i = 1 To $aMacros[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '(\W+|\A)((?i)' & $aMacros[$i] & ')(\W+|$)'
			$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_Mcro_Style] & '\2' & $sAu3SH_CloseTag & '\3'

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Next

		$iLineNum = @ScriptLineNumber - 3
	EndIf

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern1, $sReplace1, _
		"Highlight the Macros - The Macro name/url in the <Search/Replace Pattern> is the last found name/url in the Macros list (after the loop ends)", $sAu3Code, $iLineNum)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	Return $sAu3Code
EndFunc

Func __Au3_SyntaxHighlight_ParsePreProcessor($sAu3Code)
	Local $aPreProcessor = __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, "au3.keywords.preprocessor")
	Local $sPattern1, $sPattern2, $sReplace1, $sReplace2, $iLineNum

	If $iAu3SH_AddURLs Then
		For $i = 1 To $aPreProcessor[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '(\W+|\A)((?i)' & $aPreProcessor[$i] & '.*)<(?:span|a href=).*?>(.*)</(?:span|a)>'
			$sPattern2 = '(\W+|\A)((?i)' & $aPreProcessor[$i] & ')([^\w!%-]+?|\Z)'

			$sReplace1 = '\1\2\3'
			$sReplace2 = '\1<a href="' & StringFormat($sAu3SH_PreProcessor_URL, $aPreProcessor[$i]) & '">' & _
				$aAu3SH_Styles[$iAu3SH_PrPrc_Style] & '\2' & $sAu3SH_CloseTag & '</a>\3'

			Do
				$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
			Until @extended = 0

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern2, $sReplace2)
		Next

		$iLineNum = @ScriptLineNumber - 3
	Else
		For $i = 1 To $aPreProcessor[0]
			If $iAu3SH_AbortHighlight = 1 Then
				Return SetError(-1)
			EndIf

			$sPattern1 = '(\W+|\A)((?i)' & $aPreProcessor[$i] & '.*)<(?:span|a href=).*?>(.*)</(?:span|a)>'
			$sPattern2 = '(\W+|\A)((?i)' & $aPreProcessor[$i] & ')([^\w!%-]+?|\Z)'

			$sReplace1 = '\1\2\3'
			$sReplace2 = '\1' & $aAu3SH_Styles[$iAu3SH_PrPrc_Style] & '\2' & $sAu3SH_CloseTag & '\3'

			Do
				$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
			Until @extended = 0

			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern2, $sReplace2)
		Next

		$iLineNum = @ScriptLineNumber - 3
	EndIf

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", _
		$sPattern1, $sReplace1, _
		"Highlight the PreProcessor - The PreProc. name/url in the <Search/Replace Pattern> is the last found name/url in the PreProc. list (after the loop ends)", _
		$sAu3Code, $iLineNum)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	Return $sAu3Code
EndFunc

Func __Au3_SyntaxHighlight_ParseSpecial($sAu3Code)
	Local $aSpecial = __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, "au3.keywords.special")
	Local $sPattern1, $sPattern2, $sReplace1, $sReplace2

	For $i = 1 To $aSpecial[0]
		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1)
		EndIf

		$sPattern1 = '(\W+|\A)((?i)' & $aSpecial[$i] & '.*)<(?:span|a href=).*?>(.*)</(?:span|a)>'
		$sPattern2 = '(\W+|\A)((?i)' & $aSpecial[$i] & '.*)'
		$sReplace1 = '\1\2\3'
		$sReplace2 = '\1' & $aAu3SH_Styles[$iAu3SH_Spec_Style] & '\2' & $sAu3SH_CloseTag

		Do
			$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern1, $sReplace1)
		Until @extended = 0

		$sAu3Code = StringRegExpReplace($sAu3Code, $sPattern2, $sReplace2)
	Next

	$sAu3Code = StringReplace($sAu3Code, @CR & '</span>', '</span>')

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("a", $sPattern1, $sReplace1, "", $sAu3Code, @ScriptLineNumber - 6)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("b", _
		$sPattern2, $sReplace2, _
		"Highlight Special Keywords - The Spec. keywords name in the <Search Pattern> is the last found name in the Spec. keywords list (after the loop ends)", _
		$sAu3Code, @ScriptLineNumber - 4)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	Return $sAu3Code
EndFunc

Func __Au3_SyntaxHighlight_ParseSendKeys($aStrings)
	Local $aSendKeys = __Au3_SyntaxHighlight_PropertyRead($sAu3_Keywords_File, "au3.keywords.sendkeys")
	Local $sPattern1, $sPattern2, $sReplace1, $sReplace2
	Local $sStrings

	;$sReplace1 = '\1' & $aAu3SH_Styles[$iAu3SH_SntKys_Style] & '\3' & $sAu3SH_CloseTag & '\4'
	;$sPattern2 = '((''|")[^\2\>]*?)((?i)[\^+!#]*?{\S(?:[\h]+?[\h\d]*?)?})([^\2</]*?\2)'
	$sReplace1 = $aAu3SH_Styles[$iAu3SH_SntKys_Style] & '\1' & $sAu3SH_CloseTag
	$sPattern2 = '(?i)([\^+!#]*?{\S(?:[\h]+?[\h\d]*?)?})'
	$sReplace2 = $sReplace1

	For $i = 0 To UBound($aStrings)-1 Step 2
		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1)
		EndIf

		$sStrings &= $aStrings[$i] & @CRLF
	Next

	For $i = 1 To $aSendKeys[0]
		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1)
		EndIf

		;$sPattern1 = '((''|")[^\2]*?)((?i)[\^+!#]*?{' & $aSendKeys[$i] & '(?:[\h]+?[\h\d]*?)?})([^\2]*?\2)'
		$sPattern1 = '(?i)([\^+!#]*?{' & $aSendKeys[$i] & '(?:[\h]+?[\h\d]*?)?})'
		$sStrings = StringRegExpReplace($sStrings, $sPattern1, $sReplace1)
	Next

	$sStrings = StringRegExpReplace($sStrings, $sPattern2, $sReplace2)

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("a", $sPattern1, $sReplace1, "", $sStrings, @ScriptLineNumber - 5)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("b", $sPattern2, $sReplace2, _
		"Highlight send keys - The send key name in the <Search Pattern> is the last found name in the send keys list (after the loop ends)", $sStrings, @ScriptLineNumber-3)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	Return StringSplit(StringStripWS($sStrings, 3), @CRLF, 2)
EndFunc

Func __Au3_SyntaxHighlight_ParseComments($sAu3Code)
	Local $aSplit_Code = StringSplit(StringStripCR($sAu3Code), @LF)
	Local $sSpaces, $aSplit_Comment, $iSubCommentStarted_Count = 0
	Local $sPattern1, $sPattern2, $sPattern3, $sPattern4, $sPattern5, $sReplace2, $sReplace3, $sReplace5

	$sPattern1 = '(\s+)?([^(&lt|&gt)]|\h+?|^);' ; Commented line pattern
	$sPattern2 = '<\w+\h?[^>]*?>(.*?)</\w+>' ;'<\w+\h?[^>]*?>|</\w+>' ; Remove all tags pattern
	$sPattern3 = '(?i)(\s+)?#(cs|comments.*?start)(.*)' ; #comment-start search pattern. ".*?" in "comments.*?start" is the "-" seperator, can be wrapped with tags
	$sPattern4 = '(?i)(\s+)?#(ce|comments.*?end)(.*)' ; #comment-end search pattern
	$sPattern5 = '(?i)(?<=(<span class="au3_S\d">))(?>(.*?)</span>)( *)\1|(?<=(<span class="au3_S\d\d">))(?>(.*?)</span>)( *)\4' ; Clean double tags

	$sReplace2 = '\1'
	$sReplace3 = '\1' & $aAu3SH_Styles[$iAu3SH_CmntBlck_Style] & '#\2\3'
	$sReplace5 = '\2\3\5\6'

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("a", $sPattern1, 0, "Commented line pattern", $sAu3Code, @ScriptLineNumber + 17)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("b", $sPattern2, '', "Remove all tags pattern", $sAu3Code, _
		@ScriptLineNumber + 19 & "/" & @ScriptLineNumber + 24 & "/" & @ScriptLineNumber + 36)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("c", $sPattern3, "Check mathes (flag [0] in StringRegExp) / " & $sReplace3, "#comment-start search pattern", $sAu3Code, _
		@ScriptLineNumber + 20 & '/' & @ScriptLineNumber + 25 & "/" & @ScriptLineNumber + 38)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("d", $sPattern4, "", "#comment-end search pattern" & @CRLF & @CRLF & _
		"! Summary:		Highlight commented lines / comment block", $sAu3Code, @ScriptLineNumber + 41 & "/" & @ScriptLineNumber + 46)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("", $sPattern5, $sReplace5, "Clean double tags", $sAu3Code, @ScriptLineNumber + 49)
	__Au3_SyntaxHighlight_Debug_RegExp_Patterns("===")

	$sAu3Code = ''

	; Go thru the code and check each line...
	For $i = 1 To $aSplit_Code[0]
		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1)
		EndIf

		; Commented line
		If StringRegExp($aSplit_Code[$i], $sPattern1) Then
			; Remove all tags
			$aSplit_Comment = StringRegExp($aSplit_Code[$i], '([^;]*);(.*?)$', 3)

			If UBound($aSplit_Comment) > 1 Then
				Do
					$aSplit_Comment[1] = StringRegExpReplace($aSplit_Comment[1], $sPattern2, $sReplace2)
				Until @extended = 0

				$aSplit_Code[$i] = $aSplit_Comment[0] & $aAu3SH_Styles[$iAu3SH_Cmnt_Style] & ';' & $aSplit_Comment[1] & $sAu3SH_CloseTag
			EndIf

			$sAu3Code &= $aSplit_Code[$i] & @CRLF
		; Comment block
		ElseIf StringRegExp($aSplit_Code[$i], $sPattern3) Then
			; Remove all tags
			Do
				$aSplit_Code[$i] = StringRegExpReplace($aSplit_Code[$i], $sPattern2, $sReplace2)
			Until @extended = 0

			; Add the comment *open* tag
			$sAu3Code &= StringRegExpReplace($aSplit_Code[$i], $sPattern3, $sReplace3) & @CRLF

			$iSubCommentStarted_Count += 1

			; Now check each line for ending of the comment block
			For $j = $i+1 To $aSplit_Code[0]
				$i = $j

				; Remove all tags
				Do
					$aSplit_Code[$j] = StringRegExpReplace($aSplit_Code[$j], $sPattern2, $sReplace2)
				Until @extended = 0

				$sAu3Code &= $aSplit_Code[$j] & @CRLF

				; Check if current line of code is the (sub)start of comment block. If so, make a "note" for it (inrease the comments-start counter by one)
				If StringRegExp($aSplit_Code[$j], $sPattern3) Then
					$iSubCommentStarted_Count += 1
				EndIf

				; Check if current line of code is the end of sub comment block. If so, decrease the comments-start counter by one (to allow the ending of all comments)
				If $iSubCommentStarted_Count > 0 And StringRegExp($aSplit_Code[$j], $sPattern4) Then
					$iSubCommentStarted_Count -= 1
				EndIf

				; Check if current line of code is the end of (all) comment block(s). If so, exit this current loop
				If $iSubCommentStarted_Count = 0 And StringRegExp($aSplit_Code[$j], $sPattern4) Then
					$sAu3Code &= $sAu3SH_CloseTag
					ExitLoop
				EndIf
			Next
		Else
			; Clean double tags (in sequence of keywords - operators for example: == )
			$aSplit_Code[$i] = StringRegExpReplace($aSplit_Code[$i], $sPattern5, $sReplace5)
			$sAu3Code &= $aSplit_Code[$i] & @CRLF
		EndIf
	Next

	Return $sAu3Code
EndFunc

Func __Au3_SyntaxHighlight_GetKeywordStylesHeader()
	Local $sStyle

	Local $sFontBkColor = __Au3_SyntaxHighlight_PropertyRead($sAu3_Styles_File, 'style.au3.32', '#f0f5fa', 0)
	Local $aColor = StringSplit(__Au3_SyntaxHighlight_PropertyRead($sAu3_Styles_File, 'style.au3.0', '#000000', 0), ',')

	Local $sFontColor = $aColor[1]
	Local $sFontWeight = "normal"
	Local $sFontFamily = "Courier New"

	If $aColor[0] > 1 Then
		$sFontWeight = $aColor[2]
	EndIf

	If $aColor[0] > 2 Then
		$sFontFamily = $aColor[3]
	EndIf

	Local $sRet = _
		'<head>' & @CRLF & _
		'<style type="text/css">' & @CRLF & @CRLF & _
		'.au3_codebox' & @CRLF & _
		'{' & @CRLF & _
		'	BORDER-BOTTOM: #AAAAAA 1px solid;' & @CRLF & _
		'	BORDER-LEFT: #AAAAAA 1px solid;' & @CRLF & _
		'	BORDER-RIGHT: #AAAAAA 1px solid;' & @CRLF & _
		'	BORDER-TOP: #AAAAAA 1px solid;' & @CRLF & _
		'	PADDING-RIGHT: 8px;' & @CRLF & _
		'	PADDING-LEFT: 8px;' & @CRLF & _
		'	PADDING-BOTTOM: 8px;' & @CRLF & _
		'	PADDING-TOP: 8px;' & @CRLF & _
		'	FONT-SIZE: 12px;' & @CRLF & _
		'	FONT-FAMILY: Courier New, Verdana, Courier, Arial;' & @CRLF & _
		'	FONT-WEIGHT: ' & $sFontWeight & ';' & @CRLF & _
		'	BACKGROUND-COLOR: ' & $sFontBkColor & ';' & @CRLF & _
		'	COLOR: ' & $sFontColor & ';' & @CRLF & _
		'	WHITE-SPACE: pre;' & @CRLF & _
		'}' & @CRLF & @CRLF & _
		'a' & @CRLF & _
		'{' & @CRLF & _
		'	text-decoration:none;' & @CRLF & _
		'}' & @CRLF & @CRLF & _
		'a:hover' & @CRLF & _
		'{' & @CRLF & _
		'	text-decoration:underline;' & @CRLF & _
		'}' & @CRLF & @CRLF & _
		'pre' & @CRLF & _
		'{' & @CRLF & _
		'	font-family: Verdana, Arial, Helvetica, sans-serif, "MS sans serif";' & @CRLF & _
		'	line-height: normal;' & @CRLF & _
		'	margin-top: 0.5em;' & @CRLF & _
		'	margin-bottom: 0.5em;' & @CRLF & _
		'}' & @CRLF & @CRLF & _
		'span' & @CRLF & _
		'{' & @CRLF & _
		'	font-family: ' & $sFontFamily & ';' & @CRLF & _
		'	font-weight: ' & $sFontWeight & ';' & @CRLF & _
		'	color: ' & $sFontColor & ';' & @CRLF & _
		'}' & @CRLF & @CRLF

	For $i = 0 To 15
		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1)
		EndIf

		$sStyle = __Au3_SyntaxHighlight_PropertyRead($sAu3_Styles_File, "style.au3." & $i, "", 0)
		$sRet &= ".au3_S" & $i

		; Check if it's Special keywords, the we need to override the other style
		If $i = 11 Or $i = 12 Then
			$sRet &= ", .au3_S" & $i & " span"
		EndIf

		$sRet &= @CRLF & "{" & @CRLF

		If StringInStr($sStyle, "bold") Then
			$sRet &= "	font-weight: bold;" & @CRLF
		EndIf

		If StringInStr($sStyle, "normal") Then
			$sRet &= "	font-weight: normal;" & @CRLF
		EndIf

		If StringInStr($sStyle, "italics") Then
			$sRet &= "	font-style: italic;" & @CRLF
		EndIf

		If StringInStr($sStyle, "#") Then
			$sRet &= "	color: " & StringRegExpReplace($sStyle, ".*((?i)#[a-z0-9]+).*", "\1") & ";" & @CRLF
		EndIf

		$sRet &= "}" & @CRLF & @CRLF
	Next

	Return $sRet & '</style></head>' & @CRLF
EndFunc

Func __Au3_SyntaxHighlight_ConvertHtmlToBBCodeTags($sAu3HtmlCode)
	Local $sStyle, $sTags_Start, $sTags_End, $sRet

	For $i = 0 To 15
		If $iAu3SH_AbortHighlight = 1 Then
			Return SetError(-1)
		EndIf

		$sStyle = __Au3_SyntaxHighlight_PropertyRead($sAu3_Styles_File, "style.au3." & $i, "", 0)

		$sTags_Start = ''
		$sTags_End = ''

		If StringInStr($sStyle, "bold") Then
			$sTags_Start = '[b]'
			$sTags_End = '[/b]'
		EndIf

		If StringInStr($sStyle, "italics") Then
			$sTags_Start = '[i]' & $sTags_Start
			$sTags_End &= '[/i]'
		EndIf

		If StringInStr($sStyle, "#") Then
			$sTags_Start = '[color=' & StringRegExpReplace($sStyle, ".*((?i)#[a-z0-9]+).*", "\1") & ']' & $sTags_Start
			$sTags_End &= '[/color]'
		EndIf

		; Replace <a href=> tag with bbcode [url=] tag...
		$sAu3HtmlCode = StringRegExpReplace($sAu3HtmlCode, '(?si)(.*?)<a href="([^"]*)">(.*?)</a>(.*?)', '\1[url=\2]\3[/url]\4')

		; Replace all the styles with bbcode
		$sAu3HtmlCode = StringRegExpReplace($sAu3HtmlCode, _
			'(?si)(.*?)' & $aAu3SH_Styles[$i] & '(.*?)' & $sAu3SH_CloseTag & '(.*?)', '\1' & $sTags_Start & '\2' & $sTags_End & '\3')

		While StringRegExp($sAu3HtmlCode, $aAu3SH_Styles[$i] & '(.*?)' & $sAu3SH_CloseTag)
			$sAu3HtmlCode = StringRegExpReplace($sAu3HtmlCode, _
				'(?si)(.*?)' & $aAu3SH_Styles[$i] & '(.*?)' & $sAu3SH_CloseTag & '(.*?)', '\1' & $sTags_Start & '\2' & $sTags_End & '\3')
		WEnd
	Next

	; Replace all the html entities and <br>s
	$sAu3HtmlCode = StringReplace($sAu3HtmlCode, '<br>', @CRLF)
	$sAu3HtmlCode = StringReplace($sAu3HtmlCode, '&lt;', '<')
	$sAu3HtmlCode = StringReplace($sAu3HtmlCode, '&gt;', '>')
	$sAu3HtmlCode = StringReplace($sAu3HtmlCode, '&nbsp;', ' ')

	Return $sAu3HtmlCode
EndFunc

Func __Au3_SyntaxHighlight_PropertyRead($sFile, $sProperty, $sDefault = "", $iRetArr = 1)
	Local $aFileRead = StringSplit(StringStripCR(FileRead($sFile)), @LF)
	Local $sRet

	For $i = 1 To $aFileRead[0]
		If StringInStr($aFileRead[$i], $sProperty & "=") Then
			$aFileRead[$i] = StringTrimLeft($aFileRead[$i], StringLen($sProperty & "="))
			If StringRight($aFileRead[$i], 1) = "\" Then $aFileRead[$i] = StringTrimRight($aFileRead[$i], 1)
			$sRet &= StringStripWS($aFileRead[$i], 3)

			For $j = $i+1 To $aFileRead[0]
				If StringInStr($aFileRead[$j], "=") Then
					ExitLoop 2
				ElseIf StringLeft($aFileRead[$j], 1) <> "#" Then
					If StringRight($aFileRead[$j], 1) = "\" Then $aFileRead[$j] = StringTrimRight($aFileRead[$j], 1)
					$sRet &= " " & StringStripWS($aFileRead[$j], 3)
				EndIf
			Next

			ExitLoop
		EndIf
	Next

	If $sRet = "" Then
		$sRet = $sDefault
	EndIf

	$sRet = StringStripWS($sRet, 3)

	If $iRetArr Then
		Return StringSplit($sRet, " 	")
	EndIf

	Return $sRet
EndFunc

Func __Au3_SyntaxHighlight_Debug_RegExp_Patterns($iStep, $sPattern = "", $sReplace = "", $sNotes = "", $sTestStr = "", $iScriptLineNum = @ScriptLineNumber)
	If Not $iDebug_RegExp_Patterns And Not $iDebug_RegExp_WriteLog Then
		Return 0
	EndIf

	If $iStep = '===' Then
		$iDebug_RegExp_Step += 1
	EndIf

	If $iStep <> '===' Then
		$iStep = $iDebug_RegExp_Step & $iStep
	EndIf

	Local $sDebug_Output = '', $aLines

	If Not StringRegExp($iScriptLineNum, '^\d+$') Then
		$aLines = StringSplit($iScriptLineNum, '/')

		$sDebug_Output &= @CRLF & '   Step #' & $iStep & '...' & @CRLF

		For $i = 1 To $aLines[0]
			$sDebug_Output &= '    Line (' & $aLines[$i] & ') :'
			If $i < $aLines[0] Then $sDebug_Output &= @CRLF
		Next
	Else
		$sDebug_Output = @CRLF & '   Step #' & $iStep & ', Line (' & $iScriptLineNum & ') :'
	EndIf

	If $sPattern <> '' Then
		$sDebug_Output &= @CRLF & '- Search Pattern:' & @TAB & $sPattern
	ElseIf $iStep = '===' Then
		$sDebug_Output = '> ===================================================================================='
	ElseIf $iStep = '' Then
		$sDebug_Output = ''
	EndIf

	If $sPattern <> '' Then
		If IsString($sReplace) Then
			If $sReplace = '' Then
				$sDebug_Output &= @CRLF & '+ Replace Pattern:' & @TAB & ''''' (Empty string)'
			Else
				$sDebug_Output &= @CRLF & '+ Replace Pattern:' & @TAB & $sReplace
			EndIf
		Else
			If $sReplace = 0 Then
				$sDebug_Output &= @CRLF & '- Replace Pattern:' & @TAB & 'Check mathes (flag [0] in StringRegExp)'
			Else
				$sDebug_Output &= @CRLF & '+ Replace Pattern:' & @TAB & 'Array of mathes (flag [' & $sReplace & '] in StringRegExp)'
			EndIf
		EndIf
	EndIf

	If $sTestStr <> '' Then
		Local $iTimerInit = TimerInit()

		If $sReplace = '' Then
			StringRegExp($sTestStr, $sPattern, 3)
		Else
			StringRegExpReplace($sTestStr, $sPattern, $sReplace)
		EndIf

		$sDebug_Output &= @CRLF & ' RegExp Execution Time (ms): ' & @TAB & Round(TimerDiff($iTimerInit), 3)
	EndIf

	If $sNotes <> '' Then
		$sDebug_Output &= @CRLF & '! Note:' & @TAB & @TAB & @TAB & $sNotes
	EndIf

	If $iDebug_RegExp_WriteLog Then
		$sDebug_RegExp_LogContent &= $sDebug_Output & @CRLF
	EndIf

	If $iDebug_RegExp_Patterns Then
		ConsoleWrite($sDebug_Output & @CRLF)
	EndIf
EndFunc

Opt("MustDeclareVars", 0)
Opt("MustDeclareVars", $iAu3SH_MDV_Opt)

#EndRegion Internal Functions
