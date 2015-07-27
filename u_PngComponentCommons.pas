unit u_PngComponentCommons;

                                         INTERFACE

uses
  pngimage, Graphics, Types, Buttons, Windows, Controls, Themes, Classes,
  UxTheme, PngImageList;


type
  TPngOption2 = (
       pngBlendOnEnabled, pngGrayscaleOnEnabled, 
       pngBlendOnDisabled, pngGrayscaleOnDisabled,
       pngBlendNotHovering, pngGrayscaleNotHovering
    );
  TPngOptions2 = set of TPngOption2;

  TThemingPreset = (tpCustom, tpButton, tpFlatButton, tpToolButton);

  TButtonDrawState = record
    bEnabled: Boolean;
    bPressed: Boolean;
    bHot: Boolean;
    bDefault: Boolean;
    class operator Equal(a: TButtonDrawState; d: TButtonDrawState): Boolean;
    procedure Assign(from: TButtonDrawState);
  end;
  
  TThemedButtonDetails = class;
  
  TThemedElementDetailsObject = class(TPersistent)
  private
    m_owner: TThemedButtonDetails;
    m_Element: TThemedElement;
    m_Part: Integer;
    m_State: Integer;
    procedure SetElement(AElement: TThemedElement);
    procedure SetPart(const Value: Integer);
    procedure SetState(const Value: Integer);
    function GetElement: TThemedElement;
    function GetPart: Integer;
    function GetState: Integer;
    procedure Changed;
  public
    constructor Create(AOwner: TThemedButtonDetails); reintroduce;
    procedure Assign(Source : TPersistent); override;
  published
    property Element: TThemedElement read GetElement write SetElement default teButton;
    property Part: Integer read GetPart write SetPart default BP_PUSHBUTTON;
    property State: Integer read GetState write SetState default PBS_NORMAL;
  end;
  
  IThemedButtonDetails = interface
  ['{D0171D60-E4F8-4216-A0C4-B2A3BE812A58}']
    function GetNormal: TThemedElementDetailsObject;
    function GetDisabled: TThemedElementDetailsObject;
    function GetHot: TThemedElementDetailsObject;
    function GetPressed: TThemedElementDetailsObject;
    property Normal: TThemedElementDetailsObject read GetNormal;
    property Disabled: TThemedElementDetailsObject read GetDisabled;
    property Hot: TThemedElementDetailsObject read GetHot;
    property Pressed: TThemedElementDetailsObject read GetPressed;
  end;

  IButtonControl = interface
  ['{8B2D2C7E-12A7-40B4-A161-4122AAC9E8DA}']
    function GetThemedDetails: IThemedButtonDetails;
    function GetDrawState: TButtonDrawState;
    function GetLayout: TButtonLayout;
    function GetPngOptions: TPngOptions2;
    function GetMargin: Integer;
    function GetSpacing: Integer;
    function GetPngBlendFactor: Integer;
    function GetText: string;
    function GetControl: TControl;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetEnabled: boolean;
    function GetClientRect: TRect;
    function GetPngImage: TPngImage;
    function GetCanvas: TCanvas;
    function GetFont: TFont;
    
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property Layout: TButtonLayout read GetLayout;
    property Caption: string read GetText;
    property PngBlendFactor: Integer read GetPngBlendFactor;
    property Spacing: Integer read GetSpacing;
    property Margin: Integer read GetMargin;
    property DrawState: TButtonDrawState read GetDrawState;
    property Enabled: boolean read GetEnabled;
    property ThemedDetails: IThemedButtonDetails read GetThemedDetails;
    property ClientRect: TRect read GetClientRect;
    property PngImage: TPngImage read GetPngImage;
    property PngOptions: TPngOptions2 read GetPngOptions;
    property Canvas: TCanvas read GetCanvas;
    property Font: TFont read GetFont;
  end;

  TThemedButtonDetails = class(TInterfacedPersistent, IThemedButtonDetails)
  private
    m_normal, 
    m_pressed, 
    m_hot, 
    m_disabled: TThemedElementDetailsObject;
    m_themingpreset: TThemingPreset;
    m_bChanging: Boolean;
    FOnChange: TNotifyEvent;
    function GetNormal: TThemedElementDetailsObject;
    function GetDisabled: TThemedElementDetailsObject;
    function GetHot: TThemedElementDetailsObject;
    function GetPressed: TThemedElementDetailsObject;
    procedure SetDisabled(const Value: TThemedElementDetailsObject);
    procedure SetNormal(const Value: TThemedElementDetailsObject);
    procedure SetHot(const Value: TThemedElementDetailsObject);
    procedure SetPressed(const Value: TThemedElementDetailsObject);
    procedure SetThemingPreset(const Value: TThemingPreset);
    function GetThemingPreset: TThemingPreset;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ThemingDetailsChanged(Sender: TObject);
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    procedure Assign(Source: TPersistent); override;
  protected
    function IsStored: Boolean;
  published
    property Normal: TThemedElementDetailsObject read GetNormal write SetNormal stored IsStored;
    property Disabled: TThemedElementDetailsObject read GetDisabled write SetDisabled stored IsStored;
    property Hot: TThemedElementDetailsObject read GetHot write SetHot stored IsStored;
    property Pressed: TThemedElementDetailsObject read GetPressed write SetPressed stored IsStored;
    property _Kind: TThemingPreset read GetThemingPreset write SetThemingPreset;
  end;
  
  TButtonsLib = class
  public  
    class procedure RenderButton(control: IButtonControl); overload;
    class procedure RenderButton(r: TRect; PngImage: TPngImage; DrawState: TButtonDrawState; h: HDC; Caption: string; control: TControl; Layout: TButtonLayout; Margin, Spacing, PngBlendFactor: Integer; Options: TPngOptions2; Font: TFont); overload;
    class procedure _DrawPNG(Png: TPngImage; Canvas: TCanvas; const ARect: TRect; const Options: TPngOptions2; drawstate: TButtonDrawState; PngBlendFactor: Integer);
    class procedure CalcButtonLayout(Canvas: TCanvas; PngImage: TPngImage; const Client:
      TRect; Pressed, Down: Boolean; const Caption: string; Layout: TButtonLayout;
      Margin, Spacing: Integer; var GlyphPos, TextPos: TPoint; BiDiFlags: LongInt);
  end;
  
  TPngLib = class
  public
    class procedure PngDrawOver(base, overlay: TPngImage; Left, top: Integer);
  end;

  TButtonOverlay = class(TPersistent)
  private 
    m_images: TPngImageList;
    m_nImageIndex: Integer;
    m_left: Integer;
    m_top: Integer;
    FOnChange: TNotifyEvent;
    procedure SetImageIndex(const Value: Integer);
    procedure SetImages(const Value: TPngImageList);
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure Changed;
    function GetImages: TPngImageList;
    function GetImageIndex: Integer;
    function GetLeft: Integer;
    function GetTop: Integer;
  public
    constructor Create;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published 
    property Images: TPngImageList read GetImages write SetImages;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex default -1;
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
  end;

