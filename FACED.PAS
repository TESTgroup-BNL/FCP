Unit faced;

{$N+}  {80x87 floating point processor ON}
{$D+}  {debugging compilation          ON}
{$L+}  {line number reference          ON}
{$R+}  {range checking                 ON}
{$IFDEF DELPHI}
{$H-}  {new strings (Delphi)          OFF}
{$ENDIF}

{*
 * Name:     FACEDyy.PAS
 *
 * Purpose:  BNL FACE Project
 *           Real-time and data analysis programs
 *           FACE control and Multiport output file data records
 *
 * Version:     1
 * Date:        11-06-92
 * Language:    TurboPascal 5
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Original using declarations from ANALIB.PAS v7.
 *   (2) Add 1992 and 1993 type records (which are the same).
 *   (3) Add air temperature, pressure, solar radiation, 
 *         and ambient CO2 variables to LOGG.
 *   (4) Add status word to LOGG.
 *   (5) Introduce "three byte real" storage in LOGG, STAT, and VARR,
 *   (6) Make dates String[8] rather than String[10] in L, S, V, and P.
 *   (7) Make wwdir and sstdwdir INTEGER rather than String[3] in LOGG.
 *   (8) Replace backuppath by maximum vvp refresh period in PARR.
 *   (9) Multiport 1992/3 records are the same as in 1991.  (but see 3/5/93)
 *
 * Version:     2
 * Date:        November/December 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Include the COM display settings record type.   
 *
 * Version:     3
 * Date:        5 March 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (0) Had already changed name of this unit to faced93.pas.
 *   (1) New multiport record definition which includes vapor content of air.
 *   (2) Change date to String[8].
 *   (3) Use INTEGER rather than float for CO2 and H2O records to save room.
 *       This should be ok for CO2 in umol mol-1 and H2O in Pa.
 *   (4) Standard deviations are now as stated, not first moment about nominal.
 *
 * Version:     4
 * Date:        18 October 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Define da93ch and trash93ch record types for CH multiports.
 *
 * Version:     5
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as FACED94.                                     [12/10/93]
 *   (2) Define logg94, etc. as logg93, etc. for now.              [12/10/93]
 *   (3) Define new type of display record for 1994 but don't use. [12/12/93]
 *   (4) Define new type of parr record for 1994 which (a) adds    [12/12/93]
 *       control over gas concentration alarms, (b) replaces
 *       cont by an integer variable for off, cont, clock, or solar,
 *       and (c) enrichment mode (absolute or differential).
 *   (5) Replace ccalarm_bracket, ccalarm_base by ccalarm.         [12/14/93]
 *   (6) Also need ppidfactormin and  ppidfactormax in parr.       [12/15/93]
 *
 * Version:     6
 * Date:        June 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add 5th graph type (snapshot) to display records.         [94/06/26]
 *   (2) Add const labelpos_dsplobj; used for line graph labels    [94/06/29]
 *
 * Version:     7
 * Date:        January 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) 1995 file types, etc. initially set = 1994 except VARREC  [95/01/05]
 *
 * Version:     8
 * Date:        July 1995
 * Changes:
 *   (1) However new VARR type never used by anyting; make it 1996 [95/07/11]
 *
 * Version:     9
 * Date:        Oct-Dec 1995, Jan 1996
 * Changes:
 *   (1) Becomes FACED96.PAS                                       [95/10/14]
 *   (2) Define base_rec data type for ambient + or x fumigation   [95/11/19]
 *   (3) Add eenrich_base: base_rec to parrec96                    [95/11/19]
 *   (3) Change ggcset to eenrich_val[0..2] in parrec96            [95/12/07]
 *   (4) Add ccvspeed (coeff. of var. of wind speed to logg96)     [95/12/07]
 *   (5) max_displobj now 21; uncomment ph2o stuff in lists        [96/01/05]
 *   (6) declare conditional_enabled, *_rec, *_set, & c*_var PARR  [96/01/07]
 *
 * Version:     10
 * Date:        Dec 1996
 * Changes:
 *   (1) Becomes FACED97.PAS                                       [96/12/22]
 *   (2) 1997 file types initially set same as 1996                [96/12/22]
 *
 * Version:     11
 * Date:        April 1997
 * Changes:
 *   (1) Change all non-comment occurences of CO2 to GAS           [97/04/18]
 *
 * Version:     11
 * Date:        December 1997
 * Changes:
 *   (1) Becomes FACED98.PAS                                       [97/12/23]
 *   (2) PARR98: change eenrich_val[0..2] to [0..3]                [97/12/24]
 *   (3) LOGG98: add ssite: String[3]                              [97/12/24]
 *   (4) LOGG98: add zzd: Single                                   [97/12/24]
 *   (5) LOGG98: replace aairtemp by ttemp1 AND ttemp2             [97/12/24]
 *   (6) LOGG98: add pph2o                                         [97/12/24]
 *   (7) LOGG98: replace aambient by ggcambi AND ggcntl            [97/12/24]
 *   (8) LOGG98: rename ggcont as ggcgrab                          [97/12/24]
 *   (9) LOGG98: rename aagc1hr as aagc5m                          [97/12/24]
 *  (10) DISPLAY_SET 98                                            [97/01/04]
 *
 * Version:     12
 * Date:        November 1998
 * Changes:
 *   (1) Becomes FACED99.PAS                                       [98/11/08]
 *   (2) For now, all 1999 files same as 1998                      [98/11/08]
 *
 * Version:     13
 * Date:        2000
 * Changes:
 *   (1) For now, all 2000 files same as 1998                      [00/01/18]
 *   (2) $H- directive added for old Pascal strings                [00/02/14]
 *   (3) IFDEF TURBO keep logrec99=logrec98, parrec99, & mp        [00/03/03]
 *   (4) IFDEF DELPHI use explicit type with INTEGER-->SmallInt    [00/03/03]
 *   (5) Set logrec00, etc. types = the same as logrec99, etc.     [00/05/04]
 *
 * Version:     14
 * Date:        2002
 * Changes:
 *   (1) Unit renamed faced99                                      [02-03-21]
 *
 * Version:     15
 * Date:        2003
 * Changes:
 *   (1) display_obj32: new, float-->Single and Byte-->INTEGER     [03-01-07]
 *   (2) display_set32: new, uses display_obj32                    [03-01-07]
 *   (3) displayrec32:  new, uses display_set32, deletes STAT      [03-01-07]
 *   (4) these new record types are NOT packed, i.e. use $A+       [03-01-07]
 *   (5) change display_set = from display_set98 to display_set32  [03-01-07]
 *   (6) name_dsplobj: improve                                     [03-01-09]
 *   (7) Remove pre-1999 logg, varr, parr material                 [03-06-08]
 *   (8) Remove all stat material                                  [03-06-08]
 *   (9) Remove pre-2003 disp material                             [03-06-08]
 *  (10) Remove all mp material                                    [03-06-08]
 *       faced now only for FCP 2003+; see archived faced99 2000-05-04
 *
 * Version:     16
 * Date:        2012
 * Changes:
 *   (1) Copied back in record types da93ch and trash93ch from   [2012-02-06]
 *       COM99\FACED.PAS v13 2000-05-04.  This required for the
 *       development of RING12.
 *}

