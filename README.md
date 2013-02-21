StoRM GridFTP DSI
===============================

StoRM [GridFTP DSI](http://www.globus.org/toolkit/docs/4.2/4.2.0/data/gridftp/developer/gridftp-developer-dsi.html) 
is a plugin of Globus GridFTP that computes the ADLER32 checksum on incoming file transfers and stores this value on an extended attribute
of the file.

## Build from source

### Supported platforms
* Scientific Linux 5 x86_64
* Scientific Linux 6 x86_64

### Repositories

Some of the packages needed to build storm-gridftp-dsi are in the [EPEL](http://fedoraproject.org/wiki/EPEL) 
repository. To install it run

```bash
yum install epel-release
```

### Dependencies

You need git to clone the project, and autotools (libtool, automake, autoconf) and gcc to build it.

The other dependencies are

* libattr-devel 
* globus-gridftp-server-devel  
* globus-ftp-control-devel  
* globus-ftp-client-devel

### Build instructions

```bash
./bootstrap
./configure
make rpm
```

## Contact info

If you have problems, questions, ideas or suggestions, please contact us at
the following URLs

* GGUS (official support channel): http://www.ggus.eu
