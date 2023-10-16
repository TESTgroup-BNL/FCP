Unit comdis;
{$R+  Range checking ON}
{$H-  Turbo-style strings default}

Interface

USES
{$IFDEF LINUX}
  QForms, QGraphics,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics,
{$ENDIF}
  SysUtils, Windows, 
  crt32, graph32,
  Globals,
  faced, comd, comu, coms, comp, gra, musca, debuglog;

PROCEDURE graphics (ring, group, period: INTEGER; 
                    hours: Single; record_start: INTEGER);

{*
 * Purpose:  BNL FACE Project
 *           On-line data acquisition, monitoring and control
 *           Graphical display of data and some static text pages
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
 *   (5) two occurences of 0.99999999999 changed to 0.999999
 *
 * Version:     3
 * Date:        11-06-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Fix windspeed and proportional valve errors
 *   (2) Add procedure 'gcgrid'.
 *   (3) Replace variables over* by overband[].
 *   (4) Add local procedure 'loadsd' in
 *       procedures xloggdis, xstatdis, and xvarrdis.
 *   (5) Add procedure 'shiftsd'.
 *   (6) Replace inline tick marking by calls to
 *       'vtick' (see GRAyy.PAS).
 *   (7) Fixed bug in procedure 'xloggdis' which caused
 *       0 to 7 spurious current events to be plotted
 *       at end of <F6> graph.
 *   (8) Replace box making code by call to 'bbox' in GRAyy.PAS.
 *   (9) Add calls to 'htick' when making graph window.
 *  (10) Add and use local function 'getdishour' in 'graphics'.
 *  (11) Add and use local function 'getanswer' in 'graphics'.
 *  (12) Initialize ALL the elements of the sd arrays in 'display'.
 *
 * Version:     4
 * Date:        12-06-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  Moved COM version of procedure 'screen' here
 *        from unit GRAyy.PAS.
 *
 * Version:     5
 * Date:        12-10-91
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  Removed repetition of "dispose(sd6)" which occurred at
 *        the very end of PROCEDURE display.  This caused a runtime
 *        error 204 if compiled under TurboPascal 6.0 AS BOTH THE
 *        TP5 AND TP6 MANUALS SAY IT SHOULD!!!  Apparently TP5
 *        ignored the error.  What other subtle traps exist???
 *
 * Version:     6
 * Date:        02-28-92
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  Moved procedure 'screen' back to unit GRA.PAS.
 *   (2)  Write local procedure 'writeit' for 'displayset'.
 *
 * Version:     7
 * Date:        November/December 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  Additional use of shiftsd(); -- 11/24/92
 *   (2)  Collapse some boolean expressions in graphics();
 *   (3)  Define recavail := recnum[no,row-2] in graphics();
 *   (4)  Change 2 sdir^ code items since wwdir is now INTEGER.
 *
 * Version:     8
 * Date:        January 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  In <F7> Display window section, ignore request if there are no
 *        records written to disk yet.  Replaced IF dolast by 
 *        IF dolast AND (recavail>0) in graphics().  Easy way to avoid a 
 *        bomb trying to read an empty file (12/28/92).
 *   (2)  Declare sfilsave boolean used so that sfil[no,i] restored to the
 *        value it had upon entering display (12/29/92).
 *
 * Version:     9
 * Date:        June/July/August 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  Add display of PVResp to LOGG graphs.                      [6/25/93]
 *   (2)  Add averaging of LOGG points displayed (except realtime).  [6/27/93]
 *   (3)  On varr graphs, show agcont (not agc1m), a*_adj (not a*).  [8/01/93]
 *   (4)  Added trace of ambient concentration to logg graphs.       [8/05/93]
 *
 * Version:     10
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  Begin use as COMDIS94.                                    [12/10/93]
 *
 * Version:     11
 * Date:        February 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  graphics():  Change from (no) to (VAR no).                [02/09/94]
 *   (2)  graphics():  Allow ring switching (+-) from graphics menu.[02/09/94]
 *
 * Version:     12
 * Date:        March 1994
 * J.N.  94/03/10  Completely rewritten
 * Changes:
 *   (1)  new procedures:
 *   (2)  changed procedure:
 *   (3)  var recavail becomes function recavail(no,row)
 *   (4)  ability to go backwards in time when doing historic graphs
 *
 * Version:     13
 * Date:        June/July 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1)  xloggdis(): replace 5m by 1m average for band #1.        [94/06/08]
 *   (2)  displayset: snap shot graphics (new 5th kind of "file"). [94/06/26]
 *   (3)  Move dograph, docurrent, dolast (w/dosnapshot) from COMD [94/06/28]
 *   (4)  Add graphaxis() to do all vtick() calls and labelling    [94/06/29]
 *   (5)  Add sd_average() to average values in the sd^ arrays     [94/07/01]
 *   (6)  display: add protection in event InitGraph fails         [94/07/07]
 *   (7)  displaymove: additional EOF check during "up arrow"      [94/07/07]
 *   (8)  display: remove repetition of NEW(sd6) which was         [94/07/09]
 *                 eventually causing out-of-heap error.
 *   (9)  menu: move ClrScr to graphics() so BGI err not erased.   [94/07/09]
 *
 * Version:     14
 * Date:        Feb 1995
 * Changes:
 *   (1)  Becomes COMDIS95.PAS                                     [95/02/21]
 *
 * Version:     15
 * Date:        June 1995
 * Changes:
 *   (1)  graphics(): historic "From record" allows just <CR>      [95/06/07]
 *          which defaults to latest period.  Differs from recent
 *          option in that screen will not be continually changing
 *          during 1-second data logging.
 *   (2)  displayset(), graphics(): snapshot enabled for all rings [95/06/08]
 *   (3)  displayset(): add pH2O to auxiliary screen list          [95/06/16]
 *
 * Version:     16
 * Date:        Oct-Dec 1995, Jan 1996
 * Changes:
 *   (1)  Becomes COMDIS96.PAS; update Uses.                       [95/10/14]
 *   (2)  Changes related to new VARR format.                      [96/01/01]
 *   (3)  Vars recnumber .. recend moved here from COMD96          [96/01/05]
 *   (4)  Define var longseed for forcing Longint arithmetic       [96/01/05]
 *   (5)  Use PgUp/PgDn keys to move 10 screens in snapshot (only) [96/01/16]
 *
 * Version:     17
 * Date:        June 1996
 * Changes:
 *   (1)  Move proc ephemeris() here from comp96 and modify        [96/06/20]
 *   (2)  ephemeris(1): replace kbin call by screen autoupdating   [96/06/21]
 *   (3)  Move proc h2ovapor() here from comp96 and modify         [96/06/22]
 *   (4)  Change rlabel() references to rlabel[]                   [96/06/22]
 *
 * Version:     18
 * Date:        July 1996
 * Changes:
 *   (1) proc graphics: define recstart_save which is used in      [96/07/27]
 *         "historic" graphs.  Entering -1 for starting record will
 *         pick up recstart_save.  Active between rings.
 *   (2) func getdishour: protect other parts of program by        [96/07/27]
 *         limiting dishour (a float) to MAXINT.
 *
 * Version:     19
 * Date:        Dec 1996 - Jan 1997
 * Changes:
 *   (1)  Becomes COMDIS97.PAS; update Uses.                       [96/12/22]
 *   (2)  Add numrings to argument lists of changering & clearhist [97/01/20]
 *
 * Version:     20
 * Date:        May 1997
 * Changes:
 *   (1)  Switch from snapshot_ray (DS) to snapshot_ray^ (Heap)    [97/05/18]
 *
 * Version:     21
 * Date:        July 1997
 * Changes:
 *   (1)  Move VAR rmess[8] here and increase to [24]              [97/07/31]
 *   (2)  rmess = ring label and descriptor                        [97/07/31]
 *   (3)  New rmess centered above graph box                       [97/07/31]
 *
 * Version:     22
 * Date:        December 1997
 * Changes:
 *   (1)  Becomes COMDIS98.PAS; update Uses.                       [97/12/23]
 *   (2)  Replace 6 occurences of agc1hr by agc5m.                 [97/12/29]
 *   (3)  Replace gcgrab, gc1min, gcambi, gctarget -- see COMD98.  [97/12/29]
 *   (4)  Replace most occurences of substring 'gcont' by 'gcgrab'.[97/12/29]
 *   (5)  Replace 2 occurences of gcamb[] by gccntl[].             [97/12/29]
 *   (6)  Replace aairtemp, airtemp[] by ttemp1, temp1[].          [97/12/30]
 *  (10)  Changes to display set variable list.                    [98/01/04]
 *  (11)  Activate sd13 for temp2 graphs in logg and genl ops      [98/01/05]
 *  (12)  discomm: correct temp1 average numeric in genl screen    [98/07/31]
 *  (13)  discomm: add 1 dp to "pressure", make "solar" integer    [98/07/31]
 *
 * Version:     23
 * Date:        1999
 * Changes:
 *   (1)  Uses faced99 (instead of 98).                            [99/01/15]
 *   (2)  Replace occurences of disprecord[] by disprecord^[].     [99/01/28]
 *   (3)  graphics: fix 2 minor "recstart" bugs.                   [99/04/08]
 *   (4)  display: allocate, clear and dispose sd14 and sd15       [99/11/15]
 *   (5)  graphlines_logg: add var i:integer                       [99/11/15]
 *   (6)  graphlines_logg: shift sdir(0-360) to sd15(-90 to 450)   [99/11/15]
 *   (7)  graphlines_logg: graph sd15 instead of sdir              [99/11/15]
 *   (8)  graphlines_logg: graph sd14 water vapor pressure         [99/11/15]
 *   (9)  shiftsd, loadsd, display(2x): sd14 = pH2O filling        [99/11/15]
 *
 * Version:     23
 * Date:        1999-2000
 * Changes:
 *   (1)  Becomes COMDIS99.PAS; update Uses.                       [99/12/13]
 *   (2)  IFDEF TURBO and DELPHI in Uses and invokes $H-           [00/01/19]
 *   (3)  displayset: D-button toggles EGA<>VGA<>IBM8514           [00/02/15]
 *   (4)  display: change grmaxx/y = GetMaxX/Y+1 to GetMaxX/Y      [00/02/16]
 *   (5)  display: clear whole client window                       [00/02/16]
 *   (6)  display: call screen; subwindow definition               [00/02/16]
 *   (7)  xloggdis, xstatdis, xvarrdis, xsnapdis - shorter tex()   [00/02/18]
 *   (8)  display: call TextWidth/Height after InitGraph           [00/02/18]
 *   (9)  graphics: move ClrScn and menu inside REPEAT loop        [00/03/15]
 *  (10)  add module scope rlabelsave: CHAR;                       [00/03/15]
 *  (11)  graphics: use rlabelsave                                 [00/03/15]
 *  (12)  display: try to add unique title to graphics window      [00/03/15]
 *  (13)  must add windows to IFDEF DELPHI Uses                    [00/03/15]
 *  (14)  display: replace UNTIL alr=27 by ~ OR NOT(IsWindow())    [00/03/15]
 *  (15)  add dummy module scope function IsWindow() for DOS comp  [00/03/16]
 *  (16)  add dummy module scope const    hWndGraph  for DOS comp  [00/03/16]
 *  (17)  displayset: distinguish IBM1 and IBM2 screens.           [00/03/23]
 *        In 32-bit, both will signify 1024x768, the former
 *        with pen 1 pixel wide, and the other 2 pixels.
 *  (17)  displayset: move screen type window from (70,1) to (1,2) [00/03/23]
 *  (18)  displayset: add driver = Detect as an option             [00/03/23]
 *  (19)  displayset: IFDEF DELPHI move cursor in front of cell    [00/03/23]
 *  (20)  display: IFDEF DELPHI for text SetBkMode = OPAQUE        [00/04/06]
 *  (21)  move DOS dummy function IsWindow() to coms99.pas         [00/04/06]
 *  (22)  delete module scope rlabelsave; use rmess instead        [00/04/13]
 *  (23)  display: remove item (8)                                 [00/04/17]
 *  (24)  display: SetBkMode opaque for memDC as well              [00/04/18]
 *  (25)  display: mouse aware in submenu                          [00/04/21]
 *  (26)  calls to mouse_add must now provide button mask          [00/04/25]
 *  (27)  dispsel: mouse aware little menu in upper right          [00/04/27]
 *  (28)  displaymove: "key" ahr=1 moves cursor absolutely         [00/04/27]
 *  (29)  graphics(2), menu, help: snapshot responds to F6, 7 or 8 [00/04/28]
 *  (30)  displaymove: $IFDEF DELPHI needed for DOS compilers      [00/05/05]
 *  (31)  displaymove: fix mouse cursor bug when hours<>3          [00/05/06]
 *  (32)  displaymove: new var points to solve stretching problem  [00/05/06]
 *  (33)  display_hours_default: new module var, init = 3.0        [00/05/09]
 *  (34)  getdishour(): use above instead of const dishrdef        [00/05/09]
 *  (35)  dispsel: if docurrent don't repeat draw of boilerplate   [00/05/31]
 *  (36)  dispsel: upper right menu order changed QUIT CURSOR MORE [00/10/02]
 *  (37)  remove usa argument in all calls to showdate/showtime    [00-10-12]
 *  (38)  replace showdate(..) by Copy (showdate(..), 3, 10)       [00-10-12]
 *  (39)  Uses: add musca to list                                  [00-11-07]
 *
 * Version:     24
 * Date:        2001
 * Changes:
 *   (1) menu: mouse buttons for Logg 3 & 24 hr, Aux 3 & 24 hr     [01/04/11]
 *   (2) menu: move and expand <-+> Ring number mouse target area  [01/04/11]
 *   (3) dispel: expand <ESC> mouse target area on right hand side [01/04/11]
 *   (4) dispel: new 'A'veraging toggle mouse target in numerics   [01/04/11]
 *   (5) graphics: lastquick: INTEGER for new canned graphs        [01/04/11]
 *   (6) graphics: set and parse lastquick if change #1 clicked    [01/04/11]
 *   (7) dispel: correct argument error in two mouse_add calls     [01/06/07]
 *   (8) change 10 Copy(showdate(..),3,10) to just showdate(..)    [01/06/07]
 *   (9) ephemeris: delete now unnecessary display of 'year'       [01/06/07]
 *  (10) change all 'Cursor at:' to 'Cursor:'                      [01/06/07]
 *  (11) must then reposition date labels and data slightly        [01/06/07]
 *  (12) xloggdis: "H2O" label for numerics of genlop screens      [01/10/03]
 *  (13) sd_average: add averagmg pf sd12, sd13, sd14              [01/10/03]
 *  (14) discomm: add var ssss12or numerics of genlop screens      [01/10/03]
 *  (15) discomm: format sd14^ and av14 omtp ssss12                [01/10/03]
 *  (16) discomm: rtex tje H2O value ssss12 below WDir in genlops  [01/10/03]
 *  (17) graphsegment: if color is Black, use White instead!!!     [01/10/03]
 *  (18) displayset/help: warning about color = Black              [01/10/03]
 *
 * Version:     25
 * Date:        2002
 * Changes:
 *   (1) Unit renamed comdis                                       [02-03-21]
 *   (2) Uses faced99, etc. changed to Uses faced, etc.            [02-03-21]
 *   (3) displayset: changes reflecting new graph32                [02-03-21]
 *   (4) Remove $IFDEF TURBO code $ENDIF & $IFDEF DELPHI $ENDIF    [02-03-24]
 *   (5) displaymove: save record number when mouse moves cursor   [02-03-27]
 *   (6) xlogg/stat/varrdis: (32,22,'RecNo:',12) -> (27,22,,,      [02-03-27]
 *   (7) discomm: rtex(41,22,istr(recnumber,8 -> (32,22,(,7 !!!    [02-03-27]
 *   (8) fileselect: ARRAY[1..5] OF String[17]; to String;         [02-05-14]
 *   (9) help: guts replaced by modeless form label                [02-09-14]
 *  (10) displayset/help: guts replaced by modeless form label     [02-09-14]
 *  (11) xstatdis, graphlines_stst: removed                        [02-12-17]
 *
 * Version:     26
 * Date:        2003
 * Changes:
 *   (1) Changes related to new LPF object                         [03-01-05]
 *   (2) ephemeris: moved to COMS from COMDIS                      [03-01-07]
 *   (3) h2ovapor:  moved to COMS from COMDIS                      [03-01-07]
 *   (4) displayset: removed; functionality in LGSetup             [03-01-07]
 *   (5) Removed USES LGSetup and call to .Select                  [03-01-09]
 *   (6) help: removed; functionality in LGSelect                  [03-01-09]
 *   (7) display_hours_default: removed, see LGSelect.ebHours      [03-01-09]
 *   (8) menu: removed; functionality in LGSelect                  [03-01-09]
 *   (9) Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS [03-01-24]
 *  (10) Contents of COMDA.PAS put here; COMDA.PAS deleted         [03-03-15]
 *  (11) display: remove call to gresult after InitGraph           [03-03-15]
 *  (12) display: remove variables grcode and grmsg                [03-03-15]
 *  (13) display: KeyPressed -> KeyPressed OR graph32.Event.Flag 2x[03-05-09]
 *  (14) displaymove: crt32_mouse.col -> graph32.Event.X           [03-05-09]
 *  (15) Add DebugLog capability                                   [03-05-27]
 *  (16) Add DebugLogFileWrite's to displaymove and discomm        [03-05-27]
 *
 * Version:     27
 * Date:        2004
 * Changes:
 *   (1) Added SysUtils to Uses list for Int/FloatToStr            [04-02-29]
 *   (2) displaymove: DebugLog on exit -- echo curpos related vars [04-02-29]
 *   (2) This stopped right arrow problem even when DL disabled !! [04-02-29]
 *
 * Version:     28
 * Date:        2006
 * Changes:
 *   (1) Interface Uses: remove tp5utils                           [06-04-29]
 *   (2) fstr function:  moved here from tp5utils                  [06-04-29]
 *
 * Version:     29
 * Date:        2017
 * Changes:
 *   (1) display, if docurrent section:                          [2017-03-24]
 *       kludge to suppress "not responding" when mouse clicked
 *}

Implementation

{------------------------------------------------------------}

CONST raysize = 200;

TYPE ray     = ARRAY[1..raysize] OF Single;
     ssdate  = ARRAY[1..raysize] OF String[10];
     sstime  = ARRAY[1..raysize] OF String[8];
     rayptr  = ^ray;
     dateptr = ^ssdate;
     timeptr = ^sstime;

VAR  sd1,  sd2,  sd3,  sd4,  sd5,  sd6,  sd7,  sd8,  sd9, sd10,
    sd11, sd12, sd13, sd14, sd15, sd16: rayptr;
     sdate: dateptr;
     stime: timeptr;
     sdir:  rayptr;

VAR cursor_save_1,
    cursor_save_2: Longint;  {used by zoom feature}

VAR sfilsave: BOOLEAN;
    averaging: BOOLEAN;
    xplo, ddx: float;
    av1, av2, av3, av4, av5, av6, av7, av8, av9, av10, 
    av11, av12, av13, av14: float;
    avdir, avcos, avsin: float;

    dograph, dolast, docurrent, dosnapshot: BOOLEAN;

    recnumber, direc, igrarec, irec, recstart, recend: Longint;
    longseed: Longint;
    rmess: String[24];

    no: INTEGER;

VAR debuglog_handle: INTEGER;

{------------------------------------------------------------}

FUNCTION fstr (val: REAL;    w,d: INTEGER): String;
{Simply a funtional form of Str() for floating point
 J.N.  03/11/94 
 }
VAR s: String;
BEGIN
  Str (val:w:d, s);
  fstr := s;
  END;  {function 'fstr'}
{------------------------------------------------------------}

FUNCTION recavail (no, row: INTEGER): Longint;
{2nd index below maps row 3,4,5,6 to filetype 1,2,3,1}
BEGIN
  recavail := recnum[no, row MOD 3 +1];  {<-- *** WATCH OUT FOR THIS}
  END;  {of function 'recavail'}
{------------------------------------------------------------}

PROCEDURE gcgrid (parms: display_obj32);
{Draw a segment of the horizontal bands about gas
 concentration set point.  This procedure combines 6
 repetitions of code in xloggdis, xstatdis, and xvarrdis.
 The values of the bands, as fractions, are global.
 The value of bracket color must be [0..7] such that
 center color is [8..15].
 J.N.  90/11/08  Original
 J.N.  94/03/09  Use a display_obj
 J.N.  94/03/12  Add more repetitive code (gcset now always sd12).
 }
 CONST bandcolor = Red;
 VAR   aaa, x1, x2, y, gcsett: float;
       i, j, k, inn:  INTEGER;
BEGIN
WITH parms DO IF enable AND (NOT genlop) THEN BEGIN
  i:=1; inn:=1;
  REPEAT
    REPEAT
      IF docurrent THEN inn := 181 ELSE INC(inn);
      UNTIL (sd12^[inn-1]<>sd12^[inn]) OR (inn>disrec);
    x1:=(i-1)*ddx; x2:=x1+(inn-i)*ddx;
    IF NOT docurrent THEN gcsett := sd12^[i]
                     ELSE gcsett := gcset[no];
    IF high > low
      THEN aaa := scale/(high-low)
      ELSE aaa := 1.0;
    y  := offset + aaa*(gcsett-low);
    lline (x1,y,x2,y,bandcolor+8);
    FOR j := 1 TO gcbands DO
      FOR k := 0 TO 1 DO BEGIN
        y := offset + aaa*(gcsett*(1+(2*k-1)*gcband[j])-low);
        lline (x1,y,x2,y,bandcolor);
        END;
    i:=inn
    UNTIL inn>=disrec;
  END;  {with}
  END;  {of procedure 'gcgrid'}
{------------------------------------------------------------}

PROCEDURE graphaxis (info: display_set);
{Make tick marks along left and right axes with correct position and color.
 Put labels next to right axis.                           
 J.N.  94/06/29
 }
VAR i: INTEGER;
    gridvalue: float; 
    tickcolor: INTEGER;
    xticks: float;  {separation of ticks along x-axis}
BEGIN
  {$H+} {MessageBox (0, PCHAR('GRAPHAXIS'), 'Enter...', MB_OK);} {$H-}
  FOR i := max_dsplobj DOWNTO 1 DO 
  WITH info.obj[i] DO 
  IF exists AND enable THEN BEGIN
    oouttext (1.005, offset+0.02+labelpos_dsplobj[i], color, name_dsplobj[i]);
    gridvalue := 0.0;
    tickcolor := color;
    IF i=1 THEN IF NOT genlop THEN BEGIN gridvalue := -9999.9;
                                         tickcolor := White;
                                         END
                              ELSE gridvalue := gcset[no];           
    vtick (offset, scale, low, high, gridvalue, tickcolor);
    END;

  IF dishour >= 1.0 THEN xticks := dishour        {hourly}
                    ELSE xticks := 60.0*dishour;  {minutely}
  htick (0.0,1.0/xticks,0.0,1.0,-1,TRUNC(xticks),15);
  {$H+} {MessageBox (0, PCHAR('GRAPHAXIS'), '...exit', MB_OK);} {$H-}
  END;  {of procedure 'graphaxis'}
{------------------------------------------------------------}

PROCEDURE shiftsd (source, target: INTEGER);
{This procedure copies the contents of the sd arrays
 at index source to index target.
 J.N.  11/9/90}
BEGIN
  sdate^[target] := sdate^[source];
  stime^[target] := stime^[source];
  sdir ^[target] := sdir ^[source];
  sd1  ^[target] := sd1  ^[source];
  sd2  ^[target] := sd2  ^[source];
  sd3  ^[target] := sd3  ^[source];
  sd4  ^[target] := sd4  ^[source];
  sd5  ^[target] := sd5  ^[source];
  sd6  ^[target] := sd6  ^[source];
  sd7  ^[target] := sd7  ^[source];
  sd8  ^[target] := sd8  ^[source];
  sd9  ^[target] := sd9  ^[source];
  sd10 ^[target] := sd10 ^[source];
  sd11 ^[target] := sd11 ^[source];
  sd12 ^[target] := sd12 ^[source];
  sd13 ^[target] := sd13 ^[source];
  sd14 ^[target] := sd14 ^[source];
  END;  {of procedure 'shiftsd'}
{------------------------------------------------------------}

PROCEDURE sd_average (items: INTEGER);
{This procedure computes the average of the values stored in
 the sd^ arrays.
 J.N.  94/07/01  Gathered code from xloggdis()}
VAR i: INTEGER;
BEGIN
  av1  := 0.0;  av2  := 0.0;  av3  := 0.0;  av4  := 0.0;  av5  := 0.0;   
  av6  := 0.0;  av7  := 0.0;  av8  := 0.0;  av9  := 0.0;  av10 := 0.0;   
  av11 := 0.0;  av12 := 0.0;  av13 := 0.0;  av14 := 0.0;  
  avcos := 0.0;  avsin := 0.0;
  FOR i := 1 TO items DO BEGIN
    av1  := av1 +sd1^ [i];
    av2  := av2 +sd2^ [i];
    av3  := av3 +sd3^ [i];
    av4  := av4 +sd4^ [i];
    av5  := av5 +sd5^ [i];
    av6  := av6 +sd6^ [i];
    av7  := av7 +sd7^ [i];
    av8  := av8 +sd8^ [i];
    av9  := av9 +sd9^ [i];
    av10 := av10+sd10^[i];
    av11 := av11+sd11^[i];
    av12 := av12+sd12^[i];
    av13 := av13+sd13^[i];
    av14 := av14+sd14^[i];
    avcos := avcos+COS(Pi*sdir^[i]/180.0);
    avsin := avsin+SIN(Pi*sdir^[i]/180.0);
    END;
  IF items > 0 THEN BEGIN
    av1  := av1 /items;
    av2  := av2 /items;
    av3  := av3 /items;
    av4  := av4 /items;
    av5  := av5 /items;
    av6  := av6 /items;
    av7  := av7 /items;
    av8  := av8 /items;
    av9  := av9 /items;
    av10 := av10/items;
    av11 := av11/items;
    av12 := av12/items;
    av13 := av13/items;
    av14 := av14/items;
    avcos := avcos/items;
    avsin := avsin/items;
    avdir := atan2 (avsin,avcos);
    END;
  END;  {of procedure 'sd_average'}
{------------------------------------------------------------}

PROCEDURE graphsegment (x, dx: float;
                        sd: rayptr; 
                        ifirst, ilast: INTEGER;
                        parms: display_obj32);
{Intermediate routine for scaling, offsetting, and coloring line segments.
 J.N.  03/08/94
 If color is black, operator probably did not set color; use White as flag!
 J.N.  10/03/01
 }
VAR aaa, range: float;
    i: INTEGER;
    c: INTEGER;
BEGIN
  WITH parms DO IF (exists AND enable) THEN BEGIN
    IF (color <> Black) THEN c := color ELSE c := White;
    range := high-low;
    IF range > 0.0
      THEN aaa := scale/range
      ELSE aaa := 1.0;
    FOR i := ifirst TO ilast DO BEGIN
      lline(x, aaa*(sd^[i-1]-low)+offset, x+dx, aaa*(sd^[i]-low)+offset, c);
      x := x + dx;
      END;
    END;  {with}
  END;  {of procedure 'graphsegment'}
{------------------------------------------------------------}

PROCEDURE graphlines_logg (x, dx: float; ifirst, ilast: INTEGER);
{Draws all active logg or aux graph display lines.
 J.N.  03/08/94
 }
VAR working: display_set;
    i: INTEGER;
BEGIN
  WITH disprecord^[no] DO IF loggop THEN working := logg_dspl
                                    ELSE working := genl_dspl;

  WITH working DO BEGIN
    graphsegment (x, dx, sd1,  ifirst, ilast, gc_grab);
    graphsegment (x, dx, sd2,  ifirst, ilast, gc_1min);
    graphsegment (x, dx, sd3,  ifirst, ilast, gc_5min);
    graphsegment (x, dx, sd7,  ifirst, ilast, gc_cntl);
    graphsegment (x, dx, sd8,  ifirst, ilast, gc_ambi);
    graphsegment (x, dx, sd4,  ifirst, ilast, windspeed);
    IF NOT loggop THEN
      FOR i := ifirst TO ilast DO 
        sd15^[i] := wd_90450 (sdir^[i], sd15^[i-1]);
    graphsegment (x, dx, sd15, ifirst, ilast, winddirection);
    graphsegment (x, dx, sd5,  ifirst, ilast, pv_control);
    graphsegment (x, dx, sd6,  ifirst, ilast, pv_response);
    graphsegment (x, dx, sd9,  ifirst, ilast, temperature1);
    graphsegment (x, dx, sd10, ifirst, ilast, pressure);
    graphsegment (x, dx, sd11, ifirst, ilast, radiation);
    graphsegment (x, dx, sd13, ifirst, ilast, temperature2);
    graphsegment (x, dx, sd14, ifirst, ilast, ph2o);
    END;  {with}
  END;  {of procedure 'graphlines_logg'}
{------------------------------------------------------------}

PROCEDURE xloggdis;
VAR ydis, alp: float;
    i, nput: INTEGER;
    working: display_set;

PROCEDURE loadsd (index: INTEGER);  {local for logg}
{Load 'sd' arrays at 'index' from loggrecord[no]}
BEGIN
  WITH loggrecord[no] DO BEGIN
    sdate^[index] := showdate(ddate);
    stime^[index] := showtime(ttime);
    sdir^ [index] := wwwdir;
    sd1^  [index] := ggcgrab;
    sd2^  [index] := aagc1m;
    sd3^  [index] := aagc5m;
    sd4^  [index] := wwspeed;
    sd5^  [index] := ppropc;
    sd6^  [index] := ppropresp;
    sd7^  [index] := ggccntl;
    sd8^  [index] := ggcambi;
    sd9^  [index] := ttemp1;
    sd10^ [index] := aairpres;
    sd11^ [index] := ssolrad;
    sd12^ [index] := ggcset;
    sd13^ [index] := ttemp2;
    sd14^ [index] := pph2o;
    END;
  END;  {of local procedure 'loadsd' for logg}

BEGIN
  {$H+} {MessageBox (0, PCHAR('XLOGGDIS'), 'Enter...', MB_OK);} {$H-}

WITH disprecord^[no] DO IF loggop THEN working := logg_dspl
                                  ELSE working := genl_dspl;

WITH disprecord^[no] DO WITH working DO BEGIN

  oouttext (0.50-0.007*Length(rmess), 1.03, 2, rmess);

  tinter;

  IF firstpas AND (NOT docurrent) THEN BEGIN
    ir:=1;
    sfilsave:=sfil[no,1];  sfil[no,1]:=FALSE;  RESET(logg[no]);
    IF dolast THEN BEGIN
      recend:=filesize(logg[no]);
      irec:=recend-igrarec+1+loggpoint[no];
      IF irec<1 THEN irec:=1;
      recstart:=irec;
      recnumber:=irec;
      loggwrite[no]:=FALSE;
      END;

    REPEAT
      Seek(logg[no],irec-1);
      READ(logg[no],loggrecord[no]);
      loadsd(ir);
      irec:=irec+direc; ir:=ir+1;
      UNTIL (irec>recend) OR (irec>recavail(no,row));
    CloseFile (logg[no]);  sfil[no,1]:=sfilsave;

    IF dolast THEN BEGIN  {not done if dograph -- J.N.}
      i:=1;
      WHILE i<loggpoint[no] DO BEGIN
        loggrecord[no]:=loggfile^[(no-1)*10+i];
        loadsd(ir);
        irec:=irec+direc; ir:=ir+1; recend:=recend+direc;
        i:=i+direc;
        END;
      END;
    END;

  tinter;

  IF dograph OR (dolast AND firstpas) THEN BEGIN
    disrec:=ir-1;
    ir:=1;
    END;

  IF dograph THEN ddx:=1.0/disrec ELSE ddx:=1.0/180.0;

  shiftsd(disrec,disrec+1);
  IF irec>recavail(no,row) THEN fileend:=TRUE;

  IF firstpas THEN BEGIN
    graphaxis (working);
    gcgrid (gc_grab);
    graphlines_logg (0.0, ddx, 2, disrec);
    xplo := disrec*ddx;
    END;

  IF (NOT firstpas) AND (dolast OR docurrent) THEN BEGIN
    IF disrec<181 THEN BEGIN
      graphlines_logg (xplo, ddx, disrec, disrec);
      xplo:=xplo+ddx;
      recend:=recend+direc;
      END
    ELSE IF disrec>180 THEN BEGIN
      gclear (0.0, 0.0, 1.0, 1.0, clBlack);
      bbox   (0.0, 0.0, 1.0, 1.0, White);
      FOR i:=1 TO 181-inext DO shiftsd(i+inext,i);
      recnumber:=recnumber+direc;
      recstart:=recstart+inext*direc;
      recend:=recend+direc; disrec:=disrec-inext;
      graphaxis (working);
      gcgrid (gc_grab);
      graphlines_logg (0.0, ddx, 2, disrec);
      xplo := disrec*ddx;
      END;
    END;

  tinter;

  FOR i := 1 TO gcbands DO overband[i] := 0.0;
  FOR i:=1 TO disrec DO BEGIN
    IF ABS(sd1^[i]-sd12^[i])>sd12^[i]*gcband[3]
      THEN overband[3] := overband[3]+1.0;
    IF ABS(sd2^[i]-sd12^[i])>sd12^[i]*gcband[2]
      THEN overband[2] := overband[2]+1.0;
    IF ABS(sd2^[i]-sd12^[i])>sd12^[i]*gcband[1]
      THEN overband[1] := overband[1]+1.0;
    END;
  FOR i := 1 TO gcbands DO
    overband[i] := overband[i]*100.0/disrec;

  sd_average (disrec);

  IF firstpas THEN BEGIN
    IF fileend THEN tex(63,20,'ENDoFILE',LightGreen);
    tex(1,21,'From',14); tex(27,21,'to',14);
    tex(51,21,'Display window:           Hr',12);
    tex(1,22,'Cursor:',14); tex(27,22,'RecNo:',12);
    tex(39,22,'Averaging:',11); tex(51,22,'Zoom:',11);
    IF loggop THEN BEGIN
      tex ( 1,23, 'Display data',      14);
      tex (19,23, 'Ov20%In:',          12);
      tex (35,23, 'Ov10%1m:',          12);
      tex (51,23, 'Ov20%1m:',          12);
      tex (67,23, 'PVCon:',            12);
      tex ( 1,24, 'Display variables', 14);
      tex (19,24, ' WSpeed:',          12);
      tex (35,24, '   WDir:',          12);
      tex (51,24, '  GConc:',          12);
      tex (67,24, 'PVRes:',            12);
      END;
    IF genlop THEN BEGIN
      tex ( 1,23, 'GCgrab:', 14);
      tex (14,23, 'GC1min:', 14);
      tex (27,23, 'GC5min:', 14);
      tex (40,23, 'GCcntl:', 14);
      tex (53,23, 'WSpeed:', 14);
      tex (66,23, '  WDir:', 14);
      tex ( 1,24, 'PvCntl:', 14);
      tex (14,24, 'PvResp:', 14);
      tex (27,24, '  Temp:', 14);
      tex (40,24, '  Pres:', 14);
      tex (53,24, 'SolRad:', 14);
      tex (66,24, '   H2O:', 14);
      END;
    END;

  IF dolast OR docurrent THEN firstpas:=FALSE;
  IF docurrent THEN BEGIN
    recnumber:=recend;
    irec:=disrec;
    END;

  END;  {with disprecord}
  {$H+} {MessageBox (0, PCHAR('XLOGGDIS'), '...exit', MB_OK);} {$H-}
  END;  {of procedure 'xloggdis'}
{------------------------------------------------------------}

PROCEDURE graphlines_varr (x, dx: float; ifirst, ilast: INTEGER);
{Draws all active varr graph display lines.
 J.N.  03/08/94
 }
BEGIN
WITH disprecord^[no].varr_dspl DO BEGIN
  graphsegment (x, dx, sd1,  ifirst, ilast, gc_cont);
  graphsegment (x, dx, sd11, ifirst, ilast, gc_grab);
  graphsegment (x, dx, sd2,  ifirst, ilast, term_int);
  graphsegment (x, dx, sd3,  ifirst, ilast, term_prop);
  graphsegment (x, dx, sd4,  ifirst, ilast, term_diff);
  graphsegment (x, dx, sd5,  ifirst, ilast, term_wind);
  graphsegment (x, dx, sd6,  ifirst, ilast, pv_control);
  END;  {with}
  END;  {of procedure 'graphlines_varr'}
{------------------------------------------------------------}

PROCEDURE xvarrdis;
VAR ydis, alp: float;
    i: INTEGER;
PROCEDURE loadsd (index: INTEGER);  {local for varr}
{Load 'sd' arrays at 'index' from varrecord[no]}
BEGIN
  WITH varrecord[no] DO BEGIN
    sdate^[index] := showdate(ddate);
    stime^[index] := showtime(ttime);
    sd1^  [index] := ggcav;
    sd2^  [index] := ccinteg;
    sd3^  [index] := ccprop;
    sd4^  [index] := ccdiff;
    sd5^  [index] := ccwind;
    sd6^  [index] := ppropc;
    sd7^  [index] := aainteg_adj;
    sd8^  [index] := aaprop_adj;
    sd9^  [index] := aadiff_adj;
    sd10^ [index] := aawind_adj;
    sd11^ [index] := ggcinst;
    sd12^ [index] := ggcset;
    END;
  END;  {of local procedure 'loadsd' for varr}

BEGIN
WITH disprecord^[no] DO WITH varr_dspl DO BEGIN

  oouttext (0.50-0.007*Length(rmess), 1.03, 2, rmess);

  IF firstpas AND (NOT docurrent) THEN BEGIN
    ir:=1;
    sfilsave:=sfil[no,3];  sfil[no,3]:=FALSE;  RESET(varr[no]);
    IF dolast THEN BEGIN
      recend:=filesize(varr[no]);
      irec:=recend-igrarec+1; IF irec<1 THEN irec:=1;
      recstart:=irec; recnumber:=irec;
      varrwrite[no]:=FALSE;
      END;
    REPEAT
      Seek(varr[no],irec-1);
      READ(varr[no],varrecord[no]);
      loadsd(ir);
      irec:=irec+direc; ir:=ir+1;
      UNTIL (irec>recend) OR (irec>recavail(no,row));
    CloseFile (varr[no]);  sfil[no,3]:=sfilsave;
    END;

  tinter;

  IF dograph OR (dolast AND firstpas) THEN BEGIN
    disrec:=ir-1;
    ir:=1;
    END;

  IF dograph THEN ddx:=1.0/disrec ELSE ddx:=1.0/180.0;

  shiftsd (disrec, disrec+1);
  IF irec>recavail(no,row) THEN fileend:=TRUE;

  IF firstpas THEN BEGIN
    graphaxis (varr_dspl);
    gcgrid (gc_grab);
    graphlines_varr (0.0, ddx, 2, disrec);
    xplo := disrec*ddx;
    END;

  IF (NOT firstpas) AND (dolast OR docurrent) THEN BEGIN
    IF disrec<181 THEN BEGIN
      graphlines_varr (xplo, ddx, disrec, disrec);
      xplo:=xplo+ddx;
      recend:=recend+direc;
      END
    ELSE IF disrec>180 THEN BEGIN
      gclear (0.0, 0.0, 1.0, 1.0, clBlack);
      bbox   (0.0, 0.0, 1.0, 1.0, White);
      FOR i:=1 TO 181-inext DO shiftsd (i+inext, i);
      recnumber:=recnumber+direc; recstart:=recstart+inext*direc;
      recend:=recend+direc; disrec:=disrec-inext;
      graphaxis (varr_dspl);
      gcgrid (gc_grab);
      graphlines_varr (0.0, ddx, 2, disrec);
      xplo := disrec*ddx;
      END;
    END;

  tinter;

  FOR i := 1 TO gcbands DO overband[i] := 0.0;
  FOR i := 1 TO disrec DO
    IF ABS(sd1^[i]-sd12^[i])>sd12^[i]*gcband[2]
      THEN overband[2] := overband[2]+1.0;
  overband[2]:=overband[2]*100.0/disrec;

  IF firstpas THEN BEGIN
    IF fileend THEN 
    tex (63,20, 'ENDoFILE', 27);
    tex ( 1,21, 'From', 14);
    tex (27,21, 'to', 14); 
    tex (51,21, 'Display window:           Hr', 12);
    tex (77,21, 'Hr', 12);
    tex ( 1,22, 'Cursor:', 14); 
    tex (27,22, 'RecNo:', 12);
    tex (51,22, 'Ov10%Av:', 12);
    tex ( 1,23, 'Ctrl coeff', 14);
    tex (12,23, 'Aintg:', 12);
    tex (25,23, 'Aprop:', 12);
    tex (38,23, 'Adiff:', 12);
    tex (51,23, 'Awind:', 12);
    tex (64,23, 'WSgrab:', 14);
    tex ( 1,24, 'Ctrl term ', 14);
    tex (12,24, 'Intgc::', 12);
    tex (25,24, 'Propc:', 12);
    tex (38,24, 'Diffc::', 12);
    tex (51,24, 'Windc:', 12);
    tex (64,24, 'PIDfac:', 14);
  END;

  IF dolast OR docurrent THEN firstpas:=FALSE;
  IF docurrent THEN BEGIN
    recnumber:=recend;
    irec:=disrec;
    END;

  END;  {with disprecord}
  END;  {of procedure 'xvarrdis'}
{------------------------------------------------------------}

PROCEDURE graphlines_snap (x, dx: float; ifirst, ilast: INTEGER);
{Draws all active snap shot graph display lines.
 J.N.  94/06/29
 }
BEGIN
WITH disprecord^[no].snap_dspl DO BEGIN
  graphsegment (x, dx, sd1,  ifirst, ilast, gc_grab);
  graphsegment (x, dx, sd2,  ifirst, ilast, gc_1min);
  graphsegment (x, dx, sd3,  ifirst, ilast, gc_cntl);
  graphsegment (x, dx, sd4,  ifirst, ilast, pv_control);
  graphsegment (x, dx, sd5,  ifirst, ilast, pv_response);
  graphsegment (x, dx, sd6,  ifirst, ilast, term_int);
  graphsegment (x, dx, sd7,  ifirst, ilast, term_prop);
  graphsegment (x, dx, sd8,  ifirst, ilast, term_wind);
  graphsegment (x, dx, sd9,  ifirst, ilast, windspeed);
  graphsegment (x, dx, sdir, ifirst, ilast, winddirection);
  END;  {with}
  END;  {of procedure 'graphlines_snap'}
{------------------------------------------------------------}

PROCEDURE xsnapdis;
VAR i: INTEGER;
PROCEDURE loadsd (index: INTEGER);  {local for snap shot}
{Load 'sd' arrays at 'index' from snap shot ring buffer}
BEGIN
  WITH snapshot_ray^[no][snapshot_show]^[index] DO BEGIN
    stime^[index] := showtime(zeit);
    sdir^ [index] := winddir;
    sd1^  [index] := igcgrab;
    sd2^  [index] := igc1min;
    sd3^  [index] := igccntl;
    sd4^  [index] := propctl / 10.0;
    sd5^  [index] := proprsp / 10.0;
    sd6^  [index] := kinteg  / 10.0;
    sd7^  [index] := kprop   / 10.0;
    sd8^  [index] := kwind   / 10.0;
    sd9^  [index] := windspd / 100.0;
    sd12^ [index] := igcset;
    END;
  END;  {of local procedure 'loadsd' for snap shot}

BEGIN
WITH disprecord^[no] DO WITH snap_dspl DO BEGIN

  oouttext (0.50-0.007*Length(rmess), 1.03, 2, rmess);

  IF snapshot_show = snapshot_fill THEN disrec := snapshot_index
                                   ELSE disrec := 180;
                                   
  FOR i := 1 TO disrec DO loadsd(i);

  tinter;

  ddx:=1.0/180.0;

  graphaxis (snap_dspl);
  gcgrid (gc_grab);
  graphlines_snap (0.0, ddx, 2, disrec);
  xplo := disrec*ddx;

  sd_average (disrec);

  tinter;

  IF firstpas THEN BEGIN
    tex ( 1,21, 'From', 14);
    tex (27,21, 'to', 14); 
    tex (51,21, 'Display window:', 12);
    tex (77,21, 'Hr', 12);
    tex ( 1,22, 'Cursor:', 14); 
    tex (27,22, 'RecNo:', 12);
    tex (39,22, 'Averaging:',11);
    tex ( 1,23, 'GC-Gr:', 12);
    tex (14,23, 'GC-1m:', 12);
    tex (27,23, 'GC-Cl:', 12);
    tex (41,23, 'Cintg:', 12);
    tex (54,23, 'Cprop:', 12);
    tex (67,23, 'Cwind:', 12);
    tex ( 1,24, ' WSpd:', 12);
    tex (14,24, ' WDir:', 12);
    tex (41,24, 'PVCtl:', 12);
    tex (54,24, 'PVRsp:', 12);
    END;

  firstpas:=FALSE;

  END;  {with disprecord}
  END;  {of procedure 'xsnapdis'}
{------------------------------------------------------------}

PROCEDURE dispsel;
BEGIN
  {$H+} {MessageBox (0, PCHAR('DISPSEL'), 'Enter...', MB_OK);} {$H-}
  IF (NOT docurrent) OR (docurrent AND (disrec = 2)) THEN BEGIN
    bbox(0.0,0.0,1.0,1.0,7);

    oouttext(1.005,1.02,11,'ESC');
      SetColor(10); OutText(' Quit');
    oouttext(1.005,0.98,11,CHR(27)+CHR(26));
      SetColor(10); OutText('Cursor');
    oouttext(1.005,0.94,11,CHR(25)+CHR(24));
      SetColor(10); OutText(' MORE');
    oouttext(1.005,0.90,11,'--------');
  
    mouse_clear (0);
    mouse_add (1, transformx(1.005), grmaxx, 
                  transformy(0.98), transformy(0.94), 0, 75);
    mouse_add (2, transformx(1.005), grmaxx, 
                  transformy(0.98), transformy(0.94), 0, 77);
    mouse_add (1, transformx(1.005), grmaxx, 
                  transformy(0.94), transformy(0.90), 0, 80);
    mouse_add (2, transformx(1.005), grmaxx, 
                  transformy(0.94), transformy(0.90), 0, 72);
    mouse_add (3, transformx(1.005), grmaxx, 0, grmaxy, 27, 0);
    mouse_add (3, transformx(0.6), transformx(1.0), 
                  transformy(0.0), grmaxy, ORD('Z'), 0);
    mouse_add (3, transformx(0.0), transformx(1.0), 
                  transformy(0.0), grmaxy, ORD('A'), 0);
    mouse_add (3, transformx(0.0), transformx(1.0), 
                  transformy(1.0), transformy(0.0), 0, 1);
    END;

  IF loggop OR genlop THEN BEGIN
    ifi:=1;
    xloggdis;
    END
  ELSE IF varrop THEN BEGIN
    ifi:=3;
    xvarrdis;
    END
  ELSE IF snapop THEN xsnapdis;
  {$H+} {MessageBox (0, PCHAR('DISPSEL'), '...exit', MB_OK);} {$H-}
  END;  {of procedure 'dispsel'}
{------------------------------------------------------------}

PROCEDURE discomm;
VAR datacolor: INTEGER;
    sss1, sss2, sss3, sss4, sss5, sss6, sss7, sss8, sss9, 
    sss10, sss11, sss12: String[10];
BEGIN
  IF DebugLogEnableGet (debuglog_handle) THEN BEGIN
    DebugLogFileWrite (debuglog_handle, 'discomm: Enter...');
    DebugLogFileFlush;
    END;
  {$H+} {MessageBox (0, PCHAR('DISCOMM'), 'Enter...', MB_OK);} {$H-}
  IF docurrent THEN ir:=disrec;
  IF NOT docurrent THEN lline(curpos, 0.002, curpos, 0.998, 15);
  rtex ( 8, 21, sdate^[1]     +' '+stime^[1],     10);
  rtex (30, 21, sdate^[disrec]+' '+stime^[disrec],10);
  rtex ( 8, 22, sdate^[ir]    +' '+stime^[ir],    10);
  rtex (67, 21, fstr(dishour,8,2), 10);
  rtex (32, 22, istr(recnumber,7), 10);

  IF loggop THEN BEGIN
    rtex (28, 23, fstr(overband[3],6,2), 10);       
    rtex (44, 23, fstr(overband[2],6,2), 10); 
    rtex (60, 23, fstr(overband[1],6,2), 10);
    IF averaging
      THEN BEGIN
        datacolor := White;
        Str(av4     :6:2,sss1);  Str(avdir   :3:0 ,sss2); 
        Str(av1     :7:2,sss3);  
        Str(av5     :7:2,sss4);  Str(av6     :7:2,sss5);
        END
      ELSE BEGIN
        datacolor := 10;
        Str(sd4^[ir]:6:2,sss1);  Str(sdir^[ir]:3:0,sss2); 
        Str(sd1^[ir]:7:2,sss3);  
        Str(sd5^[ir]:7:2,sss4);  Str(sd6^[ir]:7:2,sss5);
        END;
    rtex(28,24,sss1,datacolor);     rtex(45,24,sss2,datacolor);
    rtex(59,24,sss3,datacolor);     
    rtex(73,23,sss4,datacolor);     rtex(73,24,sss5,datacolor);
    END ELSE

  IF genlop THEN BEGIN
    IF averaging
      THEN BEGIN
        datacolor := White;
        Str(av1  :4:0,sss1 );  Str(av2  :4:0,sss2 );  Str(av3  :4:0,sss3 );
        Str(av7  :4:0,sss4 );  Str(av4  :4:1,sss5 );  Str(av5  :4:0,sss6 );
        Str(av6  :4:0,sss7 );  Str(av9  :5:1,sss8 );  Str(av10 :5:1,sss9 );
        Str(av11 :5:0,sss10);  Str(av14 :4:0,sss12);  Str(avdir:4:0,sss11);
        END
      ELSE BEGIN
        datacolor := 10;
        Str(sd1 ^[ir]:4:0,sss1 );  Str(sd2 ^[ir]:4:0,sss2 );  
        Str(sd3 ^[ir]:4:0,sss3 );  Str(sd7 ^[ir]:4:0,sss4 );  
        Str(sd4 ^[ir]:4:1,sss5 );  Str(sd5 ^[ir]:4:0,sss6 );
        Str(sd6 ^[ir]:4:0,sss7 );  Str(sd9 ^[ir]:5:1,sss8 );  
        Str(sd10^[ir]:5:1,sss9 );  Str(sd11^[ir]:5:0,sss10);  
        Str(sd14^[ir]:4:0,sss12);
        Str(sdir^[ir]:4:0,sss11);
        END;
    rtex ( 8, 23, sss1,  datacolor);  rtex (21, 23, sss2,  datacolor);
    rtex (34, 23, sss3,  datacolor);  rtex (47, 23, sss4,  datacolor);
    rtex (60, 23, sss5,  datacolor);  rtex (73, 23, sss11, datacolor);
    rtex ( 8, 24, sss6,  datacolor);  rtex (21, 24, sss7,  datacolor);
    rtex (34, 24, sss8,  datacolor);  rtex (47, 24, sss9,  datacolor);
    rtex (60, 24, sss10, datacolor);  rtex (73, 24, sss12, datacolor);
    END ELSE

  IF varrop THEN BEGIN
       datacolor := 10;
       rtex (60, 22, fstr(overband[2],6,2), datacolor);
       rtex (18, 23, fstr(sd7^ [ir],6,2), datacolor); 
       rtex (31, 23, fstr(sd8^ [ir],6,2), datacolor);
       rtex (44, 23, fstr(sd9^ [ir],6,2), datacolor); 
       rtex (57, 23, fstr(sd10^[ir],6,2), datacolor);
       rtex (18, 24, fstr(sd2^ [ir],6,2), datacolor);  
       rtex (31, 24, fstr(sd3^ [ir],6,2), datacolor);
       rtex (44, 24, fstr(sd4^ [ir],6,2), datacolor);  
       rtex (57, 24, fstr(sd5^ [ir],6,2), datacolor);
       IF docurrent THEN BEGIN
         rtex (72, 23, fstr(   wspeed[no],6,2), datacolor);
         rtex (72, 24, fstr(pidfactor[no],6,2), datacolor);
         END;
       END ELSE

  IF snapop THEN BEGIN
    IF averaging
      THEN BEGIN
        datacolor := White;
        Str(av1  :5:0,sss1 );  Str(av2  :5:0,sss2 );  Str(av3  :5:0,sss3 );
        Str(av4  :5:1,sss4 );  Str(av5  :5:1,sss5 );
        Str(av6  :5:1,sss6 );  Str(av7  :5:1,sss7 );  Str(av8  :5:1,sss8 );
        Str(av9  :5:2,sss9 );  Str(avdir:5:0,sss10);
        END
      ELSE BEGIN
        datacolor := 10;
        Str(sd1^[ir]:5:0,sss1); Str(sd2^[ir]:5:0,sss2); Str(sd3^[ir]:5:0,sss3);
        Str(sd4^[ir]:5:1,sss4); Str(sd5^[ir]:5:1,sss5);
        Str(sd6^[ir]:5:1,sss6); Str(sd7^[ir]:5:1,sss7); Str(sd8^[ir]:5:1,sss8);
        Str(sd9^[ir]:5:2,sss9); Str(sdir^[ir]:5:0,sss10);
        END;
    rtex ( 8, 23, sss1,  datacolor);  rtex (21, 23, sss2,  datacolor);
    rtex (34, 23, sss3,  datacolor);  rtex (48, 23, sss6,  datacolor);
    rtex (61, 23, sss7,  datacolor);  rtex (74, 23, sss8,  datacolor);
    rtex ( 8, 24, sss9,  datacolor);  rtex (21, 24, sss10, datacolor);
    rtex (48, 24, sss4,  datacolor);  rtex (61, 24, sss5,  datacolor);
    END ELSE;

  IF loggop OR genlop THEN BEGIN
    IF (cursor_save_1 <= cursor_save_2) 
      THEN BEGIN
        rtex (56, 22, istr (cursor_save_1, 7), 10);
        rtex (62, 22, istr (cursor_save_2, 7), 10);
        END
      ELSE BEGIN
        rtex (56, 22, istr (cursor_save_2, 7), 10);
        rtex (62, 22, istr (cursor_save_1, 7), 10);
        END;
    END;

  IF loggop OR genlop OR snapop THEN 
    IF averaging THEN rtex (47, 22, ' ON', datacolor)
                 ELSE rtex (47, 22, 'OFF', datacolor);

  {$H+} {MessageBox (0, PCHAR('DISCOMM'), '...exit', MB_OK);} {$H-}
  IF DebugLogEnableGet (debuglog_handle) THEN BEGIN
    DebugLogFileWrite (debuglog_handle, 'discomm: ...exit');
    DebugLogFileFlush;
    END;
  END;  {of procedure 'discomm'}
{------------------------------------------------------------}

PROCEDURE displaymove;
VAR rectemp: Longint;
    step,
    points:    INTEGER;
BEGIN
  IF DebugLogEnableGet (debuglog_handle) THEN BEGIN
    DebugLogFileWrite (debuglog_handle, 'displaymove: Enter...');
    DebugLogFileFlush;
    END;
    IF curpos>0.00000001 THEN lline (curpos, 0.002, curpos, 0.998, 0);
    IF loggop OR genlop THEN graphlines_logg (curpos, ddx, ir+1, ir+1)
    ELSE IF snapop      THEN graphlines_snap (curpos, ddx, ir+1, ir+1)
    ELSE IF varrop      THEN BEGIN
      graphlines_varr (curpos, ddx, ir+1, ir+1);
      mmoveto(curpos,0.45);
      END;

    IF ahr IN [116, 115, 77, 75, 1, 72, 80, 73, 81] THEN BEGIN
      IF ahr IN [116, 115, 77, 75, 1] THEN BEGIN  {move cursor line}
             IF ahr=116 THEN step :=  10
        ELSE IF ahr=115 THEN step := -10
        ELSE IF ahr=77  THEN step :=   1
        ELSE IF ahr=75  THEN step :=  -1
        ELSE IF ahr=1   THEN BEGIN
          IF dograph
            THEN points := disrec
            ELSE points := 180;
          step := ROUND (points*
            (graph32.Event.X-transformx(0))/(transformx(1)-transformx(0)));
        {WRITE ('Step A: ', step:1, '  ');}
          IF snapop THEN step := step - ir
                    ELSE step := step - (recnumber-recstart) DIV direc;
        {WRITE ('Step B: ', step:1, '  ');}
          END;
        rectemp := recnumber + step*direc;
        {WRITELN (recstart:6, recend:6, recnumber:6, step:6, rectemp:6);}
        IF (NOT snapop) AND
           (rectemp <= recend{-direc}) AND
           (dolast OR (rectemp <= recnum[no,ifi]-direc)) AND
           (rectemp >= recstart) THEN BEGIN
             recnumber := rectemp;
             IF (ahr = 1) THEN BEGIN  {if mouse used, save for possible zoom}
               cursor_save_2 := cursor_save_1;
               cursor_save_1 := recnumber;
               END;
             curpos := curpos + step*ddx; 
             ir := ir+step; 
             irpos := ir;
            END;
        IF snapop THEN BEGIN
          rectemp := ir + step;
          IF (rectemp > 0) AND (rectemp <= 180) THEN BEGIN
            ir := rectemp;
            recnumber := recnumber + step;
            curpos := curpos + step*ddx;
            END;
          END;
        END;
      IF ahr IN [72, 80, 73, 81] THEN BEGIN  {new screen}
        IF NOT snapop THEN BEGIN
          IF (ahr=72) AND 
             (NOT fileend) AND
             ((recend+direc)<recavail(no,row)) THEN BEGIN  {up arrow}
               recstart := recend+direc;
               recend   := recend+igrarec;
               END;
          IF ahr=80 THEN BEGIN                             {down arrow}
            recstart := recstart-igrarec;  
            IF recstart<1 THEN recstart := 1;
            fileend := FALSE;
            recend := recstart+igrarec-1;
            END;
          irec      := recstart;
          recnumber := recstart;
          END;
        IF snapop THEN BEGIN
          IF ahr=72 THEN step :=   1;  {up arrow}
          IF ahr=80 THEN step :=  -1;  {down arrow}
          IF ahr=73 THEN step :=  10;  {PgUp}
          IF ahr=81 THEN step := -10;  {PgDn}
          snapshot_show := snapshot_show + step;
          IF snapshot_show > snapshot_size THEN snapshot_show := 1;
          IF snapshot_show < 1             THEN snapshot_show := snapshot_size;
          recnumber := 1 + longseed * 180 * 
           ((snapshot_size+snapshot_show-snapshot_fill-1) MOD snapshot_size);
          END;
        gclear (0.0, 0.0, 1.0, 1.0, clBlack);
        bbox   (0.0, 0.0, 1.0, 1.0, White);
        ir := 1; 
        curpos := 0.0;
        dispsel;
        END;
      discomm;
      END

    ELSE IF UpCase(calr)='A' THEN BEGIN
      averaging := NOT averaging;
      discomm;
      END;

  IF DebugLogEnableGet (debuglog_handle) THEN BEGIN
    DebugLogFileWrite (debuglog_handle, 'alr:      '+IntToStr(alr));
    DebugLogFileWrite (debuglog_handle, 'ahr:      '+IntToStr(ahr));
    DebugLogFileWrite (debuglog_handle, 'step:     '+IntToStr(step));
    DebugLogFileWrite (debuglog_handle, 'points:   '+IntToStr(points));
    DebugLogFileWrite (debuglog_handle, 'direc:    '+IntToStr(direc));
    DebugLogFileWrite (debuglog_handle, 'recnumber:'+IntToStr(recnumber));
    DebugLogFileWrite (debuglog_handle, 'ddx:      '+FloatToStr(ddx));
    DebugLogFileWrite (debuglog_handle, 'curpos:   '+FloatToStr(curpos));
    DebugLogFileWrite (debuglog_handle, 'ir:       '+IntToStr(ir));
    DebugLogFileWrite (debuglog_handle, 'irpos:    '+IntToStr(irpos));
    DebugLogFileWrite (debuglog_handle, 'displaymove: ...exit');
    DebugLogFileFlush;
    END;
  END;  {of procedure 'displaymove'}
{------------------------------------------------------------}

PROCEDURE display;
VAR ndis,nput: INTEGER;

BEGIN
  NEW(sdate); NEW(stime); NEW(sdir);
  NEW(sd1);   NEW(sd2);   NEW(sd3);  NEW(sd4);  NEW(sd5);
  NEW(sd6);   NEW(sd7);   NEW(sd8);  NEW(sd9);  NEW(sd10); 
  NEW(sd11);  NEW(sd12);  NEW(sd13); NEW(sd14); NEW(sd15);
  FOR ndis := 1 TO raysize DO BEGIN
    sdate^[ndis]:=' '; stime^[ndis]:=' '; sdir^[ndis]:=0.0;
    sd1^ [ndis]:=0.0;  sd2^ [ndis]:=0.0;  sd3^ [ndis]:=0.0;
    sd4^ [ndis]:=0.0;  sd5^ [ndis]:=0.0;  sd6^ [ndis]:=0.0;
    sd7^ [ndis]:=0.0;  sd8^ [ndis]:=0.0;  sd9^ [ndis]:=0.0;
    sd10^[ndis]:=0.0;  sd11^[ndis]:=0.0;
    sd13^[ndis]:=0.0;  sd14^[ndis]:=0.0;  sd15^[ndis]:=0.0;  
    END;

  InitGraph (grdriver, grmode, '');

  SetBkMode (hDCGraph, OPAQUE);
  SetBkMode (memDC,    OPAQUE);
  {$H+}
  IF loggop 
    THEN SetWindowText (hWndGraph, PCHAR('LOGG '      + STRING(rmess)));
  IF genlop 
    THEN SetWindowText (hWndGraph, PCHAR('AUXILIARY ' + STRING(rmess)));
  IF varrop 
    THEN SetWindowText (hWndGraph, PCHAR('VARR '      + STRING(rmess)));
  IF snapop 
    THEN SetWindowText (hWndGraph, PCHAR('SNAPSHOT '  + STRING(rmess)));
  {$H-}
  
  grmaxx := GetMaxX;
  grmaxy := GetMaxY;

  {Paint whole client area black}
  gra.screen (0.0, 0.0, 1.0, 1.0);
  gclear (0.0, 0.0, 1.0, 1.0, clBlack);

  {Define Kolber's subscreen}
  gra.screen (0.05, 0.176, 0.8438, 0.8);

  averaging := FALSE;

  ir:=1; curpos := 0.0; irpos:=1;
  IF dolast THEN inext:=1 ELSE IF docurrent THEN inext:=60;
  firstpas:=TRUE;

  IF dograph OR dosnapshot THEN BEGIN
    dispsel; discomm;
    REPEAT
      kbin;
      displaymove;
      UNTIL (alr=27) OR NOT(IsWindow(hWndGraph));
    END

  ELSE IF dolast THEN REPEAT
    dataput[no]:=FALSE; loggput[no]:=FALSE; varrput[no]:=FALSE;
    nput:=0;
    dispsel; discomm;
    REPEAT
      tinter;
      IF KeyPressed OR graph32.Event.Flag THEN BEGIN
        tinter;
        ikbin;
        displaymove;
        END;
      IF (loggop OR genlop) AND loggput[no] THEN BEGIN
        loggput[no]:=FALSE;
        nput:=nput+1;
        IF nput=direc THEN BEGIN
          dataput[no]:=TRUE;
          disrec:=disrec+1;
          sdate^[disrec]:=showdate(date); 
          stime^[disrec]:=showtime(time);
          sdir^[disrec]:=wwdir[no];
          sd1^ [disrec]:=gcgrab[no];
          sd2^ [disrec]:=agc1m[no].Integral;
          sd3^ [disrec]:=agc5m[no].Integral;
          sd4^ [disrec]:=wspeed[no];
          sd5^ [disrec]:=propc[no];
          sd6^ [disrec]:=propresp[no];
          sd7^ [disrec]:=gccntl[no];
          sd8^ [disrec]:=gcambi[no];
          sd9^ [disrec]:=temp1[no];
          sd10^[disrec]:=airpres[no];
          sd11^[disrec]:=solrad[no];
          sd12^[disrec]:=gcset[no];
          sd13^[disrec]:=temp2[no];
          sd14^[disrec]:=ph2o[no];
          nput:=0;
        END;
      END ELSE
      IF varrop AND varrput[no] THEN BEGIN
        varrput[no]:=FALSE;
        nput:=nput+1;
        IF nput=direc THEN BEGIN
          dataput[no]:=TRUE;
          disrec:=disrec+1;
          sdate^[disrec]:=showdate(date); 
          stime^[disrec]:=showtime(time);
          sd1^[disrec]:=agcont[no].Integral;
          sd2^[disrec]:=cinteg[no];
          sd3^[disrec]:=cprop[no];
          sd4^[disrec]:=cdiff[no];
          sd5^[disrec]:=cwind[no];
          sd6^[disrec]:=propc[no];
          sd7^[disrec]:=ainteg_adj[no];
          sd8^[disrec]:=aprop_adj[no];
          sd9^[disrec]:=adiff_adj[no];
          sd10^[disrec]:=awind[no];
          sd11^[disrec]:=gcgrab[no];
          sd12^[disrec]:=gcset[no];
          nput:=0;
        END;
      END;
    UNTIL dataput[no] OR (alr=27) OR NOT(IsWindow(hWndGraph));
    dataput[no]:=FALSE;
  UNTIL (alr=27) OR NOT(IsWindow(hWndGraph))

  ELSE IF docurrent THEN REPEAT
    IF disrec>1 THEN BEGIN
      dispsel; 
      discomm;
      END;
    idataput[no]:=FALSE;
    REPEAT
      tinter;
      IF KeyPressed OR graph32.Event.Flag THEN WITH graph32.Event DO BEGIN
        IF (ORD(KeyChar1) = 255)
          THEN mouse_convert (Button, X, Y, alr, ahr, calr, cahr)
          ELSE BEGIN calr := KeyChar1;  alr := ORD(calr);  END;
        IF (UpCase(calr)='A') OR
           (UpCase(calr)='Z') OR
           (ORD(calr)   =27) THEN BEGIN
          tinter;
          IF UpCase(calr)='A' THEN averaging := NOT averaging;
          END;
        Flag := FALSE;
        END;
      IF idataput[no] AND (loggop OR genlop) THEN BEGIN
        disrec:=disrec+1;
        sdate^[disrec] := showdate(date); 
        stime^[disrec] := showtime(time);
        sdir^ [disrec] := wwdir[no];
        sd1^  [disrec] := gcgrab[no];
        sd2^  [disrec] := agc1m[no].Integral;
        sd3^  [disrec] := agc5m[no].Integral;
        sd4^  [disrec] := wspeed[no];
        sd5^  [disrec] := propc[no];
        sd6^  [disrec] := propresp[no];
        sd7^  [disrec] := gccntl[no];
        sd8^  [disrec] := gcambi[no];
        sd9^  [disrec] := temp1[no];
        sd10^ [disrec] := airpres[no];
        sd11^ [disrec] := solrad[no];
        sd12^ [disrec] := gcset[no];
        sd13^ [disrec] := temp2[no];
        sd14^ [disrec] := ph2o[no];
      END ELSE
      IF varrop AND idataput[no]
        THEN BEGIN
          disrec:=disrec+1;
          sdate^[disrec]:=showdate(date); 
          stime^[disrec]:=showtime(time);
          sd1^[disrec]:=agcont[no].Integral;
          sd2^[disrec]:=cinteg[no];
          sd3^[disrec]:=cprop[no];
          sd4^[disrec]:=cdiff[no];
          sd5^[disrec]:=cwind[no];
          sd6^[disrec]:=propc[no];
          sd7^[disrec]:=ainteg_adj[no];
          sd8^[disrec]:=aprop_adj[no];
          sd9^[disrec]:=adiff_adj[no];
          sd10^[disrec]:=awind[no];
          sd11^[disrec]:=gcgrab[no];
          sd12^[disrec]:=gcset[no];
          END;
      UNTIL idataput[no] OR (alr=27) OR NOT(IsWindow(hWndGraph));
    idataput[no]:=FALSE;
  UNTIL (alr=27) OR NOT(IsWindow(hWndGraph));
  CloseGraph; 

  DISPOSE(sdate); DISPOSE(stime); DISPOSE(sdir);
  DISPOSE(sd1);  DISPOSE(sd2);  DISPOSE(sd3);  DISPOSE(sd4);  DISPOSE(sd5);
  DISPOSE(sd6);  DISPOSE(sd7);  DISPOSE(sd8);  DISPOSE(sd9);  DISPOSE(sd10); 
  DISPOSE(sd11); DISPOSE(sd12); DISPOSE(sd13); DISPOSE(sd14); DISPOSE(sd15); 
  END;  {of procedure 'display'}
{------------------------------------------------------------}

PROCEDURE graphics (ring, group, period: INTEGER; 
                    hours: Single; record_start: INTEGER);
VAR i: INTEGER;

BEGIN
 alr := 0;
 no := ring;  {***TEMPORARY***}
 longseed := 1;
  rmess:='Ring '+rlabel[no]+':  '+descriptor[no];
      IF (group = 1) THEN row := group + 2  {***TEMPORARY***}
                         ELSE row := group + 3; {***TEMPORARY***}
      loggop := (group = 1);
      varrop := (group = 2);
      genlop := (group = 3);
      snapop := (group = 4);
      dograph    := (period = 1);
      dolast     := (period = 2);
      docurrent  := (period = 3);
      dosnapshot := snapop;
      dishour := hours;
      recstart := record_start;
      fileend:=FALSE; firstpas:=TRUE;
      IF dograph AND (recavail(no,row)>0) THEN BEGIN
        IF (recstart > recavail(no,row)) THEN recstart := 0;
        IF recstart = 0 THEN BEGIN
          recstart := recavail(no,row)-ROUND(60.0*dishour);
          IF recstart < 1 THEN recstart := 1;
          END;
        igrarec:=ROUND(dishour*60.0);
        recend:=recstart+igrarec-1; recnumber:=recstart;
        IF recend>recavail(no,row) THEN BEGIN
          recend:=recavail(no,row);
          igrarec:=recend-recstart+1;
          END;
        direc:=ROUND(INT(igrarec/180+0.999999));
        IF direc<1 THEN direc:=1;
        IF recavail(no,row)<181 THEN direc:=1;
        irec:=recstart;
        display;
        END;
      IF dolast AND (recavail(no,row)>0) THEN BEGIN
        IF dishour>3 THEN dishour:=ROUND(dishour/3)*3;
        igrarec:=ROUND(dishour*60);
        direc:=ROUND(INT(igrarec/180+0.999999));
        IF direc<1 THEN direc:=1;
        IF recavail(no,row)<181 THEN direc:=1;
        IF dishour<3.0 THEN dishour:=3.0;
        display;
        END;
      IF docurrent THEN BEGIN
        recnumber:=1; recstart:=1; recend:=1; disrec:=0;
        dishour := 3.0/(60.0*tsamp[no]);  direc := 1;
        display;
        END;
      IF dosnapshot THEN BEGIN
        dishour := 2.0*3.0/(60.0*tsamp[no]);  {x2 if every other sample}
        snapshot_show := snapshot_fill;
        recnumber := 1 + longseed * 180 * (snapshot_size - 1);
        display;
        END;
  END;  {of procedure 'graphics'}
{-------------------------------------------------------------}

Initialization

BEGIN
  cursor_save_1 := 1;
  cursor_save_2 := 2;

  debuglog_handle := DebugLogRegister ('COMDIS');
  END;

Finalization

BEGIN
  END;

{of unit COMDIS.PAS...}
END.
