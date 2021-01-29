@echo off
rem
rem   BUILD_LIB
rem
rem   Build the FLINE library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_char
call src_pas %srcdir% %libname%_coll
call src_pas %srcdir% %libname%_cpos
call src_pas %srcdir% %libname%_file
call src_pas %srcdir% %libname%_hier
call src_pas %srcdir% %libname%_lib
call src_pas %srcdir% %libname%_line

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%
