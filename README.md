# MsgBoxSync
Multi-threaded Message Box for C, AutoIt.

### Usage

- **C**: 
    ```c
    int MsgBoxSync(void* fn, char* fn_name, unsigned int flags, wchar_t *title, wchar_t *text, HWND parent);
    ```

- **AutoIt3**:
    ```au3
    MsgBoxSync($uFlags, $sTitle, $sText, $hWnd = null, $fnOnMsgBoxClosed = null)
    ```

<br>

### Example

```au3
#include "MsgBoxSync.au3"

MsgBoxSync(0x20, 'MsgBoxSync 1', "I'm from MsgBoxSync() function\nwithout function for callback.", null)
MsgBoxSync(0x40, 'MsgBoxSync 2', "I'm from MsgBoxSync() function\nwith __OnMsgBoxClosed function for callback.\n" & _
	'Close me to call this function.', null, __OnMsgBoxClosed)

MsgBox(0, 'MsgBox', StringFormat("I'm from MsgBox() function.\nI'm in main thread, close me to exit."))

do ; do loop
until false

func __OnMsgBoxClosed($ret)

	ConsoleWrite(StringFormat('MsgBoxSync closed with return: ' & $ret & '\n'))

	exit
endfunc
```
<br>
<p align="center">
    <img src="https://i.imgur.com/pnOTFPg.png">
</p>
