UNIT UtilObjs;
{
A gathering of general-purpose classes

v 01.01  2003-01-05  Add LPF (low pass filter)
v 01.02  2003-01-06  TLPF.LambdaNuSet: tau=0 --> lambda=0, nu=1
v 01.03  2003-01-06  TLPF: change "limit" to "range"
v 01.04  2003-01-26  Replace CLX by LINUX | MSWINDOWS in USES
v 01.05  2003-06-13  TLPF: RangeMin, RangeMax now also READ properties
v 01.06  2003-06-15  Use TTemplate and two ListBoxes
v 01.07  2003-06-15  Add LastIntegral field
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QGraphics, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics, StdCtrls,
{$ENDIF}
  Template,
  SysUtils;

{Low pass filter objects}

TYPE TLPFForm = CLASS (TTemplate)
  PRIVATE
    lbField: TListBox;
    lbValue: TListBox;
    cbAuto: TCheckBox;
  END;

TYPE TLPF = CLASS (TObject)
  PRIVATE
    FName: STRING;
    FSeedDone: BOOLEAN;
    FSeedCount: INTEGER;
    FSeedSum: DOUBLE;
    FInterval: DOUBLE;
    FResponseTime: DOUBLE;
    FLambda: DOUBLE;  {multiplier of previous integral}
    FNu: DOUBLE;  {multiplier of new value; lambda+nu=1}
    FRangeMin: DOUBLE;
    FRangeMax: DOUBLE;
    FOutOfRange: BOOLEAN;
    FDefaultValue: DOUBLE;
    FDefaultEnable: BOOLEAN;
    FNTotal: INTEGER;
    FNInvalid: INTEGER;
    FLastIntegral: DOUBLE;
    FLastValue: DOUBLE;
    FIntegral: DOUBLE;  {result}
    dumpform: TLPFForm;
    PROCEDURE MakeChildren;  {this and below debug form related}
    PROCEDURE Refresh;
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnClickButton (Sender: TObject);
  PUBLIC
    PROCEDURE SeedDoneSet (value: BOOLEAN);
    PROCEDURE LambdaNuSet;
    PROCEDURE IntervalSet (value: DOUBLE);
    PROCEDURE ResponseTimeSet (value: DOUBLE);
    PROPERTY Name: STRING WRITE FName;
    PROPERTY SeedDone: BOOLEAN WRITE SeedDoneSet;
    PROPERTY Interval: DOUBLE WRITE IntervalSet;
    PROPERTY ResponseTime: DOUBLE WRITE ResponseTimeSet;
    PROPERTY Lambda: DOUBLE WRITE FLambda;
    PROPERTY RangeMin: DOUBLE READ FRangeMin WRITE FRangeMin;
    PROPERTY RangeMax: DOUBLE READ FRangeMax WRITE FRangeMax;
    PROPERTY DefaultValue: DOUBLE WRITE FDefaultValue;
    PROPERTY DefaultEnable: BOOLEAN WRITE FDefaultEnable;
    PROPERTY Integral: DOUBLE READ FIntegral WRITE FIntegral;
    CONSTRUCTOR Create;
    PROCEDURE Integrate (value: DOUBLE);
    PROCEDURE ShowDump;
    END;

IMPLEMENTATION

{++++++++++++++++++++ LPF object ++++++++++++++++++++}

CONSTRUCTOR TLPF.Create;
BEGIN
  INHERITED Create;
  FName          := '[none provided]';
  FSeedDone      := FALSE;  {use averaging to seed the integral}
  FSeedCount     := 0;
  FSeedSum       := 0.0;
  FInterval      := 1.0;
  FResponseTime  := 0.0;
  FLambda        := 0.0;     {i.e., no integration}
  FNu            := 1.0;
  FRangeMin      := -1.0E37; {effectively, no input value range check}
  FRangeMax      := +1.0E37; 
  FDefaultValue  := 0.0;     {will decay to zero if default enabled}
  FDefaultEnable := FALSE;   {freeze integral if input value out of range}
  FNTotal        := 0;
  FNInvalid      := 0;
  FLastValue     := FRangeMax;
  FIntegral      := 0.0;
  END;  {constructor Create}
{--------------------------------------------------------------}

PROCEDURE TLPF.SeedDoneSet (value: BOOLEAN);
{Provide a means of redoing the seeding process.
 Set SeedDone property from TRUE to FALSE to redo.
 Set SeedDone property to TRUE to stop seeding process at any time.}
BEGIN
  IF (value <> FSeedDone) THEN BEGIN
    FSeedDone := value;
    IF (NOT FSeedDone) THEN BEGIN
      FSeedCount :=  0;
      FSeedSum   :=  0.0;
      END;
    END;
  END;  {procedure SeedDoneSet}
{--------------------------------------------------------------}

PROCEDURE TLPF.LambdaNuSet;
{See Integrate method for meaning of integration constants.
 A non-positive response time means filter is a simple pass through.}
BEGIN
  IF (FResponseTime > 0.0) 
    THEN FLambda := EXP(-FInterval/FResponseTime)
    ELSE FLambda := 0.0;
  FNu := 1.0 - FLambda;
  END;  {procedure LambdaNuSet}
{--------------------------------------------------------------}

PROCEDURE TLPF.IntervalSet (value: DOUBLE);
{Interval is the sampling period, i.e. the expected
 time between calls to the Integrate method.
 Changing the interval automatically recalculates 
 the integration constants.}
BEGIN
  IF (value <> FInterval) THEN BEGIN
    FInterval := value;
    LambdaNuSet;
    END;
  END;  {procedure IntervalSet}
{--------------------------------------------------------------}

PROCEDURE TLPF.ResponseTimeSet (value: DOUBLE);
{ResponseTime is tau in exp(-t/tau).
 Changing the response time automatically recalculates 
 the integration constant.}
BEGIN
  IF (value <> FResponseTime) THEN BEGIN
    FResponseTime := value;
    LambdaNuSet;
    END;
  END;  {procedure ResponseTimeSet}
{--------------------------------------------------------------}

PROCEDURE TLPF.Integrate (value: DOUBLE);
BEGIN
  INC (FNTotal);
  FLastIntegral := FIntegral;
  FLastValue := value;
  {Test of out-of-range input value}
  FOutOfRange := FALSE;
  IF (value < FRangeMin) OR (value > FRangeMax) THEN BEGIN
    INC (FNInvalid);
    FOutOfRange := TRUE;
    value := FDefaultValue;  {replace input value}
    END;
  IF (NOT FOutOfRange) OR FDefaultEnable THEN
    IF FSeedDone
      {Seeding complete.  Use recursive filter.}
      THEN BEGIN
        FIntegral := FLambda * FIntegral + FNu * value;
        END
      {Seeding not complete.  Use averaging.}
      ELSE BEGIN
        INC (FSeedCount);
        FSeedSum := FSeedSum + value;
        IF (FSeedCount > 0) THEN BEGIN
          FIntegral := FSeedSum/FSeedCount;
          {Stop seeding at approximately one response time period.}
          FSeedDone := (1.0/FSeedCount < FNu);
          END;
        END;
    IF Assigned (dumpform) AND dumpform.cbAuto.Checked THEN Refresh;
  END;  {procedure Integrate}
{--------------------------------------------------------------}

PROCEDURE TLPF.ShowDump;
BEGIN
  IF (NOT Assigned (dumpform)) THEN BEGIN
    dumpform := TLPFForm.Create (Application);
    MakeChildren;
    END;
  WITH dumpform DO BEGIN
    Show;
    SetFocus;
    WindowState := wsNormal;
    END;  {with dumpform}
  Refresh;
  END;  {procedure ShowDump}
{--------------------------------------------------------------}

PROCEDURE TLPF.MakeChildren;
BEGIN
  With dumpform DO BEGIN

    {Form parameters -- height set at end}
    Caption := 'LPF (low pass filter) object field dump';
    Width := (Screen.Width * 4) DIV 5;
    OnClose := OnCloseForm;

    {Command buttons}
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
    WITH btnOK DO BEGIN
      Visible := FALSE;
      Enabled := FALSE;
      END;
    WITH btnCancel DO BEGIN  {upper left anchor}
      Top := Height DIV 2;
      Left := 15;
      OnClick := OnClickButton;
      END;
  
    {Dynamically create Field and Value list boxes}
    IF NOT Assigned (lbField) THEN BEGIN
      lbField := TListBox.Create (dumpform);
      With lbField DO BEGIN
        Parent := dumpform;
        Top := btnCancel.Top + (btnCancel.Height * 3) DIV 2;
        Left := btnCancel.Left;
        Width := dumpform.Width DIV 4;
        Items[ 0] := 'Name';
        Items[ 1] := 'SeedDone';
        Items[ 2] := 'SeedCount';
        Items[ 3] := 'SeedSum';
        Items[ 4] := 'Interval';
        Items[ 5] := 'ResponseTime';
        Items[ 6] := 'Lambda';
        Items[ 7] := 'Nu';
        Items[ 8] := 'RangeMax';
        Items[ 9] := 'RangeMin';
        Items[10] := 'OutOfRange';
        Items[11] := 'DefaultValue';
        Items[12] := 'DefaultEnable';
        Items[13] := 'NTotal';
        Items[14] := 'NInvalid';
        Items[15] := 'LastIntegral';
        Items[16] := 'LastValue';
        Items[17] := 'Integral';
        Height := (Count + 1) * ItemHeight;
        END;
      END;
    IF NOT Assigned (lbValue) THEN BEGIN
      lbValue := TListBox.Create (dumpform);
      With lbValue DO BEGIN
        Parent := dumpform;
        Top := lbField.Top;
        Left := lbField.Left + lbField.Width;
        Width := dumpform.Width - Left - 15;
        Height := lbField.Height;
        Font.Style := [];
        END;
      END;

    {Dynamically create autorefresh check box}
    IF NOT Assigned (cbAuto) THEN BEGIN
      cbAuto := TCheckBox.Create (dumpform);
      With cbAuto DO BEGIN
        Parent := dumpform;
        AllowGrayed := FALSE;
        Top := btnCancel.Top + (btnCancel.Height DIV 2) - (Height DIV 2);
        Left := lbValue.Left;
        Width := 2 * Width;
        Caption := 'Auto refresh';
        END;
      END;

    Height := lbField.Top + lbField.Height + 40;
    END;  {with dumpform}
  END;  {of procedure MakeChildren}
{--------------------------------------------------------------}

PROCEDURE TLPF.Refresh;
{Refresh values of fields displayed on dump form}
BEGIN
  IF Assigned (dumpform) THEN WITH dumpform DO BEGIN
    lbValue.Items[ 0] := FName;
    lbValue.Items[ 1] := BoolToStr(FSeedDone,TRUE);
    lbValue.Items[ 2] := IntToStr(FSeedCount);
    lbValue.Items[ 3] := FloatToStr(FSeedSum);
    lbValue.Items[ 4] := FloatToStr(FInterval);
    lbValue.Items[ 5] := FloatToStr(FResponseTime);
    lbValue.Items[ 6] := FloatToStr(FLambda);
    lbValue.Items[ 7] := FloatToStr(FNu);
    lbValue.Items[ 8] := FloatToStr(FRangeMax);
    lbValue.Items[ 9] := FloatToStr(FRangeMin);
    lbValue.Items[10] := BoolToStr(FOutOfRange,TRUE);
    lbValue.Items[11] := FloatToStr(FDefaultValue);
    lbValue.Items[12] := BoolToStr(FDefaultEnable,TRUE);
    lbValue.Items[13] := IntToStr(FNTotal);
    lbValue.Items[14] := IntToStr(FNInvalid);
    lbValue.Items[15] := FloatToStr(FLastIntegral);
    lbValue.Items[16] := FloatToStr(FLastValue);
    lbValue.Items[17] := FloatToStr(FIntegral);
    END;
  END;  {of procedure 'Refresh'}
{--------------------------------------------------------------}

PROCEDURE TLPF.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  OnClickButton (TObject(dumpform.btnCancel));
  END;  {of procedure OnCloseForm}
{--------------------------------------------------------------}

PROCEDURE TLPF.OnClickButton (Sender: TObject);
BEGIN
  IF (Sender = dumpform.btnCancel) THEN BEGIN
    dumpform.Release;
    dumpform := NIL;
    END;
  END;  {of procedure OnClickButton}
{--------------------------------------------------------------}

{++++++++++++++++++++ end of LPF object +++++++++++++++++++++++}

{-------------------- end of unit UtilObj ---------------------}
END.
