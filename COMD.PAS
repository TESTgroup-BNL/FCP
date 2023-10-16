Unit comd;
{$H-}

{*
 * Name:     COMD.PAS
 *
 * Purpose:  BNL FACE Project
 *           On-line data acquisition, monitoring and control
 *           Type definitions, variable declarations, etc.
 *
 * Version:     1
 * Date:        04-04-90
 * Programmer:  Z. Kolber
 * Language:    TurboPascal 5.0
 * Hardware:    Dell 310 20MHz 80386 AT
 * O/S:         MS-DOS 3.3
 * Changes:
 *   (1) As developed to this point by Z. Kolber
 *
 * Version:     2
 * Date:        04-19-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Excessively long lines were rationalized
 *   (2) Some comments added
 *   (3) TYPE float = Single added to declaration unit
 *   (4) REAL types in all units redeclared as float
 *       (see J.N. memo "FACE Binary Records Changed" 4/19/90)
 *   (5) added CONST numrings = 4 & used where appropriate
 *
 * Version:     3
 * Date:        07-18-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Added variables ppmperv[] and voffset[]
 *
 * Version:     4
 * Date:        11-06-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Removed TYPEs timrec & datrec
 *       and VARs timerec & daterec.
 *   (2) Added gcbands, gcband[], and overband[].
 *   (3) Globalized var 'cgw' out of proc 'xloggdis'.
 *   (4) Deleted var ssss.
 *   (5) Replace variables odx, ody, & ihor (which were not used)
 *       by grmaxx & grmaxy.
 *
 * Version:     5
 * Date:        12-06-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Moved following global variables to unit GRAyy.PAS
 *         grdriver, grmode, scalex, scaley,
 *         displx, disply, grmaxx, grmaxy.
 *
 * Version:     6
 * Date:        April 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Introduced const 'maxrings';
 *         'numrings' now a var which is site specific.
 *   (2) Introduced const 'maxvalvs' and
 *         var 'numvalvs' as well.
 *   (3) Defined and used types rings  = [1..maxrings]
 *                          and valves = [1..maxvalvs].
 *   (4) Define type errec and variables err[].
 *   (5) Define variables pverr[] and conterr[].
 *   (6) Rename voffset[] to offset[].
 *   (7) Define site_id as a 3-character string.
 *   (8) 'datapath' changed from const to configuration var.
 *
 * Version:     7
 * Date:        May 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Defined type 'darec'.
 *   (2) Added var 'wd'.
 *   (3) Added vars 'timeerrint' and 'timeerrlast'.
 *   (4) Defined type 'qtrec'.
 *   (5) Added vars 'co2qt[ring]'.
 *   (6) Replaced var 'fanval' by 'fanbits' and 'co2bits'.
 *
 * Version:     8
 * Date:        February 1992
 * Programmer:  J. Nagy
 * Changes:     Make changes/additions for incorporation of DAT
 *   (1) Add 'sss5' and 'sss6'.
 *   (2) Add other variables previously used only by DAT program.
 *   (3) Remove simul; add run_mode, simul_mode, archive_mode.
 *   (4) Remove regs: Registers;
 *
 * Version:     9
 * Date:        November/December 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Use 'faced.pas' and its type definitions.
 *   (2) Change backuppath[ring] to a FACE.CFG variable from a PARR.
 *   (3) Add vvp valve refresh logic record type and variable.
 *   (4) Change var wwdir type from str4 to INTEGER.
 *   (5) Add calibration_param and calibrate_var[rings].  (12/10/92)
 *   (6) Remove VAR i: INTEGER;
 *   (7) Added dataflow type, variable, misc. for diagnostics (12/14/92)
 *   (8) Added variables for air temperature, pressure, and solar radiation.
 *   (9) Added gcont_overflow[] boolean variables. (12/15/92)
 *
 * Version:     10
 * Date:        January 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) forceon and forcevalue vars for calibration mode debugging (1/5).
 *   (2) in calibration mode, make upper and lower limits into bands (1/26).
 *
 * Version:     11
 * Date:        February/March/April/May/June 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin development of COM93 which will include Opto22 DAQC. [2/22/93]
 *   (2) Expand definition of type darec, and make two types
 *         called daqc_port and daqc_addr. [2/23/93]
 *   (3) Delete ppmperv, offset, offscale and replace by CO2_center.
 *   (4) Add enclosure temperature and "humidity" to dataflow list. [4/9/93]
 *   (5) Add variables for 5, 12, +-15V PS test bits. [4/28/93]
 *   (6) Add variable misc_digital_in[ring] for diagnostic bits.
 *   (7) Field code in errrec changed from integer to word.
 *   (8) Add variable comm_err[iring].
 *   (9) Add variables to hold vvp patterns now read from face.cfg.
 *  (10) Change adc_read from BOOLEAN to Word, i.e., the last address read.
 *  (11) Add variables for IRGA zero and span control bits.  [5/25/93]
 *  (12) Move 'fanbits' and 'co2bits' to procedure 'tinter'.
 *  (13) Changed name of gcont_overflow[] to gcont_underflow[]. (06/06/92)
 *  (14) Add type autocalib_rec and vars autocalib_var[ring][zero..span] 
 *       and calib_msg[ring].
 *  (15) Add addr and chan to daqc_port type for use by bus devices (6/27/93)
 *
 * Version:     12
 * Date:        July/August 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Variables needed for link to multiport.  [7/18/93]
 *
 * Version:     13
 * Date:        September/October 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Make gc, wd, ws integrals for multiport into arrays so that
 *       more than one multiport system can be accomidated.  [09/09/93]
 *
 * Version:     14
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as COMD94.                                       [12/10/93]
 *   (2) Add .cfg variables site_lat, _lon, _alt, _zd               [12/12/93]
 *   (3) Changes needed for new PARR records.  See faced94.pas.     [12/12/93]
 *   (4) Replace calram_bracket[], calarm_base[] by calarm[].       [12/14/93]
 *   (5) Add pidfactormin[] and pidfactormax[] for algorithm().     [12/15/93]
 *   (6) Add variables associated with AZ WCL ambient system.       [12/17/93]
 *   (7) Begin using Implementation section for initializations.    [12/17/93]
 *   (8) Add vars site_lag, _lat_sin, _lat_cos to compute just once [12/23/93]
 *   (9) Add vars dawn_alt_sin[] and dawn_alt_cos[].                [12/23/93]
 *
 * Version:     15
 * Date:        January/February 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Variables needed for procedure ephemeris                   [01/06/94]
 *   (2) Negate v14 #8 and #9                                       [01/10/94]
 *   (3) Globalize year, month, day, hour, minute, second           [01/18/94]
 *   (4) Globalize pidfactor and make array[ring]                   [02/05/94]
 *
 * Version:     16
 * Date:        May 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) add const num_mp_links and make var mp an array!           [94/05/02]
 *
 * Version:     16
 * Date:        June/July 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) add record type pittman (for pv motor control)             [94/06/11]
 *   (2) add var array [rings] pv_motor                             [94/06/11]
 *   (3) add var snapop to loggop, etc. list                        [94/06/26]
 *   (4) add types and vars for snapshot graphics                   [94/06/27]
 *   (5) move dograph, dolast, docurrent (w/ dosnapshot) to COMDIS  [94/06/28]
 *   (6) add boolean var snapshot_toggle                            [94/07/09]
 *   (7) add int_change and int_step to type pittman                [94/07/12]
 *
 * Version:     17
 * Date:        August/September 1994
 * Changes:
 *   (1) Change adc_read from Word to an array of records           [94/08/28]
 *
 * Version:     18
 * Date:        Feb-Mar 1995
 * Changes:
 *   (1) Becomes COMD95.PAS                                         [95/02/21]
 *
 * Version:     19
 * Date:        June/July 1995
 * Changes:
 *   (1) Add variable gcamb_peak (during a logging interval)        [95/06/05]
 *   (2) Add display variables solar_ton, solar_toff                [95/06/07]
 *   (3) Remove variable snapshot_ring; now all rings enabled       [95/06/08]
 *   (4) Change var humidity[] to water_vapor[]                     [95/06/14]
 *   (5) Change var watervapor[] to ph2o[]                          [95/06/14]
 *   (6) Add derived quantities rh, dewpoint, vpd [] *** NO ***     [95/06/14]
 *   (7) Add variables h2ovapor_show, _auto for use 'h2ovapor'      [95/06/15]
 *   (8) Add variable errlatch[] (err[] will be cleared on write)   [95/06/16]
 *   (9) Add variable timeerrtest, now separate from timeerrint     [95/06/16]
 *  (10) Add variables progload_date, progload_time                 [95/06/29]
 *  (11) add blflag to type pittman so it is global                 [95/07/29]
 *
 * Version:     20
 * Date:        Sep 1995
 * Changes:
 *   (1) add wwv_present, gps_present: boolean vars. see proc config[95/09/04]
 *   (2) add protocol string to type daqc_port.                     [95/09/04]
 *   (3) delete var daqc_type. replaced by (2).                     [95/09/04]
 *
 * Version:     21 
 * Date:        Oct-Dec 1995; Jan 1996
 * Changes:
 *   (1) Becomes COMD96; update Uses.                               [95/10/14]
 *   (2) Delete xacc, xr (& corresponding y's)                      [95/10/15]
 *   (3) Change variables related to new WCL MP system              [95/11/18]
 *   (4) Replace type valves by valv_range                          [95/12/16]
 *   (5) Replace type rings  by ring_range                          [95/12/16]
 *   (6) Delete variable gcamb_peak                                 [95/12/20]
 *   (7) In type pittman, gain-->kp, kp-->f                         [95/12/20]
 *   (8) Add variables fumigation_enabled[], conditional_ok[]       [96/01/01]
 *   (9) Add variables amb_base_grab and amb_base_int (scalars)     [96/01/01]
 *  (10) snap_ray: increase to 240 (snapshot_max) screens per ring  [96/01/05]
 *  (11) add variable wspeed_avsd                                   [96/01/05]
 *  (12) must add tp5utils to Uses                                  [96/01/05]
 *  (13) add variable conditional_enabled, conditional_var          [96/01/07]
 *  (14) name changes: ps05-->ps01, ps12-->ps02, etc.               [96/01/08]
 *  (15) add boolean var ambient_in_default (an error condition)    [96/01/08]
 *
 * Version:     22
 * Date:        May-July 1996
 * Changes:
 *   (1) Define type motofiletype.                                  [96/05/29]
 *   (2) Define var  moto, motob.                                   [96/05/29]
 *   (3) Change filnam[1..5] to filnam[1..6] for new .DAT file.     [96/05/29]
 *   (4) Define var motoback.                                       [96/05/29]
 *   (5) Add date and time stamps to pv_motor[ring] records.        [96/05/29]
 *   (6) Add boolean var new_sample[ring] set/reset in comp tinter; [96/06/21]
 *   (7) Add rlabel, rhex arrays to replace function rlabel         [96/06/22]
 *   (8) daqc_addr type variable name changes and additions related [96/07/01]
 *       to slaved control ring concept; many others in the fumigation/
 *       control/ambient mess not changed at this time.
 *       CO2_center --> conc_fumi, CO2_ambient --> conc_cont, conc_ambi
 *       vvp_open --> vvp_open_fumi, vvp_open_cont,
 *       fan_rotation --> fan_rotation_fumi, fan_rotation_cont,
 *       fan_onoff --> fan_onoff_fumi, fan_onoff_cont.
 *   (9) digital_in_fumi[] and digital_in_cntl[] <- misc_digital_in [96/07/31]
 *
 * Version:     23
 * Date:        Dec 1996
 * Changes:
 *   (1) Becomes COMD97                                             [96/12/22]
 *   (2) Move adc_read functionality to optomux.pas                 [96/12/30]
 *
 * Version:     24
 * Date:        Jan-Apr 1997
 * Changes:
 *   (1) Declare conditional_value[][].  These are the actual values[97/01/12]
 *         used to test if fumigation conditions are satisfied.  These and
 *         titles for conditional_var[][] are set in tinter after sampling.
 *   (2) Define conditional_var_type.                               [97/01/12]
 *   (3) Allocate conditional_var[][] on heap instead of in DSeg.   [97/01/12]
 *   (4) Declare site_tz:String[4] which is time zone, e.g. EST.    [97/04/10]
 *   (5) Add flow_meter record to type pittman for nonlinear use.   [97/04/11]
 *   (6) Change non-comment occurences of CO2 to GAS,               [97/04/11]
 *         with the exception of the variable co2qt.
 *   (7) Add variable num_conditionals: 1..max_conditionals         [97/04/19]
 *   (8) Add boolean array faceraw_switch used to view comm flow    [97/04/20]
 *
 * Version:     25
 * Date:        May 1997
 * Changes:
 *   (1) Define snapshot_table which is type of old snapshot_ray    [97/05/18]
 *   (2) snapshot_ray is now a pointer to its old self              [97/05/18]
 *   (3) Change loggf, varrf, statf from [1..40] to [1..60]         [97/05/18]
 *   (4) Add variable errgrab:BOOLEAN -- see errset() and tinter;   [97/05/21]
 *
 * Version:     26
 * Date:        July-August 1997
 * Changes:
 *   (1) Define fan_debug_set, gas_debug_set[] for RIV debug mode   [97/07/07]
 *   (2) Add unit_name, label_name, bdtype fields to daqc_add rec   [97/07/08]
 *   (3) Define TYPE list_addr and VAR list_addr_ptr from daqc_addr [97/07/08]
 *   (4) Can now set maxrings to 6;  there is enough DS             [97/07/10]
 *   (5) Get rid of VAR errgrab which was not working for dialout   [97/07/21]
 *   (6) Define VAR errseq used for flase positive killing & dialout[97/07/21]
 *   (7) errseq initialized as follows: alarm_count=1 for errnumbers[97/07/21]
 *       4(fan rot fumi), 5(fan rot cntl), 6(gas supply), 8(PS#2),
 *       9(PS#3), 10(PS#4) -- PS#2..4 may have pressure in series;
 *       dialout_count=10 for 4, 6, 7, 8, 9.
 *   (8) Change errseq[][0..10] to errseq[][0..15].                 [97/07/29]
 *   (9) Add VAR descriptor: ARRAY [rings] OF String[16]            [97/07/31]
 *  (10) Move VAR rmess to comdis97.pas                             [97/07/31]
 *  (11) errseq[12] wind dir stuck set to alarm=1 dialout=7         [97/08/04]
 *  (12) type pittman: replace m-parameter by m1 and m2             [97/08/05]
 *
 * Version:     27
 * Date:        September-October 1997
 * Changes:
 *   (1) Add var wdstuck (rather like pverr and conterr)            [97/09/25]
 *   (2) Take out specific errseq[][] initialization; now in .CFG.  [97/09/27]
 *   (3) Add var watchdog_debug and initialize as FALSE; see RIV.PAS[97/09/28]
 *   (4) Begin adding global boolean vars that indicate the current [97/10/01]
 *       "in screen" even for those pages not now being actively
 *       updated.  Use will require close coordination of tinter()
 *       and the procedure that writes the static screen.  This is a
 *       very kludgy way to do this, but I do not see anyway out given
 *       the 80x86 CodeSegment problem and the size of COMP.  First
 *       var defined and initialized here will be 'page_alarm_1'.
 *   (5) fumisav[]:boolean -- saves value of fumigation_enabled[]   [97/10/23]
 *
 * Version:     28
 * Date:        December 1997
 * Changes:
 *   (1) Becomes COMD98; update Uses.                               [97/12/23]
 *   (2) Remove lobyte, hibyte from dataflow_rec typedef.           [97/12/24]
 *   (3) Replace occurence of agc1hr by agc5m.                      [97/12/29]
 *   (4) Replace logrec97, etc. by logrec98.                        [97/12/29]
 *   (5) Replace gcgrab, gc1min, gcambi, gctarget by                [97/12/29]
 *         igcgrab, igc1min, igccntl, igcset.                       [97/12/29]
 *   (6) Replace 'gcont' substring by 'gcgrab' in variable names    [97/12/29]
 *         gcont, gcont_underflow, sgcont. (Not agcont, agcontp.)   [97/12/29]
 *   (7) Replace gcamb by gccntl and gcambi.                        [97/12/29]
 *   (8) Replace airtemp, encltemp by temp1, temp2[].               [97/12/30]
 *   (9) Add 'range' to type 'daqc_addr'.                           [97/12/31]
 *  (10) Add day-of-year 'doy' global var daqc_addr'.               [98/01/01]
 *  (11) Completely change contents of type pittman.flow_meter.     [98/01/03]
 *  (12) Begin new CONST section for mathematical & physical consts.[98/01/04]
 *  (13) Put pv_motor[] on heap as pv_motor_ray, pv_motor^[].       [98/01/04]
 *  (14) Change t_unit..pipe_type in VALV from Byte to INTEGER      [98/02/09]
 *  (15) Add physical constant atm_inHg = 29.92                     [98/02/11]
 *  (14) Change t_unit..pipe_type in VALV back to Byte!             [98/02/15]
 *
 * Version:     29
 * Date:        April-May 1998
 * Changes:
 *   (1) dataflow_var[,1..12].  Twelfth is ambient concentration.   [98/04/29]
 *   (2) encl_temp_alarm_set[ring].  New variable.                  [98/05/30]
 *
 * Version:     30
 * Date:        July-December 1998
 * Changes:
 *   (1) temp3[] added to temp1 & temp2 for AZ2 slaved cntl encls.  [98/07/29]
 *   (2) dataflow_var[,1..15].  13th is "auxiliary temperature".    [98/08/01]
 *   (3) temp_auxiliary.  New item in type list_addr.               [98/08/01]
 *   (4) Change back to 6 maxrings; DATA Segment now xFD7C.         [98/09/05]
 *   (5) Define type ambmp_hardware_rec for ambient multiport.      [98/10/25]
 *   (6) Define var ambmp_hardware_var^ for ambient multiport.      [98/10/25]
 *   (7) Define var ambmp_def_file      for ambient multiport.      [98/10/25]
 *   (8) Define net_logg_type, var net_logg ^, and allocate.        [98/11/21]
 *   (9) In net_logg_type change loggn type to TEXT.                [98/12/03]
 *
 * Version:     31
 * Date:        1999
 * Changes:
 *   (1) Uses faced99 (instead of 98).                              [99/01/15]
 *   (2) Declare mp_net[] for multiport linking using network files [99/01/28]
 *   (3) Declare disprecord_type array [] of displayrecord          [99/01/28]
 *       Redeclare disprecord var as pointer to above type          [99/01/28]
 *       Allocate instance of disprecord on heap                    [99/01/28]
 *       All this to free up about 3336h of DATA SEGMENT!
 *   (4) TYPE net_file to be used by logg & mplink net files        [99/01/28]
 *   (5) Declare tmplink and tmplinklast                            [99/01/28]
 *   (6) Declare super_switch (see comp/kbin; toggled by ctrl-j)    [99/05/15]
 *   (7) Init ambmp_hardware_var^.number_nodes := -1 (WI O3 prob!)  [99/06/03]
 *   (8) VAR ambmp_def_file deleted.                                [99/06/08]
 *   (9) Fields cfg_file_name, cfg_file_handle added to ambmp rec.  [99/06/08]
 *  (10) Field device replaced by device_c, _f, and _d.             [99/06/08]
 *  (11) Init of number_nodes replaced by enable=FALSE & _name=NONE [99/06/08]
 *  (12) node ARRAY [1..31] replaced by [0..15].                    [99/06/17]
 *  (13) daqc_addr: invert: BOOLEAN added to digital nature of type [99/06/25]
 *  (14) Delete *wcl* variables of the original WCL ambient mp.     [99/07/13]
 *  (15) Delete initialization of *wcl* variables.                  [99/07/13]
 *  (16) Rename wd as wd_port, add vars wd_pp and wd_init.          [99/08/04]
 *  (17) New var alarm_debug: boolean and init as false.            [99/09/04]
 *  (18) Change maxrings from 6 to 7.                               [99/11/13]
 *  (19) Change sw: ARRAY [1..28] to [1..40]                        [99/11/13]
 *  (20) ambmp_hardware_rec, ambmp_hardware_var, NEW() removed!!!   [99/11/14]
 *
 * Version:     32
 * Date:        1999-2000
 * Changes:
 *   (1) Unit name changed to '99.                                  [99/12/13]
 *   (2) IFDEF DELPHI will involke  $H-.                            [00/01/19]
 *   (3) Initialization: remove statscr=TRUE (see main's loop).     [00/02/14]
 *   (4) Replace logrec98, etc. by logrec99.                        [00/03/03]
 *   (5) daqc_addr: (included by pittman) INTEGER --> SmallInt      [00/03/06]
 *   (6) pittman: IF DELPHI INTEGER --> SmallInt (re VALV.SET size) [00/03/06]
 *   (7) IFDEF DELPHI maxrings = 15                                 [00/03/15]
 *   (8) Change sw: ARRAY [1..40] to [1..96]                        [00/03/16]
 *   (9) Change loggf, varrf, statf ARRAY [1..70] to [1..160]       [00/03/16]
 *  (10) TYPE net_file: add fields lasterr and lastdt.              [00/03/17]
 *  (11) fkey: change from array of INTEGER to Byte.                [00/03/20]
 *  (12) Change sw: ARRAY [1..96] to [1..7*maxrings]                [00/05/08]
 *  (13) Change 16-bit maxrings from 7 to 6                         [00/05/08]
 *  (14) Add needs_reset boolean to status_rec for latched          [00/09/07]
 *  (15) Delete usa: BOOLEAN                                        [00-10-12]
 *  (16) progload_date[8] --> [10]                                  [00-10-12]
 *
 * Version:     33
 * Date:        2001
 * Changes:
 *   (1) TYPE snapshot_rec: INTEGER --> IFDEF DELPHI SmallInt       [01-05-12]
 *   (2) TYPE daqc_port: protocol[8] --> [32]                       [01-09-19]
 *
 * Version:     34
 * Date:        2002
 * Changes:
 *   (1) Unit renamed comd                                          [02-03-21]
 *   (2) Uses faced99 changed to Uses faced                         [02-03-21]
 *   (3) $IFDEF TURBO code $ENDIF deleted                           [02-03-22]
 *   (4) $IFDEF DELPHI $ENDIF bracketing removed                    [02-03-22]
 *   (5) Add conditional_state[r][i]: BOOLEAN similar to _value     [02-03-25]
 *   (6) Status word documentation updated                          [02-03-25]
 *   (7) Initialization: set conditional_state[][] TRUE             [02-03-26]
 *   (8) net_file.filename: change String[26]; to String;           [02-05-14]
 *   (9) filename, crefilename: OF String[18]; to String;           [02-05-14]
 *  (10) loggback,..,motoback: OF String[26]; to String;            [02-05-14]
 *  (11) filnam, comm: OF OF String[20]; to String;                 [02-05-14]
 *  (12) add message_beep_code: Word (for Windows.MessageBeep)      [02-07-08]
 *  (13) a change made but then negated                             [02-09-15]
 *  (14) remove identifiers related to watchdog                     [02-12-02]
 *  (15) remove ?horizont (and others below STAT file related)      [02-12-17]
 *  (16) remove ldev*, dev*, var*, std* (* = , 1m, 1hr)             [02-12-17]
 *  (17) remove dncounts and hncounts                               [02-12-17]
 *  (18) remove all stat* statistics file related types and vars    [02-12-17]
 *  (19) AlarmMsgGet, err* type and vars moved to Alarms            [02-12-17]
 *
 * Version:     34
 * Date:        2003
 * Changes:
 *   (1) Type float changed to class TLPF for these [ring] vars:    [03-01-05]
 *         awcos, awsin, cos_mp3, sin_mp3, agcont, agc1m, agc5m,
 *         gc_mp3s, proplearn, windlearn, awspeed, ws_mp3s,
 *         axwdir, wdirvar, stdwdir, pverr, conterr, wdstuck
 *   (2) amb_base_int: changed to ambient_base: TLPF & instanced    [03-01-05]
 *   (3) conditional_value[][] changed to TLPF and instantiated     [03-01-05]
 *   (4) conditional_value[][].Name -- correct INITIALIZATION error [03-01-06]
 *   (5) agcontp renamed agcontsave                                 [03-01-06]
 *   (6) axwdir & wdirvar removed -- not being used                 [03-01-06]
 *   (7) Initialization: change conditional_state = TRUE to FALSE   [03-01-07]
 *   (8) Change displayrecord = from displrec99 to displrec32       [03-01-07]
 *   (9) Delete ephemeris_show BOOLEAN                              [03-03-17]
 *  (10) new_sample[ring]: deleted; used only by old h2ovapor()     [03-05-26]
 *  (11) h2ovapor_show, h2ovapor_auto: delete                       [03-05-26]
 *  (12) Begin moving stuff to new unit Globals.pas                 [03-05-28]
 *  (13) Move RingColor* functions to RingBar.pas                   [03-05-28]
 *  (14) Move "shut" related material to ExitSeq                    [03-05-31]
 *  (15) Move network logging related material to NetLog            [03-05-31]
 *  (16) Remove dobackup: BOOLEAN                                   [03-06-07]
 *  (17) Move logg .. motob arrays to Globals.pas                   [03-06-08]
 *  (18) Move loggrecord .. disprecord to Globals.pas               [03-06-08]
 *  (19) Delete loggfiletype .. dispfiletype                        [03-06-08]
 *  (20) Move types/var pittman, pv_motor_ray, pv_motor also        [03-06-08]
 *  (21) Move type daqc_addr to Globals.pas                         [03-06-08]
 *  (22) Move type logrec et al. to Globals.pas                     [03-06-08]
 *  (23) Move back?, recnum[,], sfil[,] to Globals                  [03-06-08]
 *  (24) Initialization: move TLPF.Name sets to COMS/lpf_constants  [03-06-15]
 *
 * Version:     35
 * Date:        2004
 * Changes:
 *  (1) Initialization: add num_conditionals := 4; (from COMP)      [04-02-29]
 *
 * Version:     36
 * Date:        2006
 * Changes:
 *  (1) Interface Uses: replace tp5utils by AVSD;                   [06-04-30]
 *  (2) Initialization: initialize wspeed_avsd[]                    [06-04-30]
 *
 * Version:     37
 * Date:        2009
 * Changes:
 *  (1) Delete type daqc_addr -- now see DataComm.Ports[]           [09-08-10]
 *  (2) Delete const num_mp_links                                   [09-08-10]
 *  (3) Change mp_net[] from array to scalar                        [09-08-10]
 *  (4) Delete modem, gas_supply, and timeserv daqc_port declares   [09-08-10]
 *
 * Version:     38
 * Date:        2011
 * Changes:
 *  (1) list_addr: add analog element "vvp_pressure"              [2011-09-23]
 *  (2) dataflow_var[14]: change from "not assigned" to "Pvvp"    [2011-09-23]
 *  (3) Pvvp[ring]: new float var (like solrad[ring], etc.)       [2011-09-23]
 *  (4) super_switch: delete all references                       [2011-09-23]
 *  (5) vvpfailsafe[]: now groups of 8 valves instead of 16       [2011-10-18]
 *  (6) vvpfailsafe[]: now Integer (was Word) [range err problem] [2011-10-18]
 *  (7) Delete types str4, str30, and str80 -- not much used      [2011-10-18]
 *
 * Version:     39
 * Date:        2012
 * Changes:
 *  (1) Remove variables mp3s_ring, mp3s_debug, mp3s_tsamp        [2012-07-13]
 *  (2) Remove gc_mp3s ws_ cos_ sin_ :TLPF & wd_mp3s :float       [2012-07-13]
 *  (3) Declare rmplink (ring seq no) used by comp/multiport      [2012-07-16]
 *  (4) Remove record type net_file - only used for mp_net        [2012-07-23]
 *  (5) Remove var mp_net - functionality replaced by DataComm    [2012-07-23]
 *  (6) Add CONST maxfcplink = 9 and VAR tfcplinklast[]           [2012-08-01]
 *  (7) Change CONST maxfcplink from 9 to 4                       [2012-08-22]
 *  (8) Add CONST maxlogger = 1                                   [2012-08-23]
 *  (9) dataflow_var[15]: change from "*** not assigned ***" to   [2012-08-24]
 *      "ambient base value"
 * (10) list_addr: add analog element "ambient_base_value"        [2012-08-24]
 * (11) AmbientBaseValue[]: new float var (like Pvvp[], etc.)     [2012-08-24]
 *}

INTERFACE

USES 
  SysUtils,
  UtilObjs,
  faced, AVSD,
  Globals;

CONST

  fkey: ARRAY [0..12] OF Byte = (58,59,60,61,62,63,64,65,66,67,68,69,70);

  histbins = 20; {number of bins in each histogram}
  gcbands  = 3;  {number of deviation bands, e.g., 2%, 10%}

  clipon  = TRUE;
  clipoff = FALSE;

TYPE
  float = Single;  {IEEE 4-byte representation}

  ring_range  = 1..maxrings;
  valv_range  = 1..maxvalvs;

  swindow = RECORD
    x,y,lx,ly,col1,col2,ls: INTEGER;
    m: float;
    mess: String[30];
    END;

  dataflow_rec = RECORD               {added 12/14/92}
                   digital: INTEGER;  {assuming only 12-bit}
                   volts,
                   value:   float;
                   END;

  list_addr = RECORD         {analog channels associated with 'ringdaqc'}
      conc_fumi,               {[gas] fumigation ring}
      conc_cont,               {[gas] control ring}
      conc_ambi,               {[gas] remote amient}
      wind_speed,
      wind_direction,
      pv_response,
      pv_control,
      temp_atmosphere,
      temp_enclosure,
      temp_auxiliary,
      pressure_atmosphere,
      solar_radiation,
      water_vapor,
      vvp_pressure,
      ambient_base_value,
      vvp_open_fumi,         {digital channels}
      vvp_open_cont,           {used with slaved control rings}
      vvp_close,               {currently used only in AZ}
      fan_onoff_fumi,
      fan_onoff_cont,          {used with slaved control rings}
      fan_rotation_fumi,
      fan_rotation_cont,       {used with slaved control rings}
      gas_shutoff,             {e.g., output to CO2 quarter turn valve}
      gas_pressure,            {e.g., CO2 supply line at a ring}
      ps01,                    {power supply monitors}
      ps02,
      ps03,
      ps04,
      irga_zero,               {for remote controlled calibrations}
      irga_span
        : daqc_addr;
      END;

  qtrec = RECORD  {for delay of quarter turn valve change}
    asked, state: BOOLEAN;
    delay, lastchange: float;
    END;

  vvprec = RECORD        {for periodic refresh of vvp valve state}
    period,              {maximum period in seconds}
    lastchange: float;   {last time valves changed or were refreshed}
    newpattern, needsrefresh:  BOOLEAN;
    rrrr_old, rrrr_new: String[maxvalvs];
    msg: String[2];
    END;

  status_rec = RECORD
                 current,
                 latched: Word;
                 needs_reset: BOOLEAN;
                 END;

    {Contents as of 03/02/94
     bit 0-2: ring number
           3: enrich_mode   0=absolute   1=differential
           4: runon
           5: debug
           6: calibration_active  (manual OR automatic)
           7: calibration_enable  (manual ONLY)
           8: prop valve alarm
           9: CO2 concen alarm
          10: communications error
          11:
          12: gc underflow
          13:
          14:
          15:

     Contents as of 01/01/96, amended 10/20/97
     bit 0-3: ring number   1..15 (0000 not used)
         4-5: enrich_mode  0=constant  1=additive  2=multiplicative  3=profile
           6: NOT conditional_ok      (wind speed, PAR, temperature, etc.)
           7: NOT fumigation_enabled  (by clock, by solar altitude, etc.)
           8: debugging on
           9: (not used)
          10: calibration_active  (manual OR automatic)
          11: calibration_enable  (manual ONLY)
          12: alarm: proportional valve
          13: alarm: gas concentration 
          14: error: communications
          15: (not used)

     Contents as of 2002-03-25 (only bits 9 and 15 changed)
     bit 0-3: ring number   1..15 (0000 not used)
         4-5: enrich_mode  0=constant  1=additive  2=multiplicative  3=profile
           6: NOT conditional_ok      (wind speed, PAR, temperature, etc.)
           7: NOT fumigation_enabled  (by clock, by solar altitude, etc.)
           8: debugging on
           9: NOT conditional_state[][3] -- highest temperature
          10: calibration_active  (manual OR automatic)
          11: calibration_enable  (manual ONLY)
          12: alarm: proportional valve
          13: alarm: gas concentration 
          14: error: communications
          15: NOT conditional_state[][4] -- lowest windspeed
          }
  
  hisarray = ARRAY[ring_range,1..histbins] OF Longint;

  conditional_var_type = ARRAY [ring_range] OF conditional_set;

  loggf = ARRAY[1..160] OF logrec;
  varrf = ARRAY[1..160] OF varrec;

  loggptr = ^loggf;
  varrptr = ^varrf;

VAR
  ior: INTEGER;  {for saving IOResult}

  matr, pattern_windlow, pattern_runoff: String;
  vvpfailsafe: ARRAY [0..(maxvalvs DIV 8)-1] OF Integer;  
    {valve normally closed[0] or open[1] pattern}

  loggfile: loggptr;
  varrfile: varrptr;

VAR  
  sw: ARRAY [1..7*maxrings] OF swindow;
  ckol,crow: INTEGER;
  houron,houroff,minon,minoff,
    timeon,timeoff: ARRAY[ring_range] OF INTEGER;
  loggpoint,varrpoint: ARRAY[ring_range] OF INTEGER;
  loggcount: ARRAY[ring_range] OF INTEGER;
  limit, adif, rtime: ARRAY[ring_range] OF float;
  tint, tintlast, tlast: float;

{Used for comp/multiport calls (sending file data to other programs)}
  rmplink: INTEGER;
  tmplink, tmplinklast: float;

{Used for data logger LineIn calls (getting ASCII string data)}
CONST maxlogger = 1;

{Used for FCPLink LineIn calls (getting file data from other FCP's)}
CONST maxfcplink = 4;
VAR   tfcplinklast: ARRAY [1..maxfcplink] OF float;

VAR
  tsamp, tsamplast, tcont, tcontlast: ARRAY[ring_range] OF float;
  lttime, gcgrab, agcontsave, gcerr, agcerr, wspeed,
    propc: ARRAY[ring_range] OF float;
  gcgrab_underflow: ARRAY [ring_range] OF BOOLEAN;
  gccntl, gcambi,
    temp1, temp2, temp3,
    airpres, solrad, ph2o,
    Pvvp, AmbientBaseValue: ARRAY [ring_range] OF float;
  amb_base_grab: float;
  ambient_base: TLPF;
  amb_in_default: BOOLEAN;
  wwdir: ARRAY[ring_range] OF INTEGER;

  message_beep_code: Word;

  falarm, calarm,
    windthr,
    cinteg, cprop, cdiff, cwind, cwindprop,
    ainteg, aprop, adiff, awind,
    pidfactor, pidfactormin, pidfactormax,
    ainteg_adj, aprop_adj, adiff_adj: ARRAY[ring_range] OF float;
  encl_temp_alarm_set: ARRAY[ring_range] OF float;
  awinddir: ARRAY[ring_range] OF float;
  gcint,wsint,wdint,tlearn,preset,agc20s,gcset,
    winddir, winddirsave: ARRAY[ring_range] OF float;
  gc5p,gc10p,gc20p,agc1m5p,agc1m10p,agc1m20p,agc1hr1p,
    agc1hr2p,agc1hr5p: ARRAY[ring_range] OF float;
  windprop: ARRAY[ring_range] OF float;
  ncount: ARRAY[ring_range] OF float;
  pr1,pr2,pr5,pr10,pr20: ARRAY[ring_range] OF float;
  logglen, varrlen: ARRAY[ring_range] OF Longint;
  lvalue: Longint;
  dishour,curpos: float;
  tf1last, tf2last, tf3last, rvalue: float;
  propresp: ARRAY[ring_range] of float;
  col,row,keyal,keyah: INTEGER;
  timestep: ARRAY[1..3] of float;  {one for each data file}
  len: ARRAY[ring_range,1..5] of Longint;
  rval: ARRAY[ring_range,1..5] of INTEGER;
  inext,disrec,slen,bufsize,ifi,ihor,ahset,
    ir,irpos: INTEGER;
  histo: ARRAY[ring_range] OF INTEGER;
  rn: ARRAY[ring_range] OF array[1..6] OF INTEGER;
  iring,nno,no: INTEGER;
  ifire,fanrelay,rsel: INTEGER;
  hsel,psel,wsel: ARRAY[ring_range] OF INTEGER;
  xwind, ywind: ARRAY[ring_range] OF INTEGER;
  hisi,hism,hish: hisarray;
  hisimax,hismmax,hishmax: ARRAY[ring_range] OF Longint;
  ascfile:text{[$400]};
  s: String;
  sgcgrab, spropc, spropresp, swwdir,
    swspeed: ARRAY[ring_range] OF String[5];
  filename,crefilename: ARRAY[ring_range] OF String;
  cvalue,ans,s1: String[1];
  s2: String[2];
  st1,st2,st3,st4,st5,st6,st7,st8,st9,st10,st11,st12,st13,st14,
     st15,st16,st17,st18,st19,st20: String[12];
  ring: ARRAY[ring_range] OF String[maxvalvs];
  awwdir: ARRAY[ring_range] OF String[4];
  filnam, comm: ARRAY[ring_range] OF ARRAY[1..6] OF String;
  loggback, varrback,
    parrback, dispback, motoback: ARRAY[ring_range] OF String;
  name: String[10];
  doy, year, month, day,
  hour, minute, second: INTEGER;
  date, time: String;
  progload_date: String[10];  progload_time: String[8];
  line60: String[60];
  windup,winddown,loggend,varrend,
    parrend: ARRAY[ring_range] OF BOOLEAN;
  run_mode, simul_mode, archive_mode: BOOLEAN;
  fan, setdefine, endpro, newdata, sperry, background,
    binary, ascii, fileend: BOOLEAN;
  statscr, inrings: BOOLEAN;
  doinitialize, doexamine, doprint, docreate, 
    action, update, doexit, dochange: BOOLEAN;
  netpath:  String;
  loggop, varrop, parrop, genlop, snapop: BOOLEAN;
  idataput,dataput,loggput,varrput,loggwrite,
    varrwrite: ARRAY[ring_range] OF BOOLEAN;
  firstpas: BOOLEAN;
  runon, runsave, fumigation_enabled, fumisave,
    conditional_enabled, conditional_ok,
    oper, debug, faceraw_switch,
    fan_debug_set, gas_debug_set: ARRAY [ring_range] OF BOOLEAN;
  num_conditionals: 1..max_conditionals;
  conditional_var: ^conditional_var_type;
  conditional_value:
    ARRAY [ring_range] OF ARRAY [1..max_conditionals] OF TLPF;
  conditional_state:
    ARRAY [ring_range] OF ARRAY [1..max_conditionals] OF BOOLEAN;
  enrich_mode, onoff_mode: ARRAY [ring_range] OF INTEGER;
  enrich_val: ARRAY [ring_range] OF ARRAY [0..3] OF float;
  enrich_base: ARRAY [ring_range] OF base_rec;
  stimeon, stimeoff: ARRAY [ring_range] OF String[5];
  solar_ton, solar_toff: ARRAY [ring_range] OF String[6];
  dawn_altitude: ARRAY [ring_range] OF float; {degrees}
  vact,vnoact: ARRAY [ring_range, valv_range] OF BOOLEAN;
  sacceptactive: BOOLEAN;
  ahr,alr: Byte;
  calr,cahr: CHAR;
  r: ARRAY [ring_range,1..6] OF String[8];
  svalue,path: String[30];
  gcband: ARRAY [1..gcbands] of float;  {deviation band values}
  overband: ARRAY [1..gcbands] of float;  {amount outside bands}

  {These are low pass filter declarations go here -- see INITIALIZATION also}
  awcos, awsin, 
  proplearn, windlearn,
  agcont, agc1m, agc5m,
  awspeed, stdwdir,
  pverr, conterr, wdstuck: 
    ARRAY[ring_range] OF TLPF;

  wspeed_avsd: ARRAY [ring_range] OF avsd_rec;

  comm_err: ARRAY [ring_range] OF BOOLEAN;

  list_addr_ptr: ARRAY [ring_range] OF ^list_addr;

  digital_in_fumi,
  digital_in_cntl: ARRAY [ring_range] OF Word;

  co2qt: ARRAY [ring_range] OF qtrec;  {e.g., CO2 quarter turn valves}

  vvptime: ARRAY [ring_range] OF vvprec;  {vvp valve refresh information}

  calibrate_param: RECORD
                     llimit, ulimit: RECORD  {umol mol-1 bands}
                       low, high: Longint;
                       END;
                     period: Longint;        {minutes}
                     END;

  calibrate_var: ARRAY [ring_range] OF RECORD  {manual}
                                    enable,            {if enabled}
                                    active,            {if out-of-range}
                                    forceon: BOOLEAN;  {debugging}
                                    timeon,
                                    timeoff,
                                    forcevalue: float; {debugging}
                                    llimit, ulimit: RECORD  {bands}
                                      low, high: INTEGER;
                                      END;
                                    END;

  calibrate_msg: ARRAY [ring_range] OF RECORD
                                    message: String;
                                    color: Byte;      {if out-of-range}
                                    END;

  dataflow_var: ARRAY [ring_range, 1..15] OF dataflow_rec;
    { 1: treatment gas concentration
      2: control gas concentration
      3: temp1 (air temperature)
      4: air pressure
      5: wind speed
      6: wind direction
      7: solar radiation
      8: proportional valve control
      9: proportional valve response
     10: temp2 (enclosure temperature)
     11: air water vapor partial pressure
     12: ambient gas concentration
     13: temp3 (auxiliary temperature, slaved control enclosure temperature)
     14: vvp manifold pressure
     15: ambient base value
     }
  dataflow_key: INTEGER;
  dataflow_show: BOOLEAN;

  h2ovapor_show, h2ovapor_auto: BOOLEAN;

  status_var: ARRAY [ring_range] OF status_rec;

  {Variables used previously only by DAT program}
  nocount, ggcsetp,
  average1, average2, average3,
  over20, over10, over2: float;
  nav, pro: ARRAY [1..3] OF INTEGER;
  wsortlow, wsorthigh: float;
  dsortlow, dsorthigh: INTEGER;
  ttsortlow, ttsorthigh, tsortlow, tsorthigh: String[8];
  xcute, dsort, tsort, wsort, disrecords, ddone: BOOLEAN;

{For circulating buffer snapshot graphics}
CONST snapshot_max = 240;      {maximum number of screens per ring}
TYPE  snapshot_rec = RECORD
        zeit: String[8];
        igcgrab, igc1min, igccntl,
        propctl, proprsp,
        windspd, winddir,
        kinteg, kprop, kwind,
        igcset
        : SmallInt;  {16 bits}
        END;
      snapshot_screen = ARRAY [1..180] OF snapshot_rec;
      snapshot_ptr    = ^snapshot_screen;
      snapshot_table  = ARRAY [1..maxrings] OF 
                          ARRAY [1..snapshot_max] OF snapshot_ptr;
VAR   snapshot_size: INTEGER;  {number of screens to save; set in COMyy}
      snapshot_show,            {screen number being displayed}
      snapshot_fill,            {screen number being filled}
      snapshot_index: INTEGER;  {last event in screen filled}
      snapshot_toggle: BOOLEAN; {used to select every other sample}
      snapshot_ray: ^snapshot_table;

{$H+}
FUNCTION DebugMsgGet (ring: INTEGER): String;
FUNCTION CommErrMsgGet (ring: INTEGER): String;
{$H-}

Implementation

VAR i, j, k: INTEGER;

{$H+}

FUNCTION DebugMsgGet (ring: INTEGER): String;
BEGIN
  IF debug[ring] THEN DebugMsgGet := 'Debug mode  ';
  END;  {function 'DebugMsgGet'}

FUNCTION CommErrMsgGet (ring: INTEGER): String;
BEGIN
  IF comm_err[ring] THEN CommErrMsgGet := 'Communications error  ';
  END;  {function 'CommErrMsgGet'}
{$H-}

Initialization

BEGIN
  
  inrings := FALSE;

  ambient_base := TLPF.Create;
  ambient_base.Name := 'Ambient base concentration';

  FOR i := 1 TO maxrings DO BEGIN
    awcos    [i] := TLPF.Create;
    awsin    [i] := TLPF.Create; 
    proplearn[i] := TLPF.Create; 
    windlearn[i] := TLPF.Create;
    agcont   [i] := TLPF.Create; 
    agc1m    [i] := TLPF.Create; 
    agc5m    [i] := TLPF.Create;
    awspeed  [i] := TLPF.Create; 
    stdwdir  [i] := TLPF.Create;
    pverr    [i] := TLPF.Create; 
    conterr  [i] := TLPF.Create; 
    wdstuck  [i] := TLPF.Create; 
    END;

  FOR i := 1 TO maxrings DO BEGIN
    avsd_init (wspeed_avsd[i]);
    END;

  num_conditionals := 4;
  FOR i := 1 TO maxrings DO
  FOR j := 1 TO max_conditionals DO BEGIN
    conditional_value[i][j] := TLPF.Create;
    conditional_value[i][j].Name := 
      'Conditional fumigation -' + 
      ' RingSeq ' + IntToStr(i) +
      ' CondNr ' + IntToStr(j);
    conditional_state[i][j] := FALSE;
    END;
  
  NEW (conditional_var);
  END;

Finalization

BEGIN
  END;

{of unit 'comd.pas'...}
END.
