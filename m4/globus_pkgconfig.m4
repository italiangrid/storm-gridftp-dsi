dnl Usage:
dnl AC_GLOBUS(MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl - GLOBUS_THR_CFLAGS
dnl - GLOBUS_THR_LIBS
dnl - GLOBUS_COMMON_THR_LIBS
dnl - GLOBUS_FTP_CLIENT_THR_LIBS
dnl - GLOBUS_SSL_THR_LIBS
dnl - GLOBUS_GSS_THR_LIBS
dnl - GLOBUS_LDAP_THR_LIBS

AC_DEFUN([AC_GLOBUS],
[

    have_globus_callout=no
    PKG_CHECK_MODULES(GLOBUS_CALLOUT, globus-callout, have_globus_callout=yes, have_globus_callout=no)
    
    have_globus_common=no
    PKG_CHECK_MODULES(GLOBUS_COMMON, globus-common, have_globus_common=yes, have_globus_common=no)
    
    have_globus_core=no
    PKG_CHECK_MODULES(GLOBUS_CORE, globus-core, have_globus_core=yes, have_globus_core=no)
    
    have_globus_ftp_client=no
    PKG_CHECK_MODULES(GLOBUS_FTP_CLIENT, globus-ftp-client, have_globus_ftp_client=yes, have_globus_ftp_client=no)
    
    have_globus_ftp_control=no
    PKG_CHECK_MODULES(GLOBUS_FTP_CONTROL, globus-ftp-control, have_globus_ftp_control=yes, have_globus_ftp_control=no)
    
    have_globus_gsi_callback=no
    PKG_CHECK_MODULES(GLOBUS_GSI_CALLBACK, globus-gsi-callback, have_globus_gsi_callback=yes, have_globus_gsi_callback=no)
    
    have_globus_gsi_cert_utils=no
    PKG_CHECK_MODULES(GLOBUS_GSI_CERT_UTILS, globus-gsi-cert-utils, have_globus_gsi_cert_utils=yes, have_globus_gsi_cert_utils=no)
    
    have_globus_gsi_credential=no
    PKG_CHECK_MODULES(GLOBUS_GSI_CREDENTIAL, globus-gsi-credential, have_globus_gsi_credential=yes, have_globus_gsi_credential=no)
    
    have_globus_gsi_openssl_error=no
    PKG_CHECK_MODULES(GLOBUS_GSI_OPENSSL_ERROR, globus-gsi-openssl-error, have_globus_gsi_openssl_error=yes, have_globus_gsi_openssl_error=no)
    
    have_globus_gsi_proxy_core=no
    PKG_CHECK_MODULES(GLOBUS_GSI_PROXY_CORE, globus-gsi-proxy-core, have_globus_gsi_proxy_core=yes, have_globus_gsi_proxy_core=no)
    
    have_globus_gsi_proxy_ssl=no
    PKG_CHECK_MODULES(GLOBUS_GSI_PROXY_SSL, globus-gsi-proxy-ssl, have_globus_gsi_proxy_ssl=yes, have_globus_gsi_proxy_ssl=no)
    
    have_globus_gsi_sysconfig=no
    PKG_CHECK_MODULES(GLOBUS_GSI_SYSCONFIG, globus-gsi-sysconfig, have_globus_gsi_sysconfig=yes, have_globus_gsi_sysconfig=no)
    
    have_globus_gssapi_error=no
    PKG_CHECK_MODULES(GLOBUS_GSSAPI_ERROR, globus-gssapi-error, have_globus_gssapi_error=yes, have_globus_gssapi_error=no)
    
    have_globus_gssapi_gsi=no
    PKG_CHECK_MODULES(GLOBUS_GSSAPI_GSI, globus-gssapi-gsi, have_globus_gssapi_gsi=yes, have_globus_gssapi_gsi=no)
    
    have_globus_gss_assist=no
    PKG_CHECK_MODULES(GLOBUS_GSS_ASSIST, globus-gss-assist, have_globus_gss_assist=yes, have_globus_gss_assist=no)
    
    have_globus_io=no
    PKG_CHECK_MODULES(GLOBUS_IO, globus-io, have_globus_io=yes, have_globus_io=no)
    
    have_globus_openssl_module=no
    PKG_CHECK_MODULES(GLOBUS_OPENSSL_MODULE, globus-openssl-module, have_globus_openssl_module=yes, have_globus_openssl_module=no)
    
    have_globus_openssl=no
    PKG_CHECK_MODULES(GLOBUS_OPENSSL, globus-openssl, have_globus_openssl=yes, have_globus_openssl=no)
    
    have_globus_xio=no
    PKG_CHECK_MODULES(GLOBUS_XIO, globus-xio, have_globus_xio=yes, have_globus_xio=no)


    GLOBUS_FTP_CLIENT_THR_LIBS="${GLOBUS_FTP_CLIENT_LIBS} ${GLOBUS_FTP_CONTROL_LIBS}"
    GLOBUS_SSL_THR_LIBS="${GLOBUS_OPENSSL_LIBS} ${GLOBUS_OPENSSL_MODULE_LIBS}"
    GLOBUS_COMMON_THR_LIBS="${GLOBUS_CALLOUT_LIBS} ${GLOBUS_COMMON_LIBS} ${GLOBUS_CORE_LIBS}"
    
    GLOBUS_GSS_THR_LIBS="${GLOBUS_GSI_CALLBACK_LIBS} ${GLOBUS_GSI_CERT_UTILS_LIBS} ${GLOBUS_GSI_CREDENTIAL_LIBS}"
    GLOBUS_GSS_THR_LIBS="${GLOBUS_GSS_THR_LIBS} ${GLOBUS_GSI_OPENSSL_ERROR_LIBS} ${GLOBUS_GSI_PROXY_CORE_LIBS}"
    GLOBUS_GSS_THR_LIBS="${GLOBUS_GSS_THR_LIBS} ${GLOBUS_GSI_PROXY_SSL_LIBS} ${GLOBUS_GSI_SYSCONFIG_SSL}"
    GLOBUS_GSS_THR_LIBS="${GLOBUS_GSS_THR_LIBS} ${GLOBUS_GSSAPI_ERROR_LIBS} ${GLOBUS_GSSAPI_GSI_LIBS} ${GLOBUS_GSS_ASSIST_LIBS}"

    GLOBUS_THR_LIBS="${GLOBUS_FTP_CLIENT_THR_LIBS} ${GLOBUS_SSL_THR_LIBS} ${GLOBUS_COMMON_THR_LIBS}"
    GLOBUS_THR_LIBS="${GLOBUS_THR_LIBS} ${GLOBUS_IO_LIBS} ${GLOBUS_XIO_LIBS}"
    
    
    GLOBUS_FTP_CLIENT_THR_CFLAGS="${GLOBUS_FTP_CLIENT_CFLAGS} ${GLOBUS_FTP_CONTROL_CFLAGS}"
    GLOBUS_SSL_THR_CFLAGS="${GLOBUS_OPENSSL_CFLAGS} ${GLOBUS_OPENSSL_MODULE_CFLAGS}"
    GLOBUS_COMMON_THR_CFLAGS="${GLOBUS_CALLOUT_CFLAGS} ${GLOBUS_COMMON_CFLAGS} ${GLOBUS_CORE_CFLAGS}"
    
    GLOBUS_GSS_THR_CFLAGS="${GLOBUS_GSI_CALLBACK_CFLAGS} ${GLOBUS_GSI_CERT_UTILS_CFLAGS} ${GLOBUS_GSI_CREDENTIAL_CFLAGS}"
    GLOBUS_GSS_THR_CFLAGS="${GLOBUS_GSS_THR_CFLAGS} ${GLOBUS_GSI_OPENSSL_ERROR_CFLAGS} ${GLOBUS_GSI_PROXY_CORE_CFLAGS}"
    GLOBUS_GSS_THR_CFLAGS="${GLOBUS_GSS_THR_CFLAGS} ${GLOBUS_GSI_PROXY_SSL_CFLAGS} ${GLOBUS_GSI_SYSCONFIG_SSL}"
    GLOBUS_GSS_THR_CFLAGS="${GLOBUS_GSS_THR_CFLAGS} ${GLOBUS_GSSAPI_ERROR_CFLAGS} ${GLOBUS_GSSAPI_GSI_CFLAGS} ${GLOBUS_GSS_ASSIST_CFLAGS}"

    GLOBUS_THR_CFLAGS="${GLOBUS_FTP_CLIENT_THR_CFLAGS} ${GLOBUS_SSL_THR_CFLAGS} ${GLOBUS_COMMON_THR_CFLAGS}"
    GLOBUS_THR_CFLAGS="${GLOBUS_THR_CFLAGS} ${GLOBUS_IO_CFLAGS} ${GLOBUS_XIO_CFLAGS}"
    
    if test x$have_globus_callout = xyes -a x$have_globus_common = xyes -a x$have_globus_core = xyes \
            -a x$have_globus_ftp_client = xyes -a x$have_globus_ftp_control = xyes -a x$have_globus_gsi_callback = xyes \
            -a x$have_globus_gsi_cert_utils = xyes -a x$have_globus_gsi_credential = xyes \
            -a x$have_globus_gsi_openssl_error = xyes -a x$have_globus_gsi_proxy_core = xyes \
            -a x$have_globus_gsi_proxy_ssl = xyes -a x$have_globus_gsi_sysconfig = xyes \
            -a x$have_globus_gssapi_error = xyes -a x$have_globus_gssapi_gsi = xyes -a x$have_globus_gss_assist = xyes \
            -a x$have_globus_io = xyes -a x$have_globus_openssl_module = xyes -a x$have_globus_openssl = xyes \
            -a x$have_globus_xio = xyes ; then
        ifelse([$2], , :, [$2])
    else
        ifelse([$3], , :, [$3])
    fi

    GLOBUS_NOTHR_CFLAGS=$GLOBUS_THR_CFLAGS
    GLOBUS_NOTHR_LIBS=$GLOBUS_THR_LIBS
    GLOBUS_COMMON_NOTHR_LIBS=$GLOBUS_COMMON_THR_LIBS
    GLOBUS_FTP_CLIENT_NOTHR_LIBS=$GLOBUS_FTP_CLIENT_THR_LIBS
    GLOBUS_SSL_NOTHR_LIBS=$GLOBUS_SSL_THR_LIBS
    GLOBUS_GSS_NOTHR_LIBS=$GLOBUS_GSS_THR_LIBS
    GLOBUS_LDAP_NOTHR_LIBS=$GLOBUS_LDAP_THR_LIBS

    AC_SUBST(GLOBUS_THR_CFLAGS)
    AC_SUBST(GLOBUS_THR_LIBS)
    AC_SUBST(GLOBUS_COMMON_THR_LIBS)
    AC_SUBST(GLOBUS_FTP_CLIENT_THR_LIBS)
    AC_SUBST(GLOBUS_SSL_THR_LIBS)
    AC_SUBST(GLOBUS_GSS_THR_LIBS)
    AC_SUBST(GLOBUS_LDAP_THR_LIBS)

    AC_SUBST(GLOBUS_NOTHR_CFLAGS)
    AC_SUBST(GLOBUS_NOTHR_LIBS)
    AC_SUBST(GLOBUS_COMMON_NOTHR_LIBS)
    AC_SUBST(GLOBUS_FTP_CLIENT_NOTHR_LIBS)
    AC_SUBST(GLOBUS_SSL_NOTHR_LIBS)
    AC_SUBST(GLOBUS_GSS_NOTHR_LIBS)
    AC_SUBST(GLOBUS_LDAP_NOTHR_LIBS)

])
