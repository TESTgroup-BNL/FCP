Unit riv;
{$R+}
{$H-}

{*
 * Name:     RIVyy.PAS
 *
 * Purpose:  BNL FACE Project
 *           Used by COM and DAT programs
 *           Graphics mode display of all rings
 *
 * Version:     1
 * Date:        04-04-90
 * Programmer:  Z. Kolber
 * Language:    TurboPascal 5.0
 * Hardware:    Dell 310 20MHz 80386 AT
 * O/S:         MS-DOS 3.3
 * Changes:
 *   (1) As developed to this point by Z. Kolber
 *
 * Version:     2
 * Date:        04-19-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Excessively long lines were rationalized
 *   (2) Some comments added
 *   (3) TYPE float = Single added to declaration unit
 *   (4) REAL types in all units redeclared as float
 *       (see J.N. memo "FACE Binary Records Changed" 4/19/90)
 *
 * Version:     3
 * Date:        11-08-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Made use of procedure 'changering'.
 *
 * Version:     4
 * Date:        April 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Various corrrections to handle a variable number
         of rings.
 *
 * Version:     5
 * Date:        2 June 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add c-key option when in histogram window open
 *       which clears (zeroes) all histograms for all rings.
 *
 * Version:     6
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as RIV94.                                       [12/10/93]
 *
 * Version:     7
 * Date:        March 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Remove SHUTD option.  Don't see that it serves any        [03/16/94]
 *       purpose not also served by the new OFF setting of the
 *       algorithm page.  In addition, SHUTD was bypassing usual
 *       housekeeping done when runon=FALSE.
 *   (2) Remove option to change GCSET when in DEBUG mode.         [03/16/94]
 *       No point in doing this since vent pipe valves and
 *       proportional valve are under operator, not algortihm,
 *       control.  And again, this was bypassing usual housekeeping.
 *   (3) When DEBUG entered, VVPs will be in low wind pattern,     [03/16/94]
 *       not all shut off.  This is to avoid possible damage
 *       blocking all airflow.  It is then up to the operator
 *       to set the VVPs as he/she desires without damaging equipment.
 *   (4) Flash message on main menu (status) page if in DEBUG.     [03/16/94]
 *   (5) Since "c" being used in OPER mode to clear all histos,    [03/16/94]
 *       use "s" (shut=schliessen) instead. Open=oeffnen remains "o".
 *   (6) Add help screen.  Use <F1>, ?, h, or H.  Returns to main. [03/16/94]
 *   (7) Fixed bug introduced a couple of years ago when I         [03/16/94]
 *       "cleaned" unit comp procedure algorithm() code which
 *       clamped pv control to 0.0 (but not ring picture value!)
 *       when in DEBUG.
 *   (8) Position of a ring on screen determined by topo[ring]     [03/16/94]
 *       which is declared globally in COMD and set in procedure ringv().
 *       First argument given to post() is now position, not ring nr.
 *
 * Version:     8
 * Date:        June 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add Uses coms to pick up new home of post()               [94/06/12]
 *
 * Version:     9
 * Date:        Feb-Mar 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes RIV95.PAS                                         [95/02/21]
 *
 * Version:     10
 * Date:        Oct-Dec 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes RIV96.PAS; update Uses.                           [95/10/14]
 *   (2) Delete IF CH1 topo = code; now in COM main config().      [95/10/15]
 *   (3) Code cleanup related to getting (2) to work.              [95/10/15]
 *   (4) Add numvalvs arg to post() call.                          [95/12/20]
 *
 * Version:     11
 * Date:        Dec 1996 - Jan 1997
 * Changes:
 *   (1) Becomes RIV97.PAS; update Uses.                           [96/12/22]
 *   (2) Add numrings to changering & clearhist arg lists.         [97/01/20]
 *   (3) Move initial clearing of histos here from com97.          [97/01/20]
 *
 * Version:     12
 * Date:        July/August/September 1997
 * Changes:
 *   (1) Add fan and gas switch windows, and debugging control.    [97/07/07]
 *   (2) Insert IF topo[ring] IN [1..4] in a lot of places.        [97/07/22]
 *   (3) Possible description[] window at bottom of a ring picture.[97/08/02]
 *   (4) Add Watchdog window.  "w" will toggle watchdog_debug.     [97/09/28]
 *
 * Version:     13
 * Date:        December 1997
 * Changes:
 *   (1) Becomes RIV98.PAS; update Uses.                           [97/12/23]
 *
 * Version:     14
 * Date:        1999-2000
 * Changes:
 *   (1) Becomes RIV99.PAS; update Uses.                           [99/12/13]
 *   (2) IFDEF TURBO and DELPHI for Uses.                          [00/01/19]
 *   (3) ringv: declare loop index var 'iring'.                    [00/01/19]
 *   (4) $H- directive added so old Pascal strings used.           [00/02/14]
 *   (5) ringv: IFDEF DELPHI turn statscr back on!                 [00/02/14]
 *   (6) ringv: remove statscr=TRUE at end.                        [00/02/14]
 *   (7) add Uses Windows so WinAPI's can be called.               [00/04/05]
 *   (8) ringv: MapMode, WindowExt, ViewportExt added for scaling  [00/04/05]
 *   (9) ringv: text SetBkMode = TRANSPARENT.                      [00/04/06]
 *  (10) ringv: give screen a title.                               [00/04/06]
 *  (11) help: must statscr=F, ClrScr, ..., statscr=T.             [00/04/06]
 *  (12) ringv: add NOT IsWindow() to exit check.                  [00/04/06]
 *  (13) ptex: procedure erased since duplicate in comu99.         [00/04/12]
 *  (14) windd: procedure erased since duplicate in comu99.        [00/04/12]
 *  (15) after InitGraph, add grmaxx|y := GetMaxX|Y.               [00/04/12]
 *  (16) caccept: scale the x and y arguments.                     [00/04/12]
 *  (17) make call to new procedure 'putaxes' in coms99. [00/04/17][00/04/12]
 *  (18) swind: remove unused x, y, m local vars.                  [00/04/13]
 *  (19) kbin: make module special version sensitive to IsWindow   [00/04/17]
 *  (20) cancel change #12.                                        [00/04/17]
 *  (21) help: REPEAT kbin UNTIL.  Otherwise now exits immediately [00/04/17]
 *  (22) ringv: in debug mode, use lt green ring for selected valve[00/04/17]
 *  (23) ringv: SetBkMode for memDC to transparent as well         [00/04/18]
 *  (24) ringv: Quit & Help buttons w/ mouse support               [00/05/07]
 *  (25) ringv: keystroke Q made equivalent to ESC (doexit)        [00/05/07]
 *  (26) help:  $IFDEF DELPHI use of mouse page added              [00/05/07]
 *  (27) mxscale, myscale: new functions for scaling mouse coords  [00/05/07]
 *  (28) doexit, dohelp, dotopo (new): were prog global, now mod   [00/05/07]
 *  (29) topo_select: new test mode procedure to select rings      [00/05/07]
 *  (30) sw[] indices: 4*iring --> base1 = maxrings+4*(iring-1)    [00/05/08]
 *  (31) sw[] indices: 20      --> base2 = 5*maxrings              [00/05/08]
 *  (32) rselinit: new proc to set rsel to fist shown ring         [00/05/08]
 *  (33) submice:  new proc to define rsel dependent mouse coords  [00/05/08]
 *  (34) Uses: add musca to list                                   [00/11/07]
 *  (35) topo_select: remove i: INTEGER not used by the procedure  [00/11/07]
 *  (36) submice: in CASE topo[] provide an Else to suppress hint  [00/11/07]
 *
 * Version:     15
 * Date:        2001
 * Changes:
 *   (1) display: add clearing screen to specified background color[01/04/18]
 *   (2) display: use K-key to toggle background color             [01/04/18]
 *   (3) riv_background: new module variable                       [01/04/18]
 *   (4) (init): initialize riv_background to Black for Jaak       [01/04/18]
 *   (5) (init): initialize riv_background to LightBlue for C.F.   [01/05/11]
 *   (6) caccept, saccept: unsuccessful changes for caret & BS     [01/10/03]
 *
 * Version:     16
 * Date:        2002
 * Changes:
 *   (1) Unit name now riv.pas                                     [02-03-21]
 *   (2) Uses comd, etc.                                           [02-03-21]
 *   (3) Remove $IFDEF TURBO code $ENDIF, $IFDEF DELPHI $ENDIF     [02-03-25]
 *   (4) Many changes related to windows look-and-feel upgrade     [02-09-16]
 *   (5) Many changes related to windows look-and-feel upgrade     [02-09-17]
 *   (6) ringv: add debug-mode yellow VVP valve selected window    [02-09-19]
 *   (7) Remove watch debug window                                 [02-11-16]
 *
 * Version:     17
 * Date:        2003
 * Changes:
 *   (1) Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS [03-01-24]
 *   (2) Replace all "Topology" by "RVSetup"                       [03-01-29]
 *   (3) help: does nothing if console not allocated (NOT statscr) [03-03-19]
 *   (4) ringv: remove statscr := TRUE; statscr has new meaning    [03-03-19]
 *   (5) kbin: special version removed; no longer required         [03-03-19]
 *   (6) topo_select: make sure RVSetup form doesn't exist already [03-05-09]
 *   (7) comd/Globals changes                                      [03-05-28]
 *   (8) Delete topo_select; replace by call to RVSetup.Select     [03-05-29]
 *   (9) Enter debug: initial pattern_windlow -> pattern_runoff    [03-05-31]
 *  (10) Use SysUtils.Sleep(500) for mouse-F&G key-C etc. problems [03-06-15]
 *
 * Version:     18
 * Date:        2007
 * Changes:
 *   (1) help: change from console screen to LblForm and update    [07-06-15]
 *   (2) Do not exit ring pictures when help is selected           [07-06-15]
 *
 * Version:     19
 * Date:        2011
 * Changes:
 *   (1) ringv: when only the upper left panel is active...      [2011-09-22]
 *     Added vars multi, rect, OnlyUL, NumPanelsActive
 *     (a) relocate position of Quit, Help, Setup buttons
 *     (b) resize ring picture window
 *     (c) relocate position of yellow VVP debugging window      [2011-10-18]
 *}