{$IF RTLVersion < 23.0 }
type
  TThemeServicesHelper = class helper for TThemeServices
  private
    function GetEnabled: Boolean;
  public
    function GetElementContentRect(DC: HDC; Details: TThemedElementDetails; const BoundingRect: TRect;
        out ContentRect: TRect): Boolean; overload;
    property Enabled: Boolean read GetEnabled;
  end;
{$IFEND}


procedure Register;
  
const
  SDelphiComponentsPageName = 'PngComponents2';

                                       IMPLEMENTATION




uses
  PngFunctions
  ,SysUtils, Math
  {$ifdef nbi},u_Ini {$endif}
  ,Dialogs;


{$region 'TThemeServicesHelper'}
///From PngBitBtn:
{$IF RTLVersion < 23.0 }

function TThemeServicesHelper.GetElementContentRect(DC: HDC; Details: TThemedElementDetails; const BoundingRect: TRect;
    out ContentRect: TRect): Boolean;
begin
  ContentRect := Self.ContentRect(DC, Details, BoundingRect);
  Result := true;
end;

function TThemeServicesHelper.GetEnabled: Boolean;
begin
  Result := ThemesEnabled;
end;
{$IFEND}
{$endregion 'TThemeServicesHelper'}



  
class procedure TButtonsLib._DrawPNG(Png: TPngImage; Canvas: TCanvas; const ARect: TRect; const Options: TPngOptions2; drawstate: TButtonDrawState; PngBlendFactor: Integer);
{-----------------------------------------------------------------------------
  Procedure: _DrawPNG
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: Png: TPngImage; Canvas: TCanvas; const ARect: TRect; const Options: TPngOptions2
  Result:    None
-----------------------------------------------------------------------------}
var
  PngCopy: TPngImage;
