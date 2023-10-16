rem MAKEFCP.BAT 2011-09-21 -- capitalize FCP
rem M     Do a make as necessary
rem DUNIT CLOCKS.PAS, etc. are to be compiled as units
rem $A-   PACKED RECORD used by default for COM98 binary record compatibility
dp /M /DUNIT /$A- %1 %2 %3 %5 %6 %7 FCP