Interface

USES
{$IFDEF LINUX}
  QForms, QGraphics,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics,
{$ENDIF}
  Windows, SysUtils,
  crt32, graph32,
  comd, Globals, gra, comp, coms, comu, musca;

PROCEDURE rselinit;
PROCEDURE ringv;
PROCEDURE BackgroundColorSet (color: TColor);
FUNCTION BackgroundColorGet: TColor;

Implementation

Uses RVSetup, LblForm;

VAR xacc, yacc: INTEGER;
    doexit, dohelp, dotopo: BOOLEAN;
    riv_background: TColor;

PROCEDURE caccept;
BEGIN
  kbin;
  IF (alr <> 8)
    THEN BEGIN
      MoveTo (ROUND(xacc*grmaxx DIV 640), ROUND(yacc*grmaxy DIV 350));
      OutText(calr);
      xacc:=xacc+8;
      END
    ELSE BEGIN
      xacc:=xacc-8;
      OutText(calr);
      END;
  END;  {of procedure 'caccept'}

PROCEDURE saccept;
VAR i: Byte;
BEGIN
  caret_enable := TRUE;
  fillchar(svalue,sizeof(svalue),' ');
  svalue[0]:=#30;
  Delete(svalue,1,30);
    REPEAT
    caccept; 
    IF (alr IN [13, 32..127]) THEN svalue:=svalue+calr;
    IF (alr = 8) THEN BEGIN
      i := ORD(svalue[0]);
      IF (i > 0) THEN svalue[0] := CHR(i-1);
      END;
    UNTIL (alr=13) OR (alr=27);
  IF (alr=27) THEN svalue := '';
  caret_enable := FALSE;
  END;