begin
  if Options <> [] then begin
    PngCopy := TPngImage.Create;
    try
      PngCopy.Assign(Png);
      
      if(not drawstate.bEnabled) then begin
        /// disabled
        if (u_PngComponentCommons.pngGrayscaleOnDisabled in Options) then
          MakeImageGrayscale(PngCopy);
        if (u_PngComponentCommons.pngBlendOnDisabled in Options) then
          MakeImageBlended(PngCopy, PngBlendFactor);
      end 
      else 
      begin
        /// ENABLED
        if (pngGrayscaleOnEnabled in Options) then
          MakeImageGrayscale(PngCopy);
        if (pngBlendOnEnabled in Options) then
          MakeImageBlended(PngCopy, PngBlendFactor);

        /// not hovered?
        if(not drawstate.bHot) and (pngGrayscaleNotHovering in Options) then
          MakeImageGrayscale(PngCopy);
        if(not drawstate.bHot) and (pngBlendNotHovering in Options) then
          if(not drawstate.bPressed) then   //dont blend when button is Down
            MakeImageBlended(PngCopy, PngBlendFactor);
      end;
        
      try
        PngCopy.Draw(Canvas, ARect);
      except
        on e:Exception do begin
          raise;
        end;
      end;
    finally
      PngCopy.Free;
    end;
  end
  else begin
    Png.Draw(Canvas, ARect);
  end;
end;



class procedure TButtonsLib.RenderButton(control: IButtonControl);
begin
  TButtonsLib.RenderButton(control.ClientRect, control.PngImage, control.DrawState,
    control.Canvas.Handle, control.Caption, control.GetControl, control.Layout, control.Margin, control.Spacing,
    control.PngBlendFactor, control.PngOptions, control.font
  );
end;



class procedure TButtonsLib.RenderButton(r: TRect; PngImage: TPngImage;
   DrawState: TButtonDrawState; h: HDC; Caption: string; control: TControl; Layout: TButtonLayout; 
   Margin, Spacing, PngBlendFactor: integer; Options: TPngOptions2; Font: TFont);
var
  Canvas: TCanvas;
  PaintRect: TRect;
  GlyphPos, TextPos: TPoint;
  //LastOrigin: TPoint;
  
  procedure DrawTheText;
  var
    PaintRect: TRect;
  begin
    if Length(Caption) > 0 then begin
      //PaintRect := Rect(TextPos.X, TextPos.Y, control.Width-TextPos.X, control.Height-TextPos.Y);
      PaintRect := Rect(TextPos.X, TextPos.Y, control.Width, control.Height);
      //if() then begin Dec(paintrect.Right, TextPos.X); //no glyph
      Canvas.Brush.Style := bsClear;
      
      DrawText(Canvas.Handle, PChar(Caption), -1, PaintRect,
        control.DrawTextBiDiModeFlags(0) {or DT_VCENTER} or DT_LEFT or DT_WORDBREAK {or DT_CENTER} or DT_CALCRECT);

      //grayed Caption when disabled
      if not DrawState.bEnabled then begin
        OffsetRect(PaintRect, 1, 1);
        Canvas.Font.Color := clBtnHighlight;
        DrawText(Canvas.Handle, PChar(Caption), -1, PaintRect,
          control.DrawTextBiDiModeFlags(0) {or DT_VCENTER} or DT_LEFT or DT_WORDBREAK {or DT_CENTER} {or DT_CALCRECT});
        OffsetRect(PaintRect, -1, -1);
        Canvas.Font.Color := clBtnShadow;
      end;

      DrawText(Canvas.Handle, PChar(Caption), -1, PaintRect,
        control.DrawTextBiDiModeFlags(0) {or DT_LEFT} {or DT_VCENTER} or DT_WORDBREAK or DT_CENTER);
    end;
  end;

  procedure DrawThemedBorder;
  var
    a: TThemedElementDetailsObject;
    btncontrol: IButtonControl;
  begin
    if(not supports(control, IButtonControl, btncontrol)) then EXIT;
      
    ASSERT(btncontrol<>nil);
    ASSERT(btncontrol.themeddetails<>nil);
      
    if(DrawState.bPressed) then
      a := btncontrol.ThemedDetails.Pressed
    else
    if(not DrawState.bEnabled) then
      a := btncontrol.ThemedDetails.Disabled
    else
    if(DrawState.bHot) then
      a := btncontrol.ThemedDetails.Hot
    else
      a := btncontrol.ThemedDetails.Normal;

    //if(a.Part<>0) then 
    begin
      //Paint the background, border, and finally get the inner rect
      //Details := ThemeServices.GetElementDetails(TThemedButton(a.Element));
      
      //ThemeServices.DrawParentBackground(0, Canvas.Handle, @Details, True);
      DrawThemeParentBackground(0, Canvas.Handle, nil);
      
      //ThemeServices.DrawElement(Canvas.Handle, Details, control.ClientRect);
      DrawThemeBackground(ThemeServices.Theme[a.Element], Canvas.Handle, a.Part, a.state, control.ClientRect, nil);
      
      //ThemeServices.GetElementContentRect(Canvas.Handle, Details, control.ClientRect, R);
      //r := GetThemeBackgroundContentRect(Theme[Element], DC, Part, State, BoundingRect);
    end;
  end;

  procedure DrawUnthemedBorder;
  var
    Flags: Cardinal;
  begin
    //Draw the outer border, when focused
    if DrawState.bDefault then begin
      Canvas.Pen.Color := clWindowFrame;
      Canvas.Pen.Width := 1;
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      InflateRect(R, -1, -1);
    end;
    //Draw the inner border
    if DrawState.bPressed then begin
      Canvas.Pen.Color := clBtnShadow;
      Canvas.Pen.Width := 1;
      Canvas.Brush.Color := clBtnFace;
      Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      InflateRect(R, -1, -1);
    end
    else begin
      Flags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
      if not DrawState.bEnabled then
        Flags := Flags or DFCS_INACTIVE;
      DrawFrameControl(Canvas.Handle, R, DFC_BUTTON, Flags);
    end;
    
    if DrawState.bPressed then
      OffsetRect(R, 1, 1);
  end;
  
