object frmLineGraf: TfrmLineGraf
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCreate = OnCreateForm
  OnClose = OnCloseForm
  OnDestroy = OnDestroyForm
  OnKeyDown = OnKeyDownForm
  Visible = True
  PixelsPerInch = 96
  object imageLG: TImage
    Cursor = crCross
  end
  object btnCancel: TBitBtn
    Caption = '&Cancel'
    OnClick = OnClickButton
    Kind = bkCancel
  end
  object btnHelp: TBitBtn
    Caption = '&Help'
    OnClick = OnClickButton
    Kind = bkHelp
  end
  object cbAveraging: TCheckBox
    Caption = '&Averaging'
    AllowGrayed = False
  end
end
