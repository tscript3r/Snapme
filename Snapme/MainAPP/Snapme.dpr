program Snapme;

uses
  FastMM4,
  SysUtils,
  Forms,
  MenuFrm in 'MenuFrm.pas' {MenuForm},
  ScreenFrm in 'ScreenFrm.pas' {ScreenForm},
  UploadFrm in 'UploadFrm.pas' {UploadForm},
  Cnst in 'Cnst.pas',
  Attendat in 'Attendat.pas',
  Snapshot in 'Snapshot.pas',
  HKHandlers in 'HKHandlers.pas',
  MainButtons in 'MainButtons.pas',
  Settings in 'Settings.pas',
  ScreenSvr in 'ScreenSvr.pas',
  TagPrs in 'TagPrs.pas';

{$R *.res}

var
  Daddy: TAttendat;
  XMLSettings: TXMLSettings;

begin
  Application.Initialize;
  Application.ShowMainForm:=False;
  Application.CreateForm(TMenuForm, MenuForm);
  Application.CreateForm(TScreenForm, ScreenForm);
  Daddy:=TAttendat.Create(Application, MenuForm, ScreenForm);
  try
    XMLSettings:=TXMLSettings.Create;
    try
      XMLSettings.MainLoad;
      XMLSettings.LayoutLoad;
      XMLSettings.LanguageLoad;
      Daddy.SetSettingsInfo(XMLSettings.Design, XMLSettings.LayoutFile,
                            XMLSettings.LangPath, XMLSettings.LayoutFile);
    finally
      XMLSettings.Free;
    end;
    Daddy.RegisterKeys;
    Daddy.StartHook;
    Application.Run;
  finally
    Daddy.Free;
  end;
end.
