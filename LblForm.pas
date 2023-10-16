Unit LblForm;

{
A general-purpose, modeless form that contains only one label control.
To be used for non-interactive information windows like Help's.

v01.01 2002-09-14 Original
v01.02 2002-09-15 Additional comments
v01.03 2002-09-20 TitleSet, BodyClear, BodyAppend: added methods
v01.04 2003-01-05 LabelFontPitch, LabelFontStyle: added methods
v01.05 2003-01-26 Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS
v01.06 2003-01-30 OnCreateForm: Font.Size 10 --> Font.Height -14
                  LabelFontSizeSet: replaced by LabelFontHeightSet
                  OnResizeForm: SizeSet div 55 --> HeightSet - div 40
v01.07 2003-03-16 OnClickForm & OnKeyPressForm call Close
                  Many calls to Application.ProcessMessages *** TEMPORARY
v01.08 2003-03-17 BodyAppend: Position VertScrollBar at Max
v01.09 2003-03-18 Replace procedure OnDestroyForm by OnCloseForm
v01.10 2003-03-18 Procedure Close; changed to Cancel;
v01.11 2003-05-25 OnDestroyForm: added back; Self := NIL
v01.12 2003-05-27 Cancel: added Self := NIL -- still flaky
v01.13 2003-05-27 Cancel: try Dispatch (WM_CLOSE) instead
v01.14 2003-05-27 Replace OnKeyPressForm by OnKeyDownForm
v01.15 2003-05-27 Add USES Classes for TShiftState
v01.16 2003-06-26 OnCloseForm: calls Cancel
v01.17 2003-06-26 Cancel: calls Release and assigns to NIL
v01.18 2006-09-24 OnCreateForm: Self.Height := ROUND (0.9 * Screen.Height);
}

INTERFACE

USES
{$IFDEF LINUX}
  QForms, QGraphics, QStdCtrls,
  Types,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics, StdCtrls,
  Windows, Messages, Classes,
{$ENDIF}
  SysUtils;

TYPE
  TLblForm = class(TForm)
    Label1: TLabel;
    PROCEDURE OnClickForm (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
    PROCEDURE OnKeyDownForm (Sender: TObject; var Key: Word; Shift: TShiftState);
    PROCEDURE OnResizeForm (Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
    PROCEDURE LabelFontNameSet (nm: String);
    PROCEDURE LabelFontHeightSet (h: INTEGER);
    PROCEDURE LabelFontPitchSet (pt: TFontPitch);
    PROCEDURE LabelFontStyleSet (st: TFontStyles);
    PROCEDURE Display (header: String; body: String);
    PROCEDURE TitleSet (header: String);
    PROCEDURE BodyClear;
    PROCEDURE BodyAppend (morestuff: String);
    PROCEDURE Cancel;
  END;

Implementation

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE TLblForm.OnClickForm (Sender: TObject);
{Cancel on mouse click anywhere on form}
BEGIN
  Cancel;
  END;  {of procedure OnClickForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnCreateForm (Sender: TObject);
{Set default properties}
BEGIN
  Self.Height := ROUND (0.9 * Screen.Height);
  WITH Label1.Font DO BEGIN
    Name := 'Arial';
    Height := -14;
    Style := [fsBold];
    END;  {with label.font}
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  {
  Action := caFree;
  Self := NIL;
  }
  Cancel;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  Self := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnKeyDownForm (
  Sender: TObject; VAR Key: Word; Shift: TShiftState);
{Cancel form on any key press}
BEGIN
  Cancel;
  END;  {of procedure OnKeyDownForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnResizeForm (Sender: TObject);
{Change font height depending on size of form}
VAR body: String;
BEGIN
  WITH Label1 DO BEGIN
      LabelFontHeightSet (-1 * (Self.Width DIV 40));
      body := Caption;
      Caption := body;
    END;  {with label}
  END;  {of procedure OnResizeForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.LabelFontNameSet (nm: String);
BEGIN  
  Self.Label1.Font.Name := nm;
  END;  {of procedure LabelFontNameSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.LabelFontHeightSet (h: INTEGER);
BEGIN  
  Self.Label1.Font.Height := h;
  END;  {of procedure LabelFontHeightSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.LabelFontPitchSet (pt: TFontPitch);
BEGIN  
  Self.Label1.Font.Pitch := pt;
  END;  {of procedure LabelFontPitchSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.LabelFontStyleSet (st: TFontStyles);
BEGIN  
  Self.Label1.Font.Style := st;
  END;  {of procedure LabelFontStyleSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.Display (header: String; body: String);
{Display the modeless form}
BEGIN
  WITH Self DO BEGIN
    Caption := header;
    Label1.Caption := body;
    Show;
    SetFocus;
    END;  {with self}
  Application.ProcessMessages;
  END;  {of procedure Display}
{-------------------------------------------------------------}

PROCEDURE TLblForm.TitleSet (header: String);
{New caption for the form}
BEGIN
  Self.Caption := header;
  Application.ProcessMessages;
  END;  {of procedure TitleSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.BodyClear;
{Erase the text currently in the label control}
BEGIN
  Label1.Caption := '';
  Application.ProcessMessages;
  END;  {of procedure BodyClear}
{-------------------------------------------------------------}

PROCEDURE TLblForm.BodyAppend (morestuff: String);
{Add additional text to the label control}
BEGIN
  Label1.Caption := Label1.Caption + morestuff;
  VertScrollBar.Position := 65000 {VertScrollBar.Max won't compile};
  Application.ProcessMessages;
  END;  {of procedure BodyAppend}
{-------------------------------------------------------------}

PROCEDURE TLblForm.Cancel;
VAR Message: TMessage;
{Cancel form from another unit}
BEGIN
  {
  Message.Msg := WM_CLOSE;
  Dispatch (Message);
  }
  Self.Release;
  Self := NIL;
  END;  {of procedure Cancel}
{-------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of form unit 'LblForm'...}
END.
