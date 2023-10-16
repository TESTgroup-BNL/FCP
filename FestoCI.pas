UNIT FestoCI;
{$R+} {Range checking on}
{
Festo CPX FEC Command Interpreter (CI) class

Example:  VAR objFestoCI_1: clsFestoCI;
          objFestoCI_1 := clsFestoCI.Create;

John Nagy  B.N.L.  nagy@bnl.gov

v1.0  2011-05-03  First version ready for use, including primitives
                  Setup, Open, Logon, Close, Send, Receive, Talk

v1.1  2011-05-08  Add higher level methods
                  FEWrite, DOWrite, DORead, DIRead, AIRead
                  Add detection of En:<text> errors

v2.0  2011-09-13  v1.x were for the CEC controller
                  v2 is for the FEC controller
                  All higher order methods are replaced by [Bit|Word][Read|Write]()
                  Operands of type output, input, and flag are supported
                  Not paying attention to TCP mode working correctly
                  No logon support -- Logon() has been deleted
                  Festo's error response now merely ACCESS ERROR

v2.1  2011-09-29  FDebugMemo, FDebugEnable, FDebugPause: fields added
                  DebugMemoSet(), DebugEnableSet(), DebugPauseSet(): new
                  Send, Receive: debugging (raw traffic) code added

v2.2  2011-11-02  Open, Close: add debugging output
v2.3  2012-01-17  Receive: some additional IF fSuccess THEN nesting required

v2.4  2016-07-30  Add timestamp to OPEN... CLOSE... debugging messages
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QGraphics, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics, StdCtrls,
{$ENDIF}
  SysUtils, WinSock, Windows, {provided by Borland}
  Socket;                     {provided by J.N.}

{++++++++++++++++++++ FestoCI declarations ++++++++++++++++++++}

{If a form is ever added, it will be declared here}

TYPE clsFestoCI = CLASS (TObject)
  PRIVATE
    FName:    STRING;   {Only for unique identification in displays}
    FHandle:  INTEGER;
    FMode:    STRING;
    FIP:      STRING;
    FRPort:   INTEGER;
    FLPort:   INTEGER;
    FRaddr:   sockaddr_in;
    FTimeout: INTEGER;  {ms; JN algorithm, not setsockopt}
    FTerm:    STRING;   {command termination -- see Setup}
    FDebugMemo:   TMemo;
    FDebugEnable: BOOLEAN;
    FDebugPause:  BOOLEAN;
    PROCEDURE LastErrorProcess (func: STRING; errnumber: INTEGER);
  PUBLIC
    LastCommand,
    LastResponse:      STRING;
    LastErrorFunction: STRING;
    LastErrorNumber:   INTEGER;
    LastErrorMessage:  STRING;
    PROCEDURE LastErrorWindow (msg: STRING);
    CONSTRUCTOR Create;
    PROCEDURE Setup (name, mode, IP: STRING; rport, lport, timeout: INTEGER);
    PROCEDURE DebugMemoSet   (memo: TMemo);
    PROCEDURE DebugEnableSet (enableit: BOOLEAN);
    PROCEDURE DebugPauseSet  (pauseit: BOOLEAN);
    FUNCTION Open: BOOLEAN;
    FUNCTION Close: BOOLEAN;
    FUNCTION Send (s: STRING): BOOLEAN;
    FUNCTION Receive (VAR s: STRING): BOOLEAN;
    FUNCTION Talk (s: STRING; VAR t: String): BOOLEAN;
    FUNCTION BitRead (aef: CHAR; VAR b: BOOLEAN; addr, chan: INTEGER): BOOLEAN;
    FUNCTION WordRead (aef: CHAR; VAR i: INTEGER; addr: INTEGER): BOOLEAN;
    FUNCTION BitWrite (aef: CHAR; b: BOOLEAN; addr, chan: INTEGER): BOOLEAN;
    FUNCTION WordWrite (aef: CHAR; i: INTEGER; addr: INTEGER): BOOLEAN;
  END;

IMPLEMENTATION

{++++++++++++++++++++ FestoCI object ++++++++++++++++++++}

PROCEDURE clsFestoCI.LastErrorProcess (func: STRING; errnumber: INTEGER);
CONST nl = CHR(13)+CHR(10);

{If there was an error,
 set LastErrorFunction, ~Number, ~Message.
 }

BEGIN
  IF (errnumber <> 0) THEN BEGIN
    LastErrorFunction := func;
    LastErrorNumber   := errnumber;
    CASE errnumber OF
      1: LastErrorMessage :=
           'Socket error-- ' + nl +
            Socket.LastErrorFunction + nl +
            IntToStr(Socket.LastErrorNumber) + nl +
            Socket.LastErrorMessage;
      2: LastErrorMessage := 'Receive time out';
      3: LastErrorMessage := 'OK not returned after a set command';
      4: LastErrorMessage := '= not returned after a get command';
      5: LastErrorMessage := 'ERR contained in last response';
      6: LastErrorMessage := 'Incorrect number of fields returned';
      7: LastErrorMessage := 'StrToInt error';
      8: LastErrorMessage := 'Target type not ''A'', ''E'', or ''M''';
    ELSE LastErrorMessage := 'No text assigned to this error number!';
      END; {case}
    END;
  END;  {of procedure LastErrorProcess}

{----------------------------------------------------------}

PROCEDURE clsFestoCI.LastErrorWindow (msg: STRING);

{FestoCI class error notification window}

CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR title, body: STRING;
BEGIN
  body := msg + nl2;
  body := body + 'Func:   ' + LastErrorFunction + nl2;
  body := body + 'ErrNo:  ' + SysUtils.IntToStr(LastErrorNumber) + nl2;
  body := body + 'ErrMsg: ' + LastErrorMessage;
  title := 'FestoCI.pas error in function ' + LastErrorFunction;
  Windows.MessageBeep(MB_ICONEXCLAMATION);
  Application.MessageBox (PCHAR(body), PCHAR(title),
    MB_OK OR MB_ICONEXCLAMATION);
  END;  {of procedure LastErrorWindow'}

{----------------------------------------------------------}

CONSTRUCTOR clsFestoCI.Create;
BEGIN
  INHERITED Create;
  END;  {constructor Create}

{--------------------------------------------------------------}

PROCEDURE clsFestoCI.DebugMemoSet   (memo: TMemo);
BEGIN
  FDebugMemo := memo;
  END;

PROCEDURE clsFestoCI.DebugEnableSet (enableit: BOOLEAN);
BEGIN
  FDebugEnable := enableit;
  END;

PROCEDURE clsFestoCI.DebugPauseSet  (pauseit: BOOLEAN);
BEGIN
  FDebugPause := pauseit;
  END;

{--------------------------------------------------------------}

PROCEDURE clsFestoCI.Setup (name, mode, IP: STRING; rport, lport, timeout: INTEGER);
{Load IP information into private fields.
 Generally will be called only once when the object is created.
 }
BEGIN
  FName    := name;
  FMode    := mode;
  FIP      := IP;
  FRPort   := rport;
  IF (UpperCase(mode) = 'TCP') THEN FLPort := 0 ELSE
  FLPort   := lport;
  FTimeout := timeout;  {J.N.'s}
  IF (mode = 'TCP') THEN FTerm := '' + CHR(13);
  IF (mode = 'UDP') THEN FTerm := '';
  END;  {procedure Setup}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.Open: BOOLEAN;
{Open a socket for communications with the Festo unit}
{Note token winsock read timeout -- make use of SelectReadStatus()}
VAR fSuccess: BOOLEAN;
BEGIN
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    FDebugMemo.Lines.Add ('OPEN....' + FormatDateTime (' hhh:nn:ss.zzz', Time));
  fSuccess :=
  Socket.Open (FHandle, FMode, FIP, FRPort, FLPort, FRaddr, 10);
  IF NOT fSuccess THEN
  LastErrorProcess ('Open', 1);
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    IF fSuccess
      THEN FDebugMemo.Lines.Add ('No error')
      ELSE FDebugMemo.Lines.Add ('<!!' + LastErrorMessage);
  Open := fSuccess;
  END;  {function Open}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.Close: BOOLEAN;
{Close the socket; must open again for additional communication}
VAR fSuccess: BOOLEAN;
BEGIN
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    FDebugMemo.Lines.Add ('CLOSE...' + FormatDateTime (' hh:nn:ss.zzz', Time));
  fSuccess :=
  Socket.Close (FHandle);
  IF NOT fSuccess THEN
  LastErrorProcess ('Close', 1);
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    IF fSuccess
      THEN FDebugMemo.Lines.Add ('No error')
      ELSE FDebugMemo.Lines.Add ('<!!' + LastErrorMessage);
  Close := fSuccess;
  END;  {function Close}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.Send (s: STRING): BOOLEAN;
{Send this string to remote on an open socket}
VAR fSuccess:   BOOLEAN;
    bytesready: INTEGER;
    t:          STRING;
BEGIN
  {Flush any debris from input. No error checking done!}
  bytesready := Socket.SelectReadStatus(FHandle);
  IF bytesready > 0 THEN
    Socket.ReceiveString (FHandle, FRaddr, t);
  {Now send the string}
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    FDebugMemo.Lines.Add ('-->' + s);
  fSuccess :=
  Socket.SendString (FHandle, FRaddr, s + FTerm);
  IF NOT fSuccess THEN
  LastErrorProcess ('Send/SendString', 1);
  LastCommand := s;
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    IF (NOT fSuccess) THEN FDebugMemo.Lines.Add ('!!>' + LastErrorMessage);
  Send := fSuccess;
  END;  {function Send}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.Receive (VAR s: STRING): BOOLEAN;
{Receive input sent by a remote to an open socket, or time out}
CONST wink = 10;
VAR timeout,
    bytesready,
    errnumber: INTEGER;
    dataready: BOOLEAN;
VAR fSuccess: BOOLEAN;
BEGIN
  {This timeout is a J.N. loop, not WinSock's}
  timeout := FTimeout;
  errnumber := 0;
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN
    FDebugMemo.Lines.Add ('<--');
  REPEAT
    bytesready := Socket.SelectReadStatus(FHandle);
    dataready := (bytesready > 0);
    IF (bytesready = SOCKET_ERROR) THEN errnumber := 1;
    timeout := timeout - wink;
    IF (timeout <= 0) THEN errnumber := 2;
    IF (bytesready = 0) THEN Windows.Sleep(wink);
    UNTIL dataready OR (errnumber <> 0);
  LastErrorProcess ('Receive/SelectReadStatus', errnumber);
  fSuccess := (errnumber = 0);

  {Now do the actual read}
  IF fSuccess THEN BEGIN
    fSuccess := Socket.ReceiveString (FHandle, FRaddr, s);
    IF NOT fSuccess THEN
      LastErrorProcess ('Receive/ReceiveString', 1);
    IF fSuccess THEN BEGIN
      fSuccess := NOT (Pos('ERR',s) <> 0);
      IF NOT fSuccess THEN
        LastErrorProcess ('Receive/ReceiveString', 5);
      END;
    END;

  LastResponse := s;
  IF FDebugEnable AND (NOT FDebugPause) AND (FDebugMemo <> NIL) THEN BEGIN
    FDebugMemo.Lines.Add (s);
    IF (NOT fSuccess) THEN FDebugMemo.Lines.Add ('<!!' + LastErrorMessage);
    END;
  Receive := fSuccess;
  END;  {function Receive}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.Talk (s: STRING; VAR t: STRING): BOOLEAN;
{Combined call to Send and Receive.
 Also attempts to handle possibly separate echo and response
 when mode is TCP.}
VAR fSuccess:   BOOLEAN;
    tt:     STRING;
BEGIN
  tt := '';
  fSuccess := Send (s);
  IF fSuccess THEN BEGIN
    fSuccess := Receive (t);
    IF fSuccess AND (FMode = 'TCP') AND (Pos('OK',t) = 0)
                AND (Pos('=',t) <> 1) THEN fSuccess := Receive (tt);
    END;
  t := t + tt;
  Talk := fSuccess;
  END;  {function Talk}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.BitRead (aef: CHAR; VAR b: BOOLEAN; addr, chan: INTEGER): BOOLEAN;
{Command to read bit as true|false.
 "aef" denotes whether target is 'A' digital output, 'E' digital input,
   or 'M' flag.
 }
VAR fSuccess: BOOLEAN;
    s, t:     STRING;
    whereeq:  INTEGER;
    answer:   CHAR;
BEGIN
  s := '';
  CASE UpCase(aef) OF
    'A': s := 'DA';
    'E': s := 'DE';
    'M': s := 'DM';
    END;
  fSuccess := (s <> '');
  IF NOT fSuccess THEN
    LastErrorProcess ('BitRead/target', 8);

  IF fSuccess THEN BEGIN
    s := s + IntToStr(addr) + '.' + IntToStr(chan) + ';';
    fSuccess := Talk (s, t);
    END;

  IF NOT fSuccess THEN
    LastErrorProcess ('BitRead/Talk', 1);

  IF fSuccess THEN BEGIN
    whereeq := Pos('=',t);
    fSuccess := (whereeq <> 0);  {pretty weak!}
    IF NOT fSuccess THEN
      LastErrorProcess ('BitRead/equal', 4);
    END;

  IF fSuccess THEN BEGIN
    answer := t[whereeq+1];
    b := (answer = '1');
    END;

  fSuccess := (answer IN ['0','1']);
  IF NOT fSuccess THEN
    LastErrorProcess ('BitRead/parse', 6);

  BitRead := fSuccess;
  END;  {function BitRead}

  {--------------------------------------------------------------}

FUNCTION clsFestoCI.WordRead (aef: CHAR; VAR i: INTEGER; addr: INTEGER): BOOLEAN;
{Command to read word as integer.
 "aef" denotes whether target is 'A' output, 'E' input, or 'M' flag.
 }
VAR fSuccess: BOOLEAN;
    s, t:     STRING;
    whereeq:  INTEGER;
    answer:   STRING;
    k: INTEGER;
BEGIN
  s := '';
  CASE UpCase(aef) OF
    'A': s := 'DAW';
    'E': s := 'DEW';
    'M': s := 'DMW';
    END;
  fSuccess := (s <> '');
  IF NOT fSuccess THEN
    LastErrorProcess ('WordRead/target', 8);

  IF fSuccess THEN BEGIN
    s := s + IntToStr(addr) + ';';
    fSuccess := Talk (s, t);
    END;

  IF NOT fSuccess THEN
    LastErrorProcess ('WordRead/Talk', 1);

  IF fSuccess THEN BEGIN
    whereeq := Pos('=',t);
    fSuccess := (whereeq <> 0);  {pretty weak!}
    IF NOT fSuccess THEN
      LastErrorProcess ('WordRead/equal', 4);
    END;

  IF fSuccess THEN BEGIN
    answer := '';
    k := whereeq+1;
    WHILE ((k<=Length(t)) AND (t[k] IN ['0'..'9'])) DO BEGIN
      answer := answer + t[k];
      INC(k);
      END;
    {Application.MessageBox(PCHAR('/'+t+'/'+answer+'/'),'FestoCI/WordRead');}
    TRY
      i := StrToInt (answer);
      EXCEPT
      i := -1;
      fSuccess := FALSE;
      END;
    IF NOT fSuccess THEN
      LastErrorProcess ('WordRead/convert', 7);
    END;

  WordRead := fSuccess;
  END;  {function WordRead}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.BitWrite (aef: CHAR; b: BOOLEAN; addr, chan: INTEGER): BOOLEAN;
{Command to set bit true/on/1 or false/off/0
 "aef" denotes whether target is 'A' digital output, 'E' digital input,
   or 'M' flag.
 }
VAR fSuccess: BOOLEAN;
    value:    STRING;
    s, t:     STRING;
BEGIN
  value := IntToStr(ORD(b));

  s := '';
  CASE UpCase(aef) OF
    'A': s := 'MA';
    'E': s := 'ME';
    'M': s := 'MM';
    END;
  fSuccess := (s <> '');
  IF NOT fSuccess THEN
    LastErrorProcess ('BitWrite/target', 8);

  s := s + IntToStr(addr) + '.' + IntToStr(chan) + '=' + value + ';';

  fSuccess := Talk (s, t);
  IF NOT fSuccess THEN
    LastErrorProcess ('BitWrite/Talk', 1);

  fSuccess := (t = 'OK');
  IF NOT fSuccess THEN
    LastErrorProcess ('BitWrite/Talk', 3);

  BitWrite := fSuccess;
  END;  {function BitWrite}

{--------------------------------------------------------------}

FUNCTION clsFestoCI.WordWrite (aef: CHAR; i: INTEGER; addr: INTEGER): BOOLEAN;
{Command to set a word.
 "aef" denotes whether target is 'A' digital output, 'E' digital input,
   or 'M' flag.
 }
VAR fSuccess: BOOLEAN;
    value:    STRING;
    s, t:     STRING;
BEGIN
  value := IntToStr(i);

  s := '';
  CASE UpCase(aef) OF
    'A': s := 'MAW';
    'E': s := 'MEW';
    'M': s := 'MMW';
    END;
  fSuccess := (s <> '');
  IF NOT fSuccess THEN
    LastErrorProcess ('WordWrite/target', 8);

  s := s + IntToStr(addr) + '=' + value + ';';

  fSuccess := Talk (s, t);
  IF NOT fSuccess THEN
    LastErrorProcess ('WordWrite/Talk', 1);

  fSuccess := (t = 'OK');
  IF NOT fSuccess THEN
    LastErrorProcess ('WordWrite/Talk', 3);

  WordWrite := fSuccess;
  END;  {function WordWrite}

{--------------------------------------------------------------}


{+++++++++++++++++ end of FestoCI object ++++++++++++++++++++++}

{----------------- end of unit FestoCI ------------------------}

END.
