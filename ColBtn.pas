UNIT ColBtn;

{ v0.0 1999-11-19  Jan   janColorButton as downloaded from Web
  v1.0 2002-12-08  J.N.  Renamed ColBtn
                         Paint: removed unused var Acolor
                         To distinguish left and right buttons...
                           FWhichMouseClick: TMouseButton; added
                           WhichMouseClick: new property <-> FWhichMouseClick
                           Possible values are mbLeft, mbCenter, mbRight
                           MouseDown: set above from Button: TMouseButton
                           MouseUp: invoke onclick() if right button
  v1.1 2003-01-27  J.N.  Add IFDEF LINUX ENDIF IFDEF MSWINDOWS ENDIF for USES
                         Remove uses Dialogs, Forms, SysUtils -- not needed
  v1.3 2003-02-03  J.N.  Create: FDownColor make the same as FColor
                         Create: add Cursor := crHandPoint;
}

INTERFACE

USES
{$IFDEF LINUX}
  QControls, QGraphics,
  Types;
{$ENDIF}
{$IFDEF MSWINDOWS}
  Windows, Messages, Classes,
  Controls, Graphics;
{$ENDIF}

type
  TColBtn = class(TGraphicControl)
  private
    FPushDown:boolean;
    FMouseOver:boolean;
    FHotTrack: boolean;
    FColor: TColor;
    FHotColor: TColor;
    FHotFontColor: Tcolor;
    FMarginHorizontal: integer;
    FAlignment: Talignment;
    FMarginVertical: integer;
    FWordWrap: boolean;
    FBackBitmap: TBitmap;
    FLatching: boolean;
    FDown: boolean;
    FDownColor: TColor;
    FDownFontColor: TColor;
    FFlat: boolean;
    FWhichMouseClick: TMouseButton;
    procedure SetHotTrack(const Value: boolean);
    procedure SetColor(const Value: TColor);
    procedure SetHotColor(const Value: TColor);
    procedure SetHotFontColor(const Value: Tcolor);
    procedure AutoFit;
    procedure SetMarginHorizontal(const Value: integer);
    procedure SetAlignment(const Value: Talignment);
    procedure SetMarginVertical(const Value: integer);
    procedure SetWordWrap(const Value: boolean);
    procedure SetBackBitmap(const Value: TBitmap);
    procedure BackBitmapChanged (Sender: TObject);
    procedure SetLatching(const Value: boolean);
    procedure SetDown(const Value: boolean);
    procedure SetDownColor(const Value: TColor);
    procedure SetDownFontColor(const Value: TColor);
    procedure SetFlat(const Value: boolean);
    { Private declarations }
  protected
    { Protected declarations }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure Click;override;
    procedure CMMouseLeave(var Message:TMessage); message CM_MouseLeave;
    procedure CMMouseEnter(var Message:TMessage); message CM_MouseEnter;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;


  public
    {With TColBtn you have an easy to use button where you can set the color of both text and background.}
    {}
    {In addition you can use a bitmap that will be tiled as background image.}
    {}
    {The caption can be wordwrapped if you want.}
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    {Creates and initializes an instance of TColBtn. }
    destructor  Destroy;override;
    {Destroys an instance of TColBtn.}
    procedure   Paint; override;
    {Renders the image of the button.}
    property WhichMouseClick: TMouseButton
      read FWhichMouseClick write FWhichMouseClick;
    {Interface to mouse left, center, or right button.}
  published
    { Published declarations }
    property Align;
    {Determines how the control aligns within its container (parent control).}
    property Alignment:Talignment read FAlignment write SetAlignment;
    {Controls the horizontal placement of the text within the button.}
    property BackBitmap:TBitmap read FBackBitmap write SetBackBitmap;
    {Determines the tiled background image of the button.}
    property Caption;
    {Specifies a text string that identifies the control to the user.}
    property WordWrap:boolean read FWordWrap write SetWordWrap;
    {Specifies whether the button text wraps when it is too long for the width of the button.}
    property Latching:boolean read FLatching write SetLatching;
    {Determines if the button will latch when you click it.}
    property Down:boolean read FDown write SetDown;
    {Specifies whether the button is selected (down) or unselected (up).}
    property Constraints;
    {Specifies the size constraints for the control.}
    {}
    {Use Constraints to specify the minimum and maximum width and height of the control. When Constraints contains maximum or minimum values, the control can’t be resized to violate those constraints.}
    property Enabled;
    {Controls whether the control responds to mouse, keyboard, and timer events. }
    property Flat:boolean read FFlat write SetFlat;
    {Determines whether the button has a 3D border that provides a raised or lowered look.}
    property Font;
    {Controls the attributes of text written on the button.}
    property MarginHorizontal:integer read FMarginHorizontal write SetMarginHorizontal;
    {Determines the horizontal margin in pixels between the button caption and the borders.}
    property MarginVertical:integer read FMarginVertical write SetMarginVertical;
    {Determines the vertical margin in pixels between the button caption and the borders.}
    property Color:TColor read FColor write SetColor;
    {Determines the background color of the button.}
    property HotTrack:boolean read FHotTrack write SetHotTrack;
    {Determines whether the button will be automatically highlighted when the mouse moves over it.}
    property HotColor:TColor read FHotColor write SetHotColor;
    {Determines the HotTrack button face color.}
    property DownColor:TColor read FDownColor write SetDownColor;
    {Determines the button face color in the pressed down state.}
    property HotFontColor:TColor read FHotFontColor write SetHotFontColor;
    {Determines the HotTrack color of the caption}
    property DownFontColor:TColor read FDownFontColor write SetDownFontColor;
    {Determines the color of the caption when the button is down.}
    property Hint;
    {Contains the text string that can appear when the user moves the mouse over the button.}
    property ShowHint;
    {Determines whether the control displays a Help Hint when the mouse pointer rests momentarily on the control. }
    property onclick;//event
    {Occurs when the user clicks the button.}
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Jans 2', [TColBtn]);
end;

