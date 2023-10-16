Unit IPServ;
{$R+} {Range checking ON}

{
Create UDP servers providing current selected raw measurements
to clients, e.g. other FCP's, in comma delimited format.


v01.01 2012-05-07 Hardcoded for UDP with local bind INADDR_ANY:40123.
                  This is not an object.  No forms yet.

v02.01 2012-06-14 Previous version will not work properly if there is
                  more than one client.
                  Create an array of servers with different local port
                  numbers -- 4100n, n=1..NumberOfServers,
                  which is here set to 3.
                  All elements affected by call to Open, Close, or Process.
                  (Because of this, fSuccess return applies only to last one.)
                  Add agc1m and agc5m to output variables list.
                  These are not objects.  No forms yet.
v03.01 2012-07-03 Increase NumberOfServers to 9 from 3
                  Change local port base from 41000 to 51000
                  Add ambient+ base value to variable list
                  Renumber variable list comment starting at 0 (for LineIn)
v03.02 2012-08-03 Had not actually changed port base to 51000
v03.03 2012-08-19 For error (alarm) output, add -1 possibility
                   if sensor does not exist (procedure make_msg) - see Alarms
v03.04 2012-09-15 For propc..agc5m drop the decimal place
v03.05 2012-09-29 For agc5m put the decimal point back in (for AGC5M-TARGET graphs)

Possible [1..9] server convention to use at EucFACE

  51001  Called by demountable LabView program
  51002  Called by control plot FCP to get WS/WD from paired fumigation plot
  51003  Called by fumigation FCP to get paired control and ambient plot [CO2]
  51004  Called by ambient base FCP to get control or ambient plot [CO2]
  51007  Called by first fumigation FCP to get ambient base
  51008  Same for second fumigation FCP
  51009  Same for third fumigation FCP

}

INTERFACE

USES
{$IFDEF LINUX}
  QForms,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms,
  WinSock,
{$ENDIF}
  SysUtils,
  Socket, comu, comd, Globals, Alarms;

FUNCTION Close:   BOOLEAN;
FUNCTION Open:    BOOLEAN;
FUNCTION Process: BOOLEAN;

IMPLEMENTATION

CONST NumberOfServers = 9;
      LocalPortBase   = 51000;

TYPE IPServRec = RECORD
  handle:    TSocket;
  Raddr,
  Laddr:     TSockAddr;
  dataready: INTEGER;
  debug:     BOOLEAN;  {debugging switch}
  END;

VAR IPServVar: ARRAY [1..NumberOfServers] OF IPServRec;

    i: INTEGER;  {needed for the INITIALAZATION} 

{-------------------------------------------------------------}

PROCEDURE dump (index: INTEGER; title: String; result: BOOLEAN);
CONST nl = CHR(13)+CHR(10);
VAR body: STRING;
BEGIN

  WITH IPServVar[index] DO BEGIN

  body := '';
  body := body + 'index    = ' + IntToStr  (index)        + nl;
  body := body + 'fSuccess = ' + BoolToStr (result, TRUE) + nl;
  body := body + 'handle   = ' + IntToStr  (handle)       + nl;
  body := body + 'bytes    = ' + IntToStr  (dataready)    + nl;

  Application.MessageBox (PCHAR(body), PCHAR(title));

  END;  {of with}
  END;  {of procedure 'dump'}
{-------------------------------------------------------------}

PROCEDURE make_msg (ring: INTEGER; VAR msg: String);
{Used by procedure Process}

VAR j: INTEGER;

PROCEDURE fvw (value: Double; cols, decpts: INTEGER);
VAR s: String;
    i: Integer;
BEGIN
  Str (value:cols:decpts, s);
  IF (Length(s) > cols) THEN BEGIN
    s := '';
    FOR i := 1 TO cols DO s := s + ' ';
    END;
  msg := msg + ',' + s;
  END;  {of local procedure 'fvw'}

