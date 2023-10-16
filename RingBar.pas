UNIT RingBar;
{
RingBar control

Shows color-coded status of each ring
Click to open information windows

v 01.01  2002-11-13  Original
v 01.02  2002-11-16  Add invoking Alarms from popup menu
v 01.03  2002-11-16  Add method ButtonDown (down and bold)
v 01.04  2002-12-08  Use ColBtn instead of janColorButton
                     Add FIsMain and property IsMain
                     Add method ButtonUp (up and regular)
                     Add method ChangeRing
v 01.05  2003-01-09  mnuGraphs invokes LGSelect.Select
v 01.06  2003-01-10  Selected ring will have larger font size
v 01.07  2003-01-26  Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v 01.08  2003-01-30  Make & ButtonUp: Font.Size 10 --> Font.Height -14
                     ButtonDown:      Font.Size 12 --> Font.Height -16
v 01.09  2003-02-03  Add fields FRight and FBottom for postioning other controls
                     Add read-only properties Right and Bottom
                     Make: calculate right side and bottom of the RingBar
v 01.10  2003-05-27  Invoke: change from KeyPress to KeyDown orientation
                     Invoke: add IF (key = VK_F2) THEN Alarms.FirstAlarmPage
                     Add USES Classes for TShiftState & Windows for VK_*
v 01.11  2003-05-28  Linux/Types and MSWindows/Classes
                     comd/Globals changes
                     move RingColor* routines here from comd
v 01.12  2003-05-30  Invoke: remove FirstAlarmPage call (see Services)
v 01.13  2004-03-01  Make: narrow ring buttons if Number > 8
}

Interface

{See also Implementation Uses}

USES
{$IFDEF LINUX}
  QControls, QForms, QGraphics, QMenus,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Controls, Forms, Graphics, Menus,
  Windows, Classes,
{$ENDIF}
  ColBtn,
  Globals;

TYPE
  TRingBar = class(TWinControl)
  private
    { Private declarations }
    FIsMain:   BOOLEAN;
    FNumber:   INTEGER;
    FHeight:   INTEGER;
    FRight:    INTEGER;
    FBottom:   INTEGER;
    PopupMenu: TPopupMenu;
    Buttons:   ARRAY [1..maxrings] OF TColBtn;
  protected
  public
    { Public declarations }
    PROCEDURE UpdateIt;
    PROCEDURE Invoke (key: Word; shift: TShiftState);
    PROCEDURE ChangeRing (ring_new: INTEGER);
    PROCEDURE RingButtonClick (Sender: TObject);
    PROCEDURE PopupClick (Sender: TObject);
    PROCEDURE ButtonDown (ring: INTEGER);
    PROCEDURE ButtonUp (ring: INTEGER);
    PROPERTY IsMain: BOOLEAN READ FIsMain WRITE FIsMain;
    PROPERTY Right: INTEGER READ FRight;
    PROPERTY Bottom: INTEGER READ FBottom;
  published
  end;


PROCEDURE Make (VAR ARingBar: TRingBar;
                AOwner: TForm;
                Number: INTEGER;
                LLeft, TTop, WWidth, HHeight, Spacing: INTEGER);

FUNCTION  RingColorValueGet  (which, ring: INTEGER): INTEGER;
PROCEDURE RingColorValueSet  (which, ring, color: INTEGER);
FUNCTION  RingColorToggleGet (ring: INTEGER): BOOLEAN;
PROCEDURE RingColorToggleSet (ring: INTEGER; toggle: BOOLEAN);
FUNCTION  RingColorToggleMasterGet: BOOLEAN;
PROCEDURE RingColorToggleMasterSet (toggle: BOOLEAN);

Implementation

USES
  Alarms, LGSelect, Status;

VAR RingColorValue:  ARRAY [1..2, 1..maxrings] OF INTEGER;
    RingColorToggle: ARRAY [1..maxrings] OF BOOLEAN;
    RingColorToggleMaster: BOOLEAN;

PROCEDURE Make (VAR ARingBar: TRingBar;
                AOwner: TForm;
                Number: INTEGER;
                LLeft, TTop, WWidth, HHeight, Spacing: INTEGER);
VAR ring: INTEGER;
    newitem: TMenuItem;
