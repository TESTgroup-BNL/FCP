Unit MPSample;
{$R+  Range checking ON}
{
Multiport sampler show configuration and data flow window.
Initialize hardware, read and save measurements at nodes.
(Formerly known as the "ambient multiport".)

v01.01 2004-07-07 Original from gutted copy of Calibman.pas 2003-05-28
       2004-07-09 Copy in code from ambmp.pas and some modifications
       2004-07-15 ambient_mp: move setting tint_good here from comp.sampling
       2004-07-22 delete all rep and group related vars
       2004-07-22 delete valve=99 (use previous node measurement) feature
       2004-07-22 ambient_hardware_rec: add vars timeout_sec and timedout
       2004-07-27 node number range changed from 1..16 to 0..15
v01.02 2004-08-01 ambient_mp_init: change 9 licor/licor6262_* refs to licor_*
       2004-08-01 ambient_mp_init: change (channel = 21) to IN [21..22])
       2004-08-02 count_rest=50, but see licor/licor_init
v01.03 2004-12-02 ambmp_hardware_var: now DATA, was HEAP
                  remove count_rest=  see Prog NB 2, p. 128, 2004-08-02
                  Solenoid/valve board address separated from device_d, incl.
                  node_addr_hex, node_addr_word: new vars
                  print_config, ambient_mp_*: revised accordingly
v01.04 2004-12-05 ambmp_hardware_init: add power_up_clears (4x)
v01.05 2005-01-06 UpdateIt: IRGA caption red when reading not "good"
v01.06 2006-04-29 Implementation Uses: remove tp5utils
v01.07 2006-09-22 ambient_mp_config:
                    Delete SR: TSearchRec
                    Replace by Globals.searchrec_def
                    Add FindClose() statement
v02.01 2009-08-15 ambient_hardware_rec: delete element "socket"
                  ambient_hardware_rec: delete element "eq_ring"
                  ambient_multiport_init: comm_start --> DataComm.PortOpen
                  Replacement of socket by DataComm.* needed throughout
v02.02 2009-11-05 Change TCPIPRec to IPRec
v02.03 2009-11-19 ambient_mp_init: add if exists then to 3 power up clears
v03.01 2012-02-02 ambient_mp_config: replace coms.get_port by DataComm.PortGet
v03.02 2012-08-26 objMPGroup:   changed from Private to Public
                  OnCreateForm: create ALL ambmp_nodes_max objMPGroup array elements
                    for showing of ambient base raw data for cases 1 and 2
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
  ambmp_nodes_max = 16;

TYPE
  clsRingGroup = class (TPanel)
    ringlabel, fumigation, control, ambient: TLabel;
    END;

TYPE
  clsMPGroup = class (TPanel)
    nodeno, channel, purge, sample, flow, minflow,
    value, lastgood: TLabel;
    END;

TYPE
  TMPSample = class(TForm)
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    btnShowConfig: TButton;
    gbRing: TGroupBox;
      lblRingHeader: TLabel;
      lblFumigationHeader: TLabel;
      lblControlHeader: TLabel;
      lblAmbientHeader: TLabel;
    gbMP: TGroupBox;
      lblNodeHeader: TLabel;
      lblChanHeader: TLabel;
      lblPurgeHeader: TLabel;
      lblSampleHeader: TLabel;
      lblMinFlowHeader: TLabel;
      lblFlowHeader: TLabel;
      lblValueHeader: TLabel;
      lblLastGood1Header: TLabel;
      lblLastGood2Header: TLabel;
    lblIRGA: TLabel;
    lblGood: TLabel;
    lblDI: TLabel;
    lblCommErr: TLabel;
    lblTemp: TLabel;
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
  Private
    { Private declarations }
    objRingGroup: ARRAY [1..maxrings] OF clsRingGroup;
  Public
    { Public declarations }
    objMPGroup: ARRAY [0..ambmp_nodes_max-1] OF clsMPGroup;
  END;

VAR frmMPSample: TMPSample;

