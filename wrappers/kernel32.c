#define _WIN32_WINNT 0x0400

#include <stdio.h>
#include <windows.h>

#include "debug.h"

typedef struct _FILE_NETWORK_OPEN_INFORMATION {
  LARGE_INTEGER CreationTime;
  LARGE_INTEGER LastAccessTime;
  LARGE_INTEGER LastWriteTime;
  LARGE_INTEGER ChangeTime;
  LARGE_INTEGER AllocationSize;
  LARGE_INTEGER EndOfFile;
  ULONG FileAttributes;
} FILE_NETWORK_OPEN_INFORMATION, *PFILE_NETWORK_OPEN_INFORMATION;

// Passthroughs
BOOL WINAPI CORKEL32_CloseHandle(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "CloseHandle");
  return CloseHandle(param_0);
}

BOOL WINAPI CORKEL32_UnmapViewOfFile(LPCVOID param_0)
{
  Trace(TRACE_PASSTHROUGH, "UnmapViewOfFile");
  return UnmapViewOfFile(param_0);
}

BOOL WINAPI CORKEL32_FreeLibrary(HMODULE param_0)
{
  Trace(TRACE_PASSTHROUGH, "FreeLibrary");
  return FreeLibrary(param_0);
}

VOID WINAPI CORKEL32_SetLastError(DWORD err)
{
  Trace(TRACE_PASSTHROUGH, "SetLastError");
  SetLastError(err);
}

DWORD WINAPI CORKEL32_GetLastError()
{
  DWORD e = GetLastError();
  Trace(TRACE_PASSTHROUGH, "GetLastError: 0x%X", e);
  return e;
}

DWORD WINAPI CORKEL32_GetFileSize(HANDLE hFile, LPDWORD lpFileSizeHigh)
{
  Trace(TRACE_PASSTHROUGH, "GetFileSize");
  return GetFileSize(hFile, lpFileSizeHigh);
}

LONG WINAPI CORKEL32_InterlockedExchange(LPLONG Target,  LONG Value)
{
  Trace(TRACE_PASSTHROUGH, "InterlockedExchange");
  return InterlockedExchange(Target, Value);
}

FARPROC WINAPI CORKEL32_GetProcAddress(HMODULE hModule, LPCSTR lpProcName)
{
  FARPROC f = GetProcAddress(hModule, lpProcName);
  char buffer[256];
  GetModuleFileNameA(hModule, buffer, 256);
  Trace((f) ? TRACE_PASSTHROUGH : TRACE_POTENTIAL_ERROR, "GetProcAddress: %s %s = %p", buffer, lpProcName, f);
  return f;
}

DWORD WINAPI CORKEL32_VirtualQuery(LPCVOID param_0, PMEMORY_BASIC_INFORMATION param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "VirtualQuery");
  return VirtualQuery(param_0, param_1, param_2);
}

LPVOID WINAPI CORKEL32_VirtualAlloc(LPVOID param_0, DWORD param_1, DWORD param_2, DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "VirtualAlloc");
  return VirtualAlloc(param_0, param_1, param_2, param_3);
}

VOID WINAPI CORKEL32_GlobalMemoryStatus(LPMEMORYSTATUS param_0)
{
  Trace(TRACE_PASSTHROUGH, "GlobalMemoryStatus");
  GlobalMemoryStatus(param_0);
}

BOOL WINAPI CORKEL32_ReleaseMutex(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "ReleaseMutex");
  return ReleaseMutex(param_0);
}

DWORD WINAPI CORKEL32_WaitForSingleObject(HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "WaitForSingleObject");
  return WaitForSingleObject(param_0, param_1);
}

VOID WINAPI CORKEL32_GetSystemInfo(LPSYSTEM_INFO param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetSystemInfo");
  GetSystemInfo(param_0);
}

UINT WINAPI CORKEL32_SetErrorMode(UINT param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetErrorMode");
  return SetErrorMode(param_0);
}

LPVOID WINAPI CORKEL32_MapViewOfFile(HANDLE param_0, DWORD param_1, DWORD param_2, DWORD param_3, DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "MapViewOfFile");
  return MapViewOfFile(param_0, param_1, param_2, param_3, param_4);
}

LONG WINAPI CORKEL32_InterlockedIncrement(LONG *dest)
{
  Trace(TRACE_PASSTHROUGH, "InterlockedIncrement");
  return InterlockedIncrement(dest);
}

VOID WINAPI CORKEL32_ExitProcess(DWORD param_0)
{
  Trace(TRACE_PASSTHROUGH, "ExitProcess");
  ExitProcess(param_0);
}

BOOL WINAPI CORKEL32_DisableThreadLibraryCalls(HMODULE param_0)
{
  Trace(TRACE_PASSTHROUGH, "DisableThreadLibraryCalls");
  return DisableThreadLibraryCalls(param_0);
}

BOOL WINAPI CORKEL32_VirtualProtect(LPVOID param_0, DWORD param_1, DWORD param_2, LPDWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "VirtualProtect");
  return VirtualProtect(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_WriteFile(HANDLE param_0, LPCVOID param_1, DWORD param_2, LPDWORD param_3, LPOVERLAPPED param_4)
{
  Trace(TRACE_PASSTHROUGH, "WriteFile");
  return WriteFile(param_0, param_1, param_2, param_3, param_4);
}

VOID WINAPI CORKEL32_GetLocalTime(LPSYSTEMTIME param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetLocalTime");
  GetLocalTime(param_0);
}

BOOL WINAPI CORKEL32_ReadProcessMemory(HANDLE param_0, LPCVOID param_1, LPVOID param_2, DWORD param_3, LPDWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "ReadProcessMemory");
  return ReadProcessMemory(param_0, param_1, param_2, param_3, param_4);
}

LONG WINAPI CORKEL32_InterlockedDecrement(LONG *dest)
{
  Trace(TRACE_PASSTHROUGH, "InterlockedDecrement");
  return InterlockedDecrement(dest);
}

BOOL WINAPI CORKEL32_ReadFile(HANDLE param_0, LPVOID param_1, DWORD param_2, LPDWORD param_3, LPOVERLAPPED param_4)
{
  Trace(TRACE_PASSTHROUGH, "ReadFile");
  return ReadFile(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_FindClose(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "FindClose");
  return FindClose(param_0);
}

void WINAPI CORKEL32_InitializeCriticalSection(CRITICAL_SECTION *lpCrit)
{
  Trace(TRACE_PASSTHROUGH, "InitializeCriticalSection");
  InitializeCriticalSection(lpCrit);
}

void WINAPI CORKEL32_DeleteCriticalSection(CRITICAL_SECTION *lpCrit)
{
  Trace(TRACE_PASSTHROUGH, "DeleteCriticalSection");
  DeleteCriticalSection(lpCrit);
}

void WINAPI CORKEL32_EnterCriticalSection(CRITICAL_SECTION *lpCrit)
{
  Trace(TRACE_PASSTHROUGH, "EnterCriticalSection");
  EnterCriticalSection(lpCrit);
}

void WINAPI CORKEL32_LeaveCriticalSection(CRITICAL_SECTION *lpCrit)
{
  Trace(TRACE_PASSTHROUGH, "LeaveCriticalSection");
  LeaveCriticalSection(lpCrit);
}

HANDLE WINAPI CORKEL32_HeapCreate(DWORD param_0, DWORD param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "HeapCreate");
  return HeapCreate(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_HeapDestroy(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "HeapDestroy");
  return HeapDestroy(param_0);
}

BOOL WINAPI CORKEL32_GetStringTypeW(DWORD param_0, LPCWSTR param_1, INT param_2, LPWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetStringTypeW");
  return GetStringTypeW(param_0, param_1, param_2, param_3);
}

INT WINAPI CORKEL32_MultiByteToWideChar(UINT CodePage, DWORD dwFlags, LPCSTR lpMultiByteStr, INT cbMultiByte, LPWSTR lpWideCharStr, INT cchWideChar)
{
  INT r;

  r =  MultiByteToWideChar(CodePage, dwFlags, lpMultiByteStr, cbMultiByte, lpWideCharStr, cchWideChar);
  Trace(TRACE_PASSTHROUGH, "MultiByteToWideChar - CodePage = %u, flags = %x, result = %d", CodePage, dwFlags, r);

  return r;
}

BOOL WINAPI CORKEL32_IsDBCSLeadByteEx(UINT param_0, BYTE param_1)
{
  Trace(TRACE_PASSTHROUGH, "IsDBCSLeadByteEx");
  return IsDBCSLeadByteEx(param_0, param_1);
}

LPVOID WINAPI CORKEL32_TlsGetValue(DWORD param_0)
{
  Trace(TRACE_PASSTHROUGH, "TlsGetValue");
  return TlsGetValue(param_0);
}

HMODULE WINAPI CORKEL32_GetModuleHandleA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetModuleHandleA: %s", param_0);
  return GetModuleHandleA(param_0);
}

