UNIT LGSelect;
{$R+}
{
Line graph selection -- ring, file, etc.

v01.01 2003-01-09 Original
v01.02 2003-01-27 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.03 2003-01-31 Change GROUP_*, PERIOD_* to LG_GROUP_*, LG_PERIOD_*
v01.04 2003-01-31 Move LG_*_* from Implementation to Interface section
v01.05 2003-01-31 Transfer these global constants to LGSetup
v01.06 2003-03-14 btnGo: if ring=1 use LineGraf instead of COMDIS
v01.07 2003-03-15 OnClickRadio: SetFocus to ebRecord if Sender is rbHistoric
v01.08 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.09 2003-03-19 .dfm: make Go-bar width same as groups it applies to
v01.10 2003-05-10 btnGo: if ring=1 AND site=NC1 use LineGraf instead of COMDIS
v01.11 2003-05-25 OnDestroyForm: added back; frmLGSelect := NIL
v01.12 2003-05-27 Replace OnKeyPressForm by OnKeyDownForm
v01.13 2003-05-27 Add USES Classes for TShiftState
v01.14 2003-05-28 comd/Globals changes
v01.15 2003-06-08 in sfil[] replace 1 or 3 by FTLOGG or FTVARR
v01.16 2004-02-29 OnClickRadio: IF created AND (Sender = rbHistoric) ...
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QExtCtrls, QForms, QGraphics, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, ExtCtrls, Forms, Graphics, StdCtrls,
  Windows, Classes,
{$ENDIF}
  SysUtils, 
  LineGraf, LGSetup, LblForm,
  Globals,
  comdis, comd;

TYPE
  TfrmLGSelect = CLASS(TForm)
    gbRing: TGroupBox;
    gbFile: TGroupBox;
      rbLogg: TRadioButton;
      rbVarr: TRadioButton;
      rbAux: TRadioButton;
      rbSnap: TRadioButton;
      lblStatus: TLabel;
      lblStatusVal: TLabel;
      lblRecords: TLabel;
      lblRecordsVal: TLabel;
      lblSize: TLabel;
      lblSizeVal: TLabel;
      lblTStep: TLabel;
      lblTStepVal: TLabel;
    gbPeriod: TGroupBox;
      rbHistoric: TRadioButton;
      rbRecent: TRadioButton;
      rbCurrent: TRadioButton;
      lblHours: TLabel;
      ebHours: TEdit;
      lblRecord: TLabel;
      ebRecord: TEdit;
    gpShortcuts: TGroupBox;
      btnLogg: TButton;
      btnAux: TButton;
      rbQuikA: TRadioButton;
      rbQuikB: TRadioButton;
      rbQuikC: TRadioButton;
      rbQuikD: TRadioButton;
      rbQuikE: TRadioButton;
      rbQuikF: TRadioButton;
    btnCancel: TBitBtn;
    btnSetup: TBitBtn;
    btnHelp: TBitBtn;
    lblHot: TLabel;
    lbHot: TListBox;
    btnGo: TBitBtn;
    PROCEDURE Apply;
    PROCEDURE Refresh;
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnClickRadio (Sender: TObject);
    PROCEDURE OnKeyDownForm (Sender: TObject; VAR Key: Word; Shift: TShiftState);
  PRIVATE
    { Private declarations }
    rbRings: ARRAY [1..maxrings] OF TRadioButton;
  PUBLIC
    { Public declarations }
  END;

PROCEDURE Select (ring: INTEGER);
FUNCTION HotRingGet: INTEGER;

IMPLEMENTATION

VAR
  frmLGSelect: TfrmLGSelect;
  frmHelp: TLblForm;

  SRing:   INTEGER;
  SHot:    INTEGER;
  SGroup:  INTEGER;
  SPeriod: INTEGER;
  SHours:  Single;
  SRecord: Longint;
  SQuik:   Single;

  created: BOOLEAN;

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE debug (where, when: String);
BEGIN
  IF NOT ASSIGNED(frmHelp) THEN frmHelp := TLblForm.Create (Application);
  frmHelp.Display ('LGSelect: ' + where + ' ' + when, 
    'SRing   = ' + IntToStr(SRing)    +CHR(13)+CHR(10)+CHR(13)+CHR(10)+
    'SGroup  = ' + IntToStr(SGroup)   +CHR(13)+CHR(10)+CHR(13)+CHR(10)+
    'SPeriod = ' + IntToStr(SPeriod)  +CHR(13)+CHR(10)+CHR(13)+CHR(10)+
    'SHours  = ' + FloatToStr(SHours) +CHR(13)+CHR(10)+CHR(13)+CHR(10)+
    'SRecord = ' + IntToStr(SRecord)  +CHR(13)+CHR(10)+CHR(13)+CHR(10)+
    'SQuik   = ' + FloatToStr(SQuik)  +CHR(13)+CHR(10)+CHR(13)+CHR(10)+
    'SHot    = ' + IntToStr(SHot)
    );
  MessageBox (0, 'debug', 'LGSelect', MB_OK);
  frmHelp.Release;
  frmHelp := NIL;
  END;  {of procedure 'debug'}
{-------------------------------------------------------------}

FUNCTION HotRingGet: INTEGER;
BEGIN
  HotRingGet := SHot;
  END;  {of function HotRingGet}
{-------------------------------------------------------------}

PROCEDURE Select (ring: INTEGER);
{Come here when this menu item selected on a form}
BEGIN
  SRing := ring;
  IF NOT Assigned (frmLGSelect)
    THEN frmLGSelect := TfrmLGSelect.Create (Application)
    ELSE frmLGSelect.rbRings[SRing].Checked := TRUE;
  WITH frmLGSelect DO BEGIN
    Refresh;
    Show;
    SetFocus;
    WindowState := wsNormal;
    END;
  created := TRUE;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.Apply;
{Loads working static variables from form controls}
VAR ring: INTEGER;
BEGIN
  {debug ('Apply', 'BEFORE');}
  FOR ring := 1 TO numrings DO
    IF rbRings[ring].Checked THEN SRing := ring;
  IF rbLogg.Checked THEN SGroup := LG_GROUP_LOGG;
  IF rbVarr.Checked THEN SGroup := LG_GROUP_VARR;
  IF rbAux .Checked THEN SGroup := LG_GROUP_AUX;
  IF rbSnap.Checked THEN SGroup := LG_GROUP_SNAPSHOT;
  IF rbHistoric.Checked THEN SPeriod := LG_PERIOD_HISTORIC;
  IF rbRecent  .Checked THEN SPeriod := LG_PERIOD_RECENT;
  IF rbCurrent .Checked THEN SPeriod := LG_PERIOD_CURRENT;
  SHours  := StrToFloat (ebHours.Text);
  SRecord := StrToInt   (ebRecord.Text);
  IF rbQuikA.Checked THEN SQuik := rbQuikA.Tag;
  IF rbQuikB.Checked THEN SQuik := rbQuikB.Tag;
  IF rbQuikC.Checked THEN SQuik := rbQuikC.Tag;
  IF rbQuikD.Checked THEN SQuik := rbQuikD.Tag;
  IF rbQuikE.Checked THEN SQuik := rbQuikE.Tag;
  IF rbQuikF.Checked THEN SQuik := rbQuikF.Tag;
  SHot := lbHot.ItemIndex + 1;
  {debug ('Apply', 'AFTER');}
  END;  {of procedure 'Apply'}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.Refresh;
{Loads form controls from working static variables}
BEGIN
  ebHours.Text  := FloatToStrF (SHours, ffFixed, 3, 1);
  ebHours.Visible := (SPeriod <> LG_PERIOD_CURRENT);
  lblHours.Visible := ebHours.Visible;
  ebRecord.Text := IntToStr (SRecord);
  ebRecord.Visible := (SPeriod = LG_PERIOD_HISTORIC);
  lblRecord.Visible := ebRecord.Visible;
  lbHot.ItemIndex := SHot - 1;
  CASE SGroup OF
    LG_GROUP_LOGG,
    LG_GROUP_AUX:
      BEGIN
        IF sfil[SRing,FTLOGG] 
          THEN BEGIN
            lblStatusVal.Caption := 'Open';
            lblStatusVal.Font.Color := clGreen;
            END
          ELSE BEGIN
            lblStatusVal.Caption := 'Closed';
            lblStatusVal.Font.Color := clRed;
            END;
        IF (recnum[SRing,1] > 0)
          THEN BEGIN
            lblRecordsVal.Caption := IntToStr (recnum[SRing,1]);
            lblRecordsVal.Font.Color := clBlack;
            END
          ELSE BEGIN
            lblRecordsVal.Caption := 'EMPTY';
            lblRecordsVal.Font.Color := clRed;
            END;
        lblSizeVal.Caption := IntToStr (len[SRing,1]);
        lblTStepVal.Caption := FloatToStr (timestep[1]);
        END;
    LG_GROUP_VARR:
      BEGIN
        IF sfil[SRing,FTVARR] 
          THEN BEGIN
            lblStatusVal.Caption := 'Open';
            lblStatusVal.Font.Color := clGreen;
            END
          ELSE BEGIN
            lblStatusVal.Caption := 'Closed';
            lblStatusVal.Font.Color := clRed;
            END;
        IF (recnum[SRing,3] > 0)
          THEN BEGIN
            lblRecordsVal.Caption := IntToStr (recnum[SRing,3]);
            lblRecordsVal.Font.Color := clBlack;
            END
          ELSE BEGIN
            lblRecordsVal.Caption := 'EMPTY';
            lblRecordsVal.Font.Color := clRed;
            END;
        lblSizeVal.Caption := IntToStr (len[SRing,3]);
        lblTStepVal.Caption := FloatToStr (timestep[3]);
        END;
    LG_GROUP_SNAPSHOT:
      BEGIN
        lblStatusVal.Caption := 'Open';
        lblStatusVal.Font.Color := clBlack;
        lblRecordsVal.Caption := 'Not appl.';
        lblRecordsVal.Font.Color := clBlack;
        lblSizeVal.Caption := 'Not appl.';
        lblTStepVal.Caption := '2';  {hardwired since toggle used}
        END;
    END;  {case}
  END;  {of procedure 'Refresh'}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.OnCreateForm (Sender: TObject);
VAR ring: INTEGER;
BEGIN
  {Do not execute Apply when radio buttons initialized}
  created := FALSE;

  {Form gets to look at key strokes first for ring changing}
  KeyPreview := TRUE;

  {Create ring select radio buttons}
  FOR ring := 1 TO numrings DO BEGIN
    rbRings[ring] := TRadioButton.Create (Self);
    WITH rbRings[ring] DO BEGIN
      Parent := gbRing;
      Checked := (ring = SRing);
      Caption := rlabel[ring];
      Left := 10;
      Top := ring * 15 + 5;
      Width := 30;
      OnClick := OnClickRadio;
      END;
    END;
  
  {Create hot button list}
  lbHot.Clear;
  FOR ring := 1 TO numrings DO WITH lbHot DO BEGIN
    AddItem ('Ring ' + rlabel[ring], NIL);
    END;
  lbHot.Color := clWhite;

  rbLogg.Checked := (SGroup = LG_GROUP_LOGG);
  rbVarr.Checked := (SGroup = LG_GROUP_VARR);
  rbAux .Checked := (SGroup = LG_GROUP_AUX);
  rbSnap.Checked := (SGroup = LG_GROUP_SNAPSHOT);

  rbHistoric.Checked := (SPeriod = LG_PERIOD_HISTORIC);
  rbRecent  .Checked := (SPeriod = LG_PERIOD_RECENT);
  rbCurrent .Checked := (SPeriod = LG_PERIOD_CURRENT);

  WITH rbQuikA DO BEGIN
    Tag := 3;
    Caption := IntToStr (Tag) + ' hours';
    Checked := (ROUND(SQuik) = Tag);
    END;
  WITH rbQuikB DO BEGIN
    Tag := 6;
    Caption := IntToStr (Tag) + ' hours';
    Checked := (ROUND(SQuik) = Tag);
    END;
  WITH rbQuikC DO BEGIN
    Tag := 9;
    Caption := IntToStr (Tag) + ' hours';
    Checked := (ROUND(SQuik) = Tag);
    END;
  WITH rbQuikD DO BEGIN
    Tag := 12;
    Caption := IntToStr (Tag) + ' hours';
    Checked := (ROUND(SQuik) = Tag);
    END;
  WITH rbQuikE DO BEGIN
    Tag := 18;
    Caption := IntToStr (Tag) + ' hours';
    Checked := (ROUND(SQuik) = Tag);
    END;
  WITH rbQuikF DO BEGIN
    Tag := 24;
    Caption := IntToStr (Tag) + ' hours';
    Checked := (ROUND(SQuik) = Tag);
    END;

  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmLGSelect := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmLGSelect := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.OnClickButton (Sender: TObject);
{What to do when a button is clicked}
CONST nl  = CHR(13) + CHR(10);
      nl2 = nl + nl;
VAR header, body: String;
BEGIN

  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmLGSelect := NIL;
    END;

  IF (Sender = btnSetup) THEN BEGIN
    Apply;
    LGSetup.Select (SRing, SGroup);
    END;

  IF (Sender = btnHelp) THEN BEGIN
    header := 'Line graph selection help';
    body :=
'This screen will launch a new line graph window.' + nl2 +
'Select a ring from the left panel.' + nl2 +
'Select a file type from the next panel.' + nl +
'  LOGG files: [gas] averages, wind speed, proportional valve.' + nl +
'  VARR files: [gas] control PID algorithm.' + nl +
'  Auxiliary:  other variables in LOGG files, e.g. temperature.' + nl +
'  Snap shot:  selected 1-second data from LOGG && VARR.' + nl2 +
'Select a time period from the third panel.' + nl2 +
'  Historic:' + nl +
'    Graph variables from any records still stored on disk.' + nl +
'    The beginning record number is entered.' + nl +
'    Record = 0 shows most recent data.' + nl2 +
'  Recent:' + nl +
'    Graph variables from stored records in the last 3, 6, etc. hours.' + nl2 +
'  Current:' + nl +
'    Real time plotting of all samples.' + nl2 +
'Use SETUP button to change display parameters (range, position on' + nl +
'  screen, color, etc.) for the selected ring and file type set.' + nl2 +
'HOT BUTTON defines the ring associated with the Main window' + nl +
'  QuickGraph feature (LOGG file, Recent 3-hours).' + nl +
'  Select a ring and then click on it to latch the value..'
;
    frmHelp := TLblForm.Create (Application);
    frmHelp.Display (header, body);
    END;

  IF (Sender = btnGo) THEN BEGIN
    Apply;
    IF (SRing = 1) AND (site_id = 'NC1') {***TEMPORARY***}
    THEN LineGraf.Select (SRing, SGroup, SPeriod)
    ELSE comdis.graphics (SRing, SGroup, SPeriod, SHours, SRecord);
    END;

  IF (Sender = btnLogg) THEN BEGIN
    Apply;
    comdis.graphics (SRing, LG_GROUP_LOGG, LG_PERIOD_RECENT, SQuik, 0);
    END;

  IF (Sender = btnAux) THEN BEGIN
    Apply;
    comdis.graphics (SRing, LG_GROUP_AUX, LG_PERIOD_RECENT, SQuik, 0);
    END;

  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.OnClickRadio (Sender: TObject);
{What to do when a selected radio button is clicked}
BEGIN
  IF created THEN Apply;
  Refresh;
  IF created AND (Sender = rbHistoric) THEN ebRecord.SetFocus;
  END;  {of procedure OnClickRadio}
{-------------------------------------------------------------}

PROCEDURE TfrmLGSelect.OnKeyDownForm (
  Sender: TObject; VAR Key: Word; Shift: TShiftState);
{Keyboard change ring.  
 A..F not implemented directly due to possible conflict.
 However : ; < = > ? might work for these!
 }
BEGIN
  IF (Key = VK_SUBTRACT) OR (Key = 189) THEN BEGIN
    DEC (SRing);
    IF (SRing < 1) THEN SRing := numrings;
    rbRings[SRing].Checked := TRUE;
    END;
  IF (Key = VK_ADD) OR (Key = 187) THEN BEGIN
    INC (SRing);
    IF (SRing > numrings) THEN SRing := 1;
    rbRings[SRing].Checked := TRUE;
    END;
  {Number keys not active if any numeric .Text control has focus}
  IF (ActiveControl <> ebHours) AND (ActiveControl <> ebRecord) THEN
    IF (((Key And $FF)-ORD('0')) IN [1..numrings]) THEN BEGIN
      SRing := ((Key And $FF)-ORD('0'));
      rbRings[SRing].Checked := TRUE;
      END;
  END;  {of event handling procedure OnKeyDownForm}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  SHot := 2; {first NC fumigation ring}
  SGroup := LG_GROUP_LOGG;
  SPeriod := LG_PERIOD_RECENT;
  SHours := 3.0;
  SRecord := 0;
  SQuik  := 3.0;
  END;

FINALIZATION

BEGIN
  END;

{of form unit LGSelect...} END.
