Unit CalibMan;
{
Manual calibration mode window

v01.01 2002-09-17 Original
v01.02 2002-11-11 Work continues
v01.03 2003-01-26 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.04 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.05 2003-03-18 Rename ButtonCancel as btnCancel, etc.
v01.06 2003-05-25 OnDestroyForm: added back; frmCalibMan := NIL
v01.07 2003-05-28 Linux/Types and MSWindows/Classes
v01.08 2003-05-28 comd/Globals changes
v01.09 2006-03-17 Remove Uses tp5utils.  Add Uses COMU.
                  Remove Implementation Uses Main; Don't know why there.
v02.01 2012-09-18 Provide button and code for CalLi840 unit.
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QControls, QForms, QGraphics, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Controls, Forms, Graphics, StdCtrls,
  Windows, Messages, Classes,
{$ENDIF}
  SysUtils,
  LblForm, Globals,
  comu, comd;

TYPE
  TCalibMan = class(TForm)
    btnCancel: TBitBtn;
    btnApply: TBitBtn;
    btnOK: TBitBtn;
    btnHelp: TBitBtn;
    btnLI840: TBitBtn;
    BandGroupBox: TGroupBox;
      TimeoutLabel: TLabel;
      TimeoutEdit: TEdit;
      ZeroGroupBox: TGroupBox;
        ZeroLowLabel: TLabel;
        ZeroLowEdit: TEdit;
        ZeroHighLabel: TLabel;
        ZeroHighEdit: TEdit;
      SpanGroup: TGroupBox;
        SpanLowLabel: TLabel;
        SpanLowEdit: TEdit;
        SpanHighLabel: TLabel;
        SpanHighEdit: TEdit;
    CheckBoxMP: TCheckBox;
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
  Private
    { Private declarations }
    CheckBoxRings: ARRAY [1..maxrings] OF TCheckBox;
    LabelStatusRings: ARRAY [1..maxrings] OF TLabel;
  Public
    { Public declarations }
  END;

VAR frmCalibMan: TCalibMan;
    frmHelp: TLblForm;

    {These are global variables but should only be accessed
     through the procedures/functions below}

    ambient_multiport_calibrate: BOOLEAN;

PROCEDURE AmbientMultiportCalibratingSet (state: BOOLEAN);
FUNCTION  AmbientMultiportCalibratingGet: BOOLEAN;
PROCEDURE Select;
PROCEDURE UpdateIt;
FUNCTION StatusMsgGet (ring: INTEGER): String;

Implementation

Uses CalLi840;

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmCalibMan)
    THEN frmCalibMan := TCalibMan.Create (Application);
  frmCalibMan.Show;
  frmCalibMan.SetFocus;
  frmCalibMan.WindowState := wsNormal;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
{Come here at end of every sample/control period}
VAR ring: INTEGER;
BEGIN
  IF Assigned (frmCalibMan) THEN
    IF (frmCalibMan.WindowState <> wsMinimized) THEN
      FOR ring := 1 TO numrings DO
        WITH frmCalibMan.LabelStatusRings[ring] DO
          IF calibrate_var[ring].active
            THEN Caption := FloatToStrF (gcgrab[ring], ffFixed, 7, 1)
            ELSE Caption := '';
  END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

FUNCTION StatusMsgGet (ring: INTEGER): String;
VAR msg: String;
BEGIN
  WITH calibrate_var[ring] DO IF enable THEN BEGIN
    msg := msg + 'CALIBRATION ';
    IF active THEN msg := msg + 'Active '
              ELSE msg := msg + 'Waiting ';
    msg := msg + Copy(hhmmss(timeon),1,5) + '-'
               + Copy(hhmmss(timeoff),1,5) + ' '
               + IntToStr(llimit.low) + ' ' + IntToStr (llimit.high) + ' &&'
               + IntToStr(ulimit.low) + ' ' + IntToStr (ulimit.high) + '  ';
    END;
  IF AmbientMultiportCalibratingGet THEN
    msg := msg + 'Ambient multiport calibrating';
  StatusMsgGet := msg
  END;  {of 'StatusMsgGet'}
{-------------------------------------------------------------}

PROCEDURE color_checkbox (checkbox: TCheckBox);
BEGIN
  WITH checkbox DO
    IF Checked
      THEN BEGIN
        Font.Color := clRed;
        TabOrder := 0;
        END
      ELSE Font.Color := clGreen;
  END;  {procedure color_checkbox}
{-------------------------------------------------------------}

PROCEDURE TCalibMan.OnClickButton (Sender: TObject);
CONST nl = CHR(13)+CHR(10);
      nl2 = nl+nl;
VAR header, body: String;
    ring: INTEGER;
