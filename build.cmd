@echo off
echo.
echo Working...
echo.
%~dp0assets\ahk2exe.exe /bin %~dp0assets\bw-at.bin /in %~dp0bw-at.ahk /out %~dp0release\bw-at.exe
pushd %~dp0release
del /q bw-at.*z*
..\assets\7z.exe a -t7z -mx=9 bw-at.7z bw-at.exe >nul
..\assets\7z.exe a -tzip -mx=9 bw-at.zip bw-at.exe >nul
pause
