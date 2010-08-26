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

EXTRA_DIST = dsi_StoRM.h

OTHER_CFLAGS = -fPIC -DPIC -D_LARGEFILE64_SOURCE -Wall -Werror
MTC_CFLAGS = -pthread -DCTHREAD_POSIX -D_THREAD_SAFE -D_REENTRANT

noinst_INCLUDES = dsi_StoRM.h
 
lib_LTLIBRARIES = libglobus_gridftp_server_StoRM_@GLOBUS_NOTHR_FLAVOR@.la

libglobus_gridftp_server_StoRM_@GLOBUS_NOTHR_FLAVOR@_la_SOURCES = \
    globus_gridftp_server_StoRM.c
libglobus_gridftp_server_StoRM_@GLOBUS_NOTHR_FLAVOR@_la_LIBADD = \
    @GLOBUS_FTP_CONTROL_NOTHR_LIBS@ \
    @ZLIB_DEVEL_LIBS@ \
    -ldl
libglobus_gridftp_server_StoRM_@GLOBUS_NOTHR_FLAVOR@_la_LDFLAGS = \
    -shared -rpath $(libdir)
libglobus_gridftp_server_StoRM_@GLOBUS_NOTHR_FLAVOR@_la_CPPFLAGS = \
    $(OTHER_CFLAGS) \
    $(MTC_CFLAGS) \
    @GLOBUS_NOTHR_CFLAGS@ \
    @LIBATTR_DEVEL_CFLAGS@ \
    @ZLIB_DEVEL_CFLAGS@ \
    $(API_INCLUDES)

API_INCLUDES = \
    -I$(top_srcdir)/src/
    
MAINTAINERCLEANFILES = Makefile.in    
