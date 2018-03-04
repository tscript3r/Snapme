unit Attendat;

{

  TODO: Uncomment -> 112

}

interface

uses
  Dialogs, Forms, Cnst, MenuFrm, ScreenFrm, SysUtils, Windows, Messages, Classes, Snapshot,
  HKHandlers, ClipBrd, ShellApi, UploadFrm, SaveFrm, Settings, OmSpBtn, ScreenSvr;

type
  TAttendat = class(TObject)
  private
    FHWND : THandle;
    FMenuForm: TMenuForm;
    FScreenForm: TScreenForm;
    FApplication: TApplication;
    Design,
    LangPath,
    Lang,
    LayoutPath: String;
    Snapshot: TSnapshot;
    KeysHandler: THKHandlers;
    procedure WndMethod(var Msg: TMessage);
  public
    constructor Create(Application: TApplication; MenuForm: TMenuForm; ScreenForm: TScreenForm);
    destructor Destroy; override;
    { Creates snapshot, and stores it }
    procedure MakeScreen(ActiveWindow: Boolean);
    { Shows forms: MenuForm & ScreenForm }
    procedure ShowForms;
    { Hide forms: MenuForm & ScreenForm }
    procedure HideForms;
    { Registers hotkeys }
    procedure RegisterKeys;
    { Starts monitoring the keyboard }
    procedure StartHook;
    { It's called when the user press & hold the Snapshot button }
    procedure InitEditMode;
    { It's called when the user press shortly the Snapshot button }
    procedure InitQuickMode;
    { Translating pressed by user keys }
    procedure TranslateKey(vkCode, State: Integer);
    { Setting the UploadForm layout }
    procedure UploadSettings;
    { Storing some data from main.xml }
    procedure SetSettingsInfo(DesignName, LayoutFile, LangName, LangFile: String);
    { An show - effect for Forms }
    procedure FormsShowEffect(Forms: array of TForm);
    { It's called when the user press the sbCut button }
    procedure CutMode;
    { It's called by a message from TScreenForm, when the user select two cut points }
    procedure CutPoints(Oblong: POblong);
    { Reversing a cutted snapshot to oryginal. It's called by sbCut in revers mode button }
    procedure Reverse;
    { Sending the snapshot/cutted snapshot to paint }
    procedure PaintEdit;
    procedure Upload;
    procedure Save;
    procedure HideAPP;
    procedure Copy;
    { Self handle, for other objects }
    property Handle: THandle read FHWND;
  end;

implementation

constructor TAttendat.Create;
begin
  inherited Create;
  FHWND:=AllocateHWND(WndMethod);
  FScreenForm:=ScreenForm;
  FMenuForm:=MenuForm;
  FApplication:=Application;
  Snapshot:=TSnapshot.Create;
  KeysHandler:=THKHandlers.Create;
  FMenuForm.DaddysHandle:=FHWND;
  FScreenForm.DaddysHandle:=FHWND;
end;

destructor TAttendat.Destroy;
begin
  Snapshot.Free;
  KeysHandler.Free;
  DeallocateHWND(FHWND);
  inherited;
end;


{ A parser for pressed by user keys; the KE.dll hook sends four states of an key:
  - MSG_W_DOWN  - the key is down pressed
  - MSG_W_UP    - the key is up pressed
  - MSG_W_LONG  - the key was held-pressed
  - MSG_W_SHORT - was normally - fast pressed }
procedure TAttendat.TranslateKey;
begin
  case vkCode of
    VK_SNAPSHOT:
      case State of
        MSG_W_DOWN:  MakeScreen(False);
        MSG_W_LONG:  InitEditMode;
        MSG_W_SHORT: InitQuickMode;
      end;
    VK_ESCAPE:    //if(MenuForm.Showing)then
      HideForms;
  end;
end;

{ This method is an receiver for messages, from:
   - KE.dll - keyboard hook
   - other forms }
procedure TAttendat.WndMethod(var Msg: TMessage);
begin
  case Msg.Msg of
    { Hook keys receiver }
    WM_KEYBOARD:
      TranslateKey(Msg.LParam, Msg.WParam);
    { Snapshot2Paint sender }
    WM_PAINT_EDIT:
      PaintEdit;
    { Abort/Cancel button }
    WM_CANCEL:
      HideAPP;
    { Loading layout settings for dynamic-loaded UploadForm }
    WM_UPLOAD_LAYOUT:
      UploadSettings;
    { Reversing an cut }
    WM_REVERSE:
      Reverse;
    { Cut button method }
    WM_CUT_MODE:
      CutMode;
    { Cutting image by received points }
    WM_CUT_POINTS:
      CutPoints(Pointer(Msg.LParam));
    { MenuForm -> Upload button click }
    WM_UPLOAD:
      Upload;
    { MenuForm -> Save button click }
    WM_SAVE:
      Save;
    WM_COPY_IMAGE:
      Copy;
  end;
end;

procedure TAttendat.ShowForms;
begin
  with KeysHandler.Hookkeys do
    LockKeys(True);
  FMenuForm.FullScreen(False);
  FScreenForm.Show;
  FMenuForm.Show;
  SetForegroundWindow(FScreenForm.Handle);
  SetForegroundWindow(FMenuForm.Handle);
  //FormsShowEffect([FScreenForm, FMenuForm]);
end;

{ The APPs main method - screen creation; using the TSnapshot class. }
procedure TAttendat.MakeScreen;
begin
  { BLING! Creating & Storing the Snapshot }
  Snapshot.Make(ActiveWindow);
  { Setting up the screen for TScreenForm }
  FScreenForm.SetImage(Snapshot.Snapshot);
end;

procedure TAttendat.RegisterKeys;
begin
  with KeysHandler.Hookkeys do begin
    Handle:=FHWND;
    MessageID:=WM_KEYBOARD;
    Add(VK_SNAPSHOT, 350);
    Add(VK_ESCAPE, 350);
  end;
end;

procedure TAttendat.StartHook;
begin
  with KeysHandler.Hookkeys do
    Start;
end;

procedure TAttendat.InitEditMode;
begin
  ShowForms;
end;

procedure TAttendat.InitQuickMode;
begin

end;

procedure TAttendat.CutMode;
begin
  FMenuForm.Hide;
  FScreenForm.FormStyle:=fsStayOnTop;
  FScreenForm.CutPoints;
end;

procedure TAttendat.CutPoints;
begin
  { Cutting the full screen shot to selected area}
  Snapshot.CutPoints(Oblong^);
  { Releasing pointed-record TOblong ( Includes two points for the cut function ) }
  Dispose(Oblong);
  FScreenForm.Hide;
  { Setting cutted screen to the ScreenForm & autosize, and autoposition of ScreenForm }
  FScreenForm.SetImage(Snapshot.Snapshot);
  { Changing size of MenuForm to full screen size form }
  FMenuForm.FullScreen(True);

  FMenuForm.Show;
  FScreenForm.Show;
end;

procedure TAttendat.PaintEdit;
var
  CP: TClipboard;
  I: Integer;
begin
  { Setting up for sure the Snapshot in to clipboard }
  CP:=TClipboard.Create;
  try
    CP.Assign(Snapshot.Snapshot);
  finally
    CP.Free;
  end;
  { Hidding the APP }
  HideAPP;
  { Opening the Paint }
  ShellExecute(0, SHELL_OPEN, PAINT_EXE, nil, nil, 1);
  { Waiting X sec for paint }
  I:=0;
  while not(isWindow(FindWindow(WND_PAIN_CLASS, nil)))do begin
    Sleep(100);
    Inc(I);
    if(I=50)then Break;
  end;
  if(isWindow(FindWindow(WND_PAIN_CLASS, nil)))then begin
    { Window found }
    SetForegroundWindow(FindWindow(WND_PAIN_CLASS, nil));
    { Virtually pressing the CTRL+V (paste) combination }
    keybd_event(VK_CONTROL, 0, 0, 0);
    keybd_event($56, 0, 0, 0);
    keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);
  end;
end;

procedure TAttendat.HideForms;
begin
  { Unlocking all keys }
  KeysHandler.Hookkeys.LockKeys(False);
  FMenuForm.Hide;
  FScreenForm.Hide;
end;

procedure TAttendat.FormsShowEffect;
const
  INC_VALUE = 178;
var
  I: Integer;
  Blends: array of Integer;
begin
  SetLength(Blends, 0);
  for I:=Low(Forms) to Length(Forms)-1 do begin
    SetLength(Blends, I+1);
    Blends[I]:=Forms[I].AlphaBlendValue;
    Forms[I].AlphaBlendValue:=0;
    Forms[I].Show;
  end;
  for I:=Low(Forms) to Length(Forms)-1 do begin
    repeat
      if(Forms[I].AlphaBlendValue+INC_VALUE>=Blends[I])then begin
        Forms[I].AlphaBlendValue:=Blends[I];
        Break;
      end else
        Forms[I].AlphaBlendValue:=Forms[I].AlphaBlendValue+INC_VALUE;
    until(Forms[I].AlphaBlendValue>=Blends[I]);
  end;
  SetLength(Blends, 0);
end;

{ Storing some data from main.xml for dynamic-loaded forms }
procedure TAttendat.SetSettingsInfo;
begin
  Design:=DesignName;
  LayoutPath:=LayoutFile;
  Lang:=LangName;
  LangPath:=LangFile;
end;


{ This method is called when the user press the 'sbCut' in revers mode button.
  Its an method to restore oryginal snapshot, from the cutted snapshot. }
procedure TAttendat.Reverse;
begin
  FScreenForm.Hide;
  FScreenForm.FormStyle:=fsNormal;  // ?
  FScreenForm.SetImage(Snapshot.FullSnapshot);
  Snapshot.Snapshot.Assign(Snapshot.FullSnapshot);
  FScreenForm.Show;

  FMenuForm.Hide;
  FMenuForm.FullScreen(False);
  FMenuForm.Show;
end;

procedure TAttendat.UploadSettings;
var
  UploadLayoutSettings: TUploadLayoutSettings;
begin
  try
    UploadLayoutSettings:=TUploadLayoutSettings.Create(LayoutPath);
    try
      UploadLayoutSettings.Load(Design, LayoutPath, UploadForm);
    finally
      UploadLayoutSettings.Free;
    end;
  except
    Halt(0);
  end;
end;

procedure TAttendat.Upload;
begin
  UploadForm:=TUploadForm.Create(FHWND);
  UploadSettings;
  try
    with MenuForm do begin
      Buttons.Hide;
      FullScreen(True);
      FApplication.ProcessMessages;
      UploadForm.ShowModal;
      FullScreen(False);
      Buttons.Show;
    end;
  finally
    UploadForm.Free;
  end;
end;

procedure TAttendat.Save;
var
  ScreenSaver: TScreenSaver;
  ScreenSaverSettings: TScreenSaverSettings;
begin
  try
    ScreenSaver:=TScreenSaver.Create;
    ScreenSaverSettings:=TScreenSaverSettings.Create(SETTINGS_FILE);
    try
      with MenuForm do begin
        Buttons.Hide;
        FormPosition(True);
        FullScreen(True);
        ScreenForm.Hide;
        ScreenSaverSettings.Load(ScreenSaver);
        if not(DirectoryExists(PChar(ScreenSaver.InitialDir)))then
          CreateDirectory(PChar(ScreenSaver.InitialDir), nil);
        ScreenSaver.Execute;
        FormPosition(False);
        FullScreen(False);
        Buttons.Show;
        HideAPP;
      end;
    finally
      ScreenSaver.Free;
      ScreenSaverSettings.Free;
    end;
  except
    FApplication.Terminate;
  end;
end;

procedure TAttendat.HideAPP;
begin
  HideForms;
  ScreenForm.iScreen.Picture.Bitmap.FreeImage;
  Snapshot.Cleanup;
end;

procedure TAttendat.Copy;
var
  CP: TClipboard;
begin
  { Setting up for sure the Snapshot in to clipboard }
  CP:=TClipboard.Create;
  try
    CP.Assign(Snapshot.Snapshot);
  finally
    CP.Free;
  end;
  HideAPP;
end;

end.
