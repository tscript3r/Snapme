object SaveForm: TSaveForm
  Left = 336
  Top = 229
  BorderStyle = bsNone
  Caption = 'SaveForm'
  ClientHeight = 406
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object omSpeedBtn1: TomSpeedBtn
    Left = 16
    Top = 344
    Width = 545
    Height = 49
    Caption = 'Cancel'
    Flat = True
    OnClick = omSpeedBtn1Click
    FontHot.Charset = DEFAULT_CHARSET
    FontHot.Color = clWindowText
    FontHot.Height = -11
    FontHot.Name = 'MS Sans Serif'
    FontHot.Style = []
    Options.GrayedDisabledGlyph = True
    Options.GrayedInactiveGlyph = False
    Options.CustomBorderColor = 12871729
    Options.CustomHotColor = 15716542
    Options.CustomPressedColor = 15120025
    Options.CustomShadowColor = 10132122
    Options.SetDefaultColors = False
  end
end
