object frmLGSelect: TfrmLGSelect
  Left = 183
  Top = 144
  Width = 572
  Height = 321
  Caption = 'Line graph selection'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  OnCreate = OnCreateForm
  OnClose = OnCloseForm
  OnDestroy = OnDestroyForm
  OnKeyDown = OnKeyDownForm
  object gbRing: TGroupBox
    Left = 8
    Top = 8
    Width = 49
    Height = 217
    Caption = 'Ring'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabStop = False
  end
  object gbFile: TGroupBox
    Left = 72
    Top = 8
    Width = 145
    Height = 217
    Caption = 'File type'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabStop = False
    object lblStatus: TLabel
      Left = 8
      Top = 106
      Width = 65
      Height = 16
      AutoSize = False
      Caption = 'Status'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStatusVal: TLabel
      Left = 72
      Top = 104
      Width = 65
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'x'
    end
    object lblRecords: TLabel
      Left = 8
      Top = 126
      Width = 65
      Height = 16
      AutoSize = False
      Caption = 'Records'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblRecordsVal: TLabel
      Left = 72
      Top = 124
      Width = 65
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'x'
    end
    object lblSize: TLabel
      Left = 8
      Top = 146
      Width = 65
      Height = 16
      AutoSize = False
      Caption = 'Size [kB]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSizeVal: TLabel
      Left = 72
      Top = 144
      Width = 65
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'x'
    end
    object lblTStep: TLabel
      Left = 8
      Top = 166
      Width = 65
      Height = 16
      AutoSize = False
      Caption = 'Interval [s]'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblTStepVal: TLabel
      Left = 72
      Top = 164
      Width = 65
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'x'
    end
    object rbLogg: TRadioButton
      Left = 8
      Top = 20
      Width = 97
      Height = 17
      Caption = 'LOGG file'
      TabStop = False
      OnClick = OnClickRadio
    end
    object rbVarr: TRadioButton
      Left = 8
      Top = 40
      Width = 97
      Height = 17
      Caption = 'VARR file'
      TabStop = False
      OnClick = OnClickRadio
    end
    object rbAux: TRadioButton
      Left = 8
      Top = 60
      Width = 97
      Height = 17
      Caption = 'Auxiliary'
      TabStop = False
      OnClick = OnClickRadio
    end
    object rbSnap: TRadioButton
      Left = 8
      Top = 80
      Width = 97
      Height = 17
      Caption = 'Snap shot'
      TabStop = False
      OnClick = OnClickRadio
    end
  end
  object gbPeriod: TGroupBox
    Left = 231
    Top = 8
    Width = 105
    Height = 217
    Caption = 'Period'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabStop = False
    object rbHistoric: TRadioButton
      Left = 12
      Top = 20
      Width = 77
      Height = 17
      Caption = 'Historic'
      TabStop = False
      OnClick = OnClickRadio
    end
    object rbRecent: TRadioButton
      Left = 12
      Top = 40
      Width = 77
      Height = 17
      Caption = 'Recent'
      Checked = True
      TabStop = False
      OnClick = OnClickRadio
    end
    object rbCurrent: TRadioButton
      Left = 12
      Top = 60
      Width = 77
      Height = 17
      Caption = 'Current'
      TabStop = False
      OnClick = OnClickRadio
    end
    object lblHours: TLabel
      Left = 12
      Top = 104
      Width = 36
      Height = 16
      Caption = 'Hours'
    end
    object ebHours: TEdit
      Left = 12
      Top = 120
      Width = 73
      Height = 24
      Text = 'ebHours'
      TabStop = False
    end
    object lblRecord: TLabel
      Left = 12
      Top = 152
      Width = 82
      Height = 16
      Caption = 'From record...'
    end
    object ebRecord: TEdit
      Left = 12
      Top = 168
      Width = 73
      Height = 24
      Text = 'ebRecord'
      TabStop = False
    end
  end
  object gpShortcuts: TGroupBox
    Left = 351
    Top = 8
    Width = 105
    Height = 217
    Caption = 'Short cuts'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabStop = False
    object btnLogg: TButton
      Left = 8
      Top = 24
      Width = 89
      Height = 25
      Caption = '&LOGG data'
      TabStop = False
      OnClick = OnClickButton
    end
    object btnAux: TButton
      Left = 8
      Top = 56
      Width = 89
      Height = 25
      Caption = '&Auxiliary data'
      TabStop = False
      OnClick = OnClickButton
    end
    object rbQuikA: TRadioButton
      Left = 8
      Top = 92
      Width = 89
      Height = 17
      TabStop = False
    end
    object rbQuikB: TRadioButton
      Left = 8
      Top = 112
      Width = 89
      Height = 17
      TabStop = False
    end
    object rbQuikC: TRadioButton
      Left = 8
      Top = 132
      Width = 89
      Height = 17
      TabStop = False
    end
    object rbQuikD: TRadioButton
      Left = 8
      Top = 152
      Width = 89
      Height = 17
      TabStop = False
    end
    object rbQuikE: TRadioButton
      Left = 8
      Top = 172
      Width = 89
      Height = 17
      TabStop = False
    end
    object rbQuikF: TRadioButton
      Left = 8
      Top = 192
      Width = 89
      Height = 17
      TabStop = False
    end
  end
  object btnCancel: TBitBtn
    Left = 471
    Top = 16
    Width = 78
    Height = 33
    Caption = '&Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Default = False
    Kind = bkCancel
    OnClick = OnClickButton
  end
  object btnSetup: TBitBtn
    Left = 471
    Top = 64
    Width = 78
    Height = 33
    Caption = '&Setup'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = OnClickButton
  end
  object btnHelp: TBitBtn
    Left = 471
    Top = 112
    Width = 78
    Height = 33
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Kind = bkHelp
    OnClick = OnClickButton
  end
  object lblHot: TLabel
    Left = 471
    Top = 186
    Width = 60
    Height = 16
    Caption = 'Hot button'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lbHot: TListBox
    Left = 471
    Top = 205
    Width = 73
    Height = 24
    IntegralHeight = True
    ParentColor = False
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 24
    ParentFont = False
    TabStop = False
  end
  object btnGo: TBitBtn
    Left = 8
    Top = 240
    Width = 328
    Height = 41
    Caption = '&Go'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Kind = bkOK
    OnClick = OnClickButton
  end
end
