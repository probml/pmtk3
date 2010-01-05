@if exist "c:\Program Files\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat" (
call "c:\Program Files\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"
) else (
if exist "c:\Program Files\Microsoft Visual Studio .NET 2003\Common7\Tools\vsvars32.bat" (
call "c:\Program Files\Microsoft Visual Studio .NET 2003\Common7\Tools\vsvars32.bat"
) else (
if exist "c:\Program Files\Microsoft Visual Studio\VC98\bin\vcvars32.bat" (
call "c:\Program Files\Microsoft Visual Studio\VC98\bin\vcvars32.bat"
) else (
@echo "Could not find either of these files:"
@echo "c:\Program Files\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"
@echo "c:\Program Files\Microsoft Visual Studio .NET 2003\Common7\Tools\vsvars32.bat"
@echo "c:\Program Files\Microsoft Visual Studio\VC98\bin\vcvars32.bat"
)))
@rem /MD : link with MSVCRT.lib
cl  /c /MD /O2 /DNDEBUG random.c
link random.obj /dll /def:random.def
