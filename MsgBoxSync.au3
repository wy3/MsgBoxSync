#include-once

global $__MsgBoxSync_Dll = -1, $__MsgBoxSync_Dll_Ref = 0
global const $__MsgBoxSync_Port = DllCallbackRegister('__MsgBoxSync_Port', 'none', 'int;str')

Global const $__MsgBoxSync_X64 = @AutoItX64
Global const $__MsgBoxSync_PTR_SIZE = DllStructGetSize(DllStructCreate('ptr', 1))

Global const $__MsgBoxSync_kernel32 = DllOpen('kernel32.dll')
Global const $__MsgBoxSync_user32 = DllOpen('user32.dll')

#cs
Name...........: MsgBoxSync
Syntax.........: MsgBoxSync($flags, $title, $text[, $parent = null[, $OnMsgBoxClosed = null]])
					$flags   <uint>   : The flag indicates the type of message box and the possible button combinations (see MsgBox).
				    $title   <string> : The title of the message box.
				    $text    <string> : The text of the message box.
				    $parent  <HWND>   : [optional] The window handle to use as the parent for this dialog.

				    $fnOnMsgBoxClosed  <string|func(<int>)>
				                      : [optional] The function be called after message box closed,
										the first param is return of message box (see MsgBox).
										If $OnMsgBoxClosed is null, no function called.
Return.........: 1 -> succeed.
				 0 -> failed.
Author.........: wuuyi123
#ce ===================================================================
func MsgBoxSync($uFlags, $sTitle, $sText, $hWnd = null, $fnOnMsgBoxClosed = null)
	if $__MsgBoxSync_Dll == -1 then __MsgBoxSync_Startup()

	if isfunc($fnOnMsgBoxClosed) then _
		$fnOnMsgBoxClosed = funcname($fnOnMsgBoxClosed)

	local $ret = dllcall($__MsgBoxSync_Dll, 'int:cdecl', 'MsgBoxSync', _
		'ptr', 	DllCallbackGetPtr($__MsgBoxSync_Port), _
		'str', 	$fnOnMsgBoxClosed ? $fnOnMsgBoxClosed : null, _
		'uint', $uFlags, _
		'wstr', stringformat($sTitle), _
		'wstr', stringformat($sText), 	_
		'hwnd', $hWnd _
	)

	return @error ? 0 : $ret[0]
endfunc

; // internal function
; ===========================================================================
func __MsgBoxSync_Port($ret, $fn_name)
	call($fn_name, $ret)
endfunc

func __MsgBoxSync_Startup($fLoadDLL = False, $sDll = "MsgBoxSync.dll")
	If $__MsgBoxSync_Dll = -1 Then
		If $fLoadDLL Then
			If $__MsgBoxSync_X64 And @NumParams = 1 Then $sDll = "MsgBoxSync_X64.dll"
			$__MsgBoxSync_Dll = DllOpen($sDll)
		Else
			$__MsgBoxSync_Dll = __MsgBoxSync_Mem_DllOpen()
		EndIf
		If $__MsgBoxSync_Dll = -1 Then Return SetError(1, 0, False)
	EndIf
	If $__MsgBoxSync_Dll_Ref <= 0 Then
		$__MsgBoxSync_Dll_Ref = 0
		If @error Then
			DllClose($__MsgBoxSync_Dll)
			$__MsgBoxSync_Dll = -1
			Return SetError(2, 0, False)
		EndIf
	EndIf
	$__MsgBoxSync_Dll_Ref += 1
	Return True
endfunc

Func __MsgBoxSync_Shutdown($fFinal = False)
	If $__MsgBoxSync_Dll_Ref <= 0 Then Return 0
	$__MsgBoxSync_Dll_Ref -= 1
	If $fFinal Then $__MsgBoxSync_Dll_Ref = 0
	Return $__MsgBoxSync_Dll_Ref
EndFunc

#Region Call Pointer

