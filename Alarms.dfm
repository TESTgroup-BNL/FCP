object frmAlarms: TfrmAlarms
  Left = 120
  Top = 127
  Width = 632
  Height = 375
  Autoscroll = FALSE
  Caption = 'Alarms'
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
  OnKeyDown = OnKeyDownForm
  PixelsPerInch = 96
  TextHeight = 16
  object lblEHeader: TLabel
    Left = 0
    Top = 0
    Width = 43
    Height = 16
    Caption = 'Errors'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblTHeader: TLabel
    Left = 0
    Top = 0
    Width = 47
    Height = 16
    Caption = 'Trailer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDHeader: TLabel
    Left = 0
    Top = 0
    Width = 50
    Height = 16
    Caption = 'Dialout'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnHelp: TBitBtn
    Left = 308
    Top = 320
    Width = 96
    Height = 25
    TabOrder = 2
    OnClick = OnClickTest
    Kind = bkHelp
  end
  object btnReset: TButton
    Left = 408
    Top = 320
    Width = 96
    Height = 25
    Caption = '&Reset alarms'
    TabOrder = 0
    OnClick = OnClickTest
  end
  object btnCancel: TBitBtn
    Left = 508
    Top = 320
    Width = 96
    Height = 25
    Caption = '&Cancel'
    TabOrder = 1
    OnClick = OnClickTest
    Kind = bkCancel
  end
  object cbAudible: TCheckBox
    Left = 16
    Top = 320
    Width = 145
    Height = 25
    Caption = 'Test audible alarm'
    TabOrder = 3
    OnClick = OnClickTest
  end
  object cbWatchdog: TCheckBox
    Left = 160
    Top = 320
    Width = 161
    Height = 25
    Caption = 'Test watchdog dial out'
    TabOrder = 4
    OnClick = OnClickTest
  end
end
