# Copyright (c) Istituto Nazionale di Fisica Nucleare (INFN). 2006-2010.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

AC_PREREQ(2.57)
AC_INIT([storm globus gridftp server], [1.2.0], [vincenzo.vagnoni@bo.infn.it])
AC_CONFIG_AUX_DIR([./project])
AC_CONFIG_SRCDIR([src/dsi_StoRM.h])
AM_INIT_AUTOMAKE
AC_CONFIG_MACRO_DIR([m4])

# Release number
osdist=`cat /etc/redhat-release | awk 'BEGIN {FS="release "} {print $2}'| awk 'BEGIN {FS="."} {print $1}'`
AC_SUBST([STORM_GLOBUS_GRIDFTP_SO], [sl$osdist])
AC_SUBST([STORM_GLOBUS_GRIDFTP_AGE_NUMBER], [4])

AC_SUBST([PACKAGE_PREFIX_NAME], [storm])
AC_SUBST([PACKAGE_LONG_NAME], [storm-globus-gridftp-server])
AC_SUBST([PACKAGE_SHORT_NAME], [globus-frontend-server])

# Notices.
AC_COPYRIGHT([See LICENCE file for details])
AC_REVISION([$Revision: $])

#Environment.
WORKDIR=`pwd`
AC_SUBST(WORKDIR)

DEFAULT_RPM_DIR=`pwd`

dnl Checks for programs.
AC_PROG_CC
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_LIBTOOL
AM_PROG_CC_C_O
AC_PROG_INSTALL

# Checks for libraries.
# dlopen library
AC_CHECK_LIB([dl], [dlopen])

dnl Checks for libraries.
dnl Replace `main' with a function in -lpthread:
AC_CHECK_LIB(pthread, main)

dnl Checks for header files.
AC_HEADER_STDC
AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS(sys/time.h syslog.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_PID_T
AC_HEADER_TIME

dnl Checks for library functions.
#AC_CHECK_FUNCS(select socket strdup strerror bsearch vsnprintf)

AC_STORM([])
AC_STORM_GRIDFTP([])

have_globus=no
AC_GLOBUS([], have_globus=yes, have_globus=no)
AC_MSG_RESULT(["GLOBUS found $have_globus"])
AM_CONDITIONAL([HAVE_GLOBUS], [test x$have_globus = xyes])

have_libattr_devel=no

AC_LIBATTR([])
AC_LIBATTR_DEVEL([], have_libattr_devel=yes, have_libattr_devel=no)
AC_MSG_RESULT(["LIBATTR found"])
AC_MSG_RESULT(["LIBATTR_DEVEL found $have_libattr_devel"])

have_zlib_devel=no

AC_ZLIB([])
AC_ZLIB_DEVEL([], have_zlib_devel=yes, have_zlib_devel=no)
AC_MSG_RESULT(["ZLIB found"])
AC_MSG_RESULT(["ZLIB_DEVEL found $have_zlib_devel"])

# Configuration items
#AC_PREFIX_DEFAULT([/usr])

AM_CONFIG_HEADER([src/autogen/config.h])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([config/Makefile])
AC_CONFIG_FILES([config/init.d/Makefile])
AC_CONFIG_FILES([config/init.d/storm-globus-gridftp])
AC_CONFIG_FILES([config/logrotate.d/Makefile])
AC_CONFIG_FILES([config/logrotate.d/storm-globus-gridftp])
AC_CONFIG_FILES([src/Makefile])
AC_CONFIG_FILES([storm-globus-gridftp.spec])

AC_OUTPUT
