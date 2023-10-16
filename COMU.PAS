Unit comu;
{$R+  Range checking ON}
{$H-  Turbo-style strings default}

Interface

Uses SysUtils,
     crt32, graph32, 
     gra;

{*
 * Purpose:  BNL FACE Project
 *           On-line data acquisition, monitoring and control
 *           Utility routines
 *
 * Version:     1
 * Date:        January 1994
 * Programmer:  J. Nagy
 * Language:    TurboPascal 5, 6, 7
 * Hardware:    IBM PC AT clones
 * O/S:         DOS
 * Changes:
 *   (1) Constructed from parts of comp94.pas and tp5utils v2.7    [01/05/94]
 *   (2) dddmmss():  function added                                [01/07/94]
 *   (3) moved functions hhmmss() and dddmmss() to tp5utils.pas    [01/11/94]
 *
 * Version:     2
 * Date:        May 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Added function rep_hex();                                 [94/05/31]
 *
 * Version:     2
 * Date:        Feb 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMU95.PAS                                        [95/02/21]
 *
 * Version:     3
 * Date:        Oct-Dec 1995; Jan 1996
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMU96.PAS.                                       [95/10/14]
 *   (2) currentdate: replace y-1900 by y MOD 100; think positive! [95/10/15]
 *   (3) lpf(): brought here; was a local procedure in unit comp96 [96/01/01]
 *   (4) value_cycle(): new procedure for cycling thru options     [96/01/01]
 *   (5) heap_func(): variable, function, init package             [96/01/14]
 *   (6) pround(): added function                                  [96/01/16]
 *
 * Version:     4
 * Date:        June 1996
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Move f inport and p outport here from comp96              [96/06/12]
 *
 * Version:     5
 * Date:        Dec 1996 - Nov 1997
 * Changes:
 *   (1) Becomes COMU97.PAS.                                       [96/12/22]
 *   (2) Move procedure changering here from comp97.               [97/01/20]
 *   (3) New procedures cursor_row, cursor_col, cursor_page        [97/03/25]
 *   (4) New function leftjustify                                  [97/07/09]
 *
 * Version:     6
 * Date:        December 1997
 * Changes:
 *   (1) Becomes COMU98.PAS.                                       [97/12/23]
 *   (2) Add procedures 'inband' and 'outband'.                    [97/12/31]
 *
 * Version:     7
 * Date:        February 1998
 * Changes:
 *   (1) cycle: new procedure.                                     [98/02/10]
 *   (2) cycle (INTEGER) changed to cycle_byte (Byte);             [98/02/15]
 *
 * Version:     8
 * Date:        April 1998
 * Changes:
 *   (1) therm107: new function for 107 thermistor.                [98/04/29]
 *
 * Version:     9
 * Date:        1999
 * Changes:
 *   (1) funpack: new function for packing into float vars         [99/04/12]
 *   (2) wd_00540: new function maps 0-360 to 0-540                [99/11/15]
 *   (3) wd_90450: new function maps 0-360 to -90 to 450           [99/11/15]
 *
 * Version:     10
 * Date:        1999-2000
 * Changes:
 *   (1) Unit name changed to '99.                                 [99/12/13]
 *   (2) Uses $IFDEF TURBO | DELPHI                                [99/12/14]
 *   (3) rep_hex: remove unused VAR i:                             [99/12/14]
 *   (4) pround:  remove unused VAR temp:                          [99/12/14]
 *   (5) inport/outport: add $IFDEF DELPHI assembly code           [99/12/14]
 *   (6) disk: $IFDEF DELPHI replace Blink+11 by LightRed          [99/12/14]
 *   (7) windd: $IFDEF TURBO two graphics statements               [99/12/15]
 *   (8) ptex:  $IFDEF TURBO the whole body                        [99/12/15]
 *   (9) currenttime: $IFDEF TURBO DELPHI sections                 [99/12/15]
 *  (10) currenttime: delete unused VAR s1, s2, s3: String[2]      [99/12/15]
 *  (11) currentdate: $IFDEF TURBO DELPHI sections                 [99/12/15]
 *  (12) hex2word: VAR result changed to VAR value                 [99/12/15]
 *  (13) scrollup: $IFDEF TURBO only; null otherwise               [99/12/15]
 *  (14) dselected: delete unused VAR code                         [99/12/15]
 *  (15) init section: $IFDEF TURBO the heap stuff                 [99/12/15]
 *  (16) IFDEF DELPHI Uses dos32 instead of SysUtils               [00/01/13]
 *  (17) currenttime: restore to original form                     [00/01/13]
 *  (18) currentdate: restore to original form                     [00/01/13]
 *  (19) disk:  cancel change (6) above                            [00/01/13]
 *  (20) IFDEF DELPHI invokes $H-                                  [00/01/19]
 *  (21) ShortStringAsPChar(), Delphi 4 Dev Guide, p. 136          [00/03/07]
 *  (22) windd: remove $IFDEF TURBO and add scaling                [00/03/23]
 *  (23) ptex: remove $IFDEF TURBO and add scaling                 [00/03/23]
 *  (24) Add graph32 to Uses list                                  [00/03/23]
 *  (25) Add gra99 to Uses list to pick up grmaxx & grmaxy         [00/03/23]
 *  (26) Add module CONST/VARs mouse_max, _number, _table          [00/04/20]
 *  (27) Add procedure mouse_add, _clear, _convert                 [00/04/20]
 *  (28) mouse_clear: generalize for _table truncation             [00/04/21]
 *  (29) mouse_max: increase from 32 to 64                         [00/04/21]
 *  (30) cursor_row: added IF (keycode IN [lowest..highest]) THEN  [00/04/22]
 *  (31) mouse_add, _convert: Make use of a button mask            [00/04/25]
 *  (32) disk: greater than 7FFFFFFF feature; MB-->kB switch       [00/04/27]
 *  (33) mouse_add: put in some commentable debugging code         [00/05/09]
 *  (34) showdate/showtime: conform to ISO 8601 YYYY-MM-DD & :'s   [00-10-12]
 *  (35) break out all mouse_* stuff as separate unit 'musca'      [00-11-07]
 *
 * Version:     11
 * Date:        2001
 * Changes:
 *   (1) pround: replace all MAXINT with 32767                     [01/05/12]
 *
 * Version:     12
 * Date:        2002
 * Changes:
 *   (1) Unit renamed comu                                         [02-03-21]
 *   (2) Change Uses gra99 to Uses gra                             [02-03-21]
 *   (3) Remove $IFDEF TURBO code $ENDIF & $IFDEF DELPHI $ENDIF    [02-03-24]
 *   (4) disk: reformat message to make shorter                    [02-07-10]
 *   (5) windd: SetColor (col1) statement was missing!             [02-08-16]
 *   (6) disk: change from procedure to function returning string  [02-09-15]
 *   (7) disk: deleted                                             [02-09-15]
 *   (8) bytesfree: rewrote logic that gets drive letter           [02-09-15]
 *   (9) bytesfree: function now returns Int64                     [02-09-15]
 *  (10) bytesfree: calls SysUtils.DiskFree, not dos32.DiskFree    [02-09-15]
 *
 * Version:     13
 * Date:        2003
 * Changes:
 *   (1) Remove procedure lpf forward declaration from interface   [03-01-05]
 *   (2) Remove Uses dos32                                         [03-01-27]
 *   (3) bytesleft: drive: String -> path                          [03-01-27]
 *   (4) bytesleft: number: Byte -> Drive                          [03-01-27]
 *   (5) bytesleft: recognize .\ and ..\ as being "current" drive  [03-01-27]
 *   (6) currentdate: dos32 (Turbo emulator) call replaced by      [03-01-27]
 *       currenttime: direct calls to SysUtils DecodeDate/Time Now [03-01-27]
 *   (7) getchunk: comment out WRITELN to console                  [03-03-16]
 *       str2word: comment out WRITELN to console                  [03-03-16]
 *
 * Version:     14
 * Date:        2006
 * Changes:
 *   (1) Copy string function hhmmss (seconds) here from tp5utils  [06-03-17]
 *   (2) Copy integer function mjd(yyyy,mm,dd) here from tp5utils  [06-03-17]
 *   (3) Copy string function getfield() here from tp5utils        [06-03-17]
 *   (4) Copy string function istr() here from tp5utils            [06-03-17]
 *   (5) Copy string function weekday() from tp5utils              [06-03-17]
 *   (6) Copy real function atan2() from tp5utils                  [06-04-29]
 *}

