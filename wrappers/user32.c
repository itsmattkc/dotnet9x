#define _WIN32_WINNT 0x0400
#include <windows.h>

#include "debug.h"

//
// Reimplementations
//

DWORD WINAPI CORUSR_MsgWaitForMultipleObjects(DWORD nCount, const HANDLE* pHandles, BOOL fWaitAll, DWORD dwMilliseconds, DWORD dwWakeMask)
{
  Trace(TRACE_IMPLEMENTED, "MsgWaitForMultipleObjects");
  return WaitForMultipleObjects(nCount, pHandles, fWaitAll, dwMilliseconds);
}

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

void WINAPI CORUSR_NotifyWinEvent(DWORD event, HWND  hwnd, LONG  idObject, LONG  idChild)
{
  // Only Windows 95 lacks this function so if we have it, we passthrough.
  // Otherwise, just do nothing.

  typedef void (WINAPI *NotifyWinEvent_t)(DWORD, HWND, LONG, LONG);
  NotifyWinEvent_t notifyWinEvent = (NotifyWinEvent_t) GetProcAddress(GetModuleHandleA("USER32.DLL"), "NotifyWinEvent");
  
  Trace(TRACE_IMPLEMENTED, "NotifyWinEvent");

  if (notifyWinEvent) {
    notifyWinEvent(event, hwnd, idObject, idChild);
  }
}
