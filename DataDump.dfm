object LblForm: TLblForm
  Left = 0
  Top = 0
  Width = 600
  Height = 450
  Caption = 'LblForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnCreate = OnCreateForm
  OnClose = OnCloseForm
  OnClick = OnClickForm
  OnKeyPress = OnKeyPressForm
  OnResize = OnResizeForm
  PixelsPerInch = 96
  object Label1: TLabel
    Left = 32
    Top = 12
    Width = 49
    Height = 49
    Caption = '***NOTHING***'
    OnClick = OnClickForm
  end
end
