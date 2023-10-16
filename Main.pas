Unit Main;
{
The FCP main form.

v01.01 2002-09-15 Original
v01.02 2002-11-11 Work continues
v01.03 2003-01-27 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF & MSWINDOWS
v01.04 2003-01-29 FormCreate: change Font.Size := 10 to .Height := -16
v01.05 2003-01-30 LTWHlbl: copy .Height, not .Size
v01.06 2003-03-15 Finally got auto sizing working
v01.07 2003-03-17 MenuClick: replace call to ephemeris(0) by Ephem.Select
v01.08 2003-03-17 .dfm MainMenu: Change Con&figuration to Co&nfiguration
v01.09 2003-03-17 .dfm MainMenu: Add &File -> E&xit
v01.10 2003-03-19 Add procedure ExitRoutine just old main console for now
v01.11 2003-03-19 MenuClick/RingPictures: remove statscr := FALSE;
v01.12 2003-03-19 status: moved here from COMS
v01.13 2003-03-19 All status screen related code moved here from FCP.DPR
v01.14 2003-03-19 Uses crt32;
v01.15 2003-03-19 Add OnCloseForm event handler
v01.16 2003-03-20 mnuRingPictures: remove redundant inrings := TRUE;
v01.17 2003-05-09 config: moved here from fcp.dpr
v01.18 2003-05-09 Uses: many added since needed by config
v01.19 2003-05-10 ExitRoutine: meaningful console title
v01.20 2003-05-10 ExitRoutine: reinstate showing current ring label
v01.21 2003-05-26 Menu: add Utilities/WaterVapor
v01.22 2003-05-26 Remove console <F10> Water vapor calculations
v01.23 2003-05-27 exit_sequence: replace System.Halt (999) by Application.Terminate
v01.24 2003-05-27 mnuHelpDiagnosticsComponents, ListComponents: new
v01.25 2003-05-27 Replace OnKeyPressForm by OnKeyDownForm
v01.26 2003-05-28 comd/Global changes
v01.27 2003-05-28 mnuConfigConnect: new
v01.28 2003-05-29 exit_sequence: remove connect code; now in Connect.pas
v01.29 2003-05-30 mnuFileConsole -> Old &Consoles added
v01.30 2003-05-30 most of the event handlers renamed
v01.31 2003-05-30 exit_sequence functionality moved to new ExitSeq.pas
v01.32 2003-05-31 mnuConfigNetLog: new; see NetLog.pas
v01.33 2003-06-08 mnuFileDataBackup: new; see Backup.pas
v01.33 2004-03-03 config: fix typos in progress reporting
v01.34 2004-07-07 config/show: remove AmbientMP related code
v01.35 2004-07-07 mnuConfigMPSample: new; see MPSample.pas
v01.36 2004-07-07 mnuDataflow: new under mnuUtilities
v01.37 2004-07-07 mnuDataflowMPSample: new; equivalent to mnuConfigMPSamples
v01.38 2004-07-07 OnClickMenu: add two separate calls to MPSample.Select
v01.39 2004-07-07 Uses (local): add MPSample
v01.40 2004-07-08 In Uses replace ambmp by MPSample.
v01.41 2004-08-01 config: change 3 licor/licor6262_* refs to licor_*
v01.42 2004-10-03 config: read temp_auxiliary line if AZ2 or now NV1
v01.43 2004-12-09 OnClickMenu/mnuCompare: call Compare.Select;
                  Uses: Compare added
v01.44 2005-05-05 config: read temp_auxiliary line if AZ2, NV1 or now WI1
v01.45 2005-05-06 OnCreateForm: change date Left from 220 to 0
                  Init: adjustment of width depends on numrings
v01.46 2006-03-30 Config: trying to fix TN 24 VVP problem
v01.47 2006-04-29 Config: negate v01.46 because didn't fix really
                  Interface Uses: Replace tp5utils by Sol 
v01.48 2006-09-22 Config:
                    Delete fileinfo: TSearchRec
                    Replaced by Globals.searchrec_exe or _cfg
                    Move FindFirst/FindClose calls to LOAD from SHOW
v01.49 2006-09-23 Config/LOAD: SetLastError $20002001 if numrings > max
v01.50 2007-06-15 OnClickMenu: Don't call old_consoles if statscr already true
v02.00 2009-08-11 coms.get_port: port argument type has changed
                  multiport: delete link argument; there is now only 1
v03.00 2011-09-23 Config/LOAD: special temporary code for AU1 and Festo
                  Config/SHOW: show address of VVP manifold pressure sensor
                  Config/SHOW: comment out show of vvp_close (need the line)
       2011-09-30 Init: make window wider to avoid scroll bars
       2011-10-17 Config/LOAD: If AU1 then read PORT_GA and PORT_WIND
       2011-10-18 Config/LOAD: filling vvpfailsafe[] now grouped by 8 (was 16)
       2011-10-25 Config/LOAD: If PORT_GA is LI820/LI840, create and open
       2011-10-28 Uses: add LineIn
       2011-11-01 Config/LOAD: Add AU1 to list with auxiliary temperature
       2011-12-01 Config/LOAD: Add reading of datalogger #1 link
v03.01 2012-02-02 Config/LOAD: Delete MODEM, GAS_SUPPLY, WASTE_BIN, TIMESERV
                               Change coms.get_port to DataComm.PortGet
                               Site wide keys renumbered
                               Remove all IF AU1; these reads now permanent
                               Auxiliary temperature now for all sites
                               Read .vvp_pressure permanent & correct position
                               Ring specific keys renumbered starting at 1
v03.02 2012-07-12 Uses: Delete LineIn -- no longer needed
                  Config/LOAD: Remove clsLineIn.Create (3x) -- see DataComm
       2012-07-30 Config/LOAD: Add reading of PORT_FCPLINK_1 configuration
v03.03 2012-08-22 Config/LOAD: Change to reading of PORT_LINK_BASE+i [1..4]
       2012-08-24 Config/LOAD: Read ambient_base_value, new line 15
       2012-08-24 Config/SHOW: Show ambient_base_value, delete irga_zero, irga_span
v03.04 2015-11-18 Implementation: Declare external GetConsoleWindow
                  old_consoles: Disable Close (red-X) after AllocConsole()
                  
}

