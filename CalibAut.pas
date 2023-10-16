Unit CalibAut;
{
Automatic calibration mode setup window

v01.01 2002-09-19 Original
v01.02 2002-11-11 Work continues
v01.03 2002-12-17 StatusMsgGet: use a local gas var for loop
v01.04 2003-01-26 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.05 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.06 2003-03-18 Rename ButtonCancel as btnCancel, etc.
v01.07 2003-05-25 OnDestroyForm: added back; frmCalibaut := NIL
v01.08 2003-05-28 comd/Global changes
v01.09 2006-03-17 Remove Uses tp5utils -- nothing called for
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QComCtrls, QControls, QForms, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, ComCtrls, Controls, Forms, StdCtrls,
  Windows, Messages, Classes,
{$ENDIF}
  SysUtils, 
  LblForm, Globals,
  comd;

TYPE
  TCalibAut = class(TForm)
    TabControl1: TTabControl;
    LabelRing: TLabel;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    btnHelp: TBitBtn;
    GroupboxZero: TGroupBox;
      CheckboxEnabledZero: TCheckBox;
      CheckboxInvertedZero: TCheckBox;
      EditTimepulseZero: TEdit;
      EditTimeactiveZero: TEdit;
      EditIntvalminZero: TEdit;
      EditIntvalmultZero: TEdit;  
      EditIntvalmaxZero: TEdit; 
      EditIntvalnowZero: TEdit; 
      LabelTimepulseZero: TLabel;
      LabelTimeactiveZero: TLabel;
      LabelIntvalminZero: TLabel;
      LabelIntvalmultZero: TLabel;  
      LabelIntvalmaxZero: TLabel; 
      LabelIntvalnowZero: TLabel; 
      btnApplyZero: TBitBtn;
      btnTestZero: TBitBtn;
    GroupboxSpan: TGroupBox;
      CheckboxEnabledSpan: TCheckBox;
      CheckboxInvertedSpan: TCheckBox;
      EditTimepulseSpan: TEdit;
      EditTimeactiveSpan: TEdit;  
      EditIntvalminSpan: TEdit;  
      EditIntvalmaxSpan: TEdit; 
      EditIntvalmultSpan: TEdit;  
      EditIntvalnowSpan: TEdit; 
      btnApplySpan: TBitBtn;
      btnTestSpan: TBitBtn;
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  END;

TYPE autocalib_rec = RECORD
       enable,
       active,
       inverted,          {0 level activates}
       forceon: BOOLEAN;  {debugging}
       timebegan,         {all time units are seconds}
       timepulse,
       timeactive, 
       intval,            {these control time between autocalibrations}
       intvalmin,
       intvalmax,
       intvalmult: float;
       END;

TYPE GasAuto = (Zero, Span);

VAR gas: GasAuto;

VAR autocalib_var: ARRAY [ring_range] OF 
                   ARRAY [GasAuto] OF 
                     autocalib_rec;

VAR frmCalibAut: TCalibAut;
    frmHelp: TLblForm;

PROCEDURE Select;
PROCEDURE UpdateIt;
FUNCTION StatusMsgGet (ring: INTEGER): String;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Implementation

Uses Main;

{$R *.dfm}

VAR ring_selected, ring_selected_last: INTEGER;
VAR ring: INTEGER;

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmCalibAut) 
    THEN frmCalibAut := TCalibAut.Create (Application);
  frmCalibAut.Show;
  frmCalibAut.SetFocus;
  frmCalibAut.WindowState := wsNormal;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
{Come here at end of every sample/control period}
BEGIN
  IF Assigned (frmCalibAut) THEN
    IF (frmCalibAut.WindowState <> wsMinimized) THEN BEGIN
      END;
  END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

FUNCTION StatusMsgGet (ring: INTEGER): String;
VAR msg: String;
    gas: GasAuto;
BEGIN
  FOR gas := Zero TO Span DO
    WITH autocalib_var[ring][gas] DO IF active THEN BEGIN
      msg := msg + 'REMOTE CALIBRATING: ';
      IF (gas = Zero)
        THEN msg := msg + 'Zero'
        ELSE msg := msg + 'Span';
      END;
  StatusMsgGet := msg
  END;  {of 'StatusMsgGet'}
{-------------------------------------------------------------}

PROCEDURE apply (ring: INTEGER; which: GasAuto);
BEGIN
  WITH frmCalibAut,
       autocalib_var[ring][which], 
       list_addr_ptr[ring]^ DO BEGIN
    CASE which OF
      Zero: BEGIN
        IF irga_zero.exists THEN enable := CheckboxEnabledZero.Checked;
        inverted := CheckboxInvertedZero.Checked;
        timepulse := StrToFloat (EditTimepulseZero.Text);  
        IF (timepulse > timeactive) THEN timepulse := timeactive;
        timeactive := StrToFloat (EditTimeactiveZero.Text);  
        IF (timeactive > intvalmin) THEN timeactive := intvalmin;
        intvalmin := StrToFloat (EditIntvalminZero.Text);  
        IF (intvalmin > intvalmax) THEN intvalmin := intvalmax;
        intvalmax := StrToFloat (EditIntvalmaxZero.Text);  
        IF (intvalmax < intvalmin) THEN intvalmax := intvalmin;
        intvalmult := StrToFloat (EditIntvalmultZero.Text);  
        intval := StrToFloat (EditIntvalnowZero.Text);  
        END;  {Zero}
      Span: BEGIN 
{
        IF irga_zero.exists THEN enable := CheckboxEnabledSpan.Checked;
        inverted := CheckboxInvertedSpan.Checked;
        timepulse := StrToFloat (EditTimepulseSpan.Text);  
        IF (timepulse > timeactive) THEN timepulse := timeactive;
        timeactive := StrToFloat (EditTimeactiveSpan.Text);  
        IF (timeactive > intvalmin) THEN timeactive := intvalmin;
        intvalmin := StrToFloat (EditIntvalminSpan.Text);  
        IF (intvalmin > intvalmax) THEN intvalmin := intvalmax;
        intvalmax := StrToFloat (EditIntvalmaxSpan.Text);  
        IF (intvalmax < intvalmin) THEN intvalmax := intvalmin;
        intvalmult := StrToFloat (EditIntvalmultSpan.Text);  
        intval := StrToFloat (EditIntvalnowSpan.Text);  
}        
        END;  {Span}
      END;  {case}
    END;  {with}
  END;  {of procedure apply}
{-------------------------------------------------------------}

