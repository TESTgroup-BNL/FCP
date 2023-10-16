object CalibMan: TCalibMan
  Left = 267
  Top = 130
  Width = 904
  Height = 716
  Caption = 'Calibration mode - Manual calibration setup window'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = OnCloseForm
  OnCreate = OnCreateForm
  OnDestroy = OnDestroyForm
  PixelsPerInch = 96
  TextHeight = 13
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
    Top = 240
    Width = 80
    Height = 35
    TabOrder = 3
    OnClick = OnClickButton
    Kind = bkHelp
  end
  object BandGroupBox: TGroupBox
    Left = 16
    Top = 16
    Width = 305
    Height = 337
    Caption = 'Calibration band ranges'
    TabOrder = 4
    object TimeoutLabel: TLabel
      Left = 24
      Top = 294
      Width = 86
      Height = 13
      Caption = 'Time out (minutes)'
    end
    object TimeoutEdit: TEdit
      Left = 136
      Top = 294
      Width = 73
      Height = 21
      TabOrder = 2
      Text = '60'
    end
    object ZeroGroupBox: TGroupBox
      Left = 16
      Top = 24
      Width = 257
      Height = 105
      Caption = 'Zero'
      TabOrder = 0
      object ZeroLowLabel: TLabel
        Left = 16
        Top = 24
        Width = 44
        Height = 13
        Caption = 'Band low'
      end
      object ZeroHighLabel: TLabel
        Left = 16
        Top = 56
        Width = 48
        Height = 13
        Caption = 'Band high'
      end
      object ZeroLowEdit: TEdit
        Left = 120
        Top = 24
        Width = 65
        Height = 21
        TabOrder = 0
        Text = '-100'
      end
      object ZeroHighEdit: TEdit
        Left = 120
        Top = 56
        Width = 65
        Height = 21
        TabOrder = 1
        Text = '100'
      end
    end
    object SpanGroup: TGroupBox
      Left = 16
      Top = 160
      Width = 257
      Height = 105
      Caption = 'Span'
      TabOrder = 1
      object SpanLowLabel: TLabel
        Left = 16
        Top = 24
        Width = 44
        Height = 13
        Caption = 'Band low'
      end
      object SpanHighLabel: TLabel
        Left = 16
        Top = 56
        Width = 48
        Height = 13
        Caption = 'Band high'
      end
      object SpanLowEdit: TEdit
        Left = 120
        Top = 24
        Width = 65
        Height = 21
        TabOrder = 0
        Text = '900'
      end
      object SpanHighEdit: TEdit
        Left = 120
        Top = 56
        Width = 65
        Height = 21
        TabOrder = 1
        Text = '1100'
      end
    end
  end
  object CheckBoxMP: TCheckBox
    Left = 360
    Top = 400
    Width = 17
    Height = 17
    Caption = 'Ambient MP'
    TabOrder = 5
  end
  object btnLI840: TBitBtn
    Left = 490
    Top = 318
    Width = 80
    Height = 35
    Caption = '&LI-820/840/850'
    TabOrder = 6
    OnClick = OnClickButton
    NumGlyphs = 2
  end
end