PROCEDURE iaccept(VAR lvalue:Longint);
VAR code:INTEGER;
    rr:float;
BEGIN
  saccept;
  Val(Copy(svalue,1,Length(svalue)-1),rr,code);
  lvalue:=ROUND(rr);
  END;

PROCEDURE raccept(VAR rvalue:float);
VAR code:INTEGER;
BEGIN
  saccept;
  Val(Copy(svalue,1,Length(svalue)-1),rvalue,code);
  END;

PROCEDURE ringd (x,y: INTEGER; m: float; col: INTEGER);
VAR p: ARRAY[1..17,1..2] OF INTEGER;
    mm,hor,ver,a,b,c,d,e: INTEGER;
BEGIN
  a:=ROUND(2.4*m);
  b:=ROUND(1.83*m);
  c:=ROUND(0.98*m);
  d:=ROUND(0.54*m);
  e:=ROUND(1.306*m);
  hor:=a;
  ver:=ROUND(1.5*m);
  mm:=ROUND(m);
  p[1,1]:=x+ROUND(m*5.27);  p[1,2]:=y;
  p[2,1]:=p[1,1]-a;         p[2,2]:=y+d;
  p[3,1]:=p[2,1]-b;         p[3,2]:=p[2,2]+mm;
  p[4,1]:=x;                p[4,2]:=p[3,2]+e;
  p[5,1]:=x;                p[5,2]:=p[4,2]+ver;
  p[6,1]:=x+c;              p[6,2]:=p[5,2]+e;
  p[7,1]:=p[6,1]+b;         p[7,2]:=p[6,2]+mm;
  p[8,1]:=p[7,1]+a;         p[8,2]:=p[7,2]+d;
  p[9,1]:=p[8,1]+hor;       p[9,2]:=p[8,2];
  p[10,1]:=p[9,1]+a;        p[10,2]:=p[9,2]-d;
  p[11,1]:=p[10,1]+b;       p[11,2]:=p[10,2]-mm;
  p[12,1]:=p[11,1]+c;       p[12,2]:=p[11,2]-e;
  p[13,1]:=p[12,1];         p[13,2]:=p[12,2]-ver;
  p[14,1]:=p[13,1]-c;       p[14,2]:=p[13,2]-e;
  p[15,1]:=p[14,1]-b;       p[15,2]:=p[14,2]-mm;
  p[16,1]:=p[15,1]-a;       p[16,2]:=p[15,2]-d;
  p[17,1]:=p[1,1];          p[17,2]:=p[1,2];
  SetLineStyle (0, 0, 3);
  SetColor (col);
  DrawPoly(17,p);
END;

PROCEDURE swind (n: INTEGER);
VAR hor, ver: INTEGER;
BEGIN
  WITH sw[n] DO BEGIN
    hor := lx; 
    ver := ly;
    SetLineStyle (0, 0, ls);
    SetColor (col1);
    windd (x, y, hor, ver, m, col1, col2);
    ptex (x+4, y+2, mess, 0);
    END;
  END;  {of procedure 'swind'}
{------------------------------------------------------------}