TYPE
  ambmp_hardware_rec = RECORD
                         exists:          BOOLEAN;
                         cfg_file_name,
                         cfg_file_date,
                         cfg_file_time,
                         cfg_file_size:   String;
                         cfg_file_handle: TEXT;
                         device_c,                   {[gas] analog input}
                         device_f,                   {sample flow analog}
                         device_d:        daqc_addr; {"good bit" digital}
                         dataflow:        dataflow_rec;
                         commerr:         BOOLEAN;
                         errcode:         INTEGER;
                         digital_ambmp:   Word;
                         current_node,
                         current_valve:   INTEGER;
                         condition_sample,
                         condition_analog,
                         condition_digital,
                         condition_commerr,
                         condition_errcode,
                         current_good:    BOOLEAN;
                         tint_begin,
                         time_left:       float;
                         node_addr_hex:   String; {solenoid/valve board}
                         node_addr_word:  Word;
                         number_nodes:    INTEGER;
                         node: ARRAY [0..ambmp_nodes_max-1] OF RECORD
                           active,
                           timedout:      BOOLEAN;
                           valve,
                           time_purge,
                           time_sample:   INTEGER;
                           tint_good,
                           timeout_sec,
                           min_flow,
                           current_flow,
                           concentration: float;
                           END; {node subrecord}
                         END; {record}

VAR
  ambmp_debug:        BOOLEAN;
  ambmp_hardware_var: ambmp_hardware_rec;

PROCEDURE ambient_mp_config (filename: String);
PROCEDURE ambient_mp_init;
PROCEDURE ambient_mp;
{-------------------------------------------------------------}

PROCEDURE Select;
PROCEDURE UpdateIt;

Implementation

Uses
  Main, DataComm, FatalErr, LblForm,
  comp, coms, comu, optomux, licor;

{$R *.dfm}

VAR output_mask: Word;
VAR one: Word;
VAR frmConfig: TLblForm;

{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmMPSample)
    THEN frmMPSample := TMPSample.Create (Application);
  frmMPSample.Show;
  frmMPSample.SetFocus;
  frmMPSample.WindowState := wsNormal;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
{Come here at end of every sample/control period}
VAR ring, nseq: INTEGER;
BEGIN
IF Assigned (frmMPSample) THEN
  IF (frmMPSample.WindowState <> wsMinimized) THEN BEGIN

    FOR ring := 1 TO numrings DO
      WITH frmMPSample.objRingGroup[ring], list_addr_ptr[ring]^ DO BEGIN
        fumigation.Caption := FloatToStrF (gcgrab[ring], ffFixed, 8, 1);
        control   .Caption := FloatToStrF (gccntl[ring], ffFixed, 8, 1);
        ambient   .Caption := FloatToStrF (gcambi[ring], ffFixed, 8, 1);
        WITH conc_fumi DO IF (exists AND (ROUND(range)=800)) THEN
          WITH fumigation DO Caption := Caption+' ['+IntToStr(channel)+']';
        WITH conc_cont DO IF (exists AND (ROUND(range)=800)) THEN
          WITH control    DO Caption := Caption+' ['+IntToStr(channel)+']';
        WITH conc_ambi DO IF (exists AND (ROUND(range)=800)) THEN
          WITH ambient    DO Caption := Caption+' ['+IntToStr(channel)+']';
        END;

    WITH ambmp_hardware_var DO FOR nseq := 0 TO number_nodes-1 DO
      WITH frmMPSample.objMPGroup[nseq], node[nseq] DO BEGIN
        nodeno.Caption := IntToStr (nseq);
        nodeno.Font.Color := clBlack;
        purge .Caption := IntToStr (time_purge);
        sample.Caption := IntToStr (time_sample);
        flow  .Caption := FloatToStrF (current_flow, ffFixed, 8, 2);
        value .Caption := FloatToStrF (concentration, ffFixed, 8, 1);
        lastgood.Caption := IntToStr (ROUND(tint-tint_good)) + ' (' +
          IntToStr(ROUND(timeout_sec)) + ')';
        IF timedout THEN lastgood.Caption := lastgood.Caption + '!';
        IF (nseq = current_node) THEN BEGIN
          nodeno.Caption := nodeno.Caption + '-';
         {nodeno.Font.Color := clRed;}
          IF (time_left > time_sample)
            THEN BEGIN  {in purge}
              purge.Caption := IntToStr (ROUND(time_left-time_sample));
              END
            ELSE BEGIN  {in sample}
              sample.Caption := IntToStr (ROUND(time_left));
             {nodeno.Font.Color := clLime;}
              IF current_good THEN nodeno.Caption := IntToStr (nseq) + '+';
              END;
          END;
        END;

    WITH frmMPSample, ambmp_hardware_var DO BEGIN
      IF current_good
        THEN lblIRGA.Font.Color := clBlack
        ELSE lblIRGA.Font.Color := clRed;
      lblIRGA.Caption := 'IRGA: ' +
        FloatToStrF (dataflow.value, ffFixed, 8, 1);
      lblDI.Caption := 'Digital: ' +
        rep_binary (digital_ambmp, 16);
      lblGood.Caption := 'Good: ' +
        rep_binary (ORD(condition_errcode) + 2 *
                   (ORD(condition_commerr) + 2 *
                   (ORD(condition_digital) + 2 *
                   (ORD(condition_analog)  + 2 *
                   (ORD(condition_sample) )))), 5);
      lblCommErr.Caption := 'CommErr: ' +
        BoolToStr (commerr, TRUE) + ' ' +
        IntToStr (errcode);
      lblTemp.Caption :=
        FloatToStrF (amb_base_grab, ffFixed, 8, 1) + ' ' +
        FloatToStrF (ambient_base.Integral,  ffFixed, 8, 1);
      END;
    END;