PROCEDURE TCalibAut.OnClickButton (Sender: TObject);
CONST nl = CHR(13)+CHR(10);
      nl2 = nl+nl;
VAR header, body: String;
BEGIN

  {Execute here on ApplyZero or ApplySpan button clicked}
  
  IF (Sender = btnApplyZero) OR (Sender = btnApplySpan) THEN BEGIN
    IF (Sender = btnApplyZero) THEN apply (ring_selected, Zero);
    IF (Sender = btnApplySpan) THEN apply (ring_selected, Span);
    END;  {of an apply button}
  
  {Execute here on OK button clicked}
  
  IF (Sender = btnOK) THEN BEGIN
    apply (ring_selected, Zero);
    apply (ring_selected, Span);
    Self.Release;
    frmCalibAut := NIL;
    END;  {of OK button}
  
  {Execute here on Cancel button clicked}
  
  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmCalibAut := NIL;
    END;  {of cancel button}
  
  {Execute here on Help button clicked}
  
  IF (Sender = btnHelp) THEN BEGIN
    header := 'SETUP FOR REMOTE IRGA CALIBRATION MODE';
    body := 
'This menu is used to view/change parameters related '+
'to automatic calibration.'+nl+ 
'There are individual pages for each ring selected with tab separators '+
'or the <+> and <-> keys.'+nl2+
'Note: parameter changes are NOT saved to disk, only memory.'+nl2+
'Enabled           Whether IRGA autocalibrations will be done.'+nl+
'Inverted          If TRUE, then activation signal is 0V level.'+nl+
'Pulse time (s)    Length of signal to start autocalibration.'+nl+
'Time active (s)   How long calibration takes; IRGA output ignored.'+nl+
'Minimum interval  Period between calibrations following reset.'+nl+
'Maximum interval  Asymptotic period between calibrations.'+nl+
'Multiplier        The interval increases by this factor each time.';
    frmHelp := TLblForm.Create (Application);
    frmHelp.LabelFontNameSet ('Courier New');
    frmHelp.Display (header, body);
    END;  {of help button}

  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TCalibAut.OnCreateForm (Sender: TObject);
{Set properties}
VAR ring: INTEGER;
    next_top: INTEGER;
BEGIN
  WITH TabControl1.Tabs DO FOR ring := 1 TO numrings DO BEGIN
    Add ('Ring '+rlabel[ring]);
    END;  
  {Vertical position of auto gas group controls}
    next_top := 25;
    CheckboxEnabledZero .Top := next_top;
    next_top := next_top+35;
    CheckboxInvertedZero.Top := next_top;
    next_top := next_top+35;
    LabelTimepulseZero  .Top := next_top;
    EditTimepulseZero   .Top := next_top;
    next_top := next_top+35;
    LabelTimeactiveZero .Top := next_top;
    EditTimeactiveZero  .Top := next_top;
    next_top := next_top+35;
    LabelIntvalminZero  .Top := next_top;
    EditIntvalminZero   .Top := next_top;
    next_top := next_top+35;
    LabelIntvalmultZero .Top := next_top;  
    EditIntvalmultZero  .Top := next_top;  
    next_top := next_top+35;
    LabelIntvalmaxZero  .Top := next_top; 
    EditIntvalmaxZero   .Top := next_top; 
    next_top := next_top+35;
    LabelIntvalnowZero  .Top := next_top; 
    EditIntvalnowZero   .Top := next_top; 
    next_top := next_top+35;
    btnApplyZero        .Top := next_top;
    btnTestZero         .Top := next_top;
  END;  {of procedure 'OnCreateForm'}
{-------------------------------------------------------------}

PROCEDURE TCalibAut.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmCalibAut := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TCalibAut.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmCalibAut := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

Initialization  
  
BEGIN
  ring_selected_last := 1;
  FOR gas := Zero TO Span DO FOR ring := 1 TO maxrings DO
    WITH autocalib_var[ring][gas] DO BEGIN
      {TEMP...
      IF gas = Zero THEN enable := irga_zero.exists;
      IF gas = Span THEN enable := irga_span.exists;
      ...}
      active   := FALSE;
      inverted := TRUE;  {for Swiss PP Systems}
      forceon  := FALSE;
      timepulse  :=   2.0;
      timeactive :=  20.0;
      intvalmin  :=  60.0;
      intvalmax  := 600.0;
      intval     := intvalmin;
      intvalmult :=   1.5;
      timebegan  := tint - timeactive;  {tinter1 MUST have been called already}
      END;
  END;  {Initialization}

Finalization

BEGIN
  END;

{of form unit CalibAut...}
END.
