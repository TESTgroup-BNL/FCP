Unit ExitSeq;
{$R+} {Range checking ON}
{
Prompt user if FCP program exit has been requested

v01.01 2003-05-30 Original. Based on Connect.pas. Old exit_sequence code.
v01.02 2003-05-31 Replace crt32.Delay by TTimer.
v01.03 2003-06-13 Add OnCloseForm that calls OnClickButton btnCancel
v01.04 2003-06-13 Replace OnCloseClient, OnDestroyClient by OnCloseForm
v01.05 2003-06-14 Hide the new btnRefresh inherited from TTemplate
v02.00 2006-09-22 Add IMPLEMENTATION USES EventLog
                  OnClickButton: calls to AppEvLog 50002, 50003, 50004 added
}

INTERFACE

USES                    {also see IMPLEMENTATION USES}
{$IFDEF LINUX}
  QForms, QExtCtrls, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, ExtCtrls, StdCtrls,
{$ENDIF}
  SysUtils,
  Template;

TYPE
  TExitSeq = CLASS(TTemplate)
    PRIVATE
      { Private declarations }
      lblInstruct: TLabel;
      cbStage: TCheckBox;
      FTimedOut: BOOLEAN;
      tmTimeout: TTimer;
      PROCEDURE OnTimerFire (Sender: TObject);
      PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
      PROCEDURE OnClickButton (Sender: TObject);
      PROCEDURE MakeChildren;
    PUBLIC
      { Public declarations }
    END;

FUNCTION ShutMsgGet (ring: INTEGER): String;
PROCEDURE Select;

IMPLEMENTATION

USES                    {also see INTERFACE USES}
  Globals, EventLog,
  comp, comd;

VAR frmExitSeq: TExitSeq;

VAR shut: ARRAY [1..maxrings] OF BOOLEAN;

VAR ring: INTEGER;

{-------------------------------------------------------------}

FUNCTION ShutMsgGet (ring: INTEGER): String;
BEGIN
  IF shut [ring] THEN ShutMsgGet := 'In shutdown ';
  END;  {function 'ShutMsgGet'}
{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmExitSeq) THEN BEGIN
    frmExitSeq := TExitSeq.Create (Application);
    frmExitSeq.MakeChildren;
    END;
  frmExitSeq.Show;
  frmExitSeq.SetFocus;
  frmExitSeq.WindowState := wsNormal;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TExitSeq.MakeChildren;
CONST nl = CHR(13) + CHR(10);
BEGIN
  {Form parameters}
  WITH Self DO BEGIN
    Caption := 'FCP program exit has been requested...';
    Width := (Screen.Width * 4) DIV 5;
    Height := (Screen.Height * 3) DIV 4;
    Left := 0;
    Top := Screen.Height - Height - 50;
    OnClose := OnCloseForm;
    END;

  {Staged shutdown interval timer}
  tmTimeout := TTimer.Create (Self);
  WITH tmTimeout DO BEGIN
    Enabled := FALSE;
    Interval := 1000;
    OnTimer := OnTimerFire;
    END;

  {Instructions label}
  lblInstruct := TLabel.Create (Self);
  WITH lblInstruct DO BEGIN
    Parent := Self;
    Left := 20;
    Top := 20;
    Caption := 'Check box for an orderly shutdown of  ' + nl +
               'devices in the field before stopping  ' + nl +
               'the control program.                  ' + nl + nl +
               'If the box is unchecked, the program  ' + nl +
               'will exit immediately.  Field devices ' + nl +
               'will remain in their current state    ' + nl +
               'unless deactivated by watchdogs in the' + nl +
               'field.';
    END;  {with}

  {Command buttons inherited from TTemplate}
  WITH btnCancel DO BEGIN
    Left := lblInstruct.Left + lblInstruct.Width + 20;
    Width := Self.Width - Left - 50;
    Top := lblInstruct.Top;
    Height := Self.Height - Top - 50;
    OnClick := OnClickButton;
    END;
  WITH btnOK DO BEGIN  {refashioned as the do shutdown button}
    Caption := '&Shutdown FCP Program';
    Default := FALSE;
    Width := lblInstruct.Width;
    Left := lblInstruct.Left;
    Top := Self.Height - Height - 50;
    OnClick := OnClickButton;
    END;
  WITH btnRefresh DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnApply DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnHelp DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  
  {Fast/slow shutdown check box}
  IF NOT Assigned (cbStage) THEN BEGIN
    cbStage := TCheckBox.Create (Self);
    WITH cbStage DO BEGIN
      Parent := Self;
      AllowGrayed := FALSE;
      Left := lblInstruct.Left;
      Height := 20;
      Top := (lblInstruct.Top + lblInstruct.Height + btnOK.Top) DIV 2;
      Width := lblInstruct.Width;
      Caption := 'Staged shutdown of field devices';
      Checked := TRUE;
      END;  {with}
    END;  {if}

  END;  {of procedure MakeChildren}
{-------------------------------------------------------------}

PROCEDURE TExitSeq.OnTimerFire (Sender: TObject);
BEGIN
  tmTimeout.Enabled := FALSE;
  FTimedOut := TRUE;
  END;  {of procedure OnTimerFire}
{-------------------------------------------------------------}

PROCEDURE TExitSeq.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  OnClickButton (TObject(btnCancel));
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TExitSeq.OnClickButton (Sender: TObject);
VAR ring, count: INTEGER;
BEGIN

{DebugLogFileClose and reldisc not done by this version}

  IF (Sender = btnOK) THEN BEGIN
    IF cbStage.Checked THEN BEGIN
      EventLog.AppEvLog (50002);
      btnCancel.Caption := '&Abort';
      FOR ring := 1 TO numrings DO BEGIN
        oper[ring] := FALSE;
        shut[ring] := TRUE;
        FOR count := 5 DOWNTO 1 DO BEGIN
          lblInstruct.Caption := 
            'Shutting off ring ' + rlabel[ring] + ': ' + IntToStr(count);
          tmTimeout.Enabled := TRUE;
          FTimedOut := FALSE;
          REPEAT tinter; Application.ProcessMessages; UNTIL FTimedOut;
          END;
        END;
      END;
    EventLog.AppEvLog (50004);
    System.Halt;
    END;

  IF (Sender = btnCancel) THEN BEGIN
    EventLog.AppEvLog (50003);
    tmTimeout.Enabled := FALSE;
    FOR ring := 1 TO numrings DO BEGIN
      oper[ring] := TRUE;
      shut[ring] := FALSE;
      END;
    Self.Release;
    frmExitSeq := NIL;
    END;
  
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  FOR ring := 1 TO maxrings DO shut[ring] := FALSE;
  END;

FINALIZATION

BEGIN
  END;

{of unit ExitSeq...} END.
