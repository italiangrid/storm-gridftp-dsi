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
dnl - LIBTYPE
dnl - DISTTAR

dnl - STORM_CLIENT_LOCATION
dnl - STORM_CLIENT_CFLAGS
dnl - STORM_CLIENT_LDFLAGS

dnl - STORM_FRONTEND_LOCATION
dnl - STORM_FRONTEND_CFLAGS
dnl - STORM_FRONTEND_LDFLAGS

dnl - STORM_GRIDFTP_LOCATION
dnl - STORM_GRIDFTP_CFLAGS
dnl - STORM_GRIDFTP_LDFLAGS

AC_DEFUN([AC_STORM],
[
    AC_ARG_WITH(dist_bin_location,
                [  --with-dist-bin-location=PFX     prefix where DIST location is. (pwd)],
                [],
                with_dist_bin_location=$WORKDIR/../dist
               )

    DISTBIN=$with_dist_bin_location
    AC_SUBST([DISTBIN])

    AC_ARG_WITH(dist_source_location,
                [  --with-dist-source-location=PFX     prefix where DIST location is. (pwd)],
                [],
                with_dist_source_location=$WORKDIR/../dist
               )

    DISTSOURCE=$with_dist_source_location
    AC_SUBST([DISTSOURCE])

    if test "x$host_cpu" = "xx86_64"; then
        AC_SUBST([libdir], ['${exec_prefix}/lib64'])
        libtype='lib64'
    else
        libtype='lib'
    fi

    AC_SUBST([LIBTYPE], [$libtype])
    AC_SUBST([mandir], ['${prefix}/share/man'])

])

AC_DEFUN([AC_STORM_GRIDFTP],
[
    AC_ARG_WITH(storm_gridftp_location,
                [  --with-storm-gridftp-location=PFX     prefix where STORM is installed. (/opt/storm/gridftp)],
                [],
                with_storm_gridftp_location=/opt/storm/gridftp
               )

    AC_MSG_CHECKING([for STORM GRIDFTP installation at ])

    if test -n "with_storm_gridftp_location" ; then
        STORM_GRIDFTP_LOCATION="$with_storm_gridftp_location"
        STORM_GRIDFTP_CFLAGS="-I$STORM_GRIDFTP_LOCATION/include"
        if test "x$host_cpu" = "xx86_64"; then
            ac_storm_gridftp_ldlib="-L$with_storm_gridftp_location/lib64"
        else
            ac_storm_gridftp_ldlib="-L$with_storm_gridftp_location/lib"
        fi
        STORM_FRONTEND_LDFLAGS="ac_storm_gridftp_ldlib"
        AC_MSG_RESULT([$with_storm_gridftp_location])
    else
        STORM_GRIDFTP_LOCATION=""
        STORM_GRIDFTP_CFLAGS=""
        STORM_GRIDFTP_LDFLAGS=""
        AC_MSG_ERROR([$with_storm_gridftp_location: no such directory])
    fi

    AC_SUBST(STORM_GRIDFTP_LOCATION)
    AC_SUBST(STORM_GRIDFTP_CFLAGS)
    AC_SUBST(STORM_GRIDFTP_LDFLAGS)

])

AC_DEFUN([AC_STORM_FRONTEND],
[
    AC_ARG_WITH(storm_frontend_location,
                [  --with-storm-frontend-location=PFX     prefix where STORM_FRONTEND is installed. (/opt/storm/frontend)],
                [],
                with_storm_frontend_location=/opt/storm/frontend
               )

    AC_MSG_CHECKING([for STORM FRONTEND installation at ])

    if test -n "with_storm_frontend_location" ; then
        STORM_FRONTEND_LOCATION="$with_storm_frontend_location"
        STORM_FRONTEND_CFLAGS="-I$STORM_FRONTEND_LOCATION/include"
        if test "x$host_cpu" = "xx86_64"; then
            ac_storm_frontend_ldlib="-L$with_storm_frontend_location/lib64"
        else
            ac_storm_frontend_ldlib="-L$with_storm_frontend_location/lib"
        fi
        STORM_FRONTEND_LDFLAGS="ac_storm_frontend_ldlib"
        AC_MSG_RESULT([$with_storm_frontend_location])
    else
        STORM_FRONTEND_LOCATION=""
        STORM_FRONTEND_CFLAGS=""
        STORM_FRONTEND_LDFLAGS=""
        AC_MSG_ERROR([$with_storm_frontend_location: no such directory])
    fi

    AC_SUBST(STORM_FRONTEND_LOCATION)
    AC_SUBST(STORM_FRONTEND_CFLAGS)
    AC_SUBST(STORM_FRONTEND_LDFLAGS)

])

AC_DEFUN([AC_STORM_CLIENT],
[
    AC_ARG_WITH(storm_client_location,
                [  --with-storm-client-location=PFX     prefix where STORM_CLIENT is installed. (/opt/storm/client)],
                [],
                with_storm_client_location=/opt/storm/client
               )

    AC_MSG_CHECKING([for STORM CLIENT installation at ])

    if test -n "with_storm_client_location" ; then
        STORM_CLIENT_LOCATION="$with_storm_client_location"
        STORM_CLIENT_CFLAGS="-I$STORM_CLIENT_LOCATION/include"
        if test "x$host_cpu" = "xx86_64"; then
            ac_storm_client_ldlib="-L$with_storm_client_location/lib64"
        else
            ac_storm_client_ldlib="-L$with_storm_client_location/lib"
        fi
        STORM_CLIENT_LDFLAGS="ac_storm_client_ldlib"
        AC_MSG_RESULT([$with_storm_client_location])
    else
        STORM_CLIENT_LOCATION=""
        STORM_CLIENT_CFLAGS=""
        STORM_CLIENT_LDFLAGS=""
        AC_MSG_ERROR([$with_storm_client_location: no such directory])
    fi

    AC_SUBST(STORM_CLIENT_LOCATION)
    AC_SUBST(STORM_CLIENT_CFLAGS)
    AC_SUBST(STORM_CLIENT_LDFLAGS)

])
