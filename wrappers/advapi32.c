#define _WIN32_WINNT 0x0400
#include <windows.h>

#include "debug.h"

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

DWORD WINAPI CORADV32_SetEntriesInAclW( ULONG param_0,  PEXPLICIT_ACCESSW param_1,  PACL param_2,  PACL* param_3)
{
  Trace(TRACE_UNIMPLEMENTED, "SetEntriesInAclW");
  // TODO: Stub
  return 0;
}

BOOL WINAPI CORADV32_CryptEnumProvidersA (DWORD param_0,  LPDWORD param_1,  DWORD param_2,  LPDWORD param_3,  LPSTR param_4,  LPDWORD param_5)
{
  Trace(TRACE_UNIMPLEMENTED, "CryptEnumProvidersA");
  // TODO: Stub
  return FALSE;
}

DWORD WINAPI CORADV32_GetSecurityInfo( HANDLE param_0,  SE_OBJECT_TYPE param_1,  SECURITY_INFORMATION param_2,  PSID* param_3,  PSID* param_4,  PACL* param_5,  PACL* param_6,  PSECURITY_DESCRIPTOR* param_7)
{
  Trace(TRACE_UNIMPLEMENTED, "GetSecurityInfo");
  // TODO: Stub
  return 0;
}

BOOL WINAPI CORADV32_CryptAcquireContextW (HCRYPTPROV * param_0,  LPCWSTR param_1,  LPCWSTR param_2,  DWORD param_3,  DWORD param_4)
{
  Trace(TRACE_UNIMPLEMENTED, "CryptAcquireContextW");
  // TODO: Stub
  return FALSE;
}
