#define _WIN32_WINNT 0x0400
#include <windows.h>

#include "debug.h"

BOOL WINAPI CORUSR_GetUserObjectInformationW(HANDLE param_0, INT param_1, LPVOID param_2, DWORD param_3, LPDWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetUserObjectInformationW");
  return GetUserObjectInformationW(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORUSR_PostMessageW(HWND param_0, UINT param_1, WPARAM param_2, LPARAM param_3)
{
  Trace(TRACE_PASSTHROUGH, "PostMessageW");
  return PostMessageW(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORUSR_PostMessageA(HWND param_0, UINT param_1, WPARAM param_2, LPARAM param_3)
{
  Trace(TRACE_PASSTHROUGH, "PostMessageA");
  return PostMessageA(param_0, param_1, param_2, param_3);
}

LRESULT WINAPI CORUSR_DispatchMessageW(const MSG* param_0)
{
  Trace(TRACE_PASSTHROUGH, "DispatchMessageW");
  return DispatchMessageW(param_0);
}

INT WINAPI CORUSR_MessageBoxA(HWND param_0, LPCSTR param_1, LPCSTR param_2, UINT param_3)
{
  Trace(TRACE_PASSTHROUGH, "MessageBoxA");
  return MessageBoxA(param_0, param_1, param_2, param_3);
}

INT WINAPI CORUSR_MessageBoxW(HWND param_0, LPCWSTR param_1, LPCWSTR param_2, UINT param_3)
{
  Trace(TRACE_PASSTHROUGH, "MessageBoxW");
  return MessageBoxW(param_0, param_1, param_2, param_3);
}

INT WINAPI CORUSR_GetClassNameA(HWND param_0, LPSTR param_1, INT param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetClassNameA");
  return GetClassNameA(param_0, param_1, param_2);
}

INT WINAPI CORUSR_GetClassNameW(HWND param_0, LPWSTR param_1, INT param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetClassNameW");
  return GetClassNameW(param_0, param_1, param_2);
}

INT WINAPI CORUSR_LoadStringA(HINSTANCE param_0, UINT param_1, LPSTR param_2, INT param_3)
{
  Trace(TRACE_PASSTHROUGH, "LoadStringA");
  return LoadStringA(param_0, param_1, param_2, param_3);
}

INT WINAPI CORUSR_LoadStringW(HINSTANCE param_0, UINT param_1, LPWSTR param_2, INT param_3)
{
  Trace(TRACE_PASSTHROUGH, "LoadStringW");
  return LoadStringW(param_0, param_1, param_2, param_3);
}

HWND WINAPI CORUSR_GetDesktopWindow()
{
  Trace(TRACE_PASSTHROUGH, "GetDesktopWindow");
  return GetDesktopWindow();
}

HWINSTA WINAPI CORUSR_GetProcessWindowStation()
{
  Trace(TRACE_PASSTHROUGH, "GetProcessWindowStation");
  return GetProcessWindowStation();
}

LRESULT WINAPI CORUSR_DispatchMessageA(const MSG* param_0)
{
  Trace(TRACE_PASSTHROUGH, "DispatchMessageA");
  return DispatchMessageA(param_0);
}

BOOL WINAPI CORUSR_PeekMessageW(LPMSG param_0, HWND param_1, UINT param_2, UINT param_3, UINT param_4)
{
  Trace(TRACE_PASSTHROUGH, "PeekMessageW");
  return PeekMessageW(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORUSR_PeekMessageA(LPMSG param_0, HWND param_1, UINT param_2, UINT param_3, UINT param_4)
{
  Trace(TRACE_PASSTHROUGH, "PeekMessageA");
  return PeekMessageA(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORUSR_EnumThreadWindows(DWORD param_0, WNDENUMPROC param_1,LPARAM param_2)
{
  Trace(TRACE_PASSTHROUGH, "EnumThreadWindows");
  return EnumThreadWindows(param_0, param_1, param_2);
}

BOOL WINAPI CORUSR_TranslateMessage(const MSG* param_0)
{
  Trace(TRACE_PASSTHROUGH, "TranslateMessage");
  return TranslateMessage(param_0);
}

LPSTR WINAPI CORUSR_CharNextExA(WORD param_0, LPCSTR param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "CharNextExA");
  return CharNextExA(param_0, param_1, param_2);
}

BOOL WINAPI CORUSR_InSendMessage()
{
  Trace(TRACE_PASSTHROUGH, "InSendMessage");
  return InSendMessage();
}

//
// Reimplementations
//

DWORD WINAPI CORUSR_MsgWaitForMultipleObjectsEx(DWORD nCount, const HANDLE* pHandles, DWORD dwMilliseconds, DWORD dwWakeMask, DWORD dwFlags)
{
  Trace(TRACE_IMPLEMENTED, "MsgWaitForMultipleObjectsEx");
  return WaitForMultipleObjectsEx(nCount, pHandles, (dwFlags & MWMO_WAITALL), dwMilliseconds, (dwFlags & MWMO_ALERTABLE));
}

INT WINAPIV CORUSR_wsprintfW(LPWSTR param_0, LPCWSTR param_1, ...)
{
  INT r;
  va_list args;

  Trace(TRACE_IMPLEMENTED, "wsprintfW");

  va_start(args, param_1);

  r = wvsprintfW(param_0, param_1, args);

  va_end(args);

  return r;
}
