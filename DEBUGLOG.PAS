Unit debuglog;
{$L-}
{$R+}    {Range checking on}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N+}    {Numeric coprocessor}
{$E-}    {Do not include emulation code}
{*E+}    {Include emulation code}
{$H-}    {Old Turbo-style strings are default}
{
  FACE control program interface to a debugging log file.

  v1.0  2002-05-23  Original
  v1.1  2002-05-26  FileWrite: replace control chars by grave accent
                    FileOpen:  remove auto append of .LOG to file name
  v1.2  2003-01-28  Replace Uses dos32 by SysUtils
                    FileWrite: call SysUtils functions for date/time
  v1.3  2003-03-18  Replace Close() by CloseFile()

  John Nagy, Brookhaven National Lab, Upton NY 11973 U.S.A.  nagy@bnl.gov
}

Interface

CONST DEBUGLOG_NONE  = -1;  {one less than hex 0}
CONST DEBUGLOG_FIRST =  0;
CONST DEBUGLOG_LAST  = 15;
CONST DEBUGLOG_ALL   = 16;  {one more than hex F}

FUNCTION DebugLogEnableGet (id: INTEGER): BOOLEAN;
FUNCTION DebugLogEnableSet (id: INTEGER; state: BOOLEAN): INTEGER;
FUNCTION DebugLogFileClear: INTEGER;
FUNCTION DebugLogFileClose: INTEGER;
FUNCTION DebugLogFileFlush: INTEGER;
FUNCTION DebugLogFileNameGet: String;
FUNCTION DebugLogFileOpen (filename: String): INTEGER;
FUNCTION DebugLogFileWrite (id: INTEGER; msg: String): INTEGER;
FUNCTION DebugLogRegister (idname: String): INTEGER;
FUNCTION DebugLogUnitNameGet (id: INTEGER): String;

Implementation

Uses SysUtils;

VAR debug_enable_list: ARRAY [DEBUGLOG_NONE..DEBUGLOG_ALL] OF BOOLEAN;
VAR debug_idname_list: ARRAY [DEBUGLOG_NONE..DEBUGLOG_ALL] OF String;

VAR debug_file_name: String;
VAR debug_file_ptr: TEXT;

VAR debug_id_last: INTEGER;

VAR i: INTEGER;

FUNCTION DebugLogEnableGet (id: INTEGER): BOOLEAN;
VAR switch: BOOLEAN;
BEGIN
  IF (id IN [DEBUGLOG_FIRST..DEBUGLOG_LAST])
    THEN BEGIN
      switch := debug_enable_list[id];
      IF debug_enable_list[DEBUGLOG_NONE] THEN switch := FALSE;
      IF debug_enable_list[DEBUGLOG_ALL] THEN switch := TRUE;
      END
    ELSE BEGIN
      switch := FALSE;  {returned if id is not valid}
      END;
  DebugLogEnableGet := switch;
  END;  {of function 'DebugLogEnableGet'}

FUNCTION DebugLogEnableSet (id: INTEGER; state: BOOLEAN): INTEGER;
{Note that setting NONE or ALL leaves the
 specific enable values unaltered but ignored.
 See DebugLogEnableGet.
 }
VAR action: INTEGER;
BEGIN
  IF (id IN [DEBUGLOG_FIRST..DEBUGLOG_LAST])
    THEN BEGIN
      debug_enable_list[id] := state;
      IF debug_enable_list[DEBUGLOG_NONE] THEN 
        debug_enable_list[DEBUGLOG_ALL] := FALSE;
      IF (debug_enable_list[id]) AND (id <> DEBUGLOG_NONE) THEN 
        debug_enable_list[DEBUGLOG_NONE] := FALSE;
      action := 1;
      END
    ELSE BEGIN
      action := 0;  {indicates failure}
      END;
  DebugLogEnableSet := action;
  END;  {of function 'DebugLogEnableSet'}

