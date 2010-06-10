#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

#
# Authors: Elisabetta Ronchieri <elisabetta.ronchieri@cnaf.infn.it>
# Version info: $Id: $
# Release: $Name: $
#
# Revision history:
# $Log: $
#

AC_PREREQ(2.57)
AC_INIT([StoRM globus gridftp], [1.0.2])
AC_CONFIG_AUX_DIR([./project])
AM_INIT_AUTOMAKE([1.6.3 subdir-objects])
AC_CONFIG_SRCDIR([src/globus_gridftp_server_StoRM.c])

#Environment.
WORKDIR=`pwd`
AC_SUBST(WORKDIR)

dnl Checks for programs.
AC_PROG_AWK
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_CXX
AC_PROG_LIBTOOL

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
AC_CHECK_FUNCS(select socket strdup strerror bsearch vsnprintf)

have_globus=no

AC_GLOBUS([], have_globus=yes, have_globus=no)

AC_MSG_RESULT(["GLOBUS found $have_globus"])

AM_CONDITIONAL([HAVE_GLOBUS], [test x$have_globus = xyes])

dnl Temporarily built with no optimisation

CXXFLAGS="-g -O0"
CFLAGS="-g -O0"

# Configuration items
AC_PREFIX_DEFAULT([/opt/glite])
AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([config/Makefile])
AC_CONFIG_FILES([src/Makefile])
AC_CONFIG_FILES([storm-globus-gridftp.spec])

AC_OUTPUT
