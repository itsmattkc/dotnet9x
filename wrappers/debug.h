#ifndef DEBUG_H
#define DEBUG_H

#define TRACE_FORCE_DONT_PRINT -1
#define TRACE_PASSTHROUGH 0
#define TRACE_IMPLEMENTED 1
#define TRACE_UNIMPLEMENTED 2
#define TRACE_UNEXPECTED_ERROR 3
#define TRACE_FORCE_PRINT 99
#define TRACE_DISABLE 100

//#define Trace //
void Trace(int level, const char *s, ...);

#endif // DEBUG_H