Interface

USES
{$IFDEF LINUX}
  QComCtrls, QControls, QExtCtrls, QForms, QGraphics, QMenus, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  ComCtrls, Controls, ExtCtrls, Forms, Graphics, Menus, StdCtrls,
  Classes, Windows, Messages,
{$ENDIF}
  Math, SysUtils,
  Backup, CalibAut, CalibMan, Compare, Connect, DataComm, Ephem, ExitSeq, 
  H2OVapor, NetLog, Watchdog,
  RingBar, Heart, Alarms, Status, FatalErr, LblForm, RVSetup,
  crt32, {***TEMPORARY***}
  MPSample, licor,
  Globals,
  coms, comu, comd, comp, comlog, riv, netinfo, debuglog, Sol;

TYPE
  TMain = class(TForm)
    MainMenu: TMainMenu;
      mnuFile: TMenuItem;
        mnuFileData: TMenuItem;
          mnuFileDataBackup: TMenuItem;
          mnuFileDataDumps: TMenuItem;
          mnuFileDataLogging: TMenuItem;
        mnuFileConsole: TMenuItem;
        mnuFileExit: TMenuItem;
      mnuRingPictures: TMenuItem;
      mnuCalibration: TMenuItem;
        mnuCalibrationAutomatic: TMenuItem;
        mnuCalibrationManual: TMenuItem;
      mnuCompare: TMenuItem;
      mnuConfig: TMenuItem;
        mnuConfigDataComm: TMenuItem;
        mnuConfigMPSample: TMenuItem;
        mnuConfigNetLog: TMenuItem;
        mnuConfigWatchdog: TMenuItem;
        mnuConfigSep1: TMenuItem;
        mnuConfigConnect: TMenuItem;
      mnuUtilities: TMenuItem;
        mnuDataflow: TMenuItem;
          mnuDataflowMPSample: TMenuItem;
        mnuSunEphemeris: TMenuItem;
        mnuWaterVapor: TMenuItem;
      mnuHelp: TMenuItem;
        mnuHelpTopics: TMenuItem;
        mnuHelpDiagnostics: TMenuItem;
          mnuHelpDiagnosticsComponents: TMenuItem;
        mnuHelpAbout: TMenuItem;
          mnuHelpAboutSystem: TMenuItem;
          mnuHelpAboutFCP: TMenuItem;
    lblDateTitle: TLabel;
    lblDateValue: TLabel;
    lblDOYTitle: TLabel;
    lblDOYValue: TLabel;
    lblTimeTitle: TLabel;
    lblTimeValue: TLabel;
    lblTZTitle: TLabel;
    lblTZValue: TLabel;
    lblDiskTitle: TLabel;
    lblDiskValue: TLabel;
    lblMemoryTitle: TLabel;
    lblMemoryAvail: TLabel;
    lblMemoryTotal: TLabel;
    lblPhysicalTitle: TLabel;
    lblPhysicalAvail: TLabel;
    lblPhysicalTotal: TLabel;
    lblPageFileTitle: TLabel;
    lblPageFileAvail: TLabel;
    lblPageFileTotal: TLabel;
    lblVirtualTitle: TLabel;
    lblVirtualAvail: TLabel;
    lblVirtualTotal: TLabel;
    PROCEDURE OnClickForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnResizeForm (Sender: TObject);
    PROCEDURE OnClickMenu (Sender: TObject);
    PROCEDURE OnKeyDownForm (Sender: TObject; VAR Key: Word; Shift: TShiftState);
  Private
    { Private declarations }
    rb: TRingBar;    {ring bar}
    hb: THeartBeat;  {heart beat}
  Public
    { Public declarations }
    PROCEDURE Init;
    PROCEDURE UpdateIt;
    PROCEDURE HeartBeat (which: BOOLEAN);
  END;

