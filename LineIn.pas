UNIT LineIn;

{$R+} {Range checking on}
{

Generic class for FCP to read and parse
ASCII lines using DataCommn module

Example:  VAR objLineIn_1: clsLineIn;
          objLineIn_1 := clsLineIn.Create;

John Nagy  B.N.L.  nagyjohn43@gmail.com

v1.0  2011-11-02  Original for LI840A and WMT701
v1.1  2011-11-16  Some code cleanup; more debug output
v1.2  2011-12-01  Add CSI1 (UWS CR3000)
v1.3  2012-07-03  Add IPSERV protocol
                  Command hardcoded as '000'
                  Therefore useful only querying single-plot FCP instances
v1.4  2012-07-25  OutputLastError: support for FileRec (switch=3)
                  OutputDebug: changed from PRIVATE to PUBLIC
v1.5  2012-07-30  Change DataGet to ValueGet
                  Change FData to FValue
      2012-07-31  Add field FToken array
                  Add method TokenGet
                  Add code for protocol FCPLINK
      2012-08-02  Add field FUpdateTest to be used with FCPLink protocol
                  Add code to detect non-updating FCP link file
v1.6  2012-09-16  Process: add diagnostics around the UDP PortClose
v1.7  2012-09-18  Process/FCPLINK: clear resp1 before read
                                   test for null string after read
v2.0  2016-07-07  Process: Add more OutputDebug lines to better bracket whole transactions
v2.1  2016-07-09  Process: Corrections -- FALSE) should be TRUE)  (9x)
v2.2  2016-07-28  Process: in OutputDebug calls replace nn: by hh:nn:  (9x)
v2.3  2016-07-30  Process: still more time stamps

Data arrays by protocol...

LI820

 [0] Cell temperature (oC)
 [1] Cell pressure (kPa)
 [2] [CO2] (umol/mol fraction)
 [3] IVOLT

LI840

 [0] Cell temperature (oC)
 [1] Cell pressure (kPa)
 [2] [CO2] (umol/mol fraction)
 [3] IVOLT
 [4] [H2O] (mmol/mol)
 [5] Dewpoint (oC)
 [6] [CO2] (umol/mol dry air ratio)
 [7] pH2O computed from mmol/mol, P (Pa)
 [8] pH2O computed from Tdp and LI-610 manual formula (Pa)

WMT700 25

 [0] Wind speed average
 [1] Wind direction average
 [2] Wind speed peak
 [3] Wind speed maximum
 [4] Sonic temperature
 [5] Status code

CSI1 (temporary emulation for testing)

 [0] Battery voltage
 [1] Panel temperature
 [2] Slow sequence counter
 [3] Air temperature faked
 [4] PAR faked

IPSERV (FCP IPServ.pas service providing variables upon request)

 Dozens of fields
 See current IPServ.pas comments for list

FCPLink (Get output from FCP/comp/multiport data link procedure)

 [ 0] File
 [ 1] Date
 [ 2] Time
 [ 3] Plot label ('1'..'F')
 [ 4] Gas concentration average
 [ 5] Wind speed average
 [ 6] Wind direction average
 [ 7] pH2O grab
 [ 8] Proportional valve response grab
 [ 9] Gas concentration set point
 [10] Gas concentration grab -- control plot
 [11] Gas concentration grab -- ambient plot
 [12] Ambient base concentration integral
 [13] Latched status as hexadecimal

}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QGraphics, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics, StdCtrls,
{$ENDIF}
  SysUtils, Windows, Classes; {provided by Borland}

{++++++++++++++++++++ LineIn declarations ++++++++++++++++++++}

{If a form is ever added, it will be declared here}

CONST maxdata = 64; {maximum number of indices in data array}