END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

PROCEDURE TMPSample.OnCreateForm (Sender: TObject);
VAR ring, nseq: INTEGER;
BEGIN
{Position the window}
  Left := 0;
  Top := 0;
{Position the cancel button}
  btnCancel.Left := ClientWidth -  btnCancel.Width  - 8;
  btnCancel.Top  := ClientHeight - btnCancel.Height - 8;
{Position the help button}
  btnHelp.Left := btnCancel.Left -  btnHelp.Width  - 8;
  btnHelp.Top  := btnCancel.Top;
{Position the show configuration button}
  btnShowConfig.Left := btnHelp.Left -  btnShowConfig.Width  - 8;
  btnShowConfig.Top  := btnCancel.Top;
{Dynamically create the ring group variable label boxes}
  FOR ring := 1 TO numrings DO
    IF NOT Assigned (objRingGroup[ring]) THEN BEGIN
      objRingGroup[ring] := clsRingGroup.Create (Self);
      WITH objRingGroup[ring] DO BEGIN
        Parent  := Self.gbRing;
        Left    := 0;
        Top     := lblRingHeader.Top + ring * (lblRingHeader.Height + 8);
        Width   := Self.gbRing.Width;
        Height  := lblRingHeader.Height + 8;
        BorderStyle := bsSingle;
        BevelInner := bvNone;
        BevelOuter := bvNone;
        ringlabel := TLabel.Create (Self);
        WITH ringlabel DO BEGIN
          Parent  := objRingGroup[ring];
          Left    := lblRingHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := rlabel[ring];
          END;
        fumigation := TLabel.Create (Self);
        WITH fumigation DO BEGIN
          Parent  := objRingGroup[ring];
          Left    := lblFumigationHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          END;
        control := TLabel.Create (Self);
        WITH control DO BEGIN
          Parent  := objRingGroup[ring];
          Left    := lblControlHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          END;
        ambient := TLabel.Create (Self);
        WITH ambient DO BEGIN
          Parent  := objRingGroup[ring];
          Left    := lblAmbientHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          END;
        END;
      END;
{Dynamically create the multiport group variable label boxes}
  FOR nseq := 0 TO ambmp_nodes_max-1 DO
    IF NOT Assigned (objMPGroup[nseq]) THEN BEGIN
      objMPGroup[nseq] := clsMPGroup.Create (Self);
      WITH objMPGroup[nseq], ambmp_hardware_var.node[nseq] DO BEGIN
        Parent  := Self.gbMP;
        Left    := 0;
        Top     := lblNodeHeader.Top + (nseq+1) * (lblNodeHeader.Height + 8);
        Width   := Self.gbMP.Width;
        Height  := lblNodeHeader.Height + 8;
        BorderStyle := bsSingle;
        BevelInner := bvNone;
        BevelOuter := bvNone;
        nodeno := TLabel.Create (Self);
        WITH nodeno DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblNodeHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := IntToStr (nseq);
          END;
        channel := TLabel.Create (Self);
        WITH channel DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblChanHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := IntToStr (valve); {really channel}
          END;
        purge := TLabel.Create (Self);
        WITH purge DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblPurgeHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := IntToStr (time_purge);
          END;
        sample := TLabel.Create (Self);
        WITH sample DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblSampleHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := IntToStr (time_sample);
          END;
        minflow := TLabel.Create (Self);
        WITH minflow DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblMinFlowHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := FloatToStrF (min_flow, ffFixed, 8, 1);
          END;
        flow := TLabel.Create (Self);
        WITH flow DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblFlowHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := 'fff';
          END;
        value := TLabel.Create (Self);
        WITH value DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblValueHeader.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := 'vvv';
          END;
        lastgood := TLabel.Create (Self);
        WITH lastgood DO BEGIN
          Parent  := objMPGroup[nseq];
          Left    := lblLastGood1Header.Left;
          Top     := 0;
          Width   := Parent.Width;
          Height  := Parent.Height;
          Caption := 'lg';
          END;
        END;
      END;
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TMPSample.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmMPSample := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TMPSample.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmMPSample := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE print_config (valno: INTEGER; frm: TLblForm);
{Print configuration information to a LblForm window.
 valno indicates which variable to output.
 frm indicates which open LblForm to send to.
 }
 CONST nl = CHR(13) + CHR(10);
 VAR varno, nodeno: INTEGER;
    s: String;
