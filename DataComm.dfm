object DataComm: TDataComm
  Left = 343
  Top = 144
  Width = 831
  Height = 547
  Caption = 'Data communications'
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
  PixelsPerInch = 96
  TextHeight = 16
  object grpConfig: TGroupBox
    Left = 16
    Top = 8
    Width = 172
    Height = 432
    Caption = 'Configuration'
    TabOrder = 3
    object lblVPI: TLabel
      Left = 16
      Top = 24
      Width = 98
      Height = 16
      Caption = 'Virtual port index'
    end
    object lblProtocol: TLabel
      Left = 16
      Top = 80
      Width = 50
      Height = 16
      Caption = 'Protocol'
    end
    object lbl1: TLabel
      Left = 16
      Top = 144
      Width = 14
      Height = 16
      Caption = '#1'
    end
    object lbl2: TLabel
      Left = 16
      Top = 192
      Width = 14
      Height = 16
      Caption = '#2'
    end
    object lbl3: TLabel
      Left = 16
      Top = 240
      Width = 14
      Height = 16
      Caption = '#3'
    end
    object lbl4: TLabel
      Left = 16
      Top = 288
      Width = 14
      Height = 16
      Caption = '#4'
    end
    object lbl5: TLabel
      Left = 16
      Top = 336
      Width = 14
      Height = 16
      Caption = '#5'
    end
    object lbl6: TLabel
      Left = 16
      Top = 384
      Width = 14
      Height = 16
      Caption = '#6'
    end
    object comboVPI: TComboBox
      Left = 16
      Top = 40
      Width = 121
      Height = 24
      DropDownCount = 32
      ItemHeight = 16
      TabOrder = 1
      OnChange = OnChangeText
    end
    object editProtocol: TEdit
      Left = 16
      Top = 96
      Width = 120
      Height = 24
      Hint = 'What hardware and software used for data acquisition and control'
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = 'protocol'
    end
    object edit1: TEdit
      Left = 16
      Top = 160
      Width = 120
      Height = 24
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      Text = '#1'
    end
    object edit2: TEdit
      Left = 16
      Top = 208
      Width = 120
      Height = 24
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      Text = '#2'
    end
    object edit3: TEdit
      Left = 16
      Top = 256
      Width = 120
      Height = 24
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      Text = '#3'
      OnChange = OnChangeText
    end
    object edit4: TEdit
      Left = 16
      Top = 304
      Width = 120
      Height = 24
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      Text = '#4'
    end
    object edit5: TEdit
      Left = 16
      Top = 352
      Width = 120
      Height = 24
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      Text = '#5'
    end
    object edit6: TEdit
      Left = 16
      Top = 400
      Width = 65
      Height = 24
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 7
      Text = '#6'
    end
    object btnTimeoutApply: TButton
      Left = 88
      Top = 400
      Width = 49
      Height = 25
      Caption = 'Apply'
      TabOrder = 8
      OnClick = OnClickButton
    end
  end
  object grpErrstats: TGroupBox
    Left = 188
    Top = 8
    Width = 609
    Height = 432
    Caption = 'Data acquisition && control error statistics'
    TabOrder = 4
    object memoStats: TMemo
      Left = 0
      Top = 56
      Width = 609
      Height = 376
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      Lines.Strings = (
        'memoStat')
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
    object rbType: TRadioButton
      Left = 32
      Top = 24
      Width = 97
      Height = 17
      Caption = 'By &type'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = OnClickRadio
    end
    object rbAddr: TRadioButton
      Left = 144
      Top = 24
      Width = 97
      Height = 17
      Caption = 'By a&ddress'
      TabOrder = 2
      OnClick = OnClickRadio
    end
    object btnRaw: TButton
      Left = 472
      Top = 20
      Width = 121
      Height = 25
      Caption = 'Ra&w data flow'
      TabOrder = 3
      OnClick = OnClickButton
    end
  end
  object grpRaw: TGroupBox
    Left = 188
    Top = 8
    Width = 609
    Height = 432
    Caption = 'Data acquisition && control raw data flow'
    TabOrder = 5
    Visible = False
    object memoRaw: TMemo
      Left = 0
      Top = 56
      Width = 609
      Height = 376
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      Lines.Strings = (
        'memoRaw')
      MaxLength = 30000000
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
    object btnCopy: TButton
      Left = 3
      Top = 20
      Width = 119
      Height = 25
      Hint = 'Copy memoRaw window contents to clipboard'
      Caption = 'Copy to Clipboard'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = OnClickButton
    end
    object cbPause: TCheckBox
      Left = 328
      Top = 24
      Width = 65
      Height = 17
      Hint = 'Pause display of raw data flow'
      Caption = '&Pause'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = OnClickCheck
    end
    object btnClear: TButton
      Left = 400
      Top = 20
      Width = 65
      Height = 25
      Hint = 'Click here if display stops scrolling (may be full)'
      Caption = 'Cle&ar'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = OnClickButton
    end
    object btnStats: TButton
      Left = 472
      Top = 20
      Width = 121
      Height = 25
      Hint = 'Return to error statistics display'
      Caption = '&Error statistics'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = OnClickButton
    end
  end
  object btnCancel: TBitBtn
    Left = 713
    Top = 454
    Width = 85
    Height = 25
    Hint = 'Exit the data communications window'
    Caption = '&Cancel'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = OnClickButton
    Kind = bkCancel
  end
  object btnUpdate: TButton
    Left = 613
    Top = 454
    Width = 85
    Height = 25
    Hint = 'Load current error statistics (refresh display)'
    Caption = '&Update'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = OnClickButton
  end
  object btnReset: TButton
    Left = 513
    Top = 454
    Width = 85
    Height = 25
    Hint = 'Zero (clear) the error statistics'
    Caption = '&Reset'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = OnClickButton
  end
  object cbErrlog: TCheckBox
    Left = 17
    Top = 454
    Width = 265
    Height = 17
    Hint = 'Data acquisition and control errors will be logged to disk'
    Caption = '&Log errors to '
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = OnClickCheck
  end
end
