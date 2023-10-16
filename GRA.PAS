Unit gra;
{$H-  Turbo-style strings are default}

{*
 * Name:     GRAyy.PAS
 *
 * Purpose:  BNL FACE Project
 *           Graphics
 *           Operations in a sub screen
 *
 * Version:     1
 * Date:        04-04-90
 * Programmer:  Z. Kolber
 * Language:    TurboPascal 5.0
 * Hardware:    Dell 310 20Mhz 80386 AT
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
 *   (3) TYPE REAL = Single added to declaration unit
 *   (4) REAL types in all units redeclared as REAL
 *       (see J.N. memo "FACE Binary Records Changed" 4/19/90)
 *
 * Version:     3
 * Date:        11-09-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Added procedures 'vtick' and 'htick'.
 *   (2) Added procedure 'oouttext'.
 *   (3) Shifted Kolber "screen" down one "row" (disply).
 *   (4) Add procedure 'bbox'; delete procedure 'llineto'.
 *   (5) Add functions 'transformx' and 'transformy'
 *       which convert from graphics window coordinates
 *       (0..1,0..1) into video pixel coordinates.
 *       Use these functions in this unit where appropriate.
 *
 * Version:     4
 * Date:        12-06-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Version 3 changes that worked for COM
 *       don't work for DAT!
 *   (2) Moved procedure 'screen' to COMDIS and DATDIS
 *       and customized for each corresponding program.
 *   (3) Put following up as global variables:
 *         grdriver, grmode, scalex, scaley,
 *         displx, disply, grmaxx, grmaxy.
 *   (4) Use of unit COMPyy no longer needed.
 *   (5) Replace "float" by "REAL" and "str" by "String".
 *
 * Version:     5
 * Date:        02-28-92
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Move procedure 'screen' back here from 'comdis' and 'datdis'.
 *
 * Version:     6
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as GRA94.                                       [12/10/93]
 *
 * Version:     7
 * Date:        March 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) vtick: changes                                            [03/11/94]
 *
 * Version:     8
 * Date:        July 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) gresult: new procedure                                    [94/07/07]
 *
 * Version:     9
 * Date:        Feb-Mar 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes GRA95.PAS                                         [95/02/21]
 *
 * Version:     10
 * Date:        Oct 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes GRA96.PAS                                         [95/10/14]
 *
 * Version:     11
 * Date:        Dec 1996
 * Changes:
 *   (1) Becomes GRA97.PAS                                         [96/12/22]
 *
 * Version:     12
 * Date:        December 1997
 * Changes:
 *   (1) Becomes GRA98.PAS                                         [97/12/23]
 *
 * Version:     13
 * Date:        1999-2000
 * Changes:
 *   (1) Becomes GRA99.PAS                                         [99/12/13]
 *   (2) IFDEF TURBO Uses Graph IFDEF DELPHI Uses graph32          [00/01/18]
 *   (3) IFDEF DELPHI invokes $H-                                  [00/01/19]
 *   (4) screen: change default from EGA(3,1) to IBM8514(6,1)      [00/02/15]
 *   (5) tex: rewrite without assuming EGA 80 x 25 characters      [00/02/15]
 *   (6) move grdriver/mode init from screen; to Initialization    [00/02/17]
 *   (7) screen: put set to parameters in argument list            [00/02/17]
 *   (8) change REAL to Single throughout                          [00/02/17]
 *   (9) rtex: rewrite without assuming EGA 80 x 25 characters     [00/02/18]
 *  (10) add global variables textw and texth (char pixel sizes)   [00/02/18]
 *  (11) add global variables pixcol and pixrow (pixels per 80x25) [00/02/18]
 *  (12) Initialization: TURBO=EGA/EGAHi DELPHI=Detect/0           [00/03/23]
 *  (13) Delete global variables pixcol, pixrow                    [00/04/13]
 *  (14) rtex: Delete unused local variables xx1 and yy1           [00/04/13]
 *  (15) rtex: erase text window necessary only under Turbo DOS    [00/04/17]
 *  (16) rtex: remove textw/h; use real computation instead        [00/04/17]
 *  (17) tex: use real computation of pixel; avoid int16 overflow  [00/04/18]
 *  (18) transforms,y: give global scope for use by comdis99       [00/04/27]
 *
 * Version:     14
 * Date:        2002
 * Changes:
 *   (1) Becomes GRA.PAS again                                     [02-03-21]
 *   (2) Remove $IFDEF TURBO code $ENDIF, $IFDEF DELPHI $ENDIF     [02-03-25]
 *
 * Version:     15
 * Date:        2003
 * Changes:
 *   (1) No record here or in notebook on changes since 2002-03-25 !!!
 *   (2) Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS [03-01-24]
 *   (3) Remove procedure gresult -- no longer used                [03-03-15]
 *   (4) Remove procedure pputpixel -- not used -- ever ?          [03-03-15]
 *}

