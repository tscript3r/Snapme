unit ScreenFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Cnst;

type
  TScreenForm = class(TForm)
    iScreen: TImage;
    procedure iDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure iDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  private
{    FMenuHeight: Integer;
    FMenuFit: TFit;
    FMenuHandle: THandle;
}
    FDaddyHandle: THandle;
    bOriginal: TBitmap;
    CutMe: Boolean;
    SetPointsState: Integer;
    Oblong: POblong;
  public
    procedure Size;
    procedure Pos;
    procedure SetImage(B: TBitmap);
    procedure CutPoints;
    procedure SendPoints;
    property DaddysHandle: THandle read FDaddyHandle write FDaddyHandle;
  end;

var
  ScreenForm: TScreenForm;

implementation

uses MenuFrm;

{$R *.dfm}

procedure TScreenForm.Size;
begin
  Width:=iScreen.Width;
  Height:=iScreen.Height;
  AutoSize:=True;
  Refresh;
end;

procedure TScreenForm.Pos;
begin
  iScreen.Left:=0;
  iScreen.Top:=0;
  if(iScreen.Width or iScreen.Height)=(Screen.Width or Screen.Height)then begin
    { Fullscreen }
    Position:=poDesigned;
    Left:=0;
    Top:=0;
  end else
    Position:=poDesktopCenter;
end;

procedure TScreenForm.SetImage;
begin
  iScreen.Picture.Bitmap:=B;
  iScreen.Width:=B.Width;
  iScreen.Height:=B.Height;
  iScreen.Refresh;
  Size;
  Pos;
end;

procedure TScreenForm.CutPoints;
begin
  New(Oblong);
  SetPointsState:=0;
  CutMe:=True;
  bOriginal:=TBitmap.Create;
  bOriginal.Assign(iScreen.Picture.Bitmap);
end;

procedure TScreenForm.iDrawMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
  begin
  if(not(CutMe))and(not(MenuForm.Active))then
    case MenuForm.Fit of
      0: if(Y>=MenuForm.Top)then  MenuForm.Show;
      1: if(Y<=MenuForm.Top)then  MenuForm.Show;
      2: if(X<=MenuForm.Left)then MenuForm.Show;
      3: if(X>=MenuForm.Left)then MenuForm.Show;
    end;
  if(SetPointsState=1)and(CutMe)then begin
    iScreen.Repaint;
    with Canvas do begin
      Pen.Color:=$00E6371E;
      MoveTo(Oblong^.A.X, Oblong^.A.Y);
      LineTo(X, Oblong^.A.Y);
      MoveTo(Oblong^.A.X, Oblong^.A.Y);
      LineTo(Oblong^.A.X, Y);
      MoveTo(X, Y);
      LineTo(Oblong^.A.X, Y);
      MoveTo(X, Y);
      LineTo(X, Oblong^.A.Y);
    end;
  end;
end;

procedure TScreenForm.FormCreate(Sender: TObject);
begin
  CutMe:=False;
  SetPointsState:=0;
end;

procedure TScreenForm.iDrawMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if(CutMe)then begin
    Inc(SetPointsState);
    with Oblong^ do begin
      case SetPointsState of
        1: begin
             A.X:=X;
             A.Y:=Y;
           end;
        2: begin
             iScreen.Picture.Bitmap.Assign(bOriginal);
             B.X:=X;
             B.Y:=Y;
             SendPoints;
             CutMe:=False;
             SetPointsState:=0;
             bOriginal.Free;
           end;
      end;
    end;
  end;
end;

procedure TScreenForm.SendPoints;
begin
  PostMessage(FDaddyHandle, WM_CUT_POINTS, 0, Integer(Oblong));
end;

procedure TScreenForm.FormShow(Sender: TObject);
var
   r : TRect;
begin
   Borderstyle := bsNone;
   SystemParametersInfo
      (SPI_GETWORKAREA, 0, @r,0) ;
   SetBounds
     (r.Left, r.Top, r.Right-r.Left, r.Bottom-r.Top) ;
end;

end.
