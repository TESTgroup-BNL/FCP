UNIT EventLog;

{

Provide FCP with hook into Window's Application Event Log

John Nagy

v1.0  2006-09-22  Original
v1.1  2006-09-23  Add no imbedded multiport message, if so
                  Add cfg file name to 50002+ rawdata
                  Add EventID 50005 for FatalErr     

}

INTERFACE

PROCEDURE AppEvLog (id: INTEGER);

IMPLEMENTATION

USES Globals, SysUtils, Windows;

PROCEDURE AppEvLog (id: INTEGER);

VAR h:        THANDLE;
    source,
    rawdata,
    mystring: String;

PROCEDURE add_to_rawdata (fileinfo: TSearchRec);
VAR filedt: TDateTime;
BEGIN
  WITH fileinfo DO BEGIN
    rawdata := rawdata + Name;
    WHILE ((Length(rawdata) MOD 8) <> 0) DO rawdata := rawdata+' ';
    filedt := SysUtils.FileDateToDateTime (Time);
    DateTimeToString (mystring, 'YYYYMMDD', filedt);
    rawdata := rawdata + mystring;
    WHILE ((Length(rawdata) MOD 8) <> 0) DO rawdata := rawdata+' ';
    DateTimeToString (mystring, 'HH:NN:SS', filedt);
    rawdata := rawdata + mystring;
    WHILE ((Length(rawdata) MOD 8) <> 0) DO rawdata := rawdata+' ';
    Str (Size:1, mystring);
    rawdata := rawdata + mystring;
    WHILE ((Length(rawdata) MOD 8) <> 0) DO rawdata := rawdata+' ';
    END;
  END;  {of local procedure 'add_to_rawdata'}

BEGIN

  source  := 'FCP ' + CHR(0);

  rawdata := 'Unsup-  ported  EventID';

  CASE id OF

    50000: BEGIN  {FCP starting}
      rawdata := 'Starting';
      END;

    50001: BEGIN  {FCP file information}
      rawdata := '';
      add_to_rawdata (Globals.searchrec_exe);
      add_to_rawdata (Globals.searchrec_cfg);
      IF (Globals.searchrec_def.Name <> '')
        THEN add_to_rawdata (Globals.searchrec_def)
        ELSE rawdata := rawdata + 'No MP   Sampler';
      END;

    50002: BEGIN  {FCP Shutting down}
      rawdata := 'Shuttingdown    ' + Globals.searchrec_cfg.Name;
      END;

    50003: BEGIN  {FCP Shutdown aborted}
      rawdata := 'Shutdownaborted ' + Globals.searchrec_cfg.Name;
      END;

    50004: BEGIN  {FCP stopping}
      rawdata := 'Stopping' + Globals.searchrec_cfg.Name;
      END;

    50005: BEGIN  {FCP FatalErr.Msg called}
      rawdata := 'FatalErrcalled  ' + IntToHex (GetLastError, 8)
                                    + Globals.searchrec_cfg.Name;                                    ;
      WHILE ((Length(rawdata) MOD 8) <> 0) DO rawdata := rawdata+' ';
      IF (GetLastError < $20000000) THEN
        rawdata := rawdata + SysUtils.SysErrorMessage (GetLastError);
      END;

    END; {case}

  h := RegisterEventSource (NIL, PCHAR(source));

  ReportEvent (
    h,                          {hEventLog}
    EVENTLOG_INFORMATION_TYPE,  {wType}
    0,                          {wCategory}
    id,                         {dwEventID}
    NIL,                        {lpUserSid}
    0,                          {wNumStrings}
    Length(rawdata),            {dwDataSize}
    NIL,                        {lpStrings}
    PCHAR(rawdata));            {lpRawData}

  DeregisterEventSource (h);

  {of procedure AppEvLog}
  END;

{of unit EventLog}
END.
