# Sample toolchain file for building for Windows from an Ubuntu Linux system.
#
# Typical usage:
#    *) install cross compiler: `sudo apt-get install mingw-w64`
#    *) cd build
#    *) cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake ..
# This is free and unencumbered software released into the public domain.

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(TOOLCHAIN_PREFIX x86_64-w64-mingw32)

file(
  GLOB _dirs
  LIST_DIRECTORIES true
  RELATIVE /usr/lib/gcc/${TOOLCHAIN_PREFIX}
  /usr/lib/gcc/${TOOLCHAIN_PREFIX}/[1-9][0-9]*)

# cross compilers to use for C, C++ and Fortran
if(_dirs MATCHES "[0-9][0-9]-posix")
  # Debian/Ubuntu has directories named 14-win32 and 14-posix.
  set(TOOLCHAIN_LIBDIR ${CMAKE_MATCH_0})
  set(CMAKE_AR ${TOOLCHAIN_PREFIX}-gcc-ar-posix)
  set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc-${CMAKE_MATCH_0})
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++-posix)
  set(CMAKE_NM ${TOOLCHAIN_PREFIX}-gcc-nm-posix)
  set(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}-gcc-ranlib-posix)
elseif(_dirs MATCHES "[0-9][0-9]-win32")
  message(
    FATAL_ERROR "You need the install the posix version of the mingw compiler.")
else()
  # Fedora has directories named 14.x.x
  set(CMAKE_AR ${TOOLCHAIN_PREFIX}-ar)
  set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
  set(CMAKE_NM ${TOOLCHAIN_PREFIX}-nm)
  set(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}-ranlib)
endif()
set(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}-windres)

# target environment on the build host system
if(NOT CMAKE_FIND_ROOT_PATH MATCHES /usr/${TOOLCHAIN_PREFIX}/sys-root/mingw)
  list(PREPEND CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX}/sys-root/mingw)
endif()

# modify default behavior of FIND_XXX() commands
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