begin
  Canvas := TCanvas.Create;
  try
    Canvas.Handle := h;
    Canvas.Font.assign(Font);

//    GetWindowOrgEx(h, LastOrigin);
//    SetWindowOrgEx(h, r.left, r.Right, nil);
//
//    PerformEraseBackground(Self, h);
    //Canvas.Brush.Color := clBlack;
    //Canvas.fillrect(ClientRect);
    
    //Draw the border
    if ThemeServices.Enabled then begin
      DrawThemedBorder;
    end
    else begin
      DrawUnthemedBorder;
    end;

    //Calculate the position of the PNG glyph
    TButtonsLib.CalcButtonLayout(Canvas, PngImage, control.ClientRect, DrawState.bPressed, False, Caption,
      Layout, Margin, Spacing, GlyphPos, TextPos, control.DrawTextBiDiModeFlags(0));

    //Draw the image
    if (PngImage <> nil) and not PngImage.Empty then begin
      PaintRect := Bounds(GlyphPos.X, GlyphPos.Y, PngImage.Width, PngImage.Height);
      TButtonsLib._DrawPNG(PngImage, Canvas, PaintRect, Options, drawstate, PngBlendFactor);
    end;

    //Draw the text
    DrawTheText;
  
  finally
    Canvas.Free;
  end;
end;





{ TButtonDrawState }

procedure TButtonDrawState.Assign(from: TButtonDrawState);
{-----------------------------------------------------------------------------
  Procedure: Assign
  Author:    nbi
  Date:      07-Apr-2014
  Arguments: from: TButtonDrawState
  Result:    None
-----------------------------------------------------------------------------}
begin
  bEnabled := from.bEnabled;
  bPressed := from.bPressed;
  bHot := from.bHot;
  bDefault := from.bDefault;
end;




class operator TButtonDrawState.Equal(a, d: TButtonDrawState): boolean;
begin
  Result := (a.bEnabled<>d.bEnabled) or (a.bPressed<>d.bPressed) or (a.bHot<>d.bHot) or (a.bDefault<>d.bDefault);
  Result := not Result;
end;




