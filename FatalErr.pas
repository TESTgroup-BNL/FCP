Unit FatalErr;
{$H+}

{Display message window stating why program can not continue
 and then terminate the program.

 v1.0  2002-09-21  Original
 v1.1  2002-12-17  Change FatalMsg to Msg
 v1.2  2002-12-17  Add call to Application.HandleException
 v1.3  2003-01-26  Add IFDEF LINUX ENDIF IFDEF MSWINDOWS ENDIF for USES
 v1.4  2003-05-27  Replace System.Halt by Application.Terminate
 v1.5  2003-05-27  Negate v1.4; doesn't terminate!
 v2.0  2006-09-23  Add Uses EventLog
                   Msg: change errno from Word to Longint
                   Msg: add hex representation of errno
                   Msg: add calls to AppEvLog 50005, 50004
 }

Interface

PROCEDURE Msg (title, body: String);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);

Implementation

USES
{$IFDEF LINUX}
  QForms,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms,
  Windows,
{$ENDIF}
  EventLog,
  SysUtils;

PROCEDURE Msg (title, body: String);
VAR errno: Longint;
    beepcount: INTEGER;
BEGIN
  {If Win32 API error flag set, prepend number and message to body}
  errno := Windows.GetLastError;
  EventLog.AppEvLog (50005);
  IF (errno <> 0) THEN BEGIN
    body := 'ErrNo:  ' + IntToStr(errno) + ' ['
                       + IntToHex(errno,1) + ' hex]' + nl2 + body;
    body := 'ErrMsg: ' + SysErrorMessage(errno) + nl2 + body;
    END;
  title := 'FatalErr: ' + title;
  body  := body + nl2 + 'Click [OK] to finish exiting program...';

  {Audible alarm}
  FOR beepcount := 1 TO 3  DO BEGIN
    SysUtils.Sleep (500);  
    SysUtils.Beep;  
    END;

  {Display modal information window}
  Application.MessageBox (
    PCHAR(body),
    PCHAR(title),
    MB_OK Or MB_ICONERROR);

  {Show the systems error message}
  Application.HandleMessage;

  {Exit program}
  {
  Application.Terminate;
  }
  EventLog.AppEvLog (50004);
  System.Halt;
  END;  {procedure Msg}

Initialization
BEGIN
  END;

Finalization
BEGIN
  END;

  {of unit FatalErr...}  
  END.