BEGIN

  IF (Sender = btnApply) OR (Sender = btnOK) THEN BEGIN
    {Set calibration mode parameters from form}

    FOR ring := 1 TO numrings DO BEGIN
      calibrate_var[ring].enable := CheckBoxRings[ring].Checked;
      color_checkbox (CheckBoxRings[ring]);
      END;

    ambient_multiport_calibrate := CheckBoxMP.Checked;
    color_checkbox (CheckBoxMP);

    WITH calibrate_param DO BEGIN
      llimit.low  := StrToInt (ZeroLowEdit.Text);
      llimit.high := StrToInt (ZeroHighEdit.Text);
      ulimit.low  := StrToInt (SpanLowEdit.Text);
      ulimit.high := StrToInt (SpanHighEdit.Text);
      period      := StrToInt (TimeoutEdit.Text);
      IF period < 1  THEN period := 1;
      IF period > 60 THEN period := 60;
      TimeoutEdit.Text  := IntToStr (period);
      END;

    FOR ring := 1 TO numrings DO WITH calibrate_var[ring] DO BEGIN
      timeoff := -1.0;
      active := FALSE;
{
      IF (NOT autocalib_var[ring][0].active) AND
         (NOT autocalib_var[ring][1].active)
            THEN enable := (NOT enable);
}
      IF enable THEN BEGIN
        timeon := tint;
        timeoff := tint+calibrate_param.period*60.0;
        IF timeoff >= 86400.0 THEN timeoff := 86340.0;  {no wrapping}
        llimit.low  := calibrate_param.llimit.low;
        llimit.high := calibrate_param.llimit.high;
        ulimit.low  := calibrate_param.ulimit.low;
        ulimit.high := calibrate_param.ulimit.high;
        END;
      END;
    END;  {of apply button}

  IF (Sender = btnOK) OR (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmCalibMan := NIL;
    END;

  IF (Sender = btnHelp) THEN BEGIN
    header := 'SETUP FOR MANUAL IRGA CALIBRATION MODE';
    body :=
'When a treatment array is placed in calibration mode (as opposed to'+nl+
'normal mode), gas concentration measurements inside two selected limit'+nl+
'bands have no effect on control.  Thus when zero or span gas is put'+nl+
'into a sampling cell, the system doesn''t try to chase the spurious'+nl+
'signal.  (Real excursions, if any, would also be ignored!)'+nl2+
'A fumigation array is placed into calibration mode by checking its box'+nl+
'and clicking Apply or OK. The lower and upper band limits ([gas] units)'+nl+
'and timeout period (minutes) are loaded from the current values'+nl+
'displayed.  These in turn can be changed in Edit boxes.  The timeout'+nl+
'period can not exceed 60 minutes.  The program automatically returns to'+nl+
'normal mode should the operator forget to do so.  Take ring(s) out of'+nl+
'calibration mode by unchecking the box(es) and clicking Apply or OK.'+nl2+
'Ambient multiport manual calibration mode currently works as follows:'+nl+
'    Timeout doesn''t apply.  Will stay on until midnight if you forget!'+nl+
'    "Ambient signal" alarm suppressed.'+nl+
'    Calibrating active bit set if [control] or [ambient] out-of-range.'+nl2+
'For 3D Multiport systems it is best to simply turn '+nl+
'the program off during calibration.';
    frmHelp := TLblForm.Create (Application);
    frmHelp.Display (header, body);
    END;  {of help button}

  IF (Sender = btnLI840) THEN BEGIN  {*** ONLY WORKS WHEN 1 RING CHECKED ***}
    FOR ring := 1 TO numrings DO
      IF CheckBoxRings[ring].Checked
        THEN CalLi840.Select (rlabel[ring]);
    END;


  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TCalibMan.OnCreateForm (Sender: TObject);
VAR ring: INTEGER;
BEGIN
  {Dynamically create and fill the ring checkboxes}
  FOR ring := 1 TO numrings DO
    IF NOT Assigned (CheckBoxRings[ring]) THEN BEGIN
      CheckBoxRings[ring] := TCheckBox.Create (Self);
      WITH CheckBoxRings[ring] DO BEGIN
        Parent := Self;
        AllowGrayed := FALSE;
        Left := 360;
        Top := ring * 20;
        Width := 80;
        Height := 20;
        Visible := TRUE;
        Caption := 'Ring ' + rlabel[ring];
        Checked := calibrate_var[ring].enable;
        color_checkbox (CheckBoxRings[ring]);
        END;  {with}
      LabelStatusRings[ring] := TLabel.Create (Self);
      WITH LabelStatusRings[ring] DO BEGIN
        Parent := Self;
        Left := CheckBoxRings[ring].Left+CheckBoxRings[ring].Width;
        Top := CheckBoxRings[ring].Top + 5;
        Width := CheckBoxRings[ring].Width;
        Height := CheckBoxRings[ring].Height;
        Visible := TRUE;
        Caption := '-';
        END;  {with}
      END;  {if}

  {Position and fill the ambient multiport check box}
  WITH CheckBoxMP DO BEGIN
    AllowGrayed := FALSE;
    Left := 360;
    Top := (numrings + 2) * 20;
    Width := 100;
    Height := 20;
    Visible := TRUE;
    Caption := 'Ambient MP';
    Checked := ambient_multiport_calibrate;
    color_checkbox (CheckBoxMP);
    END;

  {Display the current manual calibration parameters on the form}
  WITH calibrate_param DO BEGIN
    ZeroLowEdit.Text  := IntToStr (llimit.low);
    ZeroHighEdit.Text := IntToStr (llimit.high);
    SpanLowEdit.Text  := IntToStr (ulimit.low);
    SpanHighEdit.Text := IntToStr (ulimit.high);
    TimeoutEdit.Text  := IntToStr (period);
    END;

  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TCalibMan.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmCalibMan := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TCalibMan.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmCalibMan := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE AmbientMultiportCalibratingSet (state: BOOLEAN);
BEGIN
  ambient_multiport_calibrate := state;
  END;  {of procedure AmbientMultiportCalibratingSet}
{-------------------------------------------------------------}

FUNCTION AmbientMultiportCalibratingGet: BOOLEAN;
BEGIN
  AmbientMultiportCalibratingGet := ambient_multiport_calibrate;
  END;  {of function AmbientMultiportCalibratingGet}
{-------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of form unit CalibMan...}
END.
