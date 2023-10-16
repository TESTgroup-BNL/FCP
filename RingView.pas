Unit RingView;
{$R+}
{$H-}

{*
 * Name:     RingView.pas
 *
 * Purpose:  BNL FACE Project
 *           Used by FCP
 *           Ring pictures and debugging
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
 *  (11) Remove history prior to 1999 to save diskette space       [03-06-24]
 *  (12) windd, ptex: moved here from comu and modified for canvas [03-06-24]
 *  (13) Cripple the old console help procedure for now            [03-06-24]
 *  (14) Replace one call to changering by inline code             [03-06-24]
 *  (15) Delete Uses comu                                          [03-06-24]
 *  (16) clearhist, histogram, swind, putwindow, post, putring,    [03-06-24]
 *       putaxes, puthisto: moved here from unit coms and modified [03-06-24]
 *  (17) Delete Uses coms                                          [03-06-24]
 *  (18) help: change from console to TlblForm                     [03-06-26]
 *  (19) Add saved[view]: staticinfo                               [03-06-28]
 *  (20) Copy VAR topo[1..maxrings] from RVSetup                   [03-06-28]
 *  (21) Delete USES RVSetup; functionality now here               [03-06-28]
 *  (22) Delete BackgroundColorSet, BackgroundColorGet             [03-06-28]
 *  (23) Delete dotopo and related code                            [03-06-28]
 *  (24) Renamed RingView                                          [03-06-29]
 *  (25) Add global procedure PanelRingSet                         [03-06-30]
 *}

Interface

USES
{$IFDEF LINUX}
  QControls, QExtCtrls, QForms, QGraphics, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Controls, ExtCtrls, Forms, Graphics, StdCtrls,
  Windows,
{$ENDIF}
  Classes, SysUtils,
  crt32, graph32, Template,
  comd, Globals, gra, comp, musca;

CONST PanelsMax = 16;

TYPE

  TRingPanel = RECORD
    pnlView: TPanel;
    comboRingNo: TComboBox;
    lblName: TLabel;
    colorOpera,
    colorDebug,
    colorNone: TColorBox;
    RingNo,
    Mode,
    Histo: INTEGER;
    BackColorOpera,
    BackColorDebug,
    BackColorNone : TColor;
    END;

  TRingView = CLASS(TTemplate)
      PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
      PROCEDURE OnClickButton (Sender: TObject);
      PROCEDURE OnChangeCombo (Sender: TObject);
      PROCEDURE OnMouseDownPanel (
        Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: INTEGER);
    PRIVATE
      FPanels,         {number of panels on screen}
      FRing: INTEGER;  {active ring number}
      FViews: ARRAY [1..PanelsMax] OF TRingPanel;
      comboPanels: TComboBox;
      PROCEDURE MakeChildren;
      PROCEDURE SaveToMemory;
      PROCEDURE Refresh;
      PROCEDURE Setup (panel: INTEGER; state: BOOLEAN);
    PUBLIC
    END;

VAR
  topo: ARRAY [1..maxrings] OF INTEGER;  {position of a ring on screen}

PROCEDURE Select;
PROCEDURE UpdateIt;
PROCEDURE PanelRingSet (panel, ring: INTEGER);

PROCEDURE rselinit;
PROCEDURE clearhist (ring, group, numrings: INTEGER);
PROCEDURE histogram;
PROCEDURE putwindow (iring:INTEGER);
PROCEDURE putring (where, iring, nv: INTEGER);
PROCEDURE puthisto (ifire: INTEGER);

IMPLEMENTATION

USES LblForm;

TYPE
  staticinfo = RECORD  {saves RingView settings between instantiations}
    SRingNo,
    SMode,
    SHisto: INTEGER;
    SBackColorOpera,
    SBackColorDebug,
    SBackColorNone: TColor;
    END;

VAR
  xacc, yacc: INTEGER;
  doexit: BOOLEAN;
  riv_background: TColor;

  frmRingView: TRingView;
  frmHelp: TlblForm;

  SPanels: INTEGER;
  SRing: INTEGER;
  saved: ARRAY [1..PanelsMax] OF staticinfo;

  scalex, scaley: Single;

  panel: INTEGER;  {this needed in INITIALIZATION as indices}
{------------------------------------------------------------}

PROCEDURE windd (x,y,hor,ver:INTEGER; m:float; col1,col2:INTEGER);
VAR p: array[1..17,1..2] OF INTEGER;
    mm,a,b,c,d,e: INTEGER;
    xscale,
    yscale: REAL;
