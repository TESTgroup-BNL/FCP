Unit Compare;
{$R+  Range checking ON}
{
Show selected variables for all rings in one window.

v01.01 2004-12-09 Original from gutted copy of MPSample.pas 2004-12-05
v01.02 2005-05-03 OnCreateForm: correct 'PV-rest' to 'PV-resp'.
                  OnCreateForm: correct IntToStr(ring) to rlabel[ring].
                  OnCreateForm: correct auto placement of Help & Cancel.
v01.03 2005-05-04 OnCreateForm: button placement adjustment.
                  Implementation/Uses: add RingBar
                  UpdateIt: state color same as ringbar button color #1,
                    i.e. does not flash red or gray.
v01.04 2011-09-26 CONST LinesMax: change from 17 to 18.
                  UpdateIt: add filling new line.
                  OnCreateForm: add row label "Pvvp" for line 18.
                  OnCreateForm: use wider window if only one ring.
v01.05 2012-09-14 OnCreateForm: for row captions, make use of label and
                    unit names in list_addr variables (partial).
                    The values for ring 1 are used!!!
}

Interface

Uses
{$IFDEF LINUX}
  QButtons, QControls, QExtCtrls, QForms, QGraphics, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Controls, ExtCtrls, Forms, Graphics, StdCtrls,
  Windows, Messages, Classes,
{$ENDIF}
  SysUtils,
  Globals, comd;

CONST
  LinesMax = 18;

TYPE
  TCompare = class(TForm)
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
  Private
    { Private declarations }
    objCompareTable: ARRAY [0..LinesMax] OF ARRAY [0..maxrings] OF Tlabel;
  Public
    { Public declarations }
  END;

VAR frmCompare: TCompare;

{-------------------------------------------------------------}

PROCEDURE Select;
PROCEDURE UpdateIt;

Implementation

USES Ringbar, LblForm;

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmCompare)
    THEN frmCompare := TCompare.Create (Application);
  frmCompare.Show;
  frmCompare.SetFocus;
  frmCompare.WindowState := wsNormal;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
{Come here at end of every sample/control period}
VAR ring: INTEGER;
BEGIN
IF Assigned (frmCompare) THEN
  IF (frmCompare.WindowState <> wsMinimized) THEN
    FOR ring := 1 TO numrings DO BEGIN
      WITH frmCompare, list_addr_ptr[ring]^ DO BEGIN
        objCompareTable[1][ring].Font.Style := [fsBold];
        objCompareTable[1][ring].Font.Color :=
          RingColorValueGet (1, ring);
        IF runon[ring]
          THEN objCompareTable[1][ring].Caption := 'ON'
          ELSE objCompareTable[1][ring].Caption := 'OFF';

      objCompareTable[ 2][ring].Caption :=
        FloatToStrF (gcset[ring],    ffFixed,8,0);

IF conc_fumi.exists THEN
      objCompareTable[ 3][ring].Caption :=
        FloatToStrF (gcgrab[ring],   ffFixed,8,0);

IF conc_fumi.exists AND (site_id <> 'ZA1') THEN BEGIN
      objCompareTable[ 4][ring].Caption :=
        FloatToStrF (agc1m[ring].Integral, ffFixed,8,0);
      objCompareTable[ 5][ring].Caption :=
        FloatToStrF (agc5m[ring].Integral, ffFixed,8,0);
END;

IF conc_cont.exists THEN
      objCompareTable[ 6][ring].Caption :=
        FloatToStrF (gccntl[ring],   ffFixed,8,0);

IF conc_ambi.exists THEN
      objCompareTable[ 7][ring].Caption :=
        FloatToStrF (gcambi[ring],   ffFixed,8,0);

IF pv_control.exists THEN
      objCompareTable[ 8][ring].Caption :=
        FloatToStrF (propc[ring],    ffFixed,8,1);

IF pv_response.exists THEN
      objCompareTable[ 9][ring].Caption :=
        FloatToStrF (propresp[ring], ffFixed,8,1);

IF wind_speed.exists THEN
      objCompareTable[10][ring].Caption :=
        FloatToStrF (wspeed[ring],   ffFixed,8,1);

IF wind_direction.exists THEN
      objCompareTable[11][ring].Caption :=
        IntToStr    (wwdir[ring]);

IF temp_atmosphere.exists THEN
      objCompareTable[12][ring].Caption :=
        FloatToStrF (temp1[ring],    ffFixed,8,1);

IF temp_enclosure.exists THEN
      objCompareTable[13][ring].Caption :=
        FloatToStrF (temp2[ring],    ffFixed,8,1);

IF temp_auxiliary.exists THEN
      objCompareTable[14][ring].Caption :=
        FloatToStrF (temp3[ring],    ffFixed,8,1);

