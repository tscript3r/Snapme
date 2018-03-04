unit SaveFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, OmSpBtn, Cnst;

type
  TSaveForm = class(TForm)
    omSpeedBtn1: TomSpeedBtn;
    procedure omSpeedBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDaddysHandle: THandle;
  public
    constructor Create(HWND: THandle); reintroduce; overload;
  end;

var
  SaveForm: TSaveForm;

implementation

{$R *.dfm}

constructor TSaveForm.Create(HWND: THandle);
begin
  inherited Create(nil);
  FDaddysHandle:=HWND;
  PostMessage(FDaddysHandle, WM_SAVE_LAYOUT, 0, Integer(@SaveForm));
end;

procedure TSaveForm.omSpeedBtn1Click(Sender: TObject);
begin
  Close;
end;

procedure TSaveForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PostMessage(FDaddysHandle, WM_SAVE_CLOSE, 0, 0)
end;

end.