FUNCTION DebugLogFileClear: INTEGER;
{Note that the debug file must already be assigned using Open
 and function leaves file still opened but empty.
 }
VAR outcome: INTEGER;
BEGIN
  {$I-}
  outcome := DebugLogFileClose;
  REWRITE (debug_file_ptr);
  DebugLogFileWrite (DEBUGLOG_ALL, 'File has been cleared');
  {$I+}
  DebugLogFileClear := IOResult;
  END;  {of function 'DebugLogFileClear'}

FUNCTION DebugLogFileClose: INTEGER;
BEGIN
  {$I-}
  DebugLogFileWrite (DEBUGLOG_ALL, 'File closing');
  Flush (debug_file_ptr);
  CloseFile (debug_file_ptr);
  {$I+}
  DebugLogFileClose := IOResult;
  END;  {of function 'DebugLogFileClose'}

FUNCTION DebugLogFileFlush: INTEGER;
BEGIN
  {$I-}
  Flush (debug_file_ptr);
  {$I+}
  DebugLogFileFlush := IOResult;
  END;  {of function 'DebugLogFileFlush'}

FUNCTION DebugLogFileNameGet: String;
BEGIN
  DebugLogFileNameGet := debug_file_name;
  END;  {of function 'DebugLogFileNameGet'}

FUNCTION DebugLogFileOpen (filename: String): INTEGER;
BEGIN
  {$I-}
  debug_file_name := filename;
  Assign (debug_file_ptr, debug_file_name);
  Append (debug_file_ptr);
  DebugLogFileWrite (DEBUGLOG_ALL, 'File open attempt');
  {$I+}
  DebugLogFileOpen := IOResult;
  END;  {of function 'DebugLogFileOpen'}

FUNCTION DebugLogFileWrite (id: INTEGER; msg: String): INTEGER;
{Note that debug_enable_list is not referenced in this function.}  
BEGIN
  {Replace control characters by grave accent}
  FOR i := 1 TO Length(msg) DO
    IF (msg[i] < CHR(32)) THEN msg[i] := CHR(96);
  {$I-}
  WRITELN (debug_file_ptr,
           FormatDateTime ('yyyy-mm-dd@hh:nn:ss', Now), '/',
           debug_idname_list[id]:8, '/', msg, '/');
  {$I+}
  DebugLogFileWrite := IOResult;
  END;  {of function 'DebugFileWrite'}

FUNCTION DebugLogRegister (idname: String): INTEGER;
{Returns a "handle" that the registering unit uses.}
BEGIN
  IF (debug_id_last < (DEBUGLOG_ALL-1))
    THEN BEGIN
      INC (debug_id_last);
      debug_idname_list[debug_id_last] := idname;
      END
    ELSE BEGIN
    {Too many handles requested simply go into an overflow bin}
      debug_idname_list[debug_id_last] := 'OVERFLOW';
      END;
  DebugLogRegister := debug_id_last;
  END;  {of function 'DebugLogRegister'}

FUNCTION DebugLogUnitNameGet (id: INTEGER): String;
VAR name: String;
BEGIN
  IF (id IN [DEBUGLOG_FIRST..DEBUGLOG_ALL])
    THEN name := debug_idname_list[id]  
    ELSE name := 'DebugLogUnitNameGet: ID out-of-range';
  DebugLogUnitNameGet := name;
  END;  {of function 'DebugUnitNameGet'}

{initialization of unit}

Initialization
  
  FOR i := DEBUGLOG_NONE TO DEBUGLOG_ALL DO BEGIN
    debug_enable_list[i] := FALSE;
    debug_idname_list[i] := '--';
    END;

  debug_idname_list[DEBUGLOG_NONE]   := 'NONE';
  debug_idname_list[DEBUGLOG_ALL]    := 'ALL';

  debug_id_last := DEBUGLOG_NONE;
  
{finalization of unit}

Finalization

  DebugLogFileClose;
  
  {of unit 'debuglog'...}
  END.