Interface

USES
{$IFDEF LINUX}
  QGraphics,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Graphics,
{$ENDIF}
  graph32;

VAR grdriver, grmode: INTEGER;  {for InitGraph}
    scalex, scaley: Single;     {size of subscreen}
    displx, disply: Single;     {lower left corner}
    grmaxx, grmaxy: INTEGER;    {GetMaxX|Y}

FUNCTION transformx (x: Single): INTEGER;
FUNCTION transformy (y: Single): INTEGER;
PROCEDURE screen (dx, dy, sx, sy: Single);
PROCEDURE lline (x1,y1,x2,y2: Single; color: INTEGER);
PROCEDURE llineto (x,y: Single; color: INTEGER);
PROCEDURE mmoveto (x,y: Single);
PROCEDURE htick (x0, dx, vlo, vhi: Single;
                 dpoints, nticks, color: INTEGER);
PROCEDURE vtick (y0, y1, vlo, vhi, vgrid: Single; color: INTEGER);
PROCEDURE bbox (x1,y1,x2,y2: Single; color: INTEGER);
PROCEDURE oouttext (x,y: Single; color: INTEGER; s: String);
PROCEDURE gclear (xx1,yy1,xx2,yy2: Single; col: TColor);
PROCEDURE rtex (ix1, iy1: INTEGER; textstr: String; col: INTEGER);
PROCEDURE tex (ix1, iy1: INTEGER; textstr: String; col: INTEGER);

Implementation

{------------------------------------------------------------}

PROCEDURE screen (dx, dy, sx, sy: Single);
BEGIN
  scalex := sx;   scaley := sy;
  displx := dx;   disply := dy;
  END;
{------------------------------------------------------------}

FUNCTION transformx (x: Single): INTEGER;
BEGIN
  transformx := ROUND((x*scalex+displx)*grmaxx);
  END;
{------------------------------------------------------------}

FUNCTION transformy (y: Single): INTEGER;
BEGIN
  transformy := ROUND((1.0-y*scaley-disply)*grmaxy);
  END;
{------------------------------------------------------------}

PROCEDURE lline (x1,y1,x2,y2: Single; color: INTEGER);
BEGIN
  SetColor (color);
  Line (transformx(x1), transformy(y1),
        transformx(x2), transformy(y2));
  END;
{------------------------------------------------------------}

PROCEDURE llineto (x,y: Single; color: INTEGER);
BEGIN
  SetColor (color);
  LineTo (transformx(x), transformy(y));
  END;
{------------------------------------------------------------}

PROCEDURE mmoveto (x,y: Single);
{This is a moveto with coordinates in Kolber window-space
 as input.}
BEGIN
  MoveTo (transformx(x), transformy(y));
  END;  {of procedure 'mmoveto'}
{------------------------------------------------------------}

PROCEDURE oouttext (x,y: Single; color: INTEGER; s: String);
{This replaces the common mmoveto,
 SetColor, OutText sequence.
 J.N. 11/9/90}
BEGIN
  mmoveto (x,y);
  SetColor (color);
  OutText (s);
  END;  {of procedure 'oouttext'}
{------------------------------------------------------------}

