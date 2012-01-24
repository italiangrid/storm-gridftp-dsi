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
dnl AC_LIBATTR(MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for libattr, and defines
dnl - LIBATTR_LIBS (linker flags, stripping and path)
dnl - LIBATTR_LOCATION

dnl AC_LIBATTR_DEVEL(MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for libattr-devel, and defines
dnl - LIBATTR_DEVEL_CFLAGS (compiler flags)
dnl - LIBATTR_DEVEL_LIBS (linker flags, stripping and path)
dnl - LIBATTR_DEVEL_LOCATION

AC_DEFUN([AC_LIBATTR],
[
    AC_ARG_WITH(libattr_prefix,
    [  --with-libattr-prefix=PFX     prefix where libattr is installed.],
    [],
        with_libattr_prefix=${LIBATTR_LOCATION:-/usr})

    AC_MSG_CHECKING([for LIBATTR installation at ])

    dnl Temporary checks
    if test "x$host_cpu" = "xi686" ; then
      with_libattr_prefix="$with_libattr_prefix"
    else
      a=`echo $with_libattr_prefix | awk -F '/' '{print $NF}'`
      if test "$a"  != "usr" ; then
        with_libattr_prefix="$with_libattr_prefix/usr"
      fi
    fi

    if test -n "$with_libattr_prefix" ; then
        LIBATTR_LOCATION=$with_libattr_prefix
        if test "x$host_cpu" = "xx86_64"; then
            ac_libattr_ldlib="-L$with_libattr_prefix/lib64"
        else
            ac_libattr_ldlib="-L$with_libattr_prefix/lib"
        fi
        LIBATTR_LIBS="$ac_libattr_ldlib"
        AC_MSG_RESULT([$with_libattr_prefix])
    else
        LIBATTR_LOCATION=""
        LIBATTR_LIBS=""
        AC_MSG_ERROR([$with_libattr_prefix: no such directory])
    fi

    AC_SUBST(LIBATTR_LOCATION)
    AC_SUBST(LIBATTR_LIBS)

])

AC_DEFUN([AC_LIBATTR_DEVEL],
[
    AC_ARG_WITH(libattr_devel_prefix,
                [  --with-libattr-devel-prefix=PFX   prefix where 'libattr-devel' is installed.],
                [],
                with_libattr_devel_prefix=${LIBATTR_DEVEL_LOCATION:-/usr}
                )
    AC_MSG_CHECKING([for LIBATTR DEVEL installation at ])

    dnl Temporary checks
    if test "x$host_cpu" = "xi686" ; then
      with_libattr_devel_prefix="$with_libattr_devel_prefix"
    else
      a=`echo $with_libattr_devel_prefix | awk -F '/' '{print $NF}'`
      if test "$a"  != "usr" ; then
        with_libattr_devel_prefix="$with_libattr_devel_prefix/usr"
      fi
    fi

    ac_save_CFLAGS=$CFLAGS
    ac_save_LIBS=$LIBS
    if test -n "$with_libattr_devel_prefix" ; then
        LIBATTR_DEVEL_CFLAGS="-I$with_libattr_devel_prefix/include"
        if test "x$host_cpu" = "xx86_64"; then
            ac_libattr_devel_ldlib="-L$with_libattr_devel_prefix/lib64"
        else
            ac_libattr_devel_ldlib="-L$with_libattr_devel_prefix/lib"
        fi
        LIBATTR_DEVEL_LIBS="$ac_libattr_devel_ldlib"
        AC_MSG_RESULT([$with_libattr_devel_prefix])
    else
        LIBATTR_DEVEL_CFLAGS=""
        LIBATTR_DEVEL_LIBS=""
        AC_MSG_ERROR([$with_libattr_devel_prefix: no such directory])
    fi

    LIBATTR_DEVEL_LIBS="$LIBATTR_LIBS $LIBATTR_DEVEL_LIBS -lattr"
    AC_MSG_RESULT([..... $LIBATTR_DEVEL_LIBS])
    CFLAGS="$LIBATTR_DEVEL_CFLAGS $CFLAGS"
    LIBS="$LIBATTR_DEVEL_LIBS $LIBS"
    AC_TRY_COMPILE([ #include <sys/types.h>
                     #include <attr/xattr.h> ],
                   [ int a = 1 ],
                   [ ac_cv_libattr_devel_valid=yes ], [ ac_cv_libattr_devel_valid=no ])
    CFLAGS=$ac_save_CFLAGS
    LIBS=$ac_save_LIBS
    AC_MSG_RESULT([$ac_cv_libattr_devel_valid])

    if test x$ac_cv_libattr_devel_valid = xyes ; then
        LIBATTR_DEVEL_LOCATION=$with_libattr_devel_prefix
        ifelse([$2], , :, [$2])
    else
        LIBATTR_DEVEL_CFLAGS=""
        LIBATTR_DEVEL_LIBS=""
        LIBATTR_DEVEL_LOCATION=""
        ifelse([$3], , :, [$3])
    fi

    AC_SUBST(LIBATTR_DEVEL_LOCATION)
    AC_SUBST(LIBATTR_DEVEL_CFLAGS)
    AC_SUBST(LIBATTR_DEVEL_LIBS)
])
