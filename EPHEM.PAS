unit Ephem;
{
Sun ephemeris display page

v01.01 2003-03-17 Original using IDE and comp/ephemeris()
v01.02 2003-03-17 Replace OnDestroyForm by OnCloseForm
v01.03 2003-03-17 Select: static information filling code
v01.04 2003-03-18 Rename btnClose as btnCancel
v01.05 2003-05-25 OnDestroyForm: added back; frmEphem := NIL
v01.06 2003-05-28 comd/Globals changes
v01.07 2003-05-28 showdate (comd.date) -> FormatDateTime ('yyyy-mm-dd', dt)
v01.08 2004-03-03 *.dfm: label wording improvements
v01.09 2006-03-17 Remove Uses tp5utils, add Uses Sol
}

Interface

USES
{$IFDEF LINUX}
  QButtons, QForms, QStdCtrls,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Buttons, Forms, StdCtrls,
  Windows, Messages,
{$ENDIF}
  DateUtils, SysUtils,
  comu, 
  Sol, Globals;

type
  TfrmEphem = class(TForm)
    btnCancel: TBitBtn;
    gbLocation: TGroupBox;
      lblSiteTitle: TLabel;
        lblSiteValue: TLabel;
      lblLatTitle: TLabel;
        lblLatValue1: TLabel;
        lblLatValue2: TLabel;
        lblLatValue3: TLabel;
      lblLonTitle: TLabel;
        lblLonValue1: TLabel;
        lblLonValue2: TLabel;
        lblLonValue3: TLabel;
      lblElevTitle: TLabel;
        lblElevM: TLabel;
        lblElevFT: TLabel;
    gbClock: TGroupBox;
      lblCivil: TLabel;
      lblUTC: TLabel;
      lblDateTitle: TLabel;
        lblDateValue: TLabel;
      lblDayTitle: TLabel;
        lblDayValue: TLabel;
      lblDOYTitle: TLabel;
        lblDOYCivil: TLabel;
        lblDOYUTC: TLabel;
      lblTimeTitle: TLabel;
        lblTimeCivil1: TLabel;
        lblTimeUTC1: TLabel;
        lblTimeCivil2: TLabel;
        lblTimeUTC2: TLabel;
    gbAdjust: TGroupBox;
      lblZDTitle: TLabel;
        lblZDValue: TLabel;
      lblTZTitle: TLabel;
        lblTZValue: TLabel;
      lblLeadTitle: TLabel;
        lblLeadValue1: TLabel;
        lblLeadValue2: TLabel;
      lblEQTitle: TLabel;
        lblEQValue1: TLabel;
        lblEQValue2: TLabel;
    gbCelestial: TGroupBox;
      lblDecTitle: TLabel;
        lblDecValue1: TLabel;
        lblDecValue2: TLabel;
      lblLHATitle: TLabel;
        lblLHAValue1: TLabel;
        lblLHAValue2: TLabel;
      lblRATitle: TLabel;
        lblRAValue1: TLabel;
        lblRAValue2: TLabel;
    gbPosition: TGroupBox;
      lblAltTitle: TLabel;
        lblAltValue1: TLabel;
        lblAltValue2: TLabel;
      lblZenithTitle: TLabel;
        lblZenithValue1: TLabel;
        lblZenithValue2: TLabel;
      lblAzimuthTitle: TLabel;
        lblAzimuthValue1: TLabel;
        lblAzimuthValue2: TLabel;
    gbTransit: TGroupBox;
      lblTransitTimeTitle: TLabel;
        lblTransitTimeValue: TLabel;
      lblTransitAltTitle: TLabel;
        lblTransitAltValue: TLabel;
      lblTransitZenithTitle: TLabel;
        lblTransitZenithValue: TLabel;
    gbPhenomena: TGroupBox;
      lblBegin: TLabel;
      lblEnd: TLabel;
      lblDuration: TLabel;
      lblAstTitle: TLabel;
        lblAstBegin: TLabel;
        lblAstEnd: TLabel;
        lblAstDuration: TLabel;
      lblNavTitle: TLabel;
        lblNavBegin: TLabel;
        lblNavEnd: TLabel;
        lblNavDuration: TLabel;
      lblCivTitle: TLabel;
        lblCivBegin: TLabel;
        lblCivDuration: TLabel;
        lblCivEnd: TLabel;
      lblRSTitle: TLabel;
        lblRSBegin: TLabel;
        lblRSEnd: TLabel;
        lblRSDuration: TLabel;
    PROCEDURE OnClickButton (Sender: TObject);
    PROCEDURE OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
    PROCEDURE OnDestroyForm (Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEphem: TfrmEphem;

  PROCEDURE Select;
  PROCEDURE UpdateIt;

implementation

{$R *.dfm}

{-------------------------------------------------------------}

PROCEDURE TfrmEphem.OnClickButton (Sender: TObject);
{What to do when a command button is pressed}
BEGIN
  IF (Sender = btnCancel) THEN BEGIN
    Self.Release;
    frmEphem := NIL;
    END;
  END;  {of procedure OnClickButton}
{-------------------------------------------------------------}

PROCEDURE TfrmEphem.OnCloseForm (Sender: TObject; VAR Action: TCloseAction);
{What to do when form closed}
BEGIN
  Action := caFree;
  frmEphem := NIL;
  END;  {of procedure OnCloseForm}
{-------------------------------------------------------------}

PROCEDURE TfrmEphem.OnDestroyForm (Sender: TObject);
{What to do when form destroyed -- probably redundant}
BEGIN
  frmEphem := NIL;
  END;  {of procedure OnDestroyForm}
{-------------------------------------------------------------}

PROCEDURE Select;
{Come here when this menu item selected on a form}
BEGIN
  IF NOT Assigned (frmEphem) THEN BEGIN 
    frmEphem := TfrmEphem.Create (Application);
    END;
  {These page entries fixed unless the configuration file is changed}
  WITH frmEphem DO BEGIN
    WITH helios_var DO BEGIN
    lblSiteValue.Caption := Trim(site_id);
    lblLatValue1.Caption := FloatToStrF (site_lat.degrees, ffFixed, 8, 3);
    lblLatValue2.Caption := '---';
    lblLatValue3.Caption := Trim(site_lat.txt);
    lblLonValue1.Caption := FloatToStrF (site_lon.degrees, ffFixed, 8, 3);
    lblLonValue2.Caption := '---';
    lblLonValue3.Caption := Trim(site_lon.txt);
    lblElevM .Caption := FloatToStrF (site_alt, ffFixed, 5, 0) + ' m';
    lblElevFT.Caption := FloatToStrF (site_alt*3.28084, ffFixed, 5, 0) + ' ft';
    lblZDValue.Caption   := FloatToStrF (site_zd.td, ffFixed, 6, 1);
    lblTZValue.Caption   := Trim(site_tz);
    lblLeadValue1.Caption := FloatToStrF (site_lead.td, ffFixed, 8, 3);
    lblLeadValue2.Caption := Trim(site_lead.txt);
    END;  {with helios_var}
    Show;
    SetFocus;
    WindowState := wsNormal;
    END;  {with frmEphem}
  UpdateIt;
  END;  {of procedure 'Select'}
{-------------------------------------------------------------}

PROCEDURE UpdateIt;
{Come here at end of every sample/control period}
VAR dt: TDateTime;
    year, month, day: Word;
    begin_ast, begin_nav, begin_civ, begin_rs: Single;
BEGIN
  IF Assigned (frmEphem) THEN 
  IF (frmEphem.WindowState <> wsMinimized) THEN

  WITH frmEphem DO WITH helios_var DO BEGIN
    {Get current system date/time}
    dt := Now;
    year  := YearOf (dt);
    month := MonthOf (dt);
    day   := DayOfTheMonth (dt);
    {Date -- local civil only}
    lblDateValue.Caption := FormatDateTime ('yyyy-mm-dd', dt);
    {Weekday -- local civil only}
    lblDayValue.Caption := weekday (year, month, day);
    {Day of year}
    lblDOYCivil.Caption := FloatToStrF (lct.ty, ffFixed, 9, 4);
    lblDOYUTC  .Caption := FloatToStrF (utc.ty, ffFixed, 9, 4);
    {Time}
    lblTimeCivil1.Caption := Trim (lct.txt);
    lblTimeUTC1  .Caption := Trim (utc.txt);
    lblTimeCivil2.Caption := FloatToStrF (lct.td, ffFixed, 9, 3);
    lblTimeUTC2  .Caption := FloatToStrF (utc.td, ffFixed, 9, 3);
    {Equation of time}
    lblEQValue1.Caption := FloatToStrF (eqoft.td, ffFixed, 8, 3);
    lblEQValue2.Caption := Trim(eqoft.txt);
    {Sun's declination}
    lblDecValue1.Caption := FloatToStrF (sun_dec.degrees, ffFixed, 8, 3);
    lblDecValue2.Caption := Trim(sun_dec.txt);
    {Sun's right ascension}
    lblRAValue1.Caption := FloatToStrF (sun_ra.degrees, ffFixed, 8, 3);
    lblRAValue2.Caption := Trim(sun_ra.txt);
    {Sun's true altitude}
    lblAltValue1.Caption := FloatToStrF (sun_alt.degrees, ffFixed, 8, 3);
    lblAltValue2.Caption := Trim(sun_alt.txt);
    {Sun's true zenith angle}
    lblZenithValue1.Caption := 
      FloatToStrF (90.0 - sun_alt.degrees, ffFixed, 9, 3);
    {Sun's true azimuth}
    lblAzimuthValue1.Caption := FloatToStrF (sun_azi.degrees, ffFixed, 8, 3);
    lblAzimuthValue2.Caption := Trim(sun_azi.txt);
    {Transit}
    helios_decra (year, month, day, 12, 0, 0);
    helios_transit;
    lblTransitTimeValue.Caption := Trim(transit_when.txt);
    lblTransitAltValue.Caption := Trim(transit_where.txt);
    lblTransitZenithValue.Caption := 
      FloatToStrF (90.0 - transit_where.degrees, ffFixed, 9, 3);
    {Sun rise phenomena}
    helios_decra (year, month, day, 6, 0, 0);
    helios_riset (-18.0);  {Astronomical twilight}
    lblAstBegin.Caption := Trim(sun_rise.txt);
    begin_ast := sun_rise.td;
    helios_riset (-12.0);  {Navigational twilight}
    lblNavBegin.Caption := Trim(sun_rise.txt);
    begin_nav := sun_rise.td;
    helios_riset ( -6.0);  {Civil twilight}
    lblCivBegin.Caption := Trim(sun_rise.txt);
    begin_civ := sun_rise.td;
    helios_riset (-50.0/60.0);  {Sun rise}
    lblRSBegin.Caption := Trim(sun_rise.txt);
    begin_rs := sun_rise.td;
    {Sun set phenomena}
    helios_decra (year, month, day, 18, 0, 0);
    helios_riset (-18.0);  {Astronomical twilight}
    lblAstEnd.Caption := Trim(sun_set.txt);
    lblAstDuration.Caption := 
      FloatToStrF (sun_set.td-begin_ast, ffFixed, 5, 2);
    helios_riset (-12.0);  {Navigational twilight}
    lblNavEnd.Caption := Trim(sun_set.txt);
    lblNavDuration.Caption := 
      FloatToStrF (sun_set.td-begin_nav, ffFixed, 5, 2);
    helios_riset ( -6.0);  {Civil twilight}
    lblCivEnd.Caption := Trim(sun_set.txt);
    lblCivDuration.Caption := 
      FloatToStrF (sun_set.td-begin_civ, ffFixed, 5, 2);
    helios_riset (-50.0/60.0);  {Sun set}
    lblRSEnd.Caption := Trim(sun_set.txt);
    lblRSDuration.Caption := 
      FloatToStrF (sun_set.td-begin_rs, ffFixed, 5, 2);
    END;

  END;  {of procedure 'UpdateIt'}

{of Ephem.pas} end.
