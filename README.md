The Globus GridFTP StoRM DSI
===============================

StoRM GridFTP DSI plugin is a plugin of Globus GridFTP that computes the ADLER32 
checksum on incoming file transfers and stores this value on an extended attribute
of the file.

Supported platforms
Scientific Linux 5 on x86_64 architecture
Scientific Linux 6 on x86_64 architecture

### Building
Required packages:

* epel
* git
* automake
* autoconf
* libtool
* gcc
* libattr-devel 
* globus-gridftp-server-devel  
* globus-ftp-control-devel  
* globus-ftp-client-devel

Build command:
```bash
./bootstrap
./configure
make rpm
```

# Contact info

If you have problems, questions, ideas or suggestions, please contact us at
the following URLs

* GGUS (official support channel): http://www.ggus.eu
