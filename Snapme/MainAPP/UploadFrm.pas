
unit UploadFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Cnst, StdCtrls, OmSpBtn;

type
  TUploadForm = class(TForm)
    procedure sbCancelClick(Sender: TObject);
  private
    FDaddysHandle: THandle;
  public
    constructor Create(HWND: THandle); reintroduce; overload;
  end;

var
  UploadForm: TUploadForm;

implementation

{$R *.dfm}

constructor TUploadForm.Create(HWND: THandle);
begin
  inherited Create(nil);
  FDaddysHandle:=HWND;
end;

procedure TUploadForm.sbCancelClick(Sender: TObject);
begin
  Close;
end;

end.
