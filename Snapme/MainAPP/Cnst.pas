unit Cnst;

interface

uses Messages, Windows;

type
  { A percent variable }
  TPercent = 0..100;
  { Fit:
    0: Horizontal - Down;
    1: Horizontal - Up;
    2: Vertical   - Left;
    3: Vertical   - Right; }
  TFit = 0..3;
  { Selected area record }
  TOblong = record
    A,
    B: TPoint;
  end;
  POblong = ^TOblong;


const
  VERSION =           '1.0';
  SETTINGS_FILE =     'data\main.xml';
  KE_LIB =            'lib\KE.dll';

  BUTTON_CUT = 'sbCut';
  BUTTON_PAINT = 'sbPaint';
  BUTTON_UPLOAD = 'sbUpload';
  BUTTON_SAVE = 'sbSave';
  BUTTON_COPY = 'sbCopy';
  BUTTON_CANCEL = 'sbCancel';

  BUTTONS_LIST: array[0..5]of String =
  (BUTTON_CUT,
   BUTTON_PAINT,
   BUTTON_COPY,
   BUTTON_UPLOAD,
   BUTTON_SAVE,
   BUTTON_CANCEL);

  { Keyboard hook messages }
  WM_KEYBOARD          = WM_USER+112;
  { User Press sbCut (MenuForm) -> Attendat -> CutMode }
  WM_CUT_MODE          = WM_KEYBOARD+1;
  WM_CUT_POINTS        = WM_KEYBOARD+2;
  { User press sbPaint (MenuForm) -> Attendat -> PaintEdit }
  WM_PAINT_EDIT        = WM_KEYBOARD+3;
  WM_CANCEL            = WM_KEYBOARD+4;
  WM_UPLOAD_LAYOUT     = WM_KEYBOARD+5;
  WM_REVERSE           = WM_KEYBOARD+6;
  WM_UPLOAD            = WM_KEYBOARD+7;

  WM_SAVE              = WM_KEYBOARD+8;
  WM_SAVE_CLOSE        = WM_KEYBOARD+9;
  WM_SAVE_LAYOUT       = WM_KEYBOARD+10;
  WM_COPY_IMAGE        = WM_KEYBOARD+11;

  { Paint Window Class }
  WND_PAIN_CLASS      = 'MSPaintApp';
  { Paint exe file }
  PAINT_EXE           = 'Pbrush.exe';
  { Bitmap extension }
  BMP_EXTENSION       = '.bmp';

  SHELL_OPEN          = 'open';

  SS_FILTERS          = '*.jpg|*.jpg|*.png|*.png|*.bmp|*.bmp';

  E_KE_MISSING        = 'DUPPA';
  E_KE_FAIL           = 'Duupiasto';
  E_LAYOUT_FILE       = 'Blad podczas wczytywania pliku: %s!'#13#10+
                        'Przeinstaluj program.';

implementation

end.
