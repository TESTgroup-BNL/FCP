Unit LGSetup;
{$R+}
{
Line graph display parameters

v01.01 2003-01-07 Original starting from CalibMan v01.02
v01.02 2003-01-27 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.03 2003-01-31 Transfer global constants LG_*_* here from LGSelect
v01.04 2003-03-14 LG_ constants moved to LineGraf
v01.05 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.06 2003-03-20 .dfm: Create window in upper left corner
v01.07 2003-05-25 OnDestroyForm: added back; frmLGSetup := NIL;
v01.07 2003-05-28 comd/Globals changes
v01.08 2004-03-01 Replace btnSave by cbSave. Help text updated.
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QControls, QForms, QExtCtrls, QGraphics, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Controls, Forms, ExtCtrls, Graphics, StdCtrls,
  Windows,
{$ENDIF}
  SysUtils,
  LblForm,
  LineGraf,
  comd, Globals, faced;

TYPE
  TVarLine = CLASS(TWinControl)
      cbEnable: TCheckBox;
      ebLow,
      ebHigh,
      ebOffset,
      ebScale: TEdit;
      colColor: TColorBox;
    END;
  TLGSetup = CLASS(TForm)
      btnHelp:   TBitBtn;
      btnCancel: TBitBtn;
      btnApply:  TBitBtn;
      btnOK:     TBitBtn;
      cbSave:    TCheckBox;
      gbScreen:  TGroupBox;
      lblEnable: TLabel;
      lblLow:    TLabel;
      lblHigh:   TLabel;
      lblOffset: TLabel;
      lblScale:  TLabel;
      lblColor:  TLabel;
      PROCEDURE OnClickButton (Sender: TObject);
      PROCEDURE OnCreateForm (Sender: TObject);
      PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
      PROCEDURE OnDestroyForm (Sender: TObject);
    PRIVATE
      { Private declarations }
      FRing: INTEGER;
      FGroup: INTEGER;
      CheckBoxRings: ARRAY [1..maxrings] OF TCheckBox;
      VarLines: ARRAY [1..max_dsplobj] OF TVarLine;
      PROCEDURE Refresh;
    PUBLIC
      { Public declarations }
    END;

VAR frmLGSetup: TLGSetup;
    frmHelp: TLblForm;

PROCEDURE Select (ring: INTEGER; group: INTEGER);

IMPLEMENTATION

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE Select (ring: INTEGER; group: INTEGER);
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmLGSetup) 
    THEN frmLGSetup := TLGSetup.Create (Application);
  WITH frmLGSetup DO BEGIN
    IF (FRing = 0) THEN CheckBoxRings[ring].Checked := TRUE;
    FRing := ring;
    FGroup := group;
    Caption := 'Line graph setup window -- Graph type: ' +
               LG_GROUP_NAMES[group];
    Refresh;
    Show;
    SetFocus;
    WindowState := wsNormal;
    END;  {with}
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TLGSetup.Refresh;
{Load form from working variables}
VAR varobj: INTEGER;
BEGIN
  WITH disprecord^[FRing].dspl[FGroup] DO
    FOR varobj := 1 TO max_dsplobj DO 
      WITH obj[varobj], VarLines[varobj] DO BEGIN
        cbEnable.Checked := enable;
        cbEnable.Enabled := exists;
        ebLow.Visible := exists;
        ebHigh.Visible := exists;
        ebOffset.Visible := exists;
        ebScale.Visible := exists;
        colColor.Visible := exists;
        IF exists THEN BEGIN
          ebLow.Text := FloatToStr (low);
          ebHigh.Text := FloatToStr (high);
          ebOffset.Text := FloatToStrF (offset, ffFixed, 5, 2);
          ebScale.Text := FloatToStrF (scale, ffFixed, 5, 2);
          colColor.Selected := obj[varobj].color;
          END;
        END;
  END;  {of procedure 'Refresh'}
{-------------------------------------------------------------}

PROCEDURE TLGSetup.OnClickButton (Sender: TObject);
CONST nl = CHR(13)+CHR(10);
      nl2 = nl+nl;
