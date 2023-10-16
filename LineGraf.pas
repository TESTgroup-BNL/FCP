UNIT LineGraf;

{
Line graphs

v01.01 2003-01-31 Original using code from comdis, comda, gra
v01.02 2003-03-14 Use an Image instead of PaintBox
v01.03 2003-03-14 Add HeartBeat and skeleton for UpdateIp
v01.04 2003-03-14 LG_ constants moved here from LGSetup
v01.05 2003-03-15 Add Cancel and Help buttons; Averaging checkbox
v01.06 2003-03-16 Begin adding code to draw graphs
v01.07 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.08 2003-05-25 OnDestroyForm: added back; Self := NIL;
v01.09 2003-05-27 Replace OnKeyPressForm by OnKeyDownForm
v01.10 2003-05-28 comd/Globals changes
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QExtCtrls, QForms, QGraphics, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, ExtCtrls, Forms, Graphics, StdCtrls,
  Classes, Windows,
{$ENDIF}
  Heart, LblForm, RingBar,
  faced, 
  comd, Globals;

CONST
  LG_GROUP_LOGG      = 1;
  LG_GROUP_VARR      = 2;
  LG_GROUP_AUX       = 3;
  LG_GROUP_SNAPSHOT  = 4;
  LG_GROUP_MAX       = 4;
  LG_PERIOD_HISTORIC = 1;
  LG_PERIOD_RECENT   = 2;
  LG_PERIOD_CURRENT  = 3;
  LG_PERIOD_MAX      = 3;

CONST
  LG_GROUP_NAMES: ARRAY [1..LG_GROUP_MAX] OF STRING =
    ('LOGG file',
     'VARR file',
     'Auxiliary',
     'Snap shot');

TYPE
  TfrmLineGraf = CLASS(TForm)
    imageLG: TImage;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    cbAveraging: TCheckBox;
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
    PROCEDURE OnKeyDownForm (Sender: TObject; VAR Key: Word; Shift: TShiftState);
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE Refresh;
    PRIVATE
      { Private declarations }
      FRing: INTEGER;
      FGroup: INTEGER;
      FPeriod: INTEGER;
      rb: TRingBar;
      hb: THeartBeat;
      FUNCTION scalex (x: Single): INTEGER;
      FUNCTION scaley (y: Single): INTEGER;
    PUBLIC
      { Public declarations }
    END;

VAR
  {Dynamic (current & recent) graphs must be visible for UpdateIt calls}
  frmLG: 
    ARRAY [1..maxrings, 1..LG_GROUP_MAX, 1..LG_PERIOD_MAX] OF TfrmLineGraf;

PROCEDURE Select   (ring, group, period: INTEGER);
PROCEDURE UpdateIt (ring, group, period: INTEGER);
PROCEDURE HeartBeat (ring, group, period: INTEGER; which: BOOLEAN);

IMPLEMENTATION

CONST
  {width and height of all command buttons used on window}
  BUTTON_WIDTH  = 80;
  BUTTON_HEIGHT = 25;

VAR
  {A pool of handles for special graphs -- no implementation yet}
  frmLGScratch: ARRAY [1..16] OF TfrmLineGraf;
  {Help screen}
  frmHelp: TLblForm;

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE TfrmLineGraf.OnCreateForm (Sender: TObject);
BEGIN
  {Let form preview key strokes}
  KeyPreview := TRUE;

  WITH Self DO BEGIN
    {Size and position the whole window on the desktop}
    Show;
    Left := 0;
    Top := 0;
    Width := Screen.DesktopWidth;
    Height := Screen.DesktopHeight - 24;
    {Create and position (, , Left, Top) the heart beat}
    Heart.Make (hb, Self, 0, 0);
    {Create and position ring bar}
    RingBar.Make (rb, Self, numrings, 
                  hb.Right, 0, 60, BUTTON_HEIGHT, 0);
    {Size and position image area}
    WITH imageLG DO BEGIN
      Left := 0;
      Top := rb.Bottom + 4;
      Width := Self.Width - 8;
      Height := ROUND (3.0/4.0 * Self.Height);
      END;
    {Size and position the command buttons}
    WITH btnCancel DO BEGIN
      Width := BUTTON_WIDTH;
      Height := BUTTON_HEIGHT;
      Left := Self.Width - Width - 8;
      Top := 0;
      END;
    WITH btnHelp DO BEGIN
      Width := BUTTON_WIDTH;
      Height := BUTTON_HEIGHT;
      Left := btnCancel.Left - ROUND (1.1 * Width);
      Top := 0;
      END;
    {Size and position the averaging checkbox}
    WITH cbAveraging DO BEGIN
      Width := BUTTON_WIDTH;
      Height := BUTTON_HEIGHT;
      Left := btnHelp.Left - ROUND (1.1 * Width);
      Top := 0;
      END;
    END;
  
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TfrmLineGraf.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  Self := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TfrmLineGraf.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  Self := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TfrmLineGraf.OnKeyDownForm (
  Sender: TObject; VAR Key: Word; Shift: TShiftState);
{Note: the Cancel command button takes care of <Esc>}
BEGIN
  {MessageBox (0, PCHAR(String(CHR(Key))), 'LineGraf', MB_OK);}
  IF (Key = VK_SUBTRACT) OR (Key = 189)
    THEN rb.ChangeRing (FRing-1)
    ELSE IF (Key = VK_ADD) OR (Key = 187)
      THEN rb.ChangeRing (FRing+1)
      ELSE rb.Invoke (Key, Shift);
  END;  {of event handling procedure OnKeyDownForm}
{-------------------------------------------------------------}

PROCEDURE TfrmLineGraf.OnClickButton (Sender: TObject);
CONST nl = CHR(13)+CHR(10);
      nl2 = nl+nl;
VAR header, body: String;
BEGIN

  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmLG[FRing, FGroup, FPeriod] := NIL;
    END;  {of cancel button}
  
  IF (Sender = btnHelp) THEN BEGIN
    header := 'Help using Line Graph displays';
    body :=
'UpArrow or DownArrow moves display forward or back in time' + nl +
'by pages (180 data points).  (Historic & SnapShot only)' + nl2 +
'Cursor can be moved with RightArrow and LeftArrow.' + nl +
'Values under the cursor appear in the text area' + nl +
'unless the averaging box is checked.' + nl2 +
'Ctrl-RightArrow and Ctrl-LeftArrow move cursor in steps of 10.' + nl2 +
'The Averaging checkbox causes the average of values on the graph' + nl +
'to be displayed in the text area.' + nl2 +
'Left-clicking a ring on the RingBar causes the ring currently' + nl +
'displayed to be closed and a new one opened with the same selections.' + nl2 +
'Right-clicking any ring on the RingBar can be used to open' + nl +
'another graph window.'
;
    frmHelp := TLblForm.Create (Application);
    frmHelp.Display (header, body);
    END;  {of help button}

  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TfrmLineGraf.Refresh;
VAR objnum: INTEGER;
    i1, i2, j1, j2: INTEGER;  {pixels in imageLG space} 
BEGIN
  WITH imageLG DO BEGIN
    {Erase the blackboard}
    Canvas.Brush.Color := clBlack;
    Canvas.FillRect (Rect (0, 0, Width, Height));

    {Draw grid lines, ticks, etc.}
    WITH disprecord^[FRing].dspl[FGroup] DO
      FOR objnum := max_dsplobj DOWNTO 1 DO
        WITH obj[objnum] DO
          IF exists AND enabled THEN BEGIN
            Canvas.Pen.Color := color;
            Canvas.MoveTo (0, scaley (offset));
            Canvas.LineTo (Width, scaley (offset));
            END;

    Repaint;
    END;
  END;  {of procedure Refresh}
{-------------------------------------------------------------}

PROCEDURE Select (ring, group, period: INTEGER);
{Come here when this menu item selected on a form}
BEGIN
  IF NOT Assigned (frmLG[ring, group, period]) THEN BEGIN 
    frmLG[ring, group, period] := TfrmLineGraf.Create (Application);
    END;
  WITH frmLG[ring, group, period] DO BEGIN
    FRing := ring;
    FGroup := group;
    FPeriod := period;
    rb.ButtonDown (ring);
    CASE period OF
      LG_PERIOD_CURRENT:  Caption := 'Real-time';
      LG_PERIOD_RECENT:   Caption := 'Most recent';
      LG_PERIOD_HISTORIC: Caption := 'Historic';
      END; {case}
    Caption := Caption + ' line graphs for Ring ' + rlabel[ring] +
               ':  ' + LG_GROUP_NAMES[group];
    Show;
    SetFocus;
    Refresh;
    END;

  END;  {of procedure Select}
{-------------------------------------------------------------}

PROCEDURE UpdateIt (ring, group, period: INTEGER);
{Come here at end of every sample/control period}
BEGIN
  IF Assigned (frmLG[ring, group, period]) THEN 
  IF (frmLG[ring, group, period].WindowState <> wsMinimized) THEN
  WITH frmLG[ring, group, period] DO BEGIN
    
    {Ring bar color codes}
    rb.UpdateIt;

    END;  {object Assigned}
  END;  {of procedure UpdateIt}
{-------------------------------------------------------------}

PROCEDURE HeartBeat (ring, group, period: INTEGER; which: BOOLEAN);
BEGIN
  IF Assigned (frmLG[ring, group, period]) THEN 
  IF (frmLG[ring, group, period].WindowState <> wsMinimized) THEN
  IF Assigned(frmLG[ring, group, period].hb) THEN
    Heart.Pick (frmLG[ring, group, period].hb, which);
  END;  {of procedure HeartBeat}
{-------------------------------------------------------------}

FUNCTION TfrmLineGraf.scalex (x: Single): INTEGER;
BEGIN
  scalex := TRUNC (x * imageLG.Width);
  END;  {of function 'scalex'}

FUNCTION TfrmLineGraf.scaley (y: Single): INTEGER;
BEGIN
  scaley := TRUNC ((1.0-y) * imageLG.Height);
  END;  {of function 'scaley'}
{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  END;

FINALIZATION

BEGIN
  END;
{of form unit LineGraf...} END.
