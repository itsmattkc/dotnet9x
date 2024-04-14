cmake_minimum_required(VERSION 3.13)

project(corkel32 C ASM_MASM)

add_compile_definitions(_WIN32_WINNT=0x0400)

add_library(
  corkdebug OBJECT
  debug.c
)
target_compile_definitions(corkdebug PRIVATE _CRT_SECURE_NO_WARNINGS=1)

add_library(
  detect486 OBJECT
  detect486.asm
)

add_library(
  cas OBJECT
  cas.asm
)

include(CheckSymbolExists)
check_symbol_exists(RtlUnwind Windows.h HAS_RTL_UNWIND)

# KERNEL32 => CORKEL32
add_library(
  corkel32 MODULE
  kernel32.c
  advapi32.c
  comdlg32.c
  corkel32.def
)
target_link_libraries(corkel32 PRIVATE corkdebug detect486 cas)
target_compile_definitions(corkel32 PRIVATE _CRT_SECURE_NO_WARNINGS=1)

# NTDLL => CORNT
add_library(
  cornt MODULE
  ntdll.c
  cornt.def
)
target_link_libraries(cornt PRIVATE corkdebug)
if(HAS_RTL_UNWIND)
  target_compile_definitions(cornt PRIVATE HAS_RTL_UNWIND=1)
endif()

# USER32 => CORUSR
add_library(
  corusr MODULE
  user32.c
  corusr.def
)
target_link_libraries(corusr PRIVATE corkdebug)
