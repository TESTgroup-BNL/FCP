Unit DataComm;
{$R+} {range checking ON}

{
Configuration, drivers and information window
for FACE DAQC data communications

v01.01 2002-12-04 Original
v01.02 2002-12-05 Add "By address"
v01.03 2002-12-06 Add "Raw data flow"
v01.04 2002-12-07 alt-M Enter timeout multiplier [1..n] not implemented
v01.05 2002-12-07 Add "Log errors to file"
v01.06 2003-01-26 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.07 2003-01-30 AddrAllocate: (3x) Font.Size 8 --> Font.Height -11
v01.08 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.09 2003-03-18 Replace btnClose: TButton by btnCancel: TBitBtn
v01.10 2003-05-09 OnClickCheck/cbPause: event handling suppression with tag
v01.11 2003-05-09 OnCreateForm: set cbPause to current Optomux.DebugPause
v01.12 2003-05-25 OnDestroyForm: added back; frmDataComm := NIL
v01.13 2004-12-05 OnCloseForm: add OnClickButton (btnStats);
v02.01 2009-08-16 Add data comm port parametrization and subprograms
v02.02 2009-10-07 PortRecv/SerialRec: replace ReceiveChar by ReceiveString
                  Range checking ON
v02.03 2009-11-13 Interface Uses: add Winsock
                  Implementation Uses: add Socket
                  Replace TCPIP by IP in names
                  Add needed socket elements to IPType record
                  Add Socket.pas routine calls to Port* functions
                  Implement on-the-fly changing of timeout
                  For sockets, confirm resetting of timeout
                  Open/TCP: execute Close first (a temporary fix)
v02.04 2009-11-19 Refresh: fix label & edit control visibility bug
v03.01 2011-09-23 IPType: add a objFestoCI element
       2011-09-24 OnClickButton/btnRaw: FestoCI raw data flow enable
                  OnClickButton/btnStats: FestoCI raw data flow disable
                  OnClickCheck/cbPause: FestoCI raw data pausing
       2011-10-17 Refresh: show base and addr in decimal and hex
       2011-10-24 PortType: add a objLI8XX element; add Uses LI8XX
       2011-10-25 OnClickButton/btnRaw: LI8XX raw data flow enable
                  OnClickButton/btnStats: LI8XX raw data flow disable
                  OnClickCheck/cbPause: LI8XX raw data pausing
       2011-10-26 Change references of LI8XX to LineIn
       2011-10-27 PortTO: changes required if FestoCI is being used
       2011-11-01 OnClickButton/btnRaw,/btnStats,OnClickCheck/cbPause: WMT700
                  .dfm: memoRaw - change MaxLength from 30000 to 0
                  comboVPI: disable when doing raw data flow
v03.02 2011-12-01 PortRangeMax: change from 32 to 64
                  Add recognition of protocol CSI1 to debugging code
v03.03 2012-01-17 PortOpen: Hardwire 10 ms as WinSock read timeout
                  PortRecv: Use new Socket.ReceiveStringTO function
v04.01 2012-01-26 PortGet: New. Move and edit of coms/get_port
                  test_key, check: Copied from coms
                  hex2word, str2word, getchunk: Copied from comu
       2012-02-01 PortGet: Clean up field format.  See new CFG.TXT.
                  test_key: Existence of a key field now optional.
                  test_key: A key read of 99 matches any key expected.
v05.01 2012-07-23 Add FileType/FileRec TEXT file, switch = 3 -- extensive
       2012-07-24 Add LastErrNo and LastErrMsg to PortType
       2012-07-25 Place creation of all objLineIn in INITIALIZATION
v05.02 2012-08-22 .DFM/Virtual port index/ DropDownCount 8 --> 15
v05.03 2012-09-14 OnCreateForm: add protocol to VPI pull down listings
                  .DFM/Virtual port index/ DropDownCount 15 --> 32
v06.01 2013-12-15 .dfm: memoRaw - change MaxLength back to 30000 from 0
v06.02 2016-07-07 .dfm: memoRaw - change MaxLength back to 0 from 30000
v06.03 2016-07-09 .dfm: memoRaw - change MaxLength to 30000000 (30 MB)
v06.04 2016-07-28 OnChangeText: process if sender=edit3.  For changing watchdog "channel".
                  btnCopy[ToClipboard]: button added
                  OnClickButton: code added for above (memoRaw only)
v06.05 2016-07-30 btnCopy: put into "raw" group
}