BEGIN
  varno := valno MOD 100;
  nodeno := valno DIV 100;
  WITH ambmp_hardware_var DO CASE varno OF
    1: s := 'Imbedded multiport present: ' + BoolToStr (exists, TRUE);
    2: s := 'Node definition file: ' + cfg_file_name + ' ' +
            cfg_file_date + ' ' + cfg_file_time + ' ' + cfg_file_size;
    4: WITH DataComm.Ports[PORT_EMB_MP] DO CASE switch OF
         0: WITH SerialRec DO
           s := 'Communications port:' + nl +
                '  EXISTS='   + BoolToStr (exists, TRUE) + nl +
                '  COM='      + IntToStr (com) + nl +
                '  SPEED='    + IntToStr (speed) + nl +
                '  DATABITS=' + IntToStr (databits) + nl +
                '  STOPBITS=' + IntToStr (stopbits) + nl +
                '  PARITY='   + parity + nl +
                '  PROTOCOL=' + protocol;
         1: WITH BusRec DO ;
         2: WITH IPRec  DO ;
         END; {case}
    5: WITH device_c DO s := 'IRGA:' + nl +
         '  EXISTS=' + BoolToStr (exists, TRUE) + nl +
         '  ADDRESS=' + ' x' + word2hex(address,2,2) + nl +
         '  CHANNEL=' + IntToStr (channel) + nl +
         '  RANGE CODE=' + FloatToStrF (range, ffFixed, 8, 3) + nl +
         '  GAIN=' + FloatToStrF (gain, ffFixed, 8, 3) + nl +
         '  OFFSET=' + FloatToStrF (offset, ffFixed, 8, 3) + nl +
         '  ERROR FLAG=' + FloatToStrF (offscale, ffFixed, 8, 3);
    6: WITH device_f DO s := 'Flow meter:' + nl +
         '  EXISTS=' + BoolToStr (exists, TRUE) + nl +
         '  ADDRESS=' + ' x' + word2hex(address,2,2) + nl +
         '  CHANNEL=' + IntToStr (channel) + nl +
         '  RANGE CODE=' + FloatToStrF (range, ffFixed, 8, 3) + nl +
         '  GAIN=' + FloatToStrF (gain, ffFixed, 8, 3) + nl +
         '  OFFSET=' + FloatToStrF (offset, ffFixed, 8, 3) + nl +
         '  ERROR FLAG=' + FloatToStrF (offscale, ffFixed, 8, 3);
    7: WITH device_d DO s := 'Digital inputs:' + nl +
         '  EXISTS=' + BoolToStr (exists, TRUE) + nl +
         '  ADDRESS=' + ' x' + word2hex(address,2,2) + nl +
         '  CHANNEL=' + IntToStr (channel) + nl +
         '  INVERTED=' + BoolToStr (invert, TRUE);
    8: s := 'Number of nodes: ' + IntToStr (number_nodes);
    9: WITH node[nodeno] DO s :=
         '  NODE=' + IntToStr (nodeno) + nl +
         '    ACTIVE=' + BoolToStr (active, TRUE) + nl +
         '    CHANNEL/VALVE=' + IntToStr (valve) + nl +
         '    PURGE TIME [s]=' + IntToStr (time_purge) + nl +
         '    SAMPLE TIME [s]=' + IntToStr (time_sample) + nl +
         '    MINIMUM FLOW=' + FloatToStrF (min_flow, ffFixed, 8, 1) + nl +
         '    TIMEOUT [s]=' + FloatToStrF (timeout_sec, ffFixed, 8, 1);
   10: s := 'Digital output mask: x' +  word2hex (output_mask,4,4);
   11: s := 'Solenoid/valve board address: ' +
            node_addr_hex + ' x' + word2hex (node_addr_word,2,2) +
            ' ' + IntToStr (node_addr_word);
    END; {varno case}
  frm.BodyAppend(s + nl);
  END;  {of procedure 'print_config'}
{-------------------------------------------------------------}

