#include "MsgBoxSync.au3"

global $count = 0

MsgBoxSync(0, 'Hi', 'Click OK please!', null, __MsgBoxSync_2)

do
	$count += 1
	ConsoleWrite('loop counting: ' & $count & @CRLF)

	Sleep(500)
until false

func __MsgBoxSync_2($ret)
	MsgBoxSync(4, 'Hello', 'Click Yes fo next message box,\nNo for exit.', null, __MsgBoxSync_3)
endfunc

func __MsgBoxSync_3($ret)
	if $ret == 7 then exit
	MsgBoxSync(0, 'Goodbye', '...and no see you again :)')

	exit
endfunc