{ The second field (diptoe) of a GetPort configuration line
  determines what type of port this is:

 -1                          Port does not exist in this configuration
  0       Bus    switch = 1  Diptoe then discarded
  1..256  Serial switch = 0  Diptoe then becomes COM number
  300     File   switch = 3  Diptoe then discarded
  301+    IP     switch = 2  Diptoe then becomes remote port number
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QControls, QForms, QGraphics, QStdCtrls, Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Controls, Forms, Graphics, StdCtrls, Windows, Winsock,
  Messages, Classes,
{$ENDIF}
  SysUtils,
  LblForm, FestoCI, LineIn;

{======== Form related definitions, etc. =====================}

TYPE
  TDataComm = class(TForm)
    grpConfig: TGroupBox;
    comboVPI: TComboBox;
    editProtocol: TEdit;
    lblProtocol: TLabel;
    lbl1: TLabel;
    edit1: TEdit;
    lbl2: TLabel;
    edit2: TEdit;
    lbl3: TLabel;
    edit3: TEdit;
    lbl4: TLabel;
    edit4: TEdit;
    lbl5: TLabel;
    edit5: TEdit;
    lbl6: TLabel;
    edit6: TEdit;
    btnTimeoutApply: TButton;
    grpErrstats: TGroupBox;
    rbType: TRadioButton;
    rbAddr: TRadioButton;
    btnRaw: TButton;
    memoStats: TMemo;
    grpRaw: TGroupBox;
    btnCopy: TButton;
    cbPause: TCheckBox;
    btnClear: TButton;
    btnStats: TButton;
    memoRaw: TMemo;
    cbErrlog: TCheckbox;
    btnReset: TButton;
    btnUpdate: TButton;
    btnCancel: TBitBtn;
    PROCEDURE OnCreateForm  (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnClickCheck  (Sender: TObject);
    PROCEDURE OnClickRadio  (Sender: TObject);
    PROCEDURE OnChangeText  (Sender: TObject);
    PROCEDURE Refresh (port: INTEGER);
  private
    { Private declarations }
    FmemoRawWarned: BOOLEAN;
  public
    { Public declarations }
  end;

VAR
  frmDataComm: TDataComm;
  frmHelp: TLblForm;

  VPI_current: INTEGER;  {virtual port index currently displayed}

PROCEDURE Select;
PROCEDURE UpdateIt (port: INTEGER);

{======== Port parametrization and procedures =================}

{Port parameters are stored in an array of records.
 A record consists of serial, IP, etc. parts.
 Which part is active depends on the value of the "switch" element.
}

CONST

  PortRangeMin = 1;
  PortRangeMax = 64;

TYPE

  SerialType = RECORD
                 handle:   THandle;
                 com:      INTEGER;  {1 for COM1:, etc.}
                 speed:    DWORD;
                 databits: BYTE;
                 parity:   STRING;
                 stopbits: BYTE;
                 timeout:  INTEGER;
                 END;

  BusType    = RECORD
                 handle:   THandle;
                 base,
                 addr,
                 chan:     WORD;
                 timeout:  INTEGER;
                 END;

  IPType     = RECORD
                 handle:          TSocket;
                 mode,                      {'TCP' or 'UDP'}
                 ip_remote:       String;   {'aaa:bbb:ccc:ddd'}
                 port_remote,
                 port_local:      INTEGER;
                 sockaddr_remote: TSockAddr;
                 objFestoCI:      clsFestoCI;
                 timeout:         INTEGER;
                 END;

  FileType   = RECORD
                 handle:          TEXT;
                 filename:        String;   {incl. net, path, ext}
                 mode:            INTEGER;  {0: read, 1: write, 2: append}
                 param1,                    {3 integer parameters}
                 param2,                    {to be used by protocols}
                 param3:          INTEGER;
                 timeout:         INTEGER;  {not used}
                 END;

  PortType   = RECORD
                 exists:     BOOLEAN;
                 switch:     INTEGER;
                 protocol:   STRING;
                 objLineIn:  clsLineIn;
                 SerialRec:  SerialType;  {switch = 0}
                 BusRec:     BusType;     {switch = 1}
                 IPRec:      IPType;      {switch = 2}
                 FileRec:    FileType;    {switch = 3}
                 LastErrNo:  INTEGER;
                 LastErrMsg: STRING;
                 END;

VAR

  Ports: ARRAY [PortRangeMin..PortRangeMax] OF PortType;

PROCEDURE PortErrorWindow (port: INTEGER; complainer: String);
PROCEDURE PortGet (VAR f: TEXT; key_expect, port: INTEGER);
FUNCTION PortOpen  (port: INTEGER): BOOLEAN;
FUNCTION PortClose (port: INTEGER): BOOLEAN;
FUNCTION PortSend  (port: INTEGER; msg: String): BOOLEAN;
FUNCTION PortRecv  (port: INTEGER; VAR s: STRING; term: CHAR): BOOLEAN;
FUNCTION PortTO    (port, new_timeout: INTEGER): BOOLEAN;

{==============================================================}


Implementation

Uses optomux, Serial, Socket, FatalErr;

CONST errlogname = 'OPTOERR.LOG';

{Error by address axes and matrix}
VAR lblAddrHi: ARRAY [0..$F] OF TLabel;
    lblAddrLo: ARRAY [0..$F] OF TLabel;
    lblAddrCount: ARRAY [0..$F,0..$F] OF TLabel;

VAR i: INTEGER;

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE AddrAllocate (mother: TDataComm);
CONST aLeft   =  10;
      aTop    =  54;
      aWidth  =  35;
      aHeight =  18;
      aHGap   =   0;
      aVGap   =   0;
VAR hi, lo: INTEGER;
    newLeft, newTop: INTEGER;
BEGIN
  newTop := aTop + aHeight + aVGap;
  FOR hi := 0 TO $F DO BEGIN
    lblAddrHi[hi] := TLabel.Create (frmDataComm);
    WITH lblAddrHi[hi] DO BEGIN
      Parent := mother.grpErrstats;
      Visible := FALSE;
      Width := aWidth;
      Height := aHeight;
      Left := aLeft;
      Top := newTop;
      newTop := Top + aHeight + aVGap;
      IF ((hi MOD 4) = 0) THEN newTop := newTop + aVGap;
      Font.Height := -11;
      Font.Style := [fsBold];
      Caption := IntToHex(hi,1) + '0';
      END;
    END;  {Y-axis}
  newLeft := aLeft + aWidth + aHGap;
  FOR lo := 0 TO $F DO BEGIN
    lblAddrLo[lo] := TLabel.Create (frmDataComm);
    WITH lblAddrLo[lo] DO BEGIN
      Parent := mother.grpErrstats;
      Visible := FALSE;
      Width := aWidth;
      Height := aHeight;
      Top := aTop;
      Left := newLeft;
      newLeft := Left + aWidth + aHGap;
      IF ((lo MOD 4) = 0) THEN newLeft := newLeft + aHGap;
      Font.Height := -11;
      Font.Style := [fsBold];
      Caption := IntToHex(lo,2);
      END;
    END;  {X-axis}
  FOR hi := 0 TO $F DO
  FOR lo := 0 TO $F DO BEGIN
    lblAddrCount[hi,lo] := TLabel.Create (frmDataComm);
    WITH lblAddrCount[hi,lo] DO BEGIN
      Parent := mother.grpErrstats;
      Visible := FALSE;
      Width := aWidth;
      Height := aHeight;
      Top := lblAddrHi[hi].Top;
      Left := lblAddrLo[lo].Left;
      Font.Height := -11;
      Font.Style := [fsBold];
      END;
    END;  {Matrix}
  END;  {of procedure AddrAllocate}
{-------------------------------------------------------------}

PROCEDURE TDataComm.OnCreateForm (Sender: TObject);
VAR i: INTEGER;
BEGIN
  {Fill the virtual port index combo box list}
  comboVPI.Clear;
  FOR i := PortRangeMin TO PortRangeMax DO
    WITH Ports[i] DO
      IF exists THEN
        comboVPI.AddItem (Format('%2d', [i]) + '  ' + protocol, NIL);
  Refresh (VPI_current);
  AddrAllocate (Self);
  cbErrlog.Caption := '&Log errors to ' + errlogname;
  cbErrlog.Tag := 0;  {signal event handler not to do anything}
  cbErrlog.Checked := Optomux.ErrlogEnableGet;
  cbErrlog.Tag := 1;
  cbPause.Tag := 0;  {signal event handler not to do anything}
  cbPause.Checked := Optomux.DebugPauseGet;
  cbPause.Tag := 1;
  FmemoRawWarned := FALSE;
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TDataComm.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  OnClickButton (btnStats);
  Action := caFree;
  frmDataComm := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TDataComm.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmDataComm := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TDataComm.OnClickButton(Sender: TObject);
VAR pause_save: BOOLEAN;
BEGIN

IF (Sender = btnRaw) THEN BEGIN
  comboVPI.Enabled := FALSE;
  grpErrstats.Visible := FALSE;
  grpRaw.Visible := TRUE;
  Optomux.DebugMemoSet (memoRaw);
  Optomux.DebugEnableSet (TRUE);
  IF (editProtocol.Text = 'FE') THEN
    WITH Ports[VPI_current].IPRec DO BEGIN
      objFestoCI.DebugMemoSet (memoRaw);
      objFestoCI.DebugEnableSet (TRUE);
      objFestoCI.DebugPauseSet (cbPause.Checked);
      END;
  IF (editProtocol.Text = 'LI820')  OR
     (editProtocol.Text = 'LI840')  OR
     (editProtocol.Text = 'LI850')  OR
     (editProtocol.Text = 'WMT700') OR
     (editProtocol.Text = 'CSI1')   OR
     (Ports[VPI_current].switch=3)  THEN
    WITH Ports[VPI_current] DO BEGIN
      objLineIn.DebugMemoSet (memoRaw);
      objLineIn.DebugEnableSet (TRUE);
      objLineIn.DebugPauseSet (cbPause.Checked);
      END;
  END;

IF (Sender = btnStats) THEN BEGIN
  comboVPI.Enabled := TRUE;
  Optomux.DebugEnableSet (FALSE);
  Optomux.DebugMemoSet (NIL);
  IF (editProtocol.Text = 'FE') THEN
    WITH Ports[VPI_current].IPRec DO BEGIN
      objFestoCI.DebugEnableSet (FALSE);
      objFestoCI.DebugMemoSet (NIL);
      END;
  IF (editProtocol.Text = 'LI820')  OR
     (editProtocol.Text = 'LI840')  OR
     (editProtocol.Text = 'LI850')  OR
     (editProtocol.Text = 'WMT700') OR
     (editProtocol.Text = 'CSI1')   OR
     (Ports[VPI_current].switch=3)  THEN
    WITH Ports[VPI_current] DO BEGIN
      objLineIn.DebugEnableSet (FALSE);
      objLineIn.DebugMemoSet (NIL);
      END;
  grpRaw.Visible := FALSE;
  grpErrstats.Visible := TRUE;
  UpdateIt (1 {***TEMPORARY***});
  END;

IF (Sender = btnTimeoutApply) THEN BEGIN
  TRY
    PortTO (VPI_current, StrToInt (edit6.Text));
  EXCEPT
    edit6.Text := '99';
    END;
  END;

IF (Sender = btnCopy) THEN BEGIN
  pause_save := cbPause.Checked;
  cbPause.Tag := 0;
  cbPause.Checked := TRUE;
  memoRaw.SelectAll;
  memoRaw.CopyToClipboard;
  memoRaw.SelLength := -1;
  cbPause.Checked := pause_save;
  cbPause.Tag := 1;
  END;

  IF (Sender = btnReset) THEN BEGIN
  Optomux.ErrstatsClear;
  UpdateIt (1 {***TEMPORARY***});
  END;

IF (Sender = btnUpdate) THEN BEGIN
  UpdateIt (1 {***TEMPORARY***});
  END;

IF (Sender = btnCancel) THEN BEGIN
  OnClickButton (btnStats);
  Self.Release;
  frmDataComm := NIL;
  END;

IF (Sender = btnClear) THEN BEGIN
  memoRaw.Clear;
  memoRaw.Lines.Add ('TEXT BUFFER CLEARED');
  END;

  END;  {of procedure OnClickButton}
{---------------------------------------------------------------------}

PROCEDURE TDataComm.OnClickCheck (Sender: TObject);
BEGIN

IF (Sender = cbErrlog) AND (cbErrlog.Tag <> 0) THEN BEGIN
  Optomux.ErrlogNameSet (errlogname);
  Optomux.ErrlogEnableSet (cbErrlog.Checked);
  END;

IF (Sender = cbPause) AND (cbPause.Tag <> 0) THEN BEGIN
  Optomux.DebugPauseSet (cbPause.Checked);
  IF (editProtocol.Text = 'FE') THEN
    WITH Ports[VPI_current].IPRec DO BEGIN
      objFestoCI.DebugPauseSet (cbPause.Checked);
      END;
  IF (editProtocol.Text = 'LI820')  OR
     (editProtocol.Text = 'LI840')  OR
     (editProtocol.Text = 'LI850')  OR
     (editProtocol.Text = 'WMT700') OR
     (editProtocol.Text = 'CSI1')   OR
     (Ports[VPI_current].switch=3)  THEN
    WITH Ports[VPI_current] DO BEGIN
      objLineIn.DebugPauseSet (cbPause.Checked);
      END;
  END;

  END;  {of procedure OnClickCheck}
{---------------------------------------------------------------------}

PROCEDURE TDataComm.OnClickRadio(Sender: TObject);
VAR type_sent, addr_sent:BOOLEAN;
    hi, lo: INTEGER;
BEGIN
  type_sent := rbType.Checked;
  addr_sent := rbAddr.Checked;
  memoStats.Visible := type_sent;
  FOR hi := 0 TO $F DO lblAddrHi[hi].Visible := addr_sent;
  FOR lo := 0 TO $F DO lblAddrLo[lo].Visible := addr_sent;
  FOR hi := 0 TO $F DO
  FOR lo := 0 TO $F DO
    lblAddrCount[hi,lo].Visible := addr_sent;
  UpdateIt (1 {***TEMPORARY***});
  END;  {of procedure OnClickRadio}
{---------------------------------------------------------------------}

PROCEDURE TDataComm.OnChangeText(Sender: TObject);
VAR new_value: INTEGER;
BEGIN

IF (Sender = comboVPI) THEN BEGIN
  TRY
    VPI_current := StrToInt (Copy(comboVPI.Text,1,2));
    IF (VPI_current < PortRangeMin) THEN VPI_current := PortRangeMin;
    IF (VPI_current > PortRangeMax) THEN VPI_current := PortRangeMax;
    Refresh (VPI_current);
    UpdateIt (1 {***TEMPORARY***});
  EXCEPT
    comboVPI.Text := 'invalid';
    END;
  END;

TRY
  IF (Sender = frmDataComm.edit3) AND (frmDataComm.edit3.Text <> '') THEN BEGIN
    new_value := StrToInt (frmDataComm.edit3.Text);
    Ports[VPI_current].BusRec.chan := new_value;
    END;
  EXCEPT
  END;

  END;  {of procedure OnChangeText}
{---------------------------------------------------------------------}

PROCEDURE TDataComm.Refresh (port: INTEGER);
{Fill in the form from working variables}
BEGIN
  WITH Ports[port] DO BEGIN
    comboVPI.Text := IntToStr(port);
    editProtocol.Text := protocol;
    CASE switch OF

      0: WITH SerialRec DO BEGIN
lbl1.Caption := 'COM port';      edit1.Text := IntToStr (com);
lbl2.Caption := 'Speed';         edit2.Text := IntToStr (speed);
lbl3.Caption := 'Data bits';     edit3.Text := IntToStr (databits);
lbl4.Caption := 'Stop bits';     edit4.Text := IntToStr (stopbits);
lbl5.Caption := 'Parity';        edit5.Text := parity;
lbl6.Caption := 'Timeout [ms]';  edit6.Text := IntToStr (timeout);
lbl4.Visible := TRUE;            edit4.Visible := TRUE; 
lbl5.Visible := TRUE;            edit5.Visible := TRUE; 
lbl6.Visible := TRUE;            edit6.Visible := TRUE; 
btnTimeoutApply.Visible := TRUE;
END;

      1: WITH BusRec DO BEGIN
lbl1.Caption := 'I/O address';   edit1.Text := IntToStr (base) +
                                               ' = 0x' + IntToHex (base, 2);
lbl2.Caption := 'Field address'; edit2.Text := IntToStr (addr) +
                                               ' = 0x' + IntToHex (addr, 2);
lbl3.Caption := 'Channel';       edit3.Text := IntToStr (chan);
lbl4.Visible := FALSE;           edit4.Visible := FALSE;
lbl5.Visible := FALSE;           edit5.Visible := FALSE;
lbl6.Visible := FALSE;           edit6.Visible := FALSE;
btnTimeoutApply.Visible := FALSE;
END;

      2: WITH IPRec DO BEGIN
lbl1.Caption := 'Mode';          edit1.Text := mode;
lbl2.Caption := 'IP address';    edit2.Text := ip_remote;
lbl3.Caption := 'Remote port';   edit3.Text := IntToStr (port_remote);
lbl4.Caption := 'Local port';    edit4.Text := IntToStr (port_local);
lbl6.Caption := 'Timeout [ms]';  edit6.Text := IntToStr (timeout);
lbl4.Visible := TRUE;            edit4.Visible := TRUE; 
lbl5.Visible := FALSE;           edit5.Visible := FALSE;
lbl6.Visible := TRUE;            edit6.Visible := TRUE; 
btnTimeoutApply.Visible := TRUE;
END;

      3: WITH FileRec DO BEGIN
lbl1.Caption := 'File';        edit1.Text := filename;
lbl2.Caption := 'Mode';
  IF (mode = 0) THEN edit2.Text := IntToStr (mode) + ' READ';
  IF (mode = 1) THEN edit2.Text := IntToStr (mode) + ' WRITE';
  IF (mode = 2) THEN edit2.Text := IntToStr (mode) + ' APPEND';
lbl3.Caption := 'Parameter 1'; edit3.Text := IntToStr (param1) +
                                             ' = 0x' + IntToHex (param1, 4);
lbl4.Caption := 'Parameter 2'; edit4.Text := IntToStr (param2) +
                                             ' = 0x' + IntToHex (param2, 4);
lbl5.Caption := 'Parameter 3'; edit5.Text := IntToStr (param3) +
                                             ' = 0x' + IntToHex (param3, 4);
lbl4.Visible := TRUE;            edit4.Visible := TRUE; 
lbl5.Visible := TRUE;            edit5.Visible := TRUE; 
lbl6.Visible := FALSE;           edit6.Visible := FALSE;
btnTimeoutApply.Visible := FALSE;
END;

      END;  {of case}
    END;  {of with ports[]}
  END;  {of procedure Refresh}
{---------------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmDataComm)
    THEN frmDataComm := TDataComm.Create (Application);
  WITH frmDataComm DO BEGIN
    Show;
    SetFocus;
    WindowState := wsNormal;
    UpdateIt (1 {***TEMPORARY***});
    END;
  END;  {of procedure Select}
{-------------------------------------------------------------}

PROCEDURE UpdateIt (port: INTEGER);
{This UpdateIt is NOT called at the end of every sample/control period.
 Manual intervention required.}
VAR i: INTEGER;
    hi,
    lo: INTEGER;
    protocol: STRING;
BEGIN
  IF Assigned (frmDataComm) THEN
    IF (frmDataComm.WindowState <> wsMinimized) THEN BEGIN

      protocol := DataComm.Ports[port].protocol;

      IF frmDataComm.rbType.Checked THEN BEGIN
        frmDataComm.memoStats.Clear;
        frmDataComm.memoStats.Lines.Add ('This screen does not update automatically');
        frmDataComm.memoStats.Lines.Add ('');
        frmDataComm.memoStats.Lines.Add
          ('Since ' + Optomux.ErrstatsClearWhenGet);
        frmDataComm.memoStats.Lines.Add ('');
        frmDataComm.memoStats.Lines.Add
          ('COUNT RETRIES ERROR_TYPE LAST_DT >LAST_COMMAND \LAST_RESPONSE\');
        frmDataComm.memoStats.Lines.Add
          ('----- ------- ---------- ------- ------------- ---------------');
        IF (protocol = 'OS') OR (protocol = 'DS') THEN
          FOR i := 0 TO Optomux.optomux_errno_max DO
            WITH Optomux.optomux_errstats^[i] DO
              IF (n <> 0) THEN frmDataComm.memoStats.Lines.Add (
                IntToStr (n) + ' ' +
                IntToStr (retries) + ' ' +
                Optomux.optomux_error_list[i] + ' ' +
                lasterr_dt  + ' ' +
                lasterr_cmd + ' ' +
                lasterr_res);
        frmDataComm.memoStats.Lines.Add ('<END-OF-LIST>');
        END;  {by type}

      IF frmDataComm.rbAddr.Checked THEN BEGIN
        FOR hi := 0 TO $F DO
        FOR lo := 0 TO $F DO
        WITH lblAddrCount[hi,lo] DO
          IF (optomux_err_byaddr^[16*hi+lo] > 0)
            THEN BEGIN
              Font.Color := clRed;
              Caption := IntToStr (optomux_err_byaddr^[16*hi+lo]);
              Hint := Caption;
              ShowHint := TRUE;
              END
            ELSE BEGIN
              Font.Color := clLtGray;
              Caption := '-';
              ShowHint := FALSE;
              END;
        END;  {by address}

      END;
  END;  {of procedure UpdateIt}

{======== Actual calls to data communications system ==========}

FUNCTION Check_If_Already_Open (port: INTEGER): THandle;
{This function needed if different devices (different logical
 ports) are using the same COM interface.  If a requested port is a
 COM (i.e. serial) interface, this function looks for another logical
 port using the same COM interface AND has a valid handle.  If so, that
 handle is used (the Open function is of course a little different).
 If not, then that logical ports handle value is used.  The first logical
 port opened gets the precedence and its parameters may conflict with
 other devices trying to use the same interface.  Must be consistent.}
VAR i: INTEGER;
    handle_use: THandle;
BEGIN
  handle_use := Ports[port].SerialRec.handle;
  IF (handle_use = INVALID_HANDLE_VALUE) THEN
    FOR i := PortRangeMin TO PortRangeMax DO
      IF (Ports[i].SerialRec.com = Ports[port].SerialRec.com) AND
         (Ports[i].SerialRec.handle <> INVALID_HANDLE_VALUE)
        THEN handle_use := Ports[i].SerialRec.handle;
  Check_If_Already_Open := handle_use;
  END; {function Check_If_Already_Open}
{-------------------------------------------------------------}

PROCEDURE PortErrorWindow (port: INTEGER; complainer: String);
BEGIN
  WITH Ports[port] DO BEGIN
    CASE switch OF
      0: Serial.LastErrorWindow (complainer);
      1: ;
      2: Socket.LastErrorWindow (complainer);
      3: ;
      END; {case switch}
    END; {with ports}
  END; {procedure PortErrorWindow}
{-------------------------------------------------------------}

PROCEDURE test_key (key_read, key_expect: INTEGER);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
BEGIN
  IF (key_read <> key_expect) AND (key_read <> 99) THEN BEGIN
    SetLastError ($20005001);
    FatalErr.Msg ('DataComm/test_key',
    'Error encountered in a configuration file' + nl2 +
    'Line number key field (1st) read was ' + IntToStr(key_read) + nl2 +
    'Key expected was ' + IntToStr(key_expect));
    END;
  {For development, a key read of 99 matches any expected}
  END;  {of procedure 'test_key'}
{-----------------------------------------------------------}

PROCEDURE check (s: String; code: INTEGER);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
BEGIN
  IF (code <> 0) THEN BEGIN
    SetLastError ($20005002);
    FatalErr.Msg ('DataComm/check',
    'Error encountered in a configuration file' + nl2 +
    'Cannot decode >>>' + s + '<<< at position ' + IntToStr(code));
    END;
  END;  {of procedure 'check'}
{------------------------------------------------------------}

FUNCTION hex2word (s: String; VAR code: INTEGER): Word;
{Hexadecimal string to word conversion function.
 Stolen, with modifications, from optomux.pas 04/09/93.

   s         string (input)
   code      return code (output)
               = 0  conversion ok
               = 2  string greater than 4 characters
               = 3  invalid character in string
   hex2word  returned function value
}
CONST ofs0   = ORD('0');
      ofsucA = ORD('A')-10;
      ofslcA = ORD('a')-10;
VAR value: Word;
    i: INTEGER;
BEGIN
  value := 0;
  code := 0;
  IF Length(s) > 4
    THEN code := 2
    ELSE BEGIN
      i := 1;
      WHILE i <= Length(s) DO BEGIN
        CASE s[i] OF
          '0'..'9':  value := (value Shl 4) Or (ORD(s[i]) - ofs0  );
          'A'..'F':  value := (value Shl 4) Or (ORD(s[i]) - ofsucA);
          'a'..'f':  value := (value Shl 4) Or (ORD(s[i]) - ofslcA);
          Else code := 3;
          END;  {of case}
        INC(i);
        END;
      END;
  hex2word := value;
  END;  {of function 'hex2word'}
{-------------------------------------------------------------------}

FUNCTION str2word (s: String; VAR code: INTEGER): Word;
{Convert ascii representation of hexidecimal or decimal to word.
 Hexadecimal indicated by leading x, X, 0x, 0X, or trailing h, H.
 }
VAR hex: BOOLEAN;
    temp: Word;
BEGIN
  hex := FALSE;
  code := 0;
  WHILE (Length(s) > 0) AND (s[1] IN [' ','0','x','X']) DO BEGIN
    IF s[1] IN ['x','X'] THEN hex := TRUE;
    Delete (s,1,1);
    END;
  WHILE (Length(s) > 0) AND (s[Length(s)] IN [' ',CHR(13),CHR(10),'h','H']) 
    DO BEGIN
      IF s[Length(s)] IN ['h','H'] THEN hex := TRUE;
      Delete (s,Length(s),1);
      END;
  IF Length(s) > 0
    THEN IF hex THEN temp := hex2word (s, code)
                ELSE Val (s, temp, code)
    ELSE temp := 0;
  str2word := temp;
  END;  {of function 'str2word'}
{------------------------------------------------------------}

FUNCTION getchunk (VAR ifile: TEXT; separator: CHAR): String;
{Get a string token from text file input.
 Will not read past end-of-line or end-of-file.
 Null-string returned in this case.
 }
VAR  buffer: String;
     ch: CHAR;

FUNCTION more: BOOLEAN;
BEGIN
  more := NOT (EOF(ifile) OR EOLN(ifile));
  END;  {of local function 'more'}

BEGIN
  buffer := '';
  ch := CHR(0);  {suppress Delphi compiler "hint"}
  IF more THEN REPEAT 
    READ (ifile, ch) 
    UNTIL (ch<>separator) OR NOT more;
  IF more THEN REPEAT
    IF ch<>separator THEN buffer := buffer+ch;
    READ (ifile, ch);
    UNTIL (ch=separator) OR NOT more;
  getchunk := buffer;
  END;  {of function 'getchunk'}
{------------------------------------------------------------}

PROCEDURE PortGet (VAR f: TEXT; key_expect, port: INTEGER);
{Read in parameters for a port from config file}
VAR s: String;
    diptoe, key_found, code: INTEGER;
BEGIN
WITH DataComm.Ports[port] DO BEGIN

  {Use of a key in the file is optional.}
  IF (key_expect >= 0) THEN BEGIN  {-1 indicates key not present}
    READ (f, key_found);
    test_key (key_found, key_expect);
    END;

  READ (f, diptoe);  {must be decimal, not hexadecimal}
  exists := (diptoe >= 0);
  IF exists THEN BEGIN

    IF (diptoe-1 IN [0..255]) THEN WITH SerialRec DO BEGIN  {this is serial}
      switch := 0;
      com := diptoe;
      READ (f, speed);
      READ (f, databits);
      parity   := getchunk (f,' ');
      READ (f, stopbits);
      READ (f, timeout);
      protocol := getchunk (f,' ');
      END;

    IF (diptoe = 0) THEN WITH BusRec DO BEGIN  {this is a bus device}
      switch := 1;
      s := getchunk (f,' ');  base := str2word (s, code);  check (s, code);  
      s := getchunk (f,' ');  addr := str2word (s, code);  check (s, code);
      s := getchunk (f,' ');  chan := str2word (s, code);  check (s, code);
      protocol := getchunk (f,' ');
      END;

    IF (diptoe > 300) THEN WITH IPRec DO BEGIN  {this is an IP device}
      switch := 2;
      port_remote := diptoe;
      s := getchunk (f,' ');  ip_remote  := s;  
      s := getchunk (f,' ');  mode       := UpperCase(s);  
      s := getchunk (f,' ');  port_local := str2word (s, code);  check (s, code);  
      s := getchunk (f,' ');  timeout    := str2word (s, code);  check (s, code);  
      protocol := getchunk (f,' ');
      IF (protocol = 'FE') THEN BEGIN
        objFestoCI := clsFestoCI.Create;
        objFestoCI.Setup (
         'GET_PORT', mode, ip_remote, port_remote, port_local, timeout);
        END;
      END;

    IF (diptoe = 300) THEN WITH FileRec DO BEGIN  {this is a network text file}
      switch := 3;
      filename := getchunk (f,' ');
      s := getchunk (f,' ');  mode   := str2word (s, code);  check (s, code);
      s := getchunk (f,' ');  param1 := str2word (s, code);  check (s, code);
      s := getchunk (f,' ');  param2 := str2word (s, code);  check (s, code);
      s := getchunk (f,' ');  param3 := str2word (s, code);  check (s, code);
      protocol := getchunk (f,' ');
      END;
    END; {if exists}

  READLN (f);
  END; {with}
  END;  {of procedure 'PortGet'}
{---------------------------------------------------------------------}

FUNCTION PortOpen (port: INTEGER): BOOLEAN;
VAR fSuccess: BOOLEAN;
BEGIN
  fSuccess := TRUE;
  WITH Ports[port] DO BEGIN
    CASE switch OF

      0: WITH SerialRec DO BEGIN
           fSuccess := TRUE;
           handle := Check_If_Already_Open (port);
           IF (handle = INVALID_HANDLE_VALUE) THEN BEGIN
             fSuccess := Serial.Open
               (handle, com, speed, databits, parity, stopbits, timeout);
             IF fSuccess THEN fSuccess := Serial.DTRSet (handle, TRUE);
             IF fSuccess THEN fSuccess := Serial.RTSSet (handle, TRUE);
             IF fSuccess THEN fSuccess := Serial.EmptyBufferTx (handle);
             IF fSuccess THEN fSuccess := Serial.EmptyBufferRx (handle);
             END;
           END;

      1: WITH BusRec DO BEGIN
           END;

      2: WITH IPRec DO BEGIN
           IF (UpperCase(mode) = 'TCP') THEN PortClose (port); {***TEMPORARY***}
           fSuccess := Socket.Open
             (handle, mode, ip_remote, port_remote, port_local,
              sockaddr_remote, 10); {but see use of ReceiveStringTO in PortRecv}
           END;

      3: WITH FileRec DO BEGIN
           {$I-}
           AssignFile (handle, filename);
           {$I+}
           LastErrNo := IOResult;
           fSuccess  := (LastErrNo = 0);
           IF fSuccess THEN BEGIN
             {$I-}
             CASE mode OF
               0: RESET   (handle);
               1: REWRITE (handle);
               2: APPEND  (handle);
               END; {case mode}
             {$I+}
             LastErrNo := IOResult;
             fSuccess  := (LastErrNo = 0);
             END;
           LastErrMsg := SysUtils.SysErrorMessage(LastErrNo);
           END;

      END; {case switch}
    END; {with ports}
  PortOpen := fSuccess;
  END; {function PortOpen}
{-------------------------------------------------------------}

FUNCTION PortClose (port: INTEGER): BOOLEAN;
VAR fSuccess: BOOLEAN;
    i: INTEGER;
BEGIN
  fSuccess := TRUE;
  WITH Ports[port] DO BEGIN
    CASE switch OF

      0: WITH SerialRec DO BEGIN
                            fSuccess := Serial.DTRSet (handle, FALSE);
           IF fSuccess THEN fSuccess := Serial.RTSSet (handle, FALSE);
           IF fSuccess THEN fSuccess := Serial.Close  (handle);
           FOR i := PortRangeMin TO PortRangeMax DO BEGIN
             IF (Ports[i].SerialRec.com = com) THEN
               Ports[i].SerialRec.handle := INVALID_HANDLE_VALUE;
             END;
           END;

      1: WITH BusRec DO BEGIN
           END;

      2: WITH IPRec DO BEGIN
           fSuccess := Socket.Close (handle);
           handle := INVALID_SOCKET;
           END;

      3: WITH FileRec DO BEGIN
           {$I-}
           CloseFile (handle);
           {$I+}
           LastErrNo := IOResult;
           fSuccess  := (LastErrNo = 0);
           LastErrMsg := SysUtils.SysErrorMessage(LastErrNo);
           END;

      END; {case switch}
    END; {with ports}
  PortClose := fSuccess;
  END; {function PortClose}
{-------------------------------------------------------------}

FUNCTION PortSend (port: INTEGER; msg: String): BOOLEAN;
VAR fSuccess: BOOLEAN;
BEGIN
  fSuccess := TRUE;
  WITH Ports[port] DO BEGIN
    CASE switch OF

      0: WITH SerialRec DO BEGIN
                            fSuccess := Serial.EmptyBufferTx (handle);
           IF fSuccess THEN fSuccess := Serial.EmptyBufferRx (handle);
           IF fSuccess THEN fSuccess := Serial.SendString (handle, msg);
           END;

      1: WITH BusRec DO BEGIN
           END;

      2: WITH IPRec DO BEGIN
           fSuccess := Socket.SendString (handle, sockaddr_remote, msg);
           END;

      3: WITH FileRec DO BEGIN  {mode is not checked!}
           {$I-}
           WRITE (handle, msg);  {Note: no explicit EOL termination}
           {$I+}
           LastErrNo := IOResult;
           fSuccess  := (LastErrNo = 0);
           LastErrMsg := SysUtils.SysErrorMessage(LastErrNo);
           END;

      END; {case switch}
    END; {with ports}
  PortSend := fSuccess;
  END; {function PortSend}
{-------------------------------------------------------------}

FUNCTION PortRecv (port: INTEGER; VAR s: STRING; term: CHAR): BOOLEAN;
VAR fSuccess: BOOLEAN;
BEGIN
  fSuccess := TRUE;
  WITH Ports[port] DO BEGIN
    CASE switch OF

      0: WITH SerialRec DO BEGIN
           fSuccess := Serial.ReceiveString (handle, s, term);
           END;

      1: WITH BusRec DO BEGIN
           END;

      2: WITH IPRec DO BEGIN
           fSuccess := Socket.ReceiveStringTO
            (handle, sockaddr_remote, s, timeout);
           END;

      3: WITH FileRec DO BEGIN  {mode is not checked!}
           {$I-}
           READLN (handle, s);  {Note: read past EOL termination}
           {$I+}
           LastErrNo := IOResult;
           fSuccess  := (LastErrNo = 0);
           LastErrMsg := SysUtils.SysErrorMessage(LastErrNo);
           END;

      END; {case switch}
    END; {with ports}
  PortRecv := fSuccess;
  END; {function PortRecv}
{-------------------------------------------------------------}

FUNCTION PortTO (port, new_timeout: INTEGER): BOOLEAN;
{Sets a new read timeout interval}
VAR fSuccess: BOOLEAN;
    ms:       INTEGER;
BEGIN
  fSuccess := TRUE;
  WITH Ports[port] DO BEGIN
    CASE switch OF
      0: WITH SerialRec DO BEGIN
           timeout := new_timeout;
           fSuccess := Serial.TimeoutSet (handle, timeout);
           END; {serial}
      1: WITH BusRec DO BEGIN
           END; {bus}
      2: WITH IPRec DO BEGIN
           timeout := new_timeout;
           fSuccess := Socket.TimeoutSet (handle, timeout);
           IF fSuccess THEN BEGIN
             Socket.TimeoutGet (handle, ms);
             frmDataComm.edit6.Text := '0' + IntToStr(ms);
             END;
           {Above does not work if this port is FestoCI
            because clsFestoCI keeps its own parameter set.
            FestoCI's parameter must be loaded with the
            new DataComm timeout parameter.}
            IF (protocol = 'FE')
              THEN objFestoCI.Setup (
                'PortTO', mode, ip_remote, port_remote, port_local, timeout);
           END; {ip}
      3: WITH FileRec DO BEGIN
           END; {file}
      END; {case switch}
    END; {with ports}
  PortTO := fSuccess;
  END; {function PortTO}
{-------------------------------------------------------------}

INITIALIZATION

FOR i := PortRangeMin TO PortRangeMax DO WITH Ports[i] DO BEGIN
  exists := FALSE;
  objLineIn := clsLineIn.Create;
  SerialRec.handle := INVALID_HANDLE_VALUE;
  IPRec.handle     := INVALID_SOCKET;
  END;

VPI_current := 1;

{of unit DataComm...} END.
