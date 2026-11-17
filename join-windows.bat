@echo off
setlocal
chcp 65001 >nul
set "NAME=ForAliyah.7z"
set "EXPECTED=96326898"
set "SHA=f0d639f680c9319c83c44171d13e554617cfffeb30f05df103bda72d3b9e4c85"
cd /d "%~dp0"
echo Joining the parts, please wait ...
if exist "%NAME%" del "%NAME%"
set COUNT=0
for /f "delims=" %%f in ('dir /b /on "%NAME%.???"') do call :add "%%f"
if "%COUNT%"=="0" (echo No parts found next to this script. & goto fail)
echo Joined %COUNT% parts.
for %%A in ("%NAME%") do set SIZE=%%~zA
if not "%SIZE%"=="%EXPECTED%" (echo SIZE MISMATCH: got %SIZE% bytes, expected %EXPECTED%. A part is missing or damaged. & goto fail)
echo Size OK: %SIZE% bytes.
if "%SHA%"=="" goto ok
echo Checking SHA-256, this can take a while ...
set GOT=
for /f "skip=1 delims=" %%h in ('certutil -hashfile "%NAME%" SHA256 ^| findstr /v /i "certutil"') do if not defined GOT set "GOT=%%h"
set "GOT=%GOT: =%"
if /i not "%GOT%"=="%SHA%" (echo CHECKSUM MISMATCH. The rebuilt file is damaged. & goto fail)
echo Checksum OK. The file is complete and intact.
:ok
echo Done. The rebuilt ZIP is in this folder.
pause
exit /b 0
:fail
pause
exit /b 1
:add
if "%COUNT%"=="0" (copy /b %1 "%NAME%" >nul) else (copy /b "%NAME%"+%1 "%NAME%" >nul)
set /a COUNT+=1
exit /b
