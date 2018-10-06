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