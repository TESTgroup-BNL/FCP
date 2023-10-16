Unit Alarms;
{
View list of error and maybe clear alarm for this ring

v01.01 2002-11-16 Original starting with Status.pas
v01.02 2002-12-02 Some watchdog related stuff moved to new Watchdog.pas
                  alt-T Enter ETAS encl_temp_alarm_set[ring] not implemented
v01.03 2002-12-08 Modifications for RingBar ChangeRing feature
v01.04 2002-12-17 Initialization: 1..maxrings (was 1..numrings!)
                  Initialization: move errseq[][] init here from comd
                  AlarmMsgGet: moved here from comd
                  errcheck, errset, errreset moved here from comp
v01.05 2003-01-05 Changes related to the new TLPF object
                  OnClickForm: new for LPF ShowDump
v01.06 2003-01-10 OnCreateForm: set KeyPreview = TRUE
v01.07 2003-01-26 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.08 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.09 2003-03-18 Use standardized Cancel button (was btnClose: TButton)
v01.10 2003-03-19 OnCloseForm: replace Self := by frmAlarm[FRing] := NIL
v01.11 2003-05-25 OnDestroyForm: added back; frmAlarm[FRing] := NIL
v01.12 2003-05-27 Replace OnKeyPressForm by OnKeyDownForm
v01.13 2003-05-27 Add global procedure FirstAlarmPage
v01.14 2003-05-28 Linux/Types and MSWindows/Classes
                  comd/Globals changes
v01.15 2003-05-31 Uses NetLog.GetLastError
v01.16 2003-06-15 PVerr, GASerr, WDstuck Value -> cr HandPoint (LPF objs)
v01.17 2004-12-01 added AlarmLines[ 0].Sensor := pv_response.exists;
                  added AlarmLines[12].Sensor := wind_direction.exists;
v01.18 2005-05-04 Implementation/Uses: Add LblForm
                  TfrmAlarms: add Help BitBtn
                  help: new
                  column heading labels added
v01.19 2005-05-05 errcheck/temp[3]: check now if AZ2 or WI1
v01.20 2006-09-24 OnClickForm: enclosure temp alarm set change feature
                  OnCreateForm: EnclTempAlarmSet Value > cr HandPoint
                  help: revised
                  IMPLEMENTATION USES add Dialogs
                  .dfm: Autoscroll = FALSE
v01.21 2007-06-15 OnCreateForm: ShowHint := TRUE
                  OnCreateForm: For enclosure temperature (11) Hint :=
v01.22 2011-11-03 errcheck: change incorrect wind_speed.offset to .offscale
                  errcheck: in same statement use wspeed instead of awspeed
v01.23 2012-08-19 errseq: add .exists to this record
                  errcheck: add setting of errseq[][].exists every call
                  Select: for AlarmLines[alarm].Sensor use errseq[][].exists
v01.24 2012-08-19 Implementation Uses: add DataComm
                  errcheck: deal with very slowly changing WD from files
v01.25 2013-12-18 errset: add Else to Case setting msg := ERRTYPE I
                  errset: multimsg --> multimsg + IntToStr(code)
v01.26 2013-12-19 errcheck: add 'IF wind_direction.exists THEN' before test
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QControls, QExtCtrls, QForms, QGraphics, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Controls, ExtCtrls, Forms, Graphics, StdCtrls,
  Windows, Messages, Classes,
{$ENDIF}
  SysUtils,
  CalibMan, NetLog, RingBar, Heart, Watchdog, Connect,
  comd, Globals;

CONST
  alarms_maxbit = 13;

TYPE
  TAlarmLine = class(TWinControl)
      LED: TShape;
      Description,
      Value,
      Counts,
      MinToAlarm,
      MinToDialout: TLabel;
    PRIVATE
      Sensor : BOOLEAN;  {Exists or not}
      END;

  TfrmAlarms = class(TForm)
      cbAudible: TCheckBox;
      cbWatchdog: TCheckBox;
      btnHelp:   TBitBtn;
      btnReset:  TButton;
      btnCancel: TBitBtn;
      lblEHeader,
      lblTHeader,
      lblDHeader: TLabel;
      PROCEDURE OnClickForm (Sender: TObject);
      PROCEDURE OnCreateForm (Sender: TObject);
      PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
      PROCEDURE OnDestroyForm (Sender: TObject);
      PROCEDURE OnClickTest (Sender: TObject);
      PROCEDURE OnKeyDownForm (Sender: TObject; VAR Key: Word; Shift: TShiftState);
    PRIVATE
      { Private declarations }
      FRing: INTEGER;
      rb: TRingBar;    {ring bar}
      hb: THeartBeat;  {heart beat}
      AlarmLines: ARRAY [0..alarms_maxbit] OF TAlarmLine;
    PUBLIC
      { Public declarations }
    end;

TYPE
  errec = RECORD
    code: Word;
    errtime: String[8];
    msg: String;
    count: Longint;
    END;

VAR
  frmAlarms: ARRAY [1..maxrings] OF TfrmAlarms;

  timeerrint, timeerrtest, timeerrlast: Single;

  err,
  errlatch: ARRAY [1..maxrings] OF errec;  {alarm information}

  errseq: ARRAY [1..maxrings] OF ARRAY [0..15] OF RECORD
    count: Longint;
    alarm_count,
    dialout_count: INTEGER;
    exists:        BOOLEAN;
    END;

PROCEDURE FirstAlarmPage;
PROCEDURE Select      (ring: INTEGER);
PROCEDURE UpdateIt    (ring: INTEGER);
PROCEDURE HeartBeat   (ring: INTEGER; which: BOOLEAN);
FUNCTION  AlarmMsgGet (ring: INTEGER): String;
FUNCTION  TestAudibleGet: BOOLEAN;

PROCEDURE errclear (ring: INTEGER);
PROCEDURE errcheck;
PROCEDURE errset (ring, errtype: INTEGER);
PROCEDURE errreset (ring, errtype: INTEGER);

Implementation

{$R *.dfm}

USES LblForm, Dialogs, DataComm;

VAR
  audible_test: BOOLEAN;

  i, j: INTEGER;
{-------------------------------------------------------------}

PROCEDURE errclear (ring: INTEGER);
{Clear the  error code and other vars for ring specified}
VAR j: INTEGER;
BEGIN
  timeerrint := 120.0;  {integration period}
  timeerrtest:=  59.0;  {test interval}
  timeerrlast := tint;  {non-synchronous with other periods}
  pverr  [ring].Integral := 0.0;
  conterr[ring].Integral := 0.0;
  wdstuck[ring].Integral := 1.0;
  WITH err[ring] DO BEGIN
    code := 0;
    errtime := '';
    msg := '';
    END;
  errlatch[ring] := err[ring];
  FOR j := 0 TO alarms_maxbit DO errseq[ring][j].count := 0;
  END;  {of procedure 'errclear'}
{-------------------------------------------------------------}

PROCEDURE errcheck;
{Check and possibly set error conditions.}
VAR no: INTEGER;
    higher_temp: float;  {of temp2 or temp3}
    wind_direction_stuck_threshold: float;

PROCEDURE bittest (bitdata: Word; sensor: daqc_addr; ring, errnumber: INTEGER);
(* If sensor exists, make sure its bit is on; otherwise raise error flag. *)
BEGIN
  IF sensor.exists THEN 
    IF (bitdata And ($1 Shl sensor.channel) = 0)
      THEN errset (ring, errnumber)
      ELSE errseq[ring][errnumber].count := 0;
  END;  {of local procedure 'bittest'}

BEGIN
  FOR no := 1 TO numrings DO IF Connect.StateGet(no) THEN BEGIN

    {Fill the errseq[][].exists}
    WITH list_addr_ptr[no]^ DO BEGIN
    errseq[no][ 0].exists := pv_response.exists;
    errseq[no][ 1].exists := TRUE;
    errseq[no][ 2].exists := NOT (enrich_mode[no]=0);
    errseq[no][ 3].exists := run_mode;
    errseq[no][ 4].exists := fan_rotation_fumi.exists;
    errseq[no][ 5].exists := fan_rotation_cont.exists;
    errseq[no][ 6].exists := gas_pressure.exists;
    errseq[no][ 7].exists := ps01.exists;
    errseq[no][ 8].exists := ps02.exists;
    errseq[no][ 9].exists := ps03.exists;
    errseq[no][10].exists := ps04.exists;
    errseq[no][11].exists := temp_enclosure.exists;
    errseq[no][12].exists := wind_direction.exists;
    errseq[no][13].exists := netpath <> 'NONE';
    END;

    IF runon[no] THEN BEGIN
      IF pverr[no].Integral   > falarm[no] 
        THEN errset (no,  0) 
        ELSE errreset (no,  0);
      IF conterr[no].Integral > calarm[no] 
        THEN errset (no,  1) 
        ELSE errreset (no,  1);
{***  IF conterr[no] > calarm_bracket[no]*(gcset[no]-calarm_base[no])
      This is the invariant form, i.e. window will scale as gcset is
      changed, but it is not very operator friendly.  Replace by one
      absolute number as for falarm.  Operator should know that if
      he e.g. doubles enrichment then this window should also be
      doubled.}
      IF (enrich_mode[no] IN [1..2]) AND 
         amb_in_default AND
         (NOT AmbientMultiportCalibratingGet)
           THEN errset (no, 2) ELSE errreset (no, 2);

      wind_direction_stuck_threshold := 0.50;
      {Presume updates from file are only occasional and integers.
       Then wind direction stuck indicated by asymptotic zero.}
      WITH list_addr_ptr[no]^.wind_direction DO
        IF (range = 400) THEN  {this is a LineIn device}
          IF DataComm.Ports[address].switch = 3 {this is a file}
            THEN wind_direction_stuck_threshold := 0.01;

      IF list_addr_ptr[no]^.wind_direction.exists THEN
      IF windup[no] OR
         (wspeed[no] < 0.5*list_addr_ptr[no]^.wind_speed.offscale)
           THEN IF (wdstuck[no].Integral <= wind_direction_stuck_threshold)
                  THEN errset (no, 12) 
                  ELSE errreset (no, 12);
      END;

    IF comm_err[no] 
      THEN errset (no,  3) ELSE errreset (no,  3);
    IF (NetLog.GetLastError(no) > 0)  {errno -1 is not really an error}
      THEN errset (no, 13) ELSE errreset (no, 13);

    higher_temp := temp2[no];
    IF ((site_id = 'AZ2') OR (site_id = 'WI1')) AND
       (temp3[no] > higher_temp) THEN higher_temp := temp3[no];
    IF (higher_temp > encl_temp_alarm_set[no]) THEN errset (no, 11) 
                                               ELSE errreset (no, 11);

    IF runon[no] THEN WITH list_addr_ptr[no]^ DO BEGIN
      bittest (digital_in_fumi[no], fan_rotation_fumi, no,  4);
      bittest (digital_in_cntl[no], fan_rotation_cont, no,  5);
      bittest (digital_in_fumi[no], gas_pressure, no,  6);
      END;
    {!!!fix this mess sometime!!!}
    WITH list_addr_ptr[no]^ DO BEGIN
      IF fan_onoff_fumi.address = ps01.address
        THEN bittest (digital_in_fumi[no], ps01, no,  7);
      IF fan_onoff_fumi.address = ps02.address 
        THEN bittest (digital_in_fumi[no], ps02, no,  8);
      IF fan_onoff_fumi.address = ps03.address 
        THEN bittest (digital_in_fumi[no], ps03, no,  9);
      IF fan_onoff_fumi.address = ps04.address 
        THEN bittest (digital_in_fumi[no], ps04, no, 10);
      END;
    WITH list_addr_ptr[no]^ DO BEGIN
      IF fan_onoff_cont.address = ps01.address 
        THEN bittest (digital_in_cntl[no], ps01, no,  7);
      IF fan_onoff_cont.address = ps02.address 
        THEN bittest (digital_in_cntl[no], ps02, no,  8);
      IF fan_onoff_cont.address = ps03.address 
        THEN bittest (digital_in_cntl[no], ps03, no,  9);
      IF fan_onoff_cont.address = ps04.address 
        THEN bittest (digital_in_cntl[no], ps04, no, 10);
      END;
    END;
  timeerrlast := tint;
  END;  {of procedure 'errcheck'}
{------------------------------------------------------------}

PROCEDURE errset (ring, errtype: INTEGER);
{Set the error code and other vars for ring specified
 when certain type of error detected.}
CONST multimsg = 'Multiple errors';
VAR   mask: Word;
BEGIN
  WITH errseq[ring][errtype] DO BEGIN
    INC (count);
    IF (count > alarm_count) THEN BEGIN
      mask := ($1 Shl errtype);
      WITH err[ring], list_addr_ptr[ring]^ DO
        IF (code And mask) = 0 THEN BEGIN
          code := code Or mask;
          IF errtime = '' THEN errtime := comd.time;
          IF msg <> ''
            THEN msg := multimsg + '  code = ' + IntToStr(code)
            ELSE CASE errtype OF
               0: msg := 'Proportional valve';
               1: msg := 'Gas concentration';
               2: msg := 'No ambient signal';
               3: msg := 'DAQC communications';
               4: msg := 'Fan rotation -- treatment';
               5: msg := 'Fan rotation -- control';
               6: msg := 'Gas supply';
               7: msg := ps01.label_name;
               8: msg := ps02.label_name;
               9: msg := ps03.label_name;
              10: msg := ps04.label_name;
              11: msg := 'Enclosure temperature(s)';
              12: msg := 'Wind direction stuck';
              13: msg := 'Logging to network';
            Else  msg := 'ERRTYPE ' + IntToStr(errtype);
              END;  {of case}
          END;
      END;  {of if count}
    END;  {of with}
  errlatch[ring] := err[ring];
  END;  {of procedure 'errset'}
{------------------------------------------------------------}

PROCEDURE errreset (ring, errtype: INTEGER);
{Reset the error sequence count for ring and type of error specified.}
BEGIN
  WITH errseq[ring][errtype] DO count := 0;
  END;  {of procedure 'errreset'}
{------------------------------------------------------------}

PROCEDURE TfrmAlarms.OnCreateForm (Sender: TObject);
CONST StartLeft = 15;
      StartTop  = 45;
      HHeight   = 15;
VAR alarm: INTEGER;
BEGIN
  {Let form preview key strokes}
  KeyPreview := TRUE;

  {Enable "Help Hints"}
  ShowHint := TRUE;

  {Gray out the test check box if there is no watchdog}
  cbWatchdog.Enabled := Watchdog.Exists;

  {Create the information lines for each error alarm type}
  FOR alarm := 0 TO alarms_maxbit DO BEGIN
    AlarmLines[alarm] := TAlarmLine.Create (Self);
    WITH AlarmLines[alarm] DO BEGIN
      Parent := Self;
      LED := TShape.Create (Self);
      WITH LED DO BEGIN
        Parent := Self;
        Left := StartLeft;
        Top := StartTop + alarm * HHeight + HHeight DIV 4;
        Height := 3*HHeight DIV 4;
        Width  := 3*HHeight DIV 4;
        Shape := stRoundSquare;
        Brush.Color := clBlack;
        END;
      Description := TLabel.Create (Self);
      WITH Description DO BEGIN
        Parent := Self;
        Left := LED.Left + HHeight;
        Top := StartTop + alarm * HHeight;
        Width := 400;
        {Caption filled in during Select since ring specific PS's}
        END;
      Value := TLabel.Create (Self);
      WITH Value DO BEGIN
        Parent := Self;
        Left := Description.Left + Description.Width;
        Top := Description.Top;
        Width := 50;
        {PV 0, [gas] 1, and WDstuck 12 values are LPF objects}
        {EnclTempAlarmSet 11 has an InputBox}
        IF (alarm IN [0, 1, 12, 11]) THEN Cursor := crHandPoint;
        IF (alarm = 11) THEN Hint := 'Click to temporarily change alarm limit';
        OnClick := OnClickForm;
        END;
      Counts := TLabel.Create (Self);
      WITH Counts DO BEGIN
        Parent := Self;
        Left := Value.Left + Value.Width;
        Top := Description.Top;
        Width := 50;
        END;
      MinToAlarm := TLabel.Create (Self);
      WITH MinToAlarm DO BEGIN
        Parent := Self;
        Left := Counts.Left + Counts.Width;
        Top := Description.Top;
        Width := 50;
        END;
      MinToDialout := TLabel.Create (Self);
      WITH MinToDialout DO BEGIN
        Parent := Self;
        Left := MinToAlarm.Left + MinToAlarm.Width;
        Top := Description.Top;
        Width := 50;
        END;
      END;
    END;

  {Column heading positioning}
  lblEHeader.Top  := AlarmLines[0].Counts.Top - lblEHeader.Height;
  lblEHeader.Left := AlarmLines[0].Counts.Left;
  lblTHeader.Top  := lblEHeader.Top;
  lblTHeader.Left := AlarmLines[0].MinToAlarm.Left;
  lblDHeader.Top  := lblEHeader.Top;
  lblDHeader.Left := AlarmLines[0].MinToDialout.Left;

  {Adjust form window based on location of last dialout minimum}
  WITH AlarmLines[alarms_maxbit].MinToDialout DO BEGIN
    btnCancel.Top  := Top + Height + 15;
    btnCancel.Left := Left + Width - btnCancel.Width;
    btnReset.Top   := btnCancel.Top;
    btnReset.Left  := btnCancel.Left - btnReset.Width - 8;
    btnHelp.Top    := btnCancel.Top;
    btnHelp.Left   := btnReset.Left - btnHelp.Width - 8;
    cbWatchdog.Top := btnCancel.Top;
    cbAudible.Top  := btnCancel.Top;
    Self.Height := btnCancel.Top + btnCancel.Height + 48;
    Self.Width  := btnCancel.Left + btnCancel.Width + 16;
    END;
  
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TfrmAlarms.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmAlarms[FRing] := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TfrmAlarms.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmAlarms[FRing] := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TfrmAlarms.OnClickForm (Sender: TObject);
CONST nl  = CHR(13) + CHR(10);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
{For showing the low pass filter dump forms and InputBox's}
BEGIN
  IF (Sender = AlarmLines[ 0].Value) THEN  {Prop valve error}
    pverr[FRing].ShowDump;
  IF (Sender = AlarmLines[ 1].Value) THEN  {Concentration error}
    conterr[FRing].ShowDump;
  IF (Sender = AlarmLines[12].Value) THEN  {Wind direction stuck error}
    wdstuck[FRing].ShowDump;
  IF (Sender = AlarmLines[11].Value) THEN  {Encl temp alarm set}
    Try
      encl_temp_alarm_set[FRing] :=
        StrToFloat (InputBox (
          'EnclTempAlarmSet - Ring ' + rlabel[FRing],
          'CHANGE ENCLOSURE TEMPERATURE ALARM SET POINT ' +
          'FOR RING ' + rlabel[FRing] + nl2 +
          'Warning:  This dialog box is modal.' + nl2 +
          'Sampling, control, and watchdog petting' + nl +
          'are suspended.' + nl2 +
          'Click OK or Cancel, or Return as soon as possible.' + nl2 +
          'Note:  Changes are not saved to disk.' + nl2 +
          'Default value will be restored if program restarts.' + nl2,
          FloatToStr (encl_temp_alarm_set[FRing])));
    Except
      On E: EConvertError DO
        ShowMessage (E.ClassName + nl2 + E.Message + nl2 +
                     'Click OK or Return now!');
    END; {try..except}
  END;  {of procedure OnClickForm}
{-------------------------------------------------------------}

PROCEDURE help;
CONST nl  = CHR(13) + CHR(10);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR frmHelp: TLblForm;
BEGIN
  frmHelp := TLblForm.Create(Application);
  frmHelp.Display ('RingBar > Alarms > Help', '');
  frmHelp.BodyAppend (
'Errors (E):' + nl2 +
'Error flags are checked about once per minute.' + nl +
'This column shows the number of CONSECUTIVE minutes that' + nl +
'this error flag has been raised.' + nl2 +
'Trailer (T):' + nl2 +
'Trailer audible alarm for this error will be sounded when' + nl +
'the consecutive error counter (E) exceeds this value.' + nl2 +
'Dialout (D):' + nl2 +
'Watchdog dialout to offsite phones will be initiated when' + nl +
'the consecutive error counter (E) exceeds this value.' + nl +
'A value of -1 means dialout for this error type is disabled.' + nl2 +
'Column T and D values can not be changed while program is running.' + nl +
'See CFG.TXT concerning setting of T,D pairs in line type 47' + nl +
'(one for each ring) in the configuration file.' + nl2 +
'Enclosure temperature(s) alarm:' + nl2 +
'To change alarm set point for selected ring, click value.' + nl +
'Note WARNING and NOTE messages!' + nl2 +
'Notes to programmers:' + nl2 +
'Proportional valve error, gas concentration error, and wind stuck' + nl +
'are low pass filter objects.  Click on value to see fields.' + nl2 +
'');
  END;  {of procedure 'help'}
{-------------------------------------------------------------}

PROCEDURE TfrmAlarms.OnClickTest (Sender: TObject);
{Handle change in test check boxes and button clicks}
BEGIN
  IF (Sender = btnHelp) THEN
    help;
  IF (Sender = btnReset) THEN
    errclear (FRing);
  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmAlarms[FRing] := NIL;
    END;
  IF (Sender = cbAudible) THEN
    audible_test := cbAudible.Checked;
  IF (Sender = cbWatchdog) THEN
    Watchdog.TestSet (cbWatchdog.Checked);
  END;  {of procedure OnClickTest}
{-------------------------------------------------------------}

PROCEDURE FirstAlarmPage;
{Display alarm page for first ring in alarm, if any}
VAR ring, ring_selected: INTEGER;
BEGIN
  ring_selected := -1;
  FOR ring := 1 TO numrings DO
    IF (errlatch[ring].code <> 0) AND (ring_selected < 0) THEN
      ring_selected := ring;
  IF (ring_selected > 0) THEN Select (ring_selected);
  END;  {of procedure FirstAlarmPage}
{-------------------------------------------------------------}

PROCEDURE Select (ring: INTEGER);
{Come here when this menu item selected on a form}
VAR alarm: INTEGER;
BEGIN
  IF NOT Assigned (frmAlarms[ring]) THEN BEGIN
    frmAlarms[ring] := TfrmAlarms.Create (Application);
    WITH frmAlarms[ring] DO BEGIN
      {Create and position (, , Left, Top) the heart beat}
      Heart.Make (hb, frmAlarms[ring], 0, 0);
      {Create and position ring bar}
      RingBar.Make (rb, frmAlarms[ring], numrings,
                    hb.Right, 0, 60, 25, 0);
      END;
    END;
  WITH frmAlarms[ring] DO BEGIN
    FRing := ring;
    rb.ButtonDown (ring);
    Caption :=
      'RingBar > Alarms: Error Condition Alarm Listing & Clearing for Ring ' +
       rlabel[ring];
    Show;
    SetFocus;
    WindowState := wsNormal;
    END;

  WITH frmAlarms[ring], list_addr_ptr[ring]^ DO BEGIN

    {Get whether or not the variable's sensor exists or not}
    FOR alarm := 0 TO alarms_maxbit DO
      AlarmLines[alarm].Sensor := errseq[ring][alarm].exists;

    {Get power supply descriptions as per configuration file}
    AlarmLines[ 0].Description.Caption
      := 'Proportional valve control and response disagreement';
    AlarmLines[ 1].Description.Caption
      := 'Gas concentration has been off target too far for too long';
    AlarmLines[ 2].Description.Caption
      := 'Program can not find a good ambient signal';
    AlarmLines[ 3].Description.Caption
      := 'Data acquisition and control communications error';
    AlarmLines[ 4].Description.Caption
      := 'Fan not rotating (treatment)';
    AlarmLines[ 5].Description.Caption
      := 'Fan not rotating (control)';
    AlarmLines[ 6].Description.Caption
      := 'Gas supply pressure low';
    AlarmLines[ 7].Description.Caption
      := ps01.label_name;
    AlarmLines[ 8].Description.Caption
      := ps02.label_name;
    AlarmLines[ 9].Description.Caption
      := ps03.label_name;
    AlarmLines[10].Description.Caption
      := ps04.label_name;
    AlarmLines[11].Description.Caption
      := 'Enclosure temperature versus ';
    AlarmLines[12].Description.Caption
      := 'Wind direction stuck';
    AlarmLines[13].Description.Caption
      := 'Error writing LOGG.NET file';
    END;

  UpdateIt (ring);
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TfrmAlarms.OnKeyDownForm (
  Sender: TObject; VAR Key: Word; Shift: TShiftState);
BEGIN
  {MessageBox (0, PCHAR(String(CHR(Key))), 'Alarms', MB_OK);}
  IF (Key = VK_ESCAPE)
    THEN BEGIN Self.Release; frmAlarms[FRing] := NIL; END
    ELSE IF (Key = VK_SUBTRACT) OR (Key = 189)
      THEN rb.ChangeRing (FRing-1)
      ELSE IF (Key = VK_ADD) OR (Key = 187)
        THEN rb.ChangeRing (FRing+1)
        ELSE rb.Invoke (Key, Shift);
  END;  {of event handling procedure OnKeyDownForm}
{-------------------------------------------------------------}

PROCEDURE UpdateIt (ring: INTEGER);
{Come here at end of every sample/control period}
VAR alarm: INTEGER;
    mask: Word;
BEGIN
  IF Assigned (frmAlarms[ring]) THEN
  IF (frmAlarms[ring].WindowState <> wsMinimized) THEN
  WITH frmAlarms[ring] DO BEGIN

    cbAudible.Checked := audible_test;
    cbWatchdog.Checked := Watchdog.TestGet;

    {Update the alarm lines}
    mask := $1;
    FOR alarm := 0 TO alarms_maxbit DO WITH AlarmLines[alarm] DO BEGIN
      IF Sensor
        THEN BEGIN
               LED.Visible := TRUE;
               Description.Enabled := TRUE;
               IF (errlatch[ring].code AND mask) <> 0
                 THEN IF RingColorToggleMasterGet
                   THEN LED.Brush.Color := clWhite
                   ELSE LED.Brush.Color := clRed
                 ELSE LED.Brush.Color := clLime;
               END
        ELSE BEGIN
               LED.Visible := FALSE;
               Description.Enabled := FALSE;
               END;
      IF (alarm =  0) THEN Value.Caption :=
        FloatToStrF(pverr[ring].Integral, ffFixed, 7, 1);
      IF (alarm =  1) THEN Value.Caption :=
        FloatToStrF(conterr[ring].Integral, ffFixed, 7, 1);
      IF (alarm = 11) THEN Value.Caption :=
        FloatToStrF(encl_temp_alarm_set[ring], ffFixed, 7, 1);
      IF (alarm = 12) THEN Value.Caption :=
        FloatToStrF(wdstuck[ring].Integral, ffFixed, 7, 1);
      WITH errseq[ring][alarm] DO BEGIN
        Counts.Caption := IntToStr(count);
        MinToAlarm.Caption := IntToStr(alarm_count);
        MinToDialout.Caption := IntToStr(dialout_count);
        END;
      mask := mask Shl 1;
      END;

    {Ring bar color codes}
    rb.UpdateIt;

    END;  {object Assigned}
  END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

PROCEDURE HeartBeat (ring: INTEGER; which: BOOLEAN);
BEGIN
  IF Assigned (frmAlarms[ring]) THEN
  IF (frmAlarms[ring].WindowState <> wsMinimized) THEN
  IF Assigned(frmAlarms[ring].hb) THEN
    Heart.Pick (frmAlarms[ring].hb, which);
  END;  {of procedure HeartBeat}
{-------------------------------------------------------------}

FUNCTION AlarmMsgGet (ring: INTEGER): String;
BEGIN
  WITH errlatch[ring] DO
    IF code <> 0 THEN
      AlarmMsgGet :=
        'ALARM: ' + IntToStr(code) + ' ' + errtime + ' ' + msg + '  ';
  END;  {function 'AlarmMsgGet'}
{-------------------------------------------------------------}

FUNCTION TestAudibleGet: BOOLEAN;
BEGIN
  TestAudibleGet := audible_test;
  END;  {of procedure TestAudibleGet}
{-------------------------------------------------------------}

Initialization

BEGIN
  audible_test := FALSE;

  FOR i := 1 TO maxrings DO BEGIN
    FOR j := 0 TO 15 DO WITH errseq[i][j] DO BEGIN
      count := 0;
      alarm_count   :=  0;  {alarm on first occurence}
      dialout_count := -1;  {do not use for dialout}
      END;
    errclear (i);
    END;

  END;

Finalization

BEGIN
  END;

{of form unit Alarms...} END.