BEGIN
  {Instantiate a RingBar object}
  ARingBar := TRingbar.Create (AOwner);

  {Non-main screen by default.  Use IsMain := TRUE for main screen.}
  ARingBar.FIsMain := FALSE;

  {Save some information for other calls}
  ARingBar.FNumber := Number;
  ARingBar.FHeight := HHeight;

  {Make the popup menu}
  WITH ARingBar DO BEGIN
    PopupMenu := TPopupMenu.Create (AOwner);
    newitem := TMenuItem.Create (PopupMenu);
      PopupMenu.Items.Add (newitem);
      newitem.Name    := 'mnuStatus';
      newitem.Caption := '&Status';
      newitem.OnClick := PopupClick;
    newitem := TMenuItem.Create (PopupMenu);
      PopupMenu.Items.Add (newitem);
      newitem.Name    := 'mnuGraphs';
      newitem.Caption := '&Graphs';
      newitem.OnClick := PopupClick;
    newitem := TMenuItem.Create (PopupMenu);
      PopupMenu.Items.Add (newitem);
      newitem.Name    := 'mnuAlarms';
      newitem.Caption := '&Alarms';
      newitem.OnClick := PopupClick;
    newitem := TMenuItem.Create (PopupMenu);
      PopupMenu.Items.Add (newitem);
      newitem.Name    := 'mnuDataflow';
      newitem.Caption := '&Data flow';
      newitem.OnClick := PopupClick;
    newitem := TMenuItem.Create (PopupMenu);
      PopupMenu.Items.Add (newitem);
      newitem.Name    := 'mnuSetup';
      newitem.Caption := 'Se&tup';
      newitem.OnClick := PopupClick;
    END;

  {Create a bar of ring buttons across the group box}
  FOR ring := 1 TO Number DO WITH ARingBar DO BEGIN
    Buttons[ring] := TColBtn.Create (AOwner);
    WITH Buttons[ring] DO BEGIN
      Parent := AOwner;
      IF (Number <= 8)
        THEN Width := WWidth
        ELSE Width := WWidth Div 2;
      Height := HHeight;
      Top := TTop;
      Left := LLeft + (ring-1) * (Width + Spacing);
      MarginHorizontal := 4;
      MarginVertical := 2;
      IF (Number <= 8) THEN Caption := 'Ring ';
      Caption := Caption + rlabel[ring];
      Font.Height := -14;
      Flat := FALSE;
      Latching := FALSE;
      HotColor  := clWhite;
      OnClick := RingButtonClick;
      FRight := Left + Spacing;
      FBottom := Top + Height;
      END;  {with}
    END;  {if}
  END;  {of procedure Make}

PROCEDURE TRingBar.UpdateIt;
{Ring button color codes}
VAR ring: INTEGER;
    btn_color: TColor;
BEGIN
  FOR ring := 1 TO FNumber DO BEGIN
    btn_color := clAqua;
    IF RingColorToggleGet (ring) AND RingColorToggleMasterGet
      THEN btn_color := RingColorValueGet (1, ring)
      ELSE btn_color := RingColorValueGet (2, ring);
    WITH Buttons[ring] DO BEGIN
      Color     := btn_color;
      DownColor := btn_color;
      END;
    END;  {of ring loop}
  END;  {of procedure 'UpdateIt'}

PROCEDURE TRingBar.Invoke (key: Word; shift: TShiftState);
{Clients send commands to this object using key codes}
VAR ring: INTEGER;
    code: CHAR;
BEGIN
  ring := 0;
  code := UpCase(CHR(key And $FF));
  IF (code IN ['1'..'9']) THEN ring := ORD(code)-ORD('0');
  IF (code IN ['A'..'F']) THEN ring := ORD(code)-ORD('A')+10;
  IF (ring IN [1..FNumber]) THEN BEGIN
    Buttons[ring].WhichMouseClick := mbLeft;
    RingButtonClick (Buttons[ring]);
    END;
  END;  {of procedure 'Invoke'}

PROCEDURE TRingBar.ChangeRing (ring_new: INTEGER);
VAR ring_old: INTEGER;
    found: BOOLEAN;
