Unit Status;
{
Ring status page window

v01.01 2002-11-12 Original
v01.02 2002-12-08 Modifications for RingBar ChangeRing feature
v01.03 2003-01-05 Changes related to new LPF objects
v01.04 2003-01-06 agcerr and conterr are different! 
v01.05 2003-01-26 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.06 2003-03-16 UpdateIt: Gas QT logic added
v01.07 2003-03-16 UpdateIt: VVP states and action display added
v01.08 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.09 2003-03-19 OnCloseForm: replace Self by frmStatus[FRing] := NIL
v01.10 2003-03-20 OnCreateForm: fix VVP parent glitch introduced yesterday
v01.11 2003-05-25 OnDestroyForm: added back; frmStatus[FRing] := NIL;
v01.12 2003-05-27 Replace OnKeyPressForm by OnKeyDownForm
v01.12 2003-05-28 comd/Globals change
v01.13 2003-05-31 Uses ExitSeq.ShutMsgGet
v01.14 2011-10-01 .dfm: increase TfrmStatus width to avoid scroll bars
v01.15 2012-08-25 OnClickForm: ambient_base -- LPF ShowDump
                  .dfm: HandCursor and OnClick event for ambient_base
}

Interface

USES
{$IFDEF LINUX}
  QControls, QExtCtrls, QForms, QGraphics, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Controls, ExtCtrls, Forms, Graphics, StdCtrls,
  Windows, Messages, Classes,
{$ENDIF}
  SysUtils,
  Alarms, CalibAut, CalibMan, Connect, ExitSeq, Heart, RingBar,
  comd, Globals;

