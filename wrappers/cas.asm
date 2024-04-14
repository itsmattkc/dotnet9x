.486
.MODEL FLAT

.CODE

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

_InterlockedCompareExchange_486@12 PROC
  mov ecx, DWORD PTR [esp + 4] ; dest
  mov edx, DWORD PTR [esp + 8] ; exchange
  mov eax, DWORD PTR [esp + 12] ; compare
  lock cmpxchg DWORD PTR [ecx], edx
  ret 12
_InterlockedCompareExchange_486@12 ENDP

END