IF pressure_atmosphere.exists THEN
      objCompareTable[15][ring].Caption :=
        FloatToStrF (airpres[ring],  ffFixed,8,2);

IF water_vapor.exists THEN
      objCompareTable[16][ring].Caption :=
        FloatToStrF (ph2o[ring],     ffFixed,8,0);

IF solar_radiation.exists THEN
      objCompareTable[17][ring].Caption :=
        FloatToStrF (solrad[ring],   ffFixed,8,0);

IF vvp_pressure.exists THEN
      objCompareTable[18][ring].Caption :=
        FloatToStrF (Pvvp[ring],     ffFixed,8,2);

      END;
    END;
END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

PROCEDURE TCompare.OnCreateForm (Sender: TObject);
CONST hlab = 80;
      vlab = 20;
VAR line, ring: INTEGER;
BEGIN

{Give it a title}
  Caption := 'Comparison of selected variables for all rings';

{Dynamically create the compare table objects}
  FOR line := 0 TO LinesMax DO
    FOR ring := 0 TO numrings DO
      IF NOT Assigned (objCompareTable[line][ring]) THEN BEGIN
      objCompareTable[line][ring] := TLabel.Create (Self);
      WITH objCompareTable[line][ring] DO BEGIN
        Parent  := Self;
        Left    := ring * hlab;
        Top     := line * vlab;
        Width   := hlab;
        Height  := vlab;
        Caption := '---';
        END;
      END;

  FOR line := 1 TO LinesMax DO
    {Index 0 is row labels}
    WITH objCompareTable[line][0], list_addr_ptr[1]^ DO BEGIN
      Font.Style := [fsBold];
      CASE line OF
         1: Caption := 'State';
         2: Caption := 'Target';
         3: IF (site_id <> 'ZA1') THEN Caption := 'Fum-grab'
                                  ELSE Caption := 'Cham A';
         4: Caption := 'Fum-1min';
         5: Caption := 'Fum-5min';
         6: IF (site_id <> 'ZA1') THEN Caption := 'Control'
                                  ELSE Caption := 'Cham B';
         7: Caption := 'Ambient';
         8: Caption := 'PV-ctrl';
         9: Caption := 'PV-resp';
        10: Caption := 'Wind spd';
        11: Caption := 'Wind dir';
        12: Caption := temp_atmosphere.label_name + ' ' +
                       temp_atmosphere.unit_name;
        13: Caption := temp_enclosure.label_name + ' ' +
                       temp_enclosure.unit_name;
        14: Caption := temp_auxiliary.label_name + ' ' +
                       temp_auxiliary.unit_name;
        15: Caption := pressure_atmosphere.label_name + ' ' +
                       pressure_atmosphere.unit_name;
        16: Caption := water_vapor.label_name + ' ' +
                       water_vapor.unit_name;
        17: Caption := solar_radiation.label_name + ' ' {+
                       solar_radiation.unit_name};
        18: Caption := vvp_pressure.label_name + ' ' +
                       vvp_pressure.unit_name;
        END; {case}
      END;

  FOR ring := 1 TO numrings DO
    {Index 0 is column labels}
    WITH objCompareTable[0][ring] DO BEGIN
      Font.Style := [fsBold];
      IF (site_id <> 'ZA1')
        THEN Caption := 'Ring '
        ELSE Caption := 'Pair ';
      Caption := Caption + rlabel[ring];
      END;

{Position the window}
  Left := 0;
  Top := 0;

{Size the window}
  IF (numrings <= 1)
    THEN Width  :=            3 * hlab
    ELSE Width  := (numrings+1) * hlab;
  Height := (LinesMax+3) * vlab + btnCancel.Height + 8;

{Position the cancel button}
  btnCancel.Left := ClientWidth  - btnCancel.Width  - 8;
  btnCancel.Top  := ClientHeight - btnCancel.Height - 8;

{Position the help button}
  btnHelp.Left := btnCancel.Left - btnHelp.Width - 8;
  btnHelp.Top  := btnCancel.Top;
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TCompare.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmCompare := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TCompare.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmCompare := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE help;
CONST nl  = CHR(13) + CHR(10);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR frmHelp: TLblForm;
BEGIN
  frmHelp := TLblForm.Create(Application);
  frmHelp.Display ('Variable comparison table: help', '');
  frmHelp.BodyAppend (
'No help information prepared yet.' + nl2 +
'Probably none needed.' + nl +
'');
  END;  {of procedure 'help'}
{-------------------------------------------------------------}

PROCEDURE TCompare.OnClickButton (Sender: TObject);
BEGIN
  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmCompare := NIL;
    END;
  IF (Sender = btnHelp) THEN BEGIN
    help;
    END;
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

{VAR i: INTEGER;}

Initialization

BEGIN

  END;

Finalization

BEGIN
  END;

{of form unit Compare...}
END.
