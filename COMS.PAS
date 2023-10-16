Unit coms;
{$R+} {Range checking ON}
{$H-} {Turbo-style strings default}

{*
 * Purpose:  BNL FACE Project
 *           On-line data acquisition, monitoring and control
 *           Some screen routines and higher level utilities
 *
 * Version:     1
 * Date:        June 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Had to move some routines out of COMP; getting too big!   [94/06/12]
 *
 * Version:     2
 * Date:        Feb-Mar 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMS95.PAS                                        [95/02/21]
 *
 * Version:     3
 * Date:        Oct 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMS96.PAS; update Uses.                          [95/10/14]
 *   (2) Generalize post(); putring(); for any number of valves.   [95/12/20]
 *
 * Version:     4
 * Date:        June 1996
 * Changes:
 *   (1) Bring procedure sidebar() here from comp96.pas            [96/06/22]
 *   (2) Bring function rlabel() here from comp96.pas              [96/06/22]
 *   (3) Delete function rlabel() the same evening!                [96/06/22]
 *   (4) Change rlabel() references to rlabel[]                    [96/06/22]
 *
 * Version:     5
 * Date:        Dec 1996
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMS97.PAS; update Uses.                          [96/12/22]
 *   (2) Move procedure clearhist here from comp97                 [97/01/20]
 *
 * Version:     6
 * Date:        1997
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Fan and gas subwindow code.                               [97/  /  ]
 *   (2) putwindow(): watchdog board window.                       [97/09/28]
 *
 * Version:     7
 * Date:        December 1997
 * Changes:
 *   (1) Becomes COMS98.PAS; update Uses.                          [97/12/23]
 *   (2) Replace 3 occurences of sgcont by sgcgrab.                [97/12/29]
 *   (3) Move procedure status and statdis here from COMP          [98/01/01]
 *
 * Version:     8
 * Date:        1998
 * Changes:
 *   (1) status(), statdis(): display ratio of proplearn to wind   [98/05/30]
 *   (2) setco2qt(); average(); histogram(); flasher(); procedures [98/08/18]
 *       moved here from COMP.
 *
 * Version:     9
 * Date:        1999
 * Changes:
 *   (1) average: use atan2 from tp5utils for wd averaging         [99/01/28]
 *   (2) super_switch_out: new debugging tool                      [99/05/15]
 *   (3) move com98/config/get_ show_ _port _addr subprocs here    [99/06/19]
 *   (4) move com98/config/ test_key and check subprocs here       [99/06/19]
 *   (5) Implementation Uses optomux, netinfo, licor               [99/06/19]
 *   (6) Add "ring" to argument list of get_addr.                  [99/06/19]
 *   (7) New procedure ioerrhalt.                                  [99/06/25]
 *   (8) get_addr: read in the invert value for a digital i/o      [99/06/25]
 *   (9) sidebar:  change starting column from 45 to 50.           [99/07/15]
 *  (10) ioerrhalt: wasn't testing if ioresult 0 or not!           [99/08/03]
 *  (11) get_port&get_addr: echo line id expected.                 [99/08/18]
 *  (12) flasher: use alarm_debug to test audible alarm (sound).   [99/09/04]
 *  (13) get_addr: add filling of adc_read[].select.               [99/09/29]
 *
 * Version:     10
 * Date:        1999-2000
 * Changes:
 *   (1) Unit name and uses changed to '99.                        [99/12/13]
 *   (2) $IFDEF TURBO | DELPHI Uses.                               [99/12/17]
 *   (3) clearhist: change identifier 'class' to 'group'           [00/01/18]
 *   (4) statdis: global 'iautocalib' can not be local loop index  [00/01/18]
 *   (5) IFDEF DELPHI invokes $H-.                                 [00/01/19]
 *   (6) status: remove statscr=TRUE (now in main's loop).         [00/02/14]
 *   (7) IsWindow: dummy DOS function moved here from COMDIS99     [00/04/06]
 *   (8) post: scale x, dx, y, dy (crudely)                        [00/04/12]
 *   (9) add gra99 to Uses list to pick up grmaxx|y                [00/04/12]
 *  (10) puthisto: scale using grmaxx|y                            [00/04/12]
 *  (11) axes: new procedure for use by riv                        [00/04/12]
 *  (12) putaxes: renaming of axes                                 [00/04/17]
 *  (13) flasher: new local var rmax; width = max(numrings,4)      [00/04/17]
 *  (14) sidebar (global version): mouse awareness                 [00/04/21]
 *  (15) putwindow: iring*4 --> maxrings+4*(iring-1)               [00/05/08]
 *  (16) calls to continue; added before Halt(n); statements       [00/06/15]
 *  (17) Replace Halt(n); by Halt (50n).                           [00/09/26]
 *  (18) status & statdis: minor mods for ISO 8601 date & time     [00-10-12]
 *  (19) Implementation Uses: add musca to list                    [00-11-07]
 *  (20) swind: unnedded VAR declarations removed                  [00-11-07]
 *  (21) swind: ver, hor args in windd changed to lx, ly           [00-11-07]
 *  (22) post: in CASE where, Else added to suppress warning       [00-11-07]
 *  (23) puthisto: in CASE hsel[], Else added to suppress warning  [00-11-07]
 *  (24) average: delete VAR d1hr                                  [00-11-07]
 *  (25) average: delete d1hr := ddel/3600.0                       [00-11-07]
 *  (26) average: delete unused VAR avangle                        [00-11-07]
 *
 * Version:     11
 * Date:        2001
 * Changes:
 *   (1) putaxes: insert another SetColor(0) after SetLineStyle(,3)[01/04/08]
 *   (2) putwindow: replace swwdir[iring] := awwdir[] by WD grab   [01/05/11]
 *
 * Version:     12
 * Date:        2002
 * Changes:
 *   (1) Unit renamed coms                                         [02-03-21]
 *   (2) Uses comd99, etc. changed to Uses comd                    [02-03-21]
 *   (3) Remove $IFDEF TURBO code $ENDIF & $IFDEF DELPHI $ENDIF    [02-03-24]
 *   (4) flasher: replace Sound(440) by 3x Windows.MessageBeep()   [02-07-08]
 *   (5) flasher: delete IF state = 'OFF' THEN NoSound             [02-07-08]
 *   (6) flasher: change from 3x to 2x Windows.MessageBeep         [02-07-08]
 *   (7) swind: del redundant/ineffectual 2nd call to SetLineStyle [02-08-17]
 *   (8) flasher: change from 2x to 1x Windows.MessageBeep         [02-07-08]
 *   (9) statdis & status: date & time display moved to Main       [02-09-15]
 *  (10) statdis: remove ring pictures prompt                      [02-09-17]
 *  (11) ioerrhalt: deleted                                        [02-09-21]
 *  (12) flasher:   deleted                                        [02-11-15]
 *  (13) putwindow: remove watchdog window                         [02-11-16]
 *  (14) average:   remove STAT file related calculations          [02-12-17]
 *
 * Version:     13
 * Date:        2003
 * Changes:
 *   (1) average: replace calls to lpf by TLPF objects             [03-01-05]
 *   (2) lpf_constants: new procedure                              [03-01-05]
 *   (3) lpf_constants: set many fields of ambient_base: TLPF      [03-01-06]
 *   (4) lpf_constants: cos/sin ranges set to -1.0..+1.0           [03-01-06]
 *   (5) lpf_constants: wind speed ranges set to 0..25             [03-01-06]
 *   (6) lpf_constants: pverr/conterr/wdstuck no autoseed          [03-01-06]
 *   (7) lpf_constants: prop/windlearn set some fields             [03-01-06]
 *   (8) ephemeris: moved to COMS from COMDIS                      [03-01-07]
 *   (9) h2ovapor:  moved to COMS from COMDIS                      [03-01-07]
 *   (9) ephemeris: moved to COMP -- needs tinter, etc.            [03-01-07]
 *  (10) h2ovapor:  moved to COMP -- needs tinter, etc.            [03-01-07]
 *  (11) status: remove Line Graphs prompt                         [03-01-10]
 *  (12) remove uses of dos32                                      [03-01-28]
 *  (13) get_port: comment out WRITELN of expected key             [03-03-16]
 *  (14) get_port: comment out call to show_port                   [03-03-16]
 *  (15) get_addr: ditto, so console not needed in config/load     [03-03-16]
 *  (16) status, statdis: co2qt display moved to Status            [03-03-16]
 *  (17) status, statdis: current vvp pattern display to Status    [03-03-16]
 *  (18) statdis: procedure deleted                                [03-03-19]
 *  (19) status: moved to Main                                     [03-03-19]
 *  (20) average: wsweight set to 1 for wind direction integration [03-05-03]
 *  (21) comd/Globals changes                                      [03-05-28]
 *  (22) lpf_constants: change all sin/cos RangeMin to -ws.RangeMax[03-06-13]
 *  (23) lpf_constants: change all sin/cos RangeMax to +ws.RangeMax[03-06-13]
 *  (24) average: reinstate ws weight for wd averaging (see #20)   [03-06-13]
 *  (25) lpf_constants: move setting of .Name here from COMD       [03-06-14]
 *  (26) average: remove spurious agcerr[] := line !!!             [03-06-15]
 *
 * Version:     14
 * Date:        2004
 * Changes:
 *   (1) get_addr: change licor/licor6262_* refs to licor_*        [04-08-01]
 *   (2) get_addr: call licor/licor_model_set                      [04-08-01]
 *
 * Version:     15
 * Date:        2006
 * Changes:
 *   (1) Interface Uses: replace tp5utils by AVSD                  [06-04-30]
 *   (2) test_key: on error, SetLastError $20005001                [06-09-23]
 *   (3) check   : on error, SetLastError $20005002                [06-09-23]
 *   (4) get_addr: on error, SetLastError $20005003, $20005004     [06-09-23]
 *
 * Version:     16
 * Date:        2007
 * Changes:
 *   (1) average: do not LPF process agc1m, etc. if comm_err[no]   [07-06-15]
 *
 * Version:     17
 * Date:        2009
 * Changes:
 *   (1) get_port, show_port: rewritten to use new DataComm.Ports  [09-08-11]
 *   (2) get_addr: recognize irga type "24" for licor_alloc        [09-08-17]
 *   (3) get_port: read in IP parameters if "diptoe" > 256         [09-11-05]
 *
 * Version:     18
 * Date:        2011
 * Changes:
 *   (1) Delete procedure super_switch_out()                     [2011-09-23]
 *   (2) Add FestCI to Implementation Uses                       [2011-09-23]
 *   (3) get_port: if IPType and FE protocol, then Create Festo  [2011-09-23]
 *                 object and Setup parameters -- do not Open
 *   (4) get_port/serial: set timeout to 50 ms; this is temporary[2011-10-26]
 *   (5) get_port/socket: use mode = UpperCase(s) to assure upper[2011-11-01]
 *   (6) average: also integrate wdstuck if wspeed is < -0.5     [2011-11-03]
 *
 * Version:     18
 * Date:        2012
 * Changes:
 *   (1) Delete procedure get_port. Moved to DataComm as PortGet [2012-01-26]
 *   (2) average, lpf_constants: remove all mp3s related work    [2012-07-13]
 *   (3) lpf_constants: wind stuck response time = 0 (AU cntls)  [2012-09-19]
 *   (4) lpf_constants: previous change was exactly the wrong    [2012-09-20]
 *         thing to do (control plot integrals == 0 most of time).
 *         Since most important that code work for the fumigation
 *         return to previous response time values (timeerrint).
 *}

Interface

Uses
  CalibAut,
  crt32, graph32,
  Globals,
  comd, comu, gra;

PROCEDURE average (no: INTEGER);
PROCEDURE clearhist (ring, group, numrings: INTEGER);
PROCEDURE histogram;
PROCEDURE lpf_constants;
PROCEDURE show_port (port: INTEGER);
PROCEDURE show_addr (addrdef: daqc_addr);
PROCEDURE get_addr (VAR ifile: TEXT; key, ring, bdflag: INTEGER; 
                    VAR addrdef: daqc_addr);
PROCEDURE swind (n: INTEGER);
PROCEDURE post (where,ip,nv,col1: INTEGER; act: BOOLEAN; style: INTEGER);
PROCEDURE putaxes (xr, yr, hisno: INTEGER);
PROCEDURE puthisto (ifire: INTEGER);
PROCEDURE putring (where, iring, nv: INTEGER);
PROCEDURE putwindow (iring: INTEGER);
PROCEDURE setco2qt (ring: INTEGER; request: BOOLEAN);
PROCEDURE sidebar (msg: String; ringno: INTEGER);

Implementation

Uses 
  Windows, SysUtils, DataComm,
  Alarms, CalibMan, FatalErr,
  FestoCI, optomux, netinfo, licor, musca, AVSD;

{------------------------------------------------------------}

PROCEDURE test_key (key_read, key_expect: INTEGER);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
BEGIN
  IF (key_read <> key_expect) THEN BEGIN
    SetLastError ($20005001);
    FatalErr.Msg (
    'coms --> test_key',
    'Error encountered in a configuration file' + nl2 +
    'Line number key field (1st) read was ' + IntToStr(key_read) + nl2 +
    'Key expected was ' + IntToStr(key_expect));
    END;
  END;  {of procedure 'test_key'}
{-----------------------------------------------------------}

PROCEDURE check (s: String; code: INTEGER);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
BEGIN
  IF (code <> 0) THEN BEGIN
    SetLastError ($20005002);
    FatalErr.Msg ('coms --> check',
    'Error encountered in a configuration file' + nl2 +
    'Cannot decode >>>' + s + '<<< at position ' + IntToStr(code));
    END;
  END;  {of procedure 'check'}
{------------------------------------------------------------}

PROCEDURE average (no: INTEGER);
VAR angle, wcos, wsin: float;
    wdirdev, gcdev,
    wsweight: float;

BEGIN
  gcdev     := gcgrab[no]-gcset[no];

  angle:=winddir[no]*2.0*pi;
  IF wspeed[no] > 0.0 THEN wsweight := wspeed[no]
                      ELSE wsweight := 0.001;

  wcos:=wsweight*COS(angle);
  wsin:=wsweight*SIN(angle);

  awcos[no].Integrate (wcos);
  awsin[no].Integrate (wsin);
  awinddir[no] := atan2 (awsin[no].Integral, awcos[no].Integral) / 360.0;

  IF (NOT calibrate_var[no].active) AND
     (NOT comm_err[no])             THEN BEGIN
    agcont[no].Integrate (gcgrab[no]);
    agc1m[no].Integrate (gcgrab[no]);
    agc5m[no].Integrate (gcgrab[no]);
    END;

  IF runon[no] THEN BEGIN
    proplearn[no].Integrate (propc[no]);
    windlearn[no].Integrate (wspeed[no]);
    END;
  awspeed[no].Integrate (wspeed[no]);
  IF winddir[no]>1 THEN winddir[no]:=winddir[no]-1;
                                          { 1 min wdir std }
  {1-minute average of absolute wind direction fluctuations in degrees}
  wdirdev := ABS(winddir[no]-winddirsave[no]);
  WHILE wdirdev > 0.5 DO wdirdev := wdirdev - 0.5;
  stdwdir[no].Integrate (wdirdev*360.0);
  winddirsave[no] := winddir[no];

  avsd_proc (wspeed_avsd[no], wspeed[no], 1.0);

  outband (gcset[no], gcgrab[no], pr5[no] , gc5p[no]);
  outband (gcset[no], gcgrab[no], pr10[no], gc10p[no]);
  outband (gcset[no], gcgrab[no], pr20[no], gc20p[no]);
  outband (gcset[no], agc1m[no].Integral, pr5[no] , agc1m5p[no] );
  outband (gcset[no], agc1m[no].Integral, pr10[no], agc1m10p[no]);
  outband (gcset[no], agc1m[no].Integral, pr20[no], agc1m20p[no]);
  outband (gcset[no], agc5m[no].Integral, pr1[no] , agc1hr1p[no]);
  outband (gcset[no], agc5m[no].Integral, pr2[no] , agc1hr2p[no]);
  outband (gcset[no], agc5m[no].Integral, pr5[no] , agc1hr5p[no]);
  ncount[no] := ncount[no] + 1.0;

{calculate errors generated by integrating measurements}
  pverr[no].Integrate (ABS(propc[no]-propresp[no]));
  IF NOT calibrate_var[no].active THEN
    conterr[no].Integrate (ABS(gcdev));
  IF windup[no] OR (wspeed[no] < (-0.5)) THEN
    wdstuck[no].Integrate (wdirdev*360.0);  {Note: ws must be working!}
  END;  {of procedure 'average'}
{------------------------------------------------------------}

PROCEDURE clearhist (ring, group, numrings: INTEGER);
CONST max = 3;
VAR i: INTEGER;
{clear all, some, or one of the histograms used in the ring view display;
 'ring'  is the ring number (0 denotes all)
 'group' is one of the histograms kept for that ring (0 denotes all)
 'numrings' is the number of facility rings now passed as argument}
 BEGIN
   IF ring=0
     THEN FOR i := 1 TO numrings DO clearhist (i, group, numrings)
     ELSE IF group=0
       THEN FOR i := 1 TO max DO clearhist (ring, i, numrings)
       ELSE FOR i := 1 TO histbins DO CASE group OF
         1: BEGIN hisi[ring,i] := 0; hisimax[ring] := 0; END;
         2: BEGIN hism[ring,i] := 0; hismmax[ring] := 0; END;
         3: BEGIN hish[ring,i] := 0; hishmax[ring] := 0; END;
         END; {case}
   END;  {of procedure 'clearhist'}
{------------------------------------------------------------}

PROCEDURE histogram;
VAR nor: INTEGER;
    gcnorm: float;

PROCEDURE binhis (value, scale: float; hisnum: INTEGER);
VAR i: INTEGER;
    x: float;

    PROCEDURE incit (VAR val, peak: Longint);
    BEGIN
      INC(val);
      IF peak < val THEN peak := val;
      END;  {of double local procedure 'incit'}

BEGIN
  x := scale*(value-gcnorm)/gcnorm+10.5;
  IF ABS(x) < 32000 THEN i := ROUND(x)
                    ELSE i := 32000;
  IF (i>0) AND (i<21) THEN CASE hisnum OF 
    1: incit (hisi[nor,i], hisimax[nor]);
    2: incit (hism[nor,i], hismmax[nor]);
    3: incit (hish[nor,i], hishmax[nor]);
    END;  {case}
  END;  {of local procedure 'binhis'}

BEGIN
  FOR nor := 1 TO numrings DO IF runon[nor] THEN BEGIN
    IF gcset[nor] > 0.0 THEN gcnorm := gcset[nor]
                        ELSE gcnorm := 1.0;  {bomb proofing}
    binhis (gcgrab[nor],           20.0, 1);
    binhis (agc1m[nor].Integral,   20.0, 2);
    binhis (agc5m[nor].Integral,  200.0, 3);
    END;
  END;  {of procedure 'histogram'}
{---------------------------------------------------------------------}

PROCEDURE lpf_constants;
{Set the TLPF low pass filter object Interval and ResponseTime,
 and thus indirectly the integration constants FLambda and FNu}
VAR ring: INTEGER;
    cond: INTEGER;
BEGIN
  WITH ambient_base, enrich_base[1] DO BEGIN
    Interval := tcont[1];
    ResponseTime := int;
    SeedDone := TRUE;
    RangeMin := low;
    RangeMax := high;
    DefaultValue := default;
    DefaultEnable := TRUE;
    END;
  FOR ring := 1 TO numrings DO BEGIN
    WITH agcont[ring] DO BEGIN 
      Name := 'PID control average - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := gcint[ring]; 
      END;
    WITH agc1m[ring] DO BEGIN 
      Name := 'GC 1-minute integral - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := 60.0; 
      END;
    WITH agc5m[ring] DO BEGIN 
      Name := 'GC 5-minute integral - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := 300.0; 
      END;
    WITH awspeed[ring] DO BEGIN 
      Name := 'Wind speed integral - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := wsint[ring]; 
      RangeMin :=  0.0;
      RangeMax := 25.0;
      END;
    WITH awcos[ring] DO BEGIN 
      Name := 'Wind direction cosine - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := wdint[ring];
      RangeMin := -awspeed[ring].RangeMax;
      RangeMax := +awspeed[ring].RangeMax;
      END;
    WITH awsin[ring] DO BEGIN 
      Name := 'Wind direction sine - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := wdint[ring]; 
      RangeMin := -awspeed[ring].RangeMax;
      RangeMax := +awspeed[ring].RangeMax;
      END;
    WITH stdwdir[ring] DO BEGIN 
      Name := 'Wind direction st dev - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := 60.0; 
      END;
    WITH proplearn[ring] DO BEGIN 
      Name := 'Gas flow valve learn - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := tlearn[ring];
      SeedDone := TRUE;
      RangeMin :=  0.0;
      DefaultValue := 0.0;
      DefaultEnable := TRUE;
      END;
    WITH windlearn[ring] DO BEGIN 
      Name := 'Wind speed learn - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := tlearn[ring]; 
      SeedDone := TRUE;
      RangeMin :=  0.0;
      RangeMax := 25.0;
      DefaultValue := 0.0;
      DefaultEnable := TRUE;
      END;
    WITH pverr[ring] DO BEGIN 
      Name := 'Proportional valve error - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := timeerrint;
      SeedDone := TRUE;
      END;
    WITH conterr[ring] DO BEGIN 
      Name := 'Gas concentration error - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := timeerrint; 
      SeedDone := TRUE;
      END;
    WITH wdstuck[ring] DO BEGIN 
      Name := 'Wind direction stuck - Ring ' + rlabel[ring];
      Interval := tsamp[ring]; 
      ResponseTime := timeerrint; 
      SeedDone := TRUE;
      END;
    FOR cond := 1 TO num_conditionals DO BEGIN
      WITH conditional_value[ring][cond] DO BEGIN
        Interval := tsamp[ring];
        ResponseTime := conditional_var^[ring][cond].int;
        END;
      END;
    END;
  END;  {of procedure 'lpf_constants'}
{---------------------------------------------------------------------}

PROCEDURE show_port (port: INTEGER);
BEGIN
  WITH DataComm.Ports[port] DO IF exists 
    THEN BEGIN
      WRITE ('  YES ');
      CASE switch OF
        0: WITH SerialRec DO
            WRITELN (com:4, speed:10, databits:2,
                     stopbits:2, ' ',parity, '  ',protocol);
        1: WITH BusRec DO
            WRITELN (base:10, addr:10, chan:10, '  ',protocol);
        2: ;
        END; {case switch}
      END
    ELSE WRITELN ('   NO');
  END;  {of procedure 'show_port'}
{---------------------------------------------------------------------}

PROCEDURE show_addr (addrdef: daqc_addr);
BEGIN
  WRITELN;
  WITH addrdef DO BEGIN 
    WRITE (leftjustify(label_name,16));
    IF exists 
      THEN BEGIN
        WRITE (' YES ');
        WRITE (' x', rep_hex(address,2), channel:3);
        IF (bdtype=1) 
          THEN WRITE (range:8:3, gain:13:5, offset:12:6, offscale:10:3)
          ELSE IF invert THEN WRITE ('INVERT':21);
        END
      ELSE WRITE ('  NO');
    END;
  END;  {of procedure 'show_addr'}
{---------------------------------------------------------------------}

PROCEDURE get_addr (VAR ifile: TEXT; key, ring, bdflag: INTEGER; 
                    VAR addrdef: daqc_addr);
{read in parameters for a parallel or serial port from config file
 bdtype 0 is digital; bdtype 1 is analog, i.e. needs eng. conv.}
CONST nl = CHR(13) + CHR(10); 
      nl2 = CHR(13) + CHR(10) + CHR(10);
VAR s: String;
    code: INTEGER;
BEGIN WITH addrdef DO BEGIN
  {
  WRITELN ('Ring seq = ', ring:1, '  Line key expected = ', key:1);
  }
  address := 0;  channel := 0;     range := 0.0;
  gain := 0.0;   offset := 0.0;    offscale := 0.0;
  bdtype := 0;   unit_name := '';  label_name := '';
  READ (ifile, code);  test_key (code, key);
  s := getchunk (ifile, ' ');
  exists := (Pos('-',s) = 0);  {- something is nonexistence flag}
  IF exists THEN BEGIN
    address := str2word (s, code);
    check (s, code);
    END;
  s := getchunk (ifile,' ');
    channel := str2word (s, code);  
    check (s, code);
  IF bdflag = 0 THEN BEGIN  {this is a digital channel}
    READ (ifile, code);
    invert := (code <> 0);
    END;
  IF bdflag = 1 THEN BEGIN  {this is an analog channel}
    bdtype := 1;
    READ (ifile, range);
    IF (range >= 900) THEN
      IF NOT netinfo_installed
        THEN BEGIN
          SetLastError ($20005003);
          FatalErr.Msg (
          'coms --> get_addr --> netinfo_',
          'No network information transfer files are installed' + nl2 +
          'Each device with range code 9xx must have' + nl +
          'a corresponding sequence number 9xx file' + nl + 
          'definition line at the beginning of the' + nl +
          'configuration file before the first ring section.' + nl2 +
          'See CFG.TXT')
          END
        ELSE IF NOT netinfo_ptr^[ROUND(range) MOD 10].init
          THEN netinfo_check (3, TRUE)
          ELSE netinfo_ptr^[ROUND(range) MOD 10].write_only := FALSE;
    READ (ifile, gain);
    READ (ifile, offset);
    READ (ifile, offscale);
    s := getchunk (ifile,'"');  unit_name := getchunk (ifile,'"');
    {LiCor memory allocation}
    IF exists AND (channel IN [21,22,24]) THEN BEGIN
      licor_alloc (address, code);
      IF (code = 0) THEN BEGIN
        licor_addcode (address, ROUND(range), code);
        IF (code = 0) THEN licor_model_set (address, channel, code);
        END;
      IF (code <> 0) THEN BEGIN
        SetLastError ($20005004);
        FatalErr.Msg (
        'coms --> get_addr --> licor_',
        'Sequence: ' + IntToStr(ring) + nl2 +
        'Ring label: ' + rlabel[ring] + nl2 +
        'Line no: ' + IntToStr(key)  + nl2 +
        'Address: ' + IntToStr(address) + nl2 +
        'Channel: ' + IntToStr(channel) + nl2 +
        'LiCor code: ' + FloatToStr(range) + nl2 +
        'ErrorMsg: ' + licor_errmsg[code]);
        END;
      END;
    {ADC's}
    IF exists AND (channel IN [0..15]) THEN
      WITH adc_read^[address] DO 
        select := select Or (1 Shl channel);
    END;  {analog}
  s := getchunk (ifile,'"');  label_name := getchunk (ifile,'"');
  READLN (ifile);
  {
  show_addr (addrdef);
  }
  END;  {of with}
  END;  {of procedure 'get_addr'}
{---------------------------------------------------------------------}

PROCEDURE swind (n: INTEGER);
BEGIN
  WITH sw[n] DO BEGIN
    SetLineStyle (0, 0, ls);
    SetColor (col1);
    windd (x, y, lx, ly, m, col1, col2);
    ptex (x+4, y+2, mess, Black);
    END;
  END;  {of procedure 'swind'}
{------------------------------------------------------------}

PROCEDURE putwindow (iring:INTEGER);
VAR wcolor: INTEGER;
BEGIN
  IF NOT sacceptactive THEN BEGIN
    Str(propc[iring]:5:1,s);  
    sw[maxrings+4*(iring-1)+4].mess:=s;  
    swind(maxrings+4*(iring-1)+4);
    END;
  Str(gcset[iring]:5:1,s);  
  sw[maxrings+4*(iring-1)+3].mess:=s;  
  swind(maxrings+4*(iring-1)+3);
  ptex(xwind[iring]+52,ywind[iring]+26,sgcgrab[iring],7);
  Str(gcgrab[iring]:6:1,sgcgrab[iring]);
  ptex(xwind[iring]+52,ywind[iring]+26,sgcgrab[iring],0);
  ptex(xwind[iring]+152,ywind[iring]+26,spropresp[iring],7);
  Str(propresp[iring]:5:1,spropresp[iring]);
  ptex(xwind[iring]+152,ywind[iring]+26,spropresp[iring],0);
  ptex(xwind[iring]+52,ywind[iring]+36,swspeed[iring],7);
  Str(wspeed[iring]:5:2,swspeed[iring]);
  ptex(xwind[iring]+52,ywind[iring]+36,swspeed[iring],0);
  ptex(xwind[iring]+144,ywind[iring]+36,swwdir[iring],7);
  Str(wwdir[iring]:3,swwdir[iring]);
  ptex(xwind[iring]+144,ywind[iring]+36,swwdir[iring],0);
  IF fan_debug_set[iring] THEN wcolor := LightRed ELSE wcolor := LightGray;
  windd (xwind[iring]+220, ywind[iring]+100, 20, 6, 1, 15, wcolor);
  ptex (xwind[iring]+224, ywind[iring]+102, 'Fan', Black);
  IF gas_debug_set[iring] THEN wcolor := LightRed ELSE wcolor := LightGray;
  windd (xwind[iring]+220, ywind[iring]+116, 20, 6, 1, 15, wcolor);
  ptex (xwind[iring]+224, ywind[iring]+118, 'Gas', Black);
  END;
{------------------------------------------------------------}

PROCEDURE post (where,ip,nv,col1: INTEGER; act: BOOLEAN; style: INTEGER);
VAR pp: array[1..9,1..2] OF INTEGER;
    col2,m,x,y,dx,dy: INTEGER;
    theta: REAL;
BEGIN
  CASE where OF
  1:BEGIN x:=7; y:=5; END;
  4:BEGIN x:=7; y:=180; END;
  2:BEGIN x:=342; y:=5; END;
  3:BEGIN x:=342; y:=180; END
  Else
    BEGIN x:=175; y:=100; END
  END;

  m:=22;
  theta := (ip-0.5)*2.0*pi/nv;
  x := x + ROUND(m*(6.4+6.3*SIN(theta)));
  y := y + ROUND(m*(3.6-3.6*COS(theta)));

  dx:=3; 
  dy:=2;

   x := ROUND (( x * grmaxx) DIV 640);
  dx := ROUND ((dx * grmaxx) DIV 640);
   y := ROUND (( y * grmaxy) DIV 350);
  dy := ROUND ((dy * grmaxy) DIV 350);

  pp[1,1]:=x-2*dx; pp[1,2]:=y-dy;
  pp[2,1]:=x-2*dx; pp[2,2]:=y+dy;
  pp[3,1]:=x-dx;   pp[3,2]:=y+2*dy;
  pp[4,1]:=x+dx;   pp[4,2]:=y+2*dy;
  pp[5,1]:=x+2*dx; pp[5,2]:=y+dy;
  pp[6,1]:=x+2*dx; pp[6,2]:=y-dy;
  pp[7,1]:=x+dx;   pp[7,2]:=y-2*dy;
  pp[8,1]:=x-dx;   pp[8,2]:=y-2*dy;
  pp[9,1]:=x-2*dx; pp[9,2]:=y-dy;

  SetLineStyle (0,0,3);     SetColor (0);    DrawPoly (9,pp);
  SetLineStyle (0,0,style); SetColor (col1);
  IF act THEN col2 := LightRed ELSE col2 := 8;
  SetFillStyle (SolidFill, col2);
  FillPoly (9,pp);
  END;  {of procedure 'post'}
{------------------------------------------------------------}

PROCEDURE putring (where, iring, nv: INTEGER);
VAR j: INTEGER;
BEGIN
  FOR j := 1 TO nv DO
    IF vnoact[iring,j] <> vact[iring,j] THEN BEGIN
      post (where,j,nv,7,vact[iring,j],0);
      vnoact[iring,j] := vact[iring,j];
      END;
  END;  {of procedure 'putring'}

{------------------------------------------------------------}
PROCEDURE putaxes (xr, yr, hisno: INTEGER);
VAR xscale, yscale: REAL;
    itik: INTEGER;
    s1:   String;
PROCEDURE line_scaled (x1, y1, x2, y2: INTEGER);
BEGIN
  Line (ROUND(x1*xscale), ROUND(y1*yscale), 
        ROUND(x2*xscale), ROUND(y2*yscale));
  END;  {of local procedure 'line_scaled'}
BEGIN
  xscale := grmaxx/640;
  yscale := grmaxy/350;
  SetColor (0);
  line_scaled (xr+4,  yr+90, xr+200, yr+90);
  line_scaled (xr+100,yr+90, xr+100, yr+46);
  FOR itik:=-9 TO 9 DO
    line_scaled (xr+100-itik*10, yr+90, xr+100-itik*10, yr+92);
  SetLineStyle (0, 0, 3);
  SetColor (0);
  FOR itik:=-2 TO 2 DO BEGIN
    line_scaled (xr+100-itik*40, yr+90, xr+100-itik*40, yr+93);
    IF (hisno = 3) THEN Str (itik*2:1, s1) ELSE Str (itik*20:2, s1);
    ptex (xr+90+itik*40, yr+95, s1, 0);
    END;
  SetLineStyle (0, 0, 0);
  ptex (xr+180, yr+65, '[%]', 0);
  END;  {of procedure 'putaxes'}
{------------------------------------------------------------}

PROCEDURE puthisto (ifire: INTEGER);
VAR il, xr, yr: INTEGER;
    ar: ARRAY[1..20] OF REAL;
    maxx: REAL;
    xscale,
    yscale: REAL;

PROCEDURE line_scaled (x1, y1, x2, y2: INTEGER);
BEGIN
  Line (Round(xscale*x1), Round(yscale*y1), 
        Round(xscale*x2), Round(yscale*y2));
  END;  {of local procedure 'line_scaled'}

BEGIN
  xscale := grmaxx/640;  
  yscale := grmaxy/350;

  CASE hsel[ifire] OF
    1:BEGIN
        FOR il:=1 TO 20 DO ar[il] := hisi[ifire,il];
        maxx := hisimax[ifire];
        END;
    2:BEGIN
        FOR il:=1 TO 20 DO ar[il] := hism[ifire,il];
        maxx := hismmax[ifire];
        END;
    3:BEGIN
        FOR il:=1 TO 20 DO ar[il] := hish[ifire,il];
        maxx := hishmax[ifire];
        END;
    Else maxx := 999;
    END;  {case}

  SetLineStyle (0, 0, 3);
  xr := xwind[ifire]-5;  
  yr := ywind[ifire]+89;
  IF maxx>0.5 THEN
    FOR il:=1 TO 20 DO BEGIN
      SetColor(7);
      line_scaled (xr+il*10, yr, xr+il*10, yr-45);
      IF (il IN [ 1.. 6]) OR (il IN [15..20]) THEN SetColor(Red);
      IF (il IN [ 7.. 8]) OR (il IN [13..14]) THEN SetColor(Magenta);
      IF (il IN [ 9..13])                     THEN SetColor(Blue);
      line_scaled (xr+il*10, yr, xr+il*10, yr-ROUND((ar[il]/maxx)*45));
      END;
  END;  {of procedure 'puthisto'}
{------------------------------------------------------------}

PROCEDURE setco2qt (ring: INTEGER; request: BOOLEAN);
{This routine will introduce delays into the change
 in position of CO2 manifold quarter turn valves.
 Note:  TRUE  is a request to turn ON
        FALSE is a request to turn OFF
 J.N. -- May 31, 1991
         Aug 18, 1998  Moved to COMU from COMP
}
VAR doit: BOOLEAN;
    i: INTEGER;
BEGIN
  WITH co2qt[ring] DO BEGIN
    asked := request;
    IF state <> asked THEN BEGIN
      doit := TRUE;
      FOR i := 1 TO numrings DO
        IF ABS (tint - co2qt[i].lastchange) < co2qt[i].delay
          THEN doit := FALSE;
      IF doit THEN BEGIN
          state := asked;
          lastchange := tint;
          END;
      END;
    END;
  END;  {of procedure 'setco2qt'}
{------------------------------------------------------------}

PROCEDURE sidebar (msg: String; ringno: INTEGER);
{For general use by 'template' local procedures.
 JN  95/06/15  Original
 }
BEGIN
  ClrScr;
  IF msg <> '' THEN xywrite (1, 1, LightRed, msg);
  xywrite (50, 1, LightGreen, '<ESC> Return to previous menu');
  mouse_clear (0);
  mouse_add (3, 50, 80, 1, 1, 27, 0);
  IF ringno IN [1..numrings] THEN BEGIN
    xywrite (50, 2, LightGreen, '<-+>  Change ring');  
    mouse_add (3, 50, 51, 2, 2, ORD('-'), 0);
    mouse_add (3, 52, 80, 2, 2, ORD('+'), 0);
    mouse_add (2, 50, 80, 2, 2, ORD('+'), 0);
    xywrite (35, 1, Yellow, 'RING '+rlabel[ringno]);
    END;
  END;  {of procedure 'sidebar'}
{------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of unit COMS.PAS...}
END.
