unit u_componentPngSpeedButton2;

                                 INTERFACE

{
Author Nedko Ivanov
Based on PngComponents by Uwe Raabe http://cc.embarcadero.com/item/26127
Date 2015-07-27
URL https://github.com/nedich/PngComponents2
License MIT
}
                                 
uses
  pngimage, Buttons, Messages, Controls, Windows, Classes, SysUtils, Graphics, u_PngComponentCommons,
  {$ifdef nbi}u_intfBufferedPaint, {$endif}
  PngImageList;

type
  TPngSpeedButton2 = class(TSpeedButton, IButtonControl)
  private
    m_PngImage: TPngImage;
    m_PngOptions: TPngOptions2;
    m_bImageFromAction: Boolean;
    m_bMouseInControl: Boolean;
    {$ifdef nbi}m_bufferedpaint: IBufferedPaint;{$endif}
    m_lastdrawstate: TButtonDrawState;
    m_drawstate: TButtonDrawState;
    m_themingdeatails: TThemedButtonDetails;
    m_nPngBlendFactor: Integer;
    m_imagelist: TPngImageList;
    m_nImageIndex: Integer;
    m_overlay: TButtonOverlay;
    procedure SetPngBlendFactor(const Value: Integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetPngOptions(const Value: TPngOptions2);
    procedure SetPngImage(const Value: TPngImage);
    function PngImageStored: Boolean;
    procedure CreatePngGlyph;
    {$ifdef nbi}procedure OnProvideStartEndFrame(bp: IBufferedPaint; hFrom, hTo: HDC);{$endif}
    procedure _setImageFromImageList;
    procedure SetImageIndex(const Value: Integer);
    procedure SetImageList(const Value: TPngImageList);
    procedure RecomposeImage(Sender: TObject = nil);
  protected
    procedure Paint; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    procedure Loaded; override;
    property Glyph stored False;
    property NumGlyphs stored False;
  public
    {$ifdef nbi}function GetBufferedPaint: IBufferedPaint;{$endif}
    function GetThemedDetails: IThemedButtonDetails;
    function GetDrawState: TButtonDrawState;
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
    function GetText: string;
    function GetFont: TFont;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Images: TPngImageList read m_imagelist write SetImageList;
    property ImageIndex: Integer read m_nImageIndex write SetImageIndex default -1;
    property PngImage: TPngImage read m_PngImage write SetPngImage stored PngImageStored;
    property PngOptions: TPngOptions2 read m_PngOptions write SetPngOptions default [pngGrayscaleOnDisabled,pngBlendNotHovering];
    property PngBlendFactor: Integer read m_nPngBlendFactor write SetPngBlendFactor default 127;
    property ThemingDetails: TThemedButtonDetails read m_themingdeatails write m_themingdeatails;
    property Overlay: TButtonOverlay read m_overlay write m_overlay;
    property Transparent default False;
  end;

procedure Register;
  
  
                                 IMPLEMENTATION

                                 

uses
  ActnList, Themes, PngFunctions, Dialogs, Clipbrd;

{ TPngSpeedButton2 }



procedure TPngSpeedButton2.ActionChange(Sender: TObject; CheckDefaults: Boolean);
{-----------------------------------------------------------------------------
  Procedure: ActionChange
  Author:    nbi
  Date:      20-Feb-2014
  Arguments: Sender: TObject; CheckDefaults: Boolean
  Result:    None
-----------------------------------------------------------------------------}
begin
  inherited ActionChange(Sender, CheckDefaults);
  
  m_bImageFromAction := (Sender<>nil);
  
  if Sender is TCustomAction then begin
    with TCustomAction(Sender) do begin
      //Copy image from action's imagelist
      if (PngImage.Empty or m_bImageFromAction) and (ActionList <> nil) and
        (ActionList.Images <> nil) and (ImageIndex >= 0) and 
        (ImageIndex < ActionList.Images.Count) then 
      begin
        CopyImageFromImageList(m_PngImage, ActionList.Images, ImageIndex);
        m_bImageFromAction := True;
      end;
    end;
  end;
end;




procedure TPngSpeedButton2.Paint;
{-----------------------------------------------------------------------------
  Procedure: CNDrawItem
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: var Message: TWMDrawItem
  Result:    None
-----------------------------------------------------------------------------}
var
  bPressed: Boolean;
begin
  bPressed := Down or (FState=bsDown);

  m_drawstate.bEnabled := Enabled;
  m_drawstate.bPressed := bPressed;
  m_drawstate.bHot := m_bMouseInControl;
  m_drawstate.bDefault := false;

  //if(m_drawstate=m_drawstate) then EXIT;

//  if not (m_lastdrawstate=m_drawstate) then
//    GetBufferedPaint.StartAnimation(Canvas)
//  else begin
//    //SetViewportOrgEx(canvas.handle, Left,top, @p);
//    b := GetBufferedPaint.IsRunning;
//    //SetViewportOrgEx(canvas.handle, p.x,p.y, nil);
//    if(not b) then
  try
      TButtonsLib.RenderButton(self);
  except
    on e:Exception do begin
      //raise;
    end;
  end;

//  end;

  m_lastdrawstate.assign(m_drawstate);
end;




function TPngSpeedButton2.PngImageStored: Boolean;
{-----------------------------------------------------------------------------
  Procedure: PngImageStored
  Author:    nbi
  Date:      20-Feb-2014
  Arguments: None
  Result:    Boolean
-----------------------------------------------------------------------------}
begin
  Result := not m_bImageFromAction and ((m_nImageIndex=-1) or (m_imagelist=nil));
end;




procedure TPngSpeedButton2.SetPngImage(const Value: TPngImage);
{-----------------------------------------------------------------------------
  Procedure: SetPngImage
  Author:    nbi
  Date:      20-Feb-2014
  Arguments: const Value: TPngImage
  Result:    None
-----------------------------------------------------------------------------}
begin
  //This is all neccesary, because you can't assign a nil to a TPngImage
  if Value = nil then begin
    m_PngImage.Free;
    m_PngImage := TPngImage.Create;
  end
  else
    m_PngImage.Assign(Value);

  //To work around the gamma-problem
  try
    with m_PngImage do
      if Header.ColorType in [COLOR_RGB, COLOR_RGBALPHA, COLOR_PALETTE] then
        Chunks.RemoveChunk(Chunks.ItemFromClass(TChunkgAMA));
  except
  end;

  m_bImageFromAction := False;
  CreatePngGlyph;
  Repaint;
end;


constructor TPngSpeedButton2.Create(AOwner: TComponent);
{-----------------------------------------------------------------------------
  Procedure: Create
  Author:    nbi
  Date:      16-Sep-2013
  Arguments: AOwner: TComponent
  Result:    None
-----------------------------------------------------------------------------}
begin
  inherited;
  
  m_PngImage := TPngImage.Create;
  m_nPngBlendFactor := 127;
  m_bImageFromAction := False;

  m_themingdeatails := TThemedButtonDetails.Create;//(self);
  //m_themingdeatails.SetSubComponent(True);
  m_themingdeatails._Kind := tpButton;
  m_themingdeatails.OnChange := RecomposeImage;

  m_PngOptions := [u_PngComponentCommons.pngGrayscaleOnDisabled,u_PngComponentCommons.pngBlendNotHovering];
  
  m_nImageIndex := -1;
  m_imagelist := nil;

  m_overlay := TButtonOverlay.Create;
  m_overlay.OnChange := RecomposeImage;
end;



destructor TPngSpeedButton2.Destroy;
{-----------------------------------------------------------------------------
  Procedure: Destroy
  Author:    nbi
  Date:      16-Sep-2013
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
begin
  //Canvas := TCanvas.Create;
  m_themingdeatails.Free;
  inherited;
end;


{$ifdef nbi}
procedure TPngSpeedButton2.OnProvideStartEndFrame(bp: IBufferedPaint; hFrom, hTo: HDC);
{-----------------------------------------------------------------------------
  Procedure: OnProvideStartEndFrame
  Author:    nbi
  Date:      20-Feb-2014
  Arguments: hFrom, hTo: HDC
  Result:    None
-----------------------------------------------------------------------------}
//var
//  p: TPoint;
begin
  if(hTo<>0) then begin
    //SetViewportOrgEx(hTo, Left,top, @p);

    //Canvas.Brush.Color := clBlack;
    //fillrect(hto, bp.GetRect, Canvas.Brush.Handle);
    
    TButtonsLib.RenderButton(bp.GetRect, pngimage, m_drawstate, hTo, Caption, Self, Layout, Margin, spacing, PngBlendFactor, PngOptions, font);
    //SetViewportOrgEx(hTo, p.x,p.y, nil);
  end;
  
  if(hFrom<>0) then begin
    //SetViewportOrgEx(hFrom, left,top, @p);
    
    //Canvas.Brush.Color := clBlack;
    //fillrect(hFrom, bp.GetRect, Canvas.Brush.Handle);
    
    TButtonsLib.RenderButton(bp.GetRect, pngimage, m_lastdrawstate, hFrom, Caption, Self, Layout, Margin, spacing, PngBlendFactor, PngOptions, font);
    //SetViewportOrgEx(hFrom, p.x,p.y, nil);
  end;
end;



function TPngSpeedButton2.GetBufferedPaint: IBufferedPaint;
{-----------------------------------------------------------------------------
  Procedure: GetBufferedPaint
  Author:    nbi
  Date:      20-Feb-2014
  Arguments: None
  Result:    IBufferedPaint
-----------------------------------------------------------------------------}
begin
  if(m_bufferedpaint=nil) then 
    m_bufferedpaint := NewBufferedPaint_GraphicControl(self, 100, OnProvideStartEndFrame);
  Result := m_bufferedpaint;
end;
{$endif}


function TPngSpeedButton2.GetCanvas: TCanvas;
begin
  Result := Canvas;
end;

//function TPngSpeedButton2.GetCaption: string;
//begin
//  Result := Caption;
//end;

function TPngSpeedButton2.GetControl: TControl;
begin
  Result := Self;
end;

function TPngSpeedButton2.GetDrawState: TButtonDrawState;
begin
  Result := m_drawstate;
end;

function TPngSpeedButton2.GetFont: TFont;
begin
  Result := Font;
end;

function TPngSpeedButton2.GetHeight: Integer;
begin
  Result := Height;
end;

function TPngSpeedButton2.GetLayout: TButtonLayout;
begin
  Result := Layout;
end;

function TPngSpeedButton2.GetMargin: Integer;
begin
  Result := Margin;
end;

function TPngSpeedButton2.GetPngBlendFactor: Integer;
begin
  Result := PngBlendFactor;
end;

function TPngSpeedButton2.GetPngImage: TPngImage;
begin
  Result := PngImage;
end;

function TPngSpeedButton2.GetPngOptions: TPngOptions2;
begin
  Result := PngOptions;
end;

function TPngSpeedButton2.GetSpacing: Integer;
begin
  Result := Spacing;
end;

function TPngSpeedButton2.GetText: string;
begin
  Result := Caption;
end;

function TPngSpeedButton2.GetThemedDetails: IThemedButtonDetails;
begin
  Result := m_themingdeatails;
end;

function TPngSpeedButton2.GetWidth: Integer;
begin
  Result := Width;
end;

procedure TPngSpeedButton2.Loaded;
begin
  inherited;
end;



procedure TPngSpeedButton2.SetPngBlendFactor(const Value: Integer);
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




procedure TPngSpeedButton2.SetPngOptions(const Value: TPngOptions2);
{-----------------------------------------------------------------------------
  Procedure: SetPngOptions
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: const Value: TPngOptions2
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_PngOptions := Value;
  repaint;
end;




procedure TPngSpeedButton2._setImageFromImageList;
{-----------------------------------------------------------------------------
  Procedure: SetImageFromImageList
  Author:    nbi
  Date:      05-May-2014
  Arguments: None
  Result:    None
-----------------------------------------------------------------------------}
var
//  _canvas: TCanvas;
  _overlayimage: TPngImage;
//  _bmp: TBitmap;
//  r: TRect;
//  t: TTransparentCanvas;
begin
  if(m_imagelist=nil) or (m_nImageIndex<0) then
    EXIT;

  if(m_nImageIndex >= m_imagelist.Count) then
    EXIT;

  m_PngImage.Assign(m_imagelist.PngImages.Items[m_nImageIndex].PngImage);

  //if(False) then
  if(m_overlay<>nil) and (m_overlay.Images<>nil) and (m_overlay.ImageIndex>=0) and (m_overlay.ImageIndex<m_overlay.Images.count) then begin
//    _bmp := TBitmap.Create;
    //b2 := TAlphaBitmapWrapper.CreateForGDI(_bmp.Canvas.Handle, );
    try
//      t := TTransparentCanvas.Create(m_PngImage.Width, m_PngImage.Height);

//      _bmp.PixelFormat := pf32bit;
//      _bmp.Width := m_PngImage.Width;
//      _bmp.Height := m_PngImage.Height;
      //_bmp.Handle := t.FWorkingCanvas.bitmaphandle;
      //_bmp.
      //_canvas := _bmp.Canvas;
      //_canvas.Handle := t.Handle;

      //m_PngImage.SaveToFile('c:\temp\aaa.png');
      ///===FACT: m_PngImage has got alpha here!
      //m_PngImage.Draw(_bmp.Canvas, rect(0,0, m_PngImage.Width-1, m_PngImage.Height-1));

      //_bmp.SaveToFile('c:\temp\aaa.bmp'); ///===FACT: after png.draw(bmp) -> bmp does NOT have alpha!

//      t.Draw(0,0, m_PngImage.Canvas, m_PngImage.Width, m_PngImage.Height);
//      t.DrawToGlass(0,0, _canvas.handle);
//
//      m_PngImage.assign(_bmp);


      _overlayimage := m_overlay.Images.PngImages.Items[m_overlay.ImageIndex].PngImage;

      TPngLib.PngDrawOver(m_PngImage, _overlayimage, m_overlay.Left, m_overlay.top);
      //m_PngImage.SaveToFile('c:\temp\aaa.png');
      
      ///===FACT: _overlayimage has got alpha here!
      //_overlayimage.SaveToFile('c:\temp\aaa2.png');
//      r := rect(0,0, _overlayimage.Width, _overlayimage.Height);
//      OffsetRect(r, m_overlay.Left, m_overlay.Top);
//      _overlayimage.Draw(_canvas, r);

      //m_PngImage.assign(_bmp);
    finally
//      _bmp.Free;
    end;
  end;
end;



procedure TPngSpeedButton2.SetImageIndex(const Value: Integer);
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



//procedure TPngSpeedButton2.SetImageIndexOfOverlay(const Value: Integer);
//{-----------------------------------------------------------------------------
//  Procedure: SetImageIndexOfOverlay
//  Author:    nbi
//  Date:      14-May-2014
//  Arguments: const Value: Integer
//  Result:    None
//-----------------------------------------------------------------------------}
//begin
//  m_nImageIndexOfOverlay := value;
//  _setImageFromImageList;
//  Repaint;
//end;




procedure TPngSpeedButton2.SetImageList(const Value: TPngImageList);
{-----------------------------------------------------------------------------
  Procedure: SetImageList
  Author:    nbi
  Date:      05-May-2014
  Arguments: const Value: TImageList
  Result:    None
-----------------------------------------------------------------------------}
begin
  m_imagelist := value;
  RecomposeImage;
end;




procedure TPngSpeedButton2.RecomposeImage(Sender: TObject);
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


//procedure TPngSpeedButton2.SetImageListOverlay(const Value: TPngImageList);
//{-----------------------------------------------------------------------------
//  Procedure: SetImageListOverlay
//  Author:    nbi
//  Date:      14-May-2014
//  Arguments: const Value: TPngImageList
//  Result:    None
//-----------------------------------------------------------------------------}
//begin
//  m_imagelistoverlay := value;
//  _setImageFromImageList;
//  Repaint;
//end;




procedure TPngSpeedButton2.CMMouseEnter(var Message: TMessage);
{-----------------------------------------------------------------------------
  Procedure: CMMouseEnter
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: var Message: TMessage
  Result:    None
-----------------------------------------------------------------------------}
begin
  inherited;
  if {ThemeServices.Enabled and} not m_bMouseInControl {and not (csDesigning in ComponentState)} then begin
    m_bMouseInControl := True;
    Repaint;
  end;
end;



procedure TPngSpeedButton2.CMMouseLeave(var Message: TMessage);
{-----------------------------------------------------------------------------
  Procedure: CMMouseLeave
  Author:    nbi
  Date:      16-Sep-2014
  Arguments: var Message: TMessage
  Result:    None
-----------------------------------------------------------------------------}
begin
  inherited;
  if {ThemeServices.Enabled and} m_bMouseInControl then begin
    m_bMouseInControl := False;
    Repaint;
  end;
end;


procedure TPngSpeedButton2.CreatePngGlyph;
var
  Bmp: TBitmap;
begin
  //Create an empty glyph, just to align the text correctly
  Bmp := TBitmap.Create;
  try
    Bmp.Width := m_PngImage.Width;
    Bmp.Height := m_PngImage.Height;
    Bmp.Canvas.Brush.Color := clBtnFace;
    Bmp.Canvas.FillRect(Rect(0, 0, Bmp.Width, Bmp.Height));
    Glyph.Assign(Bmp);
    NumGlyphs := 1;
  finally
    Bmp.Free;
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
  RegisterComponents(SDelphiComponentsPageName, [TPngSpeedButton2]);
end;




end.
