Unit Template;
{$R+} {Range checking ON}
{
Generic form with command buttons

v01.01 2003-05-29 Original
v01.02 2003-06-13 OnCloseClient, OnDestroyClient: removed
v01.03 2003-06-14 btnRefresh: new; uses blue left arrow glyph
v01.04 2004-07-16 .dfm: change font from Courier New to MS Sans Serif
}

INTERFACE

USES
{$IFDEF LINUX}
  QButtons, QForms;
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Forms;
{$ENDIF}

TYPE
  TTemplate = CLASS(TForm)
    btnCancel  : TBitBtn;
    btnRefresh : TBitBtn;
    btnApply   : TBitBtn;
    btnOK      : TBitBtn;
    btnHelp    : TBitBtn;
    PRIVATE
      { Private declarations }
    PUBLIC
      { Public declarations }
    END;

IMPLEMENTATION

{$R *.DFM}

{-------------------------------------------------------------}

INITIALIZATION

BEGIN
  END;

FINALIZATION

BEGIN
  END;

{of unit Template...} END.