TYPE float = Single;  {IEEE 4-byte real representation}

FUNCTION inport (addr: Word): Word;
PROCEDURE outport (addr, value: Word);
FUNCTION atan2 (s,c: REAL): REAL;
FUNCTION bytesleft (path: String): Int64;
FUNCTION funpack (package, trunc1, trunc2: float): float;
FUNCTION getchunk (VAR ifile: TEXT; separator: CHAR): String;
FUNCTION getfield (s: String; sep: CHAR; no: INTEGER): String;
FUNCTION hhmmss (t: float): String;
FUNCTION istr (val: Longint; w:   INTEGER): String;
FUNCTION leftjustify (substring: String; newlength: INTEGER): String;
FUNCTION mjd (year, month, day: INTEGER): Longint;
FUNCTION pround (value: float): INTEGER;
FUNCTION rep_binary (value, bits: Word): String;
FUNCTION rep_hex    (value, byts: Word): String;
FUNCTION ShortStringAsPChar (VAR s: ShortString): PChar;
FUNCTION showdate (date: String): String;
FUNCTION showtime (time: String): String;
FUNCTION hex2word (s: String; VAR code: INTEGER): Word;
FUNCTION str2word (s: String; VAR code: INTEGER): Word;
FUNCTION therm107 (vx, vs, r1, r2: float): float;
FUNCTION wdir (w: float): INTEGER;
FUNCTION wd_00540 (wd2, wd1prime: float): float;
FUNCTION wd_90450 (wd2, wd1prime: float): float;
FUNCTION weekday (year, month, day: INTEGER): String;
FUNCTION tselected (time, lo,hi:  String; enabled: BOOLEAN): BOOLEAN;
FUNCTION wselected (wspeed, lo,hi: float; enabled: BOOLEAN): BOOLEAN;
FUNCTION dselected (wdir, lo,hi: INTEGER; enabled: BOOLEAN): BOOLEAN;
PROCEDURE changering (VAR ring: INTEGER; numrings: INTEGER; key: CHAR);
PROCEDURE cursor_row (VAR row: INTEGER; lowest, highest, keycode: INTEGER);
PROCEDURE cursor_col (VAR col: INTEGER; lowest, highest, keycode: INTEGER);
PROCEDURE cursor_page (VAR pagno: INTEGER; lowest, highest, keycode: INTEGER);
PROCEDURE cycle_byte (VAR i: Byte; lowest, highest: Byte);
PROCEDURE clwindow (ru,cu,rd,cd: INTEGER);
PROCEDURE currentdate (VAR sdate: String; VAR year, month, day: INTEGER);
PROCEDURE currenttime (VAR t: float; VAR hour, minute, second:  INTEGER);
PROCEDURE inband  (ref, value, band: float; VAR counter: float);
PROCEDURE outband (ref, value, band: float; VAR counter: float);
PROCEDURE ptex (x,y: INTEGER; textstr: String; colour: INTEGER);
PROCEDURE scrollup (lines, fill, urow, drow, lcol, rcol: INTEGER);
PROCEDURE windd (x,y,hor,ver: INTEGER; m: float; col1,col2: INTEGER);
PROCEDURE value_cycle (VAR value: INTEGER; low, high: INTEGER; ch: CHAR);
PROCEDURE xywrite (x,y,color: INTEGER; s: String);

