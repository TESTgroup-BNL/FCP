{*APPTYPE CONSOLE}
{*DEFINE DEBUG}
Unit crt32;
{# freeware}
{# version 1.0.0127}
{# Date 18.01.1997}
{# Author Frank Zimmer}
{# description
 Copyright © 1997, Frank Zimmer, 100703.1602@compuserve.com
 Version: 1.0.0119
 Date:    18.01.1997

---------------------------------------------------------------------------
 v 1.0.200  J.N.  98/12/01  www.csd.net/~cgadd/knowbase/DELPHI0013.HTM
                            Restyling of some capitalization and indenting
                  98/12/04  Sound: ~Frequenz and ~Duration now arguments
                  98/12/06  replace many INTEGER by LongWord -compatibility
                            KeyEvent --> Event.KeyEvent in PROC ReadKey
 v 1.0.300  J.N.  00/01/11  ReadKey: extensive rewrite to emulate DOS KB
                  00/01/12  Sound: Made single argument (frequency) for
                            compatability with Turbo Sound procedure.
                            Now fixed 250 ms duration and still SYNCHRONOUS.
                  00/01/13  Blink: added to text color constant list
                            Window: add procedure
                            IFDEF DEBUG and proc print_error added
                  00/01/19  WindMin, WindMax: change from TCOORD to Word
                  00/01/21  Remove $APPTYPE CONSOLE compiler directive
                            Make procedure init globally visible
                            Remove call to init in Initialization
                            *** init must be called by main program ***
                  00/01/28  Add file scope vars fSuccess, fHaltIt: BOOLEAN
                            Add file scope method error_check
                            GotoXY: implement $I-$I+, fSuccess and error_check
                  00/04/20  KeyPressed: mouse button released returns TRUE
                            ReadKey: returns CHR(255) if mouse flag TRUE
                            add global record var 'crt32_mouse'
                  00/04/25  KeyPressed, ReadKey: implement mouse button mask
                            init: had to start using Get/SetConsoleMode !!!
                  00/05/17  Implementation: added VARs hBeep, iBeep
                            Sound/NoSound: now simply control the beep thread
                            thread_beep: this is the beep thread function
                            init: start a suspended beep thread
                            Finalization: exit and close the beep thread
                  00/06/08  Finalization: remove above, WASN'T closing!
                  00/11/02  ClrRect: new; not in Crt; = ClrScr but bounded
 v 1.0.400  J.N.  01/04/10  hConsoleHandle: new VAR (exported)
                            GetConsoleHwnd: new FUNCTION (not exported)
                            init: fill hConsoleHandle using GetConsoleHandle
 v 1.0.401  J.N.  02/07/02  Sound: use asynchrounous MessageBeep(-1) 3x
                            NoSound: no longer has to do anything
---------------------------------------------------------------------------


 an Implementation of Turbo Pascal CRT-Unit for Win32 Console Subsystem
 testet with Windows NT 4.0
 At Startup you get the Focus to the Console!!!!

 ( with * are not in the original Crt-Unit):
 Procedure and Function:
   ClrScr
  *ClrRect           // J.N.
   ClrEol
   WhereX
   WhereY
   GotoXY
   InsLine
   DelLine
   HighVideo
   LowVideo
   NormVideo
   TextBackground
   TextColor
   Window            // J.N.
   Delay             // use no processtime
   KeyPressed
   ReadKey           // use no processtime
   Sound             // with Windows NT your could use
                        the Variables SoundFrequenz, SoundDuration
   NoSound
   *TextAttribut     // Set TextBackground and TextColor at the same time,
                        usefull for Lastmode
   *FlushInputBuffer // Flush the Keyboard and all other Events
   *ConsoleEnd       // output of 'Press any key' and
                        wait for key input when not pipe
   *Pipe             // True when the output is redirected
                        to a pipe or a file

 Variables:
   WindMin           // the min. WindowRect
   WindMax           // the max. WindowRect
   *ViewMax          // the max. ConsoleBuffer start at (1,1);
   TextAttr          // Actual Attributes only by changing with this Routines
   LastMode          // Last Attributes only by changing with this Routines
   *SoundFrequenz    // with Windows NT your could use these Variables
   *SoundDuration    // how long bells the speaker  -1 until ??, default = -1
   *hConsoleInput    // the Input-handle;
   *hConsoleOutput   // the Output-handle;
   *hConsoleError    // the Error-handle;
  *hConsoleHandle    // console window handle


 This Source is freeware, have fun :-)

 History
   18.01.97   the first implementation
   23.01.97   Sound, delay, Codepage inserted and setfocus to the console
   24.01.97   Redirected status
}

Interface
Uses Windows, Messages;

{$IFDEF win32}
Const
  Black           = 0;
  Blue            = 1;
  Green           = 2;
  Cyan            = 3;
  Red             = 4;
  Magenta         = 5;
  Brown           = 6;
  LightGray       = 7;
  DarkGray        = 8;
  LightBlue       = 9;
  LightGreen      = 10;
  LightCyan       = 11;
  LightRed        = 12;
  LightMagenta    = 13;
  Yellow          = 14;
  White           = 15;
  Blink           = 128;

  FUNCTION WhereX: INTEGER;
  FUNCTION WhereY: INTEGER;
  PROCEDURE ClrEol;
  PROCEDURE ClrRect (x1, y1, x2, y2: INTEGER);
  PROCEDURE ClrScr;
  PROCEDURE InsLine;
  PROCEDURE DelLine;
  PROCEDURE GotoXY (Const x,y: INTEGER);
  PROCEDURE HighVideo;
  PROCEDURE LowVideo;
  PROCEDURE NormVideo;
  PROCEDURE TextBackground (Const Color:word);
  PROCEDURE TextColor (Const Color:word);
  PROCEDURE TextAttribut (Const Color,Background:word);
  PROCEDURE Delay (Const ms: INTEGER);
  FUNCTION KeyPressed: BOOLEAN;
  FUNCTION ReadKey: CHAR;
  PROCEDURE Sound (SoundFrequenz: INTEGER);
  PROCEDURE NoSound;
  PROCEDURE ConsoleEnd;
  PROCEDURE FlushInputBuffer;
  FUNCTION Pipe: BOOLEAN;
  PROCEDURE Window (X1, Y1, X2, Y2: Byte);

  PROCEDURE init;
  FUNCTION GetConsoleHwnd: HWND;

VAR
  hConsoleInput:  THandle;
  hConsoleOutput: THandle;
  hConsoleError:  THandle;
  hConsoleHandle: THandle;
  WindMin: Word;
  WindMax: Word;
  ViewMax: TCoord;
  TextAttr: Word;
  LastMode: Word;

  crt32_mouse: RECORD
    flag:    BOOLEAN;
    button,
    col,
    row:     INTEGER;
    END;

{$ENDIF win32}

{Used in and for debugging ReadKey}
VAR CRT32RepeatCount,
    CRT32VirtualKeyCode,
    CRT32VirtualScanCode,
    CRT32ControlKeyState,
    CRT32ExtendedSave: DWORD;

Implementation
{$IFDEF win32}
Uses sysutils;

VAR
  StartAttr: Word;
  OldCP:     INTEGER;
  CrtPipe:   BOOLEAN;
  German:    BOOLEAN;
  fSuccess:  BOOLEAN;
  fHaltIt:   BOOLEAN;
  hBeep:     THandle;  {handle to the beep thread}
  iBeep:     INTEGER;  {<0 leave thread function, =0 off, >0 frequency}

{This is a "second code" versus key number table used by ReadKey.
 Will probably fail for some combinations on non-US keyboards.
 This version for 83-key keyboard.  Extra pad probably won't work.  DOES!
 An entry of 0 means that program shouldn't be looking here in first
 place or that this extended key not supported by the table.
 An entry of -1, -2, etc. means that a physical key is used 2 or more
 times for extensions.  Resolved by the local function lookup_table.
 Positive entries returned as the second code.
 Reference is IBM Technical Reference 2.02 and READKEY.WK1 file.
 }
CONST extended_table_max = 83;
      extended_table: ARRAY [1..extended_table_max] OF Integer =
  (  0, 120,  -1, 122, 123, 124, 125, 126, 127, 128,
   129, 130, 131,   0,  15,  16,  17,  18,  19,  20,
    21,  22,  23,  24,  25,   0,   0,   0,   0,  30,
    31,  32,  33,  34,  35,  36,  37,  38,   0,   0,
     0,   0,   0,  44,  45,  46,  47,  48,  49,  50,
     0,   0,   0,   0,   0,   0,   0,   0,  -2,  -2,
    -2,  -2,  -2,  -2,  -2,  -2,  -2,  -2,   0,   0,
    -3,  72,  -3,   0,  -3,   0,  -3,   0,  -3,  80,
    -3,  82,  83);

{---------------------------------------------------------------------}
PROCEDURE print_error (proc: String);
VAR api_error_num: DWORD;
    api_error_msg: ARRAY [0..255] OF CHAR;
    i: INTEGER;
BEGIN
  api_error_num := GetLastError;
  FormatMessage (
    FORMAT_MESSAGE_FROM_SYSTEM,
    NIL,
    api_error_num,
    0,
    api_error_msg,
    255,
    NIL);
  WRITE ('ERR: ', proc, ' ', api_error_num:1, ' ');
  i := 0;
  WHILE (i<256) AND (ORD(api_error_msg[i])<>0) DO BEGIN
    WRITE (api_error_msg[i]);
    INC (i);
    END;
  END;  {of internal procedure 'print_error'}
{---------------------------------------------------------------------}

PROCEDURE error_check (proc: String);
BEGIN
  print_error (proc);
  IF fHaltIt THEN BEGIN
    WRITE ('Hit carriage return...');
    READLN;
    Halt;
    END;
  END;  {of internal procedure 'error_check'}
{---------------------------------------------------------------------}

FUNCTION GetConsoleHwnd: HWND;
{Based on MSDN Q124103 "HOWTO: Obtain a Console Window Handle"}
CONST size = 255;
VAR workingTitle, fabricatedTitle, originalTitle: String[size];
    hwndFound: HWND;
BEGIN
  {Fetch current window title.}
  GetConsoleTitle (@originalTitle[1], size);
  {Format a "unique" title.}
  Str (GetTickCount:1, fabricatedTitle);
  Str (GetCurrentProcessId:1, workingTitle);
  fabricatedTitle := fabricatedTitle + '/' + workingTitle;
  {Change current window title.}
  SetConsoleTitle (@fabricatedTitle[1]);
  {Ensure window title has been updated.}
  Sleep (100);
  {Look for fabricated title.}
  hwndFound := FindWindow (NIL, @fabricatedTitle[1]);
  {Restore original window title.}
  SetConsoleTitle (@originalTitle[1]);
  {Return result}
  GetConsoleHwnd := hwndFound;
  END;  {of procedure 'GetConsoleHwnd'}
{---------------------------------------------------------------------}

PROCEDURE ClrEol;
VAR tC: tCoord;
    len, nw: LongWord;
    cbi: TConsoleScreenBufferInfo;
BEGIN
  GetConsoleScreenBufferInfo(hConsoleOutput,cbi);
  len := cbi.dwsize.x-cbi.dwcursorposition.x;
  tc.x := cbi.dwcursorposition.x;
  tc.y := cbi.dwcursorposition.y;
  FillConsoleOutputAttribute (hConsoleOutput, TextAttr, len, tc, nw);
  FillConsoleOutputCharacter (hConsoleOutput, #32,      len, tc, nw);
  END;  {procedure ClrEol}

PROCEDURE ClrRect (x1, y1, x2, y2: INTEGER);
{Clear the console window in area bounded by (x1,y1) (x2,y2) inclusive.
 This was not an original Crt procedure.
 Replaces BIOS Int 10, Function 6 calls in RINGU/clwindow.
 }
VAR tC: tCoord;
    len, nw: LongWord;
    cbi: TConsoleScreenBufferInfo;
    y: INTEGER;
BEGIN
  GetConsoleScreenBufferInfo(hConsoleOutput,cbi);
  len  := x2-x1+1;
  tc.x := x1;
  FOR y := y1 TO y2 DO BEGIN
    tc.y := y;
    FillConsoleOutputAttribute (hConsoleOutput, TextAttr, len, tc, nw);
    FillConsoleOutputCharacter (hConsoleOutput, #32,      len, tc, nw);
    END;
  END;  {procedure ClrRect}

PROCEDURE ClrScr;
VAR tc: tcoord;
    nw: LongWord;
    cbi: TConsoleScreenBufferInfo;
BEGIN
  getConsoleScreenBufferInfo (hConsoleOutput, cbi);
  tc.x := 0;
  tc.y := 0;
  FillConsoleOutputAttribute (hConsoleOutput,
    TextAttr, cbi.dwsize.x*cbi.dwsize.y, tc, nw);
  FillConsoleOutputCharacter (hConsoleOutput,
    #32, cbi.dwsize.x*cbi.dwsize.y, tc, nw);
  setConsoleCursorPosition (hConsoleOutput, tc);
  END;

FUNCTION WhereX: INTEGER;
VAR cbi : TConsoleScreenBufferInfo;
BEGIN
  GetConsoleScreenBufferInfo(hConsoleOutput,cbi);
  result := TCoord(cbi.dwCursorPosition).x+1
  END;

FUNCTION WhereY: INTEGER;
VAR cbi : TConsoleScreenBufferInfo;
BEGIN
  GetConsoleScreenBufferInfo(hConsoleOutput,cbi);
  result := TCoord(cbi.dwCursorPosition).y+1
  END;

PROCEDURE GotoXY (Const x,y: INTEGER);
VAR coord: TCoord;
BEGIN
  coord.x := x-1;
  coord.y := y-1;
  {$I-}
  fSuccess := SetConsoleCursorPosition (hConsoleOutput, coord);
  {$I+}
  IF NOT fSuccess THEN error_check ('GotoXY');
  END;

PROCEDURE InsLine;
VAR
 cbi: TConsoleScreenBufferInfo;
 ssr: tsmallrect;
 coord: tcoord;
 ci: tcharinfo;
 nw: LongWord;
BEGIN
  GetConsoleScreenBufferInfo(hConsoleOutput,cbi);
  coord := cbi.dwCursorPosition;
  ssr.left := 0;
  ssr.top := coord.y;
  ssr.right := cbi.srwindow.right;
  ssr.bottom := cbi.srwindow.bottom;
  ci.asciichar := #32;
  ci.attributes := cbi.wattributes;
  coord.x := 0;
  coord.y := coord.y+1;
  ScrollConsoleScreenBuffer (hConsoleOutput, ssr, NIL, coord, ci);
  coord.y := coord.y-1;
  FillConsoleOutputAttribute (hConsoleOutput,
    TextAttr, cbi.dwsize.x*cbi.dwsize.y, coord, nw);
  END;

PROCEDURE DelLine;
VAR
 cbi: TConsoleScreenBufferInfo;
 ssr: tsmallrect;
 coord: tcoord;
 ci: tcharinfo;
 nw: Longword;
BEGIN
  getConsoleScreenBufferInfo(hConsoleOutput,cbi);
  coord := cbi.dwCursorPosition;
  ssr.left := 0;
  ssr.top := coord.y+1;
  ssr.right := cbi.srwindow.right;
  ssr.bottom := cbi.srwindow.bottom;
  ci.asciichar := #32;
  ci.attributes := cbi.wattributes;
  coord.x := 0;
  coord.y := coord.y;
  ScrollConsoleScreenBuffer (hConsoleOutput, ssr, NIL, coord, ci);
  FillConsoleOutputAttribute (hConsoleOutput,
    TextAttr, cbi.dwsize.x*cbi.dwsize.y, coord, nw);
  END;

PROCEDURE TextBackground (Const Color:word);
BEGIN
  LastMode := TextAttr;
  TextAttr := (color shl 4) OR (TextAttr AND $f);
  SetConsoleTextAttribute(hConsoleOutput,TextAttr);
  END;

PROCEDURE TextColor (Const Color:word);
BEGIN
  LastMode := TextAttr;
  TextAttr := (color AND $f) OR (TextAttr AND $f0);
  SetConsoleTextAttribute (hConsoleOutput, TextAttr);
  END;

PROCEDURE TextAttribut (Const Color,Background:word);
BEGIN
  LastMode := TextAttr;
  TextAttr := (color AND $f) OR (Background shl 4);
  SetConsoleTextAttribute(hConsoleOutput,TextAttr);
  END;

PROCEDURE HighVideo;
BEGIN
  LastMode := TextAttr;
  TextAttr := TextAttr OR $8;
  SetConsoleTextAttribute(hConsoleOutput,TextAttr);
  END;

PROCEDURE LowVideo;
BEGIN
  LastMode := TextAttr;
  TextAttr := TextAttr AND $f7;
  SetConsoleTextAttribute(hConsoleOutput,TextAttr);
  END;

PROCEDURE NormVideo;
BEGIN
  LastMode := TextAttr;
  TextAttr := startAttr;
  SetConsoleTextAttribute(hConsoleOutput,TextAttr);
  END;
{---------------------------------------------------------------------}

PROCEDURE FlushInputBuffer;
BEGIN
  FlushConsoleInputBuffer (hConsoleInput)
  END;
{---------------------------------------------------------------------}

FUNCTION KeyPressed: BOOLEAN;
VAR NumberOfEvents,
    NumRead:  LongWord;
    InputRec: TInputRecord;
    discard_this_key,
    discard_this_mouse: BOOLEAN;
BEGIN
  GetNumberOfConsoleInputEvents (hConsoleInput,
                                 NumberOfEvents);
  IF NumberOfEvents > 0 THEN BEGIN
    PeekConsoleInput (hConsoleInput, InputRec, 1, NumRead);
    {WRITELN ('EventType = ', InputRec.EventType:1);}
    {See if this is a desired key event}
    discard_this_key :=
      (InputRec.EventType <> KEY_EVENT) OR
      (NOT InputRec.Event.KeyEvent.bKeyDown) OR
      (InputRec.Event.KeyEvent.wVirtualKeyCode IN [16..18, 20, 144..145]);
    {See if this is a desired mouse event}
    discard_this_mouse :=
      (InputRec.EventType <> _MOUSE_EVENT) OR
      (InputRec.Event.MouseEvent.dwButtonState <> 0) OR
      (InputRec.Event.MouseEvent.dwEventFlags  <> 0);
    {Save button state now for use when released later}
    IF (InputRec.EventType = _MOUSE_EVENT) AND discard_this_mouse
      THEN WITH InputRec.Event.MouseEvent, crt32_mouse DO BEGIN
        button := dwControlKeyState;
        button := (((button Shl 8) Or dwEventFlags) Shl 8) Or dwButtonState;
        END;
    {Ignore and discard undesired "events"}
    IF discard_this_key AND discard_this_mouse THEN BEGIN
      ReadConsoleInput (hConsoleInput, InputRec, 1, NumRead);
      NumberOfEvents := 0;
      END;
    END;
  crt32_mouse.flag := (NOT discard_this_mouse);
  {IF NOT discard_this_mouse THEN
    WRITELN ('discard_this_mouse = ', discard_this_mouse);}
  result := NumberOfEvents > 0;
  END;  {of function 'KeyPressed'}
{---------------------------------------------------------------------}

FUNCTION ReadKey: CHAR;
VAR NumRead:  LongWord;
    InputRec: TInputRecord;
    ch:       CHAR;
{.....................................................}
FUNCTION lookup_table: DWORD;
{Simulates the DOS BIOS 0 + scancode read key functions.}
CONST bad = 255;
VAR   value: Integer;
BEGIN
  IF NOT (CRT32VirtualScanCode IN [1..extended_table_max])
    THEN value := bad
    ELSE BEGIN
      value := extended_table[CRT32VirtualScanCode];
      IF value = 0
        THEN value := bad
        ELSE CASE value OF
          -1: BEGIN
                IF (CRT32ControlKeyState AND
                   (LEFT_CTRL_PRESSED OR RIGHT_CTRL_PRESSED)) <> 0
                   THEN value := 3;
                IF (CRT32ControlKeyState AND
                   (LEFT_ALT_PRESSED OR RIGHT_ALT_PRESSED)) <> 0
                   THEN value := 121;
                END;
          -2: BEGIN
                IF (CRT32ControlKeyState AND
                   (LEFT_ALT_PRESSED OR RIGHT_ALT_PRESSED)) <> 0
                   THEN value := CRT32VirtualScanCode + 45
                ELSE IF (CRT32ControlKeyState AND
                   (LEFT_CTRL_PRESSED OR RIGHT_CTRL_PRESSED)) <> 0
                   THEN value := CRT32VirtualScanCode + 35
                ELSE IF (CRT32ControlKeyState AND SHIFT_PRESSED) <> 0
                   THEN value := CRT32VirtualScanCode + 25
                ELSE    value := CRT32VirtualScanCode;
                END;
          -3: BEGIN
                IF (CRT32ControlKeyState AND
                   (LEFT_CTRL_PRESSED OR RIGHT_CTRL_PRESSED)) = 0
                  THEN value := CRT32VirtualScanCode
                  ELSE CASE CRT32VirtualScanCode OF
                    71: value := 119;
                    73: value := 132;
                    75: value := 115;
                    77: value := 116;
                    79: value := 117;
                    81: value := 118;
                    END;  {case}
                END;
          END;  {case}
      END;
  Result := value;
  END;  {of local function 'lookup_table'}
{.....................................................}
BEGIN
  IF (CRT32ExtendedSave <> 0)
    {If previous call returned NUL, now just return the extended scan code}
    THEN BEGIN
      ch := CHR(CRT32ExtendedSave);
      CRT32ExtendedSave := 0;
      END
    {Otherwise process the system input event buffer.}
    ELSE IF NOT crt32_mouse.flag THEN BEGIN
      WHILE
        {Wait for keyboard, key down event that is not SIMPLY
         a Ctrl, Alt, Shift, Caps, Num, or Scroll Lock.}
        NOT ReadConsoleInput (hConsoleInput, InputRec, 1, NumRead) OR
        (InputRec.EventType <> KEY_EVENT) OR
        NOT InputRec.Event.KeyEvent.bKeyDown OR
        (InputRec.Event.KeyEvent.wVirtualKeyCode IN [16..18, 20, 144..145])
        DO;
      WITH InputRec.Event.KeyEvent DO BEGIN
        CRT32RepeatCount     := wRepeatCount;
        CRT32VirtualKeyCode  := wVirtualKeyCode;
        CRT32VirtualScanCode := wVirtualScanCode;
        CRT32ControlKeyState := dwControlKeyState;
        ch                   := AsciiChar;
        END;
      {WinNT buffer not returning ORD(ch)=0 for Alt-1..0, Alt-A..Z.
       "Fix" it here.}
      IF ((CRT32ControlKeyState AND
          (LEFT_ALT_PRESSED OR RIGHT_ALT_PRESSED)) <> 0) AND
         (ch IN ['0'..'9', 'A'..'Z', 'a'..'z', '-', '='])
         THEN ch := CHR(0);
      {Figure out what DOS would return as the second code of an
       extended key and save it for the next call to this function.}
      IF (ORD(ch) = 0) THEN CRT32ExtendedSave := lookup_table
                       {This is not an extended key.  Flag as such.}
                       ELSE CRT32ExtendedSave := 0;
      END;

  WITH crt32_mouse DO IF flag THEN BEGIN
    ReadConsoleInput (hConsoleInput, InputRec, 1, NumRead);
    col  := InputRec.Event.MouseEvent.dwMousePosition.X;
    row  := InputRec.Event.MouseEvent.dwMousePosition.Y;
    ch   := CHR(255);
    flag := FALSE;
    END;

  Result := ch;
  END;  {of function 'ReadKey'}

PROCEDURE Delay (Const ms: INTEGER);
BEGIN
  Sleep(ms);
  END;

FUNCTION thread_beep: INTEGER;
{Approximate on/off capability using 100 ms chunks and flag checking.
 Run in a separate thread since Windows.Beep is synchronous.
 }
BEGIN
  WHILE iBeep >= 0 DO
    IF iBeep > 0 THEN Windows.Beep (iBeep, 100);
  Result := 0;
  END;  {of procedure 'thread_beep'}

PROCEDURE Sound (SoundFrequenz: INTEGER);
BEGIN
  {synchronous Beep API in a separate thread...
  iBeep := SoundFrequenz;
  ResumeThread (hBeep);
  }
  {asynchronous MessageBeep N times using "computer speaker"}
  MessageBeep ($FFFFFFFF);
  MessageBeep ($FFFFFFFF);
  MessageBeep ($FFFFFFFF);
  END;  {of procedure 'Sound'}

PROCEDURE NoSound;
BEGIN
  {synchronous Beep API in a separate thread...
  iBeep := 0;
  SuspendThread (hBeep);
  }
  {asynchronous MessageBeep ...
  ...do not have to do anything}
  END;  {of procedure 'NoSound'}

PROCEDURE ConsoleEnd;
BEGIN
  if isconsole AND NOT crtpipe THEN
  BEGIN
    if wherex > 1 THEN writeln;
    textcolor(green);
    setfocus(GetCurrentProcess);
    if german THEN write('Bitte eine Taste drücken!')
              else write('Press any key!');
    normvideo;
    FlushInputBuffer;
    ReadKey;
    FlushInputBuffer;
    END;
  END;

FUNCTION Pipe: BOOLEAN;
BEGIN
  result := crtpipe;
  END;
{---------------------------------------------------------------------}

PROCEDURE Window (X1, Y1, X2, Y2: Byte);
{Upper left corner is 1,1}
CONST proc =         'Window';
      bAbsolute =    TRUE;
VAR   ConsoleWindow: TSmallRect;
BEGIN
{This code simply made the window seen smaller.
 Could move scroll bar to see rest of the 25 lines.
 No split screen behavior at all.
  WITH ConsoleWindow DO BEGIN
    Left   := X1-1;
    Top    := Y1-1;
    Right  := X2-1;
    Bottom := Y2-1;
    END;
  fSuccess := SetConsoleWindowInfo
                (hConsoleOutput, bAbsolute, ConsoleWindow);
  IF NOT fSuccess THEN print_error (proc);
...}
  END;  {of procedure 'window'}
{---------------------------------------------------------------------}

PROCEDURE init;
VAR cbi: TConsoleScreenBufferInfo;
    tc: tcoord;
    fdwMode: DWORD;
    ThreadId: DWORD;

BEGIN
  //SetActiveWindow(0);

  hConsoleInput  := GetStdHandle (STD_INPUT_HANDLE);
  hConsoleOutput := GetStdHandle (STD_OUTPUT_HANDLE);
  hConsoleError  := GetStdHandle (STD_ERROR_HANDLE);

  hConsoleHandle := GetConsoleHwnd;

  GetConsoleMode (hConsoleInput, fdwMode);
  SetConsoleMode (hConsoleInput, fdwMode Or ENABLE_MOUSE_INPUT);

  IF GetConsoleScreenBufferInfo (hConsoleOutput,cbi) THEN BEGIN
    TextAttr := cbi.wAttributes;
    StartAttr := cbi.wAttributes;
    lastmode  := cbi.wAttributes;
    tc.x := cbi.srwindow.left+1;
    tc.y := cbi.srwindow.top+1;
    WindMin := (tc.x Shl 8) Or tc.y;
    ViewMax := cbi.dwsize;
    tc.x := cbi.srwindow.right+1;
    tc.y := cbi.srwindow.bottom+1;
    WindMax := (tc.x Shl 8) Or tc.y;
    crtpipe := FALSE;
    END ELSE crtpipe := TRUE;


//  {Start the Turbo Beep simulation thread running.}
//  ibeep := 0;
//  hBeep := CreateThread (
//    NIL,               {default security}
//    0,                 {default stack size}
//    @thread_beep,      {pointer to thread function}
//    NIL,               {no thread function parameter}
//    CREATE_SUSPENDED,  {initially not running}
//    ThreadId);         {required to have one by 95/98}
//  IF hBeep = 0 THEN BEGIN
//    WRITELN ('ERROR CREATING THE BEEP THREAD');
//    WRITELN ('GetLastError = ', GetLastError:1);
//    WRITELN ('Stopping process');
//    WRITELN ('Hit <carriage-return> to close this window...');
//    Halt;
//    END;

  oldCp := GetConsoleoutputCP;
  SetConsoleOutputCP(1252);
  german := $07 = (LoWord(GetUserDefaultLangID) AND $3FF);
  CRT32ExtendedSave := 0;
  fHaltIt := TRUE;
  END;

Initialization
  {init;}  {must now may explicit call AFTER console window allocated}

Finalization
  SetConsoleOutputCP (oldcp);

  {Stop the Turbo Beep simulation thread running.  Probably don't need this.}
  iBeep := -1;
  {If leave this here, Pascal Halt() doesn't kill this thread!...
  ResumeThread (hBeep);
  ExitThread   (hBeep);
  CloseHandle  (hBeep);
  ...}

{$ENDIF win32}
{of unit 'crt32'...}
  END.
