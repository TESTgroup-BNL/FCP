UNIT Services;
{
Provides various support services to the FCP addlication

v01.00 2003-05-30 Original
v01.01 2003-05-30 FKey: application-wide F-key handling service
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms;
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Messages, Windows;
{$ENDIF}

{-------------------- FKey ---------------------}

TYPE TFkey = CLASS (TObject)
               PRIVATE
                 PROCEDURE FKey (VAR Msg: TMsg; VAR Handled: BOOLEAN);
               END;
{-----------------------------------------------}

IMPLEMENTATION

USES
  Alarms;

VAR objFKey: TFKey;

{-------------------- FKey ---------------------}

PROCEDURE TFkey.FKey (VAR Msg: TMsg; VAR Handled: BOOLEAN);
{Capture and process F-keys at the Application level}
BEGIN
  IF (Msg.wParam = VK_F2) AND (Msg.Message = WM_KEYDOWN) THEN BEGIN
    Alarms.FirstAlarmPage;
    Handled := TRUE;
    END

  ELSE Handled := FALSE;

  END;  {procedure 'FKey'}
{-----------------------------------------------}

INITIALIZATION

BEGIN
  objFKey := TFKey.Create;
  Application.OnMessage := objFKey.FKey;
  END;

FINALIZATION

BEGIN
  END;

{-------------------- end of unit Services ---------------------}
END.