Implementation

FUNCTION inport (addr: Word): Word;
BEGIN 
  Asm
    mov dx, addr
    xor ax, ax
    In al, dx
    mov result, ax
    END;
  END;  {of function 'inport'}
{----------------------------------------------------------------------------}

PROCEDURE outport (addr, value: Word);
BEGIN
  Asm
    mov dx, addr
    mov ax, value
    Out dx, al
    END;
  END;  {of function 'outport'}
{----------------------------------------------------------------------------}

FUNCTION atan2 (s,c: REAL): REAL;
{Since standard Pascal only supplies a principal value
 (-pi/2 <= arctan <= +pi/2), this function was written
 to (1) provide angle in all 4 quadrants
    (2) in degrees 0 <= atan2 < 360.
 John Nagy  12/11/90}
CONST pi = 3.14159;
VAR x: REAL;
BEGIN
  IF c <> 0.0
    THEN x := ARCTAN (s/c)
    ELSE IF s >= 0.0 THEN x := +pi/2.0
                     ELSE x := -pi/2.0;
  IF c < 0.0 THEN x := pi+x;
  x := x*180.0/pi;
  WHILE x <    0.0 DO x := x+360.0;
  WHILE x >= 360.0 DO x := x-360.0;
  atan2 := x;
  END;  {of function 'atan2'}
{----------------------------------------------------------------------------}

FUNCTION pround (value: float): INTEGER;
{This function is a "protected ROUND".
 ROUND itself returns a Longint.  COM usually assigns this to an INTEGER.
 An out-of-range error is possible.  This function is to be used to
 fill non-critical integers, e.g. the snapshot storage arrays, so as to
 lessen the possibility of a run-time error.  Do not use this function
 for critical integers.  Let them cause a $R+ bomb because then
 something is wrong and should be fixed, not continue running.  This
 routine also protects the float input from being too large for the
 longint intermediate result.
 J.N. -- 95/01/16  Original
 Replace MAXINT by 32767 so that under 32-bit compilations
 when INTEGER is 32 bits, this function will protect loading
 of snap shot records that are now being changed to 16 bit SmallInt
 J.N. -- 01/05/12  MAXINT --> 32767
 }
BEGIN
       IF value >= +32767 THEN pround := +32767
  ELSE IF value <= -32767 THEN pround := -32767
  ELSE                          pround := ROUND(value);
  END;  {of function 'pround'}
{----------------------------------------------------------------------------}

