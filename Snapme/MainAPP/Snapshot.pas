unit Snapshot;

interface

uses Classes, SysUtils, Windows, Graphics, Cnst, Dialogs, Forms;

type
  TRange = record
    From,
    Too: Integer;
  end;
  { Sorted selected area }
  TRanges = record
    XRange: TRange;
    YRange: TRange;
  end;
  PRanges = ^TRanges;
  TSnapshot = class
  private
    FbSnapshot,
    FbPreviousSnapshot,
    FbFullSnapshot: TBitmap;
    procedure ScreenShot(ActiveWindow: Boolean; var DestBitmap : TBitmap);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Make(ActiveWindow: Boolean);
    procedure CutPoints(Oblong: TOblong);
    procedure SortRanges(Oblong: TOblong; var Ranges: TRanges);
    procedure Cleanup;
    property Snapshot: TBitmap read FbSnapshot write FbSnapshot;
    property PreviousSnapshot: TBitmap read FbPreviousSnapshot;
    property FullSnapshot: TBitmap read FbFullSnapshot;
  end;

implementation

constructor TSnapshot.Create;
begin
  FbSnapshot:=TBitmap.Create;
  FbPreviousSnapshot:=TBitmap.Create;
  FbFullSnapshot:=TBitmap.Create;
end;

destructor TSnapshot.Destroy;
begin
  FbSnapshot.Free;
  FbPreviousSnapshot.Free;
  FbFullSnapshot.Free;
end;

procedure TSnapshot.ScreenShot(ActiveWindow: Boolean; var DestBitmap : TBitmap);
var
  W, H: Integer;
  DC: HDC;
  hWin: Cardinal;
  r: TRect;
  c: TCanvas;
begin
  if(ActiveWindow)then begin
    hWin:=GetForegroundWindow;
    DC:=GetWindowDC(hWin) ;
    GetWindowRect(hWin, r) ;
    W:=r.Right-r.Left;
    H:=r.Bottom-r.Top;
  end else begin
{
rocedure ScreenShot(Bild: TBitMap);
var
  c: TCanvas;
  r: TRect;
begin
  c := TCanvas.Create;
  c.Handle := GetWindowDC(GetDesktopWindow);
  try
    r := Rect(0, 0, Screen.Width, Screen.Height);
    Bild.Width := Screen.Width;
    Bild.Height := Screen.Height;
    Bild.Canvas.CopyRect(r, c, r);
  finally
    ReleaseDC(0, c.Handle);
    c.Free;
  end;
end;
}
    hWin:=GetDesktopWindow;
    DC:=GetDC(hWin) ;
    W:=GetDeviceCaps(DC, HORZRES);
    H:=GetDeviceCaps(DC, VERTRES);
  end;
  try
    DestBitmap.Width := Screen.Width;
    DestBitmap.Height := Screen.Height;
    BitBlt(DestBitmap.Canvas.Handle, 0, 0, DestBitmap.Width,
           DestBitmap.Height, DC, 0, 0, SRCCOPY);
  finally
    ReleaseDC(hWin, DC) ;
  end;
end;

procedure TSnapshot.Make;
begin
  FbPreviousSnapshot.Assign(FbSnapshot);
  ScreenShot(ActiveWindow, FbSnapshot);
  FbFullSnapshot.Assign(FbSnapshot);
end;

procedure TSnapshot.SortRanges(Oblong: TOblong; var Ranges: TRanges);
begin
  with Oblong do begin
    with Ranges.XRange do begin
      if(A.X>B.X)then begin
        From:=B.X;
        Too:=A.X;
      end else
        if(A.X<B.X)then begin
          From:=A.X;
          Too:=B.X;
        end else begin
          From:=A.X;
          Too:=A.X;
        end;
    end;
    with Ranges.YRange do begin
      if(A.Y>B.Y)then begin
        From:=B.Y;
        Too:=A.Y;
      end else
        if(A.Y<B.Y)then begin
          From:=A.Y;
          Too:=B.Y;
        end else begin
          From:=A.Y;
          Too:=A.Y;
        end;
    end;
  end;
end;

procedure TSnapshot.CutPoints;
var
  Ranges: PRanges;
begin
  New(Ranges);
  SortRanges(Oblong, Ranges^);
  FbPreviousSnapshot.Assign(FbSnapshot);
  FbSnapshot.FreeImage;
  with Ranges^ do begin
    FbSnapshot.Width:=XRange.Too-XRange.From;
    FbSnapshot.Height:=YRange.Too-YRange.From;
    FbSnapshot.Canvas.CopyRect(Rect(0, 0, FbSnapshot.Width, FbSnapshot.Height),
                               FbPreviousSnapshot.Canvas, Rect(XRange.From, YRange.From, XRange.Too, YRange.Too));
  end;
  Dispose(Ranges);
end;

procedure TSnapshot.Cleanup;
begin
  FbSnapshot.FreeImage;
  FbPreviousSnapshot.FreeImage;
  FbFullSnapshot.FreeImage;
end;

end.
