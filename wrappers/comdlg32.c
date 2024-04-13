#define _WIN32_WINNT 0x0400
#include <windows.h>

#include "debug.h"

BOOL WINAPI CORDLG32_GetOpenFileNameA(LPOPENFILENAMEA lpOpenFileName)
{
  Trace(TRACE_PASSTHROUGH, "GetOpenFileNameA");

  // .NET's hook crashes USER.EXE, so we remove it here
  lpOpenFileName->lpfnHook = NULL;

  return GetOpenFileNameA(lpOpenFileName);
}

BOOL WINAPI CORDLG32_GetOpenFileNameW(LPOPENFILENAMEW lpOpenFileName)
{
  Trace(TRACE_PASSTHROUGH, "GetOpenFileNameW");

  // .NET's hook crashes USER.EXE, so we remove it here
  lpOpenFileName->lpfnHook = NULL;

  return GetOpenFileNameW(lpOpenFileName);
}
