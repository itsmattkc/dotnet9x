#define _WIN32_WINNT 0x0400
#include <windows.h>

#include "debug.h"

// Passthroughs
BOOL WINAPI CORKEL32_GetKernelObjectSecurity(HANDLE param_0, SECURITY_INFORMATION param_1, PSECURITY_DESCRIPTOR param_2, DWORD param_3, LPDWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetKernelObjectSecurity");
  return GetKernelObjectSecurity(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_GetSecurityDescriptorOwner(PSECURITY_DESCRIPTOR param_0, PSID * param_1, LPBOOL param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetSecurityDescriptorOwner");
  return GetSecurityDescriptorOwner(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_CryptEncrypt(HCRYPTKEY param_0, HCRYPTHASH param_1, BOOL param_2, DWORD param_3, LPBYTE param_4, LPDWORD param_5, DWORD param_6)
{
  Trace(TRACE_PASSTHROUGH, "CryptEncrypt");
  return CryptEncrypt(param_0, param_1, param_2, param_3, param_4, param_5, param_6);
}

BOOL WINAPI CORKEL32_CryptDecrypt (HCRYPTKEY param_0,  HCRYPTHASH param_1,  BOOL param_2,  DWORD param_3,  BYTE * param_4,  DWORD * param_5)
{
  Trace(TRACE_PASSTHROUGH, "CryptDecrypt");
  return CryptDecrypt(param_0, param_1, param_2, param_3, param_4, param_5);
}

BOOL WINAPI CORKEL32_CryptDeriveKey (HCRYPTPROV param_0,  ALG_ID param_1,  HCRYPTHASH param_2,  DWORD param_3,  HCRYPTKEY * param_4)
{
  Trace(TRACE_PASSTHROUGH, "CryptDeriveKey");
  return CryptDeriveKey(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_CryptSetProvParam(HCRYPTPROV hProv, DWORD dwParam, BYTE *pbData, DWORD dwFlags)
{
  Trace(TRACE_PASSTHROUGH, "CryptSetProvParam");
  return CryptSetProvParam(hProv, dwParam, pbData, dwFlags);
}

BOOL WINAPI CORKEL32_CryptSetKeyParam(HCRYPTKEY hKey, DWORD dwParam, BYTE *pbData, DWORD dwFlags)
{
  Trace(TRACE_PASSTHROUGH, "CryptSetKeyParam");
  return CryptSetKeyParam(hKey, dwParam, pbData, dwFlags);
}

BOOL WINAPI CORKEL32_CryptGenKey (HCRYPTPROV param_0,  ALG_ID param_1,  DWORD param_2,  HCRYPTKEY * param_3)
{
  Trace(TRACE_PASSTHROUGH, "CryptGenKey");
  return CryptGenKey(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_SetSecurityDescriptorDacl(PSECURITY_DESCRIPTOR param_0, BOOL param_1, PACL param_2, BOOL param_3)
{
  Trace(TRACE_PASSTHROUGH, "SetSecurityDescriptorDacl");
  return SetSecurityDescriptorDacl(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_InitializeSecurityDescriptor(PSECURITY_DESCRIPTOR param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "InitializeSecurityDescriptor");
  return InitializeSecurityDescriptor(param_0, param_1);
}

BOOL WINAPI CORKEL32_AllocateAndInitializeSid(PSID_IDENTIFIER_AUTHORITY param_0, BYTE param_1, DWORD param_2, DWORD param_3, DWORD param_4, DWORD param_5, DWORD param_6, DWORD param_7, DWORD param_8, DWORD param_9, PSID * param_10)
{
  Trace(TRACE_PASSTHROUGH, "AllocateAndInitializeSid");
  return AllocateAndInitializeSid(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9, param_10);
}

BOOL WINAPI CORKEL32_AddAccessAllowedAce(PACL param_0, DWORD param_1, DWORD param_2, PSID param_3)
{
  Trace(TRACE_PASSTHROUGH, "AddAccessAllowedAce");
  return AddAccessAllowedAce(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_DeleteAce(PACL param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "DeleteAce");
  return DeleteAce(param_0, param_1);
}

BOOL WINAPI CORKEL32_CryptVerifySignatureA (HCRYPTHASH param_0,  const LPBYTE param_1,  DWORD param_2,  HCRYPTKEY param_3,  LPCSTR param_4,  DWORD param_5)
{
  Trace(TRACE_PASSTHROUGH, "CryptVerifySignatureA");
  return CryptVerifySignatureA(param_0, param_1, param_2, param_3, param_4, param_5);
}

BOOL WINAPI CORKEL32_CryptSetHashParam (HCRYPTHASH param_0,  DWORD param_1,  const LPBYTE param_2,  DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "CryptSetHashParam");
  return CryptSetHashParam(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_CryptSignHashA (HCRYPTHASH param_0,  DWORD param_1,  LPCSTR param_2,  DWORD param_3,  BYTE * param_4,  DWORD * param_5)
{
  Trace(TRACE_PASSTHROUGH, "CryptSignHashA");
  return CryptSignHashA(param_0, param_1, param_2, param_3, param_4, param_5);
}

DWORD WINAPI CORKEL32_GetLengthSid(PSID param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetLengthSid");
  return GetLengthSid(param_0);
}

BOOL WINAPI CORKEL32_CopySid(DWORD param_0, PSID param_1, PSID param_2)
{
  Trace(TRACE_PASSTHROUGH, "CopySid");
  return CopySid(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_IsValidSid(PSID param_0)
{
  Trace(TRACE_PASSTHROUGH, "IsValidSid");
  return IsValidSid(param_0);
}

PSID_IDENTIFIER_AUTHORITY WINAPI CORKEL32_GetSidIdentifierAuthority(PSID param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetSidIdentifierAuthority");
  return GetSidIdentifierAuthority(param_0);
}

PUCHAR WINAPI CORKEL32_GetSidSubAuthorityCount(PSID param_0)
{
  Trace(TRACE_PASSTHROUGH, "GetSidSubAuthorityCount");
  return GetSidSubAuthorityCount(param_0);
}

PDWORD WINAPI CORKEL32_GetSidSubAuthority(PSID param_0, DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetSidSubAuthority");
  return GetSidSubAuthority(param_0, param_1);
}

BOOL WINAPI CORKEL32_CryptGetKeyParam (HCRYPTKEY param_0,  DWORD param_1,  BYTE * param_2,  DWORD * param_3,  DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "CryptGetKeyParam");
  return CryptGetKeyParam(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_CryptImportKey (HCRYPTPROV param_0,  const BYTE * param_1,  DWORD param_2,  HCRYPTKEY param_3,  DWORD param_4,  HCRYPTKEY * param_5)
{
  Trace(TRACE_PASSTHROUGH, "CryptImportKey");
  return CryptImportKey(param_0, param_1, param_2, param_3, param_4, param_5);
}

BOOL WINAPI CORKEL32_CryptGetProvParam (HCRYPTPROV param_0,  DWORD param_1,  BYTE * param_2,  DWORD * param_3,  DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "CryptGetProvParam");
  return CryptGetProvParam(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_CryptGetUserKey (HCRYPTPROV param_0,  DWORD param_1,  HCRYPTKEY * param_2)
{
  Trace(TRACE_PASSTHROUGH, "CryptGetUserKey");
  return CryptGetUserKey(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_CryptDestroyKey (HCRYPTKEY param_0)
{
  Trace(TRACE_PASSTHROUGH, "CryptDestroyKey");
  return CryptDestroyKey(param_0);
}

BOOL WINAPI CORKEL32_CryptExportKey (HCRYPTKEY param_0,  HCRYPTKEY param_1,  DWORD param_2,  DWORD param_3,  BYTE * param_4,  DWORD * param_5)
{
  Trace(TRACE_PASSTHROUGH, "CryptExportKey");
  return CryptExportKey(param_0, param_1, param_2, param_3, param_4, param_5);
}

BOOL WINAPI CORKEL32_CryptGenRandom (HCRYPTPROV param_0,  DWORD param_1,  BYTE * param_2)
{
  Trace(TRACE_PASSTHROUGH, "CryptGenRandom");
  return CryptGenRandom(param_0, param_1, param_2);
}

HANDLE WINAPI CORKEL32_RegisterEventSourceW(LPCWSTR param_0, LPCWSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "RegisterEventSourceW");
  return RegisterEventSourceW(param_0, param_1);
}

BOOL WINAPI CORKEL32_ReportEventW(HANDLE param_0, WORD param_1, WORD param_2, DWORD param_3, PSID param_4, WORD param_5, DWORD param_6, LPCWSTR * param_7, LPVOID param_8)
{
  Trace(TRACE_PASSTHROUGH, "ReportEventW");
  return ReportEventW(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8);
}

BOOL WINAPI CORKEL32_DeregisterEventSource(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "DeregisterEventSource");
  return DeregisterEventSource(param_0);
}

BOOL WINAPI CORKEL32_LookupAccountSidW(LPCWSTR param_0, PSID param_1, LPWSTR param_2, LPDWORD param_3, LPWSTR param_4, LPDWORD param_5, PSID_NAME_USE param_6)
{
  Trace(TRACE_PASSTHROUGH, "LookupAccountSidW");
  return LookupAccountSidW(param_0, param_1, param_2, param_3, param_4, param_5, param_6);
}

BOOL WINAPI CORKEL32_LookupAccountSidA(LPCSTR param_0, PSID param_1, LPSTR param_2, LPDWORD param_3, LPSTR param_4, LPDWORD param_5, PSID_NAME_USE param_6)
{
  Trace(TRACE_PASSTHROUGH, "LookupAccountSidA");
  return LookupAccountSidA(param_0, param_1, param_2, param_3, param_4, param_5, param_6);
}

LONG WINAPI CORKEL32_RegQueryValueExW(HKEY param_0, LPCWSTR param_1, LPDWORD param_2, LPDWORD param_3, LPBYTE param_4, LPDWORD param_5)
{
  LONG l = RegQueryValueExW(param_0, param_1, param_2, param_3, param_4, param_5);;
  Trace(TRACE_PASSTHROUGH, "RegQueryValueExW");
  return l;
}

LONG WINAPI CORKEL32_RegEnumValueW(HKEY param_0, DWORD param_1, LPWSTR param_2, LPDWORD param_3, LPDWORD param_4, LPDWORD param_5, LPBYTE param_6, LPDWORD param_7)
{
  Trace(TRACE_PASSTHROUGH, "RegEnumValueW");
  return RegEnumValueW(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7);
}

LONG WINAPI CORKEL32_RegEnumValueA(HKEY param_0, DWORD param_1, LPSTR param_2, LPDWORD param_3, LPDWORD param_4, LPDWORD param_5, LPBYTE param_6, LPDWORD param_7)
{
  Trace(TRACE_PASSTHROUGH, "RegEnumValueA");
  return RegEnumValueA(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7);
}

LONG WINAPI CORKEL32_RegDeleteValueW(HKEY param_0, LPCWSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "RegDeleteValueW");
  return RegDeleteValueW(param_0, param_1);
}

LONG WINAPI CORKEL32_RegDeleteValueA(HKEY param_0, LPCSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "RegDeleteValueA");
  return RegDeleteValueA(param_0, param_1);
}

LONG WINAPI CORKEL32_RegQueryValueW(HKEY param_0, LPCWSTR param_1, LPWSTR param_2, LPLONG param_3)
{
  LONG l = RegQueryValueW(param_0, param_1, param_2, param_3);
  Trace(TRACE_PASSTHROUGH, "RegQueryValueW");
  return l;
}

LONG WINAPI CORKEL32_RegQueryValueA(HKEY param_0, LPCSTR param_1, LPSTR param_2, LPLONG param_3)
{
  LONG l = RegQueryValueA(param_0, param_1, param_2, param_3);
  Trace(TRACE_PASSTHROUGH, "RegQueryValueA");
  return l;
}

LONG WINAPI CORKEL32_RegCreateKeyExW(HKEY param_0, LPCWSTR param_1, DWORD param_2, LPWSTR param_3, DWORD param_4, REGSAM param_5, LPSECURITY_ATTRIBUTES param_6, PHKEY param_7, LPDWORD param_8)
{
  Trace(TRACE_PASSTHROUGH, "RegCreateKeyExW");
  return RegCreateKeyExW(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8);
}

LONG WINAPI CORKEL32_RegCreateKeyExA(HKEY param_0, LPCSTR param_1, DWORD param_2, LPSTR param_3, DWORD param_4, REGSAM param_5, LPSECURITY_ATTRIBUTES param_6, PHKEY param_7, LPDWORD param_8)
{
  Trace(TRACE_PASSTHROUGH, "RegCreateKeyExA");
  return RegCreateKeyExA(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8);
}

LONG WINAPI CORKEL32_RegSetValueExW(HKEY param_0, LPCWSTR param_1, DWORD param_2, DWORD param_3, const BYTE* param_4, DWORD param_5)
{
  Trace(TRACE_PASSTHROUGH, "RegSetValueExW");
  return RegSetValueExW(param_0, param_1, param_2, param_3, param_4, param_5);
}

LONG WINAPI CORKEL32_RegSetValueExA(HKEY param_0, LPCSTR param_1, DWORD param_2, DWORD param_3, const BYTE* param_4, DWORD param_5)
{
  Trace(TRACE_PASSTHROUGH, "RegSetValueExA");
  return RegSetValueExA(param_0, param_1, param_2, param_3, param_4, param_5);
}

LONG WINAPI CORKEL32_RegDeleteKeyW(HKEY param_0, LPCWSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "RegDeleteKeyW");
  return RegDeleteKeyW(param_0, param_1);
}

LONG WINAPI CORKEL32_RegDeleteKeyA(HKEY param_0, LPCSTR param_1)
{
  Trace(TRACE_PASSTHROUGH, "RegDeleteKeyA");
  return RegDeleteKeyA(param_0, param_1);
}

BOOL WINAPI CORKEL32_DuplicateToken(HANDLE param_0, SECURITY_IMPERSONATION_LEVEL param_1, PHANDLE param_2)
{
  Trace(TRACE_PASSTHROUGH, "DuplicateToken");
  return DuplicateToken(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_GetUserNameW(LPWSTR param_0, LPDWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetUserNameW");
  return GetUserNameW(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetUserNameA(LPSTR param_0, LPDWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "GetUserNameA");
  return GetUserNameA(param_0, param_1);
}

LONG WINAPI CORKEL32_RegQueryInfoKeyW(HKEY param_0, LPWSTR param_1, LPDWORD param_2, LPDWORD param_3, LPDWORD param_4, LPDWORD param_5, LPDWORD param_6, LPDWORD param_7, LPDWORD param_8, LPDWORD param_9, LPDWORD param_10, LPFILETIME param_11)
{
  LONG l = RegQueryInfoKeyW(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9, param_10, param_11);
  Trace(TRACE_PASSTHROUGH, "RegQueryInfoKeyW");
  return l;
}

LONG WINAPI CORKEL32_RegQueryInfoKeyA(HKEY param_0, LPSTR param_1, LPDWORD param_2, LPDWORD param_3, LPDWORD param_4, LPDWORD param_5, LPDWORD param_6, LPDWORD param_7, LPDWORD param_8, LPDWORD param_9, LPDWORD param_10, LPFILETIME param_11)
{
  LONG l = RegQueryInfoKeyA(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9, param_10, param_11);;
  Trace(TRACE_PASSTHROUGH, "RegQueryInfoKeyA");
  return l;
}

LONG WINAPI CORKEL32_RegEnumKeyExW(HKEY param_0, DWORD param_1, LPWSTR param_2, LPDWORD param_3, LPDWORD param_4, LPWSTR param_5, LPDWORD param_6, LPFILETIME param_7)
{
  LONG l = RegEnumKeyExW(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7);
  Trace(TRACE_PASSTHROUGH, "RegEnumKeyExW");
  return l;
}

LONG WINAPI CORKEL32_RegEnumKeyExA(HKEY param_0, DWORD param_1, LPSTR param_2, LPDWORD param_3, LPDWORD param_4, LPSTR param_5, LPDWORD param_6, LPFILETIME param_7)
{
  LONG l = RegEnumKeyExA(param_0, param_1, param_2, param_3, param_4, param_5, param_6, param_7);
  Trace(TRACE_PASSTHROUGH, "RegEnumKeyExA");
  return l;
}

LONG WINAPI CORKEL32_RegOpenKeyExW(HKEY param_0, LPCWSTR param_1, DWORD param_2, REGSAM param_3, PHKEY param_4)
{
  LONG l = RegOpenKeyExW(param_0, param_1, param_2, param_3, param_4);
  Trace(TRACE_PASSTHROUGH, "RegOpenKeyExW");
  return l;
}

BOOL WINAPI CORKEL32_EqualSid(PSID param_0,  PSID param_1)
{
  Trace(TRACE_PASSTHROUGH, "EqualSid");
  return EqualSid(param_0, param_1);
}

LONG WINAPI CORKEL32_RegOpenKeyExA(HKEY hKey, LPCSTR lpSubKey, DWORD ulOptions, REGSAM samDesired, PHKEY phkResult)
{
  LONG l = RegOpenKeyExA(hKey, lpSubKey, ulOptions, samDesired, phkResult);
  Trace(TRACE_PASSTHROUGH, "RegOpenKeyExA - hKey = %p, lpSubKey = %s", hKey, lpSubKey);
  return l;
}

LONG WINAPI CORKEL32_RegQueryValueExA(HKEY hKey, LPCSTR lpValueName, LPDWORD lpReserved, LPDWORD lpType, LPBYTE lpData, LPDWORD lpcbData)
{
  LONG l = RegQueryValueExA(hKey, lpValueName, lpReserved, lpType, lpData, lpcbData);
  Trace(TRACE_PASSTHROUGH, "RegQueryValueExA - hKey = %p, lpValueName = %s, result = %d, data = %s", hKey, lpValueName, l, lpData);
  return l;
}

BOOL WINAPI CORKEL32_CryptAcquireContextA(HCRYPTPROV * param_0,  LPCSTR param_1,  LPCSTR param_2,  DWORD param_3,  DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "CryptAcquireContextA");
  return CryptAcquireContextA(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_CryptCreateHash (HCRYPTPROV param_0,  ALG_ID param_1,  HCRYPTKEY param_2,  DWORD param_3,  HCRYPTHASH * param_4)
{
  Trace(TRACE_PASSTHROUGH, "CryptCreateHash");
  return CryptCreateHash(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_CryptHashData (HCRYPTHASH param_0,  const BYTE * param_1,  DWORD param_2,  DWORD param_3)
{
  Trace(TRACE_PASSTHROUGH, "CryptHashData");
  return CryptHashData(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_CryptGetHashParam (HCRYPTHASH param_0,  DWORD param_1,  BYTE * param_2,  DWORD * param_3,  DWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "CryptGetHashParam");
  return CryptGetHashParam(param_0, param_1, param_2, param_3, param_4);
}

BOOL WINAPI CORKEL32_CryptDestroyHash (HCRYPTHASH param_0)
{
  Trace(TRACE_PASSTHROUGH, "CryptDestroyHash");
  return CryptDestroyHash(param_0);
}

BOOL WINAPI CORKEL32_CryptReleaseContext (HCRYPTPROV param_0,  DWORD param_1)
{
  Trace(TRACE_PASSTHROUGH, "CryptReleaseContext");
  return CryptReleaseContext(param_0, param_1);
}

BOOL WINAPI CORKEL32_GetSecurityDescriptorDacl(PSECURITY_DESCRIPTOR param_0, LPBOOL param_1, PACL * param_2, LPBOOL param_3)
{
  Trace(TRACE_PASSTHROUGH, "GetSecurityDescriptorDacl");
  return GetSecurityDescriptorDacl(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_SetKernelObjectSecurity(HANDLE param_0, SECURITY_INFORMATION param_1, PSECURITY_DESCRIPTOR param_2)
{
  Trace(TRACE_PASSTHROUGH, "SetKernelObjectSecurity");
  return SetKernelObjectSecurity(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_InitializeAcl(PACL param_0, DWORD param_1, DWORD param_2)
{
  Trace(TRACE_PASSTHROUGH, "InitializeAcl");
  return InitializeAcl(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_GetAce(PACL param_0, DWORD param_1, LPVOID* param_2)
{
  Trace(TRACE_PASSTHROUGH, "GetAce");
  return GetAce(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_OpenThreadToken(HANDLE param_0, DWORD param_1, BOOL param_2, PHANDLE param_3)
{
  Trace(TRACE_PASSTHROUGH, "OpenThreadToken");
  return OpenThreadToken(param_0, param_1, param_2, param_3);
}

BOOL WINAPI CORKEL32_SetThreadToken(PHANDLE param_0, HANDLE param_1)
{
  Trace(TRACE_PASSTHROUGH, "SetThreadToken");
  return SetThreadToken(param_0, param_1);
}

BOOL WINAPI CORKEL32_ImpersonateLoggedOnUser(HANDLE param_0)
{
  Trace(TRACE_PASSTHROUGH, "ImpersonateLoggedOnUser");
  return ImpersonateLoggedOnUser(param_0);
}

BOOL WINAPI CORKEL32_RevertToSelf()
{
  Trace(TRACE_PASSTHROUGH, "RevertToSelf");
  return RevertToSelf();
}

LONG WINAPI CORKEL32_RegCloseKey(HKEY param_0)
{
  Trace(TRACE_PASSTHROUGH, "RegCloseKey");
  return RegCloseKey(param_0);
}

BOOL WINAPI CORKEL32_OpenProcessToken(HANDLE param_0, DWORD param_1, PHANDLE param_2)
{
  Trace(TRACE_PASSTHROUGH, "OpenProcessToken");
  return OpenProcessToken(param_0, param_1, param_2);
}

BOOL WINAPI CORKEL32_GetTokenInformation(HANDLE param_0, TOKEN_INFORMATION_CLASS param_1, LPVOID param_2, DWORD param_3, LPDWORD param_4)
{
  Trace(TRACE_PASSTHROUGH, "GetTokenInformation");
  return GetTokenInformation(param_0, param_1, param_2, param_3, param_4);
}

PVOID WINAPI CORKEL32_FreeSid(PSID param_0)
{
  Trace(TRACE_PASSTHROUGH, "FreeSid");
  return FreeSid(param_0);
}

// Reimplementations
typedef enum _SE_OBJECT_TYPE {
  SE_UNKNOWN_OBJECT_TYPE,
  SE_FILE_OBJECT,
  SE_SERVICE,
  SE_PRINTER,
  SE_REGISTRY_KEY,
  SE_LMSHARE,
  SE_KERNEL_OBJECT,
  SE_WINDOW_OBJECT,
  SE_DS_OBJECT,
  SE_DS_OBJECT_ALL,
  SE_PROVIDER_DEFINED_OBJECT,
  SE_WMIGUID_OBJECT,
  SE_REGISTRY_WOW64_32KEY,
  SE_REGISTRY_WOW64_64KEY
} SE_OBJECT_TYPE;

typedef struct _OBJECTS_AND_NAME_W {
  DWORD          ObjectsPresent;
  SE_OBJECT_TYPE ObjectType;
  LPWSTR         ObjectTypeName;
  LPWSTR         InheritedObjectTypeName;
  LPWSTR         ptstrName;
} OBJECTS_AND_NAME_W, *POBJECTS_AND_NAME_W;

typedef struct _OBJECTS_AND_SID {
  DWORD ObjectsPresent;
  GUID  ObjectTypeGuid;
  GUID  InheritedObjectTypeGuid;
  SID   *pSid;
} OBJECTS_AND_SID, *POBJECTS_AND_SID;

typedef enum _TRUSTEE_TYPE {
  TRUSTEE_IS_UNKNOWN,
  TRUSTEE_IS_USER,
  TRUSTEE_IS_GROUP,
  TRUSTEE_IS_DOMAIN,
  TRUSTEE_IS_ALIAS,
  TRUSTEE_IS_WELL_KNOWN_GROUP,
  TRUSTEE_IS_DELETED,
  TRUSTEE_IS_INVALID,
  TRUSTEE_IS_COMPUTER
} TRUSTEE_TYPE;

typedef enum _TRUSTEE_FORM {
  TRUSTEE_IS_SID,
  TRUSTEE_IS_NAME,
  TRUSTEE_BAD_FORM,
  TRUSTEE_IS_OBJECTS_AND_SID,
  TRUSTEE_IS_OBJECTS_AND_NAME
} TRUSTEE_FORM;

typedef enum _MULTIPLE_TRUSTEE_OPERATION {
  NO_MULTIPLE_TRUSTEE,
  TRUSTEE_IS_IMPERSONATE
} MULTIPLE_TRUSTEE_OPERATION;

typedef struct _TRUSTEE_W
{
    struct _TRUSTEE_W          *pMultipleTrustee;
    MULTIPLE_TRUSTEE_OPERATION  MultipleTrusteeOperation;
    TRUSTEE_FORM                TrusteeForm;
    TRUSTEE_TYPE                TrusteeType;
    LPWSTR                      ptstrName;
} TRUSTEE_W, *PTRUSTEE_W, TRUSTEEW, *PTRUSTEEW;

typedef enum _ACCESS_MODE {
  NOT_USED_ACCESS,
  GRANT_ACCESS,
  SET_ACCESS,
  DENY_ACCESS,
  REVOKE_ACCESS,
  SET_AUDIT_SUCCESS,
  SET_AUDIT_FAILURE
} ACCESS_MODE;

typedef struct _EXPLICIT_ACCESS_W {
  DWORD       grfAccessPermissions;
  ACCESS_MODE grfAccessMode;
  DWORD       grfInheritance;
  TRUSTEE_W   Trustee;
} EXPLICIT_ACCESS_W, *PEXPLICIT_ACCESS_W, EXPLICIT_ACCESSW, *PEXPLICIT_ACCESSW;

DWORD WINAPI CORKEL32_SetEntriesInAclW( ULONG param_0,  PEXPLICIT_ACCESSW param_1,  PACL param_2,  PACL* param_3)
{
  Trace(TRACE_UNIMPLEMENTED, "SetEntriesInAclW");
  // TODO: Stub
  return 0;
}

BOOL WINAPI CORKEL32_CryptEnumProvidersA (DWORD param_0,  LPDWORD param_1,  DWORD param_2,  LPDWORD param_3,  LPSTR param_4,  LPDWORD param_5)
{
  Trace(TRACE_UNIMPLEMENTED, "CryptEnumProvidersA");
  // TODO: Stub
  return FALSE;
}

DWORD WINAPI CORKEL32_GetSecurityInfo( HANDLE param_0,  SE_OBJECT_TYPE param_1,  SECURITY_INFORMATION param_2,  PSID* param_3,  PSID* param_4,  PACL* param_5,  PACL* param_6,  PSECURITY_DESCRIPTOR* param_7)
{
  Trace(TRACE_UNIMPLEMENTED, "GetSecurityInfo");
  // TODO: Stub
  return 0;
}

BOOL WINAPI CORKEL32_CryptAcquireContextW (HCRYPTPROV * param_0,  LPCWSTR param_1,  LPCWSTR param_2,  DWORD param_3,  DWORD param_4)
{
  Trace(TRACE_UNIMPLEMENTED, "CryptAcquireContextW");
  // TODO: Stub
  return FALSE;
}
