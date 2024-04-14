#ifndef DETECT_486
#define DETECT_486

#ifndef STDCALL
#define STDCALL __stdcall
#endif

int STDCALL is_cpu_486_or_newer(void);

#endif // DETECT_486