TYPE
  TfrmStatus = class(TForm)
    lblMsg: TLabel;
    gbID: TGroupBox;
      lblLabel: TLabel;
      lblLabelValue: TLabel;
      lblSequence: TLabel;
      lblSequenceValue: TLabel;
      lblName: TLabel;
      lblNameValue: TLabel;
    gbStatus: TGroupBox;
      lblFumigation: TLabel;
      lblFumigationValue: TLabel;
      lblEnabled: TLabel;
      lblEnabledValue: TLabel;
      lblConditions: TLabel;
      lblConditionsValue: TLabel;
    gbBuffer: TGroupBox;
      lblNumber: TLabel;
      lblNumberValue: TLabel;
      lblCount: TLabel;
      lblCountValue: TLabel;
    gbOpMode: TGroupBox;
      lblOpMode: TLabel;
      lblOpModeValue: TLabel;
      lblParam1: TLabel;
      lblParam1Value: TLabel;
      lblParam2: TLabel;
      lblParam2Value: TLabel;
      lblParam3: TLabel;
      lblParam3Value: TLabel;
    gbFumMode: TGroupBox;
      lblFumMode: TLabel;
      lblFumModeValue: TLabel;
      lblFumTreat: TLabel;
      lblFumTreatValue: TLabel;
      lblFumBase: TLabel;
      lblFumBaseValue: TLabel;
      lblFumTarget: TLabel;
      lblFumTargetValue: TLabel;
    gbGasValve: TGroupBox;
      lblGVControl: TLabel;
      lblGVControlValue: TLabel;
      lblGVResponse: TLabel;
      lblGVResponseValue: TLabel;
      lblGVError: TLabel;
      lblGVErrorValue: TLabel;
    gbPID: TGroupBox;
      lblIntegral: TLabel;
      lblIntegralValue: TLabel;
      lblProportional: TLabel;
      lblProportionalValue: TLabel;
      lblDifferential: TLabel;
      lblDifferentialValue: TLabel;
      lblWindTerm: TLabel;
      lblWindTermValue: TLabel;
    gbLearning: TGroupBox;
      lblPeriod: TLabel;
      lblPeriodValue: TLabel;
      lblFlow: TLabel;
      lblFlowValue: TLabel;
      lblWind: TLabel;
      lblWindValue: TLabel;
      lblRatio: TLabel;
      lblRatioValue: TLabel;
    gbConcWind: TGroupBox;
      lblGasConc: TLabel;
      lblGasConcGrab: TLabel;
      lblGasConcTime: TLabel;
      lblGasConcInt: TLabel;
      lblGasErr: TLabel;
      lblGasErrGrab: TLabel;
      lblGasErrTime: TLabel;
      lblGasErrInt: TLabel;
      lblWindSpd: TLabel;
      lblWindSpdGrab: TLabel;
      lblWindSpdTime: TLabel;
      lblWindSpdInt: TLabel;
      lblWindDir: TLabel;
      lblWindDirGrab: TLabel;
      lblWindDirTime: TLabel;
      lblWindDirInt: TLabel;
    gbVVP: TGroupBox;
      lblVVPAction: TLabel;
    gbQT: TGroupBox;
      lblQTLogic: TLabel;
    PROCEDURE OnClickForm (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
    PROCEDURE OnKeyDownForm (Sender: TObject; VAR Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FRing: INTEGER;
    rb: TRingBar;    {ring bar}
    hb: THeartBeat;  {heart beat}
    vvp: ARRAY [1..maxvalvs] OF TShape;
  public
    { Public declarations }
  end;

VAR
  frmStatus: ARRAY [1..maxrings] OF TfrmStatus;

PROCEDURE Select (ring: INTEGER);
PROCEDURE UpdateIt (ring: INTEGER);
PROCEDURE HeartBeat (ring: INTEGER; which: BOOLEAN);

Implementation

{$R *.dfm}

VAR onoff: ARRAY [FALSE..TRUE] OF String = ('OFF', 'ON');

{-------------------------------------------------------------}

PROCEDURE TfrmStatus.OnClickForm (Sender: TObject);
BEGIN
  IF (Sender = lblGVError) OR (Sender = lblGVErrorValue) 
    THEN pverr[FRing].ShowDump;
  IF (Sender = lblFlow) OR (Sender = lblFlowValue) 
    THEN proplearn[FRing].ShowDump;
  IF (Sender = lblWind) OR (Sender = lblWindValue) 
    THEN windlearn[FRing].ShowDump;
  IF (Sender = lblGasConcInt)
    THEN agcont[FRing].ShowDump;
  IF (Sender = lblWindSpdInt)
    THEN awspeed[FRing].ShowDump;
  IF (Sender = lblWindDirInt) THEN BEGIN
    awcos[FRing].ShowDump;
    awsin[FRing].ShowDump;
    END;
  IF (Sender = lblFumBase) OR (Sender = lblFumBaseValue) 
    THEN ambient_base.ShowDump;
  END;  {of procedure OnClickForm}
{-------------------------------------------------------------}

PROCEDURE TfrmStatus.OnCreateForm (Sender: TObject);
VAR valve: INTEGER;
BEGIN
  {Allocate the VVP valve on/off colored shapes}
  FOR valve := 1 TO numvalvs DO BEGIN
    vvp[valve] := TShape.Create (gbVVP);
    WITH vvp[valve] DO BEGIN
      Parent := gbVVP;
      Left := 10 + (valve-1) * 12 + ((valve-1) DIV 8) * 8;
      Top := 20;
      Height := 10;
      Width  := 10;
      Shape := stRoundSquare;
      Brush.Color := clBlack;
      END;
    END;
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TfrmStatus.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmStatus[FRing] := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TfrmStatus.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmStatus[FRing] := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TfrmStatus.OnKeyDownForm (
  Sender: TObject; VAR Key: Word; Shift: TShiftState);
BEGIN
  {MessageBox (0, PCHAR(String(CHR(Key))), 'Status', MB_OK);}
  IF (Key = VK_ESCAPE)
    THEN BEGIN Self.Release; frmStatus[FRing] := NIL; END
    ELSE IF (Key = VK_SUBTRACT) OR (Key = 189)
      THEN rb.ChangeRing (FRing-1)
      ELSE IF (Key = VK_ADD) OR (Key = 187)
        THEN rb.ChangeRing (FRing+1)
        ELSE rb.Invoke (Key, Shift);
  END;  {of event handling procedure OnKeyDownForm}
{-------------------------------------------------------------}

PROCEDURE Select (ring: INTEGER);
{Come here when this menu item selected on a form}
BEGIN
  IF NOT Assigned (frmStatus[ring]) THEN BEGIN 
    frmStatus[ring] := TfrmStatus.Create (Application);
    WITH frmStatus[ring] DO BEGIN
      {Create and position (, , Left, Top) the heart beat}
      Heart.Make (hb, frmStatus[ring], 0, lblMsg.Height+4);
      {Create and position ring bar}
      RingBar.Make (rb, frmStatus[ring], numrings, 
                    hb.Right, lblMsg.Height+4, 60, 25, 0);
      END;
    END;
  WITH frmStatus[ring] DO BEGIN
    FRing := ring;
    rb.ButtonDown (ring);
    Caption := 'Status ' + rlabel[ring];
    Show;
    SetFocus;
    WindowState := wsNormal;
    END;
  UpdateIt (ring);
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt (ring: INTEGER);
{Come here at end of every sample/control period}
CONST sint = ' s integration = ';
VAR msg: String;
    gas: GasAuto;
    valve: INTEGER;

FUNCTION fs (x: Single): String;
VAR s: String;
BEGIN
  Str (x:6:1, s);
  fs := s;
  END;  {of local function 'fs'}

BEGIN
  {Operation-off normal flasher and message stripe}
  msg := '';
  msg := msg + Connect.DisconnectMsgGet (ring);
  msg := msg + comd.DebugMsgGet (ring);
  msg := msg + comd.CommErrMsgGet (ring);
  msg := msg + ExitSeq.ShutMsgGet (ring);
  msg := msg + CalibMan.StatusMsgGet (ring);
  msg := msg + CalibAut.StatusMsgGet (ring);
  IF (msg <> '') THEN RingColorValueSet (1, ring, clLtGray);
  msg := msg + Alarms.AlarmMsgGet (ring);
  RingColorToggleSet (ring, (msg <> ''));

  IF Assigned (frmStatus[ring]) THEN 
  IF (frmStatus[ring].WindowState <> wsMinimized) THEN

  WITH frmStatus[ring] DO BEGIN
    lblMsg.Caption := msg;

    lblLabelValue.Caption := rlabel[ring];
    lblSequenceValue.Caption := IntToStr (ring);
    lblNameValue.Caption := descriptor[ring];

    IF runon[ring]
      THEN lblFumigationValue.Caption := 'On'
      ELSE lblFumigationValue.Caption := 'Off';
    IF fumigation_enabled[ring]
      THEN lblEnabledValue.Caption := 'Yes'
      ELSE lblEnabledValue.Caption := 'No';
    IF conditional_ok[ring]
      THEN lblConditionsValue.Caption := 'OK'
      ELSE lblConditionsValue.Caption := 'Bad';

    lblNumberValue.Caption := IntToStr (loggpoint[ring]);
    lblCountValue.Caption := IntToStr (loggcount[ring]);

    CASE onoff_mode[ring] OF
      0: BEGIN
           lblOpModeValue.Caption := 'Off';
           lblParam1Value.Caption := '';
           lblParam2Value.Caption := '';
           lblParam3Value.Caption := '';
           lblParam1.Caption := '';
           lblParam2.Caption := '';
           lblParam3.Caption := '';
           END;
      1: BEGIN
           lblOpModeValue.Caption := 'Always';
           lblParam1Value.Caption := '';
           lblParam2Value.Caption := '';
           lblParam3Value.Caption := '';
           lblParam1.Caption := '';
           lblParam2.Caption := '';
           lblParam3.Caption := '';
           END;
      2: BEGIN
           lblOpModeValue.Caption := 'Clock';
           lblParam1Value.Caption := stimeon[ring];
           lblParam2Value.Caption := stimeoff[ring];
           lblParam3Value.Caption := '';
           lblParam1.Caption := 'Time on';
           lblParam2.Caption := 'Time off';
           lblParam3.Caption := '';
           END;
      3: BEGIN
           lblOpModeValue.Caption := 'Solar';
           lblParam1Value.Caption := fs (dawn_altitude[ring]);
           lblParam2Value.Caption := solar_ton[ring];
           lblParam3Value.Caption := solar_toff[ring];
           lblParam1.Caption := 'Sun alt';
           lblParam2.Caption := 'Time on';
           lblParam3.Caption := 'Time off';
           END;
      END;  {case}

    CASE enrich_mode[ring] OF
      0: lblFumModeValue.Caption := 'Constant';
      1: lblFumModeValue.Caption := 'Additive';
      2: lblFumModeValue.Caption := 'Multiplicative';
      3: lblFumModeValue.Caption := 'Custom';
      END;  {case}
    lblFumTreatValue.Caption := fs (enrich_val[ring][enrich_mode[ring]]);
    lblFumBaseValue.Caption := fs (ambient_base.Integral);
    lblFumTargetValue.Caption := fs (gcset[ring]);

    lblGVControlValue.Caption := fs (propc[ring]);
    lblGVResponseValue.Caption := fs (propresp[ring]);
    lblGVErrorValue.Caption := fs (pverr[ring].Integral);

    lblIntegralValue.Caption := fs (cinteg[ring]);
    lblProportionalValue.Caption := fs (cprop[ring]);
    lblDifferentialValue.Caption := fs (cdiff[ring]);
    lblWindTermValue.Caption := fs (cwind[ring]);

    lblPeriodValue.Caption := fs (tlearn[ring]);
    lblFlowValue.Caption := fs (proplearn[ring].Integral);
    lblWindValue.Caption := fs (windlearn[ring].Integral);
    IF (windlearn[ring].Integral > 0.0)
      THEN lblRatioValue.Caption := 
        fs (proplearn[ring].Integral/windlearn[ring].Integral)
      ELSE lblRatioValue.Caption := '???';

    lblGasConcGrab.Caption := fs (gcgrab[ring]);
    lblGasConcTime.Caption := fs (gcint[ring]) + sint;
    lblGasConcInt.Caption  := fs (agcont[ring].Integral);
    lblGasErrGrab.Caption := fs (gcerr[ring]);
    lblGasErrInt.Caption  := fs (agcerr[ring]);
    lblWindSpdGrab.Caption := fs (wspeed[ring]);
    lblWindSpdTime.Caption := fs (wsint[ring]) + sint;
    lblWindSpdInt.Caption  := fs (awspeed[ring].Integral);
    lblWindDirGrab.Caption := IntToStr(ROUND(wwdir[ring]));
    lblWindDirTime.Caption := fs (wdint[ring]) + sint;
    lblWindDirInt.Caption  := awwdir[ring];

    FOR valve := 1 TO numvalvs DO IF vact[ring,valve]
      THEN vvp[valve].Brush.Color := clWhite
      ELSE vvp[valve].Brush.Color := clLtGray;
    IF ifire IN [1..maxrings] 
      THEN lblVVPAction.Caption:= vvptime[ring].msg + ' ' + rlabel[ifire]
      ELSE lblVVPAction.Caption:= vvptime[ring].msg;
    vvptime[ring].msg := '  ';

    lblQTLogic.Caption := 'Ask:'   + onoff[co2qt[ring].asked] +
                          ' Give:' + onoff[co2qt[ring].state];

    {Ring bar color codes}
    rb.UpdateIt;

    END;  {object Assigned}
  END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

PROCEDURE HeartBeat (ring: INTEGER; which: BOOLEAN);
BEGIN
  IF Assigned (frmStatus[ring]) THEN
  IF (frmStatus[ring].WindowState <> wsMinimized) THEN
  IF Assigned(frmStatus[ring].hb) THEN
    Heart.Pick (frmStatus[ring].hb, which);
  END;  {of procedure HeartBeat}
{-------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of form unit Status...} END.