class procedure TButtonsLib.CalcButtonLayout(Canvas: TCanvas; PngImage: TPngImage; const Client:
  TRect; Pressed, Down: Boolean; const Caption: string; Layout: TButtonLayout;
  Margin, Spacing: Integer; var GlyphPos, TextPos: TPoint; BiDiFlags: LongInt);
{-----------------------------------------------------------------------------
  Procedure: CalcButtonLayout
  Author:    
  Date:      26-Feb-2014
  Arguments: Canvas: TCanvas; PngImage: TPngImage; const Client: TRect; Pressed, Down: Boolean; const Caption: string; Layout: TButtonLayout; Margin, Spacing: Integer; var GlyphPos, TextPos: TPoint; BiDiFlags: LongInt
  Result:    None
-----------------------------------------------------------------------------}  
var
  ClientSize, GlyphSize, TextSize, BedSize: TPoint;
  TextBounds: TRect;
  //r: TRect;
begin
  if (BiDiFlags and DT_RIGHT) = DT_RIGHT then begin
    if Layout = blGlyphLeft then
      Layout := blGlyphRight
    else if Layout = blGlyphRight then
      Layout := blGlyphLeft;
  end;

  //Calculate the item sizes
  ClientSize := Point(Client.Right - Client.Left, Client.Bottom - Client.Top);

  if PngImage <> nil then
    GlyphSize := Point(PngImage.Width, PngImage.Height)
  else
    GlyphSize := Point(0, 0);

  if Length(Caption) > 0 then begin
    TextBounds := Rect(0, 0, Client.Right - Client.Left, 0);
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), TextBounds,
      DT_CALCRECT or BiDiFlags);
    TextSize := Point(TextBounds.Right - TextBounds.Left, TextBounds.Bottom - TextBounds.Top);
  end
  else begin
    TextBounds := Rect(0, 0, 0, 0);
    TextSize := Point(0, 0);
  end;

  //If the layout has the glyph on the right or the left, then both the
  //text and the glyph are centered vertically.  If the glyph is on the top
  //or the bottom, then both the text and the glyph are centered horizontally.
  if Layout in [blGlyphLeft, blGlyphRight] then
    GlyphPos.Y := (ClientSize.Y - GlyphSize.Y + 1) div 2
  else
    GlyphPos.X := (ClientSize.X - GlyphSize.X + 1) div 2;

  //If there is no text or no bitmap, then Spacing is irrelevant
  if (TextSize.X = 0) or (GlyphSize.X = 0) then begin
    Spacing := 0;
  end;

  // bed = glyph + spacing + text
  if Layout in [blGlyphLeft, blGlyphRight] then
    BedSize := Point(GlyphSize.X + Spacing + TextSize.X,   MAX(GlyphSize.Y, TextSize.Y))
  else
    BedSize := Point(MAX(GlyphSize.X, TextSize.X),  GlyphSize.Y + Spacing + TextSize.Y);

  if(Margin=-1) then begin
    ///centered
    if Layout in [blGlyphLeft, blGlyphRight] then
      Margin := (clientsize.x - bedsize.x) div 2
    else
      Margin := (clientsize.y - bedsize.y) div 2;
  end else begin
//    /// margin=0 is not the client.x=0 . we would want to start placing at some margin which is equal to the margin space from top (for left glyph)
//    /// thus with margin=0 the placement would look nice
//    if Layout in [blGlyphLeft, blGlyphRight] then
//      Margin := Margin + (clientsize.y - BedSize.y) div 2;
  end;

  
  ///position glyph
  case Layout of
    blGlyphLeft: GlyphPos.X := Margin;
    blGlyphRight: GlyphPos.X := ClientSize.X - Margin - GlyphSize.X;
    blGlyphTop: GlyphPos.Y := Margin;
    blGlyphBottom: GlyphPos.Y := ClientSize.Y - Margin - GlyphSize.Y;
  end;


  
  if Layout in [blGlyphLeft, blGlyphRight] then
    TextPos.Y := (ClientSize.Y - TextSize.Y) div 2
  else
    TextPos.X := (ClientSize.X - TextSize.X) div 2;

  ///position text    
  case Layout of
    blGlyphLeft: TextPos.X := GlyphPos.X + GlyphSize.X + Spacing;
    blGlyphRight: TextPos.X := GlyphPos.X - Spacing - TextSize.X;
    blGlyphTop: TextPos.Y := GlyphPos.Y + GlyphSize.Y + Spacing;
    blGlyphBottom: TextPos.Y := GlyphPos.Y - Spacing - TextSize.Y;
  end;

