object MPSample: TMPSample
  Left = 277
  Top = 207
  AutoScroll = False
  Caption = 'Imbedded multiport sampler: data flow'
  ClientHeight = 688
  ClientWidth = 990
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = OnCloseForm
  OnCreate = OnCreateForm
  OnDestroy = OnDestroyForm
  DesignSize = (
    990
    688)
  PixelsPerInch = 120
  TextHeight = 20
  object btnCancel: TBitBtn
    Left = 881
    Top = 639
    Width = 100
    Height = 44
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    TabOrder = 0
    OnClick = OnClickButton
    Kind = bkCancel
  end
  object btnHelp: TBitBtn
    Left = 671
    Top = 639
    Width = 100
    Height = 44
    Anchors = [akRight, akBottom]
    TabOrder = 3
    OnClick = OnClickButton
    Kind = bkHelp
  end
  object btnShowConfig: TButton
    Left = 671
    Top = 639
    Width = 190
    Height = 44
    Anchors = [akRight, akBottom]
    Caption = '&Show configuration'
    ModalResult = 2
    TabOrder = 4
    OnClick = OnClickButton
  end
  object gbRing: TGroupBox
    Left = 10
    Top = 0
    Width = 421
    Height = 621
    Caption = 'Ring variables [mapped node]'
    TabOrder = 1
    object lblRingHeader: TLabel
      Left = 10
      Top = 30
      Width = 50
      Height = 20
      AutoSize = False
      Caption = 'Ring'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblFumigationHeader: TLabel
      Left = 90
      Top = 30
      Width = 100
      Height = 20
      AutoSize = False
      Caption = 'Fumigation'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblControlHeader: TLabel
      Left = 200
      Top = 30
      Width = 100
      Height = 20
      AutoSize = False
      Caption = 'Control'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblAmbientHeader: TLabel
      Left = 308
      Top = 30
      Width = 100
      Height = 20
      AutoSize = False
      Caption = 'Ambient'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object gbMP: TGroupBox
    Left = 440
    Top = 0
    Width = 541
    Height = 621
    Caption = 'Imbedded multiport variables'
    TabOrder = 2
    object lblNodeHeader: TLabel
      Left = 10
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Node'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblChanHeader: TLabel
      Left = 74
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Chan'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblPurgeHeader: TLabel
      Left = 138
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Purge'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSampleHeader: TLabel
      Left = 202
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Samp'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMinFlowHeader: TLabel
      Left = 266
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'MinFl'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblFlowHeader: TLabel
      Left = 330
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Flow'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblValueHeader: TLabel
      Left = 394
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblLastGood1Header: TLabel
      Left = 458
      Top = 14
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Last'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblLastGood2Header: TLabel
      Left = 458
      Top = 30
      Width = 64
      Height = 20
      AutoSize = False
      Caption = 'Good'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object lblIRGA: TLabel
    Left = 8
    Top = 632
    Width = 129
    Height = 20
    AutoSize = False
    Caption = 'irga'
  end
  object lblGood: TLabel
    Left = 152
    Top = 632
    Width = 129
    Height = 20
    AutoSize = False
    Caption = 'good'
  end
  object lblDI: TLabel
    Left = 8
    Top = 664
    Width = 273
    Height = 20
    AutoSize = False
    Caption = 'di'
  end
  object lblCommErr: TLabel
    Left = 297
    Top = 632
    Width = 160
    Height = 20
    AutoSize = False
    Caption = 'commerr'
  end
  object lblTemp: TLabel
    Left = 297
    Top = 664
    Width = 209
    Height = 20
    AutoSize = False
    Caption = 'temp'
  end
end
