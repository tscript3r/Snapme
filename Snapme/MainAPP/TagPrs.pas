unit TagPrs;

interface

uses Classes, Windows, SysUtils;

{
  %u = logged user name
  %d = date
  %t = time
  %r = random
}

const
  T_USER_NAME = '%u';
  T_DATE = '%d';
  T_TIME = '%t';
  T_RANDOM = '%r';

function TagParse(S: String): String;
function GetCurrentUserName : string;

implementation

function GetCurrentUserName : string;
const
  cnMaxUserNameLen = 254;
var
  sUserName: String;
  dwUserNameLen: DWord;
begin
  dwUserNameLen:=cnMaxUserNameLen-1;
  SetLength(sUserName, cnMaxUserNameLen );
  GetUserName(PChar(sUserName),dwUserNameLen );
  SetLength(sUserName, dwUserNameLen-1);
  Result:=sUserName;
end;


function TagParse(S: String): String;
begin
  Randomize;
  Result:=StringReplace(S, T_USER_NAME, GetCurrentUserName, [rfReplaceAll]);
  Result:=StringReplace(Result, T_DATE, FormatDateTime('dd-mm-yy', Date), [rfReplaceAll]);
  Result:=StringReplace(Result, T_TIME, FormatDateTime('hh-nn', Time), [rfReplaceAll]);
  Result:=StringReplace(Result, T_RANDOM, IntToStr(Random(99999)), [rfReplaceAll]);
end;

end.