{ TColBtn }

procedure TColBtn.Click;
begin
  if FPushDown then
    if assigned(onclick) then
      onclick(self);
end;

constructor TColBtn.Create(AOwner: TComponent);
begin
  inherited;
  Cursor := crHandPoint;
  width:=24;
  height:=24;
  FColor:=clSilver;
  FDownColor:=clSilver;
  FDownFontColor:=clblack;
  FPushDown:=false;
  FMouseOver:=false;
  FHotTrack:=true;
  FHotFontColor:=clred;
  FHotColor:=clyellow;
  FLatching:=false;
  FDown:=false;
  FFlat:=true;
  FMarginHorizontal:=8;
  FMarginVertical:=4;
  Falignment:=taCenter;
  FBackBitmap := TBitmap.Create;
  FBackBitmap.OnChange := BackBitmapChanged;

end;


procedure TColBtn.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FWhichMouseClick := Button;
  FPushDown:=true;
  Paint;
end;

procedure TColBtn.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (FWhichMouseClick = mbRight) then
    if assigned(onclick) then
      onclick(self);
  if FLatching then
    FDown:=not FDown;
  FPushDown:=false;
  Paint;
end;

procedure TColBtn.Paint;
var R,RCap:Trect;
    w,h:integer;
    TileBack:boolean;

  procedure DrawBackBitmap;
  var
  ix, iy: Integer;
  BmpWidth, BmpHeight: Integer;
  hCanvas, BmpCanvas: THandle;
  bm:Tbitmap;
  begin
    bm:=FBackBitmap;
      begin
        BmpWidth := bm.Width;
        BmpHeight := bm.Height;
        BmpCanvas := bm.Canvas.Handle;
        hCanvas := THandle (canvas.handle);
        for iy := 0 to ClientHeight div BmpHeight do
          for ix := 0 to ClientWidth div BmpWidth do
            BitBlt (hCanvas, ix * BmpWidth, iy * BmpHeight,
              BmpWidth, BmpHeight, BmpCanvas,
              0, 0, SRCCOPY);
      end;
  end;

  procedure drawcaption(fontcolor:TColor);
  begin
    canvas.brush.style:=bsclear;
    canvas.font.color:=Fontcolor;
    if not Fwordwrap then
    begin
    case Falignment of
    taCenter:
      DrawText(canvas.handle,@Caption[1],-1,Rcap, DT_SINGLELINE or DT_VCENTER or DT_CENTER);
    taLeftJustify:
      DrawText(canvas.handle,@Caption[1],-1,Rcap, DT_SINGLELINE or DT_VCENTER or DT_LEFT);
    taRightJustify:
      DrawText(canvas.handle,@Caption[1],-1,Rcap, DT_SINGLELINE or DT_VCENTER or DT_RIGHT);
    end;
    end
    else
    begin  // wordwrap
    case Falignment of
    taCenter:
      DrawText(canvas.handle,@Caption[1],-1,Rcap, DT_VCENTER or DT_CENTER or DT_WORDBREAK);
    taLeftJustify:
      DrawText(canvas.handle,@Caption[1],-1,Rcap, DT_VCENTER or DT_LEFT or DT_WORDBREAK);
    taRightJustify:
      DrawText(canvas.handle,@Caption[1],-1,Rcap, DT_VCENTER or DT_RIGHT or DT_WORDBREAK);
    end
    end;
  end;

  procedure drawbackground(AColor:TColor);
  begin
    if TileBack then DrawBackBitmap
    else
    begin
      canvas.brush.color:=AColor;
      canvas.FillRect (R);
    end;
  end;


  procedure drawdownborder;
  begin
    with canvas do
    begin
      pen.style:=pssolid;
      pen.color:=clgray;
      MoveTo(w,0);
      LineTo(0,0);
      LineTo(0,h);
      pen.color:=clwhite;
      LineTo(w,h);
      LineTo(w,0);
    end;
  end;

  procedure drawupborder;
  begin
    with canvas do
    begin
      pen.style:=pssolid;
      pen.color:=clwhite;
      MoveTo(w,0);
      LineTo(0,0);
      LineTo(0,h);
      pen.color:=clgray;
      LineTo(w,h);
      LineTo(w,0);
    end;
  end;

