object CalLi840Form: TCalLi840Form
  Left = 22
  Top = 16
  Width = 1008
  Height = 708
  Caption = 'CalLi840Form'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblPlot: TLabel
    Left = 16
    Top = 16
    Width = 113
    Height = 41
    AutoSize = False
    Caption = 'Plot x'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblWhich: TLabel
    Left = 16
    Top = 72
    Width = 145
    Height = 25
    AutoSize = False
    Caption = 'Function'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblVPI: TLabel
    Left = 16
    Top = 152
    Width = 130
    Height = 24
    Caption = 'DataComm port'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblCO2Span: TLabel
    Left = 16
    Top = 393
    Width = 170
    Height = 24
    Caption = 'CO2 Span umol/mol'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblCO2Span2: TLabel
    Left = 16
    Top = 463
    Width = 180
    Height = 24
    Caption = 'CO2 Span2 umol/mol'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblDewpointSpan: TLabel
    Left = 16
    Top = 598
    Width = 157
    Height = 24
    Caption = 'Dewpoint Span oC'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblDump: TLabel
    Left = 235
    Top = 279
    Width = 137
    Height = 49
    Alignment = taCenter
    AutoSize = False
    Caption = 'C:\CalLi840\  CalLi840_sn.log'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object lblSN: TLabel
    Left = 136
    Top = 8
    Width = 258
    Height = 24
    Caption = 'S/N and factory calibration date'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object gbIRGA: TGroupBox
    Left = 16
    Top = 233
    Width = 145
    Height = 89
    Caption = 'IRGA model'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object rb820: TRadioButton
      Left = 8
      Top = 28
      Width = 121
      Height = 17
      Caption = 'LI-8&20'
      TabOrder = 0
    end
    object rb840: TRadioButton
      Left = 8
      Top = 57
      Width = 113
      Height = 17
      Caption = 'LI-8&40'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
  end
  object cbWhich: TComboBox
    Left = 16
    Top = 96
    Width = 145
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 24
    ItemIndex = 0
    ParentFont = False
    TabOrder = 1
    Text = 'Fumigation'
    Items.Strings = (
      'Fumigation'
      'Control'
      'Ambient'
      'Embedded MP'
      '3D Multiport')
  end
  object editVPI: TEdit
    Left = 16
    Top = 177
    Width = 145
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Text = '27'
  end
  object editCO2Span: TEdit
    Left = 16
    Top = 419
    Width = 145
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Text = '1000'
  end
  object editCO2Span2: TEdit
    Left = 16
    Top = 489
    Width = 145
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Text = '300'
  end
  object editH2OSpan: TEdit
    Left = 16
    Top = 624
    Width = 145
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    Text = '20'
  end
  object btnCO2Zero: TButton
    Left = 232
    Top = 344
    Width = 137
    Height = 41
    Caption = 'CO2 Zero'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = OnClickButton
  end
  object btnCO2Span: TButton
    Left = 232
    Top = 410
    Width = 137
    Height = 41
    Caption = 'CO2 Span'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clAqua
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnClick = OnClickButton
  end
  object btnCO2Span2: TButton
    Left = 232
    Top = 480
    Width = 137
    Height = 41
    Caption = 'CO2 Span2'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    OnClick = OnClickButton
  end
  object btnH2OZero: TButton
    Left = 232
    Top = 552
    Width = 137
    Height = 41
    Caption = 'H2O Zero'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
    OnClick = OnClickButton
  end
  object btnH2OSpan: TButton
    Left = 232
    Top = 624
    Width = 137
    Height = 41
    Caption = 'H2O Span'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 10
    OnClick = OnClickButton
  end
  object btnDump: TButton
    Left = 232
    Top = 96
    Width = 137
    Height = 109
    Caption = '&Dump <CAL>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 11
    OnClick = OnClickButton
  end
  object chkAutoDump: TCheckBox
    Left = 232
    Top = 220
    Width = 137
    Height = 25
    Caption = 'Auto dump'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 12
  end
  object memoComm: TMemo
    Left = 440
    Top = 40
    Width = 537
    Height = 513
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      'memoComm')
    ParentFont = False
    TabOrder = 13
  end
  object btnClear: TButton
    Left = 768
    Top = 624
    Width = 97
    Height = 41
    Caption = '&Clear'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 14
    OnClick = OnClickButton
  end
  object btnExit: TButton
    Left = 880
    Top = 624
    Width = 97
    Height = 41
    Caption = 'E&xit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 15
    OnClick = OnClickButton
  end
  object btnGetData: TButton
    Left = 440
    Top = 624
    Width = 185
    Height = 41
    Caption = 'Get Data'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 16
    OnClick = OnClickButton
  end
  object chkLogging: TCheckBox
    Left = 232
    Top = 252
    Width = 137
    Height = 25
    Caption = 'Logging to file'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 17
  end
  object editSN: TEdit
    Left = 136
    Top = 33
    Width = 233
    Height = 32
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 18
    Text = 'xxxxx'
  end
end