Func __MsgBoxSync_PointerCall($sRetType, $pAddress, $sType1 = "", $vParam1 = 0, $sType2 = "", $vParam2 = 0, $sType3 = "", $vParam3 = 0, $sType4 = "", $vParam4 = 0, $sType5 = "", $vParam5 = 0, $sType6 = "", $vParam6 = 0, $sType7 = "", $vParam7 = 0, $sType8 = "", $vParam8 = 0, $sType9 = "", $vParam9 = 0, $sType10 = "", $vParam10 = 0, $sType11 = "", $vParam11 = 0, $sType12 = "", $vParam12 = 0, $sType13 = "", $vParam13 = 0, $sType14 = "", $vParam14 = 0, $sType15 = "", $vParam15 = 0, $sType16 = "", $vParam16 = 0, $sType17 = "", $vParam17 = 0, $sType18 = "", $vParam18 = 0, $sType19 = "", $vParam19 = 0, $sType20 = "", $vParam20 = 0)
	Local Static $pHook, $hPseudo, $tPtr, $sFuncName = "MemoryCallEntry"
	If $pAddress Then
		If Not $pHook Then
			Local $sDll = "MsgBoxSync.dll"
			If $__MsgBoxSync_X64 Then $sDll = "MsgBoxSync_X64.dll"
			$hPseudo = DllOpen($sDll)
			If $hPseudo = -1 Then
				$sDll = "kernel32.dll"
				$sFuncName = "GlobalFix"
				$hPseudo = DllOpen($sDll)
			EndIf
			Local $aCall = DllCall($__MsgBoxSync_kernel32, "ptr", "GetModuleHandleW", "wstr", $sDll)
			If @error Or Not $aCall[0] Then Return SetError(7, @error, 0) ; Couldn't get dll handle
			Local $hModuleHandle = $aCall[0]
			$aCall = DllCall($__MsgBoxSync_kernel32, "ptr", "GetProcAddress", "ptr", $hModuleHandle, "str", $sFuncName)
			If @error Then Return SetError(8, @error, 0) ; Wanted function not found
			$pHook = $aCall[0]
			$aCall = DllCall($__MsgBoxSync_kernel32, "bool", "VirtualProtect", "ptr", $pHook, "dword", 7 + 5 * $__MsgBoxSync_X64, "dword", 64, "dword*", 0)
			If @error Or Not $aCall[0] Then Return SetError(9, @error, 0) ; Unable to set MEM_EXECUTE_READWRITE
			If $__MsgBoxSync_X64 Then
				DllStructSetData(DllStructCreate("word", $pHook), 1, 0xB848)
				DllStructSetData(DllStructCreate("word", $pHook + 10), 1, 0xE0FF)
			Else
				DllStructSetData(DllStructCreate("byte", $pHook), 1, 0xB8)
				DllStructSetData(DllStructCreate("word", $pHook + 5), 1, 0xE0FF)
			EndIf
			$tPtr = DllStructCreate("ptr", $pHook + 1 + $__MsgBoxSync_X64)
		EndIf
		DllStructSetData($tPtr, 1, $pAddress)
		Local $aRet
		Switch @NumParams
			Case 2
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName)
			Case 4
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1)
			Case 6
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2)
			Case 8
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3)
			Case 10
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4)
			Case 12
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5)
			Case 14
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6)
			Case 16
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7)
			Case 18
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8)
			Case 20
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9)
			Case 22
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10)
			Case 24
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11)
			Case 26
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12)
			Case 28
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13)
			Case 30
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14)
			Case 32
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15)
			Case 34
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16)
			Case 36
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17)
			Case 38
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18)
			Case 40
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18, $sType19, $vParam19)
			Case 42
				$aRet = DllCall($hPseudo, $sRetType, $sFuncName, $sType1, $vParam1, $sType2, $vParam2, $sType3, $vParam3, $sType4, $vParam4, $sType5, $vParam5, $sType6, $vParam6, $sType7, $vParam7, $sType8, $vParam8, $sType9, $vParam9, $sType10, $vParam10, $sType11, $vParam11, $sType12, $vParam12, $sType13, $vParam13, $sType14, $vParam14, $sType15, $vParam15, $sType16, $vParam16, $sType17, $vParam17, $sType18, $vParam18, $sType19, $vParam19, $sType20, $vParam20)
			Case Else
				If Mod(@NumParams, 2) Then Return SetError(4, 0, 0) ; Bad number of parameters
				Return SetError(5, 0, 0)
		EndSwitch
		Return SetError(@error, @extended, $aRet)
	EndIf
	Return SetError(6, 0, 0)
EndFunc

#EndRegion Call Pointer

