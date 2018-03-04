{

  TODO: Resolution change handling -> 163
        Loading Cut <> Reverse caption
}

unit MenuFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Cnst, OmSpBtn, MainButtons;

type
  TMenuForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnsOnClick(Sender: TObject);
  private
    FSize: TPercent;
    FFit: TFit;
    FDaddysHandle: THandle;
    FFullScreen: Boolean;
    FCutCaption,
    FReverseCaption: String;
    { Resolution which has been fitted }
    FitResolution: Integer;
    { Calculating by increasing bits the Resolution }
    function Resolution: Integer;
    { Checking if the resolution has ben changed }
    function ChangedResolution: Boolean;
    { Creating buttons }
    procedure CreateButtons;
  public
    Buttons: TButtonsHandler;
    procedure SetButtons;
    { Calculating & setting the size of MenuForm }
    procedure FormSize(FullScreen: Boolean);
    { Calculating & setting the position of MenuForm }
    procedure FormPosition(FullScreen: Boolean);
    procedure FullScreen(Full: Boolean);
    { Storing the Percent size of MenuForm }
    property Size: TPercent read FSize write FSize;
    { Storing the Fit of MenuForm }
    property Fit: TFit read FFit write FFit;
    property DaddysHandle: THandle read FDaddysHandle write FDaddysHandle;
    property FullScr: Boolean read FFullScreen;

    property CutCaption: String read FCutCaption write FCutCaption;
    property ReverseCaption: String read FReverseCaption write FReverseCaption;
  end;

var
  MenuForm: TMenuForm;

implementation

uses UploadFrm;

{$R *.dfm}

function TMenuForm.Resolution: Integer;
begin
  { Bits increasing }
  Result:=Screen.Width or Screen.Height;
end;

function TMenuForm.ChangedResolution: Boolean;
begin
  if(Resolution=FitResolution)then
    Result:=False
  else
    Result:=True;
end;

procedure TMenuForm.FormSize;
begin
  { Setting MenuForm size }
  if(FullScreen)then begin
//    Left:=1;
//    Top:=1;
    Width:=Screen.Width;
    Height:=Screen.Height;
  end else begin
    if(Fit in[0..1])then begin
      { Horizontal }
      Width:=Screen.Width;
      Height:=(Size*Screen.Height)div 100;
    end else begin
      { Vertical }
      Height:=Screen.Height;
      Width:=(Size*Screen.Width)div 100;
    end;
  end;
end;

procedure TMenuForm.FormPosition;
begin
  { Setting the MenuForm position }
  if(FullScreen)then begin
    Left:=1;
    Top:=1;
  end else
    case FFit of
      { Horizontal, fit bottom }
      0: begin
        Left:=0;
        Top:=Screen.Height-Height;
      end;
      { Vertical, fit to the right }
      3: begin
        Top:=0;
        Left:=Screen.Width-Width;
      end;
      { Horizontal, fit to the top & Vertical, fit to the left }
      else begin
        Left:=0;
        Top:=0;
      end;
    end;
end;

procedure TMenuForm.CreateButtons;
var
  I: Integer;
begin
  for I:=Low(BUTTONS_LIST) to Length(BUTTONS_LIST)-1 do
    Buttons.Add(BUTTONS_LIST[I]);
end;

procedure TMenuForm.FormCreate(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLong(Application.Handle, GWL_EXSTYLE,
                getWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  ShowWindow(Application.Handle, SW_SHOW);
  Buttons:=TButtonsHandler.Create(MenuForm);
  CreateButtons;
  SetButtons;
  FFullScreen:=True;
end;

procedure TMenuForm.FormDestroy(Sender: TObject);
begin
  Buttons.Free;
end;

procedure TMenuForm.BtnsOnClick(Sender: TObject);
begin
  if(Sender is TomSpeedBtn)then begin
    if((Sender as TomSpeedBtn).Name=BUTTON_CUT)then
      if not(FFullScreen)then
        PostMessage(FDaddysHandle, WM_CUT_MODE, 0, 0)
      else
        PostMessage(FDaddysHandle, WM_REVERSE, 0, 0);
    if((Sender as TomSpeedBtn).Name=BUTTON_PAINT)then
      PostMessage(FDaddysHandle, WM_PAINT_EDIT, 0, 0);
    if((Sender as TomSpeedBtn).Name=BUTTON_CANCEL)then
      PostMessage(FDaddysHandle, WM_CANCEL, 0, 0);
    if((Sender as TomSpeedBtn).Name=BUTTON_UPLOAD)then
      PostMessage(FDaddysHandle, WM_UPLOAD, 0, 0);
    if((Sender as TomSpeedBtn).Name=BUTTON_SAVE)then
      PostMessage(FDaddysHandle, WM_SAVE, 0, 0);
    if((Sender as TomSpeedBtn).Name=BUTTON_COPY)then
      PostMessage(FDaddysHandle, WM_COPY_IMAGE, 0, 0);
  end;
end;

procedure TMenuForm.SetButtons;
var
  I: Integer;
begin
  with Buttons.List do
    for I:=0 to Count-1 do
      TomSpeedBtn(Items[I]).OnClick:=BtnsOnClick;
end;

procedure TMenuForm.FullScreen;
begin
  if not(Full)then
    TomSpeedBtn(Buttons.Button(BUTTON_CUT)).Caption:=FCutCaption
  else
    TomSpeedBtn(Buttons.Button(BUTTON_CUT)).Caption:=FReverseCaption;
  if(Full<>FFullScreen)or(ChangedResolution)then begin
    FormSize(Full);
    FormPosition(Full);
    if(ChangedResolution)then begin
      Buttons.Sizes;
      FitResolution:=Resolution;
    end;
    FFullScreen:=Full;
    Buttons.Positions(Full);
  end;
end;


end.
