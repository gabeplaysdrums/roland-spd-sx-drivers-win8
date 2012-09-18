@echo off
setlocal

set _cert_cn=TEST - My Driver Cert
set _cert_file="%~dp0TestCert.cer"
set _wdk_bin="%~dp0wdk"

echo adding cert to system stores
%_wdk_bin%\certmgr.exe -add -c -n "%_cert_cn%" %_cert_file% -s -r localMachine root 
%_wdk_bin%\certmgr.exe -add -c -n "%_cert_cn%" %_cert_file% -s -r localMachine trustedpublisher

echo.
echo NEXT STEPS:
echo 1. In device manager, right click the device and choose "Update drivers"
echo 2. Choose to install drivers from a custom location
echo 3. Browse to %_output%
echo 4. Continue and complete installation
echo 5. Enjoy!
echo.


endlocal
