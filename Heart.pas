Unit Heart;
{
Heart beat control

v01.01 2002-11-15 Original
v02.01 2003-05-28 Change Bitmaps.Load to .LoadImage
}

{$R+}

Interface

Uses
{$IFDEF CLX}
  QExtCtrls, QForms,
{$ELSE}
  Controls, ExtCtrls, Forms,
{$ENDIF}
  Bitmaps;

TYPE
  THeartBeat = class(TWinControl)
    PRIVATE
      FRight: INTEGER;
      Images: ARRAY [0..1] OF TImage;
    PUBLISHED
      PROPERTY Right: INTEGER READ FRight;
    END;

PROCEDURE Make (VAR hb: THeartBeat; frm: TForm; LLeft, TTop: INTEGER);
PROCEDURE Pick (VAR hb: THeartBeat; which: BOOLEAN);

Implementation

{-------------------------------------------------------------}
PROCEDURE Make (VAR hb: THeartBeat; frm: TForm; LLeft, TTop: INTEGER);
VAR offon: INTEGER;
BEGIN
  IF NOT Assigned (hb) THEN BEGIN
    hb := THeartBeat.Create (frm);
    WITH hb DO FOR offon := 0 TO 1 DO BEGIN
      Images[offon] := TImage.Create (frm);
      WITH Images[offon] DO BEGIN
        Parent := frm;
        Left := LLeft;
        Top := TTop;
        Width := 24;
        Height := 24;
        IF (offon = 0)
          {'nothing' is a legitimate entry}
          THEN Bitmaps.LoadImage (Images[offon], 'HeartSm')
          ELSE Bitmaps.LoadImage (Images[offon], 'HeartLg');
        FRight := Left + Width;
        Visible := (offon = 0);
        END;
      END;  {for}
    END;
  END;  {of procedure Create}
{-------------------------------------------------------------}

PROCEDURE Pick (VAR hb: THeartBeat; which: BOOLEAN);
BEGIN
  IF Assigned(hb) THEN BEGIN
    hb.Images[ORD(NOT which)].Visible := FALSE;
    hb.Images[ORD(    which)].Visible := TRUE;
    hb.Images[0].Repaint;
    hb.Images[1].Repaint;
    END;
  END;  {of procedure Set}
{-------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of unit Heart...}
END.