//  l(Caption);
//  lf('ClientSize %d %d',[ClientSize.x, ClientSize.y]);
//  lf('GlyphSize %d %d',[GlyphSize.x, GlyphSize.y]);  
//  lf('TextSize %d %d',[TextSize.x, TextSize.y]);  
//  lf('GlyphPos %d %d',[GlyphPos.x, GlyphPos.y]);
//  lf('TextPos %d %d',[TextPos.x, TextPos.y]);  
//  l;
//
//  r := rect(0,0, TextSize.x, TextSize.y);
//  offsetrect(r, textpos.x, textpos.y);
//  Canvas.FillRect(r);
//  Canvas.Pen.Color := clred;
//  Canvas.Ellipse(textpos.x, textpos.y, textpos.x+1, textpos.y+1);
  
  ///n@2014-04-15 commented out, the default vcl button does not have such offset
  //n@2014-07-10 uncommented, it does not look good when it does not sink
  //Fixup the result variables
  with GlyphPos do begin
    Inc(X, Integer(Pressed or Down));
    Inc(Y, Integer(Pressed or Down));
  end;
  with TextPos do begin
    Inc(X, Integer(Pressed or Down));
    Inc(Y, Integer(Pressed or Down));
  end;
end;


{ TThemedButtonDetails }

procedure TThemedButtonDetails.Assign(Source: TPersistent);
begin
  inherited;
end;

