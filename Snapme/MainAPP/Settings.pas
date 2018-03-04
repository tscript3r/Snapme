{

  TODO: ERROR HANDLING ~ 197

}

unit Settings;

interface

uses SysUtils, Classes, Windows, Dialogs, xmldom, XMLIntf, msxmldom, XMLDoc,
     MenuFrm, Cnst, OmSpBtn, StdCtrls, UploadFrm, SaveFrm, Forms, ScreenSvr;

const
  { XML Attributes }
  XML_A_COLOR =                 'color';
  XML_A_BLEND =                 'blend';
  XML_A_SIZE =                  'size';
  XML_A_FIT =                   'fit';
  XML_A_LANG =                  'lang';
  XML_A_WIDTH =                 'width';
  XML_A_HEIGHT =                'height';
  XML_A_NAME =                  'name';
  XML_A_PATH =                  'path';
  XML_A_INTERSPACE =            'interspace';
  XML_A_TRANS =                 'trans';
  XML_A_RLINTERSPACE =          'rl_'+XML_A_INTERSPACE;
  XML_A_TBINTERSPACE =          'tb_'+XML_A_INTERSPACE;
  XML_A_HOT_COLOR =             'h_'+XML_A_COLOR;
  XML_A_FONT_COLOR =            'f_'+XML_A_COLOR;
  XML_A_FONT_HOT_COLOR =        'fh_'+XML_A_COLOR;
  XML_A_FONT_SIZE =             'f_'+XML_A_SIZE;
  XML_A_FONT_HOT_SIZE =         'fh_'+XML_A_SIZE;
  XML_A_FONT_NAME =             'f_'+XML_A_NAME;
  XML_A_FONT_HOT_NAME =         'fh_'+XML_A_NAME;
  XML_A_STYLE =                 'style';
  XML_A_CAPTION =               'caption';
  XML_A_CAPTION_EX =            'caption_ex';
  XML_A_FORMAT =                'format';
  XML_A_LAST_PATH =             'last_'+XML_A_PATH;
  { XML Tags }
  { *** Layouts.xml *** }
  XML_ROOT =                    'Layout';
  { MenuForm Child }
  XML_BUTTON_SIZES =            'ButtonsSize';
  XML_BUTTON =                  'Button';
  { *** main.xml **** }
  XML_MAIN_ROOT =               'Settings';
  XML_GLOBAL =                  'General';
  XML_GLOBAL_LAYOUT =           'Layout';
  XML_GLOBAL_LANG =             'Lang';
  XML_GLOBAL_LANGS =            'Languages';
  XML_SCREEN_SAVER =            'ScreenSaver';
  { ** LANG_TAG.xml ** }
  XML_LANG_LANG =               'Language';


type
  TSettings = class
  private
    XML: IXMLDOCUMENT;
  public
    constructor Create(SettingsFile: String);
    destructor Destroy; override;
  end;

  TLayoutSettings = class(TSettings)
  public
    procedure Load(DesignName: String; var MenuForm: TMenuForm);
  end;

  TUploadLayoutSettings = class(TSettings)
  public
    procedure Load(DesignName, LayoutFile: String; var UploadForm: TUploadForm);
  end;

  TSaveLayoutSettings = class(TSettings)
  public
    procedure Load(DesignName, LayoutFile: String; var SaveForm: TSaveForm);
  end;

  TLanguageSettings = class(TSettings)
  public
    procedure Load(var MenuForm: TMenuForm);
  end;

  TGlobalSettings = class(TSettings)
  public
    procedure Load(var LayoutFile, Design, LangPath: String);
  end;

  TScreenSaverSettings = class(TSettings)
  public
    procedure Load(var ScreenSaver: TScreenSaver);
  end;

  TXMLSettings = class
  private
    FLayoutFile,
    FDesign,
    FLangPath: String;
  public
    procedure MainLoad;
    procedure LayoutLoad;
    procedure LanguageLoad;
    property LayoutFile: String read FLayoutFile;
    property Design: String read FDesign;
    property LangPath: String read FLangPath;
  end;

implementation

function PathGenerate: String;
begin
  Result:=ExtractFilePath(ParamStr(0))+'\';
end;

constructor TSettings.Create;
begin
  XML:=LoadXMLDocument(SettingsFile);
  XML.Active := True;
end;

destructor TSettings.Destroy;
begin
  XML.Active := False;
end;


procedure TLayoutSettings.Load;
var
  LayoutNode, StartNode, SecondNode : IXMLNODE;
  Btn: TomSpeedBtn;
