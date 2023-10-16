Unit Watchdog;
{
Setup and petting of watchdog devices for alarm dialout

v01.01 2002-12-02 Original
v01.02 2002-12-02 Dropped metrabyte, serial & "WD"  protocol petting
v01.03 2002-12-03 do_dialout moved here from COMP
v01.04 2003-01-27 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.05 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.06 2003-03-18 .dfm: "Test mode" -> "Test mode (suppress petting)"
v01.07 2003-05-25 OnDestroyForm: added back; frmWatchdog := NIL;
v02.00 2009-01-22 ffpwcnt: replace incorrect lobyte := 1 by value := 1
                  OnClickButton: place 20s floor under .chan
                                 impose 20s granularity
v03.00 2009-08-10 Config, Exists: use the new PORT_WATCHDOG macro and Ports[]
                  Config: Deleted.  Now Main calls DataComm.PortConfig directly
                  Replace watchdog_port by DataComm.Ports[PORT_WATCHDOG]
v04.00 2011-09-29 Add petting of Festo FEC controller
v04.01 2011-11-02 FEC: remove objFestoCI.Open/.Close; assume done elsewhere.
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
  LblForm,
  WinIO;

TYPE
  TfrmWatchdog = class(TForm)
    btnCancel: TBitBtn;
    btnApply: TBitBtn;
    btnOK: TBitBtn;
    btnHelp: TBitBtn;
    cbExists: TCheckBox;
    cbInitialized: TCheckBox;
    cbTest: TCheckBox;
    txtBase: TEdit;
    lblBase: TLabel;
    comboProtocol: TComboBox;
    lblProtocol: TLabel;
    txtTimeout: TEdit;
    lblTimeout: TLabel;
    btnInitialize: TButton;
    memoOps: TMemo;
    btnClear: TButton;
    cbPause: TCheckBox;
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
    PROCEDURE Refresh;
  Private
    { Private declarations }
  Public
    { Public declarations }
  END;

VAR frmWatchdog: TfrmWatchdog;
    frmHelp: TLblForm;

PROCEDURE Select;
PROCEDURE UpdateIt;
FUNCTION  Exists: BOOLEAN;
FUNCTION  TestGet: BOOLEAN;
PROCEDURE TestSet (state: BOOLEAN);
FUNCTION  DialoutGet: BOOLEAN;
PROCEDURE DialoutSet (state: BOOLEAN);
PROCEDURE Pet;

Implementation

{$R *.dfm}

Uses
  DataComm, Globals,
  comd, comu, crt32;

VAR
  watchdog_pp:   TEXT;     {file handle for LPT petted watchdog}
  watchdog_init: BOOLEAN;  {set true when watchdog initialized}
  watchdog_test: BOOLEAN;  {set true to suppress petting}
  do_dialout:    BOOLEAN;  {set true by client to cause dial out}
{-------------------------------------------------------------}

PROCEDURE TfrmWatchdog.OnClickButton (Sender: TObject);
CONST nl = CHR(13)+CHR(10);
      nl2 = nl+nl;
VAR header, body: String;
    success: BOOLEAN;
BEGIN

  IF (Sender = btnApply) OR (Sender = btnOK) THEN BEGIN
    WITH DataComm.Ports[PORT_WATCHDOG] DO BEGIN
      CASE switch OF
        0: ;
        1: WITH BusRec DO BEGIN
          exists := cbExists.Checked;
          protocol := comboProtocol.Text;
          IF (protocol = 'FEC')
            THEN base := StrToInt (     txtBase.Text)
            ELSE base := StrToInt ('0x'+txtBase.Text);
          chan := StrToInt (txtTimeout.Text);
          IF (chan < 20) THEN chan := 20;
          chan := 20 * (chan DIV 20);
          END; {with}
        2: ;
        END; {case}
      END; {with}
    watchdog_init := cbInitialized.Checked;
    watchdog_test := cbTest.Checked;
    Refresh;
    memoOps.Lines.Add ('New settings applied');
    END;

  IF (Sender = btnOK) OR (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmWatchdog := NIL;
    END;

  IF (Sender = btnHelp) THEN BEGIN
    header := 'Watchdog Help Page';
    body := '';
    frmHelp := TLblForm.Create (Application);
    frmHelp.Display (header, body);
    END;  {of help button}

  IF (Sender = btnInitialize) THEN BEGIN
    IF (DataComm.Ports[PORT_WATCHDOG].protocol = 'FFPWCNT')
    THEN BEGIN
      success := WinIO.Initialize;
      watchdog_init := success;
      cbInitialized.Checked := watchdog_init;
      IF success
        THEN memoOps.Lines.Add ('WinIO Initialize OK')
        ELSE memoOps.Lines.Add ('WinIO Initialize Failed');
      END
    ELSE memoOps.Lines.Add ('Not used with this protocol')
    END;  {of initialize button}

  IF (Sender = btnClear) THEN BEGIN
    memoOps.Clear;
    END;  {of clear button}

  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TfrmWatchdog.OnCreateForm (Sender: TObject);
BEGIN
  Refresh;
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TfrmWatchdog.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmWatchdog := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TfrmWatchdog.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant but hopefully harmless}
BEGIN
  frmWatchdog := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TfrmWatchdog.Refresh;
{Fill in the form from working variables}
BEGIN
  WITH DataComm.Ports[PORT_WATCHDOG] DO BEGIN
    CASE switch OF
      0: ;
      1: WITH BusRec DO BEGIN
        cbExists.Checked := exists;
        comboProtocol.Text := protocol;
        IF (protocol = 'FEC')
          THEN txtBase.Text:= IntToStr (base)
          ELSE txtBase.Text:= IntToHex (base, 3);
        txtTimeout.Text := IntToStr (chan);
        btnInitialize.Enabled := (protocol = 'FFPWCNT');
        END; {with}
      2: ;
      END; {case}
    END; {with} 
  cbInitialized.Checked := watchdog_init;
  cbTest.Checked := watchdog_test;
  END;  {of procedure Refresh}
{---------------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmWatchdog)
    THEN frmWatchdog := TfrmWatchdog.Create (Application);
  frmWatchdog.Show;
  frmWatchdog.SetFocus;
  frmWatchdog.WindowState := wsNormal;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
{Come here at end of every sample/control period}
BEGIN
  IF Assigned (frmWatchdog) THEN
    IF (frmWatchdog.WindowState <> wsMinimized) THEN BEGIN
      END;
  END;  {of procedure 'UpdateIt'}
{-------------------------------------------------------------}

FUNCTION Exists: BOOLEAN;
BEGIN
  Exists := Ports[PORT_WATCHDOG].exists;
  END;  {of function Exists}
{-------------------------------------------------------------}

FUNCTION TestGet: BOOLEAN;
BEGIN
  TestGet := watchdog_test;
  END;  {of function TestGet}
{-------------------------------------------------------------}

PROCEDURE TestSet (state: BOOLEAN);
BEGIN
  watchdog_test := state;
  END;  {of procedure TestSet}
{------------------------------------------------------------}

FUNCTION DialoutGet: BOOLEAN;
BEGIN
  DialoutGet := do_dialout;
  END;  {of function DialoutGet}
{-------------------------------------------------------------}

PROCEDURE DialoutSet (state: BOOLEAN);
BEGIN
  do_dialout := state;
  END;  {of procedure DialoutSet}
{------------------------------------------------------------}

PROCEDURE Pet;

VAR screenup: BOOLEAN;
{.............................................................}

PROCEDURE fec;
CONST
  pet_offset  = 1;  {offsets from base address}
  time_offset = 0;

BEGIN
  WITH DataComm.Ports[PORT_WATCHDOG], BusRec,
       DataComm.Ports[PORT_RINGS], IPRec DO BEGIN
    {objFestoCI.Open;}
    objFestoCI.WordWrite ('M', 100*chan, base+time_offset);
    IF screenup AND (NOT frmWatchdog.cbPause.Checked) THEN BEGIN
      frmWatchdog.memoOps.Lines.Add ('-->' + objFestoCI.LastCommand);
      frmWatchdog.memoOps.Lines.Add ('<--' + objFestoCI.LastResponse);
      END;
    objFestoCI.WordWrite ('M',      127, base+pet_offset);
    IF screenup AND (NOT frmWatchdog.cbPause.Checked) THEN BEGIN
      frmWatchdog.memoOps.Lines.Add ('-->' + objFestoCI.LastCommand);
      frmWatchdog.memoOps.Lines.Add ('<--' + objFestoCI.LastResponse);
      END;
    {objFestoCI.Close;}
    END; {with}
  END;  {of local procedure for petting the Festo CPX FEC controller}
{.............................................................}

PROCEDURE ffpwcnt;
CONST
  pet       = 0;  {offsets from base address}
  timeout   = 1;
  mode      = 2;
  range     = 3;
  inhibit   = 0;  {mode values}
  enable    = 1;
  low_speed = 0;  {20 seconds per count}
  hi_speed  = 1;  {0.3125 seconds per count}

VAR success: BOOLEAN;
    value:   Cardinal;

PROCEDURE screento (id: String; success: BOOLEAN; p: Word; v: Cardinal);
VAR msg: String;
BEGIN
  msg := id + ':  ';
  IF success
    THEN msg := msg + 'OK  '
    ELSE msg := msg + 'Failed  ';
  msg := msg + '0x' + IntToHex (p, 3) + '  ';
  msg := msg + IntToStr (v And $FF);
  IF NOT frmWatchdog.cbPause.Checked
    THEN frmWatchdog.memoOps.Lines.Add (msg);
  END;  {double local procedure 'screento'}
BEGIN
  IF NOT watchdog_init THEN BEGIN
    success := WinIO.Initialize;
    watchdog_init := success;
    IF screenup THEN screento ('Initialize', success, 0, 0);
    END;
  WITH DataComm.Ports[PORT_WATCHDOG], BusRec DO BEGIN
    success := WinIO.PortGet (base+pet, value, 1);
    IF screenup THEN screento ('PortGet', success, base+pet, value);
    success := WinIO.PortSet (base+mode, enable, 1);
    IF screenup THEN screento ('PortSet', success, base+mode, enable);
    success := WinIO.PortSet (base+range, low_speed, 1);
    IF screenup THEN screento ('PortSet', success, base+range, low_speed);
    value := (chan DIV 20);            {wd.chan contains period in seconds}
    IF (value <= 0) THEN value := 1;   {default to a one count timeout}
    success := WinIO.PortSet (base+timeout, value, 1);
    IF screenup THEN screento ('PortSet', success, base+timeout, value);
    END; {with}
  END;  {of local procedure for Outsource E&M FFPWC1.0 ISA-mode NT driver}
{.............................................................}

PROCEDURE parallel (whichone: INTEGER);

PROCEDURE screento (id: String; value: INTEGER);
VAR msg: String;
BEGIN
  msg := id + ':  ' + IntToHex(value, 2);
  IF NOT frmWatchdog.cbPause.Checked
    THEN frmWatchdog.memoOps.Lines.Add (msg);
  END;  {double local procedure 'screento'}

BEGIN
  {Pet a TTL watchdog connected to a dedicated parallel (LPT:) port.
   Watchdog parameters (e.g. timeout) must be set externally to CPU.}
  WITH DataComm.Ports[PORT_WATCHDOG], BusRec DO BEGIN
    {Does not use direct i/o.  Use TurboPascal/BIOS so works with NT also.}
    IF NOT watchdog_init THEN BEGIN
      CASE whichone OF
        1: Assign (watchdog_pp, 'LPT1');
        2: Assign (watchdog_pp, 'LPT2');
        3: Assign (watchdog_pp, 'LPT3');
        END;  {of case}
      REWRITE (watchdog_pp);
      watchdog_init := TRUE;
      END;  {init}
      {As yet, this file not explicitly closed on program exit.}
    WRITE (watchdog_pp, CHR($FF));
    IF screenup THEN screento (protocol, $FF);
    Delay (1);
    WRITE (watchdog_pp, CHR($00));
    IF screenup THEN screento (protocol, $00);
    END;  {of with}
  END;  {of local procedure for petting a dedicated parallel port watchdog}
{.............................................................}

BEGIN  {procedure body}
  {Determine if activitiy will be written to screen.}
  screenup := FALSE;
  IF Assigned (frmWatchdog) THEN
    screenup := (frmWatchdog.WindowState <> wsMinimized);

  {Pet watchdog.  Method depends on protocol.}
  WITH DataComm.Ports[PORT_WATCHDOG] DO
  IF exists AND (NOT watchdog_test) THEN BEGIN
    IF  protocol='FEC'     THEN fec;
    IF  protocol='FFPWCNT' THEN ffpwcnt;
    IF  protocol='LPT1'    THEN parallel(1);
    IF  protocol='LPT2'    THEN parallel(2);
    IF  protocol='LPT3'    THEN parallel(3);
    END;  {of with}
  END;  {of procedure 'watchdog'}
{-------------------------------------------------------------}

Initialization

BEGIN
  watchdog_init := FALSE;
  watchdog_test := FALSE;
  do_dialout    := FALSE;
  END;

Finalization

BEGIN
  IF (DataComm.Ports[PORT_WATCHDOG].protocol='FFPWCNT')
    THEN WinIO.Shutdown;
  END;

{of form unit Watchdog...}
END.
