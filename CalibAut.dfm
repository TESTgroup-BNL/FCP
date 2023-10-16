object CalibAut: TCalibAut
  Left = 143
  Top = -13
  Width = 600
  Height = 500
  Caption = 'Calibration mode - Automatic calibration setup window'
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
  object LabelRing: TLabel
    Left = 175
    Top = 36
    Width = 54
    Height = 24
    Caption = 'Ring #'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object TabControl1: TTabControl
    Left = 0
    Top = 0
    Width = 585
    Height = 24
    TabOrder = 5
  end
  object btnCancel: TBitBtn
    Left = 490
    Top = 75
    Width = 80
    Height = 35
    Caption = '&Cancel'
    Kind = bkCancel
    TabOrder = 0
    OnClick = OnClickButton
  end
  object btnOK: TBitBtn
    Left = 490
    Top = 175
    Width = 80
    Height = 35
    Caption = '&OK'
    Kind = bkOK
    TabOrder = 1
    OnClick = OnClickButton
  end
  object btnHelp: TBitBtn
    Left = 490
    Top = 275
    Width = 80
    Height = 35
    Caption = '&Help'
    Kind = bkHelp
    TabOrder = 3
    OnClick = OnClickButton
  end
  object GroupboxZero: TGroupBox
    Left = 15
    Top = 63
    Width = 215
    Height = 370
    Caption = 'Zero'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object LabelTimepulseZero: TLabel
      Left = 16
      Top = 0
      Width = 108
      Height = 16
      Caption = 'Length of pulse [s]'
    end
    object LabelTimeactiveZero: TLabel
      Left = 16
      Top = 0
      Width = 68
      Height = 16
      Caption = 'Duration [s]'
    end
    object LabelIntvalminZero: TLabel
      Left = 16
      Top = 0
      Width = 88
      Height = 16
      Caption = 'Interval: min [s]'
    end
    object LabelIntvalmultZero: TLabel
      Left = 16
      Top = 0
      Width = 53
      Height = 16
      Caption = 'Multiplier'
    end
    object LabelIntvalmaxZero: TLabel
      Left = 16
      Top = 0
      Width = 92
      Height = 16
      Caption = 'Interval: max [s]'
    end
    object LabelIntvalnowZero: TLabel
      Left = 16
      Top = 0
      Width = 91
      Height = 16
      Caption = 'Interval: now [s]'
    end
    object CheckboxEnabledZero: TCheckBox
      Left = 16
      Top = 0
      Width = 127
      Height = 25
      Alignment = taLeftJustify
      Caption = 'Enabled'
      TabOrder = 0
    end
    object CheckboxInvertedZero: TCheckBox
      Left = 16
      Top = 0
      Width = 127
      Height = 25
      Alignment = taLeftJustify
      Caption = 'Inverted'
      TabOrder = 1
    end
    object EditTimepulseZero: TEdit
      Left = 130
      Top = 0
      Width = 65
      Height = 24
      TabOrder = 2
    end
    object EditTimeactiveZero: TEdit
      Left = 130
      Top = 0
      Width = 65
      Height = 24
      TabOrder = 3
    end
    object EditIntvalminZero: TEdit
      Left = 130
      Top = 0
      Width = 65
      Height = 24
      TabOrder = 4
    end
    object EditIntvalmultZero: TEdit
      Left = 130
      Top = 0
      Width = 65
      Height = 24
      TabOrder = 5
    end
    object EditIntvalmaxZero: TEdit
      Left = 130
      Top = 0
      Width = 65
      Height = 24
      TabOrder = 6
    end
    object EditIntvalnowZero: TEdit
      Left = 130
      Top = 0
      Width = 65
      Height = 24
      TabOrder = 7
    end
    object btnApplyZero: TBitBtn
      Left = 16
      Top = 0
      Width = 80
      Height = 35
      Caption = '&Apply'
      TabOrder = 8
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
    object btnTestZero: TBitBtn
      Left = 130
      Top = 0
      Width = 80
      Height = 35
      Caption = '&Test'
      TabOrder = 9
      OnClick = OnClickButton
    end
  end
  object GroupboxSpan: TGroupBox
    Left = 245
    Top = 63
    Width = 215
    Height = 370
    Caption = 'Span'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
end
