object Compare: TCompare
  Left = 0
  Top = 0
  Width = 800
  Height = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = OnCloseForm
  OnCreate = OnCreateForm
  OnDestroy = OnDestroyForm
  DesignSize = (
    792
    550)
  PixelsPerInch = 96
  TextHeight = 16
  object btnCancel: TBitBtn
    Left = 705
    Top = 511
    Width = 80
    Height = 35
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    TabOrder = 0
    OnClick = OnClickButton
    Kind = bkCancel
  end
  object btnHelp: TBitBtn
    Left = 537
    Top = 511
    Width = 80
    Height = 35
    Anchors = [akRight, akBottom]
    TabOrder = 1
    OnClick = OnClickButton
    Kind = bkHelp
  end
end