PROCEDURE htick (x0, dx, vlo, vhi: Single;
                 dpoints, nticks, color: INTEGER);
{Draws tick marks and labels on both X-axes
 of Kolber graphics window.  This functionality wasn't
 used in original COM programming.  It is added
 now into GRA for use in other applications.
 x0 and dx are in window-space.
 vlo and vhi are in engineering-space.
 nticks is the number of ticks (none at x0).
 dx is the separation of ticks in window-space.
 (vhi-vlo)/nticks is the value of each tick interval.
 vlo would be the value at x0 (if there were a tick).
 vhi is the value of the nticks'th tick.
 The purpose of 'nudge' is to begin label
 horizontally on a tick mark.
 Negative 'dpoints' suppresses tick labels.
 J.N. 11/30/90 by modifying 'vtick'}
CONST tbegin = -0.006;  {Y values of tick end points}
      tend   = +0.012;  {on bottom side of graph}
      lbegin = -0.02;   {where label field begins}
      nudge  = -0.02;
VAR   i: INTEGER;
      x, v, dv: Single;
      s: String;
BEGIN
IF nticks > 0 THEN BEGIN  {ignore call if nticks bad}
  SetColor(color);
  dv := (vhi-vlo)/nticks;
  FOR i := 1 TO nticks DO BEGIN
    x := x0+i*dx;
    lline(x,tbegin,x,tend,color);          {bottom}
    lline(x,1.0-tbegin,x,1.0-tend,color);  {top}
    IF dpoints >= 0 THEN BEGIN
      mmoveto(lbegin,x+nudge);
      v := vlo+i*dv;
      IF dpoints = 0 THEN Str(ROUND(v):1,s)
                     ELSE Str(v:dpoints+2:dpoints,s);
      OutText(s);
      END;  {writing of label}
    END;  {tick loop}
  END;  {valid ntick}
END;  {of procedure 'htick'}
{------------------------------------------------------------}

PROCEDURE vtick (y0, y1, vlo, vhi, vgrid: Single; color: INTEGER);
{Draws tick marks and labels on both Y-axes
 of Kolber graphics window of COM <F4> button.
 y0 and y1 are in window-space, bottom and height.
 vlo and vhi are in engineering-space.
 vlo is the value at y0.
 vhi is the value at y0+y1.
 vgrid line drawn if [vlo..vhi].
 The purpose of 'nudge' is to center label
 vertically on a tick mark.
 J.N. 11/08/90  Original
      11/30/90  Add negative dpoints label suppression facility
      03/09/94  Now will label the y0 point
      03/11/94  Auto decimal point calculation
      03/12/94  Grid line option added
      03/13/94  Removed nticks from argument list
      }
CONST tbegin = -0.006;  {X values of tick end points}
      tend   = +0.012;  {on left side of graph}
      lbegin = -0.06;  {where label field begins}
      lwidth = 4;      {max width of label field in chars}
      nudge  = 0.01;
VAR   i, size, width, dpoints, nticks: INTEGER;
      y, dy, v, dv: Single;
      s: String;