PROCEDURE help;
CONST nl  = CHR(13) + CHR(10);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR frmHelp: TLblForm;
BEGIN
  frmHelp := TLblForm.Create(Application);
  frmHelp.Display ('Imbedded multiport sampler: help', '');
  frmHelp.BodyAppend (
'RING: Ring label, e.g. 1, 2, A, etc.' + nl2 +
'FUMIGATION: Grab sample gas concentration at the center of a' + nl +
' fumigation ring.  Generally unused for a control ring.' + nl2 +
'CONTROL: Gas concentration at the center of the control ring' + nl +
' (if any) associated with that fumigation ring.' + nl2 +
'AMBIENT: Gas concentration at the center of the ambient plot' + nl +
' (if any) associated with that fumigation ring.' + nl2 +
'NODE: Ordinal of sampling point in order read from multiport' + nl +
' configuration file.  Node number is how FCP configuration' + nl +
' maps a sampling point to a fumigation, control, or ambient value.' + nl +
' Sampling points are sampled in node number order.' + nl2 +
'A minus or plus sign will appear after the node number when' + nl +
' that node is active.  A plus sign means all "good" criteria' + nl +
' and the current measurement is being latched to storage.  The' + nl +
' "good" criteria are (1) in sampling period, (2) sufficient flow,' + nl +
' (3) equipment check bit on, and (4) no communications errors.' + nl2 +
'CHAN: Digital I/O board channel (counting from 0) that selects' + nl +
' the sampling point solenoid valve.  (This is completely' + nl +
' independent of the location of a valve on its manifold.)' + nl2 +
'PURGE: Purge time in seconds.' + nl2 +
'SAMP:  Sample time in seconds.' + nl2 +
'MINFL: Minimum gas flow measurement required for a "good"' + nl +
' gas concentration.  Set negative if there is no flow meter.' + nl2 +
'FLOW: Flow meter measurement.  Will be 0 if there is no meter.' + nl2 +
'LAST GOOD: Age of last good measurement in seconds.  If older than' + nl +
' timeout (in parentheses), timed out flag will be set (indicated by !).');
  END;  {of procedure 'help'}
{-------------------------------------------------------------}

