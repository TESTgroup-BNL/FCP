Unit Sol;

{
Sun ephemeris package

v1.0 2004-06-18 Split out of HELIOS package from tp5utils.pas v5.0 01/28/03
}

Interface

TYPE hangle  = RECORD           {used by helios_var}
                 degrees,
                 radians,
                 sine,
                 cosine: Double;
                 txt: String[12];
                 END;

     htime   = RECORD           {used by helios_var}
                 doy: INTEGER;
                 td,                  {time since 00:00h in hours}
                 ty : Double;         {time since 0 Jan 00:00h in days}
                 txt: String[12];
                 END;

VAR helios_pressure: Double;  {used by Sdir calculation; default 101.325 kPa}
    helios_var: RECORD   {this is a named common block for the helios package}
                  site_lat,             {degrees, N+}
                  site_lon:  hangle;    {degrees, E+}
                  site_zd,              {zone descriptor, e.g. EST is -5.00}
                  site_lead: htime;     {mean sun transit leads civil noon}
                  lct,                  {local civil (watch) time}
                  utc:       htime;     {"Greenwich" time}
                  sun_dec,              {declination}
                  sun_ra:    hangle;    {right ascension}
                  sun_alt,              {altitude above unobstructed horizon}
                  sun_azi:   hangle;    {azimuth}
                  sun_rise,
                  sun_set,
                  daylen:    htime;
                  eqoft:     htime;     {EquationOfTime (+ ahead of mean)}
                  transit_when:  htime;
                  transit_where: hangle;
                  sdir: RECORD
                    ratio,
                    e,
                    pfd: Double;
                    END;
                  END;


PROCEDURE helios_site (latitude, longitude, zd: Double);
PROCEDURE helios_decra (year, month, day, hour, minute, second: INTEGER);
PROCEDURE helios_altaz;
PROCEDURE helios_riset (dawn_angle: Double);
PROCEDURE helios_transit;

Implementation

{------------------------------------------------------------}

FUNCTION atan2 (s,c: Double): Double;
{Since standard Pascal only supplies a principal value
 (-pi/2 <= arctan <= +pi/2), this function was written
 to (1) provide angle in all 4 quadrants
    (2) in degrees 0 <= atan2 < 360.
 John Nagy  12/11/90}
CONST pi = 3.14159;
VAR x: Double;
BEGIN
  IF c <> 0.0
    THEN x := ARCTAN (s/c)
    ELSE IF s >= 0.0 THEN x := +pi/2.0
                     ELSE x := -pi/2.0;
  IF c < 0.0 THEN x := pi+x;
  x := x*180.0/pi;
  WHILE x <    0.0 DO x := x+360.0;
  WHILE x >= 360.0 DO x := x-360.0;
  atan2 := x;
  END;  {of function 'atan2'}
{--------------------------------------------------}

FUNCTION dddmmss (angle: Double): String;
{Convert angle in degrees to string sDDDoMM'SS"
 J.N.  01/07/94}
VAR ia: Longint;
    iss, imm, idd: INTEGER;
    ss, mm, dd: String;
    sign: CHAR;
    i: INTEGER;
