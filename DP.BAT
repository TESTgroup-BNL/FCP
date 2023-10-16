rem INVOKE COMMAND LINE DELPHI COMPILER WITH SELECTED OPTIONS
rem J.N. 1998-09-28
rem J.N. 2002-06-10  Use REM to select Delphi4 or Delphi6
rem J.N. 2002-06-13  Delphi6 only w/ separate BIN and LIB macros
rem J.N. 2013-12-15  Change progra~1 to progra~2 for Windows 7 machines
set BIN=c:\progra~2\borland\delphi6\bin
set LIB=c:\progra~2\borland\delphi6\lib
%BIN%\dcc32 /U%LIB% /DDELPHI /$N+ /$D+ /$L+ /$Q+ /$R+ /GD /H %1 %2 %3 %4 %5