#Region Embedded DLL
Func __MsgBoxSync_Mem_DllOpen($bBinaryImage = 0, $sSubrogor = "cmd.exe")
	If Not $bBinaryImage Then
		If $__MsgBoxSync_X64 Then
			$bBinaryImage = __MsgBoxSync_Mem_BinDll_X64()
		Else
			$bBinaryImage = __MsgBoxSync_Mem_BinDll()
		EndIf
	EndIf
	Local $tBinary = DllStructCreate("byte[" & BinaryLen($bBinaryImage) & "]")
	DllStructSetData($tBinary, 1, $bBinaryImage) ; fill the structure
	Local $pPointer = DllStructGetPtr($tBinary)
	Local $tIMAGE_DOS_HEADER = DllStructCreate("char Magic[2];" & _
			"word BytesOnLastPage;" & _
			"word Pages;" & _
			"word Relocations;" & _
			"word SizeofHeader;" & _
			"word MinimumExtra;" & _
			"word MaximumExtra;" & _
			"word SS;" & _
			"word SP;" & _
			"word Checksum;" & _
			"word IP;" & _
			"word CS;" & _
			"word Relocation;" & _
			"word Overlay;" & _
			"char Reserved[8];" & _
			"word OEMIdentifier;" & _
			"word OEMInformation;" & _
			"char Reserved2[20];" & _
			"dword AddressOfNewExeHeader", _
			$pPointer)
	$pPointer += DllStructGetData($tIMAGE_DOS_HEADER, "AddressOfNewExeHeader") ; move to PE file header
	$pPointer += 4
	Local $tIMAGE_FILE_HEADER = DllStructCreate("word Machine;" & _
			"word NumberOfSections;" & _
			"dword TimeDateStamp;" & _
			"dword PointerToSymbolTable;" & _
			"dword NumberOfSymbols;" & _
			"word SizeOfOptionalHeader;" & _
			"word Characteristics", _
			$pPointer)
	Local $iNumberOfSections = DllStructGetData($tIMAGE_FILE_HEADER, "NumberOfSections")
	$pPointer += 20
	Local $tMagic = DllStructCreate("word Magic;", $pPointer)
	Local $iMagic = DllStructGetData($tMagic, 1)
	Local $tIMAGE_OPTIONAL_HEADER
	If $iMagic = 267 Then
		If $__MsgBoxSync_X64 Then Return SetError(1, 0, -1)
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"dword BaseOfData;" & _
				"dword ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"dword SizeOfStackReserve;" & _
				"dword SizeOfStackCommit;" & _
				"dword SizeOfHeapReserve;" & _
				"dword SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		$pPointer += 96
	ElseIf $iMagic = 523 Then
		If Not $__MsgBoxSync_X64 Then Return SetError(1, 0, -1)
		$tIMAGE_OPTIONAL_HEADER = DllStructCreate("word Magic;" & _
				"byte MajorLinkerVersion;" & _
				"byte MinorLinkerVersion;" & _
				"dword SizeOfCode;" & _
				"dword SizeOfInitializedData;" & _
				"dword SizeOfUninitializedData;" & _
				"dword AddressOfEntryPoint;" & _
				"dword BaseOfCode;" & _
				"uint64 ImageBase;" & _
				"dword SectionAlignment;" & _
				"dword FileAlignment;" & _
				"word MajorOperatingSystemVersion;" & _
				"word MinorOperatingSystemVersion;" & _
				"word MajorImageVersion;" & _
				"word MinorImageVersion;" & _
				"word MajorSubsystemVersion;" & _
				"word MinorSubsystemVersion;" & _
				"dword Win32VersionValue;" & _
				"dword SizeOfImage;" & _
				"dword SizeOfHeaders;" & _
				"dword CheckSum;" & _
				"word Subsystem;" & _
				"word DllCharacteristics;" & _
				"uint64 SizeOfStackReserve;" & _
				"uint64 SizeOfStackCommit;" & _
				"uint64 SizeOfHeapReserve;" & _
				"uint64 SizeOfHeapCommit;" & _
				"dword LoaderFlags;" & _
				"dword NumberOfRvaAndSizes", _
				$pPointer)
		$pPointer += 112
	Else
		Return SetError(1, 0, -1)
	EndIf
	Local $iEntryPoint = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "AddressOfEntryPoint")
	Local $pOptionalHeaderImageBase = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "ImageBase")
	$pPointer += 8
	Local $tIMAGE_DIRECTORY_ENTRY_IMPORT = DllStructCreate("dword VirtualAddress; dword Size", $pPointer)
	Local $pAddressImport = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_IMPORT, "VirtualAddress")
	$pPointer += 8
	$pPointer += 24
	Local $tIMAGE_DIRECTORY_ENTRY_BASERELOC = DllStructCreate("dword VirtualAddress; dword Size", $pPointer)
	Local $pAddressNewBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "VirtualAddress")
	Local $iSizeBaseReloc = DllStructGetData($tIMAGE_DIRECTORY_ENTRY_BASERELOC, "Size")
	$pPointer += 8
	$pPointer += 40
	$pPointer += 40
	Local $pBaseAddress = __MsgBoxSync_Mem_LoadLibraryEx($sSubrogor, 1)
	If @error Then Return SetError(2, 0, -1)
	Local $pHeadersNew = DllStructGetPtr($tIMAGE_DOS_HEADER)
	Local $iOptionalHeaderSizeOfHeaders = DllStructGetData($tIMAGE_OPTIONAL_HEADER, "SizeOfHeaders")
	If Not __MsgBoxSync_Mem_VirtualProtect($pBaseAddress, $iOptionalHeaderSizeOfHeaders, 4) Then Return SetError(3, 0, -1)
	DllStructSetData(DllStructCreate("byte[" & $iOptionalHeaderSizeOfHeaders & "]", $pBaseAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iOptionalHeaderSizeOfHeaders & "]", $pHeadersNew), 1))
	Local $tIMAGE_SECTION_HEADER
	Local $iSizeOfRawData, $pPointerToRawData
	Local $iVirtualSize, $iVirtualAddress
	Local $pRelocRaw
	For $i = 1 To $iNumberOfSections
		$tIMAGE_SECTION_HEADER = DllStructCreate("char Name[8];" & _
				"dword UnionOfVirtualSizeAndPhysicalAddress;" & _
				"dword VirtualAddress;" & _
				"dword SizeOfRawData;" & _
				"dword PointerToRawData;" & _
				"dword PointerToRelocations;" & _
				"dword PointerToLinenumbers;" & _
				"word NumberOfRelocations;" & _
				"word NumberOfLinenumbers;" & _
				"dword Characteristics", _
				$pPointer)
		$iSizeOfRawData = DllStructGetData($tIMAGE_SECTION_HEADER, "SizeOfRawData")
		$pPointerToRawData = $pHeadersNew + DllStructGetData($tIMAGE_SECTION_HEADER, "PointerToRawData")
		$iVirtualAddress = DllStructGetData($tIMAGE_SECTION_HEADER, "VirtualAddress")
		$iVirtualSize = DllStructGetData($tIMAGE_SECTION_HEADER, "UnionOfVirtualSizeAndPhysicalAddress")
		If $iVirtualSize And $iVirtualSize < $iSizeOfRawData Then $iSizeOfRawData = $iVirtualSize
		; Set MEM_EXECUTE_READWRITE for sections (PAGE_EXECUTE_READWRITE for all for simplicity)
		If Not __MsgBoxSync_Mem_VirtualProtect($pBaseAddress + $iVirtualAddress, $iVirtualSize, 64) Then
			$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
			ContinueLoop
		EndIf
		; Clean the space
		DllStructSetData(DllStructCreate("byte[" & $iVirtualSize & "]", $pBaseAddress + $iVirtualAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iVirtualSize & "]"), 1))
		; If there is data to write, write it
		If $iSizeOfRawData Then DllStructSetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pBaseAddress + $iVirtualAddress), 1, DllStructGetData(DllStructCreate("byte[" & $iSizeOfRawData & "]", $pPointerToRawData), 1))
		; Relocations
		If $iVirtualAddress <= $pAddressNewBaseReloc And $iVirtualAddress + $iSizeOfRawData > $pAddressNewBaseReloc Then $pRelocRaw = $pPointerToRawData + ($pAddressNewBaseReloc - $iVirtualAddress)
		; Imports
		If $iVirtualAddress <= $pAddressImport And $iVirtualAddress + $iSizeOfRawData > $pAddressImport Then __MsgBoxSync_Mem_FixImports($pPointerToRawData + ($pAddressImport - $iVirtualAddress), $pBaseAddress) ; fix imports in place
		; Move pointer
		$pPointer += 40 ; size of $tIMAGE_SECTION_HEADER structure
	Next
	; Fix relocations
	If $pAddressNewBaseReloc And $iSizeBaseReloc Then __MsgBoxSync_Mem_FixReloc($pRelocRaw, $iSizeBaseReloc, $pBaseAddress, $pOptionalHeaderImageBase, $iMagic = 523)
	; Entry point address
	Local $pEntryFunc = $pBaseAddress + $iEntryPoint
	; DllMain simulation
	__MsgBoxSync_PointerCall("bool", $pEntryFunc, "ptr", $pBaseAddress, "dword", 1, "ptr", 0) ; DLL_PROCESS_ATTACH
	; Get pseudo-handle
	Local $hPseudo = DllOpen($sSubrogor)
	__MsgBoxSync_Mem_FreeLibrary($pBaseAddress) ; decrement reference count
	Return $hPseudo