constructor TThemedButtonDetails.Create;//(AOwner: TControl);
{-----------------------------------------------------------------------------
  Procedure: Create
  Author:    nbi
  Date:      08-Apr-2014
  Arguments: AOwner: TControl
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_bChanging := False;
  
  m_disabled := TThemedElementDetailsObject.Create(self);
  m_hot := TThemedElementDetailsObject.Create(self);
  m_normal := TThemedElementDetailsObject.Create(self);
  m_pressed := TThemedElementDetailsObject.Create(self);

//  m_pressed.SetSubComponent(True);
//  m_hot.SetSubComponent(True);
//  m_normal.SetSubComponent(True);
//  m_disabled.SetSubComponent(True);

  _Kind := tpButton;
  
  inherited Create;//(TComponent(aowner));
end;



destructor TThemedButtonDetails.Destroy;
{-----------------------------------------------------------------------------
  Procedure: Destroy
  Author:    nbi
  Date:      08-Apr-2014
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_pressed.Free;
  m_normal.Free;
  m_hot.Free;
  m_disabled.Free;
  inherited;
end;



function TThemedButtonDetails.GetDisabled: TThemedElementDetailsObject;
begin
  Result := m_disabled;
end;

function TThemedButtonDetails.GetHot: TThemedElementDetailsObject;
begin
  Result := m_hot;
end;

function TThemedButtonDetails.GetNormal: TThemedElementDetailsObject;
begin
  Result := m_normal;
end;

function TThemedButtonDetails.GetPressed: TThemedElementDetailsObject;
begin
  Result := m_pressed;
end;



function TThemedButtonDetails.GetThemingPreset: TThemingPreset;
{-----------------------------------------------------------------------------
  Procedure: GetThemingPreset
  Author:    nbi
  Date:      15-May-2014
  Arguments: None
  Result:    TThemingPreset
-----------------------------------------------------------------------------}
begin
  Result := m_themingpreset;
end;




function TThemedButtonDetails.IsStored: Boolean;
begin
  Result := m_themingpreset=tpCustom;
end;




procedure TThemedButtonDetails.ThemingDetailsChanged(Sender: TObject);
{-----------------------------------------------------------------------------
  Procedure: OnThemingDetailsChanged
  Author:    nbi
  Date:      08-Apr-2014
  Arguments: Sender: TObject
  Result:    None
-----------------------------------------------------------------------------}
begin
  //if(Owner<>nil) then
    //(Owner as IButtonControl).GetControl.Invalidate;
  if(Assigned(FOnChange)) then
    FOnChange(Self);
end;



procedure TThemedButtonDetails.SetDisabled(const Value: TThemedElementDetailsObject);
begin
  m_disabled.assign(value);
end;

procedure TThemedButtonDetails.SetHot(const Value: TThemedElementDetailsObject);
begin
  m_hot.assign(value);
end;

procedure TThemedButtonDetails.SetNormal(const Value: TThemedElementDetailsObject);
begin
  m_normal.assign(value);
end;

procedure TThemedButtonDetails.SetPressed(const Value: TThemedElementDetailsObject);
begin
  m_pressed.assign(value);
end;



procedure TThemedButtonDetails.SetThemingPreset(const Value: TThemingPreset);
{-----------------------------------------------------------------------------
  Procedure: SetThemingPreset
  Author:    nbi
  Date:      08-Apr-2014
  Arguments: const Value: TThemingPreset
  Result:    None
-----------------------------------------------------------------------------}
begin
  if(m_bChanging) then EXIT;//avoid reentrancy
  m_bChanging := True;
  
  case Value of
    tpCustom: ;
    tpButton: begin 
      m_pressed.m_Element := teButton;
      m_pressed.m_Part := BP_PUSHBUTTON;
      m_pressed.m_state := PBS_PRESSED;

      m_hot.m_Element := teButton;
      m_hot.m_Part := BP_PUSHBUTTON;
      m_hot.m_state := PBS_HOT;

      m_disabled.m_Element := teButton;
      m_disabled.m_Part := BP_PUSHBUTTON;
      m_disabled.m_state := PBS_DISABLED;

      m_normal.m_Element := teButton;
      m_normal.m_Part := BP_PUSHBUTTON;
      m_normal.m_state := PBS_NORMAL;
    end;
    tpFlatButton: begin 
      m_pressed.m_Element := teButton;
      m_pressed.m_Part := BP_PUSHBUTTON;
      m_pressed.m_state := PBS_PRESSED;

      m_hot.m_Element := teButton;
      m_hot.m_Part := BP_PUSHBUTTON;
      m_hot.m_state := PBS_HOT;

      m_disabled.m_Element := teButton;
      m_disabled.m_Part := BP_PUSHBUTTON;
      m_disabled.m_state := PBS_DISABLED;

      m_normal.m_Element := teToolbar;
      m_normal.m_Part := TP_BUTTON;
      m_normal.m_state := TS_NORMAL;
    end;
    tpToolButton: begin 
      m_pressed.m_Element := teToolbar;
      m_pressed.m_Part := TP_BUTTON;
      m_pressed.m_state := TS_PRESSED;

      m_hot.m_Element := teToolbar;
      m_hot.m_Part := TP_BUTTON;
      m_hot.m_state := TS_HOT;

      m_disabled.m_Element := teToolbar;
      m_disabled.m_Part := TP_BUTTON;
      m_disabled.m_state := TS_DISABLED;

      m_normal.m_Element := teToolbar;
      m_normal.m_Part := TP_BUTTON;
      m_normal.m_state := TS_NORMAL;
    end;
  end;

  m_themingpreset := value;

  ThemingDetailsChanged(self);
  
  m_bChanging := False;
end;

{ TThemedElementDetailsObject }

procedure TThemedElementDetailsObject.Assign(Source: TPersistent);
{-----------------------------------------------------------------------------
  Procedure: Assign
  Author:    nbi
  Date:      08-Apr-2014
  Arguments: Source: TPersistent
  Result:    None
-----------------------------------------------------------------------------}
begin
  ASSERT(Source is TThemedElementDetailsObject);
  m_Element := TThemedElementDetailsObject(Source).element;
  m_Part := TThemedElementDetailsObject(Source).Part;
  m_State := TThemedElementDetailsObject(Source).State;
end;



procedure TThemedElementDetailsObject.Changed;
{-----------------------------------------------------------------------------
  Procedure: Changed
  Author:    nbi
  Date:      08-Apr-2014
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_owner.ThemingDetailsChanged(Self);
  m_owner._Kind := tpCustom;
end;



constructor TThemedElementDetailsObject.Create(AOwner: TThemedButtonDetails);
{-----------------------------------------------------------------------------
  Procedure: Create
  Author:    nbi
  Date:      08-Apr-2014
  Arguments: AOwner: TControl
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_owner := aowner;
  inherited Create;//(TComponent(aowner));
end;

function TThemedElementDetailsObject.GetElement: TThemedElement;
begin
  Result := m_Element;
end;

function TThemedElementDetailsObject.GetPart: Integer;
begin
  Result := m_Part;
end;

function TThemedElementDetailsObject.GetState: Integer;
begin
  Result := m_State;
end;

procedure TThemedElementDetailsObject.SetElement(AElement: TThemedElement);
begin
  m_Element := AElement;
  Changed;
end;

procedure TThemedElementDetailsObject.SetPart(const Value: Integer);
begin
  m_Part := value;
  Changed;
end;

procedure TThemedElementDetailsObject.SetState(const Value: Integer);
begin
  m_State := value;
  Changed;
end;


procedure Register;
begin
end;

{ TButtonOverlay }

procedure TButtonOverlay.Changed;
begin
  if(Assigned(FOnChange)) then try
    FOnChange(Self);
  except
    beep;
  end;
end;

constructor TButtonOverlay.Create;
begin
  inherited;
  m_images := nil;
  m_nImageIndex := -1;
  m_left := 0;
  m_top := 0;
end;

function TButtonOverlay.GetImageIndex: Integer;
begin
  Result := m_nImageIndex;
end;

function TButtonOverlay.GetImages: TPngImageList;
begin
  Result := m_images;
end;

function TButtonOverlay.GetLeft: Integer;
begin
  Result := m_left;
end;

function TButtonOverlay.GetTop: Integer;
begin
  Result := m_top;
end;

procedure TButtonOverlay.SetImageIndex(const Value: Integer);
begin
  m_nImageIndex := value;
  Changed;
end;

procedure TButtonOverlay.SetImages(const Value: TPngImageList);
begin
  m_images := value;
  Changed;
end;

procedure TButtonOverlay.SetLeft(const Value: Integer);
begin
  m_left := value;
  Changed;
end;

procedure TButtonOverlay.SetTop(const Value: Integer);
begin
  m_top := value;
  Changed;
end;



class procedure TPngLib.PngDrawOver(base, overlay: TPngImage; Left, top: Integer);
{-----------------------------------------------------------------------------
  Procedure: PngDrawOver
  Author:    nbi
  Date:      24-Jul-2014
  Arguments: base, overlay: TPngImage; Left, top: Integer
  Result:    None
-----------------------------------------------------------------------------}
var
  w, h: Integer;
  line: PRGBLine;
  y: Integer;
  x: Integer;
  alphaline: pngimage.pByteArray;
  line2: PRGBLine;
  alphaline2: pngimage.pByteArray;
  c: TRGBTriple;

  function BlendColor(p1, p2: PRGBLine; alpha,alpha2: Byte): TRGBTriple;
  var
    a,ac: single;
  begin
    a := alpha/255;
    ac := 1 - a;
    
    Result.rgbtRed := Byte(trunc((p1[0].rgbtRed * a) + (p2[0].rgbtRed * ac)));
    Result.rgbtGreen := Byte(trunc((p1[0].rgbtGreen * a) + (p2[0].rgbtGreen * ac)));
    Result.rgbtBlue := Byte(trunc((p1[0].rgbtBlue * a) + (p2[0].rgbtBlue * ac)));
  end;
  
begin
  ASSERT(base<>nil);
  ASSERT(base.Header.colortype=COLOR_RGBALPHA);  
  ASSERT(overlay<>nil);
  ASSERT(overlay.Header.colortype=COLOR_RGBALPHA);
  
  c.rgbtRed := 255;
  c.rgbtGreen := 255;  
  c.rgbtBlue := 255;  
  
  w := overlay.Width;
  h := overlay.Height;
  
  if(w+top)>base.Width then
    w := w - (base.Width - left); //trim whats outside
    
  if(h+left)>base.Height then
    h := h - (base.Height - top); //trim whats outside

  for y := 0 to h-1 do begin    
    pbyte(line) := pbyte(base.Scanline[y+top]) + Left*SizeOf(TRGBTriple);
    alphaline := base.AlphaScanline[y+top];
    
    line2 := overlay.Scanline[y];
    alphaline2 := overlay.AlphaScanline[y];
    
    for x := 0 to w-1 do begin
      line^[0] := BlendColor(line, line2, 255- alphaline2^[0], alphaline^[Left]);
      alphaline^[left] := max(alphaline^[left], alphaline2^[0]);
      
      pbyte(line) := pbyte(line) + SizeOf(TRGBTriple);
      pbyte(line2) := pbyte(line2) + SizeOf(TRGBTriple);      
      pbyte(alphaline2) := pbyte(alphaline2) + 1;
      pbyte(alphaline) := pbyte(alphaline) + 1;
    end;
  end;
end;



end.