BEGIN
  IF (ring_new > FNumber) THEN ring_new := 1;
  IF (ring_new < 1      ) THEN ring_new := FNumber;
  found := FALSE;
  FOR ring_old := 1 TO FNumber DO
    IF (Owner = frmAlarms[ring_old]) AND (NOT found) THEN BEGIN
      found := TRUE;
      IF (ring_new <> ring_old) THEN BEGIN
        IF NOT Assigned (frmAlarms[ring_new]) THEN BEGIN
          ButtonUp (ring_old);
          frmAlarms[ring_new] := frmAlarms[ring_old];
          {
          frmAlarms[ring_old].Release;
          }
          frmAlarms[ring_old] := NIL;
          END;
        Alarms.Select (ring_new);
        END;
      END;
  IF NOT found THEN FOR ring_old := 1 TO FNumber DO
    IF (Owner = frmStatus[ring_old]) AND (NOT found) THEN BEGIN
      found := TRUE;
      IF (ring_new <> ring_old) THEN BEGIN
        IF NOT Assigned (frmStatus[ring_new]) THEN BEGIN
          ButtonUp (ring_old);
          frmStatus[ring_new] := frmStatus[ring_old];
          {
          frmStatus[ring_old].Release;
          }
          frmStatus[ring_old] := NIL;
          END;
        Status.Select (ring_new);
        END;
      END;
  END;  {of procedure ChangeRing}

PROCEDURE TRingBar.RingButtonClick (Sender: TObject);
VAR ring, ring_selected: INTEGER;
    whereX, whereY: INTEGER;
BEGIN
  ring_selected := -1;
  FOR ring := 1 TO FNumber DO
    IF (Sender = Buttons[ring]) 
      THEN ring_selected := ring
      ELSE Buttons[ring].Down := FALSE;
  IF FIsMain OR (Buttons[ring_selected].WhichMouseClick = mbRight)
    {popup menu if ringbar on main screen or right click}
    THEN BEGIN
      WITH Buttons[ring_selected].ClientOrigin DO BEGIN
        whereX := X;
        whereY := Y + FHeight;;
        END;
      PopupMenu.Tag := ring_selected;
      PopupMenu.Popup (whereX, whereY);
      END
    {change ring being displayed if left click on a non-main screen}
    ELSE BEGIN
      ChangeRing (ring_selected);
      END;
  END;  {of procedure RingButtonClick}

PROCEDURE TRingBar.PopupClick (Sender: TObject);
BEGIN
  WITH Sender As TMenuItem DO BEGIN
    IF (Name = 'mnuAlarms') 
      THEN Alarms.Select (PopupMenu.Tag);
    IF (Name = 'mnuGraphs') 
      THEN LGSelect.Select (PopupMenu.Tag);
    IF (Name = 'mnuStatus') 
      THEN Status.Select (PopupMenu.Tag);
    END;
  END;  {of procedure PopupClick}

PROCEDURE TRingBar.ButtonDown (ring: INTEGER);
BEGIN
  WITH Buttons[ring] DO BEGIN
    Down := TRUE;
    Font.Height := -16;
    Font.Style := [fsBold];
    END;
  END;  {of procedure ButtonDown}

PROCEDURE TRingBar.ButtonUp (ring: INTEGER);
BEGIN
  WITH Buttons[ring] DO BEGIN
    Down := FALSE;
    Font.Height := -14;
    Font.Style := [];
    END;
  END;  {of procedure ButtonUp}

FUNCTION  RingColorValueGet  (which, ring: INTEGER): INTEGER;
BEGIN
  RingColorValueGet := RingColorValue[which,ring];
  END;  {function 'RingColorValueGet'}

PROCEDURE RingColorValueSet  (which, ring, color: INTEGER);
BEGIN
  RingColorValue[which,ring] := color;
  END;  {procedure 'RingColorValueSet'}

FUNCTION RingColorToggleGet (ring: INTEGER): BOOLEAN;
BEGIN
  RingColorToggleGet := RingColorToggle[ring];
  END;  {function 'RingColorToggleGet'}

PROCEDURE RingColorToggleSet (ring: INTEGER; toggle: BOOLEAN);
BEGIN
  RingColorToggle[ring] := toggle;
  END;  {procedure 'RingColorToggleSet'}

FUNCTION RingColorToggleMasterGet: BOOLEAN;
BEGIN
  RingColorToggleMasterGet := RingColorToggleMaster;
  END;  {function 'RingColorToggleGet'}

PROCEDURE RingColorToggleMasterSet (toggle: BOOLEAN);
BEGIN
  RingColorToggleMaster := toggle;
  END;  {procedure 'RingColorToggleMasterSet'}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of class unit RingBar...} END.
