rem Usage: ZIPFCP vvvv where vvvv is version number as e.g. 0601
if exist FCP%1.zip goto already
pkzip FCP%1 fcp.exe
pkzip FCP%1 fcp.map
pkzip FCP%1 history.txt
pkunzip -t FCP%1
pkunzip -v FCP%1
pause
exit
:already
echo ZIP FILE EXISTS ALREADY.  NO ACTION TAKEN.
exit
