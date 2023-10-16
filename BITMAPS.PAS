Unit Bitmaps;
{
Loads and stores bitmaps for use by other routines.

v 01.01  2002-11-15  Original
v 02.01  2003-05-28  change Load to LoadImage
v 02.02  2003-05-28  add LoadBitmap
v 02.03  2003-06-15  add reading LtArrow.bmp
v 02.04  2003-06-15  comment out reading all but HeartLg and HeartSm
}

Interface

Uses
{$IFDEF CLX}
  QExtCtrls, QGraphics;
{$ELSE}
  ExtCtrls, Graphics;
{$ENDIF}

PROCEDURE LoadBitmap (bitmap: TBitmap; which: String);
PROCEDURE LoadImage (image: TImage; which: String);

Implementation

{Declare an object var for each bitmap}
VAR
  HeartLg,
  HeartSm,
  RtArrow,
  LtArrow,
  Test1:   TBitmap;

{-------------------------------------------------------------}

PROCEDURE LoadBitmap (bitmap: TBitmap; which: String);
BEGIN
  IF (which = 'HeartSm') THEN bitmap := HeartSm;
  IF (which = 'HeartLg') THEN bitmap := HeartLg;
  IF (which = 'RtArrow') THEN bitmap := RtArrow;
  IF (which = 'LtArrow') THEN bitmap := LtArrow;
  IF (which = 'Test1'  ) THEN bitmap := Test1;
  END;  {of procedure LoadBitmap}
{-------------------------------------------------------------}

PROCEDURE LoadImage (image: TImage; which: String);
BEGIN
  IF (which = 'HeartSm') THEN image.Picture.Bitmap := HeartSm;
  IF (which = 'HeartLg') THEN image.Picture.Bitmap := HeartLg;
  IF (which = 'RtArrow') THEN image.Picture.Bitmap := RtArrow;
  IF (which = 'LtArrow') THEN image.Picture.Bitmap := RtArrow;
  IF (which = 'Test1'  ) THEN image.Picture.Bitmap := Test1;
  END;  {of procedure LoadImage}
{-------------------------------------------------------------}

Initialization

BEGIN
  HeartLg := TBitmap.Create;
  HeartLg.LoadFromFile ('HeartLg.bmp');

  HeartSm := TBitmap.Create;
  HeartSm.LoadFromFile ('HeartSm.bmp');

{  
  RtArrow := TBitmap.Create;
  RtArrow.LoadFromFile ('RtArrow.bmp');

  LtArrow := TBitmap.Create;
  LtArrow.LoadFromFile ('LtArrow.bmp');

  Test1   := TBitmap.Create;
  Test1  .LoadFromFile ('Test1.bmp');
}
  END;

Finalization

BEGIN
  END;

{of unit Bitmaps...}
END.
