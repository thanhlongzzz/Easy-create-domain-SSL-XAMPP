@echo off

REM Set the domain name and path
set domain=mydomain.local
set /p domain=Enter the domain name (e.g., mydomain.local): 
set path_to_xampp=C:/xampp

REM Start Apache
REM echo Starting Apache...
cd %path_to_xampp%/apache
REM httpd.exe

REM Add domain to hosts file
echo Adding domain to hosts file...
echo 127.0.0.1 %domain% >> %SystemRoot%/System32/drivers/etc/hosts

REM Generate a self-signed SSL certificate
echo Generating SSL certificate...
cd %path_to_xampp%/apache/bin

xcopy /y /F "%path_to_xampp%/cert_default.conf"  "%path_to_xampp%/apache/conf/cert_mod.conf"
echo commonName_default          = %domain% >> "%path_to_xampp%/apache/conf/cert_mod.conf"
echo [ alternate_names ] >> "%path_to_xampp%/apache/conf/cert_mod.conf"
echo DNS.1       = %domain% >> "%path_to_xampp%/apache/conf/cert_mod.conf"

set OPENSSL_CONF=%path_to_xampp%/apache/conf/openssl.cnf
%path_to_xampp%/apache/bin/openssl req -config "%path_to_xampp%/apache/conf/cert_mod.conf" -new -sha256 -newkey rsa:2048 -nodes -keyout "%path_to_xampp%/apache/conf/ssl.key/server_%domain%.key" -x509 -days 765 -out "%path_to_xampp%/apache/conf/ssl.crt/server_%domain%.crt"

REM Configure Apache with SSL
echo Configuring Apache with SSL...
cd "%path_to_xampp%/apache/conf/extra"
echo # >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo #%domain% >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo ^<VirtualHost *:80^> >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo     DocumentRoot "%path_to_xampp%/htdocs/%domain%" >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo     ServerName %domain% >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo ^</VirtualHost^> >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo. >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo ^<VirtualHost *:443^> >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo     DocumentRoot "%path_to_xampp%/htdocs/%domain%" >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo     ServerName %domain% >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo     SSLEngine on >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo     SSLCertificateFile "%path_to_xampp%/apache/conf/ssl.crt/server_%domain%.crt" >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo     SSLCertificateKeyFile "%path_to_xampp%/apache/conf/ssl.key/server_%domain%.key" >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"
echo ^</VirtualHost^> >> "%path_to_xampp%/apache/conf/extra/httpd-vhosts.conf"

echo Create DocumentRoot folder...
if not exist "%path_to_xampp%/htdocs/%domain%" mkdir "%path_to_xampp%/htdocs/%domain%"

REM Restart Apache
REM echo Restarting Apache...
REM httpd -k restart

echo Done.
cd %path_to_xampp%
"%path_to_xampp%/apache/conf/ssl.crt/server_%domain%.crt"
"%path_to_xampp%/xampp_stop.exe"
REM pause