BEGIN
  xscale := grmaxx / 640.0;
  yscale := grmaxy / 350.0;

  a  :=ROUND (xscale*2.4*m);
  b  :=ROUND (xscale*1.83*m);
  c  :=ROUND (xscale*0.98*m);
  d  :=ROUND (yscale*0.54*m);
  e  :=ROUND (yscale*1.306*m);
  mm :=ROUND (yscale*m);

  x := ROUND (xscale * x);
  y := ROUND (yscale * y);

  hor := ROUND (xscale * hor);
  ver := ROUND (yscale * ver);

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
  SetColor(col1);
  SetFillStyle(solidfill,col2);
  FillPoly(17,p);
END;  {of procedure 'windd'}
{------------------------------------------------------------}

PROCEDURE ptex (x,y: INTEGER; textstr: String; colour: INTEGER);
VAR xx, yy: Longint;
BEGIN
  xx := x * grmaxx;
  xx := xx DIV 640;
  yy := y * grmaxy;
  yy := yy DIV 350;
  SetColor (colour);
  MoveTo (xx, yy);
  OutText (textstr);
  END;  {of procedure 'ptex'}
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

PROCEDURE swind (n: INTEGER);
BEGIN
  WITH sw[n] DO BEGIN
    SetLineStyle (0, 0, ls);
    SetColor (col1);
    windd (x, y, lx, ly, m, col1, col2);
    ptex (x+4, y+2, mess, Black);
    END;
  END;  {of procedure 'swind'}
{---------------------------------------------------------------------}

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
{------------------------------------------------------------}

PROCEDURE help;  {for ring picture unit}
CONST nl = CHR(13) + CHR(10);
BEGIN
  {*** IF NOT Assigned (frmHelp) THEN} frmHelp := TLblForm.Create (Application);
  WITH frmHelp DO BEGIN
  frmHelp.Display ('Help: Ring picture window', '');
  BodyAppend (
  '[Ring #] Click this control to select this quadrant' +nl+
  '(or use + and - keys).' + nl +
  'All actions below apply only to selected quadrant.' +nl+nl);
  BodyAppend (
  'Click [Hist], [Mode], or [FCont] to select that control' +nl+
  '(or use UpArrow and DownArrow).' +nl+nl);
  BodyAppend (
  '[Hist] Right click (spacebar) to choose histogram integration time.' +nl+
  '[Mode] Right click (spacebar) to toggle debugging on/off.' +nl+
  '[FCont] Right click (spacebar) to change gas flow.*' +nl+nl);
  BodyAppend (
  'Click to select VVP to change (Right/LeftArrow).*' +nl+
  'Left click to shut VVP valve (S-key). *' +nl+
  'Right click to open VVP valve (O-key).*' +nl+nl);
  BodyAppend (
  '[Fan] Click to toggle state of fan on/off (F-key).*' +nl+
  '[Gas] Click to toggle state of gas on/off (G-key).*' +nl+nl);
  BodyAppend (
  'I-key  Zero histogram, active ring and histogram type only.**' +nl+
  'C-key  Zero histogram, all rings and types.**' +nl+nl);
  BodyAppend (
  '*  DEBG mode only.' +nl+
  '** OPER mode only.  There is no equivalent mouse action.');
  END;  {with}
  END;  {of procedure 'help' of ring picture unit}
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

BEGIN;
{***}{$H+} {Application.MessageBox ('Marker 1', 'RIV', 0);} {$H-}
  InitGraph(grdriver,grmode,'');

  grmaxx := GetMaxX;
  grmaxy := GetMaxY;

  {Paint whole client background}
  gra.screen (0.0, 0.0, 1.0, 1.0);
  gclear (0.0, 0.0, 1.0, 1.0, riv_background);

  SetBkMode (hDCGraph, TRANSPARENT);
  SetBkMode (memDC,    TRANSPARENT);

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

  mouse_clear (0);
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

    IF (calr='H') OR (calr='?') OR {F1}((alr=0) AND (ahr=59)) THEN help;

    doexit := (alr=27) OR (calr='Q');
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
            CASE calr OF
              '+': INC(rsel);
              '-': DEC(rsel);
              END; {case}
            IF rsel > numrings THEN rsel := 1;
            IF rsel < 1        THEN rsel := numrings;
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
          windd (602, 28, 26, 6, 1, 15, Yellow);
          ptex (604, 30, '# '+IntToStr(psel[rsel]), clBlack);
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
{-------------------------------------------------------------}

PROCEDURE PanelRingSet (panel, ring: INTEGER);
{In static (saved) area, assign a ring to a panel.
 Nothing done if either argument out of range.
 Global variable numrings must have been initialized.
 }
BEGIN
  IF (panel IN [1..PanelsMax]) AND (ring IN [1..numrings])
    THEN saved[panel].SRingNo := ring;
  END;  {of procedure 'PanelRingSet'}
{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmRingView) THEN BEGIN
    frmRingView := TRingView.Create (Application);
    frmRingView.MakeChildren;
    END;
  frmRingView.WindowState := wsMaximized;
  frmRingView.Show;
  frmRingView.Refresh;
  UpdateIt;
  frmRingView.SetFocus;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TRingView.MakeChildren;
{Dynamically create controls.
 Set any properties that can not change.
 }
