@echo off
WHERE /Q tic80.exe >NUL
IF ERRORLEVEL 1 (
  echo ERROR! tic80.exe not found in the system path or in the current directory. Relocate this file to the folder containing tic80.exe or add the path to tic80.exe to your system path.
  pause
  exit
) ELSE (
  echo tic80.exe FOUND in the system path or current dir
)
set /p name=Enter new project name, Must not contain spaces:
:start
echo Select an option:
echo __________________
echo lua      - 1
echo ruby     - 2
echo js       - 3
echo moon     - 4
echo fennel   - 5
echo squirrel - 6
echo wren     - 7
echo wasm     - 8
echo janet    - 9
echo __________________
set /p choice=Enter your choice: 
IF %choice% == 1 (
  set lang=lua
  goto end
)
IF %choice% == 2 (
  set lang=rb
  goto end
)
IF %choice% == 3 (
  set lang=js
  goto end
)
IF %choice% == 4 (
  set lang=moon
  goto end
)
IF %choice% == 5 (
  set lang=fnl
  goto end
)
IF %choice% == 6 (
  set lang=nut
  goto end
)
IF %choice% == 7 (
  set lang=wren
  goto end
)
IF %choice% == 8 (
  set lang=wasm
  goto end
)
IF %choice% == 9 (
  set lang=janet
  goto end
)
echo Invalid choice.
goto start
:end
rem md "%~dp0\projects\"
cd "projects"
md %name%
cd %name%
echo @echo off > start.bat
echo start /b tic80.exe --fs . --cmd="load %name%.%lang%" >> start.bat
echo exit >> start.bat
md libs
tic80.exe --skip --cmd="new %lang% & save %name%.%lang% & exit" --fs .
echo New project created...
echo Would you like to launch your new project?
set /p dec=Type y or n: 
if %dec% == y (
  @echo off
  start /b start.bat
)