HLOCAL WINAPI CORKEL32_LocalFree(HLOCAL param_0)
{
  Trace(TRACE_PASSTHROUGH, "LocalFree");
  return LocalFree(param_0);
}

BOOL WINAPI CORKEL32_IsDBCSLeadByte(BYTE param_0)
{
  Trace(TRACE_PASSTHROUGH, "IsDBCSLeadByte");
  return IsDBCSLeadByte(param_0);
}

BOOL WINAPI CORKEL32_GetCPInfo(UINT param_0, LPCPINFO param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetCPInfo");
  return GetCPInfo(param_0, param_1);
}

UINT WINAPI CORKEL32_GetACP()
{
  Trace(TRACE_PASSTHROUGH, "GetACP");
  return GetACP();
}

DWORD WINAPI CORKEL32_GetCurrentThreadId()
{
  Trace(TRACE_PASSTHROUGH, "GetCurrentThreadId");
  return GetCurrentThreadId();
}

BOOL WINAPI CORKEL32_QueryPerformanceCounter(LARGE_INTEGER* param_0)
{
  Trace(TRACE_PASSTHROUGH, "QueryPerformanceCounter");
  return QueryPerformanceCounter(param_0);
}

VOID WINAPI CORKEL32_GetSystemTimeAsFileTime(LPFILETIME param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetSystemTimeAsFileTime");
  GetSystemTimeAsFileTime(param_0);
}

INT WINAPI CORKEL32_lstrlenW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "lstrlenW");
  return lstrlenW(param_0);
}

LANGID WINAPI CORKEL32_GetSystemDefaultLangID()
{
  Trace(TRACE_PASSTHROUGH, "GetSystemDefaultLangID");
  return GetSystemDefaultLangID();
}

BOOL WINAPI CORKEL32_GetVersionExA(OSVERSIONINFOA* param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetVersionExA");
  return GetVersionExA(param_0);
}

UINT WINAPI CORKEL32_GetWindowsDirectoryA(LPSTR param_0, UINT param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetWindowsDirectoryA");
  return GetWindowsDirectoryA(param_0, param_1);
}

UINT WINAPI CORKEL32_GetWindowsDirectoryW(LPWSTR param_0, UINT param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetWindowsDirectoryW");
  return GetWindowsDirectoryW(param_0, param_1);
}

HMODULE WINAPI CORKEL32_GetModuleHandleW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetModuleHandleW");
  return GetModuleHandleW(param_0);
}

BOOL WINAPI CORKEL32_FreeEnvironmentStringsA(LPSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "FreeEnvironmentStringsA");
  return FreeEnvironmentStringsA(param_0);
}

LPSTR WINAPI CORKEL32_GetEnvironmentStrings()
{
  Trace(TRACE_PASSTHROUGH, "GetEnvironmentStrings");
  return GetEnvironmentStrings();
}

LPWSTR WINAPI CORKEL32_GetEnvironmentStringsW()
{
  Trace(TRACE_PASSTHROUGH, "GetEnvironmentStringsW");
  return GetEnvironmentStringsW();
}

BOOL WINAPI CORKEL32_FreeEnvironmentStringsW(LPWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "FreeEnvironmentStringsW");
  return FreeEnvironmentStringsW(param_0);
}

INT WINAPI CORKEL32_WideCharToMultiByte(UINT CodePage, DWORD dwFlags, LPCWSTR lpWideCharStr, INT cchWideChar, LPSTR lpMultiByteStr, INT cbMultiByte, LPCSTR lpDefaultChar, LPBOOL lpUsedDefaultChar)
{
  INT r;
  dwFlags = 0;
  r = WideCharToMultiByte(CodePage, dwFlags, lpWideCharStr, cchWideChar, lpMultiByteStr, cbMultiByte, lpDefaultChar, lpUsedDefaultChar);
  Trace(TRACE_PASSTHROUGH, "WideCharToMultiByte, r = %i, CodePage = %u, dwFlags = %u", r, CodePage, dwFlags);
  return r;
}

BOOL WINAPI CORKEL32_TerminateProcess(HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "TerminateProcess");
  return TerminateProcess(param_0, param_1);
}

HANDLE WINAPI CORKEL32_GetCurrentProcess()
{
  Trace(TRACE_PASSTHROUGH, "GetCurrentProcess");
  return GetCurrentProcess();
}

HMODULE WINAPI CORKEL32_LoadLibraryExA(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
  HMODULE h = LoadLibraryExA(lpLibFileName, hFile, dwFlags);
  Trace((h != NULL) ? TRACE_PASSTHROUGH : TRACE_POTENTIAL_ERROR, "LoadLibraryExA: %s - result: %p", lpLibFileName, h);
  return h;
}

HMODULE WINAPI CORKEL32_LoadLibraryExW(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
  HMODULE h = LoadLibraryExW(lpLibFileName, hFile, dwFlags);
  Trace((h != NULL) ? TRACE_PASSTHROUGH : TRACE_POTENTIAL_ERROR, "LoadLibraryExW: %ls - result: %p", lpLibFileName, h);
  return h;
}

DWORD WINAPI CORKEL32_GetFullPathNameA(LPCSTR param_0, DWORD param_1, LPSTR param_2, LPSTR* param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetFullPathNameA");
  return GetFullPathNameA(param_0, param_1, param_2, param_3);
}

DWORD WINAPI CORKEL32_GetFullPathNameW(LPCWSTR param_0, DWORD param_1, LPWSTR param_2, LPWSTR* param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetFullPathNameW");
  return GetFullPathNameW(param_0, param_1, param_2, param_3);
}

DWORD WINAPI CORKEL32_GetModuleFileNameA(HMODULE param_0, LPSTR param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetModuleFileNameA");
  return GetModuleFileNameA(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_GetModuleFileNameW(HMODULE param_0, LPWSTR param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetModuleFileNameW");
  return GetModuleFileNameW(param_0, param_1, param_2);
}

void WINAPI CORKEL32_RaiseException(DWORD param_0, DWORD param_1, DWORD param_2, CONST DWORD * param_3)
{
  Trace(TRACE_PASSTHROUGH, "RaiseException");
  RaiseException(param_0, param_1, param_2, param_3);
}

HANDLE WINAPI CORKEL32_CreateFileA(LPCSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, LPSECURITY_ATTRIBUTES lpSecurityAttributes, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile)
{
  /*LONG fnLen;
  char temp2[512];
  HANDLE h;
  DWORD le;*/

  Trace(TRACE_PASSTHROUGH, "CreateFileA");

  if (!strcmp(lpFileName, "\\\\.\\NDPHLPR.VXD")) {
    return (HANDLE) 0xCAFEBABE;
  }

  /*if (dwFlagsAndAttributes & FILE_FLAG_DELETE_ON_CLOSE) {
    sprintf(temp2, "lpFileName: %s, dwDesiredAccess: %x, dwShareMode: %x, lpSecurityAttributes: %p, dwCreationDisposition: %x, dwFlagsAndAttributes: %x, hTemplateFile: %x", lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
    MessageBoxA(NULL, temp2, NULL, 0);
  }

  h = CreateFileA(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);

  if (dwFlagsAndAttributes & FILE_FLAG_DELETE_ON_CLOSE) {
    le = GetLastError();
    if (le) {
      sprintf(temp2, "CreateFileA Failed: 0x%X", le);
      MessageBoxA(0, temp2, 0, 0);
      SetLastError(le);
    }
  }*/

  return CreateFileA(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
}

HANDLE WINAPI CORKEL32_CreateFileW(LPCWSTR param_0, DWORD param_1, DWORD param_2, LPSECURITY_ATTRIBUTES param_3, DWORD param_4, DWORD param_5, HANDLE param_6)
{
  Trace(TRACE_PASSTHROUGH, "CreateFileW");
  return CreateFileW(param_0, param_1, param_2, param_3, param_4, param_5, param_6);
}

HANDLE WINAPI CORKEL32_CreateSemaphoreA(LPSECURITY_ATTRIBUTES param_0, LONG param_1, LONG param_2, LPCSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "CreateSemaphoreA");
  return CreateSemaphoreA(param_0, param_1, param_2, param_3);
}

HANDLE WINAPI CORKEL32_CreateSemaphoreW(LPSECURITY_ATTRIBUTES param_0, LONG param_1, LONG param_2, LPCWSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "CreateSemaphoreW");
  return CreateSemaphoreW(param_0, param_1, param_2, param_3);
}

INT WINAPI CORKEL32_GetDateFormatA(LCID param_0, DWORD param_1, const SYSTEMTIME* param_2, LPCSTR param_3, LPSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "GetDateFormatA");
  return GetDateFormatA(param_0, param_1, param_2, param_3, param_4, param_5);
}