TYPE clsLineIn = CLASS (TObject)
  PRIVATE
    FDebugMemo:   TMemo;
    FDebugEnable: BOOLEAN;
    FDebugPause:  BOOLEAN;
    FTermOut:     STRING;
    FTermIn:      CHAR;
    FToken:       Array [0..maxdata-1] OF STRING;
    FValue:       Array [0..maxdata-1] OF REAL;
    FUpdateTest:  STRING;
    PROCEDURE OutputLastError (vp: INTEGER);
  PUBLIC
    CONSTRUCTOR Create;
    PROCEDURE DebugMemoSet   (memo: TMemo);
    PROCEDURE DebugEnableSet (enableit: BOOLEAN);
    PROCEDURE DebugPauseSet  (pauseit: BOOLEAN);
    PROCEDURE OutputDebug (vp: INTEGER; msg: STRING; fSuccess: BOOLEAN);
    FUNCTION  Process        (vp: INTEGER): BOOLEAN;
    FUNCTION  ValueGet       (index: INTEGER): REAL;
    FUNCTION  TokenGet       (index: INTEGER): STRING;
  END;

IMPLEMENTATION

Uses DataComm, Serial, Socket;  {Provided by J.N.}

{++++++++++++++++++++ LineIn object ++++++++++++++++++++}

CONSTRUCTOR clsLineIn.Create;
VAR i: INTEGER;
BEGIN
  INHERITED Create;
  FOR i := 0 TO maxdata-1 DO FToken[i] := '*9991'; {create initialization}
  FOR i := 0 TO maxdata-1 DO FValue[i] :=   9991;
  END;  {constructor Create}

{--------------------------------------------------------------}

PROCEDURE clsLineIn.DebugMemoSet   (memo: TMemo);
BEGIN
  FDebugMemo := memo;
  END;

PROCEDURE clsLineIn.DebugEnableSet (enableit: BOOLEAN);
BEGIN
  FDebugEnable := enableit;
  END;

PROCEDURE clsLineIn.DebugPauseSet  (pauseit: BOOLEAN);
BEGIN
  FDebugPause := pauseit;
  END;

{--------------------------------------------------------------}

PROCEDURE clsLineIn.OutputLastError (vp: INTEGER);
VAR s: STRING;
BEGIN
  WITH DataComm.Ports[vp] DO BEGIN
    CASE switch OF

      0: BEGIN
        s := Serial.LastErrorFunction + ': ' +
             IntToStr(Serial.LastErrorNumber) + ' ' +
             Serial.LastErrorMessage;
        END;

      1: BEGIN
        END;

      2: BEGIN
        s := Socket.LastErrorFunction + ': ' +
             IntToStr(Socket.LastErrorNumber) + ' ' +
             Socket.LastErrorMessage;
        END;

      3: BEGIN
        s := 'ERROR ' + IntToStr(LastErrNo) + ' ' + LastErrMsg;
        END;

      END; {case}
    END;
  FDebugMemo.Lines.Add ('!!!' + s);
  END;  {procedure OutputLastError}

{--------------------------------------------------------------}

PROCEDURE clsLineIn.OutputDebug (vp: INTEGER; msg: STRING; fSuccess: BOOLEAN);
BEGIN
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN BEGIN
    FDebugMemo.Lines.Add (msg);
    IF (NOT fSuccess) THEN OutputLastError (vp);
    END;
  END;  {procedure OutputDebug}

{--------------------------------------------------------------}

FUNCTION clsLineIn.Process (vp: INTEGER): BOOLEAN;
{Call to Talk with virtual port specific parameters and protocol.
}
VAR fSuccess: BOOLEAN;
    command,
    response: STRING;
    i, n:     INTEGER;
    ts:       TStringList;

    {Used by protocol LI8x0}
    sbegin,
    send:     STRING;

    {Used by protocol FCPLink}
    resp1,
    resp2:    STRING;
    found:    BOOLEAN;

BEGIN

  fSuccess := TRUE;
  response := '';

  WITH DataComm.Ports[vp] DO BEGIN

