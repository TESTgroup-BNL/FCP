Unit Connect;
{$R+} {Range checking ON}
{
Form to set/reset rings that are logically disconnected

v01.01 2003-05-28 Original.  Material from many sources.
v01.02 2003-05-29 First unit to use Template.
v01.03 2003-05-30 Remove Uses Buttons.  Not needed.
v01.04 2003-06-13 OnCloseForm: added; calls OnClickButton (btnCancel)
v01.05 2003-06-13 MakeChildren: replace OnCloseClient by OnCloseForm
v01.06 2003-06-13 MakeChildren: remove OnDestroyClient
v01.07 2003-06-14 Hide the new btnRefresh inherited from TTemplate
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QGraphics, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics, StdCtrls,
{$ENDIF}
  SysUtils,
  Template, Globals;

TYPE
  TConnect = CLASS(TTemplate)
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnClickButton (Sender: TObject);
    PRIVATE
      { Private declarations }
      lblInstruct: TLabel;
      cbRings: ARRAY [1..maxrings] OF TCheckBox;
      PROCEDURE MakeChildren;
      PROCEDURE Refresh;
    PUBLIC
      { Public declarations }
    END;

PROCEDURE StateSet (ring: INTEGER; state: BOOLEAN);
FUNCTION StateGet (ring: INTEGER): BOOLEAN;
FUNCTION DisconnectMsgGet (ring: INTEGER): String;
PROCEDURE Select;

IMPLEMENTATION

VAR connected: ARRAY [1..maxrings] OF BOOLEAN;

VAR frmConnect: TConnect;

{-------------------------------------------------------------}

PROCEDURE StateSet (ring: INTEGER; state: BOOLEAN);
BEGIN
  connected[ring] := state;
  END;  {procedure 'StateSet'}
{-------------------------------------------------------------}

FUNCTION StateGet (ring: INTEGER): BOOLEAN;
BEGIN
  StateGet := connected[ring];
  END;  {function 'StateGet'}
{-------------------------------------------------------------}

FUNCTION DisconnectMsgGet (ring: INTEGER): String;
BEGIN
  IF (NOT connected[ring]) THEN DisconnectMsgGet := '!!! DISCONNECTED !!!  ';
  END;  {function 'DisconnectMsgGet'}
{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmConnect) THEN BEGIN
    frmConnect := TConnect.Create (Application);
    frmConnect.MakeChildren;
    END;
  frmConnect.Show;
  frmConnect.SetFocus;
  frmConnect.WindowState := wsNormal;
  frmConnect.Refresh;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TConnect.Refresh;
{Refresh the check boxes and label colors}
VAR ring: INTEGER;
BEGIN
  IF NOT Assigned (cbRings[1])
    THEN
      Application.MessageBox ('cbRings not assigned', 'Connect/Refresh', 0)
    ELSE
      FOR ring := 1 TO numrings DO WITH cbRings[ring] DO BEGIN
        Checked := connected[ring];
        IF Checked THEN Font.Color := clGreen
                   Else Font.Color := clRed;
        END;
  END;  {of procedure 'Refresh'}
{-------------------------------------------------------------}

PROCEDURE TConnect.MakeChildren;
CONST nl = CHR(13) + CHR(10);
      hex: ARRAY [0..$F] OF CHAR = ('0','1','2','3','4','5','6','7',
                                    '8','9','A','B','C','D','E','F');
VAR ring: INTEGER;
BEGIN
  {Form parameters}
  With Self DO BEGIN
    Caption := 'Logical connect/disconnect of rings';
    Width := (Screen.Width * 4) DIV 5;
    OnClose := OnCloseForm;
    END;

  {Instructions label}
  lblInstruct := TLabel.Create (Self);
  WITH lblInstruct DO BEGIN
    Parent := Self;
    Left := 20;
    Top := 20;
    Caption := 'Uncheck box and hit ' + nl +
               'Apply or OK to      ' + nl +
               'logically disconnect' + nl +
               'a ring.             ' + nl + nl +
               'Ring will not       ' + nl +
               'communicate with its' + nl +
               'devices even if     ' + nl +
               'those devices are in' + nl +
               'another physical    ' + nl +
               'ring.               ' + nl + nl +
               'Conversely, other   ' + nl +
               'rings may still try ' + nl +
               'to communicate with ' + nl +
               'devices in the      ' + nl +
               'disconnected ring!  ';
    END;  {with}

  {Command buttons}
  WITH btnCancel DO BEGIN
    Left := Self.Width - Width - 20;
    Top := lblInstruct.Top;
    OnClick := OnClickButton;
    END;
  WITH btnRefresh DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnApply DO BEGIN
    Left := btnCancel.Left;
    Top := btnCancel.Top + Height + (Height DIV 2);
    OnClick := OnClickButton;
    END;
  WITH btnOK DO BEGIN
    Left := btnCancel.Left;
    Top := btnApply.Top + Height + (Height DIV 2);
    OnClick := OnClickButton;
    END;
  WITH btnHelp DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  
  {Dynamically create and fill the ring checkboxes}
  FOR ring := 1 TO numrings DO 
    IF NOT Assigned (cbRings[ring]) THEN BEGIN
      cbRings[ring] := TCheckBox.Create (Self);
      WITH cbRings[ring] DO BEGIN
        Parent := Self;
        AllowGrayed := FALSE;
        Left := lblInstruct.Left + lblInstruct.Width + 20;
        Height := 20;
        Top := lblInstruct.Top + (ring-1) * ((Height * 4) DIV 3);
        Width := btnCancel.Left - Left - 20;
        Caption := hex[ring] + ': ' + 
                   'Ring ' + rlabel[ring] + ' ' + descriptor[ring];
        END;  {with}
      END;  {if}
  
  IF (lblInstruct.Top + lblInstruct.Height) >
     (cbRings[numrings].Top + cbRings[numrings].Height)
     THEN Self.Height := lblInstruct.Top + lblInstruct.Height + 50
     ELSE Self.Height := cbRings[numrings].Top + cbRings[1].Height + 50;
  END;  {of procedure MakeChildren}
{-------------------------------------------------------------}

PROCEDURE TConnect.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  OnClickButton (TObject(btnCancel));
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TConnect.OnClickButton (Sender: TObject);
VAR ring: INTEGER;
BEGIN

  IF (Sender = btnApply) OR (Sender = btnOK) THEN BEGIN
    {Latch check box values into working variables}
    FOR ring := 1 TO numrings DO
      connected[ring] := cbRings[ring].Checked;
    Refresh;
    END;

  IF (Sender = btnOK) OR (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmConnect := NIL;
    END;
  
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  END;

FINALIZATION

BEGIN
  END;

{of unit Connect...} END.
