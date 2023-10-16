object frmTopology: TTopology
  Left = 100
  Top = 111
  Width = 650
  Height = 375
  Caption = 'TOPO - Select rings to view and background color'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = OnCreateForm
  PixelsPerInch = 96
  TextHeight = 13
  object RadioGroup1: TRadioGroup
    Left = 15
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Top Left'
    Items.Strings = (
      'None')
    TabOrder = 1
  end
  object RadioGroup2: TRadioGroup
    Left = 120
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Top Right'
    Items.Strings = (
      'None')
    TabOrder = 2
  end
  object RadioGroup3: TRadioGroup
    Left = 225
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Bottom Left'
    Items.Strings = (
      'None')
    TabOrder = 3
  end
  object RadioGroup4: TRadioGroup
    Left = 330
    Top = 15
    Width = 90
    Height = 315
    Caption = 'Bottom Right'
    Items.Strings = (
      'None')
    TabOrder = 4
  end
  object Colorbox: TColorBox
    Left = 440
    Top = 20
    Width = 90
    Height = 35
  end
  object ButtonCancel: TButton
    Left = 556
    Top = 20
    Width = 65
    Height = 35
    Caption = '&Cancel'
    Cancel = True
    OnClick = OnClickCancel
    TabOrder = 5
  end
  object ButtonApply: TButton
    Left = 556
    Top = 70
    Width = 65
    Height = 35
    Caption = '&Apply'
    OnClick = OnClickApply
    TabOrder = 6
  end
  object ButtonOK: TButton
    Left = 556
    Top = 120
    Width = 65
    Height = 35
    Caption = '&OK'
    OnClick = OnClickOK
    TabOrder = 7
  end
end
