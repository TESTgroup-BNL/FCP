UNIT H2OVapor;
{
Water vapor pressure display and calculator page

v01.01 2003-05-26 Original Ephem v01.05, IDE, and comp/h2ovapor()
v01.02 2003-05-27 Edit box cursors are crNo when in Automatic
v01.03 2006-03-17 Copy h2o_saturation() here from tp5utils.pas
                  Add to Interface
                  Remove Uses tp5utils
                  UpdateIt: suppress e_working, t_working warning message
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
  comd, Globals;

TYPE
  TfrmH2OVapor = CLASS(TForm)
    lblFormula: TLabel;
    gbInput: TGroupBox;
      rbAutomatic: TRadioButton;
      rbManual: TRadioButton;
      lblpH2O: TLabel;
        edpH2O: TEdit;
      lblTemperature: TLabel;
        edTemperature: TEdit;
    gbOutput: TGroupBox;
      lblEsatTitle: TLabel;
        lblEsatValue: TLabel;
      lblDewptTitle: TLabel;
        lblDewptValue: TLabel;
      lblRHTitle: TLabel;
        lblRHValue: TLabel;
      lblVPDTitle: TLabel;
        lblVPDValue: TLabel;
    gbRings: TGroupBox;
    btnCancel: TBitBtn;
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnClickRadioButton (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
  PRIVATE
    { Private declarations }
    rbRings: ARRAY [1..maxrings] OF TRadioButton;
  PUBLIC
    { Public declarations }
  END;

VAR
  frmH2OVapor: TfrmH2OVapor;

  SRing: INTEGER;

  PROCEDURE h2o_saturation (e, t: float; VAR esat, tdp, rh, vpd: float);

  PROCEDURE Select;
  PROCEDURE UpdateIt;

IMPLEMENTATION

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE h2o_saturation (e, t: float; VAR esat, tdp, rh, vpd: float);
{ From water vapor partial pressure [Pa] and temperature [oC]
  calculate saturation water vapor pressure, dew(frost)-point,
  relative humidity, and vapor pressure deficit.
  Note: If e < epsilon, minusbignum returned
  Ref.: LI-610 Portable Dew Point Generator Instruction Manual
        1991, p. 3-15, eq. 3-4 "Buck (1981)"
  This formula selected because it is the simplest and good enough
  J.N.  95/06/14  Original
  }
CONST k1 = 613.65;     {Pa}
      k2 = 17.502;
      k3 = 240.97;     {oC}

      epsilon     =  1.0E-10;
      minusbignum = -9999.0;

VAR lnratio: REAL;

BEGIN
  IF e > epsilon
    THEN BEGIN
      lnratio := LN(e/k1);
      esat := k1*EXP((k2*t)/(k3+t));      {saturation vapor pressure}
      tdp  := (k3*lnratio)/(k2-lnratio);  {dew-point temperature}
      rh   := 100.0*e/esat;               {relative humidity %}
      vpd  := esat - e;                   {vapor pressure deficit}
      END
    ELSE BEGIN
      esat := minusbignum;
      tdp  := minusbignum;
      rh   := minusbignum;
      vpd  := minusbignum;
      END;
  END;  {of procedure 'h2o_saturation'}
{-------------------------------------------------------------}

PROCEDURE TfrmH2OVapor.OnClickButton (Sender: TObject);
{What to do when a command button is pressed}
BEGIN
  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmH2OVapor := NIL;
    END;
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TfrmH2OVapor.OnClickRadioButton (Sender: TObject);
{What to do when a radio button is pressed}
VAR ring: INTEGER;
BEGIN
  FOR ring := 1 TO numrings DO
    IF (rbRings[ring].Checked) THEN SRing := ring;
  END;  {of procedure OnClickRadioButton}
{-------------------------------------------------------------}

PROCEDURE TfrmH2OVapor.OnCreateForm (Sender: TObject);
VAR ring: INTEGER;
    column: INTEGER;
BEGIN
  rbAutomatic.Checked := TRUE;
  rbManual.Checked := FALSE;

  {Dynamically create and fill the ring radio buttons}
  FOR ring := 1 TO numrings DO
    IF NOT Assigned (rbRings[ring]) THEN BEGIN
      rbRings[ring] := TRadioButton.Create (Self);
      WITH rbRings[ring] DO BEGIN
        Parent := gbRings;
        Font.Color := clBlack;
        Caption := '  ' + rlabel[ring];
        Checked := (ring = SRing);
        column := ((maxrings+1) DIV 2);
        Left := ((ring-1) DIV column) * (gbRings.Width DIV 2) + 10;
        Width := (gbRings.Width DIV 2) - 20;
        Height := 20;
        Top := ((ring-1) MOD column) * Height + 30;
        OnClick := OnClickRadioButton;
        END;  {with}
      END;  {if}

  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TfrmH2OVapor.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmH2OVapor := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TfrmH2OVapor.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmH2OVapor := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on a form}
BEGIN
  IF NOT Assigned (frmH2OVapor) THEN BEGIN
    frmH2OVapor := TfrmH2OVapor.Create (Application);
    END;
  WITH frmH2OVapor DO BEGIN
    Show;
    SetFocus;
    WindowState := wsNormal;
    END;  {with frmH2OVapor}
  UpdateIt;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
VAR e_working, t_working: Single;
    esat, tdp, rh, vpd:   Single;
{Come here at end of every sample/control period}
BEGIN
  IF Assigned (frmH2OVapor) THEN
  IF (frmH2OVapor.WindowState <> wsMinimized) THEN

  WITH frmH2OVapor DO BEGIN

    e_working := 0.0;  {This suppresses an initialization}
    t_working := 0.0;  {warning message.  In fact, everything OK.}

    IF rbAutomatic.Checked THEN BEGIN
      edpH2O       .ReadOnly := TRUE;
      edTemperature.ReadOnly := TRUE;
      edpH2O       .Cursor   := crNo;
      edTemperature.Cursor   := crNo;
      edpH2O       .Text     := FloatToStrF (ph2o[SRing],  ffFixed, 7, 0);
      edTemperature.Text     := FloatToStrF (temp1[SRing], ffFixed, 7, 1);
      e_working := ph2o[SRing];
      t_working := temp1[SRing];
      END;

    IF rbManual.Checked THEN BEGIN
      edpH2O       .ReadOnly := FALSE;
      edTemperature.ReadOnly := FALSE;
      edpH2O       .Cursor   := crDefault;
      edTemperature.Cursor   := crDefault;
      TRY
        e_working := StrToFloat (edpH2O.Text);
        EXCEPT
        e_working := 0.0;
        edpH2O.Text := '';
        END;
      TRY
        t_working := StrToFloat (edTemperature.Text);
        EXCEPT
        t_working := 0.0;
        edTemperature.Text := '';
        END;
      END;

    h2o_saturation (e_working, t_working, esat, tdp, rh, vpd);
    lblEsatValue .Caption := FloatToStrF (esat, ffFixed, 7, 0);
    lblDewptValue.Caption := FloatToStrF (tdp,  ffFixed, 7, 1);
    lblRHValue   .Caption := FloatToStrF (rh,   ffFixed, 7, 0);
    lblVPDValue.  Caption := FloatToStrF (vpd,  ffFixed, 7, 0);

    END;

  END;  {of procedure 'UpdateIt'}

INITIALIZATION

BEGIN
  SRing := 1;
  END;

{of H2OVapor.pas} END.