BEGIN
  sign := '+';
  IF angle < 0.0 THEN BEGIN
    sign := '-';
    angle := ABS(angle);
    END;
  ia := ROUND(angle*3600.0);
  WHILE angle >= 360.0 DO angle := angle - 360.0;
  iss := ia MOD 60;
  imm := (ia DIV 60) MOD 60;
  idd := (ia DIV 3600);
  Str(iss:2,ss);  Str(imm:2,mm); Str(idd:4,dd);
  i := 3;
  WHILE dd[i] <> ' ' DO DEC(i);
  dd[i] := sign;
  dddmmss := dd + CHR(248)+ mm + '''' + ss + '"';
  END;  {of function 'dddmmss'}
{------------------------------------------------------------}

FUNCTION hhmmss (t: Double): String;
{Convert time t in seconds since midnight to string HH:MM:SS
 J.N.  92/12/10  Original
       94/08/31  Add var tt and check for tt=24:00:00}
VAR it: Longint;
    iss, imm, ihh: INTEGER;
    ss, mm, hh, tt: String;
BEGIN
  it := ROUND(t);
  iss := it MOD 60;
  imm := (it DIV 60) MOD 60;
  ihh := (it DIV 3600);
  Str(iss:2,ss);  Str(imm:2,mm); Str(ihh:2,hh);
  IF ss[1]=' ' THEN ss[1] := '0';
  IF mm[1]=' ' THEN mm[1] := '0';
  IF hh[1]=' ' THEN hh[1] := '0';
  tt := hh+':'+mm+':'+ss;
  IF tt <> '24:00:00' THEN hhmmss := tt          
                      ELSE hhmmss := '23:59:59';
  END;  {of function 'hhmmss'}
{------------------------------------------------------------}

FUNCTION dayofyear (year, month, day: INTEGER): INTEGER;
{Day of year as defined in Almanac for Computers, 1988,
 pages B1-B2.
 Valid for years 1901..2099.
 Input is the 2-digit year and one-based month and day
 John Nagy 12/05/90
           01/10/94 renamed from julian
           11/27/98 return -1 if year, month, or day are out-of-range
           06/01/03 allow day range [0..32] for easy UTC DOY calculations
 }
VAR hold: INTEGER;
BEGIN
  IF NOT ((year  >= 0) AND (year  <= 99) AND 
          (month >= 1) AND (month <= 12) AND 
          (day   >= 0) AND (day   <= 32))  {stet!}
  THEN hold := -1
  ELSE hold :=
    ((275*month) DIV 9)
     -((month+9) DIV 12)*(1+((year-4*(year DIV 4)+2) DIV 3))
    +day - 30;
  dayofyear := hold;
  END;  {of function 'dayofyear'}
{------------------------------------------------------------}


{*******************  HELIOS PACKAGE  ***********************}
{                                                            }
{ Sun's Ephemeris                                            }
{                                                            }
{ These routines use formulae from                           }
{ "Almanac for Computers: 1988"                              }
{ United States Naval Observatory                            }
{ pp. B1-B9                                                  }
{                                                            }
{ The accuracy of the particular formulae selected for       }
{ declination and right ascension, as regards rise and       }
{ set of the sun, is summarized as, "For location between    }
{ 65o North and 65o South, the following algorithm provides  }
{ ... an accuracy of +-2 m[inutes of time], for any date     }
{ in the latter half of the twentieth century." [B5]         }
{                                                            }
{ The package is invoked by:                                 }
{                                                            }
{   Uses Sol;  <-- goes into program calling this package    }
{                                                            }
{   helios_site (latitude, longitude, zone: Double);         }
{     This procedure needs to be called only once,           }
{     assuming the location of the observer doesn't          }
{     change.  It calculates intermediate values needed      }
{     by the other procedures and MUST be called first.      }
{       latitude:  latitude of observer in degrees, North +  }
{       longitude: longitude of observer in degrees, East +  }
{       zone:      time zone descriptor, e.g. EST is -5.00   }
{                                                            }
{   helios_decra (year, month, day, hour, minute, second);   }
{     This procedure calculates the sun's declination        }
{     and right ascension at the given moment.  The six      }
{     arguments are type INTEGER.  They are the local civil  }
{     (i.e., watch) time at the location.  Whether this is   }
{     standard or daylight depends on what was used for      }
{     "zone" in the call to helios_site.  "Year" is given    }
{     in full, that is 1994, not 94.  This call must follow  }
{     helios_site (because of "zone") and precede those      }
{     described below.  One may wish to iterate.             }
{                                                            }
{   helios_altaz;                                            }
{     This procedures calculates the altitude (degrees above }
{     unobstructed horizon) and bearing (degrees from North) }
{     of the true center of the sun at the place and time    }
{     set up by the two previous routines.  No correction    }
{     is made for any elevation difference between the       }
{     observer and the horizon.  Results are returned        }
{     through the global variable record "helios_var" in     }
{     helios_var.sun_alt.* and helios_var.sun_azi.*.         }
{     See below for the various * possibilities.             }
{                                                            }
{   helios_riset (dawn_angle: Double);                       }
{     This procedure calculates the time of the beginning    }
{     and end of "daylight".  The latter is defined by       }
{     dawn_angle which is the altitude of the true center    }
{     of the sun in degrees.  For example, sun rise and set  }
{     are usually defined with an angle of -50 minutes       }
{     (= -0.83333 degrees) and civil twilight with an        }
{     angle of -6 degrees.  The sun declination used is that }
{     last calculated in helios_decra.  Results are returned }
{     in helios_var.sun_rise.$ and helios_var.sun_set.$.     }
{                                                            }
{   helios_transit;                                          }
{     This procedure calculates the local civil time of      }
{     solar transit and the altitude (not zenith) angle      }
{     at transit.  Whatever values for declination last set  }
{     by helios_decra are used.  The results are returned    }
{     in helios_var.transit_when.$ and                       }
{     helios_var.transit_where.*.                            }
{                                                            }
{   There are two types of variables stored in the record    }
{   "helios_var":  angle and time.  Subrecords simply store  }
{   the angle or time in different formats.  Note that not   }
{   all formats are calculated for all variables.            }
{                                                            }
{   Meanings of .* (angles)                                  }
{     .degrees  angle in degress                             }
{     .radians  angle in radians                             }
{     .sine     sine of angle                                }
{     .cosine   cosine of angle                              }
{     .txt      angle as text string +DDDoMM'SS"             }
{                                                            }
{   Meanings of .$ (times)                                   }
{     .year                                                  }
{     .month                                                 }
{     .day                                                   }
{     .doy      day-of-year from 0 January (January 1 = 1)   }
{     .hour                                                  }
{     .minute                                                }
{     .second                                                }
{     .td       seconds since 00:00h                         }
{     .ty       days since 0 January 00:00h                  }
{     .txt      time of day as text string HH:MM:SS          }
{                                                            }
{                                                            }
{ J.N.  01/10/94  Original constructed from a potpourri      }
{                 of older routines                          }
{------------------------------------------------------------}

FUNCTION eqoftime (t: Double): Double;
CONST dtor = 0.0174533;  {radians in one degree}
VAR xm: Double;
{Hours actual sun is ahead of mean sun.
 t is 1.000 at New Year's moment [hours].
 Almanac for Computers: 1988, p. B8, formula (1)
 This is the less accurate formula (+-0.8m) which only applies for 1988!
 J.N.  12/03/93
}
BEGIN
  xm := -7.66*SIN(dtor*(0.9856*t-4.27)) - 9.78*SIN(dtor*(1.9712*t+16.94));
  eqoftime := xm/60.0;
  END;  {of function 'eqoftime'}
{------------------------------------------------------------}

PROCEDURE anglefill (VAR angrec: hangle; angle: Double);
CONST dtor = Pi/180.0;  {convert degrees to radians}
BEGIN
  WITH angrec DO BEGIN
    degrees := angle;
    radians := dtor*degrees;
    sine    := SIN(radians);
    cosine  := COS(radians);
    txt     := dddmmss(degrees);
    END;
  END;  {of procedure 'anglefill'}
{------------------------------------------------------------}

PROCEDURE clockfill (VAR timrec: htime; t: Double; plusminus: BOOLEAN);
BEGIN
  WITH timrec DO BEGIN
    td := t;
    txt := hhmmss(3600.0*ABS(td));
    IF plusminus
      THEN IF td >= 0.0 THEN txt := '+' + txt
                        ELSE txt := '-' + txt
      ELSE txt := ' ' + txt;
    END;
  END;  {of procedure 'clockfill'}
{------------------------------------------------------------}

PROCEDURE calenfill (VAR timrec: htime; year, month, day: INTEGER);
{call after 'clockfill'}
BEGIN
  WITH timrec DO BEGIN
    doy := dayofyear (year MOD 100, month, day);
    ty := doy + td/24.0;
    END;
  END;  {of procedure 'calenfill'}
{------------------------------------------------------------}

PROCEDURE helios_site (latitude, longitude, zd: Double);
BEGIN
  WITH helios_var DO BEGIN
    anglefill (site_lat, latitude);
    anglefill (site_lon, longitude);
    clockfill (site_zd, zd, TRUE);
    clockfill (site_lead, longitude/15.0{hrs} - zd, TRUE);
    END;
  END;  {of procedure 'helios_site'}
{------------------------------------------------------------}

PROCEDURE helios_decra (year, month, day, hour, minute, second: INTEGER);
{Sun's Declination and Right Ascnsion (and Equation of Time)
 Almanac for Computers: 1988, pp. B5-B6
 }
CONST dtor = 0.0174533;  {radians in one degree}
VAR   t, m, l, sinl, cosl, s, a: Double;
BEGIN
  WITH helios_var DO BEGIN
    clockfill (lct, 1.0*hour+minute/60.0+second/3600.0, FALSE);
    calenfill (lct, year, month, day);
    t := lct.td - site_zd.td;
    IF t <   0.0 THEN BEGIN
      t := t + 24.0;
      day := day - 1;
      END;
    IF t >= 24.0 THEN BEGIN
      t := t - 24.0;
      day := day + 1;
      END;
    clockfill (utc, t, FALSE);
    calenfill (utc, year, month, day);
    m := dtor * (0.985600*utc.ty - 3.289);
    l := m + dtor * (1.916*SIN(m) + 0.020*SIN(2.0*m) + 282.634);
    sinl := SIN(l);
    cosl := COS(l);
    {for declination}
    s := 0.39782*sinl;
    a := atan2(s,SQRT(1.0-s*s));
    IF a > 180.0 THEN a := a - 360.0;
    anglefill (sun_dec, a);
    {for right ascension}
    s := 0.91746*sinl;
    anglefill (sun_ra, atan2(s,cosl));
    {also do the Equation of Time at this point}
    clockfill (eqoft, eqoftime(utc.ty), TRUE);
    END;  {of with helios_var}
  END;  {of procedure 'helios_decra'}
{------------------------------------------------------------}

PROCEDURE helios_altaz;
{Sun's Altitude and Azimuth
 JN  11/12/91  Original as function solaralt
     12/01/93  Use function solardec to get declination
     01/11/94  Incorporated in helios package and azimuth added
     04/30/99  Add calculation of clear day, sea level E and PFD from
               Pearcy et al., 1989, p. 112.  Results available
               in helios_var.sdir.ratio, .e, and .pfd for
               unitless, energy, and photon flux density
               respectively.
 }
CONST dtor = 0.0174533;  {radians in one degree}
VAR lha, sinlha, coslha, a, sina, cosa: Double;
    x, m: Double;
BEGIN
  WITH helios_var DO BEGIN
    lha := dtor * 15.0 * ((lct.td + site_lead.td + eqoft.td) - 12.0);
    sinlha := SIN(lha);
    coslha := COS(lha);
    {altitude = 90.0 - zenith}
    sina := 
      site_lat.sine*sun_dec.sine + site_lat.cosine*sun_dec.cosine*coslha;
    cosa := SQRT(1.0-sina*sina);
    a := atan2(sina,cosa);
    IF a > 180.0 THEN a := a-360.0;
    anglefill (sun_alt, a);
    {azimuth = bearing w.r.t north}
    anglefill (sun_azi, atan2(-sinlha, 
      (sun_dec.sine/sun_dec.cosine*site_lat.cosine - coslha*site_lat.sine)));
    {calculate direct radiation}
    x := 614.0 * sina;
    m := SQRT (1229.0 + x*x) - x;                         {air mass}
    m := m * helios_pressure/101.325;          {pressure correction}
    x := 1.0 + (0.034 * COS (2.0*Pi*(utc.doy-3)/365.25));  {ellipse}
    x := x * 0.56 * (EXP(-0.65*m) - EXP(-0.095*m));    {attenuation}
    WITH sdir DO BEGIN
      ratio := x * sina;
      e     := 1353.0 * ratio;  {W m-2}
      pfd   := 2510.0 * ratio;  {umol m-2 s-1}
      END;
    END;  {of with}
  END;  {of procedure 'helios_altaz'}
{------------------------------------------------------------}

PROCEDURE helios_riset (dawn_angle: Double);
CONST dtor = 0.0174533;  {radians in one degree}
VAR coslha, lha, lh: Double;
BEGIN
  WITH helios_var DO BEGIN
    coslha := (SIN(dtor*dawn_angle)-sun_dec.sine*site_lat.sine)
      /(sun_dec.cosine*site_lat.cosine);
    IF ABS(coslha) < 1.0
      THEN BEGIN
        lha := atan2(SQRT(1.0-coslha*coslha),coslha);
        lh := lha/15.0;
        clockfill (sun_rise, 12.0 - lh - site_lead.td - eqoft.td, FALSE);
        clockfill (sun_set , 12.0 + lh - site_lead.td - eqoft.td, FALSE);
        END
      ELSE IF coslha >= 1.0 
        THEN BEGIN  {sun never rises}
          clockfill (sun_rise, 12.0, FALSE);
          clockfill (sun_set , 12.0, FALSE);
          END
        ELSE BEGIN  {sun never sets}
          clockfill (sun_rise,  0.0, FALSE);
          clockfill (sun_set , 24.0, FALSE);
          END;
    clockfill (daylen  , sun_set.td - sun_rise.td, FALSE);
    END;
  END;  {of procedure 'helios_riset'}
{------------------------------------------------------------}

PROCEDURE helios_transit;
BEGIN
  WITH helios_var DO BEGIN
    clockfill (transit_when, 12.0 - site_lead.td - eqoft.td, FALSE);
    anglefill (transit_where, 90.0 - site_lat.degrees + sun_dec.degrees);
    END;
  END;  {of procedure 'helios_transit'}
{************************************************************}

{Initialize this unit}
BEGIN

{helios package}
helios_pressure := 101.325;  {kPa}
WITH helios_var DO BEGIN
  anglefill (site_lat,      0.0);
  anglefill (site_lon,      0.0);
  anglefill (sun_dec,       0.0);
  anglefill (sun_ra,        0.0);
  anglefill (sun_alt,       0.0);
  anglefill (sun_azi,       0.0);
  anglefill (transit_where, 0.0);
  clockfill (site_zd,      0.0, FALSE);
  calenfill (site_zd,      0,1,0);
  clockfill (site_lead,    0.0, FALSE);
  calenfill (site_lead,    0,1,0);
  clockfill (lct,          0.0, FALSE);
  calenfill (lct,          0,1,0);
  clockfill (utc,          0.0, FALSE);
  calenfill (utc,          0,1,0);
  clockfill (sun_rise,     0.0, FALSE);
  calenfill (sun_rise,     0,1,0);
  clockfill (sun_set,      0.0, FALSE);
  calenfill (sun_set,      0,1,0);
  clockfill (daylen,       0.0, FALSE);
  calenfill (daylen,       0,1,0);
  clockfill (transit_when, 0.0, FALSE);
  calenfill (transit_when, 0,1,0);
  END;  {with}

{unit 'Sol'...}
END.