EndFunc   ;==>__Au3Obj_Mem_DllOpen

Func __MsgBoxSync_Mem_FixReloc($pData, $iSize, $pAddressNew, $pAddressOld, $fImageX64)
	Local $iDelta = $pAddressNew - $pAddressOld ; dislocation value
	Local $tIMAGE_BASE_RELOCATION, $iRelativeMove
	Local $iVirtualAddress, $iSizeofBlock, $iNumberOfEntries
	Local $tEnries, $iData, $tAddress
	Local $iFlag = 3 + 7 * $fImageX64 ; IMAGE_REL_BASED_HIGHLOW = 3 or IMAGE_REL_BASED_DIR64 = 10
	While $iRelativeMove < $iSize ; for all data available
		$tIMAGE_BASE_RELOCATION = DllStructCreate("dword VirtualAddress; dword SizeOfBlock", $pData + $iRelativeMove)
		$iVirtualAddress = DllStructGetData($tIMAGE_BASE_RELOCATION, "VirtualAddress")
		$iSizeofBlock = DllStructGetData($tIMAGE_BASE_RELOCATION, "SizeOfBlock")
		$iNumberOfEntries = ($iSizeofBlock - 8) / 2
		$tEnries = DllStructCreate("word[" & $iNumberOfEntries & "]", DllStructGetPtr($tIMAGE_BASE_RELOCATION) + 8)
		; Go through all entries
		For $i = 1 To $iNumberOfEntries
			$iData = DllStructGetData($tEnries, 1, $i)
			If BitShift($iData, 12) = $iFlag Then ; check type
				$tAddress = DllStructCreate("ptr", $pAddressNew + $iVirtualAddress + BitAND($iData, 0xFFF)) ; the rest of $iData is offset
				DllStructSetData($tAddress, 1, DllStructGetData($tAddress, 1) + $iDelta) ; this is what's this all about
			EndIf
		Next
		$iRelativeMove += $iSizeofBlock
	WEnd
	Return 1 ; all OK!
