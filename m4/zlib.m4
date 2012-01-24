dnl Copyright (c) Istituto Nazionale di Fisica Nucleare (INFN). 2006-2010.
dnl
dnl Licensed under the Apache License, Version 2.0 (the "License");
dnl you may not use this file except in compliance with the License.
dnl You may obtain a copy of the License at
dnl
dnl     http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS,
dnl WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl See the License for the specific language governing permissions and
dnl limitations under the License.

dnl Usage:
dnl AC_ZLIB(MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for libattr, and defines
dnl - ZLIB_LIBS (linker flags, stripping and path)
dnl - ZLIB_LOCATION

dnl AC_ZLIB_DEVEL(MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for libattr-devel, and defines
dnl - ZLIB_DEVEL_CFLAGS (compiler flags)
dnl - ZLIB_DEVEL_LIBS (linker flags, stripping and path)
dnl - ZLIB_DEVEL_LOCATION

AC_DEFUN([AC_ZLIB],
[
    AC_ARG_WITH(zlib_prefix,
    [  --with-zlib-prefix=PFX     prefix where zlib is installed.],
    [],
        with_zlib_prefix=${ZLIB_LOCATION:-/usr})

    AC_MSG_CHECKING([for ZLIB installation at ])

    if test -n "$with_zlib_prefix" ; then
        ZLIB_LOCATION=$with_zlib_prefix
        if test "x$host_cpu" == "xx86_64"; then
            ac_zlib_ldlib="-L$with_zlib_prefix/lib64"
        else
            ac_zlib_ldlib="-L$with_zlib_prefix/lib"
        fi
        ZLIB_LIBS="$ac_zlib_ldlib"
        AC_MSG_RESULT([$with_zlib_prefix])
    else
        ZLIB_LOCATION=""
        ZLIB_LIBS=""
        AC_MSG_ERROR([$with_zlib_prefix: no such directory])
    fi

    AC_SUBST(ZLIB_LOCATION)
    AC_SUBST(ZLIB_LIBS)

])

AC_DEFUN([AC_ZLIB_DEVEL],
[
    AC_ARG_WITH(zlib_devel_prefix,
                [  --with-zlib-devel-prefix=PFX   prefix where 'zlib-devel' is installed.],
                [],
                with_zlib_devel_prefix=${ZLIB_DEVEL_LOCATION:-/usr}
                )
    AC_MSG_CHECKING([for ZLIB DEVEL installation at ])

    ac_save_CFLAGS=$CFLAGS
    ac_save_LIBS=$LIBS
    if test -n "$with_zlib_devel_prefix" ; then
        ZLIB_DEVEL_CFLAGS="-I$with_zlib_devel_prefix/include"
        if test "x$host_cpu" == "xx86_64"; then
            ac_zlib_devel_ldlib="-L$with_zlib_devel_prefix/lib64"
        else
            ac_zlib_devel_ldlib="-L$with_zlib_devel_prefix/lib"
        fi
        ZLIB_DEVEL_LIBS="$ac_zlib_devel_ldlib"
        AC_MSG_RESULT([$with_zlib_devel_prefix])
    else
        ZLIB_DEVEL_CFLAGS=""
        ZLIB_DEVEL_LIBS=""
        AC_MSG_ERROR([$with_zlib_devel_prefix: no such directory])
    fi

    ZLIB_DEVEL_LIBS="$ZLIB_LIBS $ZLIB_DEVEL_LIBS -lz"
    CFLAGS="$ZLIB_DEVEL_CFLAGS $CFLAGS"
    LIBS="$ZLIB_DEVEL_LIBS $LIBS"
    AC_TRY_COMPILE([ #include <zlib.h> ],
                   [ z_stream b ],
                   [ ac_cv_zlib_devel_valid=yes ], [ ac_cv_zlib_devel_valid=no ])
    CFLAGS=$ac_save_CFLAGS
    LIBS=$ac_save_LIBS
    AC_MSG_RESULT([$ac_cv_zlib_devel_valid])

    if test x$ac_cv_zlib_devel_valid = xyes ; then
        ZLIB_DEVEL_LOCATION=$with_zlib_devel_prefix
        ifelse([$2], , :, [$2])
    else
        ZLIB_DEVEL_CFLAGS=""
        ZLIB_DEVEL_LIBS=""
        ZLIB_DEVEL_LOCATION=""
        ifelse([$3], , :, [$3])
    fi

    AC_SUBST(ZLIB_DEVEL_LOCATION)
    AC_SUBST(ZLIB_DEVEL_CFLAGS)
    AC_SUBST(ZLIB_DEVEL_LIBS)
])