FUNCTION funpack (package, trunc1, trunc2: float): float;
{This function unpacks positive whole-number floating point values that
 have been packed by multiplying one number by 10^N and then adding
 the second.  Even though real type, the packed number must have
 no fractional part; otherwise fractional part will spill over
 as most significant part of the number below it.  To extract
 a number from "package" you must specify "trunc1" which is the
 shift of the number above the desired one and "trunc2" which was
 its shift.
 J.N. -- 99/04/12  Original
 }
VAR temp1, temp2, temp3, temp4: float;
BEGIN
  temp1 := ABS(package);
  temp2 := Int (temp1 / trunc1);
  temp3 := temp1 - temp2 * trunc1;
  temp4 := Int (temp3 / trunc2);
  IF (package < 0.0) AND (temp1 < trunc1)
    THEN funpack := -temp4
    ELSE funpack := +temp4;
  END;  {of function 'funpack'}
{-------------------------------------------------------------}

FUNCTION rep_binary (value, bits: Word): String;
{Represent a number in binary as a series of 0's and 1's
 J.N. -- 12/17/93  Original (as procedure out_binary)
 J.N. -- 01/05/94  Rewritten as function rep_binary in unit comu94.pas
 }
VAR i: INTEGER;
    s: String;
BEGIN
  s := '';
  FOR i := bits-1 DOWNTO 0 DO
    IF ((value Shr i) And 1) = 0 THEN s := Concat(s,'0')
                                 ELSE s := Concat(s,'1');
  rep_binary := s;
  END;  {of function 'rep_binary'}
{-------------------------------------------------------------}

FUNCTION rep_hex (value, byts: Word): String;
{Represent a number in hexadecimal
 J.N. -- 94/05/31  Original
 }
CONST hd: ARRAY [0..$F] OF CHAR = ('0','1','2','3','4','5','6','7',
                                   '8','9','A','B','C','D','E','F');
VAR s: String;
BEGIN
  s := '';
  REPEAT
    s := Concat (hd[value And $F], s);
    value := value Shr 4;
    DEC(byts);
    UNTIL byts=0;
  rep_hex := s;
  END;  {of function 'rep_hex'}
{-------------------------------------------------------------}

FUNCTION istr (val: Longint; w:   INTEGER): String;
{Simply a functional form of Str() for integers
 J.N.  03/11/94 
 }
VAR s: String;
BEGIN
  Str (val:w, s);
  istr := s;
  END;  {function 'istr'}
{-------------------------------------------------------------}

