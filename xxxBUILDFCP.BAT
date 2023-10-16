rem BUILDFCP.BAT 2011-09-21 -- capitalize FCP
rem B     Do a complete build
rem DUNIT CLOCKS.PAS, etc. are to be compiled as units
rem $A-   PACKED RECORD used by default for COM98 binary record compatibility
dp /B /DUNIT /$A- %1 %2 %3 %4 %5 FCP