BEGIN
  SetColor(color);
  size := 10;
  width := 1;
  WHILE size <= vhi DO BEGIN
    size := size*10;
    INC(width);
    END;
                      dpoints := 0;
  IF vhi < 100.0 THEN dpoints := 1;
  IF vhi <  10.0 THEN dpoints := 2;
  IF vhi <   1.0 THEN dpoints := 3;
  IF dpoints > 0 THEN BEGIN
    width := width+dpoints+1+ORD(vlo<0.0);
    WHILE width>lwidth DO BEGIN
      DEC(dpoints);
      DEC(width);
      END;
    END;
  IF width<(lwidth-1) THEN width := lwidth-1;
  IF y1 < 0.3 THEN dy := 0.05
              ELSE dy := 0.10;
  nticks := TRUNC((y1+0.000001)/dy);
  IF y1 > 0.0 THEN dv := (vhi-vlo)*dy/y1
              ELSE dv := 9999.9;
  FOR i := 0 TO nticks DO BEGIN
    y := y0+i*dy;
    lline(tbegin,y,tend,y,color);          {left}
    lline(1.0-tbegin,y,1.0-tend,y,color);  {right}
    IF dpoints >= 0 THEN BEGIN
      mmoveto(lbegin,y+nudge);
      v := vlo+i*dv;
      IF dpoints = 0 THEN Str(ROUND(v):width,s)
                     ELSE Str(v:width:dpoints,s);
      IF (i>0) OR (vlo<>0.0) THEN OutText(s);
      END;  {writing label}
    END;  {tick loop}
  IF (vgrid >= vlo) AND (vgrid <= vhi) AND (y0 > 0.0) THEN BEGIN
    y := y0 + dy*(vgrid-vlo)/dv;
    lline(0.0, y, 1.0, y, color);          {grid line}
    END;
  END;  {of procedure 'vtick'}
{------------------------------------------------------------}

PROCEDURE bbox (x1,y1,x2,y2: Single; color: INTEGER);
{Draw a box in Kolber window space.
 (x1,y1) and (x2,y2) are opposite corners.
 J.N.  11/14/90}
BEGIN
lline(x1,y1,x2,y1,color);
lline(x2,y1,x2,y2,color);
lline(x2,y2,x1,y2,color);
lline(x1,y2,x1,y1,color);
END;  {of procedure 'bbox'}
{------------------------------------------------------------}

PROCEDURE gclear (xx1,yy1,xx2,yy2: Single; col: TColor);
TYPE points=RECORD
              x1,y1,x2,y2,x3,y3,x4,y4:INTEGER;
              END;
VAR coor:points;
BEGIN
  WITH coor DO BEGIN
    SetColor(0);
    x1:=transformx(xx1);
    x2:=transformx(xx2);
    x3:=x2;
    x4:=x1;
    y1:=transformy(yy1);
    y2:=y1;
    y3:=transformy(yy2);
    y4:=y3;
    SetFillStyle (SolidFill, ORD(col));  {TEMPORARY ORD}
    FillPoly(4,coor);
    END;
  END;  {procedure 'gclear;}
{------------------------------------------------------------}

PROCEDURE tex (ix1, iy1: INTEGER; textstr: String; col: INTEGER);
VAR x1, y1: INTEGER;
    realcast: REAL;
BEGIN
  realcast := (ix1-1) / 80.0;
  x1 := TRUNC (realcast * grmaxx); 
  realcast := iy1 / 25.0;
  y1 := TRUNC (realcast * grmaxy);
  SetColor (col);
  OutTextXY (x1, y1, textstr);
  END;  {of procedure 'tex'}
{------------------------------------------------------------}

PROCEDURE rtex (ix1, iy1: INTEGER; textstr: String; col: INTEGER);
TYPE points = RECORD
       x1,y1, x2,y2, x3,y3, x4,y4: INTEGER;
       END;
VAR coor: points;
    realcast: REAL;
BEGIN
  {not needed if Win32 because writing using "opaque"...
  WITH coor DO BEGIN
    SetColor (0);
    realcast := (ix1-1) / 80.0;
    x1 := TRUNC (realcast * grmaxx);
    realcast := Length(textstr) / 80.0;
    x2 := x1 + TRUNC (realcast * grmaxx);
    x3 := x2;
    x4 := x1;
    y1 := TRUNC ((iy1+1) / 25.0 * grmaxy);
    y2 := y1;
    y3 := TRUNC (iy1 / 25.0 * grmaxy);
    y4 := y3;
    SetFillStyle (SolidFill, 0);
    FillPoly (4, coor);
    END;
  ...}
  tex (ix1, iy1, textstr, col);
  END;  {procedure 'rtex'}
{------------------------------------------------------------}

Begin  {initialization}
  grdriver := Detect;
  grmode   := 0;

{of unit GRA.PAS...}
END.
