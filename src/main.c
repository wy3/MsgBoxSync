#include "MsgBoxSync.h"

typedef struct MsgBoxSync_t {
	unsigned int 	mb_flags;
	wchar_t			*mb_title;
	wchar_t			*mb_text;
	HWND			mb_parent;
	int				(__stdcall *fn)(int ret, const char *fn_name);
	char			*fn_name;
} MsgBoxSync_t;

unsigned int __stdcall MsgBoxSync_proc(void *param);

MSGBOXSYNC_API int MsgBoxSync(void* fn, char* fn_name, unsigned int flags, wchar_t *title, wchar_t *text, HWND parent)
{
	MsgBoxSync_t *data = calloc(1, sizeof(MsgBoxSync_t));

	data->mb_flags = flags;
	data->mb_title = _wcsdup(title);
	data->mb_text = _wcsdup(text);
	data->mb_parent = parent;
	data->fn = fn;
	data->fn_name = fn_name ? _strdup(fn_name) : NULL;

	if (CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)MsgBoxSync_proc, data, 0, NULL))
		return 1;
	return 0;
}

unsigned int __stdcall MsgBoxSync_proc(void *param)
{
	int ret = 0; 
	MsgBoxSync_t *data = (MsgBoxSync_t*)param;
	
	ret = MessageBoxW(
		data->mb_parent,
		data->mb_text,
		data->mb_title,
		data->mb_flags
	);

	if (data->fn || data->fn_name)
		data->fn(ret, data->fn_name);

	free(data->fn_name);
	free(data->mb_text);
	free(data->mb_title);
	free(data);
	data = NULL;

	return 0;
}