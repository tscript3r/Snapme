unit ScreenSvr;

interface

uses Classes, SysUtils, Windows, Dialogs, Cnst, TagPrs;

type
  TScreenSaver = class(TSaveDialog)
  public
    constructor Create; reintroduce; overload;
    procedure SetInitialDir(S: String);
    procedure SetDefaultName(S: String);
  end;

implementation

constructor TScreenSaver.Create;
begin
  inherited Create(nil);
  Filter:=SS_FILTERS;

end;

procedure TScreenSaver.SetInitialDir(S: String);
begin
  InitialDir:=TagParse(S);
end;

procedure TScreenSaver.SetDefaultName(S: String);
begin
  FileName:=TagParse(S);
end;

end.
