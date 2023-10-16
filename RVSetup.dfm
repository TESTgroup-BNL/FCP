object frmRVSetup: TRVSetup
  Left = 100
  Top = 111
  Width = 650
  Height = 375
  Caption = 'TOPO - Select rings to view and background color'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = OnCloseForm
  OnDestroy = OnDestroyForm
  OnCreate = OnCreateForm
  PixelsPerInch = 96
  object RadioGroup1: TRadioGroup
    Left = 15
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Top Left'
    Items.Strings = (
      'None')
    TabOrder = 1
  end
  object RadioGroup2: TRadioGroup
    Left = 120
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Top Right'
    Items.Strings = (
      'None')
    TabOrder = 2
  end
  object RadioGroup3: TRadioGroup
    Left = 225
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Bottom Left'
    Items.Strings = (
      'None')
    TabOrder = 3
  end
  object RadioGroup4: TRadioGroup
    Left = 330
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Bottom Right'
    Items.Strings = (
      'None')
    TabOrder = 4
  end
  object Colorbox: TColorBox
    Left = 440
    Top = 20
    Width = 90
    Height = 35
  end
  object btnCancel: TBitBtn
    Left = 556
    Top = 20
    Width = 75
    Height = 35
    Caption = '&Cancel'
    Kind = bkCancel
    OnClick = OnClickCancel
    TabOrder = 5
  end
  object btnApply: TBitBtn
    Left = 556
    Top = 70
    Width = 75
    Height = 35
    Caption = '&Apply'
    OnClick = OnClickApply
    TabOrder = 6
    Glyph.Data = {
      42010000424D4201000000000000760000002800000011000000110000000100
      040000000000CC00000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      888880000000888888888B88888880000000888888888BB88888800000008888
      88888BBB888880000000888888888BBBB88880000000888888888BBBBB888000
      0000BBBBBBBBBBBBBBB880000000BBBBBBBBBBBBBBBB80000000BBBBBBBBBBBB
      BBBBB0000000BBBBBBBBBBBBBBBB80000000BBBBBBBBBBBBBBB8800000008888
      88888BBBBB8880000000888888888BBBB88880000000888888888BBB88888000
      0000888888888BB8888880000000888888888B88888880000000888888888888
      888880000000}
  end
  object btnOK: TBitBtn
    Left = 556
    Top = 120
    Width = 75
    Height = 35
    Caption = '&OK'
    Kind = bkOK
    OnClick = OnClickOK
    TabOrder = 7
  end
end
