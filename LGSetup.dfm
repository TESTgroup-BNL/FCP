object LGSetup: TLGSetup
  Left = 0
  Top = 0
  Width = 585
  Height = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = OnCreateForm
  OnClose = OnCloseForm
  OnDestroy = OnDestroyForm
  PixelsPerInch = 96
  object btnHelp: TBitBtn
    Left = 490
    Top = 20
    Width = 80
    Height = 35
    Caption = '&Help'
    TabOrder = 4
    OnClick = OnClickButton
    Kind = bkHelp
  end
  object btnCancel: TBitBtn
    Left = 490
    Top = 70
    Width = 80
    Height = 35
    Caption = '&Cancel'
    TabOrder = 0
    OnClick = OnClickButton
    Kind = bkCancel
  end
  object btnApply: TBitBtn
    Left = 490
    Top = 120
    Width = 80
    Height = 35
    Caption = '&Apply'
    TabOrder = 1
    OnClick = OnClickButton
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
    Left = 490
    Top = 170
    Width = 80
    Height = 35
    Caption = '&OK'
    TabOrder = 2
    OnClick = OnClickButton
    Kind = bkOK
  end
  object cbSave: TCheckBox
    Left = 490
    Top = 220
    Width = 80
    Height = 35
    Caption = '&Save to disk'
    TabOrder = 3
    Checked = True
  end
  object gbScreen: TGroupBox
    Left = 490
    Top = 340
    Width = 80
    Height = 100
    Caption = 'Screen size'
  end
  object lblEnable: TLabel
    Caption = 'Enable'
    Font.Style = [fsBold]
  end
  object lblLow: TLabel
    Caption = 'Low'
    Font.Style = [fsBold]
  end
  object lblHigh: TLabel
    Caption = 'High'
    Font.Style = [fsBold]
  end
  object lblOffset: TLabel
    Caption = 'Offset'
    Font.Style = [fsBold]
  end
  object lblScale: TLabel
    Caption = 'Scale'
    Font.Style = [fsBold]
  end
  object lblColor: TLabel
    Caption = 'Color'
    Font.Style = [fsBold]
  end
end
