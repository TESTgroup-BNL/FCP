Unit DataDump;

{
A general-purpose, modeless form that contains only one label control.
To be used for non-interactive information windows like Help's.

v01.01 2003-05-06 Original starting with LblForm.pas v1.10 03-18
v01.02 2003-05-25 OnDestroyForm: added back; object := NIL
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QForms, QGraphics, QStdCtrls;
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Forms, Graphics, StdCtrls;
{$ENDIF}

TYPE
  TLblForm = class(TForm)
    lbAttribute: TListBox;
    lbValue:     TListBox;
    PROCEDURE OnClickForm (Sender: TObject);
    PROCEDURE OnCreateForm (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
    PROCEDURE OnKeyPressForm (Sender: TObject; var Key: Char);
    PROCEDURE OnResizeForm (Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
    PROCEDURE FontNameSet (nm: String);
    PROCEDURE FontHeightSet (h: INTEGER);
    PROCEDURE FontPitchSet (pt: TFontPitch);
    PROCEDURE FontStyleSet (st: TFontStyles);
    PROCEDURE Display (header: String; body: String);
    PROCEDURE TitleSet (header: String);
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
  WITH lbAttribute.Font DO BEGIN
    Name := 'Arial';
    Height := -14;
    Style := [fsBold];
    END;  {with lbAttribute.Font}
  WITH lbValue.Font DO BEGIN
    Name := 'Arial';
    Height := -14;
    Style := [fsBold];
    END;  {with lbValue.Font}
  END;  {of procedure OnCreateForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  Self := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TDataDump.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  Self := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnKeyPressForm (Sender: TObject; VAR key: CHAR);
{Cancel form on any key press}
BEGIN
  Cancel;
  END;  {of procedure OnKeyPressForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.OnResizeForm (Sender: TObject);
{Change font height depending on size of form}
BEGIN
  FontHeightSet (-1 * (Self.Width DIV 40));
  END;  {of procedure OnResizeForm}
{-------------------------------------------------------------}

PROCEDURE TLblForm.FontNameSet (nm: String);
BEGIN  
  Self.lbAttribute.Font.Name := nm;
  Self.lbValue    .Font.Name := nm;
  END;  {of procedure FontNameSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.FontHeightSet (h: INTEGER);
BEGIN  
  Self.lbAttribute.Font.Height := h;
  Self.lbValue    .Font.Height := h;
  END;  {of procedure FontHeightSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.FontPitchSet (pt: TFontPitch);
BEGIN  
  Self.lbAttribute.Font.Pitch := pt;
  Self.lbValue    .Font.Pitch := pt;
  END;  {of procedure FontPitchSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.FontStyleSet (st: TFontStyles);
BEGIN  
  Self.lbAttribute.Font.Style := st;
  Self.lbValue    .Font.Style := st;
  END;  {of procedure FontStyleSet}
{-------------------------------------------------------------}

PROCEDURE TLblForm.Display (header: String; body: String);
{Display the modeless form}
BEGIN
  WITH Self DO BEGIN
    Caption := header;
    {Label1.Caption := body;}
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

PROCEDURE TLblForm.Cancel;
{Cancel form from another unit}
BEGIN
  Self.Release;
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