PROCEDURE help;  {for ring picture unit}
{$H+}
CONST nl  = CHR(13) + CHR(10);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
CONST help_string =
  'MOUSE CLICK COMMANDS  <> denotes alternative key stroke' +nl2+ 
  '[Quit]  Exit ring pictures screen <Esc> <Q>' +nl+
  '[Help]  This window <F1> <H> <?>' +nl+
  '[Setup] Select what rings to display and where on screen <F2> <T>' +nl+
  '        A ring can only be displayed at one position.' +nl2+
  '[Ring]  Click ring number button to select that ring <+->' +nl2+
  'All actions below apply only to the selected ring' +nl2+
  '[Hist] Left click to select this button <UpArrow> <DownArrow>' +nl+
  '       Right click choose histogram type <SP>' +nl+
  '       Clear histogram, active ring and histogram type only <I only>' +nl+
  '       Clear histogram, all rings and types <C only>' +nl2+
  '[Mode] Left click to select this button <UpArrow> <DownArrow>' +nl+
  '       Right click to toggle debugging on/off <SP>' +nl2+
  'The following operations are active only in debug mode.' +nl2+
  '[FCont] Left click to select this button <UpArrow> <DownArrow>' +nl+
  '        Right click change gas flow <SP>' +nl2+
  '[Fan]  Click to toggle fan between on (red) and off (gray) <F>.' +nl+
  '[Gas]  Click to toggle gas quarter turn valve open and closed <G>.' +nl2+
  'VVP    Click to select a VVP valve <RightArrow> <LeftArrow>, then...' +nl+
  'valve  Left click to close valve (red)  <C> <S>' +nl+
  'icons: Right click to open valve (gray) <O>' +nl2+nl2+
  '';
VAR frmHelp: TLblForm;
BEGIN
  frmHelp := TLblForm.Create(Application);
  WITH frmHelp DO BEGIN
    LabelFontNameSet ('Courier New');
    LabelFontHeightSet (-16);
    Display ('Ring pictures > Help', '');
    BodyAppend (help_string);
    AutoSize := TRUE;
    LabelFontHeightSet (-16);
    END;
  END;  {of procedure 'help' of ring picture unit}
{$H-}
{------------------------------------------------------------}

FUNCTION mxscale (ega: INTEGER): INTEGER;
VAR temp: Longint;
BEGIN
  temp := ega * grmaxx;
  mxscale := ROUND(temp/640.0);
  END;  {of function 'mxscale' for mouse coordinate scaling}
{------------------------------------------------------------}

FUNCTION myscale (ega: INTEGER): INTEGER;
VAR temp: Longint;
BEGIN
  temp := ega * grmaxy;
  myscale := ROUND(temp/350.0);
  END;  {of function 'myscale' for mouse coordinate scaling}
{------------------------------------------------------------}

PROCEDURE submice (start, ring, window, valve: INTEGER);
VAR i: INTEGER;
    xc, yc,
    x0, y0,
    x1, y1,
    x2, y2: INTEGER;
    theta:  REAL;
BEGIN
  mouse_clear (start-1);

  {top 4 subwindows -- select: ahr = [11..14]  change: alr = 32}
  FOR i := 1 TO 4 DO 
    IF i<>3 THEN 
      WITH sw[maxrings+4*(ring-1)+i] DO BEGIN 
        x1 := mxscale(x);
        x2 := mxscale(x+48);
        y1 := myscale(y);
        y2 := myscale(y+14);
        mouse_add (1, x1, x2, y1, y2, 0, 10+i);
        IF i = window THEN
        mouse_add (2, x1, x2, y1, y2, 32, 0);
        END;

  IF debug[ring] THEN BEGIN
  
  {Fan and Gas windows}
  x1 := mxscale(xwind[ring]+220);
  x2 := mxscale(xwind[ring]+220+30);
  y1 := myscale(ywind[ring]+100);
  y2 := myscale(ywind[ring]+100+14);
  mouse_add (3, x1, x2, y1, y2, ORD('F'), 0);
  y1 := myscale(ywind[ring]+116);
  y2 := myscale(ywind[ring]+116+14);
  mouse_add (3, x1, x2, y1, y2, ORD('G'), 0);

  {VVP valves}
  CASE topo[ring] OF
    1: BEGIN  x0 :=   7;  y0 :=   5;  END;
    2: BEGIN  x0 := 342;  y0 :=   5;  END;
    3: BEGIN  x0 := 342;  y0 := 180;  END;
    4: BEGIN  x0 :=   7;  y0 := 180;  END;
    Else
       BEGIN  x0 := 175;  y0 := 100;  END;
    END;
  FOR i := 1 TO numvalvs DO BEGIN
    theta := (i-0.5) * 2.0*Pi / numvalvs;
    xc := x0 + ROUND (22.0*(6.4+6.3*SIN(theta)));
    yc := y0 + ROUND (22.0*(3.6-3.6*COS(theta)));
    x1 := mxscale(xc-8);
    y1 := myscale(yc-5);
    x2 := mxscale(xc+8);
    y2 := myscale(yc+5);
    IF i = valve THEN BEGIN
      mouse_add (1, x1, x2, y1, y2, ORD('C'), 0);
      mouse_add (2, x1, x2, y1, y2, ORD('O'), 0);
      END;
    mouse_add (3, x1, x2, y1, y2, 0, 100+i);
    END;
  
  END; {when debugging only}

  END;  {of procedure 'submice'}
{------------------------------------------------------------}