PROCEDURE TMPSample.OnClickButton (Sender: TObject);
VAR nodeno: INTEGER;
BEGIN
  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmMPSample := NIL;
    END;
  IF (Sender = btnHelp) THEN BEGIN
    help;
    END;
  IF (Sender = btnShowConfig) THEN BEGIN
    frmConfig := TLblForm.Create(Application);
    frmConfig.Display ('Imbedded multiport sampler: configuration', '');
    print_config ( 1, frmConfig);
    print_config ( 2, frmConfig);
    print_config ( 4, frmConfig);
    print_config ( 5, frmConfig);
    print_config ( 6, frmConfig);
    print_config ( 7, frmConfig);
    print_config (11, frmConfig);
    print_config ( 8, frmConfig);
    FOR nodeno := 0 TO ambmp_hardware_var.number_nodes-1 DO
    print_config (100*nodeno+9, frmConfig);
    print_config (10, frmConfig);
    END;
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE ambient_mp_config (filename: String);
{Read in the imbedded ambient multiport definition file}
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
CONST nl  = CHR(13) + CHR(10);
VAR i, j: INTEGER;
VAR code: INTEGER;
VAR DT: TDateTime;
BEGIN

  WITH ambmp_hardware_var DO BEGIN

  cfg_file_name := SysUtils.UpperCase (filename);
  Main.frmStartup.BodyAppend
    ('Imbedded multiport definition file ' +
     ambmp_hardware_var.cfg_file_name + nl);
  IF cfg_file_name <> 'NONE' THEN BEGIN
    Try
      Assign (cfg_file_handle, cfg_file_name);
      RESET (cfg_file_handle);
      FindFirst (cfg_file_name, faAnyFile, Globals.searchrec_def);
      FindClose (Globals.searchrec_def);
      WITH Globals.searchrec_def DO BEGIN
        DT := FileDateToDateTime (Time);
        DateTimeToString (cfg_file_date, 'YYYY-MM-DD', DT);
        DateTimeToString (cfg_file_time, 'HH:MM:SS', DT);
        cfg_file_size := IntToStr (Size) + ' bytes';
        END;
      Except On Exception Do FatalErr.Msg (
        'Ambient Multiport Configuration File',
        'Ambient multiport configuration file error' + nl2 +
        ambmp_hardware_var.cfg_file_name);
      END;
    WITH ambmp_hardware_var DO BEGIN
      exists := TRUE;
      print_config (1, frmStartup);  {exists?}
      print_config (2, frmStartup);  {file}
      DataComm.PortGet (cfg_file_handle, 1, PORT_EMB_MP);
      print_config (3, frmStartup);  {same port?}
      print_config (4, frmStartup);  {comm port}
      get_addr (cfg_file_handle, 2, 0, 1, device_c);
      print_config (5, frmStartup);  {IRGA}
      get_addr (cfg_file_handle, 3, 0, 1, device_f);
      print_config (6, frmStartup);  {flow meter}
      get_addr (cfg_file_handle, 4, 0, 0, device_d);
      print_config (7, frmStartup);  {digital inputs}
      READ (cfg_file_handle, j);
      node_addr_hex := getchunk (cfg_file_handle, ' ');
      node_addr_word := str2word (node_addr_hex, code);
      IF code <> 0 THEN BEGIN
        FatalErr.Msg (
          'Imbedded Multiport Sampler Configuration ' + cfg_file_name,
          'Conversion of "' + node_addr_hex + '" in line ' +
          IntToStr(j) + ' to solenoid/valve board address failed.' + nl +
          'Function str2word returned code ' + IntToStr(code) + '.');
        END;
      print_config (11, frmStartup); {solenoid/valve board address}
      Try
        READLN (cfg_file_handle, number_nodes);
        print_config (8, frmStartup); {number of nodes}
        Except On Exception Do FatalErr.Msg (
          'Imbedded Multiport Sampler Configuration ' + cfg_file_name,
          'Configuration file error' + nl2 +
          'while attempting to read number of nodes at line ' + IntToStr(j));
        END;
      one := 1;
      IF (number_nodes > 0)
        THEN BEGIN
          FOR i := 0 TO number_nodes-1 DO WITH node[i] DO BEGIN
            Try
              READLN (cfg_file_handle, j, valve,
                      time_purge, time_sample, min_flow, timeout_sec);
              active := (valve <> (-1));
              Except On Exception Do FatalErr.Msg (
                'Imbedded Multiport Sampler Configuration ' + cfg_file_name,
                'Ambient multiport configuration file error' + nl2 +
                'while attempting to read node # ' + IntToStr(i) +
                ' at line ' + IntToStr(j));
              END;
            IF (valve IN [0..15]) THEN
              output_mask := output_mask Or (one Shl valve);
            IF NOT ( (valve IN [0..15]) OR (valve = (-1)) ) THEN
              FatalErr.Msg (
              'Imbedded Multiport Sampler Configuration ' + cfg_file_name,
              'Line = ' + IntToStr(j) + '  Node = ' + IntToStr(i) + nl2 +
              'Valve (field 2) = ' + IntToStr(valve) + ' is out of range.');
            print_config (100*i+9, frmStartup); {node parameters}
            END;
          print_config (10, frmStartup); {digital output mask}
          END
        ELSE Main.frmStartup.BodyAppend
          ('DEVICE ATTACHED IS NOT AN IMBEDDED MULTIPORT' + nl);
      current_node  := number_nodes-1;
      END;
    CloseFile (cfg_file_handle);
    Main.frmStartup.BodyAppend
      ('END READING IMBEDDED MULTIPORT DEFINITION FILE' + nl);
    END;

    END; {with}
  END;  {of procedure 'ambient_mp_config'}
{------------------------------------------------------------}

