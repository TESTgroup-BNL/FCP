object frmH2OVapor: TfrmH2OVapor
  Left = 198
  Top = 111
  Width = 568
  Height = 352
  Caption = 'Water vapor partial pressure information display and calculator'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnClose = OnCloseForm
  OnCreate = OnCreateForm
  OnDestroy = OnDestroyForm
  PixelsPerInch = 96
  TextHeight = 20
  object lblFormula: TLabel
    Left = 11
    Top = 12
    Width = 500
    Height = 24
    AutoSize = False
    Caption = 'esat = 613.65 exp (17.502 * T / (240.97+T))    Briggs[1981]'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object gbInput: TGroupBox
    Left = 10
    Top = 43
    Width = 375
    Height = 135
    Caption = 'Input'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object rbAutomatic: TRadioButton
      Left = 8
      Top = 28
      Width = 169
      Height = 17
      Caption = 'Automatic'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object rbManual: TRadioButton
      Left = 8
      Top = 44
      Width = 169
      Height = 21
      Caption = 'Manual'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object lblpH2O: TLabel
      Left = 10
      Top = 70
      Width = 271
      Height = 24
      AutoSize = False
      Caption = 'Water vapor partial pressure [Pa]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblTemperature: TLabel
      Left = 10
      Top = 101
      Width = 271
      Height = 24
      AutoSize = False
      Caption = 'Air temperature [oC]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edpH2O: TEdit
      Left = 285
      Top = 70
      Width = 80
      Height = 24
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = 'pH2O'
      Cursor = crNo
    end
    object edTemperature: TEdit
      Left = 285
      Top = 101
      Width = 80
      Height = 24
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
      Text = 'temperature'
      Cursor = crNo
    end
  end
  object gbOutput: TGroupBox
    Left = 10
    Top = 184
    Width = 375
    Height = 125
    Caption = 'Output'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    object lblEsatTitle: TLabel
      Left = 10
      Top = 22
      Width = 271
      Height = 24
      AutoSize = False
      Caption = 'Saturation water vapor pressure'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblEsatValue: TLabel
      Left = 286
      Top = 22
      Width = 80
      Height = 24
      AutoSize = False
      Caption = 'esat'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblDewptTitle: TLabel
      Left = 10
      Top = 46
      Width = 271
      Height = 24
      AutoSize = False
      Caption = 'Dew/frost point [oC]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDewptValue: TLabel
      Left = 286
      Top = 46
      Width = 83
      Height = 24
      AutoSize = False
      Caption = 'dewpoint'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblRHTitle: TLabel
      Left = 10
      Top = 70
      Width = 271
      Height = 24
      AutoSize = False
      Caption = 'Relative humidity [%]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblRHValue: TLabel
      Left = 286
      Top = 70
      Width = 80
      Height = 24
      AutoSize = False
      Caption = 'rh'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblVPDTitle: TLabel
      Left = 10
      Top = 93
      Width = 271
      Height = 24
      AutoSize = False
      Caption = 'Vapor pressure deficit [Pa]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblVPDValue: TLabel
      Left = 286
      Top = 93
      Width = 80
      Height = 24
      AutoSize = False
      Caption = 'vpd'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
  object gbRings: TGroupBox
    Left = 400
    Top = 43
    Width = 145
    Height = 223
    Caption = 'Ring selection'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
  end
  object btnCancel: TBitBtn
    Left = 400
    Top = 279
    Width = 145
    Height = 30
    Caption = '&Cancel'
    TabOrder = 0
    OnClick = OnClickButton
    Kind = bkCancel
  end
end
