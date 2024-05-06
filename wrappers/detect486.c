#include "detect486.h"

__declspec(naked) int is_cpu_486_or_newer(void)
{
  __asm {
    pushfd
    pop eax
    mov ebx, eax
    xor eax, 40000h ; toggle the AC bit in EFLAGS (only available in 486 or newer)
    push eax
    popfd
    pushfd
    pop eax
    cmp eax, ebx
    jz is_386
    push ebx
    popfd
    xor eax, eax
    inc eax
    ret

  is_386:
    xor eax, eax
    ret
  }
}
