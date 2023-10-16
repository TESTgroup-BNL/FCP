object frmWatchdog: TfrmWatchdog
  Left = 99
  Top = 65
  Width = 621
  Height = 494
  Caption = 'Watchdog'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  OnCreate = OnCreateForm
  OnClose = OnCloseForm
  OnDestroy = OnDestroyForm
  object lblBase: TLabel
    Left = 144
    Top = 172
    Width = 173
    Height = 16
    Caption = 'Base address (hexadecimal, except for FEC)'
  end
  object lblProtocol: TLabel
    Left = 144
    Top = 132
    Width = 50
    Height = 16
    Caption = 'Protocol'
  end
  object lblTimeout: TLabel
    Left = 144
    Top = 212
    Width = 112
    Height = 16
    Caption = 'Timeout (s) -- resolution is 20 seconds'
  end
  object btnCancel: TBitBtn
    Left = 490
    Top = 20
    Width = 80
    Height = 35
    Caption = '&Cancel'
    TabOrder = 0
    OnClick = OnClickButton
    Kind = bkCancel
  end
  object btnApply: TBitBtn
    Left = 490
    Top = 70
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
    Top = 120
    Width = 80
    Height = 35
    Caption = '&OK'
    TabOrder = 2
    OnClick = OnClickButton
    Kind = bkOK
  end
  object btnHelp: TBitBtn
    Left = 490
    Top = 170
    Width = 80
    Height = 35
    TabOrder = 3
    OnClick = OnClickButton
    Kind = bkHelp
  end
  object cbExists: TCheckBox
    Left = 40
    Top = 16
    Width = 169
    Height = 25
    TabStop = False
    Caption = 'Exists'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
  object cbInitialized: TCheckBox
    Left = 40
    Top = 48
    Width = 113
    Height = 33
    TabStop = False
    Caption = 'Initialized'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object cbTest: TCheckBox
    Left = 40
    Top = 88
    Width = 200
    Height = 33
    TabStop = False
    Caption = 'Test mode (suppress petting)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object txtBase: TEdit
    Left = 40
    Top = 168
    Width = 97
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    Text = 'Base'
  end
  object comboProtocol: TComboBox
    Left = 40
    Top = 128
    Width = 97
    Height = 24
    ItemHeight = 16
    ItemIndex = 5
    TabOrder = 7
    Text = '???'
    Items.Strings = (
      'FEC'
      'FFPWC'
      'FFPWCNT'
      'LPT1'
      'LPT2'
      'LPT3'
      '???')
  end
  object txtTimeout: TEdit
    Left = 40
    Top = 208
    Width = 97
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
    Text = 'Timeout'
  end
  object btnInitialize: TButton
    Left = 152
    Top = 48
    Width = 105
    Height = 33
    Caption = 'Initialize WinIO'
    TabOrder = 10
    TabStop = False
  end
  object memoOps: TMemo
    Left = 40
    Top = 248
    Width = 401
    Height = 201
    TabStop = False
    Color = clSilver
    ScrollBars = ssVertical
    TabOrder = 11
    WordWrap = False
  end
  object cbPause: TCheckBox
    Left = 488
    Top = 368
    Width = 105
    Height = 33
    TabStop = False
    Caption = 'Pause display'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
  end
  object btnClear: TButton
    Left = 490
    Top = 414
    Width = 80
    Height = 35
    Caption = 'C&lear'
    TabOrder = 12
    TabStop = False
    OnClick = OnClickButton
  end
end
