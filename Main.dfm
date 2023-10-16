object Main: TMain
  Left = 0
  Top = 0
  Width = 248
  Height = 235
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Arial'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClick = OnClickForm
  OnClose = OnCloseForm
  OnCreate = OnCreateForm
  OnKeyDown = OnKeyDownForm
  OnResize = OnResizeForm
  PixelsPerInch = 96
  TextHeight = 16
  object lblDateTitle: TLabel
    Left = 0
    Top = 0
    Width = 42
    Height = 19
    Caption = 'Date:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDateValue: TLabel
    Left = 0
    Top = 0
    Width = 28
    Height = 16
    Caption = 'date'
  end
  object lblDOYTitle: TLabel
    Left = 0
    Top = 0
    Width = 40
    Height = 19
    Caption = 'DOY:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDOYValue: TLabel
    Left = 0
    Top = 0
    Width = 23
    Height = 16
    Caption = 'doy'
  end
  object lblTimeTitle: TLabel
    Left = 0
    Top = 0
    Width = 43
    Height = 19
    Caption = 'Time:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblTimeValue: TLabel
    Left = 0
    Top = 0
    Width = 26
    Height = 16
    Caption = 'time'
  end
  object lblTZTitle: TLabel
    Left = 0
    Top = 0
    Width = 45
    Height = 16
    Caption = 'tzname'
  end
  object lblTZValue: TLabel
    Left = 0
    Top = 0
    Width = 44
    Height = 16
    Caption = 'tzvalue'
  end
  object lblDiskTitle: TLabel
    Left = 0
    Top = 0
    Width = 40
    Height = 19
    Caption = 'Disk:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDiskValue: TLabel
    Left = 0
    Top = 0
    Width = 25
    Height = 16
    Caption = 'disk'
  end
  object lblMemoryTitle: TLabel
    Left = 0
    Top = 0
    Width = 62
    Height = 19
    Caption = 'Memory'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
  end
  object lblMemoryAvail: TLabel
    Left = 0
    Top = 0
    Width = 64
    Height = 19
    Caption = 'Available'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object lblMemoryTotal: TLabel
    Left = 0
    Top = 0
    Width = 32
    Height = 19
    Caption = 'Total'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object lblPhysicalTitle: TLabel
    Left = 0
    Top = 0
    Width = 65
    Height = 19
    Caption = 'Physical'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblPhysicalAvail: TLabel
    Left = 0
    Top = 0
    Width = 29
    Height = 16
    Caption = 'avail'
  end
  object lblPhysicalTotal: TLabel
    Left = 0
    Top = 0
    Width = 27
    Height = 16
    Caption = 'total'
  end
  object lblPageFileTitle: TLabel
    Left = 0
    Top = 0
    Width = 66
    Height = 19
    Caption = 'PageFile'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblPageFileAvail: TLabel
    Left = 0
    Top = 0
    Width = 29
    Height = 16
    Caption = 'avail'
  end
  object lblPageFileTotal: TLabel
    Left = 0
    Top = 0
    Width = 27
    Height = 16
    Caption = 'total'
  end
  object lblVirtualTitle: TLabel
    Left = 0
    Top = 0
    Width = 51
    Height = 19
    Caption = 'Virtual'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblVirtualAvail: TLabel
    Left = 0
    Top = 0
    Width = 29
    Height = 16
    Caption = 'avail'
  end
  object lblVirtualTotal: TLabel
    Left = 0
    Top = 0
    Width = 26
    Height = 16
    AutoSize = False
    Caption = 'total'
  end
  object MainMenu: TMainMenu
    Left = 208
    Top = 112
    object mnuFile: TMenuItem
      Caption = '&File'
      object mnuFileData: TMenuItem
        Caption = '&Data files'
        object mnuFileDataBackup: TMenuItem
          Caption = '&Backup'
          OnClick = OnClickMenu
        end
        object mnuFileDataDumps: TMenuItem
          Caption = '&Dumps'
          OnClick = OnClickMenu
        end
        object mnuFileDataLogging: TMenuItem
          Caption = '&Logging'
          OnClick = OnClickMenu
        end
      end
      object mnuFileSep1: TMenuItem
        Caption = '-'
      end
      object mnuFileConsole: TMenuItem
        Caption = '&Console screen'
        OnClick = OnClickMenu
      end
      object mnuFileSep2: TMenuItem
        Caption = '-'
      end
      object mnuFileExit: TMenuItem
        Caption = 'E&xit'
        OnClick = OnClickMenu
      end
    end
    object mnuRingPictures: TMenuItem
      Caption = '&Ring pictures'
      OnClick = OnClickMenu
    end
    object mnuCalibration: TMenuItem
      Caption = '&Calibration'
      object mnuCalibrationAutomatic: TMenuItem
        Caption = '&Automatic'
        OnClick = OnClickMenu
      end
      object mnuCalibrationManual: TMenuItem
        Caption = '&Manual'
        OnClick = OnClickMenu
      end
    end
    object mnuCompare: TMenuItem
      Caption = 'Co&mpare'
      OnClick = OnClickMenu
    end
    object mnuConfig: TMenuItem
      Caption = 'Co&nfiguration'
      object mnuConfigDataComm: TMenuItem
        Caption = '&Data communications'
        OnClick = OnClickMenu
      end
      object mnuConfigMPSample: TMenuItem
        Caption = '&Multiport sampler'
        OnClick = OnClickMenu
      end
      object mnuConfigNetLog: TMenuItem
        Caption = '&Network logging'
        OnClick = OnClickMenu
      end
      object mnuConfigWatchdog: TMenuItem
        Caption = '&Watchdog'
        OnClick = OnClickMenu
      end
      object mnuConfigSep1: TMenuItem
        Caption = '-'
      end
      object mnuConfigConnect: TMenuItem
        Caption = '&Connect rings'
        OnClick = OnClickMenu
      end
    end
    object mnuUtilities: TMenuItem
      Caption = '&Utilities'
      object mnuDataflow: TMenuItem
        Caption = '&Data flow'
        object mnuDataflowMPSample: TMenuItem
          Caption = 'Multiport sampler'
          OnClick = OnClickMenu
        end
      end
      object mnuSunEphemeris: TMenuItem
        Caption = '&Sun ephemeris'
        OnClick = OnClickMenu
      end
      object mnuWaterVapor: TMenuItem
        Caption = '&Water vapor'
        OnClick = OnClickMenu
      end
    end
    object mnuHelp: TMenuItem
      Caption = '&Help'
      object mnuHelpTopics: TMenuItem
        Caption = '&Help topics'
        OnClick = OnClickMenu
      end
      object mnuHelpDiagnostics: TMenuItem
        Caption = '&Diagnostics'
        object mnuHelpDiagnosticsComponents: TMenuItem
          Caption = '&Components'
          OnClick = OnClickMenu
        end
      end
      object mnuHelpAbout: TMenuItem
        Caption = '&About'
        object mnuHelpAboutSystem: TMenuItem
          Caption = '&System'
          OnClick = OnClickMenu
        end
        object mnuHelpAboutFCP: TMenuItem
          Caption = '&FCP'
          OnClick = OnClickMenu
        end
      end
    end
  end
end
