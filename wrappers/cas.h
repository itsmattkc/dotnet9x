#ifndef CAS
#define CAS

#ifndef STDCALL
#define STDCALL __stdcall
#endif

long STDCALL InterlockedCompareExchange_486(long* dest, long exchange, long compare);

#endif // CAS
