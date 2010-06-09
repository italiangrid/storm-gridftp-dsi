LDFLAGS += -Wl

CC += -fPIC -D_LARGEFILE64_SOURCE -Wall -Werror
CXX += -fPIC -D_LARGEFILE64_SOURCE -Wall -Werror
MTCCFLAGS = -pthread -DCTHREAD_POSIX -D_THREAD_SAFE -D_REENTRANT
MTLDLIBS =
MTLDFLAGS = -pthread
SHLIBLDFLAGS = -shared
SHLIBREQLIBS = -lc -lpthread `g++ -print-file-name=libstdc++.so` -ldl

ACCTFLAG=-DSACCT
BIN = /usr/bin
LIBDIR = /usr/lib64
CONFIGDIR = /etc/sysconfig
CP = cp
LD = cc
LN = ln
SHELL = /bin/sh

FLAVOR=gcc32dbg
MOPTION=-m32
ifeq ($(shell uname -m), x86_64)
  FLAVOR=gcc64dbg
  MOPTION=-m64
endif

INCLUDES = -I$(GLOBUS_LOCATION)/include/$(FLAVOR)
CFLAGS = -g -O0 $(MTCCFLAGS) $(INCLUDES) $(MOPTION) -fPIC
LDFLAGS  = -L$(GLOBUS_LOCATION)/lib $(MOPTION) -shared -lz
LIBDIR = /usr/lib64

DSI_LIBDIR = $(GLOBUS_LOCATION)/lib
DSI_LIBNAME = globus_gridftp_server_StoRM_$(FLAVOR)
DSI_LDLIBS = -lglobus_ftp_control_$(FLAVOR)

lib$(DSI_LIBNAME).so: globus_gridftp_server_StoRM.o
	$(LD) -shared --no-undefined -o $@ $(LDFLAGS) -Wl,-soname,lib$(DSI_LIBNAME).so globus_gridftp_server_StoRM.o $(DSI_LDLIBS)

install:
	cp -a libglobus_gridftp_server_StoRM_gcc64dbg.so /opt/globus/lib/libglobus_gridftp_server_StoRM_gcc64dbg.so
	cp -a globus-gridftp-storm /etc/init.d/globus-gridftp-storm

build:
	rpmbuild -bb rpm.spec