BEGIN

  msg := msg + rlabel[ring];              {0}  {Plot, date, time}

  msg := msg + ',' + showdate(comd.date); {1}
  msg := msg + ',' + comd.time;           {2}

  fvw (wspeed[ring],   5, 2);             {3}  {Analog}
  fvw (wwdir[ring],    3, 0);             {4}
  fvw (temp1[ring],    5, 1);             {5}
  fvw (temp2[ring],    5, 1);             {6}
  fvw (temp3[ring],    5, 1);             {7}
  fvw (airpres[ring],  5, 1);  {BP}       {8}
  fvw (ph2o[ring],     4, 0);             {9}
  fvw (solrad[ring],   4, 0);            {10}
  fvw (propc[ring],    5, 0);            {11}
  fvw (propresp[ring], 5, 0);            {12}
  fvw (gcambi[ring],   5, 0);            {13}
  fvw (gccntl[ring],   5, 0);            {14}
  fvw (ambient_base.Integral,  5, 0);    {15}
  fvw (gcset[ring],    5, 0);            {16}
  fvw (gcgrab[ring],   5, 0);            {17}
  fvw (agc1m[ring].Integral,   5, 0);    {18}
  fvw (agc5m[ring].Integral,   5, 1);    {19}
  fvw (Pvvp[ring],     3, 1);            {20}

  fvw (ORD(fumigation_enabled[ring]),1,0); {21} {Fumigation status}
  fvw (ORD(conditional_ok    [ring]),1,0); {22}
  fvw (ORD(runon             [ring]),1,0); {23}

  FOR j := 0 TO 13 DO                    {Error (alarm) checks}

  IF errseq[ring][j].exists
    THEN fvw (ORD(errseq[ring][j].count>0), 1, 0)
    ELSE fvw (-1, 2, 0);

                                         {24} {Proportional valve}
                                         {25} {Gas concentration}
                                         {26} {No ambient signal}
                                         {27} {DAQC communications}
                                         {28} {Fan rotation - treatment}
                                         {29} {Fan rotation - control}
                                         {30} {Gas supply}
                                         {31} {ps01.label_name}
                                         {32} {ps02.label_name}
                                         {33} {ps03.label_name}
                                         {34} {ps04.label_name}
                                         {35} {Enclosure temperature(s)}
                                         {36} {Wind direction stuck}
                                         {37} {Logging to network}

  msg := msg + CHR(13) + CHR(10);

 {Application.MessageBox (PCHAR(msg), 'IPServ/make_msg');}

  END;  {of procedure 'make_msg'}
{-------------------------------------------------------------}

FUNCTION Close: BOOLEAN;
VAR fSuccess: BOOLEAN;
    i: INTEGER;
BEGIN
  FOR i := 1 TO NumberOfServers DO WITH IPServVar[i] DO BEGIN
    IF (handle <> INVALID_SOCKET)
      THEN fSuccess := Socket.Close (handle)
      ELSE fSuccess := TRUE;
    Close := fSuccess;
    END;  {of for/with loop}
  END;  {of function Close}
{-------------------------------------------------------------}

{Temporary code that opens UDP servers.
 Socket.pas Open as of v2.4 is only for clients.}

FUNCTION Open: BOOLEAN;
VAR fSuccess: BOOLEAN;
    i: INTEGER;
BEGIN

  FOR i := 1 TO NumberOfServers DO WITH IPServVar[i] DO BEGIN

  WITH Laddr DO BEGIN
    sin_family      := AF_INET;
    sin_addr.s_addr := INADDR_ANY; {inet_addr (PCHAR('127.0.0.1'))}
    sin_port        := htons (LocalPortBase+i);
    END;

  handle := Winsock.socket (AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  fSuccess := (handle <> INVALID_SOCKET);
  IF debug THEN dump (i, 'IPServ/Open/socket', fSuccess);

  IF fSuccess THEN
  fSuccess := (Winsock.bind (handle, Laddr, SizeOf(Laddr)) = 0);
  IF debug THEN dump (i, 'IPServ/Open/bind', fSuccess);

  Open := fSuccess;
  END;  {of for/with loop}
  END;  {of function Open}
{-------------------------------------------------------------}

FUNCTION Process: BOOLEAN;
VAR fSuccess: BOOLEAN;
    s, t: String;
    r:    String;
    j: INTEGER;  {ring}
    i: INTEGER;  {server}
BEGIN

  FOR i := 1 TO NumberOfServers DO WITH IPServVar[i] DO BEGIN

  fSuccess := FALSE;
  IF debug THEN  dump (i, 'IPServ/Process/BEGIN', fSuccess);

  {Check for input}
  IF (handle <> INVALID_SOCKET) THEN BEGIN
    dataready := Socket.SelectReadStatus (handle);
    fSuccess := (dataready >= 0);
    IF debug THEN dump (i, 'IPServ/Process/SelectReadStatus', fSuccess);

    IF (dataready > 0) THEN BEGIN

      {Read and process command}

      fSuccess := Socket.ReceiveStringTO (handle, Raddr, s, 100);
      r := Copy (s,1,1);
      IF debug THEN dump (i, 'IPServ/Process/ReceiveStringTO', fSuccess);

      {A command of 0 means collect all rings,
       otherwise just ring label designated.}

      IF fSuccess THEN BEGIN
        t := '';
        FOR j := 1 TO numrings DO
          IF (r = '0') OR (r = rlabel[j]) THEN make_msg (j, t);
        IF (t = '') THEN t := 'EMPTY';
        fSuccess := Socket.SendString (handle, Raddr, t);
        IF debug THEN dump (i, 'IPServ/Process/SendString', fSuccess);
        END;

      END;  {bytes are ready}

    Process := fSuccess;
    END;  {valid handle}
  END;  {of for/with server loop}
  END;  {of function Process}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  FOR i := 1 TO NumberOfServers DO WITH IPServVar[i] DO BEGIN
    handle := INVALID_SOCKET;
    debug := FALSE;
    END;
  Open;
  END;

FINALIZATION

BEGIN
  Close;
  END;

{of unit IPServ...} END.