{Communications section}

  {If this is UDP/IP, the socket must be opened (and closed below)}
  IF (switch = 2) AND (IPRec.mode = 'UDP') THEN BEGIN
    OutputDebug (vp, 'Begin UDP_OPEN for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    fSuccess := PortOpen (vp);
    OutputDebug (vp, 'UDP_OPEN...', fSuccess);
    END;

  IF (UpperCase(protocol) = 'LI820') OR
     (UpperCase(protocol) = 'LI840') OR
     (UpperCase(protocol) = 'LI850') THEN BEGIN
    FTermOut := CHR(10);
    FTermIn  := CHR(10);
    IF (UpperCase(protocol) = 'LI820') THEN BEGIN
      sbegin :=   '<LI820>';
      send   :=  '</LI820>';
      END;
    IF (UpperCase(protocol) = 'LI840') THEN BEGIN
      sbegin :=   '<LI840>';
      send   :=  '</LI840>';
      END;
	IF (UpperCase(protocol) = 'LI850') THEN BEGIN
      sbegin :=   '<LI850>';
      send   :=  '</LI850>';
      END;
    OutputDebug (vp, 'Transaction for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    command  := sbegin + '<DATA>?</DATA>' + send + FTermOut;
    fSuccess := PortSend (vp, command);
    OutputDebug (vp, '-->' + command, fSuccess);
    fSuccess := PortRecv (vp, response, FTermIn);
    OutputDebug (vp, '<--' + response, fSuccess);
    response := response + CHR(0);
    END;

  IF (UpperCase(protocol) = 'WMT700') THEN BEGIN
    FTermOut := CHR(13) + CHR(10);
    FTermIn  := CHR(10);
    OutputDebug (vp, 'Transaction for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    command  := ' $0POLL,25';
    fSuccess := PortSend (vp, command + FTermOut);
    OutputDebug (vp, '-->' + command, fSuccess);
    fSuccess := PortRecv (vp, response, FTermIn);
    OutputDebug (vp, '<--' + response, fSuccess);
    response := response + CHR(0);
    END;

  IF (UpperCase(protocol) = 'CSI1') THEN BEGIN
    FTermOut := CHR(13);
    FTermIn  := CHR(10);
    OutputDebug (vp, 'Transaction for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    command  := 'CSI1';
    fSuccess := PortSend (vp, command + FTermOut);
    OutputDebug (vp, '-->' + command, fSuccess);
    fSuccess := PortRecv (vp, response, FTermIn);
    OutputDebug (vp, '<--' + response, fSuccess);
    response := response + CHR(0);
    END;

  IF (UpperCase(protocol) = 'IPSERV') THEN BEGIN
    FTermOut := '';             {IPServ ignores terminations}
    FTermIn  := CHR(10);
    OutputDebug (vp, 'Transaction for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    command  := '000';
    fSuccess := PortSend (vp, command + FTermOut);
    OutputDebug (vp, '-->' + command, fSuccess);
    fSuccess := PortRecv (vp, response, FTermIn);
    OutputDebug (vp, '<--' + response, fSuccess);
    response := response + CHR(0);
    END;

  IF (UpperCase(protocol) = 'FCPLINK') THEN BEGIN
    FTermOut := '';             {None of these used for text file io}
    FTermIn  := CHR(0);
    command  := '';

    {Open file}
    OutputDebug (vp, 'Begin transaction for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    fSuccess := PortOpen (vp);
    OutputDebug (vp, 'PortOpen', fSuccess);

    IF fSuccess THEN BEGIN

      {Check for empty file}
      fSuccess := NOT EOF (FileRec.handle);
      IF NOT fSuccess THEN BEGIN
        LastErrNo := 8881;
        LastErrMsg := 'FCP link file empty';
        OutputDebug (vp, 'Empty file check', fSuccess);
        END

      ELSE BEGIN
        {Get first line}
        resp1 := '';
        fSuccess := PortRecv (vp, resp1, FTermIn);
        OutputDebug (vp, 'PortRecv ' + resp1, fSuccess);

        IF fSuccess THEN BEGIN
          fSuccess := (resp1 <> '');
          IF NOT fSuccess THEN BEGIN
            LastErrNo := 8882;
            LastErrMsg := 'FCP link first line is empty';
            OutputDebug (vp, 'Empty line check', fSuccess);
            END;
          END;

        {Make sure file is updating}
        IF fSuccess THEN BEGIN
          fSuccess := (resp1 <> FUpdateTest);
          IF NOT fSuccess THEN BEGIN
            LastErrNo := 8883;
            LastErrMsg := 'FCP link file not updated';
            OutputDebug (vp, 'Update check', fSuccess);
            END;
          FUpdateTest := resp1;
          END;

        {Loop over other lines}
        IF fSuccess THEN BEGIN
          found := FALSE;
          WHILE (NOT EOF (FileRec.Handle)) AND
                (NOT found)                AND
                fSuccess                   DO BEGIN
            fSuccess := PortRecv (vp, resp2, FTermIn);
            OutputDebug (vp, 'PortRecv ' + resp2, fSuccess);
            found := (StrToInt('$'+resp2[1]) = FileRec.param2);
            END;
          fSuccess := found;
          IF (NOT fSuccess) THEN BEGIN
            LastErrNo := 8884;
            LastErrMsg := 'Data for requested plot not found';
            END;
          OutputDebug (vp, 'End of looping', fSuccess);
          END;  {file is up to date}

        END;  {getting first line}

      END;  {file not empty}

    response := resp1 + ',' + resp2 + CHR(0);
    OutputDebug (vp, 'PortClose', TRUE);
    PortClose (vp);
    OutputDebug (vp, 'End   transaction for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    END;  {this protocol}

  {Close port if UDP}
  IF (switch = 2) AND (IPRec.mode = 'UDP') THEN BEGIN
    OutputDebug (vp,
      'UDP closing...' + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    fSuccess := PortClose (vp);
    OutputDebug (vp,
      'UDP closing finished -' + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    OutputDebug (vp, 'End UDP_CLOSE for virtual port ' + IntToStr(vp) + FormatDateTime(' hh:nn:ss.zzz',Time), TRUE);
    END;

{Parsing section}

  FOR i := 0 TO maxdata-1 DO FToken[i] := '*9992'; {process initialization}
  FOR i := 0 TO maxdata-1 DO FValue[i] :=   9992;

  IF fSuccess THEN BEGIN

  ts := TStringList.Create;
  n := ExtractStrings ([CHR(32),','], ['$'], PCHAR(@response[1]), ts);
  IF n > maxdata THEN n := maxdata;

  FOR i := 0 TO n-1 DO BEGIN
    TRY
        FToken[i] := ts.Strings[i];
        FValue[i] := StrToFloat (FToken[i]);
      EXCEPT
        FValue[i] := 9993;  {StrToFloat error}
      END;
    IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
      FDebugMemo.Lines.Add
        ('[' + IntToStr(i) + '] ' + FToken[i] + ' ' +
         FloatToStr(FValue[i]));
    END;
  ts.Free;

{Device specific adjustments}

  {LI-820}
  {none}

  {LI-840A}
  IF (UpperCase(protocol) = 'LI840') OR
     (UpperCase(protocol) = 'LI850') THEN BEGIN
    {CO2 mixing ratio in dry air}
    {Water vapor pressue derived from mixing fraction and total pressure}
    {Water vapor pressue derived from dewpoint and LI-610 formula}
    FValue[6] := FValue[2] * (1/(1-0.001*FValue[4]));
    FValue[7] := FValue[4] * FValue[1];
    FValue[8] := 613.65 * EXP ( (17.502*FValue[5]) / (240.97 + FValue[5]) );
    IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    FOR i := 6 TO 8 DO
      FDebugMemo.Lines.Add
        ('[' + IntToStr(i) + '] ---------- ' + FloatToStr(FValue[i]));
    END;

  {WMT-701}
  {none}

  {CR1000, CR3000}
  {none}

  {IPSERV}
  {none}

  {FCPLink}
  {none}

  END;  {success parsing}

  END;  {with}
  Process := fSuccess;
  END;  {function Process}

{--------------------------------------------------------------}

FUNCTION clsLineIn.TokenGet (index: INTEGER): STRING;
BEGIN
  IF index IN [0..(maxdata-1)]
    THEN TokenGet := FToken[index]
    ELSE TokenGet := '*9994';  {requested index out of range}
  END;  {function TokenGet}

{--------------------------------------------------------------}

FUNCTION clsLineIn.ValueGet (index: INTEGER): REAL;
BEGIN
  IF index IN [0..(maxdata-1)]
    THEN ValueGet := FValue[index]
    ELSE ValueGet := 9994;  {requested index out of range}
  END;  {function ValueGet}

{+++++++++++++++++ end of LineIn object ++++++++++++++++++++++}

{----------------- end of unit LineIn ------------------------}

END.