VAR frmMain:     TMain;     {main form}

    frmMsg:      TLblForm;  {messages}
    frmMainHelp: TLblForm;  {main form's help form}
    frmStartup:  TLblForm;  {running messages during program start}
	
	consoleOpened: BOOLEAN;

PROCEDURE config (command: String; ring: INTEGER);

Implementation

{$R *.dfm}

function GetConsoleWindow: HWND; stdcall; external kernel32;  {Used in proc old_consoles}

PROCEDURE LTWHlbl (me: TLabel; ref: TLabel; dl, dt, dw, dh: INTEGER);
{Sets the Left, Top, Width, and Height of a Label "me"
 relative to those of a reference Label "ref".
 Also sets the Font.Height of "me" to that of "ref".}
BEGIN
  me.Left := ref.Left + dl;
  me.Top  := ref.Top  + dt;
  me.Width := ref.Width + dw;
  me.Height := ref.Height + dh;
  me.Font.Height := ref.Font.Height;
  END;  {procedure 'LTWH'}

PROCEDURE TMain.OnClickForm (Sender: TObject);
BEGIN
  END;  {of procedure 'OnClickForm'}

PROCEDURE TMain.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  ExitSeq.Select;
  END;  {of procedure 'OnCloseForm'}

PROCEDURE TMain.OnCreateForm (Sender: TObject);
BEGIN

  {Initial size and position of main window}
  Show;
  Top := 3;
  Left := 1;
  Width := 600;
  Height := 300;

  {Set the position & size parameters of the DateTitle label}
  WITH lblDateTitle DO BEGIN
    Left   := 0;
    Top    := 50;
    Width  := 80;
    Height := 20;
    Font.Height := -16;
    END;  {with lblDateTitle}

  {Set other position & size parameters relative to the DateTitle label}
  LTWHlbl (lblDateValue, lblDateTitle,  90,  0, 30,  0);
  LTWHlbl (lblDOYTitle,  lblDateTitle, 190,  0,  0,  0);
  LTWHlbl (lblDOYValue,  lblDateTitle, 240,  0,  0,  0);

  LTWHlbl (lblTimeTitle, lblDateTitle,   0, 20,  0,  0);
  LTWHlbl (lblTimeValue, lblDateTitle,  90, 20, 30,  0);
  LTWHlbl (lblTZTitle,   lblDateTitle, 190, 20,  0,  0);
  LTWHlbl (lblTZValue,   lblDateTitle, 240, 20,  0,  0);

  LTWHlbl (lblDiskTitle, lblDateTitle,   0, 40, 30,  0);
  LTWHlbl (lblDiskValue, lblDateTitle,  90, 40, 30,  0);

  LTWHlbl (lblMemoryTitle, lblDateTitle,   0, 80, 90,  0);
  LTWHlbl (lblMemoryAvail, lblDateTitle,  90, 80, 90,  0);
  LTWHlbl (lblMemoryTotal, lblDateTitle, 220, 80, 90,  0);

  LTWHlbl (lblPhysicalTitle, lblDateTitle,   0, 100, 90,  0);
  LTWHlbl (lblPhysicalAvail, lblDateTitle,  90, 100, 90,  0);
  LTWHlbl (lblPhysicalTotal, lblDateTitle, 220, 100, 90,  0);

  LTWHlbl (lblPagefileTitle, lblDateTitle,   0, 120, 90,  0);
  LTWHlbl (lblPageFileAvail, lblDateTitle,  90, 120, 90,  0);
  LTWHlbl (lblPageFileTotal, lblDateTitle, 220, 120, 90,  0);

  LTWHlbl (lblVirtualTitle, lblDateTitle,   0, 140, 90,  0);
  LTWHlbl (lblVirtualAvail, lblDateTitle,  90, 140, 90,  0);
  LTWHlbl (lblVirtualTotal, lblDateTitle, 220, 140, 90,  0);

  END;  {of procedure OnCreateForm}

PROCEDURE TMain.Init;
BEGIN
  consoleOpened := FALSE;
  {Create and position (, , Left, Top) the heart beat}
  Heart.Make (hb, Self, 0, 0);

  {Create and position the ring bar}
  RingBar.Make (rb, Self, numrings, hb.Right, 0, 60, 25, 0);
  rb.IsMain := TRUE;

  {Resize main window; then allow operator to size it}
  AutoSize := TRUE;
  AutoSize := FALSE;
  Height := Height + 8;
  IF (numrings >= 7)
    THEN Width := Width + 8
    ELSE Width := Width + 90;
  END;  {of procedure Init}

PROCEDURE TMain.OnResizeForm (Sender: TObject);
BEGIN
{
  Application.MessageBox (PCHAR(IntToStr(Width)), 'Main.OnResizeForm', MB_OK);
}
  END;  {of procedure OnResizeForm}

{$H-} 
PROCEDURE TMain.UpdateIt;
{Call this routine to update realtime values displayed on main form}
VAR freespace: Int64;
    memstat: MEMORYSTATUS;
BEGIN
  IF (Self.WindowState <> wsMinimized) THEN BEGIN
  {Date information}
  lblDateValue.Caption := showdate (comd.date);
  lblDOYValue.Caption  := IntToStr (doy);
  {Time information}
  lblTimeValue.Caption := comd.time;
  lblTZTitle.Caption   := Globals.site_tz;
  lblTZValue.Caption   := FloatToStr (Globals.site_zd);

  {Primary data storage bytes still free}
  lblDiskTitle.Caption := datapath;
  freespace := bytesleft (datapath);
  IF (freespace < 5000000) THEN lblDiskValue.Font.Color := clRed;
  IF freespace > 1000000000
    THEN lblDiskValue.Caption := IntToStr (freespace DIV 1000000000) + ' GB'
    ELSE IF freespace > 1000000
      THEN lblDiskValue.Caption := IntToStr (freespace DIV 1000000) + ' MB'
    ELSE IF freespace > 1000
      THEN lblDiskValue.Caption := IntToStr (freespace DIV 1000) + ' kB'
      ELSE lblDiskValue.Caption := IntToStr (freespace);

  {Memory issues}
  GlobalMemoryStatus (memstat);  {Win32 API function}
  WITH memstat DO BEGIN
    lblPhysicalAvail.Caption := FloatToStrF(dwAvailPhys,     ffNumber,18,0);
    lblPhysicalTotal.Caption := FloatToStrF(dwTotalPhys,     ffNumber,18,0);
    lblPageFileAvail.Caption := FloatToStrF(dwAvailPageFile, ffNumber,18,0);
    lblPageFileTotal.Caption := FloatToStrF(dwTotalPageFile, ffNumber,18,0);
    lblVirtualAvail.Caption  := FloatToStrF(dwAvailVirtual,  ffNumber,18,0);
    lblVirtualTotal.Caption  := FloatToStrF(dwTotalVirtual,  ffNumber,18,0);
    END;  {of with stat}

  {Ring bar color codes}
  rb.UpdateIt;

  END;  {if not minimized}
  END;  {of procedure UpdateIt}
{$H+}
{-------------------------------------------------------------}

PROCEDURE TMain.OnKeyDownForm (
  Sender: TObject; VAR Key: Word; Shift: TShiftState);
BEGIN
  rb.Invoke(Key, Shift);
  END;  {of event handling procedure OnKeyDownForm}
{-------------------------------------------------------------}

PROCEDURE TMain.HeartBeat (which: BOOLEAN);
BEGIN
  IF (Self.WindowState <> wsMinimized) THEN
    IF Assigned(Self.hb) THEN
      Heart.Pick (Self.hb, which);
  END;  {of procedure HeartBeat}
{-------------------------------------------------------------}

PROCEDURE config (command: String; ring: INTEGER);
{Load or show FACE configuration parameters.
 These are site or computer system items distinct from
 control algorithm parameters stored in PARRn.SET files.}
CONST nl = CHR(13)+CHR(10);
      nl2 = nl+nl;
VAR drive: CHAR;
    ifn:      TEXT;
    buffer:   String;
    key:      Longint;
    matrix:   Word;
    i, j, k:  INTEGER;
    do_ring,
    do_exit:  BOOLEAN;
    filedt:   TDateTime;
    errcode:  INTEGER;
    fSuccess: BOOLEAN;

BEGIN  {body of procedure}
IF command = 'LOAD' THEN BEGIN
  {Application.MessageBox ('config/load', 'BEGIN', MB_OK);}
  frmStartup.TitleSet ('config/load...');
  frmStartup.BodyAppend ('CONFIGURATION LOAD'+nl);

  frmStartup.BodyAppend ('Searching for file '+cfgname+'...');
  Try
    Assign (ifn, cfgname);
    RESET (ifn);
    Except On Exception DO FatalErr.Msg (
      'Error opening configuration file',
      'Configuration file ' + cfgname + ' not found.' + nl2 +
      'Usage: fcp run|simulation configuration_file' + nl2 +
      'The path or filename provided either doesn''t exist or' + nl +
      'the configuration file is in another subdirectory.' + nl2 +
      'The program can not continue.');
    END;  {try}
  frmStartup.BodyAppend ('FOUND'+nl);

  {Get and save fileinfo for .exe and .cfg files}
  SysUtils.FindFirst (String(ParamStr(0)), faAnyFile, Globals.searchrec_exe);
  SysUtils.FindClose (Globals.searchrec_exe);
  SysUtils.FindFirst (cfgname, faAnyFile, Globals.searchrec_cfg);
  SysUtils.FindClose (Globals.searchrec_cfg);

  {Read in configuration data}
  frmStartup.BodyAppend ('Reading site identifier...');
  READ (ifn, key);  site_id := UpperCase (getchunk (ifn,' '));
    frmStartup.BodyAppend (site_id + nl);
    READLN(ifn);

  frmStartup.BodyAppend ('Reading site location and time zone...' + nl);
  READ (ifn, key);  READ   (ifn,site_lat,site_lon,site_alt,site_zd);
    site_tz := getchunk (ifn,' ');  READLN (ifn);
    frmStartup.BodyAppend ('Latitude: ' + FloatToStr(site_lat) + nl);
    frmStartup.BodyAppend ('Longitude: ' + FloatToStr(site_lon) + nl);
    frmStartup.BodyAppend ('Elevation: ' + FloatToStr(site_alt) + nl);
    frmStartup.BodyAppend ('Zone descriptor: ' + FloatToStr(site_zd) + nl);
    frmStartup.BodyAppend ('Time zone: ' + site_tz + nl);
    helios_site (site_lat, site_lon, site_zd);

  frmStartup.BodyAppend ('Reading number of rings...');
  READ (ifn, key);  READ   (ifn,numrings);
    frmStartup.BodyAppend (IntToStr(numrings) + nl);
    IF (numrings > maxrings) THEN BEGIN
      SetLastError ($20002001);
      FatalErr.Msg (
      'Configuration file is asking for too many rings',
      'This program supports only ' + IntToStr(maxrings) + ' replicates.' + 
      nl2 + 'Configuration file wants ' + IntToStr(numrings) +
      ' replicates.' + nl2 + 'Sorry.  Es tut mir leid.');
      END;
    frmStartup.BodyAppend ('Reading initial RingView pattern...');
    FOR j := 1 TO maxrings DO topo[j] := 0 {maxrings+1};
    FOR i := 1 TO 4 {panels in RingView} DO BEGIN
      READ (ifn, j);  
      frmStartup.BodyAppend (' ' + IntToStr(j));
      IF j IN [1..numrings] THEN topo[j] := i;
      END;
    frmStartup.BodyAppend (nl + 'Reading ring labels...');
    buffer := getchunk (ifn, ' ');
    frmStartup.BodyAppend (buffer + nl);
    FOR i := 1 TO maxrings DO BEGIN
      rlabel[i] := '*';
      IF i IN [1..numrings] THEN rlabel[i] := UpCase(buffer[i]);
      rhex[i] := 0;
      IF rlabel[i] IN ['0'..'9'] THEN rhex[i] := ORD(rlabel[i]) - ORD('0');
      IF rlabel[i] IN ['A'..'F'] THEN rhex[i] := ORD(rlabel[i]) - ORD('A') + 10;
      END;
    READLN (ifn);

  frmStartup.BodyAppend ('Reading number of vertical vent pipe valves...');
    READ (ifn, key);  READLN (ifn,numvalvs);
    frmStartup.BodyAppend (IntToStr(numvalvs) + nl);

  frmStartup.BodyAppend ('VVP pattern w/ wind up from east...');
    READ (ifn, key);  buffer := getchunk (ifn, ' ');
    frmStartup.BodyAppend (buffer + nl);
    matr := buffer + buffer + buffer + buffer;
    READLN(ifn);

  frmStartup.BodyAppend ('VVP pattern w/ wind down...');
    READ (ifn, key);  pattern_windlow := getchunk (ifn, ' ');
    frmStartup.BodyAppend (pattern_windlow + nl);
    READLN(ifn);

  frmStartup.BodyAppend ('VVP pattern w/ fumigation off...');
    READ (ifn, key);  pattern_runoff  := getchunk (ifn, ' ');
    frmStartup.BodyAppend (pattern_runoff + nl);
    READLN(ifn);

  frmStartup.BodyAppend ('VVP actuator failure pattern...');
    READ (ifn, key);  buffer := getchunk (ifn, ' ');  READLN(ifn);
    frmStartup.BodyAppend (buffer + nl);
    k := (numvalvs DIV 8);
    IF (numvalvs MOD 8) = 0 THEN DEC(k);
    FOR j := 0 TO k DO BEGIN
      vvpfailsafe[j] := 0;
      FOR i := 8 DOWNTO 1 DO BEGIN
        IF buffer[8*j+i] = '1' THEN vvpfailsafe[j] := vvpfailsafe[j] Or $1;
        IF i<>1 THEN vvpfailsafe[j] := (vvpfailsafe[j] Shl 1);
        END;
      frmStartup.BodyAppend
        ('vvpfailsafe '+IntToStr(j)+' '+IntToStr(vvpfailsafe[j])+nl);
      END;

  frmStartup.BodyAppend ('Reading data path and network path...' + nl);
    READ (ifn, key);
    datapath := UpperCase (getchunk (ifn,' '));
    netpath := UpperCase (getchunk (ifn,' '));
    frmStartup.BodyAppend (datapath + nl + netpath + nl);
    READLN(ifn);

  frmStartup.BodyAppend ('Reading data communications setup...' + nl);
  DataComm.PortGet (ifn, 10, PORT_RINGS);

  frmStartup.BodyAppend ('Reading 3D multiport link setup...' + nl);
  DataComm.PortGet (ifn, 11, PORT_MPLINK);

  frmStartup.BodyAppend ('Reading watchdog configuration...' + nl);
  DataComm.PortGet (ifn, 12, PORT_WATCHDOG);

  frmStartup.BodyAppend ('Reading gas analyzer configuration...' + nl);
  DataComm.PortGet (ifn, 13, PORT_GA);
  WITH DataComm.Ports[PORT_GA] DO BEGIN
    IF exists AND (switch = 0) THEN WITH SerialRec DO BEGIN
      fSuccess := PortOpen (PORT_GA);
      IF NOT fSuccess THEN
      PortErrorWindow (PORT_GA, 'Main/config/load: PORT_GA');
      END;
    END;

  frmStartup.BodyAppend ('Reading wind sensor configuration...' + nl);
  DataComm.PortGet (ifn, 14, PORT_WIND);
  WITH DataComm.Ports[PORT_WIND] DO BEGIN
    IF exists AND (switch = 0) THEN WITH SerialRec DO BEGIN
      fSuccess := PortOpen (PORT_WIND);
      IF NOT fSuccess THEN
      PortErrorWindow (PORT_WIND, 'Main/config/load: PORT_WIND');
      END;
    END;

  {Datalogger specificaations}
  FOR i := 1 TO maxlogger DO BEGIN
  j := 14 + i;
  frmStartup.BodyAppend ('Reading datalogger configuration...' + nl);
  DataComm.PortGet (ifn, j, PORT_LOGGER_BASE + i);
  WITH DataComm.Ports[PORT_LOGGER_BASE + i] DO BEGIN
    IF exists AND (switch = 0) THEN WITH SerialRec DO BEGIN
      fSuccess := PortOpen (PORT_LOGGER_BASE + i);
      IF NOT fSuccess THEN
      PortErrorWindow (i, 'Main/config/load: PORT_LOGGER ' +
                       IntToStr(PORT_LOGGER_BASE + i));
      END;
    END;
  END;  {loop over Datalogger configurations}

  {FCPLink specifications}
  FOR i := 1 TO maxfcplink DO BEGIN
  j := 15 + i;
  frmStartup.BodyAppend ('Reading FCP link configuration...' + nl);
  DataComm.PortGet (ifn, j, PORT_FCPLINK_BASE + i);
  WITH DataComm.Ports[PORT_FCPLINK_BASE + i] DO BEGIN
    IF exists AND (switch = 0) THEN WITH SerialRec DO BEGIN
      fSuccess := PortOpen (PORT_FCPLINK_BASE + i);
      IF NOT fSuccess THEN
      PortErrorWindow (i, 'Main/config/load: PORT_FCPLINK ' +
                       IntToStr(PORT_FCPLINK_BASE + i));
      END;
    END;
  END;  {loop over FCPLink configurations}

  {optional ambient multiport configuration file "800" line goes here}
  frmStartup.BodyAppend ('CHECKING FOR IMBEDDED MULTIPORT' + nl);
  READ (ifn, key);
  IF key = 800 THEN BEGIN
    MPSample.ambient_mp_config (getchunk (ifn, ' '));
    READLN (ifn);
    READ (ifn, key);
    END;  {optional ambient multiport configuration file name}
  {between here and the ring specific stuff MAY go netinfo file(s)}
  frmStartup.BodyAppend ('Reading network information file set ups...' + nl);
  errcode := 0;
  IF key >= 900 THEN netinfo_alloc (errcode);
  {WRITELN ('key=', key:1);}
  netinfo_check (errcode, TRUE);
  WHILE key >= 900 DO BEGIN
    netinfo_filename := getchunk (ifn, ' ');
    netinfo_eol      := getchunk (ifn, ' ');
    netinfo_sep      := getchunk (ifn, ' ');
    netinfo_writeonly := TRUE;         {May be reset in sensor def section}
    netinfo_stream    := (key = 902);  {Note special use for fast data}
    netinfo_init (key MOD 10, netinfo_filename, netinfo_eol, netinfo_sep,
                  netinfo_writeonly, netinfo_stream, errcode);
    netinfo_check (errcode, TRUE);
    READLN (ifn);
    READ (ifn, key);
    END;

  {above was for whole system; now loop over ring specific stuff}
  FOR i := 1 TO numrings DO BEGIN
    frmStartup.BodyAppend ('BEGIN SEQ '+IntToStr(i)+' RING '+rlabel[i]+nl);
    NEW (list_addr_ptr[i]);
    buffer :=        getchunk (ifn, '"');       {separator line & descriptor}
    descriptor[i] := getchunk (ifn, '"');
    frmStartup.BodyAppend (descriptor[i] + nl);
    READLN (ifn);
    WITH list_addr_ptr[i]^ DO BEGIN
      get_addr (ifn,  2, i, 1, conc_fumi);       {[gas] fumigation ring}
      get_addr (ifn,  3, i, 1, conc_cont);       {[gas] control ring}
      get_addr (ifn,  4, i, 1, conc_ambi);       {[gas] remote ambient}
      get_addr (ifn,  5, i, 1, wind_speed);
      get_addr (ifn,  6, i, 1, wind_direction);
      get_addr (ifn,  7, i, 1, pv_response);
      get_addr (ifn,  8, i, 1, pressure_atmosphere);
      get_addr (ifn,  9, i, 1, solar_radiation);
      get_addr (ifn, 10, i, 1, water_vapor);     {H2O partial pressure}
      get_addr (ifn, 11, i, 1, temp_atmosphere);
      get_addr (ifn, 12, i, 1, temp_enclosure);
      get_addr (ifn, 13, i, 1, temp_auxiliary);
      get_addr (ifn, 14, i, 1, vvp_pressure);
      get_addr (ifn, 15, i, 1, ambient_base_value);
      get_addr (ifn, 16, i, 1, pv_control);      {this is the only DAC}
      get_addr (ifn, 17, i, 0, vvp_open_fumi);   {'channel' has special meaning}
      get_addr (ifn, 18, i, 0, vvp_open_cont);   {    "      "     "       "   }
      get_addr (ifn, 19, i, 0, vvp_close);       {    "      "     "       "   }
      get_addr (ifn, 20, i, 0, fan_rotation_fumi);
      get_addr (ifn, 21, i, 0, fan_rotation_cont);
      get_addr (ifn, 22, i, 0, gas_pressure);
      get_addr (ifn, 23, i, 0, ps01);
      get_addr (ifn, 24, i, 0, ps02);
      get_addr (ifn, 25, i, 0, ps03);
      get_addr (ifn, 26, i, 0, ps04);
      get_addr (ifn, 27, i, 0, fan_onoff_fumi);
      get_addr (ifn, 28, i, 0, fan_onoff_cont);
      get_addr (ifn, 29, i, 0, gas_shutoff);
      get_addr (ifn, 30, i, 0, irga_zero);
      get_addr (ifn, 31, i, 0, irga_span);
      END;
    get_addr (ifn, 32, i, 0, pv_motor^[i].first_relay);
    READ (ifn, key);  backuppath[i] := getchunk (ifn, ' ');  READLN (ifn);
    READ (ifn, key);
    FOR j := 0 TO 12 DO BEGIN
      READ (ifn, errseq[i][j].alarm_count);
      READ (ifn, errseq[i][j].dialout_count);
      END;
    READ (ifn, message_beep_code);
    READLN (ifn);
    READLN (ifn);  {text marking end of input for this ring}
    END;
  CloseFile (ifn);
  frmStartup.BodyAppend ('Configuration load complete' + nl2);
  {pplication.MessageBox ('config/load', 'END', MB_OK);}
  END;

IF command = 'SHOW' THEN REPEAT
  ClrScr;
  filedt := SysUtils.FileDateToDateTime (Globals.searchrec_exe.Time);
  WRITE (SysUtils.UpperCase(Globals.searchrec_exe.Name):12, ' ');
  WRITE (SysUtils.FormatDateTime ('yyyy-mm-dd hh:nn:ss', filedt));
  WRITELN (Globals.searchrec_exe.Size:8, ' bytes');
  filedt := SysUtils.FileDateToDateTime (Globals.searchrec_cfg.Time);
  WRITE (SysUtils.UpperCase(Globals.searchrec_cfg.Name):12, ' ');
  WRITE (SysUtils.FormatDateTime ('yyyy-mm-dd hh:nn:ss', filedt));
  WRITELN (Globals.searchrec_cfg.Size:8, ' bytes');
  WRITE (site_id);       xywrite(20,3,-1,'SITE ID');               WRITELN;
  WRITE (site_lat:7:2);  xywrite(20,4,-1,'LATITUDE');              WRITELN;
  WRITE (site_lon:7:2);  xywrite(20,5,-1,'LONGITUDE');             WRITELN;
  WRITE (site_alt:7:2);  xywrite(20,6,-1,'ALTITUDE [M]');          WRITELN;
  WRITE (site_zd :7:2);  xywrite(20,7,-1,'ZONE DESCRIPTOR');       WRITELN;
  WRITE (numrings);  xywrite(20,8,-1,'RINGS');                     WRITELN;
  WRITE (numvalvs);  xywrite(20,9,-1,'VALVES PER RING');           WRITELN;
  WRITE (datapath);  xywrite(20,10,-1,'DATA LOGGING');             WRITELN;
  xywrite (1,13,-1,'RINGS DAQC  ');  show_port(PORT_RINGS);
  xywrite (1,14,-1,'MODEM       ');  show_port(PORT_MODEM);
  xywrite (1,15,-1,'GAS SUPPLY  ');  show_port(PORT_GAS_SUPPLY);
  xywrite (1,16,-1,'TIME SERVICE');  show_port(PORT_TIMESERV);
  xywrite (1,17,-1,'MULTIPORT   ');  show_port(PORT_MPLINK);
  xywrite (1,18,-1,'WATCHDOG    ');  show_port(PORT_WATCHDOG);
  xywrite( 1,23,-1,'Program started: '+ progload_date + '  '+ progload_time);
  xywrite (50, 1, White, '<ESC> Quit');
  xywrite (50, 2, White, '<-+>  Ring specific information');
  xywrite (50, 5, White, '<L>   LiCors');
  IF netinfo_installed THEN
  xywrite (50, 6, White, '<N>   NetInfo');
  kbin;
  do_exit := (alr = 27);
  IF (UpCase(calr) = 'L') THEN BEGIN             {LiCor's}
    licor_show (-1);
    REPEAT
      WRITELN;
      WRITE   ('For details, enter an address as xHH (or 999 to exit): ');
      saccept;
      matrix := str2word (svalue, errcode);
      IF errcode = 0 
        THEN licor_show (matrix)
        ELSE Windows.MessageBeep (MB_ICONEXCLAMATION);
      UNTIL matrix > licor_addr_max;
    END;
  IF (UpCase(calr) = 'N') AND netinfo_installed THEN BEGIN
    i := 0;
    REPEAT
      IF calr <> 'D' THEN netinfo_show (i);
      kbin;
      calr := UpCase(calr);
      IF calr = '-' THEN DEC(i);
      IF calr = '+' THEN INC(i);
      IF i < netinfo_addr_min THEN i := netinfo_addr_max;
      IF i > netinfo_addr_max THEN i := netinfo_addr_min;
      IF calr = 'D' THEN netinfo_debug := NOT netinfo_debug;
      IF calr = 'S' THEN WITH netinfo_ptr^[i] DO
        IF write_only THEN suspend := NOT suspend;
      UNTIL alr = 27;
    netinfo_debug := FALSE;
    END;
  do_ring := FALSE;
  IF calr in [' ','+','-'] THEN BEGIN
    do_ring := TRUE;
    CASE calr OF
      '+': ring := 1;
      '-': ring := numrings;
      END; {case}
    END;
  IF do_ring THEN REPEAT
    WITH list_addr_ptr[ring]^ DO BEGIN
      ClrScr;
      xywrite ( 1,1,Yellow,descriptor[ring]);
      xywrite (22,1,Red ,  'ADDR CH   RANGE  GAIN/INVERT      OFFSET  OFFSCALE');
      show_addr (conc_fumi);           
      show_addr (conc_cont);          
      show_addr (conc_ambi);          
      show_addr (wind_speed);
      show_addr (wind_direction);       
      show_addr (pv_response);
      show_addr (pressure_atmosphere);  
      show_addr (solar_radiation);      
      show_addr (water_vapor);
      show_addr (temp_atmosphere);
      show_addr (temp_enclosure);
      show_addr (vvp_pressure);
      show_addr (ambient_base_value);
      show_addr (pv_control);
      show_addr (vvp_open_fumi);
      show_addr (vvp_open_cont);
     {show_addr (vvp_close);}
      show_addr (fan_onoff_fumi);
      show_addr (fan_onoff_cont);
      show_addr (gas_shutoff);
      show_addr (fan_rotation_fumi);
      show_addr (fan_rotation_cont);
      show_addr (gas_pressure);
     {show_addr (irga_zero);}
     {show_addr (irga_span);}
      show_addr (pv_motor^[ring].first_relay);
      xywrite (68,15, Cyan+blink,  'Ring: '+rlabel[ring]);
      xywrite (68,17, Green, 'BACKUP PATH');
      xywrite (68,18, Green, backuppath[ring]);
      xywrite (68,23, White, '<ESC> Return');
      xywrite (68,24, White, '<- +> Ring #');
      kbin;
      changering (ring, numrings, calr);
      END;
    UNTIL alr = 27;
  UNTIL do_exit;
END;  {of procedure 'config'}
{------------------------------------------------------------}

PROCEDURE old_consoles;
VAR doexit: BOOLEAN;

{$H+}
FUNCTION close_handler (dwCtrlType: DWORD): BOOL;
VAR answer: INTEGER;
BEGIN
  Windows.MessageBeep (MB_ICONEXCLAMATION);
  answer := Windows.MessageBox (0,
    'Use only Main GUI Window File > Exit '+
    'to stop FACE control program.'+CHR(10)+CHR(10)+'If this message '+
    'received after End Task was selected, click No to really abort the '+
    'control program.'+CHR(10)+CHR(10)+
    'To continue control program, click YES here '+
    'and CANCEL any End Task messages.',
    'Program abort attempt trapped...',
    MB_YESNO Or MB_ICONEXCLAMATION Or MB_SYSTEMMODAL);
  close_handler := (answer = IDYES);
  END;
{$H-}

PROCEDURE utilmenu (no: INTEGER);
CONST c1 = LightRed;
      c2 = LightGreen;
      b = Blink;
      col  = 50;
      escape = 27;  {ordinal of <esc>}
VAR doexit: BOOLEAN;
BEGIN
  REPEAT
    ClrScr;
    xywrite (20 ,  1, c1, 'UTILITY MENU');
    xywrite (col,  1, c2, '<ESC> Return');
    xywrite (col,  4, c2, '<F4>  View configuration');
    xywrite (col,  5, c2, '<F5>  Data flow');
    xywrite (col,  7, c2, '<F7>  Mass flow control valve');
    GotoXY (1,24);
    kbin;
    doexit := (alr=escape);
    IF alr=0 THEN CASE ahr OF
      62: config ('SHOW', no);
      63: dataflow(0);
      65: gasflow ('SHOW', no);
      END;  {of case}
    UNTIL doexit;
  END; {of procedure 'utilmenu'}

PROCEDURE status;
CONST crlf = CHR(13)+CHR(10);
BEGIN
  ClrScr;
  xywrite(1,1,15,'MAIN CONSOLE WINDOW -- RING ' + rlabel[no]);
  xywrite(20, 5,15,'<F2>              Utilities');
  xywrite(20, 7,15,'<F3>              Algorithm');
  xywrite(20, 9,15,'<F4>              Data logging');
  xywrite(20,11,15,'<+->              Change ring');
  xywrite(20,15,15,'Hit <Esc> to cancel console window (this screen)');
  END;  {of procedure 'status'}

BEGIN
  //FreeConsole;
  //IF crt32.GetConsoleHwnd() <= 0 THEN AllocConsole
  IF consoleOpened = FALSE THEN BEGIN
	AllocConsole;
	consoleOpened := TRUE;
	END
  ELSE ShowWindow(GetConsoleWindow, SW_SHOW);

  {Disable console screen red-X}
  DeleteMenu (GetSystemMenu (GetConsoleWindow(), FALSE), SC_CLOSE, MF_BYCOMMAND);
  DrawMenuBar (GetConsoleWindow());
  SetConsoleTitle (PCHAR('FCP Console -- use <Esc> to close this window'));
  SetConsoleCtrlHandler (Addr(close_handler), TRUE);
  SetConsoleCtrlHandler (Addr(ExitProcess),   FALSE);
  crt32.init;
  ahr := 0;
  frmMain.mnuFileConsole.Hint := 'Console screen is already open';
  statscr := TRUE;

  {main menu idling loop}
  REPEAT
    status;
    kbin;
    doexit := (alr = 27);
    IF ahr=fkey[ 2]  THEN utilmenu(no);     {F2}
    IF ahr=fkey[ 3]  THEN algor(no);        {F3}
    IF ahr=fkey[ 4]  THEN datlog(no);       {F4}
    changering (no, numrings, calr);  {+ - ring number}
    UNTIL doexit;

  statscr := FALSE;
  frmMain.mnuFileConsole.Hint := '';

  ShowWindow(GetConsoleWindow, SW_HIDE);
  END;  {of procedure 'old_consoles'}
{-------------------------------------------------------------}

PROCEDURE ListComponents;
CONST nl = CHR(13) + CHR(10);
VAR i: INTEGER;
    frmCompList: TLblForm;
BEGIN
  IF NOT Assigned (frmCompList) THEN
    frmCompList := TLblForm.Create (Application);
  WITH frmCompList DO BEGIN
    Display (
      'Current application component list -- does not autorefresh', '');
    FOR i := 0 TO Application.ComponentCount - 1 DO
      BodyAppend (
        '[' + IntToStr(i) + '] ' + Application.Components[i].Name + nl);
    END;  {with}
  END;  {of procedure ListComponents}
{-------------------------------------------------------------}

PROCEDURE TMain.OnClickMenu (Sender: TObject);
BEGIN
  IF (Sender = mnuFileDataBackup)            THEN Backup.Select;
  IF (Sender = mnuFileConsole) AND
     (NOT statscr)                           THEN old_consoles;
  IF (Sender = mnuFileExit) THEN frmMain.Perform (WM_CLOSE, 0, 0);
  IF (Sender = mnuRingPictures)              THEN ringv;
  IF (Sender = mnuCalibrationAutomatic)      THEN CalibAut.Select;
  IF (Sender = mnuCalibrationManual)         THEN CalibMan.Select;
  IF (Sender = mnuCompare)                   THEN Compare.Select;
  IF (Sender = mnuConfigDataComm)            THEN DataComm.Select;
  IF (Sender = mnuConfigMPSample)            THEN MPSample.Select;
  IF (Sender = mnuConfigNetLog)              THEN NetLog.Select;
  IF (Sender = mnuConfigWatchdog)            THEN Watchdog.Select;
  IF (Sender = mnuConfigConnect)             THEN Connect.Select;
  IF (Sender = mnuDataflowMPSample)          THEN MPSample.Select;
  IF (Sender = mnuSunEphemeris)              THEN Ephem.Select;
  IF (Sender = mnuWaterVapor)                THEN H2OVapor.Select;
  IF (Sender = mnuHelpDiagnosticsComponents) THEN ListComponents;
  END;  {of procedure OnClickMenu}
{-------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of form unit 'Main'...}
END.
