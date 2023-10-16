{$IFDEF PROGRAM}  {compiler directive /DPROGRAM}
PROGRAM clocks (INPUT, OUTPUT);
{$IFDEF TURBO}
{$M 8192,0,0}  {needed for Exec procedure}
{$ENDIF}
{$IFDEF DELPHI}
{$APPTYPE CONSOLE}
{$ENDIF}
{$ENDIF}

{$IFDEF UNIT}     {compiler directive /DUNIT}
Unit clocks;
Interface
{$ENDIF}

Uses

{$IFDEF TURBO}
Dos, Crt,
{$ENDIF}

{$IFDEF DELPHI}
{$H-}
SysUtils, crt32,
{$ENDIF}

{$IFDEF UNIT} 
comd, comp, 
{$ENDIF}

ser;  {serial communications unit...end of Uses}

{
 Display PC DOS and CMOS clocks.
 Dial up and load time from USNO.
 Uses MsDos and Intr system hooks.
 Assumes generic DOS and AT BIOS.

 John Nagy  10/23/91  Original in TurboPascal5
            11/29/92  Finish coding time service dial up
            12/06/92  Provide compile switch to make either standalone 
                      program (/DPROGRAM) or unit for COM (/DUNIT)
            12/23/92  Add seroff() to stopnist.  If CD lost, call stopnist.
                      Add seron() to clockmenu to keep RTS on.
            06/03/93  Change default com port to 3.
            12/10/93  Change to Uses comd94, comp94, ser94.
            94/05/03  Bug fix: IF MemW[40: --> MemW[$40:
            95/06/02  Change to Uses comd95, comp95, ser95.
            96/01/02  Change to Uses comd96, comp96.
            96/05/03  Delete unilateral setting of BIOS $40:0000-0007
            96/12/22  Change to Uses comd97, comp97.
            97/12/23  Change to Uses comd98, comp98.
            98/04/19  Change to Uses ser98 (from ser95)
            99/12/13  Change to Uses comd99, comp99.
                      $IFDEF TURBO|DELPHI Uses
            99/12/14  VAR r: to program/implementation level.
                      get/setcursorsize, get/setdostime, get/setcmostime
                        dummied unless $IFDEF TURBO
                      function getbseaddr added
                      Option 8 as program dummied unless TURBO
                      timerec fields changed from INTEGER to Word
                      $IFDEF DELPHI get and display "now"
                      Change dx from 12 to 13
            00/01/19  IFDEF DELPHI invoke $H-.
            00/02/14  Had forgot to invoke crt32.init IFDEF PROGRAM
            00/04/25  clockmenu: switch + & - in prompt
                      clockmenu: $IFDEF UNIT ikbin; now necessary with mouse
}

CONST x0 = 20; y0 = 4;  {upper left corner of clocks}
      dx = 13;          {time display column}
      ydos = 1;         {DOS line}
      ycmos= 3;         {CMOS line}
      menubase = 7;
      lastline = 23;    {penultimate line on screen}

TYPE timerec = RECORD
                 hour, minute, sec, sec100: Word;
                 END;

     commdata = RECORD
                  port, speed, speedcode, databits, stopbits: INTEGER;
                  parity: CHAR;
                  parameter: INTEGER;
                  status: Word;
                  END;

     timedial = RECORD
                  phoneno: String;  {without prefix or suffix}
                  utc_connect,
                  utc_good: BOOLEAN;
                  zd: INTEGER;  {zone descriptor, e.g. -5 for EST}
                  END;

VAR nisttime,
    temptime: timerec;
VAR getcmoserr,
    setdoserr: BOOLEAN;
    timecomm: commdata;
    utcdata: timedial;
    csave: ARRAY [1..2] OF Byte;  {save cursor scan lines}


{$IFDEF PROGRAM}
PROCEDURE tinter;
BEGIN
  END;  {of dummy procedure 'tinter'}
{$ENDIF}

{$IFDEF UNIT}
PROCEDURE clockmenu;

Implementation
{$ENDIF}

{$IFDEF TURBO}
VAR r: Registers;
{$ENDIF}

PROCEDURE getcursorsize (VAR csbegin, csend: Byte);
{Using BIOS, get cursor begin and end scan lines
 JN  11/9/91}
BEGIN
{$IFDEF TURBO}
  WITH r DO BEGIN
    Ah := $03;
    Bh := 0;       {display page number}
    Intr($10,r);
    csbegin := Ch;
    csend   := Cl;
    END;
{$ENDIF}
  END;  {of procedure 'getcursorsize'}

PROCEDURE setcursorsize (csbegin, csend: Byte);
{Using BIOS, set cursor begin and end scan lines
 JN  11/9/91}
BEGIN
{$IFDEF TURBO}
  WITH r DO BEGIN
    Ch := csbegin;
    Cl := csend;
    Ah := $01;
    Intr($10,r);
    END;
{$ENDIF}
  END;  {of procedure 'setcursorsize'}

PROCEDURE getdostime (VAR time: timerec);
BEGIN
{$IFDEF TURBO}
  WITH r, time  DO BEGIN
    Ah := $2C;
    MsDos(r);
    hour   := Ch;
    minute := Cl;
    sec    := Dh;
    sec100 := Dl;
    END;
{$ENDIF}
{$IFDEF DELPHI}
  WITH time  DO BEGIN
    DecodeTime (Now, hour, minute, sec, sec100);
    sec100 := sec100 DIV 10;
    END;
{$ENDIF}
  END;  {of procedure 'getdostime'}

PROCEDURE setdostime (time: timerec; VAR error: BOOLEAN);
BEGIN
{$IFDEF TURBO}
  WITH r, time  DO BEGIN
    Ah := $2D;
    Ch := hour;
    Cl := minute;
    Dh := sec;
    Dl := 0;
    MsDos(r);
    error := (Al <> 0);  {or Ah = $FF}
    END;
{$ENDIF}
  END;  {of procedure 'setdostime'}

PROCEDURE getcmostime (VAR time: timerec; VAR error: BOOLEAN);
BEGIN
{$IFDEF TURBO}
  WITH r, time  DO BEGIN
    Ah := $02;
    Intr($1A,r);
    hour   := 10*(Ch Shr 4) + (Ch AND $0F);
    minute := 10*(Cl Shr 4) + (Cl AND $0F);
    sec    := 10*(Dh Shr 4) + (Dh AND $0F);
    sec100 := 0;  {not available}
    error := ODD (Flags And FCarry);
    END;
{$ENDIF}
  END;  {of procedure 'getcmostime'}

PROCEDURE setcmostime (time: timerec);
BEGIN
{$IFDEF TURBO}
  WITH r, time  DO BEGIN
    Ah := $03;
    Ch := (hour   DIV 10) Shl 4 + (hour   MOD 10);
    Cl := (minute DIV 10) Shl 4 + (minute MOD 10);
    Dh := (sec    DIV 10) Shl 4 + (sec    MOD 10);
    Dl := 0;  {do not use daylight savings option}
    Intr($1A,r);
    END;
{$ENDIF}
  END;

FUNCTION getbaseaddr (port: Word): Word;      
BEGIN
{$IFDEF TURBO}
  getbaseaddr := MemW[$40:(port-1)*2];
{$ENDIF}
  END;

FUNCTION timetostr (time: timerec): String;
{Convert time record to an 11-byte string
 in usual format including 1/100 seconds.
 J.N.  BNL  10/26/91}
VAR s, t: String;
    i: INTEGER;
BEGIN
  WITH time DO BEGIN
    s := '';
    Str(hour:2,  s);
    Str(minute:2,t);  s:= s+':'+t;
    Str(sec:2,   t);  s:= s+':'+t;
    Str(sec100:2,t);  s:= s+'.'+t;
    FOR i := 1 TO Length(s) DO
      IF s[i]=' ' THEN s[i] := '0';
    END;
  timetostr := s;
  END;  {of function 'timetostr}

PROCEDURE inform (information: String);
BEGIN
  GotoXY (1, lastline);
  ClrEol;
  WRITE (information);
  END;  {of trivial procedure 'inform'}

PROCEDURE template;
{$IFDEF PROGRAM}
CONST version = 'CLOCKS.EXE for IBM PC/AT & compatibles -- J.N. 10/91';
{$ENDIF}
{$IFDEF UNIT}
CONST version = 'CLOCKS.TPU for IBM PC/AT & compatibles -- J.N. 12/92';
{$ENDIF}
BEGIN
  ClrScr;
  WRITE (version);
  GotoXY(x0,y0+ydos);   
    {$IFDEF TURBO}
    WRITE('DOS time:');
    {$ENDIF}
    {$IFDEF DELPHI}
    WRITE('System time:');
    {$ENDIF}
  GotoXY(x0,y0+ycmos);  WRITE('CMOS time:');
  GotoXY(1,y0+menubase+1);   WRITE('(1)  Set DOS  from CMOS');
  GotoXY(1,y0+menubase+2);   WRITE('(2)  Set CMOS from DOS');
  GotoXY(1,y0+menubase+3);   WRITE('(3)  Start UTC connection');
  GotoXY(1,y0+menubase+4);   WRITE('(4)    Set DOS  from UTC');
  GotoXY(1,y0+menubase+5);   WRITE('(5)    Set CMOS from UTC');
  GotoXY(1,y0+menubase+6);   WRITE('(6)    Set Both from UTC');
  GotoXY(1,y0+menubase+7);   WRITE('(7)  Stop UTC connection');
  GotoXY(1,y0+menubase+8);   WRITE('(8)  Set DOS from TIME command');
  GotoXY(1,y0+menubase+9);   WRITE('(9)  Set DOS from keyboard');
  WITH timecomm, utcdata DO BEGIN
    GotoXY(31,y0+menubase-1);
      WRITE('UTC time service Hayes modem connection at 8-N-1');
    GotoXY(31,y0+menubase);
      WRITE('------------------------------------------------');
    GotoXY(31,y0+menubase+1);
      WRITE('(A)  Toggle port:');
      GotoXY(61,y0+menubase+1);
      WRITE('COM');  WRITE(port:1);  WRITE(getbaseaddr(port):6);
    GotoXY(31,y0+menubase+2);
      WRITE('(B)  Toggle speed:');
      GotoXY(61,y0+menubase+2);
      WRITE(speed:4);  WRITE (' bps');
    GotoXY(31,y0+menubase+3);
      WRITE('(C)  Enter phone number:');
      GotoXY(61,y0+menubase+3);
      WRITE(phoneno);
    GotoXY(31,y0+menubase+4);
      WRITE('(-+) Zone descriptor:');
      GotoXY(61,y0+menubase+4);
      WRITE(zd:3);
    GotoXY(45,y0+menubase+6);
      WRITE('  USNO: 202-653-0351');
    GotoXY(45,y0+menubase+7);
      WRITE('  NIST: 303-494-4774');
    END;  {of with}
  inform ('Hit <ESC> to exit');
  END;  {of procedure 'template'}

PROCEDURE stopnist;
CONST switch = '+';
VAR errmsg: String;
    i: INTEGER;
BEGIN
  WITH timecomm DO IF serdsrcts(port,errmsg) THEN BEGIN
    Delay(1000);
    FOR i := 1 TO 3 DO serout (port, switch, errmsg);
    Delay(1000);
    sersend (port, 'ATH');
    END;
  seroff (timecomm.port, errmsg);
  utcdata.utc_connect := FALSE;
  utcdata.utc_good    := FALSE;
  END;
    
PROCEDURE startnist;
CONST cr    = CHR(13);  {carriage return}
      abort = 'X';      {abort connect attempt}
VAR errmsg: String;
    key: CHAR;
BEGIN
  WITH timecomm, utcdata DO BEGIN
    utc_connect := FALSE;
    utc_good    := FALSE;

    serparam (speed, databits, stopbits, parity, parameter, errmsg);

    IF errmsg = '' THEN serinit (port, parameter, errmsg);

    IF errmsg = '' THEN serstatus (port, status, errmsg);

    IF (errmsg = '') AND (serdsrcts(port, errmsg)) THEN BEGIN
      sersend (port, 'ATDT'+phoneno);
      inform ('Waiting for carrier detect.  Hit "'+abort+'" to abort...');
      key := CHR(0);
      REPEAT
        IF KeyPressed THEN key := UpCase(ReadKey);
        UNTIL sercd(port,errmsg) OR (key=abort) OR (errmsg<>'');
      END;

    IF errmsg = '' THEN utc_connect := (key <> abort)
                   ELSE inform ('*** '+errmsg+' ***');

    IF NOT utc_connect THEN stopnist;
    END;  {of with}
  END;  {of procedure 'startnist'}

PROCEDURE process_msg (s: String; VAR ptr: INTEGER);
VAR good: BOOLEAN;
    hh, mm, ss: INTEGER;
    codehh, codemm, codess: INTEGER;
    labelpos: INTEGER;
    tag: CHAR;
BEGIN
  ptr := 1;
  IF s[1] = '*' THEN  {USNO marker; just ignore}
  ELSE BEGIN
    good := TRUE;
    hh := 0;  mm := 0;  ss := 0;
    codehh := -1;  codemm := -1;  codess := -1;
    labelpos := Pos('UTC',s);
    CASE labelpos OF
      18: BEGIN
            Val(Copy(s,11,2),hh,codehh);
            Val(Copy(s,13,2),mm,codemm);
            Val(Copy(s,15,2),ss,codess);
            END;
      40: BEGIN
            Val(Copy(s,16,2),hh,codehh);
            Val(Copy(s,19,2),mm,codemm);
            Val(Copy(s,22,2),ss,codess);
            END;
      Else good := FALSE;
      END;  {case}
    good := good AND (codehh=0) AND (hh IN [0..23]);
    good := good AND (codemm=0) AND (mm IN [0..59]);
    good := good AND (codess=0) AND (ss IN [0..59]);
    hh := hh+utcdata.zd;
    WHILE hh<0  DO hh := hh+24;
    WHILE hh>23 DO hh := hh-24;
    utcdata.utc_good := good;
   {WRITE ('  >>>  ',codehh:1,codemm:1,codess:1,' ',hh:2,mm:2,ss:2);}
    IF good THEN tag := '*' ELSE tag := ' ';
    GotoXY(45,y0+menubase+6+ORD(labelpos=40));
    WRITE (tag);
    GotoXY (1,lastline);
    IF good THEN WITH nisttime DO BEGIN
      hour   := hh;
      minute := mm;
      sec    := ss;
      sec100 := 0;
      END;
    END;
  END;  {of procedure process_msg}
    
PROCEDURE displaytime (dostime, cmostime: timerec; 
                       setdoserr, getcmoserr: BOOLEAN);
VAR xsave, ysave: Byte;
BEGIN
  xsave := WhereX;
  ysave := WhereY;
  GotoXY(x0+dx,y0+ydos);
  WRITE(timetostr(dostime));
  IF setdoserr THEN WRITE('  SETTING ERROR')
               ELSE WRITE('               ');
  GotoXY(x0+dx,y0+ycmos);
  {$IFDEF TURBO}
  IF NOT getcmoserr
    THEN WRITE(timetostr(cmostime))
    ELSE WRITE('not operating');
  {$ENDIF}
  GotoXY(xsave,ysave);
  END;  {of procedure 'displaytime'}

PROCEDURE action (keystroke: CHAR; dostime, cmostime: timerec);
{Note:  In DOS 3.3 and higher, setting the DOS clock also sets the CMOS!!!}
VAR secsave: Word;
    s: String;
    errcode: INTEGER;
BEGIN
  WITH timecomm, utcdata DO CASE keystroke OF
    '1':  BEGIN
            secsave := cmostime.sec;
            REPEAT
              getcmostime (cmostime, getcmoserr);
              UNTIL getcmoserr OR (cmostime.sec <> secsave);
            IF NOT getcmoserr
              THEN setdostime (cmostime, setdoserr);
            END;

    '2':  BEGIN
            {no sense waiting for dostime.sec <> secsave since can not
             set fractional part of cmos second}
            setcmostime (dostime);
            END;

    '3':  BEGIN
            startnist;
            END;

    '4','5','6':  IF utc_good THEN BEGIN
            {do cmos first since if DOS 3.3 or higher setting dos
             will also set cmos automatically}
            IF (keystroke='4') OR (keystroke='6') 
              THEN setcmostime (nisttime);
            IF (keystroke='4') OR (keystroke='5') 
              THEN setdostime (nisttime, setdoserr);
            END;

    '7':  BEGIN
            stopnist;
            END;

    '8':  {$IFDEF PROGRAM}
            IF NOT utc_connect THEN BEGIN
              inform ('Pushing to DOS TIME command...');
              setcursorsize (0, csave[2]);
          {$IFDEF TURBO}
              SwapVectors;
              Exec(GetEnv('COMSPEC'),'/C TIME');
              SwapVectors;
          {$ENDIF}
              setcursorsize ($20,0);
              template;
              END;
          {$ENDIF}

          {$IFDEF UNIT}  {don't allow Option 8 in COM}
            inform ('This option not available when running COM.  Use #9.');
            {$ENDIF}

    '9':  WITH temptime DO BEGIN
            inform 
              ('Enter time as HH MM SS (two digits separated by spaces): ');
            setcursorsize (0, csave[2]);
            {$IFDEF PROGRAM}  
              BEGIN
                errcode := 0;
                READLN (hour, minute, sec);
                END;
              {$ENDIF}
            {$IFDEF UNIT}
              BEGIN
                saccept;
                                  Val(Copy(svalue,1,2),hour  ,errcode);
                IF errcode=0 THEN Val(Copy(svalue,4,2),minute,errcode);
                IF errcode=0 THEN Val(Copy(svalue,7,2),sec   ,errcode);
                END;
              {$ENDIF}
            IF errcode=0
              THEN setdostime (temptime, setdoserr)
              ELSE inform ('Error parsing the input string');
            setcursorsize ($20,0);
            template;
            END;

    'A','a':  BEGIN
                port := port+1;
                WHILE port > 4 DO port := port-4;
                GotoXY(61,y0+menubase+1);
                WRITE('COM');  WRITE(port:1);  WRITE(getbaseaddr(port):6);
                END;

    'B','b':  BEGIN
                speedcode := speedcode+1;
                WHILE speedcode > 7 DO speedcode := speedcode-8;
                speed := serspeeds[speedcode];
                GotoXY(61,y0+menubase+2);
                WRITE(speed:4);  WRITE(' bps');
                END;

    'C','c':  BEGIN
                GotoXY(61,y0+menubase+3);  {ClrEol;}
                setcursorsize (0, csave[2]);
                {$IFDEF PROGRAM}
                  READLN(s);
                  {$ENDIF}
                {$IFDEF UNIT}
                  saccept;
                  s := svalue;
                  {$ENDIF}
                setcursorsize ($20,0);
                WHILE (s[1]=' ') AND (s<>'') DO Delete (s,1,1);
                IF (s <> '') AND (s[1]<>' ') THEN phoneno := s;
                GotoXY(61,y0+menubase+3);  ClrEol;
                WRITE(phoneno);
                END;

    '+','-':  BEGIN
                CASE keystroke OF
                  '+':  zd := zd+1;
                  '-':  zd := zd-1;
                  END;  {case}
                WHILE zd < -12 DO zd := zd+24;
                WHILE zd > +12 DO zd := zd-24;
                GotoXY(61,y0+menubase+4);
                WRITE(zd:3);
                END;
    END;  {of case}
  END;  {of procedure 'action'}

PROCEDURE clockmenu;
CONST exit = 27;         {escape character}
      cr   = 13;         {carriage return}
      lf   = 10;         {line feed}
      maxptr = 127;      {maximum size of serial input buffer}
VAR dostime,
    cmostime: timerec;
    ch: CHAR;
    buffer: ARRAY [1..maxptr] OF CHAR;
    ptr: INTEGER;
    errmsg: String;
BEGIN
  setdoserr := FALSE;
  template;
  getcursorsize (csave[1], csave[2]);
  setcursorsize ($20,0);  {blank it}
  ptr := 1;
  REPEAT
    REPEAT
      tinter;
      getdostime (dostime);
      getcmostime (cmostime, getcmoserr);
      displaytime (dostime, cmostime, setdoserr, getcmoserr);
      IF utcdata.utc_connect THEN WITH timecomm DO BEGIN
        seron (port, errmsg);  {this really shouldn't be necessary}
        IF serdataready (port, errmsg) THEN BEGIN
          serin (port, ch, errmsg);
          IF ch<>CHR(lf) THEN WRITE (ch);
          buffer[ptr] := ch;
          IF ptr<maxptr THEN INC(ptr);
          IF ch = CHR(lf) THEN process_msg (buffer, ptr);
          END;
        IF NOT sercd (port, errmsg) THEN stopnist;
        END;
      UNTIL KeyPressed;
    {$IFDEF PROGRAM}
    ch := ReadKey;
    IF ch=CHR(0) THEN BEGIN  {this routine doesn't use F-keys like COM!!!}
      ch := ReadKey;
      ch := CHR(0);
      END;
    {$ENDIF}
    {$IFDEF UNIT}
    ikbin;
    ch := calr;
    {$ENDIF}
    inform ('Hit <ESC> to exit this utility');
    action (ch, dostime, cmostime);
    UNTIL ch = CHR(exit);
  setcursorsize (csave[1], csave[2]);  {restore}
  END;  {of procedure 'clockmenu'}

BEGIN  {main/initialization}

  {Default communications parameters for connection to UTC services}
  WITH timecomm, utcdata DO BEGIN
    {deleted 96/05/03 ...
    IF MemW[$40:0] = 0 THEN MemW[$40:0] := $3F8;
    IF MemW[$40:2] = 0 THEN MemW[$40:2] := $2F8;
    IF MemW[$40:4] = 0 THEN MemW[$40:4] := $3E8;
    IF MemW[$40:6] = 0 THEN MemW[$40:6] := $2E8;
    ...}
    port     := 3;
    speedcode:= 4; {1200 bps}
    speed    := serspeeds[speedcode];
    databits := 8;
    stopbits := 1;
    parity   := 'N';
    zd       := -7;  {zone descriptor -- this is MST}
    phoneno  := '1,202-653-0351';
    utc_connect := FALSE;
    utc_good    := FALSE;
    END;  {of with}

{$IFDEF PROGRAM}
  {$IFDEF DELPHI}
  crt32.init;
  {$ENDIF}
  clockmenu;
  {$ENDIF}

{of program/unit 'clocks'...}
END.