EndFunc   ;==>__Au3Obj_Mem_FixReloc

Func __MsgBoxSync_Mem_FixImports($pImportDirectory, $hInstance)
	Local $hModule, $tFuncName, $sFuncName, $pFuncAddress
	Local $tIMAGE_IMPORT_MODULE_DIRECTORY, $tModuleName
	Local $tBufferOffset2, $iBufferOffset2
	Local $iInitialOffset, $iInitialOffset2, $iOffset
	While 1
		$tIMAGE_IMPORT_MODULE_DIRECTORY = DllStructCreate("dword RVAOriginalFirstThunk;" & _
				"dword TimeDateStamp;" & _
				"dword ForwarderChain;" & _
				"dword RVAModuleName;" & _
				"dword RVAFirstThunk", _
				$pImportDirectory)
		If Not DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk") Then ExitLoop ; the end
		$tModuleName = DllStructCreate("char Name[64]", $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAModuleName"))
		$hModule = __MsgBoxSync_Mem_LoadLibraryEx(DllStructGetData($tModuleName, "Name")) ; load the module, full load
		$iInitialOffset = $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAFirstThunk")
		$iInitialOffset2 = $hInstance + DllStructGetData($tIMAGE_IMPORT_MODULE_DIRECTORY, "RVAOriginalFirstThunk")
		If $iInitialOffset2 = $hInstance Then $iInitialOffset2 = $iInitialOffset
		$iOffset = 0 ; back to 0
		While 1
			$tBufferOffset2 = DllStructCreate("ptr", $iInitialOffset2 + $iOffset)
			$iBufferOffset2 = DllStructGetData($tBufferOffset2, 1) ; value at that address
			If Not $iBufferOffset2 Then ExitLoop ; zero value is the end
			If BitShift(BinaryMid($iBufferOffset2, $__MsgBoxSync_PTR_SIZE, 1), 7) Then ; MSB is set for imports by ordinal, otherwise not
				$pFuncAddress = __MsgBoxSync_Mem_GetAddress($hModule, BitAND($iBufferOffset2, 0xFFFFFF)) ; the rest is ordinal value
			Else
				$tFuncName = DllStructCreate("word Ordinal; char Name[64]", $hInstance + $iBufferOffset2)
				$sFuncName = DllStructGetData($tFuncName, "Name")
				$pFuncAddress = __MsgBoxSync_Mem_GetAddress($hModule, $sFuncName)
			EndIf
			DllStructSetData(DllStructCreate("ptr", $iInitialOffset + $iOffset), 1, $pFuncAddress) ; and this is what's this all about
			$iOffset += $__MsgBoxSync_PTR_SIZE ; size of $tBufferOffset2
		WEnd
		$pImportDirectory += 20
	WEnd
	Return 1
EndFunc

Func __MsgBoxSync_Mem_Base64Decode($sData) ; Ward
	Local $bOpcode
	If $__MsgBoxSync_X64 Then
		$bOpcode = Binary("0x4156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8B501000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E85301000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E80C01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8CC00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFFE8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3")
	Else
		$bOpcode = Binary("0x5557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8890100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8300100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E8EA0000008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8A80000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB99E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3")
	EndIf
	Local $tCodeBuffer = DllStructCreate("byte[" & BinaryLen($bOpcode) & "]")
	DllStructSetData($tCodeBuffer, 1, $bOpcode)
	__MsgBoxSync_Mem_VirtualProtect(DllStructGetPtr($tCodeBuffer), DllStructGetSize($tCodeBuffer), 64)
	If @error Then Return SetError(1, 0, "")
	Local $iLen = StringLen($sData)
	Local $tOut = DllStructCreate("byte[" & $iLen & "]")
	Local $tState = DllStructCreate("byte[16]")
	Local $Call = __MsgBoxSync_PointerCall("int", DllStructGetPtr($tCodeBuffer), "str", $sData, "dword", $iLen, "ptr", DllStructGetPtr($tOut), "ptr", DllStructGetPtr($tState))
	If @error Then Return SetError(2, 0, "")
	Return BinaryMid(DllStructGetData($tOut, 1), 1, $Call[0])
EndFunc

Func __MsgBoxSync_Mem_LoadLibraryEx($sModule, $iFlag = 0)
	Local $aCall = DllCall($__MsgBoxSync_kernel32, "handle", "LoadLibraryExW", "wstr", $sModule, "handle", 0, "dword", $iFlag)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc

Func __MsgBoxSync_Mem_FreeLibrary($hModule)
	Local $aCall = DllCall($__MsgBoxSync_kernel32, "bool", "FreeLibrary", "handle", $hModule)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc

Func __MsgBoxSync_Mem_GetAddress($hModule, $vFuncName)
	Local $sType = "str"
	If IsNumber($vFuncName) Then $sType = "int"
	Local $aCall = DllCall($__MsgBoxSync_kernel32, "ptr", "GetProcAddress", "handle", $hModule, $sType, $vFuncName)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc

Func __MsgBoxSync_Mem_VirtualProtect($pAddress, $iSize, $iProtection)
	Local $aCall = DllCall($__MsgBoxSync_kernel32, "bool", "VirtualProtect", "ptr", $pAddress, "dword_ptr", $iSize, "dword", $iProtection, "dword*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc

Func __MsgBoxSync_Mem_BinDll()
    Local $sData = "TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAA4fug4AtAnNIbgBTM0h"
	$sData &= "VGhpcyBwcm9ncmFtIGNhbm5vdCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAABQRQAATAEDAAAAAAAAAAAAAAAAAOAADiMLAQYAAAQAA"
	$sData &= "AAEAAAAAAAAzBEAAAAQAAAAIAAAAAAAEAAQAAAAAgAABAAAAAAAAAAEAAAAAAAAAABAAAAAAgAASgMBAAIAAAAAABAAABAAAAAAEAAAEAAAAA"
	$sData &= "AAABAAAAAAIQAATAAAAAAgAABQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAABgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAABQIAAAJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC50ZXh0AAAAOAIAAAAQAAAABAAAAAIAAAAAAAAA"
	$sData &= "AAAAAAAAACAAAGAuZGF0YQAAAEwBAAAAIAAAAAIAAAAGAAAAAAAAAAAAAAAAAABAAADALnJlbG9jAAAYAAAAADAAAAACAAAACAAAAAAAAAAAA"
	$sData &= "AAAAAAAQAAAQgAAAAAAAAAAAAAAAAAAAABVieWB7BAAAACQuBgAAABQuAEAAABQ6O0BAACDxAiJRfyLRfyLTRCJCItF/IPABItNFFGJRfjo1Q"
	$sData &= "EAAIPEBItN+IkBi0X8g8AIi00YUYlF9Oi7AQAAg8QEi030iQGLRfyDwAyLTRyJCItF/IPAEItNCIkIi0X8g8AUi00MiUXwg/kAD4QRAAAAi0U"
	$sData &= "MUOiHAQAAg8QE6QoAAAC4AAAAAOkAAAAAi03wiQG4AAAAAFC4AAAAAFCLRfxQuOkQABBQuAAAAABQuAAAAABQ6FEBAACD+AAPhAoAAAC4AQAA"
	$sData &= "AOkFAAAAuAAAAADJw1WJ5YHsFAAAAJC4AAAAAIlF/ItFCIlF+ItF+IPADItN+IPBCItV+IPCBIlF9ItF+IlN8IsIUYsCUItF8IsAUItF9IsAU"
	$sData &= "Oj1AAAAiUX8i0X4g8AQiwiD+QAPhRYAAACLRfiDwBSLCIP5AA+FBQAAAOkdAAAAi0X4g8AQi034g8EUixFSi038UYlF7ItF7IsA/9CLRfiDwB"
	$sData &= "SLCFHoqAAAAIPEBItF+IPACIsIUeiXAAAAg8QEi0X4g8AEiwhR6IYAAACDxASLRfhQ6HoAAACDxAS4AAAAAIlF+LgAAAAAycIEAAAAVYnlgew"
	$sData &= "EAAAAkItFEFCLRQxQi0UIUOgNAAAAiUX8i0X8ycIMAAAAAFWJ5YHsAAAAAJC4AQAAAMnCDAAA/yVQIAAQAAD/JVQgABAAAP8lWCAAEAAA/yVk"
	$sData &= "IAAQAAD/JWwgABAAAP8lXCAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdCAAAAAAAAAAAAAAmC"
	$sData &= "AAAFAgAACIIAAAAAAAAAAAAADHIAAAZCAAAJAgAAAAAAAAAAAAAOMgAABsIAAAAAAAAAAAAAAAAAAAAAAAAAAAAACjIAAArCAAALYgAADAIAA"
	$sData &= "AAAAAANQgAAAAAAAA7iAAAAAAAACjIAAArCAAALYgAADAIAAAAAAAANQgAAAAAAAA7iAAAAAAAABtc3ZjcnQuZGxsAAAAY2FsbG9jAAAAX3dj"
	$sData &= "c2R1cAAAAF9zdHJkdXAAAABmcmVlAGtlcm5lbDMyLmRsbAAAAENyZWF0ZVRocmVhZAB1c2VyMzIuZGxsAAAATWVzc2FnZUJveFcAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAADIhAAABAAAAAQAAAAEAAAAoIQAALCEAADAhAAAAEAAAQSEAAAAATXNnQm94U3luYy5kbGwATXNnQm94U3luYwAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAEAAAGAAAALkwCjISMhoyIjIqMjIyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
	Return __MsgBoxSync_Mem_Base64Decode($sData)
EndFunc

Func __MsgBoxSync_Mem_BinDll_X64()
    Local $sData = "TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAA4fug4AtAnNIbgBTM0h"
	$sData &= "VGhpcyBwcm9ncmFtIGNhbm5vdCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAABQRQAAZIYDAAAAAAAAAAAAAAAAAPAALiILAgYAAAQAA"
	$sData &= "AAEAAAAAAAAuBIAAAAQAAAAAAAQAAAAAAAQAAAAAgAABAAAAAAAAAAEAAAAAAAAAABAAAAAAgAAx1sAAAIAAAAAABAAAAAAAAAQAAAAAAAAAA"
	$sData &= "AQAAAAAAAAEAAAAAAAAAAAAAAQAAAAUCEAAFAAAAAAIAAAUAAAAAAAAAAAAAAAADAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUCAAAEgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAudGV4dAAAADADAAAA"
	$sData &= "EAAAAAQAAAACAAAAAAAAAAAAAAAAAAAgAABgLmRhdGEAAACgAQAAACAAAAACAAAABgAAAAAAAAAAAAAAAAAAQAAAwC5wZGF0YQAAMAAAAAAwA"
	$sData &= "AAAAgAAAAgAAAAAAAAAAAAAAAAAAEAAAEBVSInlSIHsAAAAAEiJTRBIiVUYTIlFILgBAAAAycMAAAEEAgUEAwFQVUiJ5UiB7FAAAABIiU0QSI"
	$sData &= "lVGEyJRSBMiU0oSLgwAAAAAAAAAEmJw7gBAAAASYnCTInRTIna6J0CAABIY8BIiUX4SItF+ItNIIkISItF+EiDwAhIi00oSYnKSIlF8EyJ0eh"
	$sData &= "6AgAASItN8EiJAUiLRfhIg8AQSItNMEmJykiJRehMidHoWAIAAEiLTehIiQFIi0X4SIPAGEiLTThIiQhIi0X4SIPAIEiLTRBIiQhIi0X4SIPA"
	$sData &= "KEiLTRhIiUXgSIP5AA+EFAAAAEiLRRhJicJMidHoEgIAAOkPAAAASLgAAAAAAAAAAOkAAAAASItN4EiJAUi4AAAAAAAAAABIiUQkKLgAAAAAS"
	$sData &= "IlEJCBIi0X4SYnBSI0FQwAAAEmJwEi4AAAAAAAAAABJicNIuAAAAAAAAAAASYnCTInRTIna6LABAABIg/gAD4QKAAAAuAEAAADpBQAAALgAAA"
	$sData &= "AAycNVSInlSIHsUAAAAEiJTRC4AAAAAIlF/EiLRRBIiUXwSItF8EiDwBhIi03wSIPBEEiLVfBIg8IISIlF6EiLRfBIiU3giwhJiclIiwJJicB"
	$sData &= "Ii0XgSIsASYnDSItF6EiLAEmJwkyJ0UyJ2ugwAQAAiUX8SItF8EiDwCBIiwhIg/kAD4UaAAAASItF8EiDwChIiwhIg/kAD4UFAAAA6TAAAABI"
	$sData &= "i0XwSIPAIEiLTfBIg8EoSIsRSYnTi038SYnKSIlF2EyJ0UyJ2kyLXdhNixtB/9NIi0XwSIPAKEiLCEmJykyJ0ejAAAAASItF8EiDwBBIiwhJi"
	$sData &= "cpMidHoqgAAAEiLRfBIg8AISIsISYnKTInR6JQAAABIi0XwSYnCTInR6IUAAABIuAAAAAAAAAAASIlF8LgAAAAAycNVSInlSIHsMAAAAEiJTR"
	$sData &= "BIiVUYTIlFIEiLRSBJicCLRRhJicNIi0UQSYnCTInRTIna6BL9//+JRfyLRfzJwwAAAQQCBQQDAVD/JUoNAAAAAP8lSg0AAAAA/yVKDQAAAAD"
	$sData &= "/JVoNAAAAAP8lYg0AAAAA/yU6DQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAmCAAAAAAAAAAAAAA4C"
	$sData &= "AAAFAgAADAIAAAAAAAAAAAAAAPIQAAeCAAANAgAAAAAAAAAAAAACshAACIIAAAAAAAAAAAAAAAAAAAAAAAAAAAAADrIAAAAAAAAPQgAAAAAAA"
	$sData &= "A/iAAAAAAAAAIIQAAAAAAAAAAAAAAAAAAHCEAAAAAAAAAAAAAAAAAADYhAAAAAAAAAAAAAAAAAADrIAAAAAAAAPQgAAAAAAAA/iAAAAAAAAAI"
	$sData &= "IQAAAAAAAAAAAAAAAAAAHCEAAAAAAAAAAAAAAAAAADYhAAAAAAAAAAAAAAAAAABtc3ZjcnQuZGxsAAAAY2FsbG9jAAAAX3djc2R1cAAAAF9zd"
	$sData &= "HJkdXAAAABmcmVlAGtlcm5lbDMyLmRsbAAAAENyZWF0ZVRocmVhZAB1c2VyMzIuZGxsAAAATWVzc2FnZUJveFcAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAgiEAAAEAAAABAAAAAQAAAHghAAB8IQAAgCEAACgQAACVIQAAAABNc2dCb3hTeW5jX1g2NC5kbGwATXNnQm94U3luYwAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAALEAAAHhAAACAQAAAzEAAAgxEAACAQAACOEQAAuBIAACAQAADDEgAA9hIAAPgSAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
	$sData &= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
	Return __MsgBoxSync_Mem_Base64Decode($sData)
EndFunc

#EndRegion Embedded DLL