Interface  {declarations available to other units}

CONST

  grabsmax = 60;  {see type da93ch, et seq.}

  max_dsplobj = 23;  {see type displayrec94, et seq.}
  name_dsplobj: ARRAY [1..max_dsplobj] OF String =
    ('[gas] Grab    ', '[gas] 1-minute', '[gas] 5-minute', '[gas] Control ', 
     '[gas] Ambient ', '[gas] PID     ', 'Valve Control ', 'Valve Response', 
     'Wind Speed    ', 'Wind Direction', 'Temperature #1', 'Temperature #2',
     'Atm pressure  ', 'Solar rad     ', 'pH2O          ', 'Coeff Integral',    
     'Coeff Prop    ', 'Coeff Diff    ', 'Coeff Wind    ', 'Term Integral ', 
     'Term Prop     ', 'Term Diff     ', 'Term Wind     ');
  labelpos_dsplobj: ARRAY [1..max_dsplobj] OF Single =
    (0.16, 0.12, 0.08, 0.04, 0.00, 0.00, 0.04, 0.00, 0.04, 0.00, 0.04, 0.00,
     0.00, 0.00, 0.00, 0.12, 0.08, 0.04, 0.00, 0.12, 0.08, 0.04, 0.00);

TYPE

  float = Single;  {IEEE 4-byte real}

  tbr = RECORD     {same as above with LSByte removed}
          hi2: Word;
          lo : Byte;
          END;

  base_rec = RECORD        {PARR record var type for non-constant fumigation}
               int,               {ambient [GAS] integration time in seconds}
               low,               {do not use a base value below this value}
               high,              {do not use a base value above this value}
               default: float;    {use this if ambient can not be determined}
               END;

  CONST max_conditionals = 6;    {for conditional fumigation}
  TYPE  conditional_rec  = RECORD
                             title:  String[16];
                             enable: BOOLEAN;
                             int,
                             low,
                             high,
                             hysteresis: float;
                             END;
        conditional_set  = ARRAY [1..max_conditionals] OF conditional_rec; 

  {FACE data record definitions by function and year}

  logrec99 = RECORD
    ssite                    : String[3];
    ddate, ttime             : String[8];
    wwwdir, sstdwdir         : SmallInt;
    zzd,
    wwspeed, ccvspeed,
    ttemp1, ttemp2, 
    aairpres, ssolrad, pph2o,
    ppropc, ppropresp,
    ggcset, ggcambi, ggccntl, 
    ggcgrab, aagc1m, aagc5m : {tbr}Single;
    sstatus                 : Word;
    bback1                  : Longint;
    END;

  varrec99 = RECORD
    ddate, ttime            : String[8];
    aainteg_adj, ccinteg,
    aaprop_adj,  ccprop,
    aadiff_adj,  ccdiff,
    aawind_adj,  ccwind,
    ppropc,     
    ggcset, ggcinst, ggcav,
    pproplearn, wwindlearn  : {tbr}Single;
    bback3                  : Longint;
    END;

  parrec99 = RECORD
    ddate, ttime: String[8];
    ttsamp,    ttcont,
    aainteg,   aaprop,  aadiff, aawind,
    ppidfactormin, ppidfactormax,
    wwindprop, wwindthr,
    ppreset, ffalarm, ccalarm,
    ggcint, wwsint, wwdint,
    ttlearn,   llimit,
    tfil1,     tfil2,   tfil3:  float;
    sfil1, sfil2, sfil3, sfil4: BOOLEAN;
    eenrich_mode: SmallInt;         {0=constant, 1=additive, 2=multiplicative}
    eenrich_val:  ARRAY [0..3] OF float;
    eenrich_base: base_rec;               {differential fumigation parameters}
    oonoff_mode:  SmallInt;            {0=off, 1=continuous, 2=clock, 3=solar}
    ttimeon, ttimeoff: SmallInt;   {dos clock times in minutes since midnight}
    ddawn_altitude: float;      {defines beginning of day; sun alt in degrees}
    cconditional_enabled: BOOLEAN;
    cconditional_var: conditional_set;
    rrefreshvvp: float;          {maximum vvp valve refresh period in seconds}
    bback4: Longint;
    END;

  {$A+}
  display_obj32 = RECORD
                  exists, enable: BOOLEAN;
                  low, high,              {engineering units}
                  scale, offset: Single;  {size, bottom as fraction of window}
                  color: INTEGER;
                  END;

  display_set32 = RECORD CASE BOOLEAN OF
                  TRUE:  (gc_grab,
                          gc_1min,
                          gc_5min,
                          gc_cntl,
                          gc_ambi,
                          gc_cont,       {the integral used by varr}
                          pv_control,
                          pv_response,
                          windspeed,
                          winddirection,
                          temperature1,
                          temperature2,
                          pressure,
                          radiation,
                          ph2o,
                          coef_int,
                          coef_prop,
                          coef_diff,
                          coef_wind,
                          term_int,
                          term_prop,
                          term_diff,
                          term_wind: display_obj32);
                  FALSE: (obj: ARRAY [1..max_dsplobj] OF display_obj32);
                  END;

  displrec32 = RECORD CASE BOOLEAN OF
                 TRUE:  (logg_dspl,
                         varr_dspl,
                         genl_dspl,
                         snap_dspl: display_set32);
                 FALSE: (dspl: ARRAY [1..4] OF display_set32);
                 {   1..   2..   3..   4}  
                 {logg..varr..genl..snap}
                 END;
  {$A-}

  display_set = display_set32;

  da93ch = RECORD
           sstatus: Byte;                 {7..4, 3..0 = errflag, ringno}
           nnodid: Longint;
           ddate, ttime: String[8];
           ttpurg, ttsamp,
           wwspeed, wwdir,
           ttemp: float;
           {$IFDEF TURBO}
           ggcset, ggcent: INTEGER;
           gginst: ARRAY [1..grabsmax] OF INTEGER;
           ggcav: INTEGER;
           {$ENDIF}
           {$IFDEF DELPHI}
           ggcset, ggcent: SmallInt;
           gginst: ARRAY [1..grabsmax] OF SmallInt;
           ggcav: SmallInt;
           {$ENDIF}
           llastb: Longint;
           END;

  trash93ch = RECORD
           ttaver: float;
           ggcont, ggcav24, ggstd: INTEGER;
           hh2o_port, hh2o_av, hh2o_av24, hh2o_std, hh2o_cent: INTEGER;
           END;

Implementation

{of unit 'FACED.PAS'...}
END.