INT WINAPI CORKEL32_GetDateFormatW(LCID param_0, DWORD param_1, const SYSTEMTIME* param_2, LPCWSTR param_3, LPWSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "GetDateFormatW");
  return GetDateFormatW(param_0, param_1, param_2, param_3, param_4, param_5);
}

INT WINAPI CORKEL32_GetTimeFormatA(LCID param_0, DWORD param_1, const SYSTEMTIME* param_2, LPCSTR param_3, LPSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "GetTimeFormatA");
  return GetTimeFormatA(param_0, param_1, param_2, param_3, param_4, param_5);
}

INT WINAPI CORKEL32_GetTimeFormatW(LCID param_0, DWORD param_1, const SYSTEMTIME* param_2, LPCWSTR param_3, LPWSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "GetTimeFormatW");
  return GetTimeFormatW(param_0, param_1, param_2, param_3, param_4, param_5);
}

INT WINAPI CORKEL32_LCMapStringA(LCID param_0, DWORD param_1, LPCSTR param_2, INT param_3, LPSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "LCMapStringA");
  return LCMapStringA(param_0, param_1, param_2, param_3, param_4, param_5);
}

INT WINAPI CORKEL32_LCMapStringW(LCID param_0, DWORD param_1, LPCWSTR param_2, INT param_3, LPWSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "LCMapStringW");
  return LCMapStringW(param_0, param_1, param_2, param_3, param_4, param_5);
}

HANDLE WINAPI CORKEL32_FindFirstFileA(LPCSTR param_0, LPWIN32_FIND_DATAA param_1)
{
  Trace(TRACE_PASSTHROUGH, "FindFirstFileA");
  return FindFirstFileA(param_0, param_1);
}

HANDLE WINAPI CORKEL32_FindFirstFileW(LPCWSTR param_0, LPWIN32_FIND_DATAW param_1)
{
  Trace(TRACE_PASSTHROUGH, "FindFirstFileW");
  return FindFirstFileW(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetVersionExW(OSVERSIONINFOW* param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetVersionExW");
  return GetVersionExW(param_0);
}

VOID WINAPI CORKEL32_OutputDebugStringA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "OutputDebugStringA");
  OutputDebugStringA(param_0);
}

VOID WINAPI CORKEL32_OutputDebugStringW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "OutputDebugStringW");
  OutputDebugStringW(param_0);
}

HANDLE WINAPI CORKEL32_CreateMutexA(LPSECURITY_ATTRIBUTES param_0, BOOL param_1, LPCSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "CreateMutexA");
  return CreateMutexA(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_CreateMutexW(LPSECURITY_ATTRIBUTES param_0, BOOL param_1, LPCWSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "CreateMutexW");
  return CreateMutexW(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_CreateEventA(LPSECURITY_ATTRIBUTES param_0, BOOL param_1, BOOL param_2, LPCSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "CreateEventA");
  return CreateEventA(param_0, param_1, param_2, param_3);
}

HANDLE WINAPI CORKEL32_CreateEventW(LPSECURITY_ATTRIBUTES param_0, BOOL param_1, BOOL param_2, LPCWSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "CreateEventW");
  return CreateEventW(param_0, param_1, param_2, param_3);
}

DWORD WINAPI CORKEL32_GetFileAttributesA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetFileAttributesA - %s", param_0);
  return GetFileAttributesA(param_0);
}

DWORD WINAPI CORKEL32_GetFileAttributesW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetFileAttributesW - %ls", param_0);
  return GetFileAttributesW(param_0);
}

DWORD WINAPI CORKEL32_GetEnvironmentVariableA(LPCSTR lpName, LPSTR lpBuffer, DWORD nSize)
{
  DWORD r = GetEnvironmentVariableA(lpName, lpBuffer, nSize);
  Trace(TRACE_PASSTHROUGH, "GetEnvironmentVariableA - r = %u - %s = %s", r, lpName, lpBuffer);
  return r;
}

DWORD WINAPI CORKEL32_GetEnvironmentVariableW(LPCWSTR lpName, LPWSTR lpBuffer, DWORD nSize)
{
  Trace(TRACE_PASSTHROUGH, "GetEnvironmentVariableW");
  return GetEnvironmentVariableW(lpName, lpBuffer, nSize);
}

HANDLE WINAPI CORKEL32_CreateFileMappingA(HANDLE param_0, LPSECURITY_ATTRIBUTES param_1, DWORD param_2, DWORD param_3, DWORD param_4, LPCSTR param_5)
{
  Trace(TRACE_PASSTHROUGH, "CreateFileMappingA");
  return CreateFileMappingA(param_0, param_1, param_2, param_3, param_4, param_5);
}

HANDLE WINAPI CORKEL32_CreateFileMappingW(HANDLE param_0, LPSECURITY_ATTRIBUTES param_1, DWORD param_2, DWORD param_3, DWORD param_4, LPCWSTR param_5)
{
  Trace(TRACE_PASSTHROUGH, "CreateFileMappingW");
  return CreateFileMappingW(param_0, param_1, param_2, param_3, param_4, param_5);
}

DWORD WINAPI CORKEL32_GetCurrentProcessId()
{
  Trace(TRACE_PASSTHROUGH, "GetCurrentProcessId");
  return GetCurrentProcessId();
}

HLOCAL WINAPI CORKEL32_LocalAlloc(UINT param_0, UINT param_1)
{
  Trace(TRACE_PASSTHROUGH, "LocalAlloc");
  return LocalAlloc(param_0, param_1);
}

DWORD WINAPI CORKEL32_FormatMessageA(DWORD param_0, LPCVOID param_1, DWORD param_2, DWORD param_3, LPSTR param_4, DWORD param_5, va_list* param_6)
{
  Trace(TRACE_PASSTHROUGH, "FormatMessageA");
  return FormatMessageA(param_0, param_1, param_2, param_3, param_4, param_5, param_6);
}

DWORD WINAPI CORKEL32_FormatMessageW(DWORD param_0, LPCVOID param_1, DWORD param_2, DWORD param_3, LPWSTR param_4, DWORD param_5, va_list* param_6)
{
  Trace(TRACE_PASSTHROUGH, "FormatMessageW");
  return FormatMessageW(param_0, param_1, param_2, param_3, param_4, param_5, param_6);
}

BOOL WINAPI CORKEL32_SetEvent(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetEvent");
  return SetEvent(param_0);
}

BOOL WINAPI CORKEL32_ResetEvent(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "ResetEvent");
  return ResetEvent(param_0);
}

