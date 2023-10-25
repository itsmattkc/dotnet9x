#define _WIN32_WINNT 0x0400
#include <windows.h>

#include "debug.h"

ULONG WINAPI CORNT_RtlNtStatusToDosError(NTSTATUS)
{
  Trace(TRACE_UNIMPLEMENTED, "RtlNtStatusToDosError");
  // TODO: Stub
  return 0;
}

extern NTAPI RtlUnwind(void* param_0, void* param_1, struct _EXCEPTION_RECORD* param_2, void* param_3);
VOID NTAPI CORNT_RtlUnwind(void *p0,void *p1,struct _EXCEPTION_RECORD *p2, void *p3)
{
  Trace(TRACE_PASSTHROUGH, "RtlUnwind");
  RtlUnwind(p0, p1, p2, p3);
}

VOID NTAPI CORNT_IoUnregisterDeviceInterface()
{
  // NOTE: I can't find this function mentioned anywhere. I have no idea how
  //       it could possibly be a real function.
  Trace(TRACE_UNIMPLEMENTED, "IoUnregisterDeviceInterface");
}