PROCEDURE rselinit;
BEGIN
  rsel:=1;
  WHILE (NOT (topo[rsel] IN [1..4])) AND (rsel < numrings) DO INC (rsel);
  END;  {of procedure 'rselinit'}
{------------------------------------------------------------}

PROCEDURE ringv;
VAR xr, yr: INTEGER;
    itik, ip, ir, iw: INTEGER;
    s1: String;
    x: float;
    iring,
    base1,
    base2: INTEGER;
    multi: INTEGER;  {used in positioning 3 buttons}
    rect: TRect;     {used for possbile resizing}
    OnlyUL: BOOLEAN;
    NumPanelsActive: INTEGER;

BEGIN;
{***}{$H+} {Application.MessageBox ('Marker 1', 'RIV', 0);} {$H-}
  InitGraph(grdriver,grmode,'');

  {If upper left is the only active panel, shrink window size}
  OnlyUL := FALSE;
  NumPanelsActive := 0;
  FOR iring := 1 TO numrings DO BEGIN
    IF topo[iring] IN [1..4] THEN INC(NumPanelsActive);
    IF topo[iring] = 1       THEN OnlyUL := TRUE;
    END;
  OnlyUL := OnlyUL AND (NumPanelsActive = 1);

  IF OnlyUL THEN BEGIN
    Windows.GetWindowRect (graph32.hWndGraph, rect);
    Windows.SetWindowPos (
      graph32.hWndGraph,
      0,
      0, 0,
      rect.right DIV 2 + 38, rect.bottom DIV 2,
      SWP_NOMOVE Or SWP_NOZORDER);
    END;

  grmaxx := GetMaxX;
  grmaxy := GetMaxY;

  {Paint whole client background}
  gra.screen (0.0, 0.0, 1.0, 1.0);
  gclear (0.0, 0.0, 1.0, 1.0, riv_background);

  SetBkMode (hDCGraph, TRANSPARENT);
  SetBkMode (memDC,    TRANSPARENT);
{$H+}
  SetWindowText (hWndGraph, PCHAR('Ring View and Debugging Screen'));
{$H-}
{Try automatic scaling}
{remove...
  SetMapMode (hWndGraph, MM_ANISOTROPIC);
  SetWindowExtEx (hWndGraph, EGAHiWidth, EGAHiHeight, NIL);
  CASE grdriver OF
    EGA:     BEGIN xr := EGAHiWidth;     yr := EGAHiHeight;     END;
    VGA:     BEGIN xr := VGAHiWidth;     yr := VGAHiHeight;     END;
    IBM8514: BEGIN xr := IBM8514HiWidth; yr := IBM8514HiHeight; END;
    END;
  SetViewportExtEx (hWndGraph, xr, yr, NIL);
...}

  base2 := 5*maxrings;

  FOR iw := 1 TO numrings DO IF (topo[iw] IN [1..4]) THEN WITH sw[iw] DO BEGIN
    ip := topo[iw];
    {Standard ring arrangement is   1  2
                                    4  3}
    CASE ip OF
      1: BEGIN  x:=46;   y:=34;   END;
      2: BEGIN  x:=381;  y:=34;   END;
      3: BEGIN  x:=381;  y:=209;  END;
      4: BEGIN  x:=46;   y:=209;  END;
      END;  {of case}
    lx:=182;  ly:=90;
    col1:=15; col2:=7;
    ls:=1; mess:=''; m:=2;
    END;

  base1 := maxrings;
  FOR iw := base1+1 TO base1+4*numrings DO WITH sw[iw] DO BEGIN
    lx := 38; ly := 4; col2 := 15; col1 := 15; ls:=1; m:=1;
    END;

  FOR ir:=1 TO numrings DO IF (topo[ir] IN [1..4]) THEN BEGIN
    base1 := maxrings + 4 * (ir-1);
         IF oper[ir]    THEN sw[base1+1].mess:='OPER'
    ELSE IF debug[ir]   THEN sw[base1+1].mess:='DEBUG';
         IF histo[ir]=1 THEN sw[base1+2].mess:='Inst '
    ELSE IF histo[ir]=2 THEN sw[base1+2].mess:='1 Min'
    ELSE IF histo[ir]=3 THEN sw[base1+2].mess:='5 Min';
    END;

  FOR iw := 1 TO numrings DO
  IF (topo[iw] IN [1..4]) THEN WITH sw[base2+iw] DO BEGIN
    ly:=2;
    col2:=LightMagenta; col1:=White;
    ls:=1; m:=1.5;
    CASE topo[iw] OF
      1: BEGIN x:=141-8*Length(descriptor[iw]) DIV 2; y:=142;
               mess:=' '+descriptor[iw]; lx:= 8*Length(descriptor[iw]); END;
      2: BEGIN x:=471-8*Length(descriptor[iw]) DIV 2; y:=142;
               mess:=' '+descriptor[iw]; lx:= 8*Length(descriptor[iw]); END;
      3: BEGIN x:=471-8*Length(descriptor[iw]) DIV 2; y:=316;
               mess:=' '+descriptor[iw]; lx:= 8*Length(descriptor[iw]); END;
      4: BEGIN x:=141-8*Length(descriptor[iw]) DIV 2; y:=316;
               mess:=' '+descriptor[iw]; lx:= 8*Length(descriptor[iw]); END;
      END;  {of case}
    END;

  tinter;

  IF OnlyUL THEN multi := 1 ELSE multi := 2;
  windd (multi*301,  0, 26, 6, 1, 15, LightBlue);
  ptex  (multi*302,  2, 'Quit', White);
  windd (multi*301, 14, 26, 6, 1, 15, LightBlue);
  ptex  (multi*302, 16, 'Help', White);
  windd (multi*301, 28, 26, 6, 1, 15, LightBlue);
  ptex  (multi*302, 30, 'Setup', White);

  mouse_clear (0);
  {#1 Quit} mouse_add (3, 
    mxscale(multi*300), mxscale(multi*320), myscale(  1), myscale( 14), 27, 0);
  {#2 Help} mouse_add (3, 
    mxscale(multi*300), mxscale(multi*320), myscale( 15), myscale( 28), 0, 59);
  {#3 Topo} mouse_add (3, 
    mxscale(multi*300), mxscale(multi*320), myscale( 29), myscale( 42), 0, 60);
  {#5 to #8 Ring windows UL, UR, LR, LL} 
  mouse_add (3, mxscale(116), mxscale(200), myscale( 16), myscale( 30), 0,1);
  mouse_add (3, mxscale(446), mxscale(530), myscale( 16), myscale( 30), 0,2);
  mouse_add (3, mxscale(446), mxscale(530), myscale(190), myscale(204), 0,3);
  mouse_add (3, mxscale(116), mxscale(200), myscale(190), myscale(204), 0,4);
  {Completes the "permanent" rsel independent list.  See submice() calls.}
  
  FOR iw := (base2+1) TO (base2+numrings) DO 
    IF (descriptor[iw-base2] <> '') AND (topo[iw-base2] IN [1..4])
      THEN swind(iw);

  FOR ir := 1 TO numrings DO 
  IF (topo[ir] IN [1..4]) THEN WITH sw[base2+ir] DO BEGIN
    lx:=50;  ly:=4;
    col2:=LightGray; col1:=White;
    ls:=1; m:=1.5;
    CASE topo[ir] OF
      1: BEGIN x:=116; y:=16;  mess:=' Ring '+rlabel[ir]; END;
      2: BEGIN x:=446; y:=16;  mess:=' Ring '+rlabel[ir]; END;
      3: BEGIN x:=446; y:=190; mess:=' Ring '+rlabel[ir]; END;
      4: BEGIN x:=116; y:=190; mess:=' Ring '+rlabel[ir]; END;
      END;  {of case}
    END;
  sw[base2+rsel].col2:=LightGreen; sw[base2+rsel].col2:=LightGreen;
  tinter;
  
  FOR iw := (base2+1) TO (base2+numrings) DO 
   IF (topo[iw-base2]) IN [1..4]
     THEN swind(iw);
  tinter;

  FOR iring := 1 TO numrings DO IF (topo[iring] IN [1..4]) THEN BEGIN
    xr := sw[iring].x;  
    yr := sw[iring].y;
    xwind[iring] := xr;
    ywind[iring] := yr;
    ringd (xr-39, yr-29, 22, 11);
    swind(iring);
    ptex(xr+5,yr+4, 'Mode:',1);   ptex(xr+100,yr+4, 'Histo:',1);
    ptex(xr+5,yr+16,'GSet:',1);   ptex(xr+100,yr+16,'FCont:',1);
    ptex(xr+5,yr+26,'GCon:',1);   ptex(xr+100,yr+26,  'FResp:',1);
    ptex(xr+5,yr+36,'Wspd:',1);
    ptex(xr+100,yr+36,  'WDir:     Deg',1);
    base1 := maxrings + 4 * (iring-1);
    sw[base1+1].x:=xr+48;       sw[base1+1].y:=yr+2;
    sw[base1+2].x:=xr+148;      sw[base1+2].y:=yr+2;
    sw[base1+3].x:=xr+48;       sw[base1+3].y:=yr+14;
    sw[base1+4].x:=xr+148;      sw[base1+4].y:=yr+14;
    putaxes (xr, yr, hsel[iring]);
    tinter;
    END;
  base1 := maxrings + 4 * (rsel-1);
  sw[base1+wsel[rsel]].col1 := 10; 
  sw[base1+wsel[rsel]].col2 := 10;
  submice (9, rsel, wsel[rsel], psel[rsel]);

  FOR iring:=1 TO numrings DO IF (topo[iring] IN [1..4]) THEN BEGIN
    base1 := maxrings + 4 * (iring-1);
    CASE hsel[iring] OF
      1:sw[base1+2].mess:='Inst ';
      2:sw[base1+2].mess:='1 Min';
      3:sw[base1+2].mess:='5 Min';
      END;
    END;
  tinter;
  
  FOR iw:= (maxrings+1) TO (maxrings+4*numrings) DO 
    IF (topo[((iw-maxrings-1) DIV 4) + 1] IN [1..4])
      THEN swind(iw);
  FOR iring:=1 TO numrings DO IF (topo[iring] IN [1..4]) THEN BEGIN
    tinter;
    FOR ip:=1 TO numvalvs DO
      post (topo[iring], ip, numvalvs, 7, vact[iring,ip], 3);
    END;
  inrings:=TRUE;

  { SCREEN OPERATIONS }
{***}{$H+} {Application.MessageBox ('Marker 2', 'RIV', 0);} {$H-}

  REPEAT
    kbin;
    calr := UpCase(calr);

    doexit := (alr=27) OR (calr='Q');
    dohelp := (calr='H') OR (calr='?') OR ((alr=0) AND (ahr=59));  {F1}
    dotopo := (calr='T')               OR ((alr=0) AND (ahr=60));  {F2}
    IF dohelp THEN help;
    IF dotopo THEN RVSetup.Select;
    base1 := maxrings+4*(rsel-1);
    IF (calr='+') OR (calr='-') OR (ahr IN [1..4]) THEN BEGIN
      sw[base1+wsel[rsel]].col1 := 15; 
      sw[base1+wsel[rsel]].col2 := 15;
      swind (base1+wsel[rsel]);
      IF debug[rsel]
        THEN post (topo[rsel], psel[rsel], numvalvs, 
                   7, vact[rsel,psel[rsel]], 3);
      sw[base2+rsel].col2:=7; sw[base2+rsel].col1:=15; swind(base2+rsel);
      IF alr <> 0
        THEN BEGIN  {+ or - key was used}
          iring := rsel;  {in case NO ring is in topo[]}
          REPEAT 
            changering (rsel, numrings, calr); 
            UNTIL (topo[rsel] IN [1..4]) OR (rsel = iring);
          END
        ELSE BEGIN  {a ring selection subwindow was clicked}
          rsel := 1;
          WHILE (ahr <> topo[rsel]) AND (rsel < numrings) DO INC (rsel);
          END;
      base1 := maxrings+4*(rsel-1);
      sw[base2+rsel].col1:=10; sw[base2+rsel].col2:=10; swind(base2+rsel);
      sw[base1+wsel[rsel]].col1 := 10; 
      sw[base1+wsel[rsel]].col2 := 10;
      swind(base1+wsel[rsel]);
      IF debug[rsel]
        THEN post (topo[rsel], psel[rsel], numvalvs, 
                   LightGreen, vact[rsel, psel[rsel]], 3);
      submice (9, rsel, wsel[rsel], psel[rsel]);
      END

    ELSE IF (ahr=72) OR (ahr=80) OR (ahr IN [11..14]) THEN BEGIN
      sw[base1+wsel[rsel]].col1:=15; sw[base1+wsel[rsel]].col2:=15;
      swind(base1+wsel[rsel]);
      IF ahr=72 THEN wsel[rsel] := wsel[rsel]+1;
      IF ahr=80 THEN wsel[rsel] := wsel[rsel]-1;
      IF ahr IN [11..14] THEN wsel[rsel] := (ahr MOD 10);
      IF wsel[rsel]<1 THEN wsel[rsel]:=4
                      ELSE IF wsel[rsel]>4 THEN wsel[rsel]:=1;
      sw[base1+wsel[rsel]].col2:=10; sw[base1+wsel[rsel]].col1:=10;
      swind(base1+wsel[rsel]);
      submice (9, rsel, wsel[rsel], psel[rsel]);
      END

    ELSE IF debug[rsel] THEN BEGIN
      IF (ahr=75) OR (ahr=77) OR (ahr IN [101..100+numvalvs]) OR
         (calr='O') OR (calr='C') OR (calr='S')
        THEN BEGIN
          post (topo[rsel], psel[rsel], numvalvs, 
                7, vact[rsel,psel[rsel]], 3);
          IF ahr=77 THEN psel[rsel]:=psel[rsel]+1;
          IF ahr=75 THEN psel[rsel]:=psel[rsel]-1;
          IF ahr IN [101..100+numvalvs] THEN psel[rsel] := ahr MOD 100;
          IF psel[rsel] < 1        THEN psel[rsel] := numvalvs ELSE
          IF psel[rsel] > numvalvs THEN psel[rsel] := 1;
          {Put up a little yellow valve number window}
          windd (multi*307, 42, 18, 6, 1, 15, Yellow);
          ptex  (multi*308, 44, '#'+IntToStr(psel[rsel]), clBlack);
          IF  calr='O'                THEN vact[rsel,psel[rsel]]:=TRUE;
          IF (calr='C') OR (calr='S') THEN vact[rsel,psel[rsel]]:=FALSE;
          post (topo[rsel], psel[rsel], numvalvs, 
                LightGreen, vact[rsel,psel[rsel]], 3);
          submice (9, rsel, wsel[rsel], psel[rsel]);
          END;
      IF (calr IN ['F','G']) THEN Sysutils.Sleep (500);
      IF (calr='F') THEN fan_debug_set[rsel] := NOT fan_debug_set[rsel];
      IF (calr='G') THEN gas_debug_set[rsel] := NOT gas_debug_set[rsel];
      END;

    IF (wsel[rsel]=1) AND (alr=32) THEN BEGIN  {change MODE}
      IF oper[rsel] THEN BEGIN  {step from OPER to DEBUG}
        oper[rsel]:=FALSE;  debug[rsel]:=TRUE;
        sw[base1+1].mess:='DEBUG'; swind(base1+1);
        FOR ip:=1 TO numvalvs DO BEGIN
          vact[rsel,ip] := (Copy(pattern_runoff,ip,1)='1');
          post (topo[rsel], ip, numvalvs, 7, vact[rsel,ip], 3);
          END;
        post (topo[rsel], psel[rsel], numvalvs, 
              LightGreen, vact[rsel, psel[rsel]], 3);
        submice (9, rsel, wsel[rsel], psel[rsel]);
        END
      ELSE IF debug[rsel] THEN BEGIN  {step from DEBUG to OPER}
        debug[rsel]:=FALSE; oper[rsel]:=TRUE;
        sw[base1+1].mess:='OPER'; swind(base1+1);
        post (topo[rsel],psel[rsel],numvalvs,7,vact[rsel,psel[rsel]],3);
        submice (9, rsel, wsel[rsel], psel[rsel]);
        END;

    END
    ELSE IF (wsel[rsel]=2) AND ((alr=32) OR (calr='I') OR (calr='C'))
    THEN {change HISTO} BEGIN
      IF alr=32 THEN BEGIN
        hsel[rsel]:=hsel[rsel]+1; IF hsel[rsel]>3 THEN hsel[rsel]:=1;
        xr := sw[rsel].x;  yr := sw[rsel].y;
        CASE hsel[rsel] OF
          1:BEGIN
              sw[base1+2].mess:='Inst ';
              ptex(xr+90,yr+95,'0',7);
              FOR itik:=-2 TO 2 DO BEGIN
                Str(itik*20:2,s1);
                ptex(xr+90+itik*40,yr+95,s1,0);
                END;
              END;
          2:BEGIN
              sw[base1+2].mess:='1 Min';
              FOR itik:=-2 TO 2 DO BEGIN
                Str(itik*20:2,s1);
                ptex(xr+90+itik*40,yr+95,s1,0);
                END;
              END;
          3:BEGIN
              sw[base1+2].mess:='5 Min';
              FOR itik:=-2 TO 2 DO BEGIN
                Str(itik*20:2,s1);
                ptex(xr+90+itik*40,yr+95,s1,7);
                Str(itik*2:1,s1);
                ptex(xr+90+itik*40,yr+95,s1,0);
                END;
              END;
          END; {case}
        swind(base1+wsel[rsel]);
        {clear selected histogram only}
        END ELSE IF calr='I' THEN BEGIN
        clearhist (rsel, hsel[rsel], numrings);
        puthisto(rsel);
        {clear all histograms for all rings}
        END ELSE IF calr='C' THEN BEGIN
        clearhist (0, 0, numrings);
        SysUtils.Sleep (500);
        END;
    END
    ELSE IF (wsel[rsel]=4) AND (alr=32) AND debug[rsel] THEN BEGIN
      sw[base1+4].mess:=''; sw[base1+4].col1 := LightCyan;
      sw[base1+4].col2 := LightCyan;
      swind(base1+4);
      xacc := sw[rsel].x+152;  yacc := sw[rsel].y+16;
      SetColor(Black); sacceptactive:=TRUE; raccept(x); sacceptactive:=FALSE;
      IF svalue <> '' THEN BEGIN
        propc [rsel] := x;
        cinteg[rsel] := x;
        cprop [rsel] := 0.0;
        cdiff [rsel] := 0.0;
        cwind [rsel] := 0.0;
        END;
      Str(propc[rsel]:5:1,s); sw[base1+4].mess:=s;
      sw[base1+4].col1:=LightGreen;  sw[base1+4].col2:=LightGreen;
      swind(base1+4);
      END
    ELSE SysUtils.Sleep (500);

    UNTIL doexit;
  inrings:=FALSE; 
  CloseGraph;
  END;
{------------------------------------------------------------}

PROCEDURE BackgroundColorSet (color: TColor);
BEGIN
  riv_background := color;
  END;  {of procedure BackgroundColorSet}

{------------------------------------------------------------}

FUNCTION BackgroundColorGet: TColor;
BEGIN
  BackgroundColorGet := riv_background;
  END;  {of function BackgroundColorGet}

{------------------------------------------------------------}

Initialization

BEGIN
  clearhist (0, 0, numrings);  {clear histograms, all rings and types}
  BackgroundColorSet (clBlue);
  END;

Finalization

BEGIN
  END;

{of unit RIV.PAS...}
END.
