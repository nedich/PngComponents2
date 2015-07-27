unit u_componentPngBitBtn2;

                                      INTERFACE
                                      

uses
  u_PngComponentCommons, pngimage, Messages, Controls, Windows, Classes, SysUtils, Graphics,
  Buttons, PngImageList;

type
  TPngBitBtn2 = class(TBitBtn, IButtonControl)
  private
    m_PngImage: TPngImage;
    m_PngOptions: TPngOptions2;
    m_bMouseInControl: Boolean;
    m_bPressed: Boolean;
    m_nPngBlendFactor: Integer;
    m_themingdeatails: TThemedButtonDetails;
    m_canvas: TCanvas;
    m_bImageFromAction: Boolean;
    m_imagelist: TPngImageList;
    m_nImageIndex: Integer;
    m_overlay: TButtonOverlay;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure SetPngBlendFactor(const Value: Integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetPngOptions(const Value: TPngOptions2);
    function GetDrawState: TButtonDrawState;
    procedure SetPngImage(const Value: TPngImage);
    function IsPngImageStored: Boolean;
    procedure SetImageIndex(const Value: Integer);
    procedure SetImageList(const Value: TPngImageList);
    procedure _setImageFromImageList;
    procedure RecomposeImage(Sender: TObject = nil);
  protected
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
  public
    function GetText: string;
    function GetThemedDetails: IThemedButtonDetails;
    function GetLayout: TButtonLayout;
    function GetPngOptions: TPngOptions2;
    function GetMargin: Integer;
    function GetSpacing: Integer;
    function GetPngBlendFactor: Integer;
    function GetControl: TControl;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetPngImage: TPngImage;
    function GetCanvas: TCanvas;
    function GetFont: TFont;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Images: TPngImageList read m_imagelist write SetImageList;
    property ImageIndex: Integer read m_nImageIndex write SetImageIndex;
    property PngImage: TPngImage read m_PngImage write SetPngImage stored IsPngImageStored;
    property PngOptions: TPngOptions2 read m_PngOptions write SetPngOptions default [pngGrayscaleOnDisabled,pngBlendNotHovering];
    property PngBlendFactor: Integer read m_nPngBlendFactor write SetPngBlendFactor default 255;
    property ThemingDetails: TThemedButtonDetails read m_themingdeatails;
    property Overlay: TButtonOverlay read m_overlay write m_overlay;
  end;

procedure Register;
  
  
                                 IMPLEMENTATION

                                 

uses
  ActnList, Themes, PngFunctions;


  
{ TPngBitBtn2 }


procedure TPngBitBtn2.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  
  m_bImageFromAction := (Sender<>nil);
  
  if Sender is TCustomAction then begin
    with TCustomAction(Sender) do begin
      //Copy image from action's imagelist
      if (PngImage.Empty or m_bImageFromAction) and (ActionList <> nil) and
        (ActionList.Images <> nil) and (ImageIndex >= 0) and (ImageIndex <
        ActionList.Images.Count) then begin
        CopyImageFromImageList(m_PngImage, ActionList.Images, ImageIndex);
        m_bImageFromAction := True;
      end;
    end;
  end;
end;




///From PngBitBtn:
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

function StyleServices: TThemeServices;
begin
  result := ThemeServices;
end;
{$IFEND}




procedure TPngBitBtn2.CNDrawItem(var Message: TWMDrawItem);
{-----------------------------------------------------------------------------
  Procedure: CNDrawItem
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: var Message: TWMDrawItem
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_canvas.Handle := Message.DrawItemStruct.hDC;
  m_bPressed := (Message.DrawItemStruct.itemState and ODS_SELECTED) <> 0;
  try
    TButtonsLib.RenderButton(Self);
  finally
    m_canvas.Handle := 0;
  end;
end;



constructor TPngBitBtn2.Create(AOwner: TComponent);
{-----------------------------------------------------------------------------
  Procedure: Create
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: AOwner: TComponent
  Result:    None
-----------------------------------------------------------------------------}
begin
  inherited;
  m_canvas := TCanvas.Create;
  m_PngImage := TPngImage.Create;
  m_nPngBlendFactor := 127;
  m_bImageFromAction := False;
  m_themingdeatails := TThemedButtonDetails.Create;//(self);
  //m_themingdeatails.SetSubComponent(True);
  m_themingdeatails._Kind := tpButton;
  m_themingdeatails.OnChange := RecomposeImage;
  m_nImageIndex := -1;
  m_imagelist := nil;
  m_overlay := TButtonOverlay.Create;
  m_overlay.OnChange := RecomposeImage;
end;



destructor TPngBitBtn2.Destroy;
{-----------------------------------------------------------------------------
  Procedure: Destroy
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
begin
  //FCanvas := TCanvas.Create;
  inherited;
end;



procedure TPngBitBtn2.RecomposeImage(Sender: TObject);
{-----------------------------------------------------------------------------
  Procedure: OverlayChanged
  Author:    nbi
  Date:      14-May-2014
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
begin
  _setImageFromImageList;
  Repaint;
end;




function TPngBitBtn2.GetCanvas: TCanvas;
begin
  Result := m_canvas;
end;

function TPngBitBtn2.GetControl: TControl;
begin
  Result := Self;
end;



function TPngBitBtn2.GetDrawState: TButtonDrawState;
{-----------------------------------------------------------------------------
  Procedure: GetDrawState
  Author:    nbi
  Date:      26-Feb-2014
  Arguments: None
  Result:    TButtonDrawState
-----------------------------------------------------------------------------}
begin
  result.bEnabled := Enabled;
  result.bPressed := m_bPressed;
  result.bHot := m_bMouseInControl;
  result.bDefault := Default;
end;




function TPngBitBtn2.GetFont: TFont;
begin
  Result := Font;
end;

function TPngBitBtn2.GetHeight: Integer;
begin
  Result := Height;
end;

function TPngBitBtn2.GetLayout: TButtonLayout;
begin
  Result := Layout;
end;

function TPngBitBtn2.GetMargin: Integer;
begin
  Result := Margin;
end;

function TPngBitBtn2.GetPngBlendFactor: Integer;
begin
  Result := m_nPngBlendFactor;
end;

function TPngBitBtn2.GetPngImage: TPngImage;
begin
  Result := m_PngImage;
end;

function TPngBitBtn2.GetPngOptions: TPngOptions2;
begin
  Result := m_PngOptions;
end;

function TPngBitBtn2.GetSpacing: Integer;
begin
  Result := Spacing;
end;

function TPngBitBtn2.GetText: string;
begin
  Result := Caption;
end;

function TPngBitBtn2.GetThemedDetails: IThemedButtonDetails;
begin
  Result := m_themingdeatails;
end;

function TPngBitBtn2.GetWidth: Integer;
begin
  Result := Width;
end;

function TPngBitBtn2.IsPngImageStored: Boolean;
begin
  Result := not m_bImageFromAction and ((m_nImageIndex=-1) or (m_imagelist=nil));
end;



procedure TPngBitBtn2._setImageFromImageList;
{-----------------------------------------------------------------------------
  Procedure: SetImageFromImageList
  Author:    nbi
  Date:      05-May-2014
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
begin
  if(m_imagelist=nil) or (m_nImageIndex<0) then
    EXIT;

  if(m_nImageIndex >= m_imagelist.Count) then
    EXIT;

  m_PngImage.Assign(m_imagelist.PngImages.Items[m_nImageIndex].PngImage);
end;



procedure TPngBitBtn2.SetImageIndex(const Value: Integer);
{-----------------------------------------------------------------------------
  Procedure: SetImageIndex
  Author:    nbi
  Date:      05-May-2014
  Arguments: const Value: Integer
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_nImageIndex := value;
  RecomposeImage;
end;



procedure TPngBitBtn2.SetImageList(const Value: TPngImageList);
{-----------------------------------------------------------------------------
  Procedure: SetImageList
  Author:    nbi
  Date:      05-May-201
  Arguments: const Value: TImageList
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_imagelist := value;
  RecomposeImage;
end;



procedure TPngBitBtn2.SetPngBlendFactor(const Value: Integer);
{-----------------------------------------------------------------------------
  Procedure: SetPngBlendFactor
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: const Value: Integer
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_nPngBlendFactor := Value;
  Repaint;
end;




procedure TPngBitBtn2.SetPngImage(const Value: TPngImage);
{-----------------------------------------------------------------------------
  Procedure: SetPngImage
  Author:    nbi
  Date:      05-May-2014
  Arguments: const Value: TPngImage
  Result:    None
-----------------------------------------------------------------------------}
var
  png: TPngImage;
begin
  png := m_PngImage;
  
  if Value = nil then begin
    png.Free;
    png := TPngImage.Create;
  end
  else begin
    png.Assign(Value);
  end;

  //To work around the gamma-problem
  if not png.Empty and (png.Header.ColorType in [COLOR_RGB, COLOR_RGBALPHA, COLOR_PALETTE]) then
      png.Chunks.RemoveChunk(png.Chunks.ItemFromClass(TChunkgAMA));

  m_bImageFromAction := False;

  RecomposeImage;
end;




procedure TPngBitBtn2.SetPngOptions(const Value: TPngOptions2);
{-----------------------------------------------------------------------------
  Procedure: SetPngOptions
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: const Value: TPngOptions2
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_PngOptions := Value;
  RecomposeImage;
end;




procedure TPngBitBtn2.CMMouseEnter(var Message: TMessage);
{-----------------------------------------------------------------------------
  Procedure: CMMouseEnter
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: var Message: TMessage
  Result:    None
-----------------------------------------------------------------------------}
begin
  inherited;
  if StyleServices.Enabled and not m_bMouseInControl and not (csDesigning in ComponentState) then begin
    m_bMouseInControl := True;
    Repaint;
  end;
end;



procedure TPngBitBtn2.CMMouseLeave(var Message: TMessage);
{-----------------------------------------------------------------------------
  Procedure: CMMouseLeave
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: var Message: TMessage
  Result:    None
-----------------------------------------------------------------------------}
begin
  inherited;
  if StyleServices.Enabled and m_bMouseInControl then begin
    m_bMouseInControl := False;
    Repaint;
  end;
end;



procedure Register;
{-----------------------------------------------------------------------------
  Procedure: Register
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
begin
  RegisterComponents(SDelphiComponentsPageName, [TPngBitBtn2]);
end;



end.