begin
  try
    LayoutNode:=XML.DocumentElement.ChildNodes.FindNode(DesignName);
    { Loading MenuForm layout properties }
    StartNode:=LayoutNode.ChildNodes.FindNode(MenuForm.Name);
    { Form attributes }
    with MenuForm do begin
      Color:=StartNode.Attributes[XML_A_COLOR];
      AlphaBlend:=True;  // BOOL Attribute?
      AlphaBlendValue:=StartNode.Attributes[XML_A_BLEND];
      Size:=StartNode.Attributes[XML_A_SIZE];
      Fit:=StartNode.Attributes[XML_A_FIT];
      Buttons.Fit:=StartNode.Attributes[XML_A_FIT];
      FullScreen(False);
    end;
    { Button attributes }
    with MenuForm.Buttons do begin
      { Buttons sizes, etc... }
      SecondNode:=StartNode.ChildNodes.FindNode(XML_BUTTON_SIZES);
      WidthSize:=SecondNode.Attributes[XML_A_WIDTH];
      HeightSize:=SecondNode.Attributes[XML_A_HEIGHT];
      Interspace:=SecondNode.Attributes[XML_A_INTERSPACE];
      TBInterspace:=SecondNode.Attributes[XML_A_TBINTERSPACE];
      RLInterspace:=SecondNode.Attributes[XML_A_RLINTERSPACE];
      { Single button properties }
      SecondNode:=StartNode.ChildNodes.FindNode(XML_BUTTON);
      repeat
        Btn:=TomSpeedBtn(Button(SecondNode.Attributes[XML_A_NAME]));
        if not(Assigned(Btn))then
          raise Exception.Create(Format(E_LAYOUT_FILE, []));
        with Btn do begin
          Options.CustomBorderColor:=SecondNode.Attributes[XML_A_COLOR];
          Options.CustomHotColor:=SecondNode.Attributes[XML_A_HOT_COLOR];
          Font.Color:=SecondNode.Attributes[XML_A_FONT_COLOR];
          FontHot.Color:=SecondNode.Attributes[XML_A_FONT_HOT_COLOR];
          Font.Size:=SecondNode.Attributes[XML_A_FONT_SIZE];
          FontHot.Size:=SecondNode.Attributes[XML_A_FONT_HOT_SIZE];
          Font.Name:=SecondNode.Attributes[XML_A_FONT_NAME];
          FontHot.Name:=SecondNode.Attributes[XML_A_FONT_HOT_NAME];
        end;
        SecondNode:=SecondNode.NextSibling;
      until(SecondNode=nil);
      Sizes;
      Positions(False);
    end;
  except
    Halt(0);
  end;
end;

procedure TLanguageSettings.Load;
var
  RootNode, ClassNode, TransNode : IXMLNODE;
  Obj: TObject;
begin
  try
    RootNode:=XML.ChildNodes.FindNode(XML_LANG_LANG);
    { MenuForm traslatings }
    ClassNode:=RootNode.ChildNodes.FindNode(MenuForm.Name);
    TransNode:=ClassNode.ChildNodes.First;
    repeat
      if(TransNode.LocalName=XML_BUTTON)then begin
        Obj:=MenuForm.FindComponent(TransNode.Attributes[XML_A_NAME]);
        if(Assigned(Obj))then begin
          if(TomSpeedBtn(Obj).Name<>BUTTON_CUT)then
            TomSpeedBtn(Obj).Caption:=TransNode.Attributes[XML_A_CAPTION]
          else begin
            TomSpeedBtn(Obj).Caption:=TransNode.Attributes[XML_A_CAPTION];
            MenuForm.CutCaption:=TransNode.Attributes[XML_A_CAPTION];
            MenuForm.ReverseCaption:=TransNode.Attributes[XML_A_CAPTION_EX];
          end;
        end else
          raise Exception.Create('');
      end;
      TransNode:=TransNode.NextSibling;
    until(TransNode=nil);
  except
    Halt(0);
  end;
end;

procedure TGlobalSettings.Load;
var
  GlobalNode, StartNode, SecondNode, DeepNode : IXMLNODE;
  S: String;