BOOL WINAPI CORKEL32_ReleaseSemaphore(HANDLE param_0, LONG param_1, LPLONG param_2)
{
  Trace(TRACE_PASSTHROUGH, "ReleaseSemaphore");
  return ReleaseSemaphore(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_TlsSetValue(DWORD param_0, LPVOID param_1)
{
  Trace(TRACE_PASSTHROUGH, "TlsSetValue");
  return TlsSetValue(param_0, param_1);
}

DWORD WINAPI CORKEL32_TlsAlloc()
{
  Trace(TRACE_PASSTHROUGH, "TlsAlloc");
  return TlsAlloc();
}

BOOL WINAPI CORKEL32_TlsFree(DWORD param_0)
{
  Trace(TRACE_PASSTHROUGH, "TlsFree");
  return TlsFree(param_0);
}

LPVOID WINAPI CORKEL32_HeapAlloc(HANDLE param_0, DWORD param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "HeapAlloc");
  return HeapAlloc(param_0, param_1, param_2);;
}

HANDLE WINAPI CORKEL32_GetProcessHeap()
{
  Trace(TRACE_PASSTHROUGH, "GetProcessHeap");
  return GetProcessHeap();
}

BOOL WINAPI CORKEL32_HeapFree(HANDLE param_0, DWORD param_1, LPVOID param_2)
{
  Trace(TRACE_PASSTHROUGH, "HeapFree");
  return HeapFree(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_WaitForSingleObjectEx(HANDLE param_0, DWORD param_1, BOOL param_2)
{
  Trace(TRACE_PASSTHROUGH, "WaitForSingleObjectEx");
  return WaitForSingleObjectEx(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_SleepEx(DWORD param_0, BOOL param_1)
{
  Trace(TRACE_PASSTHROUGH, "SleepEx");
  return SleepEx(param_0, param_1);
}

BOOL WINAPI CORKEL32_VirtualFree(LPVOID param_0, DWORD param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "VirtualFree");
  return VirtualFree(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_HeapValidate(HANDLE param_0, DWORD param_1, LPCVOID param_2)
{
  Trace(TRACE_PASSTHROUGH, "HeapValidate");
  return HeapValidate(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_CreateThread(LPSECURITY_ATTRIBUTES param_0, DWORD param_1, LPTHREAD_START_ROUTINE param_2, LPVOID param_3, DWORD param_4, LPDWORD param_5)
{
  Trace(TRACE_PASSTHROUGH, "CreateThread");
  return CreateThread(param_0, param_1, param_2, param_3, param_4, param_5);
}

HANDLE WINAPI CORKEL32_GetStdHandle(DWORD param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetStdHandle");
  return GetStdHandle(param_0);
}

HMODULE WINAPI CORKEL32_LoadLibraryA(LPCSTR lpLibFileName)
{
  HMODULE h = LoadLibraryA(lpLibFileName);
  Trace((h != NULL) ? TRACE_PASSTHROUGH : TRACE_POTENTIAL_ERROR, "LoadLibraryA: %s - result: %p", lpLibFileName, h);
  return h;
}

LPSTR WINAPI CORKEL32_GetCommandLineA()
{
  Trace(TRACE_PASSTHROUGH, "GetCommandLineA");
  return GetCommandLineA();
}

VOID WINAPI CORKEL32_Sleep(DWORD param_0)
{
  Trace(TRACE_PASSTHROUGH, "Sleep");
  Sleep(param_0);
}

UINT WINAPI CORKEL32_SetHandleCount(UINT param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetHandleCount");
  return SetHandleCount(param_0);
}

DWORD WINAPI CORKEL32_GetFileType(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetFileType");
  return GetFileType(param_0);
}

VOID WINAPI CORKEL32_GetStartupInfoA(LPSTARTUPINFOA param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetStartupInfoA");
  GetStartupInfoA(param_0);
}

LONG WINAPI CORKEL32_UnhandledExceptionFilter(PEXCEPTION_POINTERS param_0)
{
  Trace(TRACE_PASSTHROUGH, "UnhandledExceptionFilter");
  return UnhandledExceptionFilter(param_0);
}

DWORD WINAPI CORKEL32_GetTickCount()
{
  Trace(TRACE_PASSTHROUGH, "GetTickCount");
  return GetTickCount();
}

LPTOP_LEVEL_EXCEPTION_FILTER WINAPI CORKEL32_SetUnhandledExceptionFilter(LPTOP_LEVEL_EXCEPTION_FILTER param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetUnhandledExceptionFilter");
  return SetUnhandledExceptionFilter(param_0);
}

UINT WINAPI CORKEL32_GetOEMCP()
{
  Trace(TRACE_PASSTHROUGH, "GetOEMCP");
  return GetOEMCP();
}

DWORD WINAPI CORKEL32_HeapSize(HANDLE param_0, DWORD param_1, LPCVOID param_2)
{
  Trace(TRACE_PASSTHROUGH, "HeapSize");
  return HeapSize(param_0, param_1, param_2);
}

LPVOID WINAPI CORKEL32_HeapReAlloc(HANDLE param_0, DWORD param_1, LPVOID param_2, DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "HeapReAlloc");
  return HeapReAlloc(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_GetStringTypeA(LCID param_0, DWORD param_1, LPCSTR param_2, INT param_3, LPWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetStringTypeA");
  return GetStringTypeA(param_0, param_1, param_2, param_3, param_4);
}

INT WINAPI CORKEL32_GetLocaleInfoA(LCID param_0, LCTYPE param_1, LPSTR param_2, INT param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetLocaleInfoA");
  return GetLocaleInfoA(param_0, param_1, param_2, param_3);
}

DWORD WINAPI CORKEL32_SetFilePointer(HANDLE param_0, LONG param_1, LPLONG param_2, DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "SetFilePointer");
  return SetFilePointer(param_0, param_1, param_2, param_3);
}

UINT WINAPI CORKEL32_GetConsoleCP()
{
  Trace(TRACE_PASSTHROUGH, "GetConsoleCP");
  return GetConsoleCP();
}

BOOL WINAPI CORKEL32_GetConsoleMode( HANDLE param_0, DWORD * param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetConsoleMode");
  return GetConsoleMode(param_0, param_1);
}

BOOL WINAPI CORKEL32_SetStdHandle(DWORD param_0, HANDLE param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetStdHandle");
  return SetStdHandle(param_0, param_1);
}

BOOL WINAPI CORKEL32_WriteConsoleA(HANDLE param_0, const void * param_1, DWORD param_2, DWORD * param_3, void * param_4)
{
  Trace(TRACE_PASSTHROUGH, "WriteConsoleA");
  return WriteConsoleA(param_0, param_1, param_2, param_3, param_4);
}

UINT WINAPI CORKEL32_GetConsoleOutputCP()
{
  Trace(TRACE_PASSTHROUGH, "GetConsoleOutputCP");
  return GetConsoleOutputCP();
}

BOOL WINAPI CORKEL32_WriteConsoleW(HANDLE param_0, const void * param_1, DWORD param_2, DWORD * param_3, void * param_4)
{
  Trace(TRACE_PASSTHROUGH, "WriteConsoleW");
  return WriteConsoleW(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_FlushFileBuffers(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "FlushFileBuffers");
  return FlushFileBuffers(param_0);
}

// RtlUnwind is in KERNEL32 but has no header, so we must define it here
extern NTAPI RtlUnwind(void* param_0, void* param_1, struct _EXCEPTION_RECORD* param_2, void* param_3);
void NTAPI CORKEL32_RtlUnwind(void* param_0, void* param_1, struct _EXCEPTION_RECORD* param_2, void* param_3)
{
  Trace(TRACE_PASSTHROUGH, "RtlUnwind");
  RtlUnwind(param_0, param_1, param_2, param_3);
}

UINT WINAPI CORKEL32_GetSystemDirectoryW(LPWSTR param_0, UINT param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetSystemDirectoryW");
  return GetSystemDirectoryW(param_0, param_1);
}

void WINAPI CORKEL32_DebugBreak()
{
  Trace(TRACE_PASSTHROUGH, "DebugBreak");
  DebugBreak();
}

VOID WINAPI CORKEL32_ExitThread(DWORD param_0)
{
  Trace(TRACE_PASSTHROUGH, "ExitThread");
  ExitThread(param_0);
}

DWORD WINAPI CORKEL32_ResumeThread(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "ResumeThread");
  return ResumeThread(param_0);
}

HANDLE WINAPI CORKEL32_GetCurrentThread()
{
  Trace(TRACE_PASSTHROUGH, "GetCurrentThread");
  return GetCurrentThread();
}

BOOL WINAPI CORKEL32_FindNextFileA(HANDLE param_0, LPWIN32_FIND_DATAA param_1)
{
  Trace(TRACE_PASSTHROUGH, "FindNextFileA");
  return FindNextFileA(param_0, param_1);
}

BOOL WINAPI CORKEL32_FindNextFileW(HANDLE param_0, LPWIN32_FIND_DATAW param_1)
{
  Trace(TRACE_PASSTHROUGH, "FindNextFileW");
  return FindNextFileW(param_0, param_1);
}

BOOL WINAPI CORKEL32_FileTimeToSystemTime(const FILETIME* param_0, LPSYSTEMTIME param_1)
{
  Trace(TRACE_PASSTHROUGH, "FileTimeToSystemTime");
  return FileTimeToSystemTime(param_0, param_1);
}

BOOL WINAPI CORKEL32_FileTimeToLocalFileTime(const FILETIME* param_0, LPFILETIME param_1)
{
  Trace(TRACE_PASSTHROUGH, "FileTimeToLocalFileTime");
  return FileTimeToLocalFileTime(param_0, param_1);
}

BOOL WINAPI CORKEL32_IsValidCodePage(UINT param_0)
{
  Trace(TRACE_PASSTHROUGH, "IsValidCodePage");
  return IsValidCodePage(param_0);
}

BOOL WINAPI CORKEL32_SetConsoleCtrlHandler( PHANDLER_ROUTINE param_0, BOOL param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetConsoleCtrlHandler");
  return SetConsoleCtrlHandler(param_0, param_1);
}

LPWSTR WINAPI CORKEL32_GetCommandLineW()
{
  Trace(TRACE_PASSTHROUGH, "GetCommandLineW");
  return GetCommandLineW();
}

BOOL WINAPI CORKEL32_SetLocalTime(const SYSTEMTIME* param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetLocalTime");
  return SetLocalTime(param_0);
}

HMODULE WINAPI CORKEL32_LoadLibraryW(LPCWSTR lpLibFileName)
{
  HMODULE h = LoadLibraryW(lpLibFileName);
  Trace((h != NULL) ? TRACE_PASSTHROUGH : TRACE_POTENTIAL_ERROR, "LoadLibraryW: %ls - result: %p", lpLibFileName, h);
  return h;
}

INT WINAPI CORKEL32_GetLocaleInfoW(LCID param_0, LCTYPE param_1, LPWSTR param_2, INT param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetLocaleInfoW");
  return GetLocaleInfoW(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_SetEnvironmentVariableA(LPCSTR param_0, LPCSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetEnvironmentVariableA");
  return SetEnvironmentVariableA(param_0, param_1);
}

BOOL WINAPI CORKEL32_SetEnvironmentVariableW(LPCWSTR param_0, LPCWSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetEnvironmentVariableW");
  return SetEnvironmentVariableW(param_0, param_1);
}

LCID WINAPI CORKEL32_GetUserDefaultLCID()
{
  Trace(TRACE_PASSTHROUGH, "GetUserDefaultLCID");
  return GetUserDefaultLCID();
}

BOOL WINAPI CORKEL32_EnumSystemLocalesA(LOCALE_ENUMPROCA param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "EnumSystemLocalesA");
  return EnumSystemLocalesA(param_0, param_1);
}

BOOL WINAPI CORKEL32_IsValidLocale(LCID param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "IsValidLocale");
  return IsValidLocale(param_0, param_1);
}

DWORD WINAPI CORKEL32_GetTimeZoneInformation(LPTIME_ZONE_INFORMATION param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetTimeZoneInformation");
  return GetTimeZoneInformation(param_0);
}

INT WINAPI CORKEL32_CompareStringA(LCID param_0, DWORD param_1, LPCSTR param_2, INT param_3, LPCSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "CompareStringA");
  return CompareStringA(param_0, param_1, param_2, param_3, param_4, param_5);
}

INT WINAPI CORKEL32_CompareStringW(LCID param_0, DWORD param_1, LPCWSTR param_2, INT param_3, LPCWSTR param_4, INT param_5)
{
  Trace(TRACE_PASSTHROUGH, "CompareStringW");
  return CompareStringW(param_0, param_1, param_2, param_3, param_4, param_5);
}

BOOL WINAPI CORKEL32_Beep(DWORD param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "Beep");
  return Beep(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetDiskFreeSpaceA(LPCSTR param_0, LPDWORD param_1, LPDWORD param_2, LPDWORD param_3, LPDWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetDiskFreeSpaceA");
  return GetDiskFreeSpaceA(param_0, param_1, param_2, param_3, param_4);
}

DWORD WINAPI CORKEL32_GetLogicalDrives()
{
  Trace(TRACE_PASSTHROUGH, "GetLogicalDrives");
  return GetLogicalDrives();
}

UINT WINAPI CORKEL32_GetCurrentDirectoryA(UINT param_0, LPSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetCurrentDirectoryA");
  return GetCurrentDirectoryA(param_0, param_1);
}

BOOL WINAPI CORKEL32_SetCurrentDirectoryA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetCurrentDirectoryA");
  return SetCurrentDirectoryA(param_0);
}

BOOL WINAPI CORKEL32_SetFileAttributesA(LPCSTR param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetFileAttributesA");
  return SetFileAttributesA(param_0, param_1);
}

UINT WINAPI CORKEL32_GetDriveTypeA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetDriveTypeA");
  return GetDriveTypeA(param_0);
}

BOOL WINAPI CORKEL32_CreateDirectoryA(LPCSTR param_0, LPSECURITY_ATTRIBUTES param_1)
{
  Trace(TRACE_PASSTHROUGH, "CreateDirectoryA");
  return CreateDirectoryA(param_0, param_1);
}

BOOL WINAPI CORKEL32_RemoveDirectoryA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "RemoveDirectoryA");
  return RemoveDirectoryA(param_0);
}

BOOL WINAPI CORKEL32_DeleteFileA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "DeleteFileA");
  return DeleteFileA(param_0);
}

UINT WINAPI CORKEL32_GetCurrentDirectoryW(UINT param_0, LPWSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetCurrentDirectoryW");
  return GetCurrentDirectoryW(param_0, param_1);
}

BOOL WINAPI CORKEL32_SetCurrentDirectoryW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetCurrentDirectoryW");
  return SetCurrentDirectoryW(param_0);
}

BOOL WINAPI CORKEL32_SetFileAttributesW(LPCWSTR param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetFileAttributesW");
  return SetFileAttributesW(param_0, param_1);
}

BOOL WINAPI CORKEL32_CreateDirectoryW(LPCWSTR param_0, LPSECURITY_ATTRIBUTES param_1)
{
  Trace(TRACE_PASSTHROUGH, "CreateDirectoryW");
  return CreateDirectoryW(param_0, param_1);
}

BOOL WINAPI CORKEL32_DeleteFileW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "DeleteFileW");
  return DeleteFileW(param_0);
}

