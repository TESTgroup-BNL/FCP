Unit Serial;

{
Delphi Pascal 6 driver for Windows COMn: API

John Nagy  B.N.L.  +1-631-344-2667  nagy@bnl.gov

v1.0  2005-12-07  Original
v1.1  2008-04-03  Make LastErrorWindow public
v2.0  2011-02-04  Add function BreakSet
                  Modify function SendBreak to use BreakSet
}

{$R+} {Range checking ON}

Interface

Uses Windows, SysUtils, Forms;

VAR

  LastErrorFunction: STRING;
  LastErrorNumber:   INTEGER;
  LastErrorMessage:  STRING;

FUNCTION ParamsSet (
  handle: THandle;  {Handle of an open COM port}
  speed:  DWORD;    {Number e.g. 38400}
  data:   BYTE;     {Number of databits 4..8}
  par:    STRING;   {'N', 'None', etc.  None Odd Even Mark Space}
  stop:   BYTE      {Number either 1 or 2.  1.5 not supported.}
  ):      BOOLEAN;
FUNCTION TimeoutSet (handle: THandle; ms: INTEGER): BOOLEAN;
FUNCTION Open (
  VAR handle: THandle;
  port:       INTEGER;  {1 for COM1:, etc.}
  speed:      DWORD;
  data:       BYTE;
  par:        STRING;
  stop:       BYTE;
  timeout:    INTEGER
  ):          BOOLEAN;
FUNCTION Close (handle: THandle): BOOLEAN;
FUNCTION SendString (handle: THandle; msg: STRING): BOOLEAN;
FUNCTION DataReady (handle: THandle): BOOLEAN;
FUNCTION ReceiveChar (handle: THandle; VAR c: CHAR): BOOLEAN;
FUNCTION ReceiveString (handle: THandle; VAR s: STRING; term: CHAR): BOOLEAN;
FUNCTION EmptyBufferTx (handle: THandle): BOOLEAN;
FUNCTION EmptyBufferRx (handle: THandle): BOOLEAN;
FUNCTION DTRSet (handle: THandle; state: BOOLEAN): BOOLEAN;
FUNCTION RTSSet (handle: THandle; state: BOOLEAN): BOOLEAN;
FUNCTION DSRGet (handle: THandle): BOOLEAN;
FUNCTION CTSGet (handle: THandle): BOOLEAN;
FUNCTION CDGet  (handle: THandle): BOOLEAN;  {a.k.a RLSD}
FUNCTION RIGet  (handle: THandle): BOOLEAN;
FUNCTION ModemStatus (handle: THandle;
  VAR DSR, CTS, CD, RI: BOOLEAN): BOOLEAN;
FUNCTION BreakSet (handle: THandle; state: BOOLEAN): BOOLEAN;
FUNCTION SendBreak (handle: THandle; ms: INTEGER): BOOLEAN;
PROCEDURE LastErrorWindow (msg: STRING);

{All functions return fSuccess except
 DataReady, DSRGet, CTSGet, CDGet, and RIGet}

Implementation

{----------------------------------------------------------}

PROCEDURE LastErrorProcess (func: STRING; success: BOOLEAN);

{Set LastErrorFunction, ~Number, ~Message at end of each function.
 If last operation was successful, GetLastError will not change,
 that is will retain value from last actual error occurence.
 }

BEGIN

  LastErrorFunction := func;  {Always set}

  IF success
    THEN LastErrorNumber   := 0
    ELSE LastErrorNumber   := Windows.GetLastError;

  LastErrorMessage  := SysUtils.SysErrorMessage(LastErrorNumber);

  END;  {of procedure LastErrorProcess}

{----------------------------------------------------------}

PROCEDURE LastErrorWindow (msg: STRING);

{Communications port error notification window}

CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR title, body: STRING;
BEGIN
  body := msg + nl2;
  body := body + 'Func:   ' + LastErrorFunction + nl2;
  body := body + 'ErrNo:  ' + SysUtils.IntToStr(LastErrorNumber) + nl2;
  body := body + 'ErrMsg: ' + LastErrorMessage;
  CASE LastErrorNumber OF
     2: body := body + nl2 +
       'Generally, port does not exist -- no hardware.';
     5: body := body + nl2 +
       'Generally, port already opened by another application.';
    31: body := body + nl2 +
       'Generally, redirector can not open mapped TCP/IP address/port,' +
       ' or to be taken literally.';
    END; {case}
  title := 'Serial.pas error in function ' + LastErrorFunction;
  Windows.MessageBeep(MB_ICONEXCLAMATION);
  Application.MessageBox (PCHAR(body), PCHAR(title),
    MB_OK OR MB_ICONEXCLAMATION);
  END;  {of procedure LastErrorWindow'}

{----------------------------------------------------------}

{Set the serial communication parameters e.g. 9600,8,N,1
 of an open port}

FUNCTION ParamsSet (
  handle: THandle;  {Handle of an open COM port}
  speed:  DWORD;    {Number e.g. 38400}
  data:   BYTE;     {Number of databits 4..8}
  par:    STRING;   {'N', 'None', etc.  None Odd Even Mark Space}
  stop:   BYTE      {Number either 1 or 2.  1.5 not supported.}
  ):      BOOLEAN;

VAR fSuccess: BOOLEAN;
    vDCB: TDCB;
    parcode, stopcode: BYTE;
    where: STRING;

BEGIN

  where := 'GetCommState';
  fSuccess := Windows.GetCommState (handle, vDCB);

  IF fSuccess THEN WITH vDCB DO BEGIN
    parcode := 0;
    CASE UpCase(par[1]) OF
      'N': parcode := 0; {None}
      'O': parcode := 1; {Odd}
      'E': parcode := 2; {Even}
      'M': parcode := 3; {Mark}
      'S': parcode := 4; {Space}
      END; {parity case}
    stopcode := 0;
    CASE stop OF
      1: stopcode := 0; {1 stop bit}
      2: stopcode := 2; {2 stop bits}
      END; {stop bits case}

    BaudRate := speed;
    ByteSize := data;      {4..8 --> number of bits/byte}
    Parity   := parcode;   {0..4 --> None, Odd, Even, Mark, Space}
    StopBits := stopcode;  {0..2 --> 1, 1.5, 2 stop bits}

    where := 'SetCommState';
    fSuccess := Windows.SetCommState (handle, vDCB);

    END;

  LastErrorProcess ('ParamSet/'+where, fSuccess);
  ParamsSet := fSuccess;
  END; {function ParamsSet}

{----------------------------------------------------------}

{Set timeout for an open COM port.
 Tx and Rx timeouts are the same.}

FUNCTION TimeoutSet (handle: THandle; ms: INTEGER): BOOLEAN;

VAR fSuccess: BOOLEAN;
    vCommTimeouts: TCommTimeouts;
    where: STRING;

BEGIN

  where := 'GetCommTimeouts';
  fSuccess := Windows.GetCommTimeouts (handle, vCommTimeouts);

  IF (fSuccess) THEN WITH vCommTimeouts DO BEGIN
    ReadIntervalTimeout         := MAXDWORD;
    ReadTotalTimeoutMultiplier  := MAXDWORD;
    ReadTotalTimeoutConstant    := ms;
    WriteTotalTimeoutMultiplier := MAXDWORD;
    WriteTotalTimeoutConstant   := ms;

    where := 'SetCommTimeouts';
    fSuccess := Windows.SetCommTimeouts (handle, vCommTimeouts);

    END;

  LastErrorProcess ('TimeoutSet/'+where, fSuccess);
  TimeoutSet := fSuccess;
  END; {function TimeoutSet}

{----------------------------------------------------------}

{Open serial communications port.}
 

FUNCTION Open (
  VAR handle: THandle;
  port:       INTEGER;  {1 for COM1, etc.}
  speed:      DWORD;
  data:       BYTE;
  par:        STRING;
  stop:       BYTE;
  timeout:    INTEGER
  ):          BOOLEAN;

VAR fSuccess: BOOLEAN;
    name: STRING;

BEGIN

  name := '\\.\COM' + IntToStr(port);
  handle := Windows.CreateFile (
              PChar(name),                    {lpFileName}
              GENERIC_READ OR GENERIC_WRITE,  {dwDesiredAccess}
              0,                              {dwShareMode}
              NIL,                            {lpSecurityAttributes}
              OPEN_EXISTING,                  {dwCreationDisposition}
              0,                              {dwFlagsAndAttributes}
              0);                             {hTemplateFile}

  fSuccess := (handle <> INVALID_HANDLE_VALUE);

  IF fSuccess THEN
    fSuccess := ParamsSet (handle, speed, data, par, stop);

  IF fSuccess THEN
    fSuccess := TimeoutSet (handle, timeout);

  LastErrorProcess ('Open '+name, fSuccess);
  Open := fSuccess;
  END; {function Open}

{----------------------------------------------------------}

FUNCTION Close (handle: THandle): BOOLEAN;
VAR fSuccess: BOOLEAN;
BEGIN
  fSuccess := Windows.CloseHandle (handle);
  LastErrorProcess ('Close', fSuccess);
  Close := fSuccess;
  END;  {procedure Close}

{----------------------------------------------------------}

{Flush system output buffer}

FUNCTION EmptyBufferTx (handle: THandle): BOOLEAN;
VAR fSuccess: BOOLEAN;
BEGIN
  fSuccess :=
    Windows.PurgeComm (handle, PURGE_TXABORT OR PURGE_TXCLEAR);
  LastErrorProcess ('EmptyBufferTx', fSuccess);
  EmptyBufferTx := fSuccess;
  END;  {procedure EmptyBufferTx}

{----------------------------------------------------------}

{Flush system input buffer}

FUNCTION EmptyBufferRx (handle: THandle): BOOLEAN;
VAR fSuccess: BOOLEAN;
BEGIN
  fSuccess :=
   Windows.PurgeComm (handle, PURGE_RXABORT OR PURGE_RXCLEAR);
  LastErrorProcess ('EmptyBufferRx', fSuccess);
  EmptyBufferRx := fSuccess;
  END;  {procedure EmptyBufferRx}

{----------------------------------------------------------}

FUNCTION SendString (handle: THandle; msg: STRING): BOOLEAN;

VAR s: ARRAY[0..2047] OF CHAR;
    slenout, slenin:  DWORD;
    i: INTEGER;
    fSuccess: BOOLEAN;

BEGIN

  slenout := Length(msg);
  FOR i := 1 TO slenout DO s[i-1] := msg[i];
  fSuccess := Windows.WriteFile (handle, s, slenout, slenin, NIL);

  LastErrorProcess ('SendString/WriteFile', fSuccess);

  IF (slenin <> slenout) THEN BEGIN
    LastErrorMessage := 'Some or all of string not sent';
    fSuccess := FALSE;
    END;

  SendString := fSuccess;
  END;  {procedure SendString}

{----------------------------------------------------------}

FUNCTION DataReady (handle: THandle): BOOLEAN;
{Returns TRUE if input buffer for com port not empty.
 Note this routine does NOT return fSuccess.
 }
VAR dw_dummy: DWORD;
    vComStat: TComStat;
    temp    : BOOLEAN;
    fSuccess: BOOLEAN;
BEGIN
  fSuccess := Windows.ClearCommError (handle, dw_dummy, @vComStat);
  temp := FALSE;
  IF (fSuccess) THEN temp := (vComStat.cbInQue > 0);
  LastErrorProcess ('DataReady', fSuccess);
  DataReady := temp;
  END;  {of function DataReady}

{----------------------------------------------------------}

FUNCTION ReceiveChar (handle: THandle; VAR c: CHAR): BOOLEAN;

VAR t: ARRAY[0..2047] OF CHAR;
    slenin: DWORD;
    fSuccess: BOOLEAN;

BEGIN

  c := CHR(0);
  fSuccess := Windows.ReadFile (handle, t, 1, slenin, NIL);
  IF fSuccess THEN c := t[0];

  LastErrorProcess ('ReceiveChar/ReadFile', fSuccess);

  IF (slenin = 0) THEN BEGIN
    LastErrorMessage := 'No character received -- timed out';
    fSuccess := FALSE;
    END;

  ReceiveChar := fSuccess;
  END;  {function ReceiveChar}

{----------------------------------------------------------}

FUNCTION ReceiveString (handle: THandle; VAR s: STRING; term: CHAR): BOOLEAN;
{If terminating character is not received, function will time out.
 Terminating character IS returned with string.
 }

VAR c: CHAR;
    fSuccess: BOOLEAN;

BEGIN

  s := '';

  REPEAT
    fSuccess := ReceiveChar (handle, c);
    IF fSuccess THEN s := s + c;
    UNTIL (NOT fSuccess) OR (c = term);

  ReceiveString := fSuccess;
  END;  {function ReceiveString}

{----------------------------------------------------------}

FUNCTION DTRSet (handle: THandle; state: BOOLEAN): BOOLEAN;
VAR macro: DWORD;
    fSuccess: BOOLEAN;
BEGIN
  IF state THEN macro := SETDTR ELSE macro := CLRDTR;
  fSuccess := Windows.EscapeCommFunction (handle, macro);
  LastErrorProcess ('DTRSet', fSuccess);
  DTRSet := fSuccess;
  END;  {procedure DTRSet}

{----------------------------------------------------------}

FUNCTION RTSSet (handle: THandle; state: BOOLEAN): BOOLEAN;
VAR macro: DWORD;
    fSuccess: BOOLEAN;
BEGIN
  IF state THEN macro := SETRTS ELSE macro := CLRRTS;
  fSuccess := Windows.EscapeCommFunction (handle, macro);
  LastErrorProcess ('RTSSet', fSuccess);
  RTSSet := fSuccess;
  END;  {procedure RTSSet}

{----------------------------------------------------------}

FUNCTION DSRGet (handle: THandle): BOOLEAN;
{Returns TRUE if DSR (Data Set Ready) is ON.
 Note this routine does NOT return fSuccess.
 }
VAR vModemStat: DWORD;
    temp    : BOOLEAN;
    fSuccess: BOOLEAN;
BEGIN
  fSuccess := Windows.GetCommModemStatus (handle, vModemStat);
  temp := FALSE;
  IF (fSuccess) THEN temp := ((vModemStat And MS_DSR_ON) <> 0);
  LastErrorProcess ('DSRGet', fSuccess);
  DSRGet := temp;
  END;  {of function DSRGet}

{----------------------------------------------------------}

FUNCTION CTSGet (handle: THandle): BOOLEAN;
{Returns TRUE if CTS (Clear To Send) is ON.
 Note this routine does NOT return fSuccess.
 }
VAR vModemStat: DWORD;
    temp    : BOOLEAN;
    fSuccess: BOOLEAN;
BEGIN
  fSuccess := Windows.GetCommModemStatus (handle, vModemStat);
  temp := FALSE;
  IF (fSuccess) THEN temp := ((vModemStat And MS_CTS_ON) <> 0);
  LastErrorProcess ('CTSGet', fSuccess);
  CTSGet := temp;
  END;  {of function CTSGet}

{----------------------------------------------------------}

FUNCTION CDGet (handle: THandle): BOOLEAN;
{Returns TRUE if RLSD (Receive Line Signal Detect) is ON.
 RLSD is also known as CD (Carrier Detect).
 Note this routine does NOT return fSuccess.
 }
VAR vModemStat: DWORD;
    temp    : BOOLEAN;
    fSuccess: BOOLEAN;
BEGIN
  fSuccess := Windows.GetCommModemStatus (handle, vModemStat);
  temp := FALSE;
  IF (fSuccess) THEN temp := ((vModemStat And MS_RLSD_ON) <> 0);
  LastErrorProcess ('CDGet', fSuccess);
  CDGet := temp;
  END;  {of function CDGet}

{----------------------------------------------------------}

FUNCTION RIGet (handle: THandle): BOOLEAN;
{Returns TRUE if RI (Ring Indicator) is ON.
 Note this routine does NOT return fSuccess.
 }
VAR vModemStat: DWORD;
    temp    : BOOLEAN;
    fSuccess: BOOLEAN;
BEGIN
  fSuccess := Windows.GetCommModemStatus (handle, vModemStat);
  temp := FALSE;
  IF (fSuccess) THEN temp := ((vModemStat And MS_RING_ON) <> 0);
  LastErrorProcess ('RIGet', fSuccess);
  RIGet := temp;
  END;  {of function RIGet}

{----------------------------------------------------------}

FUNCTION ModemStatus (handle: THandle;
  VAR DSR, CTS, CD, RI: BOOLEAN): BOOLEAN;
{Returns state of all 4 modem control lines as booleans.
 }
VAR vModemStat: DWORD;
    fSuccess: BOOLEAN;
BEGIN
  fSuccess := Windows.GetCommModemStatus (handle, vModemStat);
  IF (fSuccess)
    THEN BEGIN
      DSR := ((vModemStat And MS_DSR_ON)  <> 0);
      CTS := ((vModemStat And MS_CTS_ON)  <> 0);
      CD  := ((vModemStat And MS_RLSD_ON) <> 0);
      RI  := ((vModemStat And MS_RING_ON) <> 0);
      END
    ELSE BEGIN
      DSR := FALSE;
      CTS := FALSE;
      CD  := FALSE;
      RI  := FALSE;
      END;
  LastErrorProcess ('ModemStatus', fSuccess);
  ModemStatus := fSuccess;
  END;  {of function ModemStatus}

{----------------------------------------------------------}

FUNCTION BreakSet (handle: THandle; state: BOOLEAN): BOOLEAN;
VAR macro: DWORD;
    fSuccess: BOOLEAN;
    what: STRING;
BEGIN
  IF state
    THEN BEGIN
      macro := SETBREAK;
      what := 'SETBREAK';
      END
    ELSE BEGIN
      macro := CLRBREAK;
      what := 'CLRBREAK';
      END;
  fSuccess := Windows.EscapeCommFunction (handle, macro);
  LastErrorProcess ('BreakSet '+what, fSuccess);
  BreakSet := fSuccess;
  END;  {procedure BreakSet}

{----------------------------------------------------------}

FUNCTION SendBreak (handle: THandle; ms: INTEGER): BOOLEAN;
{Encapsulates break set and clear separated by blocking timer}
VAR fSuccess: BOOLEAN;
    where: STRING;
BEGIN
  where := 'SET';
  fSuccess := BreakSet (handle, TRUE);
  IF fSuccess THEN BEGIN
    Windows.Sleep (ms);
    where := 'CLR';
    fSuccess := BreakSet (handle, FALSE);
    END;
  LastErrorProcess ('SendBreak '+where, fSuccess);
  SendBreak := fSuccess;
  END;  {procedure SendBreak}

{----------------------------------------------------------}

{of unit Serial.pas...}
END.
