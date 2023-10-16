Unit RVSetup;
{$R+}
{Select which rings to place on Ring View window and where.
 Also select background color.

v1.00 2002-      Original J.N.
v1.01 2003-01-26 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v1.02 2003-01-29 Renamed RVSetup.  Replace all "Topolgy" by "RVSetup"
v1.03 2003-03-18 Change ButtonApply: TButton to btnApply: TBitBtn
                 Change ButtonCancel: TButton to btnCancel: TBitBtn
                 Change ButtonOK: TButton to btnOK: TBitBtn
v1.04 2003-03-19 Add OnCloseForm event handler
v1.05 2003-05-25 OnDestroyForm: added  frmRVSetup := NIL;
v1.06 2003-05-28 comd/Globlas changes
v1.07 2003-05-28 topo array moved here from comd
v1.08 2003-05-29 Use TTemplate; eliminate RVSetup.dfm
v1.09 2003-06-13 Replace OnCloseClient, OnDestroyClient by OnCloseForm
v1.10 2003-06-14 Hide the new btnRefresh inherited from TTemplate
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QExtCtrls, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, ExtCtrls, StdCtrls,
  Windows, Messages,
{$ENDIF}
  SysUtils,
  Template, Globals,
  riv;

TYPE
  TRVSetup = CLASS(TTemplate)
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnClickCommand (Sender: TObject);
  Private
    { Private declarations }
    {Top Left} {Top Right} {Botton Left} {Bottom Right}
    RadioGroup: ARRAY [1..4] OF TRadioGroup;
    ColorBox: TColorBox;
    PROCEDURE MakeChildren;
  Public
    { Public declarations }
  END;

VAR
  topo: ARRAY [1..maxrings] OF INTEGER;  {used by RIV to position rings}

PROCEDURE Select;

IMPLEMENTATION

VAR frmRVSetup: TRVSetup;

{-------------------------------------------------------------}

PROCEDURE Select;
BEGIN
  IF (frmRVSetup = NIL) THEN BEGIN
    frmRVSetup := TRVSetup.Create (Application);
    frmRVSetup.MakeChildren;
    END;
  frmRVSetup.Show;
  END;  {of module procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TRVSetup.MakeChildren;
{Dynamically allocate and fill form controls}
VAR ring, 
    quad,
    found: INTEGER;
BEGIN

  WITH Self DO BEGIN
    Font.Height := -14;
    Left   :=  50;
    Top    := 120;
    Width  := 700;
    Height := 375;
    Caption := 'RingView setup - Select rings to view and background color';
    OnClose := OnCloseForm;
    END;

  FOR quad := 1 TO 4 DO BEGIN
    RadioGroup[quad] := TRadioGroup.Create (Self);
    WITH RadioGroup[quad] DO BEGIN
      Parent := Self;
      Left := 10 + (quad-1) * 115;
      Width := 105;
      Top := 15;
      Height := 20 * (numrings + 2);
      TabOrder := quad - 1;
      CASE quad OF
        1: Caption := 'Top Left';
        2: Caption := 'Top Right';
        3: Caption := 'Bottom Left';
        4: Caption := 'Bottom Right';
        END;  {case}
      Items.Clear;
      Items.Append ('None');
      FOR ring := 1 TO numrings DO BEGIN
        Items.Append ('Ring ' + rlabel[ring]);
        END;
      END;  {with quad}
    END;  {for quad}

  FOR quad := 1 TO 4 DO BEGIN
    found := 0;
    FOR ring := 1 TO numrings DO
      IF topo[ring] = quad THEN found := ring;
    CASE quad OF
      1: RadioGroup[1].ItemIndex := found;
      2: RadioGroup[2].ItemIndex := found;
      3: RadioGroup[4].ItemIndex := found;  {stet!}
      4: RadioGroup[3].ItemIndex := found;  {stet!}
      END; {case}
    END;

  ColorBox := TColorBox.Create (Self);
  WITH ColorBox DO BEGIN
    Parent := Self;
    Left := 480;
    Top := 20;
    Width := 90;
    Height := 35;
    Selected := riv.BackgroundcolorGet;
    END;

  WITH btnCancel DO BEGIN
    Left := 580;
    Top := 20;
    OnClick := OnClickCommand;
    END;

  WITH btnRefresh DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;

  WITH btnApply DO BEGIN
    Left := btnCancel.Left;
    Top := btnCancel.Top + 50;
    OnClick := OnClickCommand;
    END;

  WITH btnOK DO BEGIN
    Left := btnCancel.Left;
    Top := btnApply.Top + 50;
    OnClick := OnClickCommand;
    END;

  WITH btnHelp DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;

  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TRVSetup.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  OnClickCommand (TObject(btnCancel));
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TRVSetup.OnClickCommand (Sender: TObject);
VAR ring: INTEGER;
BEGIN

  IF (Sender = btnApply) OR (Sender = btnOK) THEN BEGIN
    FOR ring := 1 TO numrings DO topo[ring] := 0;
    IF (RadioGroup[1].ItemIndex IN [1..numrings])
      THEN topo[RadioGroup[1].ItemIndex] := 1;
    IF (RadioGroup[2].ItemIndex IN [1..numrings]) 
      THEN topo[RadioGroup[2].ItemIndex] := 2;
    IF (RadioGroup[3].ItemIndex IN [1..numrings]) 
      THEN topo[RadioGroup[3].ItemIndex] := 4;  {stet!}
    IF (RadioGroup[4].ItemIndex IN [1..numrings]) 
      THEN topo[RadioGroup[4].ItemIndex] := 3;  {stet!}
    riv.BackgroundColorSet (ColorBox.Selected);
    END;

  IF (Sender = btnCancel) OR (Sender = btnOK) THEN BEGIN
    Self.Release;
    frmRVSetup := NIL;
    END;

  END;  {of procedure OnClickCommand}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  END;

FINALIZATION

BEGIN
  END;

{of RVSetup.pas...} END.
