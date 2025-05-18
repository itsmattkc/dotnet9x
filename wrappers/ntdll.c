#include <windows.h>
#include <lm.h> // for NTSTATUS

#include "debug.h"

ULONG WINAPI CORNT_RtlNtStatusToDosError(NTSTATUS param_0)
{
  Trace(TRACE_UNIMPLEMENTED, "RtlNtStatusToDosError");
  // TODO: Stub
  return 0;
}

#ifndef HAS_RTL_UNWIND
extern NTAPI RtlUnwind(void* param_0, void* param_1, struct _EXCEPTION_RECORD* param_2, void* param_3);
#endif

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
