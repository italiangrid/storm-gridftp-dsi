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

MTC_CFLAGS = -pthread -DCTHREAD_POSIX -D_THREAD_SAFE -D_REENTRANT

INCLUDES = -I$(top_srcdir)/src/\
    @GLOBUS_THR_CFLAGS@


lib_LTLIBRARIES = globus_gridftp_server_StoRM.la

globus_gridftp_server_StoRM_la_SOURCES = \
    globus_gridftp_server_StoRM.c
globus_gridftp_server_StoRM_la_CFLAGS = $(MTC_CFLAGS)
globus_gridftp_server_StoRM_la_LDFLAGS = \
    -L$(GLOBUS_LOCATION)/lib
globus_gridftp_server_StoRM_la_LIBADD = \
    @GLOBUS_FTP_CONTROL_NOTHR_LIBS@ \
    -shared -lz \
    $(MOPTION)
    
MAINTAINERCLEANFILES = Makefile.in    
