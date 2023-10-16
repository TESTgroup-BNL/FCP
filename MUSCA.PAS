Unit musca;
{$R+  Range checking ON}

{*
 * Purpose:  BNL FACE Project
 *           Utility routines
 *           For mapping of a mouse click position to a key stroke
 *
 * Version:     1
 * Date:        November 2000
 * Programmer:  J. Nagy
 * Language:    Pascal
 * Hardware:    IBM PC AT clones
 * O/S:         DOS, Win32
 * Changes:
 *   (1) Code moved from COMU99.PAS to this separate unit.       [2000-11-07]
 *
 * Version:     2
 * Date:        April 2001
 * Programmer:  J. Nagy
 * Changes:
 *   (1) mouse_subtract: new procedure to remove last entry(ies) [2001-04-06]
 *   (2) mouse_table_print: new procedure                        [2001-04-06]
 *
 *}

Interface

PROCEDURE mouse_add (buttonmask, x1, x2, y1, y2: INTEGER; alr, ahr: Byte);
PROCEDURE mouse_clear (newlength: INTEGER);
PROCEDURE mouse_convert (button, x, y: INTEGER;
                         VAR alr, ahr: Byte; VAR calr, cahr: CHAR);
PROCEDURE mouse_subtract (deletions: INTEGER);
PROCEDURE mouse_table_print;

Implementation

{mouse support module declarations}
CONST mouse_max = 64;         {maximum number conversions in table}
VAR   mouse_number: INTEGER;  {number of conversions currently in table}
      mouse_table: ARRAY[1..mouse_max] OF
                     RECORD
                       mask, xcoord1, xcoord2, ycoord1, ycoord2: INTEGER;
                       al, ah: Byte;
                       END;

{------------------------------------------------------------------------}

PROCEDURE mouse_add (buttonmask, x1, x2, y1, y2: INTEGER; alr, ahr: Byte);
{Add a mouse click position to key stroke conversion item to the list.}
BEGIN
  INC (mouse_number);
  {No warning if maximum number is exceeded.}
  IF (mouse_number <= mouse_max) THEN
    WITH mouse_table[mouse_number] DO BEGIN
      mask    := buttonmask;
      xcoord1 := x1-1;     {x1, y1, x2, y2 define a box on the screen}
      xcoord2 := x2-1;     {in the old 1-based DOS sysytem.          }
      ycoord1 := y1-1;
      ycoord2 := y2-1;
      al      := alr;      {DOS extended key code to which box is mapped.}
      ah      := ahr;
      END;
  END;  {of local procedure 'mouse_add'}
{------------------------------------------------------------------------}

PROCEDURE mouse_clear (newlength: INTEGER);
{Usually called with newlength = 0 which will completely empty the table.  
 Can be used to truncate the table when some "parent" region does not change.
 }
BEGIN
  IF newlength <= mouse_number THEN mouse_number := newlength;
  END;  {of local procedure 'mouse_clear'}
{------------------------------------------------------------------------}

PROCEDURE mouse_convert (button, x, y: INTEGER;
                         VAR alr, ahr: Byte; VAR calr, cahr: CHAR);
{Map a mouse click position to a keystroke.
 By default, nothing happens to the output arguments.
 In the case of overlapping box and mask, the first
 conversion found takes precedence -- sometimes useful.
 Meaning of mask (in table):
   1: Must be a left click
   2: Must be a right click
   3: Can be either
 Meaning of button (input argument):
   1: Is a left click
   2: Is a right click
 }
VAR notfound: BOOLEAN;
    index:    INTEGER;
BEGIN
  notfound := TRUE;
  index := 1;
  WHILE notfound AND (index <= mouse_number) DO
    WITH mouse_table[index] DO BEGIN
      IF ((button And mask) <> 0)          AND
         (x >= xcoord1) AND (x <= xcoord2) AND
         (y >= ycoord1) AND (y <= ycoord2) THEN BEGIN
        alr := al;
        ahr := ah;
        calr := CHR(al);
        cahr := CHR(ah);
        notfound := FALSE;
        END;
      INC (index);
      END;
  END;  {of local procedure 'mouse_convert'}
{------------------------------------------------------------------------}

PROCEDURE mouse_subtract (deletions: INTEGER);
{Take the last 'deletions' entries out of the table.
 }
BEGIN
  mouse_number := mouse_number - deletions;
  IF mouse_number <= 0 THEN mouse_number := 0;
  END;  {of local procedure 'mouse_subtract'}
{------------------------------------------------------------------------}

PROCEDURE mouse_table_print;
{Write current contents of table to console window.
 }
VAR index:    INTEGER;
BEGIN
  WRITELN ('++++++ mouse table print: ', mouse_number:1, ' entries ++++++');
  FOR index := 1 TO mouse_number DO
    WITH mouse_table[index] DO
      WRITELN (index:2, ')', mask:2, '=mask', 
        xcoord1:5, '=xcoord1', xcoord2:5, '=xcoord2', 
        ycoord1:5, '=ycoord1', ycoord2:5, '=ycoord2', 
        al:3, '=al', ah:3, '=ah');
  END;  {of local procedure 'mouse_table_print'}
{------------------------------------------------------------------------}

{of unit MUSCA.PAS...}
END.
