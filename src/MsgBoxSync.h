#ifndef MSGBOXSYNC_INCLUDE
#define MSGBOXSYNC_INCLUDE
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <windows.h>
#include <stdio.h>
#include <string.h>

#ifdef BUILD_AS_DLL
#define MSGBOXSYNC_API __declspec(dllexport)
#else
#define MSGBOXSYNC_API __declspec(dllimport)
#endif

MSGBOXSYNC_API int MsgBoxSync(void* fn, char* fn_name, unsigned int flags, wchar_t *title, wchar_t *text, HWND parent);

#ifdef __cplusplus
}
#endif

#endif