VAR panel,
    ring: INTEGER;
BEGIN
  {Form parameters}
  With Self DO BEGIN
    Caption := 'Ring View and Debugging Screen';
    AutoScroll := FALSE;
    OnClose := OnCloseForm;
    END;

  {Command buttons}
  WITH btnCancel DO BEGIN
    Top := 0;
    Left := 0;
    Width := (Forms.Screen.WorkAreaWidth DIV 3);  {*** TEMP forms}
    OnClick := OnClickButton;
    END;
  WITH btnApply DO BEGIN
    Top := btnCancel.Top;
    Left := btnCancel.BoundsRect.Right;
    Width := btnCancel.Width;
    Caption := '&Save setup to memory';
    OnClick := OnClickButton;
    END;
  WITH btnHelp DO BEGIN
    Top := btnCancel.Top;
    Left := btnApply.BoundsRect.Right;
    Width := btnCancel.Width;
    OnClick := OnClickButton;
    END;
  WITH btnRefresh DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnOK DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  
  {Number of panels to display combo box}
  FPanels := SPanels;
  IF NOT Assigned (comboPanels) THEN comboPanels := TComboBox.Create (Self);
  WITH comboPanels DO BEGIN
    Parent := Self;
    Clear;
    AddItem ( '1', NIL);
    AddItem ( '2', NIL);
    AddItem ( '4', NIL);
    AddItem ( '6', NIL);
    AddItem ( '9', NIL);
    AddItem ('16', NIL);
    ItemIndex := Items.Count-1;
    CASE FPanels OF
      1: ItemIndex := 0;
      2: ItemIndex := 1;
      4: ItemIndex := 2;
      6: ItemIndex := 3;
      9: ItemIndex := 4;
      END;  {case}
    OnChange  := OnChangeCombo;
    END;
  
  {All potential panels}
  FOR panel := 1 TO PanelsMax DO WITH FViews[panel], saved[panel] DO BEGIN
    IF NOT Assigned (pnlView) THEN pnlView := TPanel.Create (Self);
    WITH pnlView DO BEGIN
      Parent  := Self;
      Visible := FALSE;
      OnMouseDown := OnMouseDownPanel;
      END;
    IF NOT Assigned (comboRingNo) THEN comboRingNo := TComboBox.Create (Self);
    WITH comboRingNo DO BEGIN
      Parent  := pnlView;
      Style   := csDropDownList;
      AddItem ('NONE', NIL);
      FOR ring := 1 TO numrings DO AddItem ('Ring ' + rlabel[ring], NIL);
      ItemIndex := SRingNo;
      OnChange  := OnChangeCombo;
      END;
    IF NOT Assigned (lblName) THEN lblName := TLabel.Create (Self);
    WITH lblName DO BEGIN
      Parent    := pnlView;
      Alignment := taCenter;
      END;
    RingNo         := SRingNo;
    Mode           := SMode;
    Histo          := SHisto;
    BackColorOpera := SBackColorOpera;
    BackColorDebug := SBackColorDebug;
    BackColorNone  := SBackColorNone;
    END;  {creating the panels and controls}

  FRing := SRing;

  END;  {of procedure .MakeChildren}
{-------------------------------------------------------------}

PROCEDURE TRingView.Refresh;
{Refresh the controls from the working variables.
 Set any properties that could be affected by control changes.
 This is a brute force, cpu cycle eater, but easy.
 }
VAR panel: INTEGER;
    xdiv, ydiv: INTEGER;
