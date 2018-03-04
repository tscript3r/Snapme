unit MainButtons;

interface

uses SysUtils, Windows, Classes, Forms, OmSpBtn, Cnst, Dialogs;

type
  TButtonsHandler = class
  private
    { Added buttons list }
    FList: TList;
    { Form owner }
    FOwner: TForm;
    FWSize,
    FHSize,
    FInterspace,
    FRLInterspace,
    FTBInterspace: Integer;
    FFit: TFit;
    { Setting Visibility property of Buttons }
    procedure SetVisibility(Visible: Boolean);
  public
    constructor Create(Owner: TForm);
    destructor Destroy; override;
    { Adding button }
    procedure Add(Name: String);
    { Release buttons }
    procedure ReleaseButtons;
    { Selecting button }
    function Button(Name: String): TObject;
    { Showing buttons }
    procedure Show;
    { Hiding buttons }
    procedure Hide;

    procedure Sizes;
    procedure Positions(FullScreen: Boolean);

    property HeightSize:   Integer read FHSize        write FHSize;
    property WidthSize:    Integer read FWSize        write FWSize;
    property Interspace:   Integer read FInterspace   write FInterspace;
    property RLInterspace: Integer read FRLInterspace write FRLInterspace;
    property TBInterspace: Integer read FTBInterspace write FTBInterspace;
    property Fit:          TFit    read FFit          write FFit;
    property List:         TList   read FList         write FList;
  end;

implementation

constructor TButtonsHandler.Create;
begin
  FList:=TList.Create;
  FOwner:=Owner;
end;

destructor TButtonsHandler.Destroy;
begin
  ReleaseButtons;
  FList.Free;
end;

procedure TButtonsHandler.Add;
begin
  FList.Add(TomSpeedBtn.Create(FOwner));
  TomSpeedBtn(FList.Items[FList.Count-1]).Name:=Name;
  TomSpeedBtn(FList.Items[FList.Count-1]).Parent:=FOwner;
  TomSpeedBtn(FList.Items[FList.Count-1]).Caption:=Name;
  TomSpeedBtn(FList.Items[FList.Count-1]).Options.UseCustomColors:=True;
end;

function TButtonsHandler.Button;
var
  I: Integer;
begin
  Result:=nil;
  if(FList.Count-1>0)then
    for I:=0 to FList.Count-1 do
      if(TomSpeedBtn(FList.Items[I]).Name=Name)then
        Result:=FList.Items[I];
end;

procedure TButtonsHandler.SetVisibility;
var
  I: Integer;
begin
  if(FList.Count-1>0)then
    for I:=0 to FList.Count-1 do begin
      TomSpeedBtn(FList.Items[I]).Visible:=Visible;
      TomSpeedBtn(FList.Items[I]).Update;
    end;
end;

procedure TButtonsHandler.Show;
begin
  SetVisibility(True);
end;

procedure TButtonsHandler.Hide;
begin
  SetVisibility(False);
end;


procedure TButtonsHandler.Sizes;
var
  I: Integer;
begin
  { Calculating width of buttons}
  if(FWSize>0)then
    FWSize:=((FWSize*FOwner.Width)div FWSize)
  else
    if(FFit in[2..3])then
      { Vertical Width }
      FWSize:=FOwner.Width-(FRLInterspace*2)
    else begin
      { Horizontal Width }
      FWSize:=FOwner.Width;
      Dec(FWSize, (Interspace*(FList.Count-1)));
      Dec(FWSize, (FRLInterspace*2));
      FWSize:=(FWSize div (FList.Count));
    end;
  { Calculating height of buttons }
  if(FHSize>0)then
    FHSize:=((FHSize*FOwner.Height)div FHSize)
  else
    if(FFit in[0..1])then
      { Horizontal height }
      FHSize:=FOwner.Height-(FRLInterspace*2)
    else begin
      { Vertical height }
      FHSize:=FOwner.Height;
      Dec(FHSize, (Interspace*(FList.Count-1)));
      Dec(FHSize, (FRLInterspace*2));
      FHSize:=(FHSize div (FList.Count));
    end;
  for I:=0 to FList.Count-1 do begin
    TomSpeedBtn(FList.Items[I]).Width:=FWSize;
    TomSpeedBtn(FList.Items[I]).Height:=FHSize;
  end;
end;

procedure TButtonsHandler.Positions;
var
  I,
  XPos,
  YPos: Integer;
begin
  if not(FullScreen)then begin
    XPos:=RLInterspace;
    YPos:=TBInterspace;
  end else begin
    case FFit of
      0: begin
           XPos:=RLInterspace;
           YPos:=(Screen.Height-(TBInterspace+TomSpeedBtn(FList.Items[0]).Height));
         end;
      3: begin
           XPos:=(Screen.Width-(RLInterspace+TomSpeedBtn(FList.Items[0]).Width));
           YPos:=TBInterspace;
         end;
      else begin
           XPos:=RLInterspace;
           YPos:=TBInterspace;
      end;
    end;
  end;
  for I:=0 to FList.Count-1 do begin
    TomSpeedBtn(FList.Items[I]).Left:=XPos;
    TomSpeedBtn(FList.Items[I]).Top:=YPos;
    if(FFit in[0..1])then
      { Horizontal }
      Inc(XPos, (TomSpeedBtn(FList.Items[I]).Width+FInterspace))
    else
      { Vertical }
      Inc(YPos, (TomSpeedBtn(FList.Items[I]).Height+FInterspace));
  end;
end;

procedure TButtonsHandler.ReleaseButtons;
var
  I: Integer;
begin
  if(FList.Count-1>0)then
    for I:=0 to FList.Count-1 do
      TomSpeedBtn(FList.Items[I]).Free;
end;


end.
