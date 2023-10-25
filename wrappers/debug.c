#include "debug.h"

#include <stdarg.h>
#include <stdio.h>
#include <windows.h>

#define DEBUG_MINIMUM_LEVEL TRACE_IMPLEMENTED

#undef Trace
void Trace(int level, const char *s, ...)
{
  va_list args;
  FILE *fptr;
  char buf[1024];
  DWORD le = GetLastError();

  if (level < DEBUG_MINIMUM_LEVEL) {
    return;
  }

  va_start(args, s);

  _vsnprintf(buf, 1024, s, args);

  fptr = fopen("log.txt", "a");
  fprintf(fptr, "%s\n", buf);
  fclose(fptr);

  va_end(args);

  SetLastError(le);
}