BOOL WINAPI CORKEL32_MoveFileW(LPCWSTR param_0, LPCWSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "MoveFileW");
  return MoveFileW(param_0, param_1);
}

BOOL WINAPI CORKEL32_RemoveDirectoryW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "RemoveDirectoryW");
  return RemoveDirectoryW(param_0);
}

UINT WINAPI CORKEL32_GetDriveTypeW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetDriveTypeW");
  return GetDriveTypeW(param_0);
}

BOOL WINAPI CORKEL32_MoveFileA(LPCSTR param_0, LPCSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "MoveFileA");
  return MoveFileA(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetExitCodeProcess(HANDLE param_0, LPDWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetExitCodeProcess");
  return GetExitCodeProcess(param_0, param_1);
}

BOOL WINAPI CORKEL32_CreateProcessA(LPCSTR param_0, LPSTR param_1, LPSECURITY_ATTRIBUTES param_2, LPSECURITY_ATTRIBUTES param_3, BOOL param_4, DWORD param_5, LPVOID param_6, LPCSTR param_7, LPSTARTUPINFOA param_8, LPPROCESS_INFORMATION param_9)
{
  Trace(TRACE_PASSTHROUGH, "CreateProcessA");
  return CreateProcessA(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9);
}

BOOL WINAPI CORKEL32_CreateProcessW(LPCWSTR param_0, LPWSTR param_1, LPSECURITY_ATTRIBUTES param_2, LPSECURITY_ATTRIBUTES param_3, BOOL param_4, DWORD param_5, LPVOID param_6, LPCWSTR param_7, LPSTARTUPINFOW param_8, LPPROCESS_INFORMATION param_9)
{
  Trace(TRACE_PASSTHROUGH, "CreateProcessW");
  return CreateProcessW(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9);
}

UINT WINAPI CORKEL32_HeapCompact(HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "HeapCompact");
  return HeapCompact(param_0, param_1);
}

BOOL WINAPI CORKEL32_HeapWalk(HANDLE param_0, LPPROCESS_HEAP_ENTRY param_1)
{
  Trace(TRACE_PASSTHROUGH, "HeapWalk");
  return HeapWalk(param_0, param_1);
}