begin
  if assigned(FBackBitmap) and (FBackBitmap.Height <> 0) and (FBackBitmap.Width <> 0) then
    TileBack:=true
  else
    TileBack:=false;
  canvas.font.Assign (Font);
  autofit;
  R:=Rect(0,0,width,height);
  if not FWordwrap then
    Rcap:=rect(FMarginHorizontal,0,width-FMarginHorizontal,height)
  else
    RCap:=rect(FMarginHorizontal,FMarginvertical,width-FMarginHorizontal,height-FMarginVertical);
  if FPushDown or FDown then
  begin
    RCap.left:=Rcap.left+1;
    RCap.top:=RCap.top+1;
    RCap.Right:=RCap.right+1;
    RCap.Bottom :=Rcap.Bottom +1;
  end;
  w:=width-1;
  h:=height-1;
  if (csDesigning in ComponentState) then
  begin
    drawbackground(FColor);
    drawupborder;
    drawcaption(font.color);
  end
  else if FPushDown or FDown then
  begin // depressed button
    drawbackground(FDownColor);
    drawdownborder;
    drawcaption(FDownFontColor);
  end
  else if (FMouseOver and FHotTrack and (not FDown)) then
  begin // raised button with highlight caption
    drawbackground(FHotColor);
    drawupborder;
    drawcaption(FHotFontcolor);
  end
  else if FMouseOver or (not FFlat)then
  begin  // raised button with normal caption
    drawbackground(Fcolor);
    drawupborder;
    drawcaption(font.color);
  end
  else
  begin  // flat button with normal caption
    drawbackground(FColor);
    drawcaption(font.color);
  end;
end;


procedure TColBtn.CMMouseLeave(var Message: TMessage);
begin
  FMouseOver:=false;
  Paint;
end;


procedure TColBtn.SetHotTrack(const Value: boolean);
begin
  FHotTrack := Value;
end;


procedure TColBtn.CMMouseEnter(var Message: TMessage);
begin
  FMouseOver:=true;
  Paint;
end;













procedure TColBtn.SetColor(const Value: TColor);
begin
  if value<>FColor then
  begin
    FColor := Value;
    invalidate;
  end;
end;

procedure TColBtn.SetHotColor(const Value: TColor);
begin
  if value<>FHotColor then
  begin
    FHotColor := Value;
  end;
end;

procedure TColBtn.SetHotFontColor(const Value: Tcolor);
begin
  FHotFontColor := Value;
end;

procedure TColBtn.AutoFit;
var w,h:integer;
    R:Trect;
begin
  if not FWordwrap then
  begin
    w:=canvas.TextWidth (Caption)+2*FMarginHorizontal;
    h:=canvas.TextHeight(Caption)+2*FMarginVertical;
    if width<w then width:=w;
    if height<h then height:=h;
  end
  else
  begin
    R:=rect(FMarginHorizontal,FMarginVertical,width-FMarginHorizontal,height);
    DrawText(canvas.handle,@Caption[1],-1,R, DT_CALCRECT or DT_WORDBREAK);
    R.bottom:=R.Bottom+FMarginVertical;
    h:=R.bottom-R.top+1;
    if height<h then height:=h;
  end;
end;

procedure TColBtn.SetMarginHorizontal(const Value: integer);
begin
  if value<>FMarginHorizontal then
  begin
    FMarginHorizontal := Value;
    invalidate;
  end;
end;

procedure TColBtn.CMFontChanged(var Message: TMessage);
begin
  invalidate;
end;

procedure TColBtn.CMTextChanged(var Message: TMessage);
begin
  invalidate;
end;

procedure TColBtn.SetAlignment(const Value: Talignment);
begin
  if value<>Falignment then
  begin
    FAlignment := Value;
    invalidate;
  end;
end;

procedure TColBtn.SetMarginVertical(const Value: integer);
begin
  if value<>FMarginVertical then
  begin
    FMarginVertical := Value;
    invalidate;
  end;
end;

procedure TColBtn.SetWordWrap(const Value: boolean);
begin
  if value<>FWordWrap then
  begin
    FWordWrap := Value;
    invalidate;
  end;
end;

procedure TColBtn.SetBackBitmap(const Value: TBitmap);
begin
  FBackBitmap.Assign (Value);
end;

destructor TColBtn.Destroy;
begin
  FBackBitmap.Free;
  inherited;
end;

procedure TColBtn.BackBitmapChanged(Sender: TObject);
begin
  invalidate;
end;

procedure TColBtn.SetLatching(const Value: boolean);
begin
  FLatching := Value;
end;

procedure TColBtn.SetDown(const Value: boolean);
begin
  if value<>FDown then
  begin
    FDown := Value;
    invalidate;
  end;
end;

procedure TColBtn.SetDownColor(const Value: TColor);
begin
  if value<>FDownColor then
  begin
    FDownColor := Value;
  end;

end;

procedure TColBtn.SetDownFontColor(const Value: TColor);
begin
  FDownFontColor := Value;
end;

procedure TColBtn.SetFlat(const Value: boolean);
begin
  if value<>FFlat then
  begin
   FFlat := Value;
   invalidate;
  end;
end;

{of unit ColBtn...} end.
