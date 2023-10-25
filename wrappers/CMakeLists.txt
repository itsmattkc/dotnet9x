cmake_minimum_required(VERSION 3.13)

project(corkel32 C)

add_library(corkdebug OBJECT
  debug.c
)
link_libraries(corkdebug)

# KERNEL32 => CORKEL32
add_library(corkel32 SHARED
  kernel32.c
  advapi32.c
  corkel32.def
)

# NTDLL => CORNT
add_library(cornt SHARED
  ntdll.c
  cornt.def
)

# USER32 => CORUSR
add_library(corusr SHARED
  user32.c
  corusr.def
)
