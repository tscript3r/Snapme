{
  Message.LParam = VK_CODE
  Message.WParam = Key state -> MSG_W_DOWN
                                MSG_W_UP
                                MSG_W_LONG
                                MSG_W_SHORT
}

library KE;

{$WARNINGS OFF}

uses
  SysUtils,
  Classes,
  Windows,
  Messages;

const
  WH_KEYBOARD_LL = 13;
  LLKHF_ALTDOWN  = $0020;

  MSG_W_DOWN     = 1001;
  MSG_W_SHORT    = MSG_W_DOWN+1;
  MSG_W_LONG     = MSG_W_DOWN+2;
  MSG_W_UP       = MSG_W_DOWN+3;

type
  TKBDLLHOOKSTRUCT = packed record
    vkCode,
    scanCode,
    flags,
    time: DWORD;
    dwExtraInfo: LongWord;
  end;
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;
  TData = record
    KList: TList;
    MSGID: Integer;
    Handle: HWND;
    KHook: Integer;
    Lock,
    LockSpecial: Boolean;
  end;
  PData = ^TData;
  TKey = record
    vkCode,
    PressTime,
    PTime: Integer;
    First,
    Sended: Boolean;
  end;
  PKey = ^TKey;

var
  Data: PData;

function KeyboardHookHandler(ACode: Integer; WParam: WParam;
                             LParam: LParam): LResult; stdcall;
var
  KS: PKBDLLHOOKSTRUCT;
  I: Integer;
begin
  with Data^ do begin
    if(ACode<0)then begin
      Result:=CallNextHookEx(KHook, ACode, WParam, LParam);
      Exit;
    end;
    if(ACode=HC_ACTION)then begin
      KS:=PKBDLLHOOKSTRUCT(Pointer(LParam));
      if(KList.Count>0)then
        for I:=0 to KList.Count-1 do
          with PKey(KList.Items[I])^ do
            if(KS^.vkCode=vkCode)then
              case WParam of
                WM_KEYDOWN: if(First)then begin
                              First:=False;
                              PostMessage(Handle, MSGID, MSG_W_DOWN, vkCode);
                              PTime:=GetTickCount;
                            end else if(GetTickCount-PTime>=PressTime)and not(Sended)then begin
                              Sended:=True;
                              PostMessage(Handle, MSGID, MSG_W_LONG, vkCode);
                            end;
                WM_KEYUP:   begin
                              PostMessage(Handle, MSGID, MSG_W_UP, vkCode);
                              if not(Sended)then begin
                                PostMessage(Handle, MSGID, MSG_W_SHORT, vkCode);
                                PTime:=0;
                              end;
                              First:=True;
                              Sended:=False;
                            end;

              end;
      if(Lock)then
        Result:=-1
      else begin
        Result:=0;
        if(LockSpecial)then begin
          case KS^.vkCode of
            VK_ESCAPE: if(WordBool(GetAsyncKeyState(VK_CONTROL)and $8000))then
                         Result:=-1
                       else
                         if(LongBool(KS^.flags and LLKHF_ALTDOWN))then
                           Result:=-1;
            VK_TAB:    if(LongBool(KS^.flags and LLKHF_ALTDOWN))then
                         Result:=-1;
            VK_RETURN: if(LongBool(KS^.flags and LLKHF_ALTDOWN))then
                         Result:=-1;
            VK_LWIN:   Result:=-1;
            VK_RWIN:   Result:=-1;
            VK_LMENU:  Result:=-1;
            VK_RMENU:  Result:=-1;
          end;
        end;
      end;
    end else Result:=CallNextHookEx(Data^.KHook, ACode, WParam, LParam);
  end;
end;

procedure AddKey(vkCode, PressTime: Integer); stdcall;
var
  Key: PKey;
begin
  New(Key);
  Key^.vkCode:=vkCode;
  Key^.PressTime:=PressTime;
  Key^.First:=True;
  Key^.Sended:=False;
  with Data^ do
    KList.Add(Key);
end;

function RemoveKey(vkCode: Integer): Boolean; stdcall;
var
  I: Integer;
begin
  Result:=False;
  with Data^ do begin
    if(KList.Count>0)then
      for I:=0 to KList.Count-1 do
        if(PKey(KList.Items[I])^.vkCode=vkCode)then begin
          Dispose(KList.Items[I]);
          KList.Delete(I);
          Result:=True;
        end;
  end;
end;

procedure ClearKeys; stdcall;
var
  I: Integer;
begin
  with Data^ do begin
    if(KList.Count>0)then
      for I:=0 to KList.Count-1 do
        Dispose(KList.Items[I]);
    KList.Clear;
  end;
end;

procedure Hook(HWND: HWND; MessageID: Integer); stdcall;
begin
  Data^.MSGID:=MessageID;
  Data^.Handle:=HWND;
  Data^.KHook:=SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardHookHandler, HINSTANCE, 0);
end;

procedure Unhook; stdcall;
begin
  UnhookWindowsHookEx(Data^.KHook);
  Data^.KHook:=0;
end;

procedure LockKeys(Lock: Boolean); stdcall;
begin
  Data^.Lock:=Lock;
end;

procedure LockSpecialKeys(Lock: Boolean); stdcall;
begin
  Data^.LockSpecial:=Lock;
end;

procedure Init(Reason: Integer);
var
  I: Integer;
begin
  if(Reason=DLL_PROCESS_DETACH)then begin
    with Data^ do begin
      if(KList.Count>0)then
        for I:=0 to KList.Count-1 do
          Dispose(KList.Items[i]);
      KList.Free;
    end;
    Dispose(Data);
  end;
end;

exports
  AddKey name 'AddKey',
  RemoveKey name 'RemoveKey',
  ClearKeys name 'ClearKeys',
  Hook name 'Hook',
  Unhook name 'Unhook',
  LockKeys name 'LockKeys',
  LockSpecialKeys name 'LockSpecialKeys';

begin
  DLLProc:=@Init;
  New(Data);
  with Data^ do begin
    KList:=TList.Create;
    Lock:=False;
    LockSpecial:=False;
  end;
end.
