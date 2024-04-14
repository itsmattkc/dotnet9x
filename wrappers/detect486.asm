.386
.MODEL FLAT, STDCALL

.CODE

is_cpu_486_or_newer PROC
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
is_cpu_486_or_newer ENDP

END