PROCEDURE ambient_mp_init;
VAR debug_save: BOOLEAN;
BEGIN
  IF ambmp_debug THEN WRITELN ('Enter: ambient_mp_init');
  {fix this in FCP...
  debug_save    := optomux_debug;
  optomux_debug := ambmp_debug;
  ...}
  WITH ambmp_hardware_var, DataComm.Ports[PORT_EMB_MP] DO
  IF exists AND run_mode THEN BEGIN
    commerr := FALSE;
    IF ambmp_debug THEN WRITELN ('CommStart: ambient_mp_init');
    DataComm.PortOpen (PORT_EMB_MP);
    IF ambmp_debug THEN WRITELN ('PowerUpClears: ambient_mp_init');
    IF device_c.exists THEN power_up_clear (PORT_EMB_MP, device_c.address);
    IF device_f.exists THEN power_up_clear (PORT_EMB_MP, device_f.address);
    IF device_d.exists THEN power_up_clear (PORT_EMB_MP, device_d.address);
    power_up_clear (PORT_EMB_MP, node_addr_word);
    IF ambmp_debug THEN WRITELN ('ConfigPos: ambient_mp_init');
    configure_positions (PORT_EMB_MP, node_addr_word, output_mask);
    commerr := optomux_var.error;
    WITH device_c DO IF exists AND (channel IN [21..22]) THEN BEGIN
      IF ambmp_debug THEN WRITELN ('LiCor: ambient_mp_init');
      licor_addcode (address, 42, errcode);
      licor_addcode (address, 43, errcode);
      licor_ptr^[address]^.daqc       := protocol;
      licor_ptr^[address]^.port       := PORT_EMB_MP;
      licor_ptr^[address]^.address    := address;
      licor_ptr^[address]^.speed      := 9600;
      licor_ptr^[address]^.auto_print := 0.0;
     {licor_ptr^[address]^.count_rest := SET IN LICOR_INIT}
      licor_init (address, errcode);
      commerr := optomux_var.error;
     {errcode := optomux_var.errno; -- errcode is last licor init result}
      END;  {with LiCor device_c}
    END;  {with var and port}
  {fix this in FCP...
  optomux_debug := debug_save;
  ...}
  IF ambmp_debug THEN WRITELN ('Exit: ambient_mp_init');
  END;  {of procedure 'ambient_mp_init'}
{------------------------------------------------------------}

PROCEDURE ambient_mp;
{Imbedded multiport to gather control ring and ambient site gas concentrations.
 First created for commissioning of FACTS-I.  The output of this routine
 simulates the input to the AZ WCL MP code which takes it from there
 as of August 1996.  In July 1998, original Arizona ambient multiport to be
 replaced by one identical to the FACTS-I.  Make appropriate code changes.
 Further changes for Germany: analog output only flow meter and use of a
 separate data acqusition port July 1999.
}
VAR period_purge,
    period_sample,
    period_total: INTEGER;
    biton:        Word;
    commerr_grab: BOOLEAN;
    debug_save:   BOOLEAN;