begin
  try
    { Layout File & Layout Design }
    GlobalNode:=XML.ChildNodes.FindNode(XML_MAIN_ROOT);
    StartNode:=GlobalNode.ChildNodes.FindNode(XML_GLOBAL);
    SecondNode:=StartNode.ChildNodes.FindNode(XML_GLOBAL_LAYOUT);
    LayoutFile:=SecondNode.Attributes[XML_A_PATH];
    Design:=SecondNode.Attributes[XML_A_NAME];
    SecondNode:=StartNode.ChildNodes.FindNode(XML_GLOBAL_LANG);
    S:=SecondNode.Attributes[XML_A_NAME];
    if(Length(S)=0)then
      raise Exception.Create('dupa');
    { Selected lang & Path to lang file }
    SecondNode:=StartNode.ChildNodes.FindNode(XML_GLOBAL_LANGS);
    DeepNode:=SecondNode.ChildNodes.FindNode(XML_A_LANG);
    repeat
      if(DeepNode.Attributes[XML_A_NAME]=S)then begin
        LangPath:=PathGenerate+DeepNode.Attributes[XML_A_PATH];
        Break;
      end;
      DeepNode:=DeepNode.NextSibling;
    until(DeepNode=nil);
    if not(FileExists(LangPath))or(DeepNode=nil)then
      raise Exception.Create('DUPA!');
  except
    Halt(0);
  end;
end;

procedure TUploadLayoutSettings.Load(DesignName, LayoutFile: String; var UploadForm: TUploadForm);
var
  I: Integer;
  LayoutNode, StartNode, DeepNode : IXMLNODE;
  Btn: TomSpeedBtn;
begin
  try
    LayoutNode:=XML.DocumentElement.ChildNodes.FindNode(DesignName);
    { Loading UploadForm layout properties }
    StartNode:=LayoutNode.ChildNodes.FindNode(UploadForm.Name);
    with UploadForm do begin
      AlphaBlendValue:=StartNode.Attributes[XML_A_BLEND];
      Color:=StartNode.Attributes[XML_A_COLOR];
      I:=StartNode.Attributes[XML_A_STYLE];
      case I of
        0: BorderStyle:=bsNone;
        1: BorderStyle:=bsToolWindow;
        2: BorderStyle:=bsSingle;
      end;
      DeepNode:=StartNode.ChildNodes.FindNode(XML_BUTTON);
      repeat
        Btn:=TomSpeedBtn(UploadForm.FindComponent(DeepNode.Attributes[XML_A_NAME]));
        if not(Assigned(Btn))then
          raise Exception.Create(Format(E_LAYOUT_FILE, []));
        with Btn do begin
          Options.CustomBorderColor:=DeepNode.Attributes[XML_A_COLOR];
          Options.CustomHotColor:=DeepNode.Attributes[XML_A_HOT_COLOR];
          Font.Color:=DeepNode.Attributes[XML_A_FONT_COLOR];
          FontHot.Color:=DeepNode.Attributes[XML_A_FONT_HOT_COLOR];
          Font.Size:=DeepNode.Attributes[XML_A_FONT_SIZE];
          FontHot.Size:=DeepNode.Attributes[XML_A_FONT_HOT_SIZE];
          Font.Name:=DeepNode.Attributes[XML_A_FONT_NAME];
          FontHot.Name:=DeepNode.Attributes[XML_A_FONT_HOT_NAME];
        end;
        DeepNode:=DeepNode.NextSibling;
      until(DeepNode=nil);
    end;
  except
    //Halt(0);
  end;
end;

procedure TSaveLayoutSettings.Load(DesignName, LayoutFile: String; var SaveForm: TSaveForm);
begin
end;

procedure TScreenSaverSettings.Load(var ScreenSaver: TSCreenSaver);
var
  GlobalNode, StartNode, DeepNode : IXMLNODE;
begin
  GlobalNode:=XML.ChildNodes.FindNode(XML_MAIN_ROOT);
  StartNode:=GlobalNode.ChildNodes.FindNode(XML_GLOBAL);
  DeepNode:=StartNode.ChildNodes.FindNode(XML_SCREEN_SAVER);
  ScreenSaver.SetInitialDir(DeepNode.Attributes[XML_A_PATH]);
  ScreenSaver.SetDefaultName(DeepNode.Attributes[XML_A_NAME]);
end;


procedure TXMLSettings.MainLoad;
var
  GlobalSettings: TGlobalSettings;
begin
  GlobalSettings:=TGlobalSettings.Create(PathGenerate+SETTINGS_FILE);
  try
    GlobalSettings.Load(FLayoutFile, FDesign, FLangPath);
  finally
    GlobalSettings.Free;
  end;
end;

procedure TXMLSettings.LayoutLoad;
var
  Layout: TLayoutSettings;
begin
  Layout:=TLayoutSettings.Create(PathGenerate+LayoutFile);
  try
    Layout.Load(Design, MenuForm);
  finally
    Layout.Free;
  end;
end;

procedure TXMLSettings.LanguageLoad;
var
  Lang: TLanguageSettings;
begin
  Lang:=TLanguageSettings.Create(LangPath);
  try
    Lang.Load(MenuForm);
  finally
    Lang.Free;
  end;
end;


end.
