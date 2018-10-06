# MsgBoxSync
Multi-threaded Message Box for C, AutoIt.
Callback be called when message box closed and first param is return of [MessageBox](https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-messagebox)/[MsgBox](https://www.autoitscript.com/autoit3/docs/functions/MsgBox.htm) function.

### Install

- Add `#include "MsgBoxSync.au3"`, dll binary is added in itself.

### Build

- **GCC**:
    ```batch
    $ cd MsgBoxSync
    $ gcc -shared -DBUILD_AS_DLL -o MsgBoxSync.dll src/main.c
    ```

- **Cl/MSVC compiler**:
    ```batch
    $ cd MsgBoxSync
    $ cd src
    $ cl -cl /MT /O2 /c /DBUILD_AS_DLL main.c
    $ link /DLL /IMPLIB:MsgBoxSync.lib /OUT:MsgBoxSync.dll main.obj 
    ```

### Usage

- **C**: 
    ```c
    int MsgBoxSync(void* fn, char* fn_name, unsigned int flags, wchar_t *title, wchar_t *text, HWND parent);
    ```

- **AutoIt3**:
    ```au3
    MsgBoxSync($uFlags, $sTitle, $sText, $hWnd = null, $fnOnMsgBoxClosed = null)
    ```

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
