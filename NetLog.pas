Unit NetLog;
{$R+} {Range checking ON}
{
Form to display status of logging to network.
Contains the procedures used to log to the network.

v01.01 2003-05-31 Original. Material from many sources. Based on Connect.
v01.02 2003-06-01 Add clear button.
v01.03 2003-06-13 Add OnCloseForm calls OnClickCancel btnCancel
v01.04 2003-06-13 Replace OnCloseClient, OnDestroyClient by OnCloseForm
v01.05 2003-06-14 Hide btnApply; use new btnRefresh in TTemplate
v01.06 2006-03-17 Remove Uses tp5utils & Add Uses COMU, Sol
                  logg2net: replace errstring by SysUtils.SysErrorMessage
                  OnClickButton: add local var rno for looping
v01.07 2012-04-24 ivw & fvw: replace msg + ' ' by msg + ','
  make_msg        fulldate: replace '/' by '-'
                  d1990: delete from output record
                  suntime, sunstr: deleted
                  sunazi: added to output record
                  ssite: delete from output record
                  ring: 1..15 replace by rlabel[ring] '1'..'F'
                  conditions OK: delete from output record
                  temperature OK: add to output record
                  wind OK: add to output record
                  gas type: delete from output record
  logg2net        remove all Application.MessageBox ('Marker x', 'logg2net', 0);
                  add call to header() after REWRITE
  header          new procedure
  AssignFiles     extension changed from .NET to .CSV
v01.08 2012-05-01 logg2net: only write values for current record
                  make_msg: make ascii string using current variables
v01.09 2012-09-16 Recode to write weekly files Mon..Sun instead of continuous
                  Interface/Uses: add DateUtils (for DayOfTheWeek)
                  Delete procedure AssignFiles
                  Change solar radiation header from FLUX to RSOL
v01.10 2018-03-06 logg2net: lift fast CSV recording restriction
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, StdCtrls,
{$ENDIF}
  SysUtils, DateUtils,
  Sol, comu, comd, faced,
  Template, Globals;

TYPE
  TNetLog = CLASS(TTemplate)
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnClickButton (Sender: TObject);
    PRIVATE
      { Private declarations }
      lblStatus: TLabel;
      PROCEDURE MakeChildren;
      PROCEDURE Refresh;
    PUBLIC
      { Public declarations }
    END;

FUNCTION GetLastError (ring: INTEGER): INTEGER;
PROCEDURE logg2net (ring: INTEGER);
PROCEDURE Select;

IMPLEMENTATION

CONST nl = CHR(13) + CHR(10);

VAR frmNetLog: TNetLog;

VAR net_logg: ARRAY [1..maxrings] OF RECORD  
                                       handle:   TEXT;
                                       filename: String;
                                       badcount: Longint;
                                       lasterr:  INTEGER;
                                       lastdt,
                                       lastmsg:  String;
                                       END;

VAR ring: INTEGER;

{-------------------------------------------------------------}

FUNCTION GetLastError (ring: INTEGER): INTEGER;
BEGIN
  GetLastError := net_logg[ring].lasterr;
  END;  {of function GetLastError}
{-------------------------------------------------------------}

PROCEDURE make_msg (ring: INTEGER; VAR msg: String);
{Used by procedure logg2net}

VAR status: WORD;

PROCEDURE ivw (value, cols: INTEGER);
VAR s: String;
    i: Integer;
BEGIN
  Str (value:cols, s);
  IF (Length(s) > cols) THEN BEGIN
    s := '';
    FOR i := 1 TO cols DO s := s + ' ';
    END;
  msg := msg + ',' + s;
  END;  {of local procedure 'ivw'}

PROCEDURE fvw (value: Double; cols, decpts: INTEGER);
VAR s: String;
    i: Integer;
BEGIN
  Str (value:cols:decpts, s);
  IF (Length(s) > cols) THEN BEGIN
    s := '';
    FOR i := 1 TO cols DO s := s + ' ';
    END;
  msg := msg + ',' + s;
  END;  {of local procedure 'fvw'}

BEGIN

  msg := rlabel[ring];

  msg := msg + ',' + showdate(comd.date);
  msg := msg + ',' + comd.time;

  fvw (Sol.helios_var.sun_alt.degrees, 6, 2);
  fvw (Sol.helios_var.sun_azi.degrees, 3, 0);

  status := status_var[ring].latched;

  ivw ((status Shr 4) And 3, 1);  {treatment mode}

  ivw (1-((status Shr  7) And 1), 1);    {fumigation enabled}
  ivw (1-((status Shr  9) And 1), 1);        {temperature OK}
  ivw (1-((status Shr 15) And 1), 1);               {wind OK}
  ivw (ORD(((status Shr  6) And 3) = 0), 1);  {fumigation ON}

  ivw ((status Shr  8) And 1 {debugging}, 1);

  ivw ((status Shr 11) And 1 {calibenab}, 1);
  ivw ((status Shr 10) And 1 {calibact},  1);

  ivw ((status Shr 12) And 1 {alarm_pv},  1);
  ivw ((status Shr 13) And 1 {alarm_gc},  1);
  ivw ((status Shr 14) And 1 {alarm_dc},  1);

  fvw (wspeed[ring],                  5, 2);
  WITH wspeed_avsd[ring] DO
    IF mean > 0.0
      THEN fvw (stddev/mean,          4, 2)
      ELSE fvw (0.0,                  4, 2);
  ivw (wwdir[ring],                   3);
  ivw (ROUND(stdwdir[ring].Integral), 3);
  fvw (temp1[ring],                   5, 1);
  fvw (temp2[ring],                   5, 1);
  fvw (temp3[ring],                   5, 1);
  fvw (10.0*airpres[ring],            4, 0);
  fvw (ph2o[ring],                    4, 0);
  fvw (solrad[ring],                  4, 0);
  fvw (propc[ring],                   6, 1);
  fvw (propresp[ring],                6, 1);
  fvw (gcambi[ring],                  6, 1);
  fvw (gccntl[ring],                  6, 1);
  fvw (ambient_base.Integral,         6, 1);
  fvw (gcset[ring],                   6, 1);
  fvw (gcgrab[ring],                  6, 1);
  fvw (agc1m[ring].Integral,          6, 1);
  fvw (agc5m[ring].Integral,          6, 1);

  END;  {of procedure 'make_msg'}
{-------------------------------------------------------------}

PROCEDURE header (VAR f: TEXT);
BEGIN
  WRITE (f,'P,');
  WRITE (f,'      DATE,');
  WRITE (f,'    TIME,');
  WRITE (f,'SUNALT,');
  WRITE (f,'AZI,');
  WRITE (f,'M,');
  WRITE (f,'E,');
  WRITE (f,'T,');
  WRITE (f,'W,');
  WRITE (f,'F,');
  WRITE (f,'D,');
  WRITE (f,'C,');
  WRITE (f,'X,');
  WRITE (f,'V,');
  WRITE (f,'G,');
  WRITE (f,'Q,');
  WRITE (f,'   WS,');
  WRITE (f,' COV,');
  WRITE (f,' WD,');
  WRITE (f,'STD,');
  WRITE (f,' TAIR,');
  WRITE (f,'TENCL,');
  WRITE (f,' TAUX,');
  WRITE (f,'  BP,');
  WRITE (f,' H2O,');
  WRITE (f,'RSOL,');
  WRITE (f,'   PVC,');
  WRITE (f,'   PVR,');
  WRITE (f,'  CAMB,');
  WRITE (f,' CCONT,');
  WRITE (f,' CBASE,');
  WRITE (f,'  CSET,');
  WRITE (f,' CGRAB,');
  WRITE (f,' C1MIN,');
  WRITE (f,' C5MIN');
  WRITELN (f);
  END;  {of procedure 'header'}
{-------------------------------------------------------------}

PROCEDURE debug_output (s: String);
BEGIN
  WITH frmNetLog.lblStatus DO Caption := Caption + s + nl;
  END;  {of procedure 'debug_output'}
{-------------------------------------------------------------}

PROCEDURE logg2net (ring: INTEGER);
VAR ior:      INTEGER;
    msg:      String;
    filename: String;
    flag:     String;
    debug:    BOOLEAN;
BEGIN
  debug := Assigned (frmNetLog);
  IF debug THEN debug_output (nl + 'Net logging for ring ' + IntToStr(ring));

  WITH net_logg[ring] DO BEGIN
    lasterr := -1;
    lastdt  := FormatDateTime ('yyyy-mm-dd hh:nn:ss', Now);
    END;

  WITH net_logg[ring] DO
  IF (netpath = 'NONE')
  THEN lastmsg := 'No netpath defined in .CFG'

  {...Lift fast CSV logging restriction
  ELSE IF (timestep[1] < 55)
  THEN lastmsg := 'No fast datalogging to net'
  ...}

  ELSE BEGIN
    IF simul_mode THEN flag := 'S' ELSE flag := '';
    filename := netpath +
                'LOGG' +
                rlabel[ring] +
                flag +
                '-' +
                FormatDateTime ('yyyymmdd', Now - (DayOfTheWeek(Now)-1)) + 
                '.CSV';
    AssignFile (handle, filename);
    {$I-}
    RESET (handle);
    ior := IOResult;
    IF debug THEN debug_output ('logg2net ior: reset = ' + IntToStr(ior));
    IF (ior = 2) THEN BEGIN  {"File not found" only !!!}
      lastmsg := 'Creating '+ filename;
      REWRITE (handle);
      ior := IOResult;
      IF debug THEN debug_output ('logg2net ior: rewrite = ' + IntToStr(ior));
      header (handle);
      END;
    CloseFile (handle);
    Append (handle);
    IF (ior = 0) THEN BEGIN
      make_msg (ring, msg);
      WRITELN (handle, msg);
      ior := IOResult;
      IF debug THEN debug_output ('logg2net ior: writing = ' + IntToStr(ior));
      END;

    IF (ior <> 0) THEN INC (badcount);
    lasterr := ior;
    lastmsg := SysUtils.SysErrorMessage (ior);
    CloseFile (handle);
    ior := IOResult;  {to clear it}
    IF debug THEN debug_output ('logg2net ior: close = ' + IntToStr(ior));
    {$I+}
    END;
  IF debug THEN frmNetLog.Refresh;
  END;  {procedure 'logg2net'}
{---------------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on main form}
BEGIN
  IF NOT Assigned (frmNetLog) THEN BEGIN
    frmNetLog := TNetLog.Create (Application);
    frmNetLog.MakeChildren;
    END;
  frmNetLog.Show;
  frmNetLog.SetFocus;
  frmNetLog.WindowState := wsNormal;
  frmNetLog.Refresh;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE TNetLog.Refresh;
{Refresh the network logging status information}
VAR ring: INTEGER;
BEGIN
  WITH lblStatus DO BEGIN
    Caption := '';
    FOR ring := 1 TO numrings DO WITH net_logg[ring] DO BEGIN
      Caption := Caption +
        'Ring ' + rlabel[ring] + ':  ' +
        lastdt + '  ' +
        filename + '  ' +
        IntToStr (badcount) + '  ' +
        lastmsg +
        ' [' + IntToStr (lasterr) + ']' + nl;
      END;  {for rings}
    Self.Height := Top + Height + 50;
    END;  {with lblStatus}
  END;  {of procedure 'Refresh'}
{-------------------------------------------------------------}

PROCEDURE TNetLog.MakeChildren;
BEGIN
  {Form parameters}
  With Self DO BEGIN
    Font.Height := -11;
    Caption := 'Network logging status';
    Left := 0;
    Width := Screen.Width - 100;
    OnClose := OnCloseForm;
    END;

  {Command buttons}
  WITH btnCancel DO BEGIN
    Left := 10;
    Top := 10;
    OnClick := OnClickButton;
    END;
  WITH btnRefresh DO BEGIN
    Left := btnCancel.Left + btnCancel.Width + 20;
    Top := btnCancel.Top;
    OnClick := OnClickButton;
    END;
  WITH btnApply DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  WITH btnOK DO BEGIN
    Caption := 'C&lear';
    Left := btnRefresh.Left + btnRefresh.Width + 20;
    Top := btnCancel.Top;
    OnClick := OnClickButton;
    END;
  WITH btnHelp DO BEGIN
    Visible := FALSE;
    Enabled := FALSE;
    END;
  
  {Status}
  lblStatus := TLabel.Create (Self);
  WITH lblStatus DO BEGIN
    Parent := Self;
    Left := btnCancel.Left;
    Top := btnCancel.Top + btnCancel.Height + 20;
    Caption := 'lblStatus';
    END;  {with}

  END;  {of procedure MakeChildren}
{-------------------------------------------------------------}

PROCEDURE TNetlog.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
BEGIN
  OnClickButton (TObject(btnCancel));
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TNetLog.OnClickButton (Sender: TObject);
VAR rno: INTEGER;
BEGIN

  IF (Sender = btnRefresh) THEN BEGIN
    {Latch current net_logg contents onto form}
    Refresh;
    END;

  IF (Sender = btnOK) THEN BEGIN
    FOR rno := 1 TO maxrings DO WITH net_logg[rno] DO BEGIN
      badcount := 0;
      lastdt := FormatDateTime ('yyyy-mm-dd hh:nn:ss', Now);
      lasterr  := -1;
      lastmsg  := 'Cleared';
      END;
    Refresh;
    END;
  
  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmNetLog := NIL;
    END;
  
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  FOR ring := 1 TO maxrings DO WITH net_logg[ring] DO BEGIN
   {handle   := NIL;}
    filename := '';
    badcount := 0;
    lasterr  := -2;
    lastmsg  := 'Program startup';
    END;
  END;

FINALIZATION

BEGIN
  END;

{of unit NetLog...} END.