FUNCTION wdir (w: float): INTEGER;
VAR ww: INTEGER;
{input:  fraction of a full circle, possibly <0 or >1
 output: whole number degrees as a integer (changed from string 11/29/92
 if input way out of line (may cause range error), return 720   03/14/94
 }
BEGIN
  IF ABS(w) < 90.0
    THEN BEGIN
      ww := ROUND(w*360.0);
      WHILE ww>=360 DO ww := ww-360;
      WHILE ww<0    DO ww := ww+360;
      wdir := ww;
      END
    ELSE wdir := 720;
  END;  {of function 'wdir'}
{-------------------------------------------------------------}

FUNCTION wd_00540 (wd2, wd1prime: float): float;
{input:  wd2 = direction in 0 to 360
         wd1prime = previous direction in 000 to 540
 intermediate: wd2 then used for temporary storage
 output: direction in 000 to 540 degrees
 algorithm of CSI CR23X 5/98 Manual 8.7
 }
BEGIN
  IF (wd2 <= 180.0) AND (wd1prime > 270.0)
    THEN wd2 := wd2 + 360.0;
  wd_00540 := wd2;
  END;  {of function 'wd_00540'}
{-------------------------------------------------------------}

FUNCTION wd_90450 (wd2, wd1prime: float): float;
{input:  wd2 = direction in 0 to 360
         wd1prime = previous direction in -90 to 450
 intermediate: wd2 then used for temporary storage
 output: direction in -90 to 450 degrees
 algorithm is modification of CSI CR23X 5/98 Manual 8.7 0 to 540 routine
 }
BEGIN
  IF (wd2 > 270.0) THEN wd2 := wd2 - 360.0;
  IF (wd2 > (-90.0)) AND (wd2 <= (+90.0)) AND (wd1prime > 180.0)
    THEN wd2 := wd2 + 360.0;
  wd_90450 := wd2;
  END;  {of function 'wd_90450'}
{------------------------------------------------------------}

FUNCTION bytesleft (path: String): Int64;
VAR letter: CHAR;
    i:      INTEGER;
    Drive:  Byte;
{Determine space still available on drive specified.
 Drive letter is ASSUMED to be first non-space character
 in argument, a path for example.}
BEGIN
  i := 1;
  REPEAT
    letter := UpCase (path[i]);
    INC (i);
    UNTIL (letter IN ['A'..'Z','.']) OR (i > Length(path));
  IF (letter = '.') THEN Drive := 0  {"current" i.e. .\ or ..\}
                    ELSE Drive := ORD(letter)-ORD('A')+1;
  bytesleft := SysUtils.DiskFree(Drive);
  END;  {of function 'bytesleft'}
{------------------------------------------------------------}

PROCEDURE changering (VAR ring: INTEGER; numrings: INTEGER; key: CHAR);
CONST upkey   = '+';
      downkey = '-';
      space   = ' ';
{Changes selected ring number based on pressing key in
 'upkey' set or 'downkey' set.  Changes will wrap.
 No action taken if key pressed not in a set.
 Variable 'numrings' no longer the global version.
 J.N. -- 90/11/01  Original
         95/06/15  Add space-bar as synonym for +
         96/01/19  'numrings' now an argument}
BEGIN
CASE key OF
  space,
  upkey:   ring := ring+1;
  downkey: ring := ring-1;
  END; {case}
IF ring > numrings THEN ring := 1;
IF ring < 1        THEN ring := numrings;
END;  {of procedure 'changering'}
{------------------------------------------------------------}

PROCEDURE cursor_row (VAR row: INTEGER; lowest, highest, keycode: INTEGER);
CONST uparrow   = 72;
      downarrow = 80;
BEGIN
CASE keycode OF
  uparrow:   DEC(row);
  downarrow: INC(row);
  END; {case}
IF row > highest THEN row := lowest;
IF row < lowest  THEN row := highest;
IF (keycode IN [lowest..highest]) THEN row := keycode;
END;  {of procedure 'cursor_row'}
{------------------------------------------------------------}

PROCEDURE cursor_col (VAR col: INTEGER; lowest, highest, keycode: INTEGER);
CONST leftarrow  = 75;
      rightarrow = 77;
BEGIN
CASE keycode OF
  leftarrow:  DEC(col);
  rightarrow: INC(col);
  END; {case}
IF col > highest THEN col := lowest;
IF col < lowest  THEN col := highest;
END;  {of procedure 'cursor_col'}
{------------------------------------------------------------}

PROCEDURE cursor_page (VAR pagno: INTEGER; lowest, highest, keycode: INTEGER);
CONST pagedown = 73;
      pageup   = 81;
BEGIN
CASE keycode OF
  pagedown: DEC(pagno);
  pageup:   INC(pagno);
  END; {case}
IF pagno > highest THEN pagno := highest;  {no wrapping around}
IF pagno < lowest  THEN pagno := lowest;
END;  {of procedure 'cursor_page'}
{------------------------------------------------------------}

PROCEDURE cycle_byte (VAR i: Byte; lowest, highest: Byte);
{Add 1 to unsigned short variable.  Recycle to lowest if greater than highest.}
BEGIN
  INC(i);
  IF i > highest THEN i := lowest;
  END;  {of procedure 'cycle_byte'}
{------------------------------------------------------------}

PROCEDURE inband  (ref, value, band: float; VAR counter: float);
{Maintains real number 'counter' of times that 'value' 
 is within 'band' of the 'ref'erence point.}
BEGIN
  IF (ABS (ref - value) <= band) THEN counter := counter + 1.0;
  END;  {of procedure 'inband'}
{------------------------------------------------------------}

PROCEDURE outband (ref, value, band: float; VAR counter: float);
{Maintains real number 'counter' of times that 'value' 
 is outside 'band' of the 'ref'erence point.}
BEGIN
  IF (ABS (ref - value) >  band) THEN counter := counter + 1.0;
  END;  {of procedure 'outband'}
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

PROCEDURE lpf (VAR a: float; x,nu: float);
{ Low Pass Filter
  Input "nu" is the inverse decay constant in units of
  calls to the procedure.  If T represents the time interval
  between calls then
    RC = T/nu; or nu = T/RC.
  All of the combinations below have a time constant of
  1 minute (60 seconds).  The first one most closely
  approximates an exponential transfer function.
    nu = 1/120  T = 0.5 seconds
    nu = 1/60   T = 1.0
    nu = 1/30   T = 2.0
  J.N. 2/7/91}
BEGIN
a := nu*x+(1.0-nu)*a;
  END;  {of local procedure 'lpf'}
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
  END;
{------------------------------------------------------------}

FUNCTION mjd (year, month, day: INTEGER): Longint;
{Return whole number part of modified Julian date at 0h
 as defined in Almanac for Computers, 1988, page B2.
 Valid for years 1901..2099.
 The value for   1/1/1901 is about 15385
 The value for 12/31/2099 is about 88068
 Examples from book are: 1978 January 1 = 43509 (B2)
                         1978 July 21   = 43710 (B2)
                         1988 October 1 = 47435 (D5)
 Note use of non-standard type Longint.
 John Nagy 11/27/90}
VAR y, m, d: Longint;
BEGIN
  y := year;  {do casts so arithmetic done using double words}
  m := month;
  d := day;
  mjd :=  367*y
         -((7*(y+((m+9) DIV 12))) DIV 4)
         +((275*m) DIV 9)
         +d
         -678987;
  END;  {of function 'mjd'}
{------------------------------------------------------------}

FUNCTION weekday (year, month, day: INTEGER): String;
{Day of week algorithm attributed to W.K.Rosen,
 Elementary Number Theory and Its Applications,
 valid for Gregorian calendar, 1582 October 15 on.
 Saturday has the value of 0.  Some check dates are:
   1991 Jan 28  Mon
   1991 Mar 14  Thurs
   1992 Feb 12  Fri
   1992 Dec 29  Tues
 John Nagy 1/28/91}
VAR n,dow: INTEGER;
BEGIN
  IF month < 3 THEN BEGIN  {for Jan & Feb}
    month := month+12;
    year  := year -1;
    END;
  n :=   day
       + 2*month
       + (3*(month+1)) DIV 5
       + year
       + year DIV 4
       - year DIV 100
       + year DIV 400
       + 2;
  dow := n MOD 7;
  CASE dow OF
    0: weekday := 'Saturday';
    1: weekday := 'Sunday';
    2: weekday := 'Monday';
    3: weekday := 'Tuesday';
    4: weekday := 'Wednesday';
    5: weekday := 'Thursday';
    6: weekday := 'Friday';
    END;  {of case}
  END;  {of function 'weekday'}
{------------------------------------------------------------}

PROCEDURE currentdate (VAR sdate: String; VAR year, month, day: INTEGER);
VAR y, m, d: Word;
    s1, s2, s3: String[2];
BEGIN
  SysUtils.DecodeDate (SysUtils.Now, y, m, d);
  Str(m:2,s1);  Str(d:2,s2);  Str(y MOD 100:2,s3);
  sdate := s1+'/'+s2+'/'+s3;
  IF sdate[1]=' ' THEN sdate[1] := '0';
  IF sdate[4]=' ' THEN sdate[4] := '0';
  IF sdate[7]=' ' THEN sdate[7] := '0';
  year  := y;
  month := m;
  day   := d;
  END;  {of procedure 'currentdate'}
{------------------------------------------------------------}

FUNCTION ShortStringAsPChar (VAR s: ShortString): PChar;
{This function null-terminates a short string so that it can
 be passed to functions that require PChar types.  If string
 is longer than 254 chars, then it will be truncated to 254.}
BEGIN
  IF Length(s) = High(s) THEN DEC(s[0]);  {Truncate s if it's too long}
  s[ORD(Length(s)) +1] := #0;             {Place null at end of string}
  Result := @s[1];                        {Return "PChar'd" string}
  END;  {of function 'ShortSringAsPChar'}
{------------------------------------------------------------}

FUNCTION hhmmss (t: float): String;
{Convert time t in seconds since midnight to string HH:MM:SS
 J.N.  92/12/10  Original
       94/08/31  Add var tt and check for tt=24:00:00}
VAR it: Longint;
    iss, imm, ihh: INTEGER;
    ss, mm, hh, tt: String;
BEGIN
  it := ROUND(t);
  iss := it MOD 60;
  imm := (it DIV 60) MOD 60;
  ihh := (it DIV 3600);
  Str(iss:2,ss);  Str(imm:2,mm); Str(ihh:2,hh);
  IF ss[1]=' ' THEN ss[1] := '0';
  IF mm[1]=' ' THEN mm[1] := '0';
  IF hh[1]=' ' THEN hh[1] := '0';
  tt := hh+':'+mm+':'+ss;
  IF tt <> '24:00:00' THEN hhmmss := tt          
                      ELSE hhmmss := '23:59:59';
  END;  {of function 'hhmmss'}
{------------------------------------------------------------}

FUNCTION showdate (date: String): String;
{Date in form MM/DD/YY conditionally converted DD.MM.YY
 J.N.  05.06.93  20,54  Original using site_id
 J.N.  05.01.94  14,40  Use usa boolean argument instead
 J.N.  00-10-12  10:55  Always return date as ISO 8601
 }
VAR mm, dd, yy: String;
    year, code: INTEGER;
BEGIN
  mm := Copy(date,1,2);
  dd := Copy(date,4,2);
  yy := Copy(date,7,2);
  Val (yy, year, code);
  IF (year > 50) THEN yy := '19' + yy
                 ELSE yy := '20' + yy;
  showdate := yy + '-' + mm + '-' + dd;
  END;  {of function 'showdate'}
{------------------------------------------------------------}

FUNCTION showtime (time: String): String;
{J.N.  05.06.93  20,54  Original using site_id
 J.N.  05.01.94  14,40  Use usa boolean argument instead
 J.N.  29.06.95         Change : to , for any place in string
 J.N.  00-10-12  10:55  Always return time as ISO 8601, i.e. do nothing
 }
BEGIN
  showtime := time;
  END;  {of function 'showtime'}
{------------------------------------------------------------}

PROCEDURE currenttime (VAR t: float; VAR hour, minute, second:  INTEGER);
VAR h, m, s, ms: Word;
BEGIN
  SysUtils.DecodeTime (SysUtils.Now, h, m, s, ms);
  t := h*3600.0 + m*60.0 + s + ms*0.001;
  hour   := h;
  minute := m;
  second := s;
  END;  {of procedure 'currenttime'}
{------------------------------------------------------------}

FUNCTION getchunk (VAR ifile: TEXT; separator: CHAR): String;
{Get a string token from text file input.
 Will not read past end-of-line or end-of-file.
 Null-string returned in this case.
 }
VAR  buffer: String;
     ch: CHAR;

FUNCTION more: BOOLEAN;
BEGIN
  more := NOT (EOF(ifile) OR EOLN(ifile));
  END;  {of local function 'more'}

BEGIN
  buffer := '';
  ch := CHR(0);  {suppress Delphi "hint"}
  IF more THEN REPEAT 
    READ (ifile, ch) 
    UNTIL (ch<>separator) OR NOT more;
  IF more THEN REPEAT
    IF ch<>separator THEN buffer := buffer+ch;
    READ (ifile, ch);
    UNTIL (ch=separator) OR NOT more;
  {WRITELN ('GETCHUNK>>>',buffer,'<<<');}
  getchunk := buffer;
  END;  {of function 'getchunk'}
{------------------------------------------------------------}

FUNCTION getfield (s: String; sep: CHAR; no: INTEGER): String;
{Purpose:  Get no'th field of a string record s in memory.
           The character sep is the field separator.
           If field doesn't exist, null string returned
           w/o any error message.
 John Nagy  01/09/92}
VAR t: String;
    col, count, l: INTEGER;
BEGIN
  l := Length(s);
  col := 1;
  count := 1;
  t := '';
  WHILE (count<no) AND (col<=l) DO BEGIN
    IF s[col]=sep THEN count := count+1;
    col := col+1;
    END;
  IF count=no THEN
    WHILE (col<=l) AND (s[col]<>sep) DO BEGIN
      t := Concat (t,s[col]);
      col := col+1;
      END;
  getfield := t;
  END;  {of function 'getfield'}
{------------------------------------------------------------}

FUNCTION leftjustify (substring: String; newlength: INTEGER): String;
{Left justify an input string 'substring' in an output string of 'newlength'}
VAR  buffer: String;

BEGIN
  buffer := substring;
  WHILE Length(buffer) < newlength DO buffer := buffer + ' ';
  leftjustify := buffer;
  END;  {of function 'leftjustify'}
{------------------------------------------------------------}

FUNCTION hex2word (s: String; VAR code: INTEGER): Word;
{Hexadecimal string to word conversion function.
 Stolen, with modifications, from optomux.pas 04/09/93.

   s         string (input)
   code      return code (output)
               = 0  conversion ok
               = 2  string greater than 4 characters
               = 3  invalid character in string
   hex2word  returned function value
}
CONST ofs0   = ORD('0');
      ofsucA = ORD('A')-10;
      ofslcA = ORD('a')-10;
VAR value: Word;
    i: INTEGER;
BEGIN
  value := 0;
  code := 0;
  IF Length(s) > 4
    THEN code := 2
    ELSE BEGIN
      i := 1;
      WHILE i <= Length(s) DO BEGIN
        CASE s[i] OF
          '0'..'9':  value := (value Shl 4) Or (ORD(s[i]) - ofs0  );
          'A'..'F':  value := (value Shl 4) Or (ORD(s[i]) - ofsucA);
          'a'..'f':  value := (value Shl 4) Or (ORD(s[i]) - ofslcA);
          Else code := 3;
          END;  {of case}
        INC(i);
        END;
      END;
  hex2word := value;
  END;  {of function 'hex2word'}
{-------------------------------------------------------------------}

FUNCTION str2word (s: String; VAR code: INTEGER): Word;
{Convert ascii representation of hexidecimal or decimal to word.
 Hexadecimal indicated by leading x, X, 0x, 0X, or trailing h, H.
 }
VAR hex: BOOLEAN;
    temp: Word;
BEGIN
  {WRITE ('STR2WORD>>>',s,'<<< ');}
  hex := FALSE;
  code := 0;
  WHILE (Length(s) > 0) AND (s[1] IN [' ','0','x','X']) DO BEGIN
    IF s[1] IN ['x','X'] THEN hex := TRUE;
    Delete (s,1,1);
    END;
  WHILE (Length(s) > 0) AND (s[Length(s)] IN [' ',CHR(13),CHR(10),'h','H']) 
    DO BEGIN
      IF s[Length(s)] IN ['h','H'] THEN hex := TRUE;
      Delete (s,Length(s),1);
      END;
  IF Length(s) > 0
    THEN IF hex THEN temp := hex2word (s, code)
                ELSE Val (s, temp, code)
    ELSE temp := 0;
  str2word := temp;
  END;  {of function 'str2word'}
{------------------------------------------------------------}

FUNCTION therm107 (vx, vs, r1, r2: float): float;
{Temperature of 107 thermistor from polynomial given in
 Campbell Scientific Inc.
 HMP35C Temperature/RH Probe
 Instruction Manual
 9/96  pp. 4&5
 vx: excitation voltage
 vs: sensed voltage
 r1: sensing resistance
 r2: fixed resistance
}
CONST c0 = -53.4601;
      c1 =  90.807;
      c2 = -83.257;
      c3 =  52.283;
      c4 = -16.723;
      c5 =   2.211;
VAR x: float;
BEGIN
  IF (vx > 0.0)
    THEN BEGIN
      x := vs/vx * 800.0;
      therm107 := c0+x*(c1+x*(c2+x*(c3+x*(c4+x*(c5)))));
      END
    ELSE therm107 := -999.9;
  END;  {of function 'therm107'}
{------------------------------------------------------------}

PROCEDURE scrollup (lines, fill, urow, drow, lcol, rcol: INTEGER);
{Haven't figured out how to do this 32-bit yet}
BEGIN
  END;  {of procedure 'scrollup'}
{------------------------------------------------------------}

PROCEDURE clwindow (ru,cu,rd,cd: INTEGER);
BEGIN
  scrollup (0,0,ru,rd,cu,cd);
  scrollup (0,0,5,7,61,79);
  END;  {of procedure 'clwindow'}
{------------------------------------------------------------}

PROCEDURE value_cycle (VAR value: INTEGER; low, high: INTEGER; ch: CHAR);
BEGIN
  IF ch IN [' ','+'] THEN INC (value);
  IF ch IN ['-']     THEN DEC (value);
  IF value > high THEN value := low;
  IF value < low  THEN value := high;
  END;  {of procedure 'value_cycle'}
{------------------------------------------------------------}

PROCEDURE xywrite (x,y,color: INTEGER; s: String);
{Write the text 's' in the color 'color'
 at the location 'x,y'.
 Current location (color) used if x (color) < 0.
 J.N. 4/24/91}
VAR colsav: Byte;
BEGIN
  colsav := TextAttr;
  IF     x >= 0 THEN GotoXY (x,y);
  IF color >= 0 THEN TextColor (color);
  WRITE (s);
  TextColor (colsav);
  END;  {of procedure 'xywrite'}
{------------------------------------------------------------}

FUNCTION tselected (time, lo,hi: String; enabled: BOOLEAN): BOOLEAN;
{Select records to be processed based on time of day.
 "low" and "high" should have been called "start" and "stop" originally.
 This new function allows selection times including midnight.
 Added lo, hi and enabled arguments 01/05/94.}
BEGIN
tselected := TRUE;
IF enabled THEN
  IF lo < hi
    THEN tselected := (time >= lo) AND
                      (time <= hi)
    ELSE tselected := (time >= lo) OR
                      (time <= hi);
END;  {of function 'tselected'}
{------------------------------------------------------------}

FUNCTION wselected (wspeed, lo,hi: float; enabled: BOOLEAN): BOOLEAN;
{Select records to be processed based on wind speed.
 Added lo, hi and enabled arguments 01/05/94.}
BEGIN
wselected := TRUE;
IF enabled THEN
  wselected := (wspeed >= lo) AND
               (wspeed <= hi);
END;  {of function 'wselected'}
{------------------------------------------------------------}

FUNCTION dselected (wdir, lo,hi: INTEGER; enabled: BOOLEAN): BOOLEAN;
{Select records to be processed based on wind direction.
 This new function allows selecting direction range enclosing North.
 Modified for integer wdir rather than string on 11/29/92.
 Added lo, hi and enabled arguments 01/05/94.}
BEGIN
dselected := TRUE;
IF enabled THEN BEGIN
  IF lo < hi
    THEN dselected := (wdir >= lo) AND
                      (wdir <= hi)
    ELSE dselected := (wdir >= lo) OR
                      (wdir <= hi);
  END;
END;  {of function 'dselected'}
{------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of unit COMU.PAS...}
END.
