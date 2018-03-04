unit HKHandlers;

interface

uses Classes, Windows, Messages, SysUtils, Cnst;

const
  MSG_W_DOWN     = 1001;
  MSG_W_SHORT    = MSG_W_DOWN+1;
  MSG_W_LONG     = MSG_W_DOWN+2;
  MSG_W_UP       = MSG_W_DOWN+3;

type
  THookProc =      procedure(HWND: HWND; MessageID: Integer); stdcall;
  TUnhookProc =    procedure stdcall;
  TLKeysProc =     procedure(Lock: Boolean); stdcall;
  TLSKeysProc =    TLKeysProc;
  TCKeysProc =     TUnhookProc;
  TAddKeyProc =    procedure(vkCode, PressTime: Integer); stdcall;
  TRemoveKeyProc = function(vkCode: Integer): Boolean; stdcall;

  THookHandler = class
  private
    FHandle:    THandle;
    FMessageID: Integer;
    Hook:       THookProc;
    Unhook:     TUnhookProc;
    LKeys:      TLKeysProc;
    LSKeys:     TLSKeysProc;
    CKeys:      TCKeysProc;
    AddKey:     TAddKeyProc;
    RemoveKey:  TRemoveKeyProc;
    DLLHandle:  THandle;
    procedure   LoadDLL;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Add(vkCode, PressTime: Integer);
    procedure   Start;
    procedure   Stop;
    procedure   LockSpecialKeys(Lock: Boolean);
    procedure   LockKeys(Lock: Boolean);
    procedure   ClearKeys;
    function    DeleteKey(vkCode: Integer): Boolean;
    property    Handle: THandle read FHandle write FHandle;
    property    MessageID: Integer read FMessageID write FMessageID;
  end;

  TKey = record
    vkCode,
    KeyID: Integer;
    Modifiers: Cardinal;
  end;
  PKey = ^TKey;

  THotkeyHandler = class
  private
    List: TList;
    FHandle: THandle;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Add(vkCode, KeyID: Integer; Modifiers: Cardinal);
    function    Remove(KeyID: Integer): Boolean;
    procedure   Clear;
    procedure   Start;
    procedure   Stop;
    property    Handle: THandle read FHandle write FHandle;
  end;

  THKHandlers = class
  public
    Hotkeys: THotkeyHandler;
    Hookkeys: THookHandler;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor THookHandler.Create;
begin
  FHandle:=0;
  FMessageID:=0;
  LoadDLL;
end;

destructor THookHandler.Destroy;
begin
  FreeLibrary(DLLHandle);
end;

procedure THookHandler.LoadDLL;
const
  P_HOOK = 'Hook';
  P_UNHOOK = 'Unhook';
  P_LOCK_KEYS = 'LockKeys';
  P_LOCK_SKEYS = 'LockSpecialKeys';
  P_CLEAR_KEYS = 'ClearKeys';
  P_ADD_KEY = 'AddKey';
  P_REMOVE_KEY = 'RemoveKey';
begin
  DLLHandle:=LoadLibrary(PChar(ExtractFilePath(ParamStr(0))+KE_LIB));
  if(DLLHandle<>0)then begin
     @Hook:=GetProcAddress(DLLHandle, P_HOOK) ;
     if not(Assigned(Hook))then
       raise Exception.Create(E_KE_FAIL);
     @Unhook:=GetProcAddress(DLLHandle, P_UNHOOK) ;
     if not(Assigned(Unhook))then
       raise Exception.Create(E_KE_FAIL);
     @LSKeys:=GetProcAddress(DLLHandle, P_LOCK_SKEYS) ;
     if not(Assigned(LSKeys))then
       raise Exception.Create(E_KE_FAIL);
     @LKeys:=GetProcAddress(DLLHandle, P_LOCK_KEYS) ;
     if not(Assigned(LKeys))then
       raise Exception.Create(E_KE_FAIL);
     @CKeys:=GetProcAddress(DLLHandle, P_CLEAR_KEYS) ;
     if not(Assigned(CKeys))then
       raise Exception.Create(E_KE_FAIL);
     @AddKey:=GetProcAddress(DLLHandle, P_ADD_KEY) ;
     if not(Assigned(AddKey))then
       raise Exception.Create(E_KE_FAIL);
     @RemoveKey:=GetProcAddress(DLLHandle, P_REMOVE_KEY) ;
     if not(Assigned(RemoveKey))then
       raise Exception.Create(E_KE_FAIL);
  end else
    raise Exception.Create(E_KE_MISSING);
end;

procedure THookHandler.Add;
begin
  AddKey(vkCode, PressTime);
end;

procedure THookHandler.Start;
begin
  Hook(FHandle, FMessageID);
end;

procedure THookHandler.Stop;
begin
  Unhook;
end;

procedure THookHandler.LockSpecialKeys;
begin
  LSKeys(Lock);
end;

procedure THookHandler.LockKeys;
begin
  LKeys(Lock);
end;

function THookHandler.DeleteKey;
begin
  Result:=RemoveKey(vkCode);
end;

procedure THookHandler.ClearKeys;
begin
  CKeys;
end;

constructor THotkeyHandler.Create;
begin
  List:=TList.Create;
end;

destructor THotkeyHandler.Destroy;
begin
  Clear;
  List.Free;
end;

function THotkeyHandler.Remove;
var
  I: Integer;
begin
  Result:=False;
  if(List.Count>0)then
    for I:=0 to List.Count-1 do
      if(PKey(List.Items[I])^.KeyID=KeyID)then begin
        Dispose(List.Items[I]);
        List.Delete(I);
        Result:=True;
      end;
end;

procedure THotkeyHandler.Add;
var
  Key: PKey;
begin
  New(Key);
  Key^.vkCode:=vkCode;
  Key^.KeyID:=KeyID;
  Key^.Modifiers:=Modifiers;
  List.Add(Key);
end;

procedure THotkeyHandler.Clear;
var
  I: Integer;
begin
  if(List.Count>0)then begin
    for I:=0 to List.Count-1 do
      Dispose(List.Items[I]);
    List.Clear;
  end;
end;

procedure THotkeyHandler.Start;
var
  I: Integer;
  Key: PKey;
begin
  if(List.Count>0)then
    for I:=0 to List.Count-1 do begin
      Key:=List.Items[I];
      with Key^ do
        RegisterHotKey(FHandle, KeyID, Modifiers, vkCode);
    end;
end;

procedure THotkeyHandler.Stop;
var
  I: Integer;
  Key: PKey;
begin
  if(List.Count>0)then
    for I:=0 to List.Count-1 do begin
      Key:=List.Items[I];
      with Key^ do
        UnregisterHotKey(FHandle, KeyID);
    end;
end;

constructor THKHandlers.Create;
begin
  Hotkeys:=THotkeyHandler.Create;
  Hookkeys:=THookHandler.Create;
end;

destructor THKHandlers.Destroy;
begin
  HotKeys.Free;
  HookKeys.Free;
end;


end.
