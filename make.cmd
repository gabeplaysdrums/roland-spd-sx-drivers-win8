@echo off
setlocal

REM Reference:
REM http://technet.microsoft.com/en-us/library/dd919238(v=WS.10).aspx

if "%~1" == "/?" goto usage

set _arch=%~1
if "%_arch%" == "" set _arch=x64

set _option=%~2

set _output="%~dp0test\%_arch%"
echo Writing output to %_output%

REM remove output directory if it already exists
rmdir /s /q %_output%

REM copy base driver directory
robocopy /e "%~dp0base\%_arch%" %_output% *.*

cd %_output%

set _wdk_bin="%~dp0wdk\%_arch%"

set _cert_cn=TEST - My Driver Cert
set _cert_store=TestMyDriverCertStore

if "%_option%" == "nomakecert" (
    echo not creating test cert
) else (
    echo creating test cert
    %_wdk_bin%\makecert.exe -r -n "CN=%_cert_cn%" -ss %_cert_store% -sr LocalMachine

    echo adding cert to system stores
    %_wdk_bin%\certmgr.exe -add -c -n "%_cert_cn%" -s -r localMachine %_cert_store% -s -r localMachine root 
    %_wdk_bin%\certmgr.exe -add -c -n "%_cert_cn%" -s -r localMachine %_cert_store% -s -r localMachine trustedpublisher
)

echo making driver package index ^(.cat file^)
set _inf_file=RDIF1124.INF
copy /y "%~dp0\inf\%_arch%\%_inf_file%" .
%_wdk_bin%\Inf2Cat.exe /driver:. /os:8_%_arch% /pageHashes

echo signing driver package index
set _cat_file=rdid1124.cat
%_wdk_bin%\SignTool.exe sign /s %_cert_store% /n "%_cert_cn%" /t http://timestamp.verisign.com/scripts/timestamp.dll %_cat_file%

echo.
echo NEXT STEPS:
echo 1. In device manager, right click the device and choose "Update drivers"
echo 2. Choose to install drivers from a custom location
echo 3. Browse to %_output%
echo 4. Continue and complete installation
echo 5. Enjoy!
echo.

goto end

:usage

echo.
echo usage: make.cmd [^<x86^|x64^> [nomakecert]]
echo.

:end

endlocal