BOOL WINAPI CORKEL32_ReadConsoleA(HANDLE param_0, void * param_1, DWORD param_2, DWORD * param_3, void * param_4)
{
  Trace(TRACE_PASSTHROUGH, "ReadConsoleA");
  return ReadConsoleA(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_ReadConsoleW(HANDLE param_0, void * param_1, DWORD param_2, DWORD * param_3, void * param_4)
{
  Trace(TRACE_PASSTHROUGH, "ReadConsoleW");
  return ReadConsoleW(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_SetConsoleMode( HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetConsoleMode");
  return SetConsoleMode(param_0, param_1);
}

BOOL WINAPI CORKEL32_SetEndOfFile(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetEndOfFile");
  return SetEndOfFile(param_0);
}

BOOL WINAPI CORKEL32_DuplicateHandle(HANDLE param_0, HANDLE param_1, HANDLE param_2, HANDLE* param_3, DWORD param_4, BOOL param_5, DWORD param_6)
{
  Trace(TRACE_PASSTHROUGH, "DuplicateHandle");
  return DuplicateHandle(param_0, param_1, param_2, param_3, param_4, param_5, param_6);
}

BOOL WINAPI CORKEL32_GetFileInformationByHandle(HANDLE param_0, BY_HANDLE_FILE_INFORMATION* param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetFileInformationByHandle");
  return GetFileInformationByHandle(param_0, param_1);
}

BOOL WINAPI CORKEL32_PeekNamedPipe(HANDLE param_0, PVOID param_1, DWORD param_2, PDWORD param_3, PDWORD param_4, PDWORD param_5)
{
  Trace(TRACE_PASSTHROUGH, "PeekNamedPipe");
  return PeekNamedPipe(param_0, param_1, param_2, param_3, param_4, param_5);
}

BOOL WINAPI CORKEL32_ReadConsoleInputA(HANDLE param_0, PINPUT_RECORD param_1, DWORD param_2, DWORD * param_3)
{
  Trace(TRACE_PASSTHROUGH, "ReadConsoleInputA");
  return ReadConsoleInputA(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_PeekConsoleInputA(HANDLE param_0, PINPUT_RECORD param_1, DWORD param_2, DWORD * param_3)
{
  Trace(TRACE_PASSTHROUGH, "PeekConsoleInputA");
  return PeekConsoleInputA(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_GetNumberOfConsoleInputEvents( HANDLE param_0, DWORD * param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetNumberOfConsoleInputEvents");
  return GetNumberOfConsoleInputEvents(param_0, param_1);
}

BOOL WINAPI CORKEL32_ReadConsoleInputW(HANDLE param_0, PINPUT_RECORD param_1, DWORD param_2, DWORD * param_3)
{
  Trace(TRACE_PASSTHROUGH, "ReadConsoleInputW");
  return ReadConsoleInputW(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_LockFile(HANDLE param_0, DWORD param_1, DWORD param_2, DWORD param_3, DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "LockFile");
  return LockFile(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_UnlockFile(HANDLE param_0, DWORD param_1, DWORD param_2, DWORD param_3, DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "UnlockFile");
  return UnlockFile(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_CreatePipe(PHANDLE param_0, PHANDLE param_1, LPSECURITY_ATTRIBUTES param_2, DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "CreatePipe");
  return CreatePipe(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_SetFileTime(HANDLE param_0, const FILETIME* param_1, const FILETIME* param_2, const FILETIME* param_3)
{
  Trace(TRACE_PASSTHROUGH, "SetFileTime");
  return SetFileTime(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_LocalFileTimeToFileTime(const FILETIME* param_0, LPFILETIME param_1)
{
  Trace(TRACE_PASSTHROUGH, "LocalFileTimeToFileTime");
  return LocalFileTimeToFileTime(param_0, param_1);
}

BOOL WINAPI CORKEL32_SystemTimeToFileTime(const SYSTEMTIME* param_0, LPFILETIME param_1)
{
  Trace(TRACE_PASSTHROUGH, "SystemTimeToFileTime");
  return SystemTimeToFileTime(param_0, param_1);
}

BOOL WINAPI CORKEL32_AllocConsole()
{
  Trace(TRACE_PASSTHROUGH, "AllocConsole");
  return AllocConsole();
}

BOOL WINAPI CORKEL32_SetConsoleTitleW(LPCWSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetConsoleTitleW");
  return SetConsoleTitleW(param_0);
}

BOOL WINAPI CORKEL32_FreeConsole()
{
  Trace(TRACE_PASSTHROUGH, "FreeConsole");
  return FreeConsole();
}

BOOL WINAPI CORKEL32_EnumSystemLocalesW(LOCALE_ENUMPROCW param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "EnumSystemLocalesW");
  return EnumSystemLocalesW(param_0, param_1);
}

BOOL WINAPI CORKEL32_EnumTimeFormatsW(TIMEFMT_ENUMPROCW param_0, LCID param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "EnumTimeFormatsW");
  return EnumTimeFormatsW(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_EnumCalendarInfoW(CALINFO_ENUMPROCW param_0, LCID param_1, CALID param_2, CALTYPE param_3)
{
  Trace(TRACE_PASSTHROUGH, "EnumCalendarInfoW");
  return EnumCalendarInfoW(param_0, param_1, param_2, param_3);
}

DWORD WINAPI CORKEL32_WaitForMultipleObjects(DWORD param_0, const HANDLE* param_1, BOOL param_2, DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "WaitForMultipleObjects");
  return WaitForMultipleObjects(param_0, param_1, param_2, param_3);
}

LANGID WINAPI CORKEL32_GetUserDefaultLangID()
{
  Trace(TRACE_PASSTHROUGH, "GetUserDefaultLangID");
  return GetUserDefaultLangID();
}

BOOL WINAPI CORKEL32_FlushInstructionCache(HANDLE param_0, LPCVOID param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "FlushInstructionCache");
  return FlushInstructionCache(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_OpenProcess(DWORD param_0, BOOL param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenProcess");
  return OpenProcess(param_0, param_1, param_2);
}

LCID WINAPI CORKEL32_GetSystemDefaultLCID()
{
  Trace(TRACE_PASSTHROUGH, "GetSystemDefaultLCID");
  return GetSystemDefaultLCID();
}

BOOL WINAPI CORKEL32_GetStringTypeExW(LCID param_0, DWORD param_1, LPCWSTR param_2, INT param_3, LPWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetStringTypeExW");
  return GetStringTypeExW(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_GetStringTypeExA(LCID param_0, DWORD param_1, LPCSTR param_2, INT param_3, LPWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetStringTypeExA");
  return GetStringTypeExA(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_IsBadReadPtr(LPCVOID param_0, UINT param_1)
{
  Trace(TRACE_PASSTHROUGH, "IsBadReadPtr");
  return IsBadReadPtr(param_0, param_1);
}

BOOL WINAPI CORKEL32_IsBadStringPtrA(LPCSTR param_0, UINT param_1)
{
  Trace(TRACE_PASSTHROUGH, "IsBadStringPtrA");
  return IsBadStringPtrA(param_0, param_1);
}

LCID WINAPI CORKEL32_GetThreadLocale()
{
  Trace(TRACE_PASSTHROUGH, "GetThreadLocale");
  return GetThreadLocale();
}

BOOL WINAPI CORKEL32_QueryPerformanceFrequency(LARGE_INTEGER* param_0)
{
  Trace(TRACE_PASSTHROUGH, "QueryPerformanceFrequency");
  return QueryPerformanceFrequency(param_0);
}

BOOL WINAPI CORKEL32_SetThreadPriority(HANDLE param_0, INT param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetThreadPriority");
  return SetThreadPriority(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetProcessAffinityMask(HANDLE param_0, LPDWORD param_1, LPDWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetProcessAffinityMask");
  return GetProcessAffinityMask(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_SetThreadAffinityMask(HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetThreadAffinityMask");
  return SetThreadAffinityMask(param_0, param_1);
}

BOOL WINAPI CORKEL32_SetThreadLocale(LCID param_0)
{
  Trace(TRACE_PASSTHROUGH, "SetThreadLocale");
  return SetThreadLocale(param_0);
}

LPVOID WINAPI CORKEL32_MapViewOfFileEx(HANDLE param_0, DWORD param_1, DWORD param_2, DWORD param_3, DWORD param_4, LPVOID param_5)
{
  Trace(TRACE_PASSTHROUGH, "MapViewOfFileEx");
  return MapViewOfFileEx(param_0, param_1, param_2, param_3, param_4, param_5);
}

VOID WINAPI CORKEL32_FreeLibraryAndExitThread(HINSTANCE param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "FreeLibraryAndExitThread");
  FreeLibraryAndExitThread(param_0, param_1);
}

BOOL WINAPI CORKEL32_DeviceIoControl(HANDLE hDevice, DWORD dwIoControlCode, LPVOID lpInBuffer, DWORD nInBufferSize, LPVOID lpOutBuffer, DWORD nOutBufferSize, LPDWORD lpBytesReturned, LPOVERLAPPED lpOverlapped)
{
  BOOL e;

  /*char buf[512];
  sprintf(buf, "hDevice: 0x%p, dwIoControlCode: 0x%X, lpInBuffer: %p, nInBufferSize: 0x%X, lpOutBuffer: %p, nOutBufferSize: 0x%X, lpBytesReturned: %p, lpOverlapped: %p", hDevice, dwIoControlCode, lpInBuffer, nInBufferSize, lpOutBuffer, nOutBufferSize, lpBytesReturned, lpOverlapped);
  MessageBoxA(0, buf, 0, 0);*/

  if (hDevice == (HANDLE) 0xCAFEBABE) {
    if (dwIoControlCode == 0x86427531) {
      *(DWORD*)lpOutBuffer = 0x40;
    } else {
      char buf[100];
      sprintf(buf, "Hijack 2: 0x%X", dwIoControlCode);
      MessageBoxA(0,buf,0,0);
    }

    return TRUE;
  }

  e = DeviceIoControl(hDevice, dwIoControlCode, lpInBuffer, nInBufferSize, lpOutBuffer, nOutBufferSize, lpBytesReturned, lpOverlapped);
  Trace(TRACE_PASSTHROUGH, "DeviceIoControl");

  /*if (!e) {
    DWORD le = GetLastError();

    sprintf(buf, "DeviceIoControl Failed: 0x%X", le);
    MessageBoxA(0, buf, 0, 0);

    SetLastError(le);
  }*/

  return e;
}

BOOL WINAPI CORKEL32_GetThreadContext(HANDLE param_0, CONTEXT * param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetThreadContext");
  return GetThreadContext(param_0, param_1);
}

BOOL WINAPI CORKEL32_SetThreadContext(HANDLE param_0, const CONTEXT * param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetThreadContext");
  return SetThreadContext(param_0, param_1);
}

DWORD WINAPI CORKEL32_SuspendThread(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "SuspendThread");
  return SuspendThread(param_0);
}

INT WINAPI CORKEL32_GetThreadPriority(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetThreadPriority");
  return GetThreadPriority(param_0);
}

DWORD WINAPI CORKEL32_QueueUserAPC(PAPCFUNC param_0, HANDLE param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "QueueUserAPC");
  return QueueUserAPC(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_WaitForMultipleObjectsEx(DWORD param_0, const HANDLE* param_1, BOOL param_2, DWORD param_3, BOOL param_4)
{
  Trace(TRACE_PASSTHROUGH, "WaitForMultipleObjectsEx");
  return WaitForMultipleObjectsEx(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_FlushViewOfFile(LPCVOID param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "FlushViewOfFile");
  return FlushViewOfFile(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetQueuedCompletionStatus(HANDLE param_0, LPDWORD param_1, LPDWORD param_2, LPOVERLAPPED* param_3, DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetQueuedCompletionStatus");
  return GetQueuedCompletionStatus(param_0, param_1, param_2, param_3, param_4);
}

INT WINAPI CORKEL32_CompareFileTime(const FILETIME* param_0, const FILETIME* param_1)
{
  Trace(TRACE_PASSTHROUGH, "CompareFileTime");
  return CompareFileTime(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetFileTime(HANDLE param_0, LPFILETIME param_1, LPFILETIME param_2, LPFILETIME param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetFileTime");
  return GetFileTime(param_0, param_1, param_2, param_3);
}

DWORD WINAPI CORKEL32_GetVersion()
{
  Trace(TRACE_PASSTHROUGH, "GetVersion");
  return GetVersion();
}

UINT WINAPI CORKEL32_GetSystemDirectoryA(LPSTR param_0, UINT param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetSystemDirectoryA");
  return GetSystemDirectoryA(param_0, param_1);
}

HRSRC WINAPI CORKEL32_FindResourceA(HMODULE param_0, LPCSTR param_1, LPCSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "FindResourceA");
  return FindResourceA(param_0, param_1, param_2);
}

HRSRC WINAPI CORKEL32_FindResourceW(HMODULE param_0, LPCWSTR param_1, LPCWSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "FindResourceW");
  return FindResourceW(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_GetShortPathNameA(LPCSTR param_0, LPSTR param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetShortPathNameA");
  return GetShortPathNameA(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_GetShortPathNameW(LPCWSTR param_0, LPWSTR param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetShortPathNameW");
  return GetShortPathNameW(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_SearchPathA(LPCSTR param_0, LPCSTR param_1, LPCSTR param_2, DWORD param_3, LPSTR param_4, LPSTR* param_5)
{
  Trace(TRACE_PASSTHROUGH, "SearchPathA");
  return SearchPathA(param_0, param_1, param_2, param_3, param_4, param_5);
}

DWORD WINAPI CORKEL32_SearchPathW(LPCWSTR param_0, LPCWSTR param_1, LPCWSTR param_2, DWORD param_3, LPWSTR param_4, LPWSTR* param_5)
{
  Trace(TRACE_PASSTHROUGH, "SearchPathW");
  return SearchPathW(param_0, param_1, param_2, param_3, param_4, param_5);
}

UINT WINAPI CORKEL32_GetPrivateProfileIntA(LPCSTR param_0, LPCSTR param_1, INT param_2, LPCSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetPrivateProfileIntA");
  return GetPrivateProfileIntA(param_0, param_1, param_2, param_3);
}

UINT WINAPI CORKEL32_GetPrivateProfileIntW(LPCWSTR param_0, LPCWSTR param_1, INT param_2, LPCWSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetPrivateProfileIntW");
  return GetPrivateProfileIntW(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_WritePrivateProfileStringA(LPCSTR param_0, LPCSTR param_1, LPCSTR param_2, LPCSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "WritePrivateProfileStringA");
  return WritePrivateProfileStringA(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_WritePrivateProfileStringW(LPCWSTR param_0, LPCWSTR param_1, LPCWSTR param_2, LPCWSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "WritePrivateProfileStringW");
  return WritePrivateProfileStringW(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_CopyFileA(LPCSTR param_0, LPCSTR param_1, BOOL param_2)
{
  Trace(TRACE_PASSTHROUGH, "CopyFileA");
  return CopyFileA(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_CopyFileW(LPCWSTR param_0, LPCWSTR param_1, BOOL param_2)
{
  Trace(TRACE_PASSTHROUGH, "CopyFileW");
  return CopyFileW(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_MoveFileExW(LPCWSTR param_0, LPCWSTR param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "MoveFileExW");
  return MoveFileExW(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_GetVolumeInformationA(LPCSTR param_0, LPSTR param_1, DWORD param_2, LPDWORD param_3, LPDWORD param_4, LPDWORD param_5, LPSTR param_6, DWORD param_7)
{
  Trace(TRACE_PASSTHROUGH, "GetVolumeInformationA");
  return GetVolumeInformationA(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7);
}

BOOL WINAPI CORKEL32_GetVolumeInformationW(LPCWSTR param_0, LPWSTR param_1, DWORD param_2, LPDWORD param_3, LPDWORD param_4, LPDWORD param_5, LPWSTR param_6, DWORD param_7)
{
  Trace(TRACE_PASSTHROUGH, "GetVolumeInformationW");
  return GetVolumeInformationW(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7);
}

HANDLE WINAPI CORKEL32_OpenEventA(DWORD param_0, BOOL param_1, LPCSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenEventA");
  return OpenEventA(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_OpenEventW(DWORD param_0, BOOL param_1, LPCWSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenEventW");
  return OpenEventW(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_OpenMutexA(DWORD param_0, BOOL param_1, LPCSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenMutexA");
  return OpenMutexA(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_OpenMutexW(DWORD param_0, BOOL param_1, LPCWSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenMutexW");
  return OpenMutexW(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_GetTempPathA(DWORD param_0, LPSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetTempPathA");
  return GetTempPathA(param_0, param_1);
}

DWORD WINAPI CORKEL32_GetTempPathW(DWORD param_0, LPWSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetTempPathW");
  return GetTempPathW(param_0, param_1);
}

UINT WINAPI CORKEL32_GetTempFileNameA(LPCSTR param_0, LPCSTR param_1, UINT param_2, LPSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetTempFileNameA");
  return GetTempFileNameA(param_0, param_1, param_2, param_3);
}

UINT WINAPI CORKEL32_GetTempFileNameW(LPCWSTR param_0, LPCWSTR param_1, UINT param_2, LPWSTR param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetTempFileNameW");
  return GetTempFileNameW(param_0, param_1, param_2, param_3);
}

HANDLE WINAPI CORKEL32_OpenFileMappingA(DWORD param_0, BOOL param_1, LPCSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenFileMappingA");
  return OpenFileMappingA(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_OpenFileMappingW(DWORD param_0, BOOL param_1, LPCWSTR param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenFileMappingW");
  return OpenFileMappingW(param_0, param_1, param_2);
}

DWORD WINAPI CORKEL32_SizeofResource(HMODULE param_0, HRSRC param_1)
{
  Trace(TRACE_PASSTHROUGH, "SizeofResource");
  return SizeofResource(param_0, param_1);
}

LPVOID WINAPI CORKEL32_LockResource(HGLOBAL param_0)
{
  Trace(TRACE_PASSTHROUGH, "LockResource");
  return LockResource(param_0);
}

HGLOBAL WINAPI CORKEL32_LoadResource(HMODULE param_0, HRSRC param_1)
{
  Trace(TRACE_PASSTHROUGH, "LoadResource");
  return LoadResource(param_0, param_1);
}

DWORD WINAPI CORKEL32_VirtualQueryEx(HANDLE param_0, LPCVOID param_1, PMEMORY_BASIC_INFORMATION param_2, DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "VirtualQueryEx");
  return VirtualQueryEx(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_FreeResource(HGLOBAL param_0)
{
  Trace(TRACE_PASSTHROUGH, "FreeResource");
  return FreeResource(param_0);
}

BOOL WINAPI CORKEL32_DosDateTimeToFileTime(WORD param_0, WORD param_1, LPFILETIME param_2)
{
  Trace(TRACE_PASSTHROUGH, "DosDateTimeToFileTime");
  return DosDateTimeToFileTime(param_0, param_1, param_2);
}

INT WINAPI CORKEL32_lstrlenA(LPCSTR param_0)
{
  Trace(TRACE_PASSTHROUGH, "lstrlenA");
  return lstrlenA(param_0);
}

BOOL WINAPI CORKEL32_AreFileApisANSI()
{
  Trace(TRACE_PASSTHROUGH, "AreFileApisANSI");
  return AreFileApisANSI();
}

BOOL WINAPI CORKEL32_GetProcessTimes(HANDLE param_0, LPFILETIME param_1, LPFILETIME param_2, LPFILETIME param_3, LPFILETIME param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetProcessTimes");
  return GetProcessTimes(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_SetPriorityClass(HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetPriorityClass");
  return SetPriorityClass(param_0, param_1);
}

int WINAPI CORKEL32_MulDiv(int nNumber, int nNumerator, int nDenominator)
{
  Trace(TRACE_PASSTHROUGH, "MulDiv");
  return MulDiv(nNumber, nNumerator, nDenominator);
}

HGLOBAL WINAPI CORKEL32_GlobalHandle(LPCVOID pMem)
{
  Trace(TRACE_PASSTHROUGH, "GlobalHandle");
  return GlobalHandle(pMem);
}

BOOL WINAPI CORKEL32_TerminateThread(HANDLE hThread, DWORD dwExitCode)
{
  Trace(TRACE_PASSTHROUGH, "TerminateThread");
  return TerminateThread(hThread, dwExitCode);
}

HGLOBAL WINAPI CORKEL32_GlobalAlloc(UINT param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "GlobalAlloc");
  return GlobalAlloc(param_0, param_1);
}

BOOL WINAPI CORKEL32_GlobalUnlock(HGLOBAL param_0)
{
  Trace(TRACE_PASSTHROUGH, "GlobalUnlock");
  return GlobalUnlock(param_0);
}

LPVOID WINAPI CORKEL32_GlobalLock(HGLOBAL param_0)
{
  Trace(TRACE_PASSTHROUGH, "GlobalLock");
  return GlobalLock(param_0);
}

HGLOBAL WINAPI CORKEL32_GlobalFree(HGLOBAL param_0)
{
  Trace(TRACE_PASSTHROUGH, "GlobalFree");
  return GlobalFree(param_0);
}

HGLOBAL WINAPI CORKEL32_GlobalReAlloc(HGLOBAL param_0, DWORD param_1, UINT param_2)
{
  Trace(TRACE_PASSTHROUGH, "GlobalReAlloc");
  return GlobalReAlloc(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_RegisterEventSourceA(LPCSTR lpUNCServerName, LPCSTR lpSourceName)
{
  Trace(TRACE_PASSTHROUGH, "RegisterEventSourceA");
  return RegisterEventSourceA(lpUNCServerName, lpSourceName);
}

DWORD WINAPI CORKEL32_ExpandEnvironmentStringsA(LPCSTR src, LPSTR dst, DWORD count)
{
  Trace(TRACE_PASSTHROUGH, "ExpandEnvironmentStringsA");
  return ExpandEnvironmentStringsA(src, dst, count);
}

DWORD WINAPI CORKEL32_ExpandEnvironmentStringsW(LPCWSTR src, LPWSTR dst, DWORD len)
{
  Trace(TRACE_PASSTHROUGH, "ExpandEnvironmentStringsW");
  return ExpandEnvironmentStringsW(src, dst, len);
}

INT WINAPI CORKEL32_lstrcmpiA(LPCSTR lpString1, LPCSTR lpString2)
{
  Trace(TRACE_PASSTHROUGH, "lstrcmpiA");
  return lstrcmpiA(lpString1, lpString2);
}

BOOL WINAPI CORKEL32_GetConsoleScreenBufferInfo(HANDLE hConsoleOutput, PCONSOLE_SCREEN_BUFFER_INFO lpConsoleScreenBufferInfo)
{
  Trace(TRACE_PASSTHROUGH, "GetConsoleScreenBufferInfo");
  return GetConsoleScreenBufferInfo(hConsoleOutput, lpConsoleScreenBufferInfo);
}

// Reimplemented
LONG WINAPI CORKEL32_InterlockedCompareExchange(LONG *dest,  LONG xchg,  LONG compare)
{
  LONG temp = *dest;

  Trace(TRACE_FORCE_DONT_PRINT, "InterlockedCompareExchange");

  if (compare == *dest) {
    *dest = xchg;
  }

  return temp;
}

HANDLE WINAPI CORKEL32_CreateToolhelp32Snapshot(DWORD param_0, DWORD param_1)
{
  Trace(TRACE_UNIMPLEMENTED, "CreateToolhelp32Snapshot");
  // TODO: Stub
  return NULL;
}

BOOL WINAPI CORKEL32_IsDebuggerPresent()
{
  Trace(TRACE_IMPLEMENTED, "IsDebuggerPresent");
  return FALSE;
}

BOOL WINAPI CORKEL32_GetFileAttributesExA(LPCSTR name, GET_FILEEX_INFO_LEVELS level, LPVOID ptr)
{
  WIN32_FILE_ATTRIBUTE_DATA *data;
  HANDLE hFile;

  Trace(TRACE_IMPLEMENTED, "GetFileAttributesExA - %s", name);

  data = ptr;
  hFile = CreateFileA(name, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (hFile == INVALID_HANDLE_VALUE) {
    return FALSE;
  }

  data->dwFileAttributes = GetFileAttributesA(name);
  GetFileTime(hFile, &data->ftCreationTime, &data->ftLastAccessTime, &data->ftLastWriteTime);
  data->nFileSizeLow = GetFileSize(hFile, &data->nFileSizeHigh);

  CloseHandle(hFile);

  return TRUE;
}

BOOL WINAPI CORKEL32_GetFileAttributesExW(LPCWSTR name, GET_FILEEX_INFO_LEVELS level, LPVOID ptr)
{
  WIN32_FILE_ATTRIBUTE_DATA *data;
  HANDLE hFile;

  Trace(TRACE_IMPLEMENTED, "GetFileAttributesExW - %ls", name);

  data = ptr;
  hFile = CreateFileW(name, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (hFile == INVALID_HANDLE_VALUE) {
    return FALSE;
  }

  data->dwFileAttributes = GetFileAttributesW(name);
  GetFileTime(hFile, &data->ftCreationTime, &data->ftLastAccessTime, &data->ftLastWriteTime);
  data->nFileSizeLow = GetFileSize(hFile, &data->nFileSizeHigh);

  CloseHandle(hFile);

  return TRUE;
}

DWORD WINAPI CORKEL32_GetLongPathNameA(LPCSTR lpszShortPath, LPSTR lpszLongPath, DWORD cchBuffer)
{
  strncpy(lpszLongPath, lpszShortPath, cchBuffer);
  Trace(TRACE_IMPLEMENTED, "GetLongPathNameA - lpszShortPath: %s, lpszLongPath: %s, cchBuffer: 0x%X", lpszShortPath, lpszLongPath, cchBuffer);
  return 0;
}

DWORD WINAPI CORKEL32_GetLongPathNameW(LPCWSTR lpszShortPath, LPWSTR lpszLongPath, DWORD cchBuffer)
{
  wcsncpy(lpszLongPath, lpszShortPath, cchBuffer);
  Trace(TRACE_IMPLEMENTED, "GetLongPathNameW - lpszShortPath: %ls, lpszLongPath: %ls, cchBuffer: 0x%X", lpszShortPath, lpszLongPath, cchBuffer);
  return 0;
}

BOOL WINAPI CORKEL32_EnumDateFormatsExW(LPVOID param_0, LCID param_1, DWORD param_2)
{
  Trace(TRACE_UNIMPLEMENTED, "EnumDateFormatsExW");
  return FALSE;
}

DWORD WINAPI CORKEL32_SetThreadIdealProcessor(HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_UNIMPLEMENTED, "SetThreadIdealProcessor");
  return 0;
}

INT WINAPI CORKEL32_GetCalendarInfoA(LCID param_0, DWORD param_1, DWORD param_2, LPSTR param_3, INT param_4, LPDWORD param_5)
{
  Trace(TRACE_UNIMPLEMENTED, "GetCalendarInfoA");
  return 0;
}

INT WINAPI CORKEL32_GetCalendarInfoW(LCID param_0, DWORD param_1, DWORD param_2, LPWSTR param_3, INT param_4, LPDWORD param_5)
{
  Trace(TRACE_UNIMPLEMENTED, "GetCalendarInfoW");
  return 0;
}

BOOL WINAPI CORKEL32_SetProcessAffinityMask(HANDLE param_0, DWORD param_1)
{
  Trace(TRACE_UNIMPLEMENTED, "SetProcessAffinityMask");
  return FALSE;
}

DWORD WINAPI CORKEL32_SignalObjectAndWait(HANDLE param_0, HANDLE param_1, DWORD param_2, BOOL param_3)
{
  Trace(TRACE_UNIMPLEMENTED, "SignalObjectAndWait");
  return 0;
}

BOOL WINAPI CORKEL32_SwitchToThread()
{
  Trace(TRACE_UNIMPLEMENTED, "SwitchToThread");
  return FALSE;
}

BOOL WINAPI CORKEL32_IsProcessorFeaturePresent(DWORD ProcessorFeature)
{
  Trace(TRACE_IMPLEMENTED, "IsProcessorFeaturePresent: %X", ProcessorFeature);
  return FALSE;
}

UINT WINAPI CORKEL32_GetSystemWindowsDirectoryW( LPWSTR path, UINT count )
{
  Trace(TRACE_IMPLEMENTED, "GetSystemWindowsDirectoryW");
  return GetWindowsDirectoryW( path, count );
}

BOOL WINAPI CORKEL32_InitializeCriticalSectionAndSpinCount(LPCRITICAL_SECTION crit, DWORD count)
{
  Trace(TRACE_IMPLEMENTED, "InitializeCriticalSectionAndSpinCount: %p, 0x%X", crit, count);

  InitializeCriticalSection(crit);
  crit->Reserved = count & ~0x80000000;
  return TRUE;
}