VAR header, body: String;
VAR ring: INTEGER;
VAR varobj: INTEGER;
VAR ior: INTEGER;
BEGIN

  IF (Sender = btnApply) OR (Sender = btnOK) THEN BEGIN
    {Set line graph display parameters from form}

    FOR ring := 1 TO numrings DO
      IF CheckBoxRings[ring].Checked THEN BEGIN
        WITH disprecord^[ring].dspl[FGroup] DO
          FOR varobj := 1 TO max_dsplobj DO 
            WITH obj[varobj], VarLines[varobj] DO 
              IF exists
                THEN BEGIN
                  enable := cbEnable.Checked;
                  low := StrToFloat (ebLow.Text);
                  high := StrToFloat (ebHigh.Text);
                  offset := StrToFloat (ebOffset.Text);
                  scale := StrToFloat (ebScale.Text);
                  obj[varobj].color := colColor.Selected;
                  END;
        END;  {ring}

    IF cbSave.Checked THEN
      {Save changes for selected rings to disk}
      FOR ring := 1 TO numrings DO
        IF CheckBoxRings[ring].Checked THEN BEGIN
          {$I-}  RESET (disp[ring]);  {$I+} 
          ior := IOResult;
          IF ior = 0 THEN BEGIN
            {$I-}  WRITE (disp[ring],disprecord^[ring]);  {$I+}
            ior := IOResult;
            CloseFile (disp[ring]);
            END;
          IF ior <> 0 THEN BEGIN
            header := 'Line graph setup -- attempt to save to disk';
            body :=
              'Could not write display setting save file ' +
              filnam[ring,5] + nl2 +
              'New display settings are not saved on disk.' + nl2 +
              'I/O error: ' + IntToStr(ior);
            IF NOT Assigned (frmHelp) 
              THEN frmHelp := TLblForm.Create (Application);
            frmHelp.Display (header, body);
            END;
          END;
  
    END;  {of apply button}
  
  IF (Sender = btnOK) OR (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmLGSetup := NIL;
    END;
  
  IF (Sender = btnHelp) THEN BEGIN
    header := 'LINE GRAPH DISPLAY PARAMETER SETUP HELP';
    body :=
'CHECK a variable to show its line graph on the screen.' + nl2 +
'Gray variables can not be viewed with this graph type.' + nl +
'Try one of the other graph types.' + nl2 +
'LOW denotes the variable''s value at the bottom of its graph Y-axis.' + nl +
'HIGH denotes the variable''s value at the top of its graph Y-axis.' + nl2 +
'OFFSET denotes how far up the screen the variable starts.' +
' Enter 0.00 to 1.00.' + nl +
'SCALE denotes what fraction of the vertical screen space' + nl +
'will be occupied by the variable.  Enter 0.00 to 1.00.' + nl2 +
'CANCEL button will close setup window.' + nl2 +
'APPLY button will apply changes made to the selected rings.' + nl2 +
'OK button executes APPLY and CANCEL.' + nl2 +
'Applied changes are also saved to disk if "Save to disk" is' + 
' checked (default).' + nl2 +
'Note:  Make sure the plotting color (right most column)' + nl +
'       is not the background color!  You won''t see anything if it is.'
;
    frmHelp := TLblForm.Create (Application);
    frmHelp.Display (header, body);
    END;  {of help button}

  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TLGSetup.OnCreateForm (Sender: TObject);
CONST StartLeft = 15;
      StartTop =  0;
      HHeight =   10;
VAR ring: INTEGER;
    varobj: INTEGER;
    tab: INTEGER;
BEGIN
  {Dynamically create and fill the ring checkboxes}
  FRing := 0;
  FOR ring := 1 TO numrings DO 
    IF NOT Assigned (CheckBoxRings[ring]) THEN BEGIN
      CheckBoxRings[ring] := TCheckBox.Create (Self);
      WITH CheckBoxRings[ring] DO BEGIN
        Parent := Self;
        AllowGrayed := FALSE;
        Left := 425;
        Top := ring * 25;
        Width := 60;
        Height := 20;
        Visible := TRUE;
        Caption := 'Ring ' + rlabel[ring];
        END;  {with}
      END;  {if}

  {Create the information lines for each graph variable}
  tab := -1;
  FOR varobj := 1 TO max_dsplobj DO BEGIN
    VarLines[varobj] := TVarLine.Create (Self);
    WITH VarLines[varobj] DO BEGIN
      Parent := Self;
      cbEnable := TCheckBox.Create (Self);
      WITH cbEnable DO BEGIN
        Parent := Self;
        AllowGrayed := FALSE;
        Left := StartLeft;
        Top := StartTop + varobj * (Height + 5);
        Width  := 95;
        Caption := name_dsplobj[varobj];
        IF (varobj = 1) THEN BEGIN
          lblEnable.Top := StartTop + 5;
          lblEnable.Left := cbEnable.Left;
          END;
        END;
      ebLow := TEdit.Create (Self);
      WITH ebLow DO BEGIN
        Parent := Self;
        Left := cbEnable.Left + cbEnable.Width;
        Top := cbEnable.Top;
        Width := 36;
        INC (tab);
        TabOrder := tab;
        IF (varobj = 1) THEN BEGIN
          lblLow.Top := lblEnable.Top;
          lblLow.Left := ebLow.Left;
          END;
        END;
      ebHigh := TEdit.Create (Self);
      WITH ebHigh DO BEGIN
        Parent := Self;
        Left := ebLow.Left + ebLow.Width + StartLeft;
        Top := cbEnable.Top;
        Width := 36;
        INC (tab);
        TabOrder := tab;
        IF (varobj = 1) THEN BEGIN
          lblHigh.Top := lblEnable.Top;
          lblHigh.Left := ebHigh.Left;
          END;
        END;
      ebOffset := TEdit.Create (Self);
      WITH ebOffset DO BEGIN
        Parent := Self;
        Left := ebHigh.Left + ebHigh.Width + StartLeft;
        Top := cbEnable.Top;
        Width := 36;
        INC (tab);
        TabOrder := tab;
        IF (varobj = 1) THEN BEGIN
          lblOffset.Top := lblEnable.Top;
          lblOffset.Left := ebOffset.Left;
          END;
        END;
      ebScale := TEdit.Create (Self);
      WITH ebScale DO BEGIN
        Parent := Self;
        Left := ebOffset.Left + ebOffset.Width + StartLeft;
        Top := cbEnable.Top;
        Width := 36;
        INC (tab);
        TabOrder := tab;
        IF (varobj = 1) THEN BEGIN
          lblScale.Top := lblEnable.Top;
          lblScale.Left := ebScale.Left;
          END;
        END;
      colColor := TColorBox.Create (Self);
      WITH colColor DO BEGIN
        Parent := Self;
        Left := ebScale.Left + ebScale.Width + StartLeft;
        Top := cbEnable.Top;
        Width := 96;
        Style := [cbCustomColor, cbStandardColors, 
                  cbExtendedColors, cbPrettyNames];
        IF (varobj = 1) THEN BEGIN
          lblColor.Top := lblEnable.Top;
          lblColor.Left := colColor.Left;
          END;  {positioning column heading}
        END;  {color box}
      END;  {with varlines}
    END;  {for varobj}

  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TLGSetup.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmLGSetup := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TLGSetup.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmLGSetup := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  END;

FINALIZATION

BEGIN
  END;

{of form unit LGSetup...}
END.