BEGIN

  WITH comboPanels DO FPanels := StrToInt(Items.Strings[ItemIndex]);

  FOR panel := 1 TO FPanels DO BEGIN
    Setup (panel, FALSE);
    WITH FViews[panel], pnlView DO BEGIN
      {Pick up any change in panel ring assignment}
      RingNo := comboRingNo.ItemIndex;

      {Determine DIV & MOD factors for panel position and size}
      xdiv := 4;
      ydiv := 4;
      CASE FPanels OF
         1: BEGIN xdiv := 1; ydiv := 1; END;
         2: BEGIN xdiv := 2; ydiv := 1; END;
         4: BEGIN xdiv := 2; ydiv := 2; END;
         6: BEGIN xdiv := 3; ydiv := 2; END;
         9: BEGIN xdiv := 3; ydiv := 3; END;
        END;  {case}
      {Position and size the panels}
      Left   := ((panel-1) MOD xdiv) * (Self.ClientWidth DIV xdiv);
      Width  := Self.ClientWidth DIV xdiv;
      Height := (Self.ClientHeight - btnCancel.BoundsRect.Bottom) DIV ydiv;
      Top    := btnCancel.BoundsRect.Bottom + ((panel-1) DIV ydiv) * Height;
      Color  := BackColorNone;
      IF (RingNo IN [1..numrings]) THEN BEGIN
        IF debug[RingNo]
          THEN Color := BackColorDebug
          ELSE Color := BackColorOpera;
        scalex :=  Width/640.0;
        scaley := Height/320.0;
        WITH comboRingNo DO BEGIN
          Width   := ROUND (90 * scalex);
          Height  := ROUND ( 4 * scaley);
          Left    := ROUND ((320 - (Width DIV 2)) * scalex);
          Top     := ROUND (18 * scaley) - (Height DIV 2);
          IF (RingNo = FRing)
            THEN Color := clLime
            ELSE Color := clWhite;
          END;
        WITH lblName DO BEGIN
          Caption := descriptor[RingNo];
          Left    := ROUND ((320 - (Width DIV 2)) * scalex);
          Top     := ROUND (142 * scaley);
          Height  := ROUND (  2 * scaley);
          Color   := pnlView.Color;
          Font.Color := Integer(Color) XOR $FFFFFF;
          Font.Style := [fsBold];
          END;
        END;  {if ring range}
      END;  {with pnlView}
    END;  {panel loop}
  END;  {of procedure .Refresh}
{-------------------------------------------------------------}

PROCEDURE TRingView.Setup (panel: INTEGER; state: BOOLEAN);
{Make controls visible/invisible depending on conditions.
 State =  TRUE --> Show only setup controls
 State = FALSE --> Show only normal controls unless RingNo = NONE
 }
VAR panelloop: INTEGER;
    showit: BOOLEAN;
BEGIN
  {Hide the panels not being used}
  FOR panelloop := 1 TO PanelsMax DO
    FViews[panelloop].pnlView.Visible := (panelloop <= FPanels);
  {Hide or show the panel controls}
  WITH FViews[panel] DO BEGIN
    showit := (NOT state) AND (RingNo > 0);
    comboRingNo.Visible := showit OR state;
    lblName.Visible := showit;
    END;
  {Place and possibly show the number of panels combo box}
  WITH comboPanels DO BEGIN
    Left := FViews[panel].pnlView.Left;
    Top  := FViews[panel].pnlView.Top;
    Visible := state;
    IF Visible THEN BringToFront;
    END;
  END;  {of procedure .Setup}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
{Update controls on screen after sample/control interval}
BEGIN
  IF Assigned (frmRingView) THEN BEGIN
    END;  {form exists}
  END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

PROCEDURE TRingView.SaveToMemory;
{Apply current changes in controls to static variables}
VAR panel: INTEGER;
BEGIN
  SPanels := FPanels;
  SRing := FRing;

  FOR panel := 1 TO FPanels DO WITH saved[panel], FViews[panel] DO BEGIN
    SRingNo         := RingNo;
    SMode           := Mode;
    SHisto          := Histo;
    SBackColorOpera := BackColorOpera;
    SBackColorDebug := BackColorDebug;
    SBackColorNone  := BackColorNone;
    END;
  END;  {of procedure .SaveToMemory}
{-------------------------------------------------------------}

PROCEDURE TRingView.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  OnClickButton (TObject(btnCancel));
  END;  {of procedure .OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TRingView.OnClickButton (Sender: TObject);
BEGIN

  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmRingView := NIL;
    END;
  
  IF (Sender = btnApply) THEN BEGIN
    SaveToMemory;
    END;
  
  IF (Sender = btnHelp) THEN BEGIN
    help;
    END;
  
  END;  {of procedure .OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TRingView.OnChangeCombo (Sender: TObject);
BEGIN
  Refresh;
  END;  {of procedure .OnChangeCombo}
{-------------------------------------------------------------}

PROCEDURE TRingView.OnMouseDownPanel (
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y: INTEGER);
VAR panel: INTEGER;
BEGIN
  FOR panel := 1 TO FPanels DO WITH FViews[panel] DO
    IF (Sender = pnlView) AND (Button = mbRight)
      THEN Setup (panel, TRUE);
  END;  {of procedure .OnMouseDownPanel}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  clearhist (0, 0, numrings);  {clear histograms, all rings and types}
  SPanels   := 4;
  SRing     := 1;
  FOR panel := 1 TO PanelsMax DO WITH saved[panel] DO BEGIN
    SRingNo := 0;
    SMode   := 0;
    SHisto  := 1;
    SBackColorOpera := clBlue;
    SBackColorDebug := clRed;
    SBackColorNone  := SBackColorOpera;
    END;
  END;

FINALIZATION

BEGIN
  END;

{of unit RIV.PAS...}
END.