BEGIN
  IF ambmp_debug THEN WRITELN ('Enter: ambient_mp');
  {fix this in FCP...
  debug_save    := optomux_debug;
  optomux_debug := ambmp_debug;
  ...}
  WITH ambmp_hardware_var DO current_good := NOT commerr;
  WITH ambmp_hardware_var, DataComm.Ports[PORT_EMB_MP] DO
  IF NOT commerr THEN BEGIN
    period_purge  := ambmp_hardware_var.node[current_node].time_purge;
    period_sample := ambmp_hardware_var.node[current_node].time_sample;
    period_total  := period_purge + period_sample;
    IF ((tint-tint_begin) > period_total) THEN BEGIN
      REPEAT
        INC (current_node);
        IF (current_node > (number_nodes-1)) THEN current_node := 0;
        UNTIL (node[current_node].valve IN [0..15]); {LOOP DANGER!!!}
      period_purge  := ambmp_hardware_var.node[current_node].time_purge;
      period_sample := ambmp_hardware_var.node[current_node].time_sample;
      period_total  := period_purge + period_sample;
      tint_begin := tint;
      END;
    current_valve := ambmp_hardware_var.node[current_node].valve;

    IF run_mode THEN BEGIN
      commerr_grab := FALSE;
    {set the selected valve}
      one := 1;
      biton := one Shl current_valve;
      activate_digital   (PORT_EMB_MP, node_addr_word, biton);
      deactivate_digital (PORT_EMB_MP, node_addr_word, output_mask And Not(biton));
      commerr := (commerr OR commerr_grab);
    {do the digital read of status bit}
      WITH device_d DO IF exists THEN BEGIN
        digital_in (protocol, PORT_EMB_MP, address, digital_ambmp, commerr_grab);
        commerr := (commerr OR commerr_grab);
        END;
    {read the flow meter}
      IF device_f.exists
        THEN analog_in (device_f, dataflow, PORT_EMB_MP, commerr_grab)
        ELSE dataflow.value := 0.0;
      commerr := (commerr OR commerr_grab);
      node[current_node].current_flow := dataflow.value;
    {get gas concentration}
      analog_in (device_c, dataflow, PORT_EMB_MP, commerr_grab);
      commerr := (commerr OR commerr_grab);
      END;  {if in run mode}

    condition_sample  := ((tint-tint_begin) > period_purge);
    IF device_f.exists
      THEN condition_analog  := (node[current_node].current_flow
                                 >= node[current_node].min_flow)
      ELSE condition_analog  := TRUE;
    IF device_d.exists
      THEN BEGIN
        condition_digital := ((digital_ambmp And (one Shl device_d.channel))
                               <> 0);
        IF device_d.invert THEN condition_digital := NOT condition_digital;
        END
      ELSE condition_digital := TRUE;
    condition_commerr := (NOT commerr);
    condition_errcode := (errcode = 0);

    current_good := condition_sample  AND
                    condition_analog  AND
                    condition_digital AND
                    condition_commerr AND
                    condition_errcode;


    WITH node[current_node] DO BEGIN
      IF current_good THEN BEGIN
        concentration := dataflow.value;
        tint_good := tint;
        END;
      timedout := ( (tint - tint_good) > timeout_sec );
      END; {with node}

    time_left := period_total - (tint-tint_begin);
    END;  {of with}

  {fix this in FCP...
  optomux_debug := debug_save;
  ...}
  IF ambmp_debug THEN WRITELN ('Exit: ambient_mp');
  END;  {of procedure 'ambient_mp'}
{-------------------------------------------------------------}

VAR i: INTEGER;

Initialization

BEGIN

{--------- unit initialization from old ambmp.pas is here ----}

  output_mask := 0;

  ambmp_debug := FALSE;

  WITH ambmp_hardware_var DO BEGIN
    exists        := FALSE;
    cfg_file_name := 'NONE';
    commerr       := FALSE;
    errcode       := 0;
    digital_ambmp := 0;
    current_node  := ambmp_nodes_max-1;
    tint_begin    := -3600.0;
    DataComm.Ports[PORT_EMB_MP].exists := FALSE;
    FOR i := 0 TO ambmp_nodes_max-1 DO WITH node[i] DO BEGIN
      active        := FALSE;
      timedout      := TRUE;
      tint_good     := -3600.0;
      concentration := -111.1;
      END;
    END;

{-------------------------------------------------------------}

  END;

Finalization

BEGIN
  END;

{of form unit MPSample...}
END.
