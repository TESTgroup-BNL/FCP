{$L-}
{$R+}    {Range checking on}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N+}    {Numeric coprocessor}
{$H-}

{      Program for controlling multiple gas enrichment systems }

PROGRAM fcp;

USES
{$IFDEF LINUX}
  QControls, QForms,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Controls, Forms,
  Windows,
{$ENDIF}
  SysUtils, 
  Main, EventLog, Alarms, Connect, DataComm, NetLog, Watchdog,
  FatalErr, LblForm,
  crt32,  {***TEMPORARY***}
  Services, Globals,
  faced, comd, comu, coms, comp, comin, comdis,
  riv, MPSample, optomux, debuglog;

{*
 * Name   :  COMyy.PAS
 *
 * Purpose:  BNL FACE Project
 *           On-line data acquistion, control, and monitoring
 *           Main program
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
 *   (5) Add parscomm() procedure to select on-line running
 *       or simulated output.
 *   (6) Append "S" to names of files generated while in simulation.
 *
 * Version:     3
 * Date:        07-18-90, 07-23-90, 07-23-90
 *                        (cleaned up and ppmperv/voffset changes)
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Added bootup setting of variables ppmperv[] amd voffset[]
 *   (2) Temporary argument option 'analyzer' added to
 *       procedure 'parscomm'.
 *
 * Version:     4
 * Date:        11-06-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Removed redundant assignments of grdriver & grmode
 *       (see GRAyy.PAS, PROCEDURE screen;)
 *   (2) Improved user tolerance of simulation query
 *       in 'parscomm'.  Added local procedure 'usage'.
 *   (3) Protected program from no inserted disk in 'datlog'.
 *   (4) Define gas concentration performance bands
 *       at beginning of body.
 *   (5) Made default window select histogram type,
 *       rather than (very dangerous) operating mode.
 *   (6) Replace use of "sline" by ClrEol in 'datlog'.
 *
 * Version:     5
 * Date:        April 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Added $E- directive (do not include emulation code)
 *   (2) Removed "analyzer" command-line option.
 *   (3) Wrote procedure 'config'.
 *
 * Version:     6
 * Date:        May 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Added call to 'errclear' at start-up.
 *   (2) Added <F10> to status screen to clear ring error(s).
 *   (3) Initialize 'co2qt' records.
 *   (4) Add watchdog parameters to configuration file.
 *   (5) Using boolean var 'all', provide ability to backup
 *         all files associated with a ring in proc 'datlog'
 *
 * Version:     7
 * Date:        February/March 1992
 * Programmer:  J. Nagy
 * Changes:     Incorporate DAT functionality as COM ARCHIVE
 *   (1) Replace Intr($10, function 6 calls by scrollup();
     (2) Change clwindow(7,1,25,80) to (7,0,24,79).
 *   (3) parscomm;
 *      (a) remove argument
 *      (b) set global run_mode, simul_mode, or archive_mode
 *   (4) Move procedure datlog(); to its own unit.
 *       Add comlog92 to uses list.
 *
 * Version:     8
 * Date:        November/December 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Read backpath[ring] from configuration file.
 *   (2) Main menu <F1> key now calls up utility menu.
 *   (3) Look only in current drive/directory for FACE.CFG
 *
 * Version:     9
 * Date:        January 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Initialize dataflow_show to false; had forgotten to!
 *   (2) Hidden menu option 'f' to call ppm_force() for calibration mode
 *       debugging.  Available only in simulation.  1/5/92
 *   (3) For calibration mode, use lower and upper limit bands.  1/26/92
 *
 * Version:     10
 * Date:        April/May/June 1993 -- changes related to Opto22 DAQC
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add ring number argument to procedure relinit;  (4/12/93)
 *   (2) Add misc di/o bit inputs for +5, +12, +-15V PSs (4/28/93)
 *   (3) Add misc di/o bit outputs for IRGA zero and span control (5/26/93)
 *   (4) Add Ctrl-Alt-F10 to main (status) menu to invoke exit sequence (6/1)
 *   (5) Initialize autocalibration variables.  CHANGES NOT SAVED TO DISK (6/6)
 *   (6) Expand calibration procedure to include autocalibration.
 *   (7) Modify config() to read/show addr & chan for bus devices. (6/27/93)
 *
 * Version:     11
 * Date:        July/August 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add filling of optomux_ports records by config/get_port routine. 
         This required a Use optomux.  [7/16]
 *
 * Version:     12
 * Date:        September/October 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Now initializing *_mp3s ring ARRAYS, rather than scalars.  [93/09/09]
 *   (2) mp3s_tsamp integration time hard wired at 60s (was 10s).   [93/10/22]
 *   (3) Now change mp3s_tsamp to 15s for 1994 Arizona run.         [94/04/12]
 *
 * Version:     13
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as COM94.                                       [93/12/10]
 *   (2) config(): put in KLUDGE to make data i/o work in AZ.      [93/12/11]
 *                 IF ringdaqc.port = 0 THEN port := base; !!!
 *   (3) config(): read site_lat, _lon, _alt, _zd.                 [93/12/12]
 *   (4) shutdown(): change delay from 3 to 5 seconds so that      [93/12/16]
 *                   AZ quarter turn valves will shut off.
 *                   (Doghouse multiplexor relay still stays on.)
 *   (5) config(): compute site_lat_sin, site_lat_cos, site_lag    [93/12/12]
 *
 * Version:     14
 * Date:        January 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) config(): compute usa switch from site_id                 [94/01/06]
 *   (2) config(): call helios_site() instead of v13 #5 above      [94/01/10]
 *
 * Version:     15
 * Date:        March 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) parscomm: second (optional) argument is configuration file [94/03/08]
 *   (2) config(): now gets configuration file name from parscomm;  [94/03/08]
 *
 * Version:     16
 * Date:        May/June 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) config: read in array of possible mp daqc link params      [94/05/02]
 *   (2) Now change mp3s_tsamp to 60s for May 1994 Zuerich run.     [94/05/02]
 *   (3) Add call to reldisc; to exit_sequence.                     [94/05/31]
 *   (4) For gcband #1, replace 0.02 by 0.2 (see also COMDIS).      [94/06/08]
 *   (5) config: read addr/chan of 1st PropValv Motor Relay.        [94/06/11]
 *   (6) utilmenu: add pv motor to menu; change some F-keys.        [94/06/11]
 *   (7) add once-only call to gasflow 'INIT'.                      [94/06/11]
 *   (8) config: show memory available                              [94/06/26]
 *   (9) add initialization code for snapshot graphics              [94/06/27]
 *
 * Version:     17
 * Date:        Feb-Mar 1995
 * Changes:
 *   (1) Becomes COM95.PAS                                          [95/02/21]
 *
 * Version:     18
 * Date:        June-July 1995
 * Changes:
 *   (1) snapshot stuff: bulletproof and multiple rings             [95/06/08]
 *   (2) config/show_*(): some variables now use rep_hex()          [95/06/14]
 *   (3) config/show_*(): display when program started              [95/06/29]
 *
 * Version:     19
 * Date:        Sep 1995
 * Changes:
 *   (1) config: change format of daqc lines of .cfg                [95/09/04]
 *   (2) Now uses cts_unit                                          [95/09/04]
 *   (3) Add procedure timeserv as next level in utilmenu           [95/09/04]
 *
 * Version:     20
 * Date:        Oct-Dec 1995, Jan 1996
 * Changes:
 *   (1) Becomes COM96; Uses updated                                [95/10/14]
 *   (2) RingView pattern now read in by config().                  [95/10/15]
 *   (3) 'numvalvs' now not necessarily divisible by 16.            [95/12/19]
 *   (4) The number of snapshot screens per array now 240 from 60.  [96/01/05]
 *
 * Version:     21
 * Date:        May-July 1996
 * Changes:
 *   (1) Add establishing of pv_motor save and backup filenames.    [96/05/29]
 *   (2) config: new "ring label" field on numrings line.           [96/06/22]
 *   (3) config: extensive changes for slave control ring concept   [96/07/01]
 *   (4) replace zeroing of misc_digital_in[] by new vars           [96/07/31]
 *         digital_in_fumi[] and digital_in_cntl[]
 *
 * Version:     22
 * Date:        Nov-Dec 1996
 * Changes:
 *   (1) parscomm: delete "are you sure" prompt if simulation.      [96/11/27]
 *   (2) parscomm: demo crippling statement (usually commented out) [96/11/27]
 *
 * Version:     23
 * Date:        Dec 1996 - Jan-Apr 1997
 * Changes:
 *   (1) Becomes COM97                                              [96/12/22]
 *   (2) Add numrings to argument lists of changering and clearhist [97/01/20]
 *   (3) Move procedure algor (parr file setting) here from comp97  [97/02/01]
 *   (4) config: add site_tz text as another field                  [97/04/10]
 *   (5) moto & motoback[] filenames changed from MOTOx. to VALVx.  [97/04/11]
 *   (6) Change occurences of CO2 to GAS where relevant.            [97/04/18]
 *   (7) Finish adding submenu feature to proc algorirthm;          [97/04/19]
 *   (8) Had to add faced97 to Uses to pick up max_conditionals.    [97/04/19]
 *   (9) Change mp3s_tsamp to 15s from 60s.                         [97/04/20]
 *
 * Version:     24
 * Date:        May-August 1997
 * Changes:
 *   (1) Switch from snapshot_ray (DS) to snapshot_ray^ (Heap)      [97/05/18]
 *   (2) config(): get unit_name, label_name, bdtype in daqc_rec    [97/07/08]
 *   (3) config(): allocate to heap the new daqc address lists      [97/07/08]
 *   (4) exit_sequence: clear comm_err upon ring dis-/reconnect     [97/07/10]
 *   (5) exit_sequence: fix overwriting by the 6'th ring's prompt   [97/07/20]
 *   (6) config: read in ring descriptor on the first specific line [97/07/31]
 *   (7) config: output descriptor on ring specific screens         [97/07/31]
 *   (8) algor: show the ring descriptor on pages                   [97/07/31]
 *   (9) exit_sequence: show descriptor on dis-/reconnect line      [97/08/02]
 *
 * Version:     25
 * Date:        September-October 1997
 * Changes:
 *   (1) config: added readin of errseq[][] lines #47               [97/09/27]
 *   (2) main: move init of statscr, inrings, ingraph to end of COMD[97/10/01]
 *   (3) algor(): for enrichment mode, add 4th option custom profile[97/10/20]
 *
 * Version:     26
 * Date:        December 1997
 * Changes:
 *   (1) Becomes COM98; update Uses.                                [97/12/23]
 *   (2) Remove one instance (r[no,5]=) of AZ1 specific code.       [97/12/23]
 *   (3) Remove initialization of lobyte, hibyte in dataflow_vars.  [97/12/24]
 *   (4) algor(): change eenrich_val := loop from 0..2 to 0..3      [97/12/29]
 *   (5) Replace gcgrab, gc1min, gcambi, gctarget -- see COMD98.    [97/12/29]
 *   (6) Change most occurences of substring gcont to gcgrab.       [97/12/29]
 *   (7) Replace gcamb[] by gccntl[], gcambi[].                     [97/12/29]
 *   (8) config(): read in new "range" field.                       [97/12/31]
 *   (9) Uses coms98 needed now to link to status();                [98/01/01]
 *  (10) Changes for confing (SHOW) to fit in range.                [98/01/04]
 *
 * Version:     27
 * Date:        1998
 * Changes:
 *   (1) I seem not to have commented many changes.                 [98/00/00]
 *   (2) PARR, DISP, VALV extensions become .SET (from .DAT)        [98/05/27]
 *   (3) Site specific bootup initialization of encl temp alarm val [98/05/30]
 *   (4) algor(): change terminology "Ring 1's" to "1st ring's"     [98/07/13]
 *   (5) Now must initialize 15 elements in data_flow.              [98/08/01]
 *   (6) config(): AZ2 ONLY - read in temp_auxiliary after temp_en..[98/08/01]
 *   (7) config(): Error message and halt if numrings > maxrings.   [98/09/06]
 *   (8) config()/get_addr(): allocation of LiCor records.          [98/09/24]
 *   (9) Add 'licor' to Uses list.                                  [98/09/25]
 *  (10) config()/get_addr(): add code for LiCor records.           [98/09/27]
 *  (11) exit_sequence(): add <F5>, <F6> for dis-, reconnect!       [98/10/24]
 *  (12) config(LOAD): read newpath on same line as datapath.       [98/11/21]
 *  (13) Construct full names and assign network LOGGing as .NET    [98/11/21]
 *  (14) Create empty *.NET if testing comes back "File not found"  [98/11/24]
 *  (15) Cancel #14.  Now being done by COMLOG buffer-by-buffer.    [98/12/03]
 *
 * Version:     28
 * Date:        1999
 * Changes:
 *   (1) Uses faced99 (rather than 98).                             [99/01/15]
 *   (2) Now change mp3s_tsamp back to 60s.                         [99/01/28]
 *   (3) Use new field names logging to net.                        [99/01/28]
 *   (4) Many changes related to WI&TN multiparameter custom profile[99/04/12]
 *   (5) Add netinfo to Uses list.                                  [99/04/21]
 *   (6) config: read in of optional net info file(s).              [99/04/21]
 *   (7) config: show netinfo stuff if there is any.                [99/04/21]
 *   (8) config: check for netinfo_installed if range code >= 900   [99/04/21]
 *   (9) config: for seq 9xx, use get_chunk(' ') & buffer[2] w/ "," [99/04/29]
 *  (10) parscomm: make cfgname upper case.                         [99/04/29]
 *  (11) config: mark netinfo files write_only if no sensor         [99/05/10]
 *  (12) config: NOT usa list includes CH1, PN1, DE1                [99/05/15]
 *  (13) config: must initialize var errcode to 0 in case no netinfo[99/05/18]
 *  (14) algor: for PARR file append, trap RESET i/o errors         [99/05/24]
 *  (15) config: add optional 800 line after 16 before any 900s.    [99/06/17]
 *  (16) config: move subprocs get_ show_ x _port _addr to COMS.    [99/06/19]
 *  (17) config: move subprocs test_key and check to COMS nonglobal.[99/06/19]
 *  (16) config: add "i, " to argument list of get_addr calls.      [99/06/19]
 *  (17) algor: change all occurences of Red to LightRed.           [99/06/25]
 *  (18) config/show: move <A>, <L>, etc. menu to first screen.     [99/07/12]
 *  (19) add conditional call to ambient_mp_init.                   [99/07/13]
 *  (20) add uses AMBMP.                                            [99/07/15]
 *
 * Version:     29
 * Date:        1999-2000
 * Changes:
 *   (1) Begin as COM99 (dual Turbo and Delphi)                     [99/12/13]
 *   (2) Changes Uses to pick up '99 units.                         [99/12/13]
 *   (3) main: global 'iautocalib' can not be used as loop index    [00/01/18]
 *   (4) IFNDEF TURBO don't use cts_unit.                           [00/01/18]
 *   (5) timeserv: IFNEF TURBO don't call cts_unit routines.        [00/01/19]
 *   (6) IFDEF DELPHI declare dummies MemAvail, MaxAvail, HeapError.[00/01/19]
 *   (7) main: Replace 'no' loops by 'rloop'.                       [00/01/19]
 *   (8) Declare rloop: INTEGER to be used as ring loop index.      [00/01/19]
 *   (9) Rename program and file COM99A.                            [00/01/19]
 *  (10) Uses Windows added.                                        [00/01/21]
 *  (11) main: AllocConsole, set title, and do crt32.init (DELPHI)  [00/01/21]
 *  (12) config: update call to netinfo_init & set stream TRUE 902  [00/01/25]
 *  (13) parscomm: Arguments optional.  Prompt user if missing.     [00/01/26]
 *                 Added local procs prompt_mode and prompt_cfg.    [00/01/26]
 *                 Usage message with halt no longer called.        [00/01/26]
 *  (14) config/SHOW: add <S> netinfo suspend writing toggle.       [00/01/27]
 *  (15) config/INIT: 902 stream=FALSE like any other file.         [00/01/30]
 *  (16) config/INIT: 902 stream=TRUE again, i.e. always open.      [00/01/31]
 *  (17) close_handler: new function returning TRUE.                [00/02/01]
 *  (18) main: for DELPHI add SetConsoleCtrlHandler call at BEGIN.  [00/02/01]
 *  (19) config/INIT: change to reflect changes in netinfo_init args[00/02/03]
 *  (20) Rename program and file COM99B -- will add graphics.       [00/02/14]
 *  (21) Main loop:  set statscr=TRUE before call to kbin.          [00/02/14]
 *  (22) move call to screen; to COMDIS99.                          [00/02/17]
 *  (23) remove Uses of gra99.                                      [00/02/17]
 *  (24) main: don't add S to simul mode DAT filename if id='XX1'   [00/03/07]
 *  (25) See v28 #2.  But mp3s_tsamp is still 15 !!!                [00/03/08]
 *  (26) Build 099.002.001 = Program.Version[=B].Build              [00/03/08]
 *  (27) Build 099.002.002                                          [00/03/08]
 *  (28) Build 099.002.003                                          [00/03/14]
 *  (29) Build 099.002.004                                          [00/03/15]
 *  (30) Build 099.002.005                                          [00/03/16]
 *  (31) Build 099.002.006                                          [00/03/17]
 *  (32) Build 099.002.007                                          [00/03/23]
 *  (33) Build 099.003.001  Program now COM99C.  Working on RIV.    [00/04/05]
 *  (34) Build 099.003.002  RIV working.                            [00/04/12]
 *  (35) Build 099.003.003  Graph window repaint working.           [00/04/18]
 *  (36) Build 099.004.001  Program now COM99D.  Working on mouse.  [00/04/19]
 *  (37) main: mouse aware (Win32 only).                            [00/04/20]
 *  (38) utilmenu: mouse aware (Win32 only).                        [00/04/21]
 *  (39) config/show: mouse aware (Win32 only).                     [00/04/25]
 *  (40) algor & others: mouse aware (Win32 only).                  [00/04/26]
 *  (41) Build 099.004.002  Mouse aware for most text screens.      [00/04/26]
 *  (42) Build 099.004.003  Mouse aware for line graphs.            [00/04/27]
 *  (43) Build 099.004.004  Fix bad DeleteObject's in graph32.      [00/04/28]
 *  (44) config/SHOW: <A><L><N><-+><ESC> positions rearranged.      [00/05/05]
 *  (45) Build 099.004.005  at c. 11:40 EDT.                        [00/05/06]
 *  (46) Better initialization of rsel variable.                    [00/05/07]
 *  (47) config/SHOW: initialize topo[] to 0 (was maxrings+1)       [00/05/07]
 *  (48) sw[] initialization, change 4*rloop to maxrings+4(r-1)     [00/05/08]
 *  (49) Call rselinit; new RIV routine to initialize rsel (see #46)[00/05/08]
 *  (50) Build 099.004.006  Fix RingView for >4 and mouse enable    [00/05/09]
 *  (51) calibrate_mode/manual: Toggle ring mode using alphanumeric [00/05/15]
 *  (52) ~/automatic: additional <ESC> <+-> <F10> mouse enabling    [00/05/15]
 *  (53) check_that_only_instance: new procedure for 32-bit         [00/05/16]
 *  (54) Build 099.004.007                                          [00/05/16]
 *  (55) Build 099.004.008 PCAW problem fixed using Invalidate trick[00/05/31]
 *  (56) exit_sequence: report progress of shutdown on screen       [00/06/08]
 *  (57) Build 099.004.009 comm_dp4 now supports com ports 1..16    [00/06/12]
 *  (58) PROGRAM com99C -- PROGRAM com99D !                         [00/06/15]
 *  (59) Build 099.004.010 noninit oversight in ambmp.pas fixed     [00/06/15]
 *  (60) Initialize status_var[rloop].needs_reset to TRUE.          [00/09/07]
 *  (61) Build 099.004.011 missing .SET and latched status changes. [00/09/07]
 *  (62) Build 099.004.012 Win32 err msgs & Examine trap if Delphi. [00/09/20]
 *  (63) Replace all Halt; by Halt (9xx).  Normal exit is 999.      [00/09/26]
 *  (64) Build 099.004.013 Hopefully better trapping of System.Halt [00/09/26]
 *  (65) Build 099.004.014 Correction of .latched ring number bug   [00/10/02]
 *  (66) Build 099.004.015 Check mark | epsilon for .NET <F4> Data  [00/10/04]
 *  (67) progload_date _time: delete usa arg & change output format [00-10-12]
 *  (68) calibrate_mode: remove argument usa in showtime(..)        [00-10-12]
 *  (69) config: remove code setting 'usa' based on 'site_id'       [00-10-12]
 *  (70) Build 099.004.016 ISO 8601 CCYY-MM-DD, YY-MM-DD, HH:MM:SS  [00-10-12]
 *  (71) Add unit musca to Uses list                                [00-11-07]
 *  (72) Build 099.004.017                                          [00-11-07]
 *
 * Version:     30
 * Date:        2001
 * Changes:
 *   (1) Build 099.004.018  Using all latest .dcu compiles          [01-04-04]
 *   (2) Build 099.004.019  Recompilation.  No real effects.        [01-04-09]
 *   (3) Build 099.004.020  Enhanced line graph mouse.              [01-04-11]
 *   (4) Build 099.004.021  Ring view background selection.         [01-04-18]
 *   (5) Simulation PARR, VALV, DISP files no longer have 'S'.      [01-04-23]
 *   (6) Build 099.004.022  See (5) above.                          [01-04-23]
 *   (7) Correct bug (s1, s2 mixup) in .bac filename suffix.        [01-04-24]
 *   (8) Build 099.004.023  See (7) above.                          [01-04-24]
 *   (9) Correct bug - s2 not assigned if running.                  [01-04-25]
 *  (10) Delete the site_id = XX1 feature; no longer necessary.     [01-04-25]
 *  (11) Build 099.004.024                                          [01-04-25]
 *  (12) Build 099.004.025  Trap on present but empty parr file     [01-05-08]
 *  (13) Build 099.004.026  Fixed errcode bug in ambmp.pas          [01-05-10]
 *  (14) Build 099.004.027  <F6> Ring view WD now shows grab        [01-05-11]
 *  (15) Build 099.004.028  TYPE snapshot_rec change                [01-05-12]
 *  (16) Build 099.004.029  comp99 call to therm107, and others     [01-06-07]
 *  (17) Build 099.004.030  comp99, analog_in: TEI serial           [01-09-19]
 *  (18) Build 099.004.031  recompilation with fixed graph32        [01-09-21]
 *  (19) Build 099.004.032  comdis99, graph32 changes               [01-10-03]
 *
 * Version:     31
 * Date:        2002
 * Changes:
 *   (1) Build 099.004.033  Recompile - change in optomux.pas       [02-01-12]
 *   (2) Program now called Com2002                                 [02-03-21]
 *   (3) Change Uses comp99 to Uses comp, etc.                      [02-03-21]
 *   (4) $IFDEF TURBO code $ENDIF deleted                           [02-03-22]
 *   (5) $IFDEF DELPHI $ENDIF bracketing removed                    [02-03-22]
 *   (6) Change initial hsel[] from 1 (grab) to 2 (1-min)           [02-03-25]
 *   (7) Build 099.005.001  for changes so far                      [02-03-25]
 *   (8) Build 099.005.002  status word w/ conditional temp & wind  [02-03-25]
 *   (9) Build 099.005.003  tei49c state[] & filename lengths       [02-05-14]
 *  (10) Build 099.005.004  tei49c possible checksum in message     [02-05-21]
 *  (11) Build 099.005.005  tei49c possible backed up records       [02-05-22]
 *  (12) Add Uses debuglog                                          [02-05-23]
 *  (13) main, exit_sequence: open, close debugging log file        [02-05-23]
 *  (14) Build 099.005.006  debuglog, tei49c, comp                  [02-05-23]
 *  (15) Change to DebugLogFileOpen (datapath+cfgname)              [02-05-23]
 *  (16) Change to DebugLogFileOpen (datapath+cfgname+'.LOG')       [02-05-26]
 *  (17) Build 099.005.007  debuglog & tei49c & comp changes        [02-05-26]
 *  (18) Build 099.005.008  tei49c: additional reset stuff          [02-06-05]
 *  (19) Build 099.005.009  Delphi 6 (only COMP changed)            [02-06-11]
 *  (20) Build 099.005.010  Changes in AMBMP.PAS and COMP.PAS       [02-06-27]
 *  (21) Build 099.005.011  Changes Sound/NoSound in CRT32.PAS      [02-07-02]
 *  (22) config/alarms: read in message_beep_code as last on line   [02-07-08]
 *  (23) config: remove showing of MemAvail and MaxAvail            [02-07-10]
 *  (24) Remove CONST Mem~ and MaxAvail and VAR HeapError           [02-07-10]
 *  (25) snapshot storage allocation: remove references to ~Avail   [02-07-10]
 *  (26) (same): remove HeapError := heap_error_user;               [02-07-10]
 *  (27) (same): remove HeapError := heap_error_system;             [02-07-10]
 *  (28) Build 099.005.012                                          [02-07-10]
 *  (29) Build 099.005.013  comp/special_files WI N                 [02-07-10]
 *  (30) Build 099.005.014  tei49c/tei49c_dutec_init                [02-07-10]
 *  (30) Build 099.005.015  comp/special_files WI N 2nd control O3  [02-07-10]
 *  (31) Build 099.005.016  comp/special_files logic correction     [02-07-18]
 *  (32) Build 099.005.017  comd/flasher only 2x MessageBeep        [02-07-20]
 *  (33) Build 099.005.018  graph32, comu, coms changes             [02-08-17]
 *  (34) Build 099.005.019  optomux                                 [02-09-09]
 *  (35) COM2002.PAS renamed FCP.DPR                                [02-09-13]
 *  (36) help: rewrite main screen help to use a TLblForm           [02-09-13]
 *  (37) Build 6.01                                                 [02-09-14]
 *  (38) Build 6.02  a "main" form now exists                       [02-09-16]
 *  (39) Build 6.03                                                 [02-09-17]
 *  (40) Build 6.04                                                 [02-09-18]
 *  (41) ppm_force: deleted                                         [02-09-19]
 *  (42) Build 6.05  Use CLX, not VCL units                         [02-09-19]
 *  (43) Build 6.06  VCL is default, $IFDEF CLX otherwise           [02-09-22]
 *  (44) Build 6.07                                                 [02-09-23]
 *  (45) Build 6.08  new "menu item already selected" technique     [02-11-11]
 *                   utility/timeserv removed                       [02-11-11]
 *  (46) Build 6.09  Status windows                                 [02-11-12]
 *  (47) Build 6.10  RingBar control                                [02-11-13]
 *  (48) Build 6.11  Apply's RtArrow.bmp                            [02-11-14]
 *  (49) Build 6.12  Heart beats                                    [02-11-15]
 *  (50) Build 6.13  Alarm windows                                  [02-11-16]
 *  (51) Build 6.14  Heart: use both small and large                [02-11-17]
 *  (52) Build 6.15  Watchdog unit                                  [02-12-03]
 *  (53) Build 6.16  Configuration: data communications             [02-12-04]
 *  (54) Build 6.17  Data communications: Error stats by address    [02-12-05]
 *  (55) Build 6.18  Data communications: Raw Optimux output        [02-12-06]
 *  (56)             Data communications: Error logging             [02-12-07]
 *  (57) Build 6.19  RingBar: right click & key strokes             [02-12-08]
 *  (58) Build 6.20  Removal of std, std1m, std1hr[], et al.        [02-12-17]
 *  (59) Build 6.21  Code changes leap-frogged -- see 6.22          [02-12-18]
 *
 * Version:     32
 * Date:        2003
 * Changes:
 *   (1) Build 6.22  Introduction of the new TLPF class objects     [03-01-05]
 *                   Fix comlog/datlog beep problem again!          [03-01-05]
 *                   fcp: replace one occurence of beep(1)          [03-01-05]
 *   (2) Build 6.23  Remove *_mp3s[] initializations                [03-01-06]
 *                   fcp: initialize ambient_base.Integral          [03-01-06]
 *                   fcp: initialize wdstuck.Integral to 1.0        [03-01-06]
 *                   fcp: remove awspeed[] init = 0.75              [03-01-06]
 *                   fcp: had to reinstate Alarms.errclear[rloop]   [03-01-06]
 *   (3) Build 6.24  LGSetup (line graph setup) -- incomplete       [03-01-07]
 *   (4) Build 6.25  LGSetup (line graph setup) -- finished         [03-01-08]
 *                   Replace most Close by CloseFile, and in units  [03-01-08]
 *   (5) Build 6.26  LGSelect (line graph select)                   [03-01-10]
 *                   Remove call to graphics() in main idling loop  [03-01-10]
 *   (6) Build 6.27  USES IFDEF LINUX & MSWINDOWS instead of CLX    [03-01-27]
 *   (7) Build 6.28  DOS32 unit no longer used                      [03-01-28]
 *                   config/SHOW:                                   [03-01-28]
 *                     VAR fileinfo now TSearchRec                  [03-01-28]
 *                     call FileFirst in SysUtils directly          [03-01-28]
 *                     add calls to Find Close                      [03-01-28]
 *                     add VAR filedt: TDateTime                    [03-01-28]
 *                     replace finfoout by direct SysUtils calls    [03-01-28]
 *   (8) Build 6.29  Resolving the small/large system font issue    [03-01-29]
 *                   Do do close frmStartup at end of startup       [03-03-16]
 *                   parscomm: no longer uses console screen        [03-03-16]
 *                   parscomm: all command line arguments required  [03-03-16]
 *                   parscomm: mode now case insensitive            [03-03-16]
 *                   config/load: extensive input echo changes      [03-03-16]
 *   (9) Build 6.30  Primarily console window removal preparation   [03-03-18]
 *                   algor: moved to COMP.PAS                       [03-03-19]
 *  (10) Build 6.31  Console window need not be open anymore        [03-03-19]
 *  (11) Build 6.32  Fix glitches in Status and riv                 [03-03-20]
 *  (12) Build 6.33  Fix Coms.pas wind direction glitch that uses   [03-05-03]
 *                   wsweight in averages
 *  (13) Build 6.34  DataComm: correct cbPause shown state error    [03-05-09]
 *                   frmStartup, frmMainHelp: moved to Main.pas     [03-05-09]
 *                   config: moved to Main.pas                      [03-05-09]
 *  (14) Build 6.35  new graph32 event handler doesn't use console  [03-05-09]
 *  (15) Build 6.36  graph32, LGSelect                              [03-05-10]
 *  (16) Build 6.37  OnDestroy handler added to most GUI units      [03-05-25]
 *                   Application.Icon <-- face3.ico                 [03-05-26]
 *                   water vapor utility: console<F2><F10> -> GUI   [03-05-26]
 *                   frmStartup disabled with hour glass cursor     [03-05-26]
 *  (17) Build 6.38  comd/Globals changes                           [03-05-28]
 *                   Use Connect and connect all rings during init  [03-05-29]
 *                   Connect and RVSetup use TTemplate              [03-05-30]
 *  (18) Build 6.39  Uses Services -- F2 key -> FirstAlarmPage      [03-05-30]
 *  (19) Build 6.40  ExitSeq and first use of TTimer                [03-05-31]
 *  (20) Build 6.41  network logging material moved to NetLog       [03-05-31]
 *  (21) Build 6.42  Backup.pas and GUI                             [03-06-08]
 *  (22) Build 6.43  Fix TTemplate [X] problem                      [03-06-14]
 *  (23) Build 6.44  Fix Backup bug. New TLPF dump form.            [03-06-15]
 *  (24) Build 6.45  Using Sleep(500) masks some bugs.              [03-06-15]
 *
 * Version:     33
 * Date:        2004
 * Changes:
 *  (1) 6.50 Abandon the 7.xx thread for now.                       [04-02-19]
 *           Only new LblForm .pas .dfm kept from 03-06-26.         [04-02-19]
 *  (2) 6.51 See comdis. Cursor RtArrow problem disappears.         [04-02-29]
 *  (3) 6.52 See LGSelect.  "Cannot focus..." fixed.                [04-02-29]
 *           See COMD, COMP re conditionals.  3 changes.            [04-02-29]
 *  (4) 6.53 See LGSetup and RingBar.                               [04-03-01]
 *  (5) 6.54 Main has focus during startup instead of Startup.      [04-03-03]
 *           See Main.pas and Ephem .pas and .dfm -- cosmetic       [04-03-03]
 *  (6) 6.55 comp/tinter: wind OK status bit calculation changed.   [04-06-22]
 *  (7) 6.56 ambmp/ambient_mp: implement special valve code 99.     [04-07-01]
 *  (8) 6.57 In Uses replace ambmp by MPSample.                     [04-07-16]
 *  (9) 6.58 Restructuring of imbedded multiport sampler complete   [04-07-27]
 * (10) 6.59 licor.pas plus others now support LI820/LI840          [04-08-04]
 * (11) 6.60 Site NV1 given auxiliary temperatures                  [04-10-03]
 * (12) 6.61 tinter: move files; outside doing sampling section     [04-10-26]
 *           loggcount[] initialized to 0 (was 1) at startup        [04-10-27]
 * (13) 6.62 Alarms: gray out PV and WD if sensors don't exist      [04-12-01]
 *           ambmp_hardware_var^ changed to ambmp_hardware_var      [04-12-02]
 *           Enclosure temp alarm for ZA1 set to 55 (LI-820)        [04-12-04]
 * (14) 6.63 Compare: window now functioning                        [04-12-09]
 *
 * Version:     34
 * Date:        2005
 * Changes:
 *  (1) 6.64 Licor:    Do not "remove trash" if not LI820/LI840     [05-01-06]
 *           Licor:    Begin changes so a LI840 will work           [05-01-06]
 *           MPSample: IRGA caption red when reading not good       [05-01-06]
 *  (2) 6.65 Compare/OnCreateForm: Three nonsubstantive corrections [05-05-03]
 *  (3) 6.66 Alarms: Added Help button and column headings          [05-05-04]
 *  (4) 6.67 Site WI1 given auxiliary temperatures w/ alarm         [05-05-05]
 *  (5) 6.68 Main: optimize sizing                                  [05-05-06]
 *
 * Version:     35
 * Date:        2006
 * Changes:
 *  (1) 6.69 Trying to fix TN VVP problem: see Main                 [06-03-30]
 *  (2)      Negate 6.69 -- didn't work                             [06-04-29]
 *  (3)      check_that_only_instance: CreateMutex errorMutex=      [06-04-29]
 *  (4)      move initialization of wspeed_avsd[] to comd           [06-04-30]
 *  (5) 6.70 Uses: delete tp5utils                                  [06-04-30]
 *  (6)      Uses: add EventLog                                     [06-09-22]
 *  (7) 6.71 Add calls to AppEvLog 50000, 50001                     [06-09-22]
 *  (8)      parscomm: on err, SetLastError $20001001 or $20001002  [06-09-23]
 *  (9)      check_that_only_instance: on err, $20001011            [06-09-23]
 * (10)      snapshot section: on err, SetLastError $20001021       [06-09-23]
 * (11)      DebugFileOpen call: on err, SetLastError $20001031     [06-09-23]
 * (12)      Position frmStartup to right relative to frmMain       [06-09-24]
 * (13) 6.72 Alarms unit: Add change encl temp alarm set feature    [06-09-24]
 *
 * Version:     36
 * Date:        2007
 * Changes:
 *  (1) 6.73 comp/sampling: wd simulation values changed            [07-02-28]
 *  (2) 6.73 comp/algorithm: TN1-only temp trip cycling protection  [07-02-28]
 *  (3) 6.73 comp/rring: NC1-only 8 vs 10 vvp testing code          [07-02-28]
 *  (4) 6.74 comp/rring: NC1&2007&March 8 vvp default; 2/4 tested   [07-03-13]
 *  (5) 6.75 tei49c: protect against 49I output with checksum       [07-05-31]
 *  (6) 6.76 COMP, COMS, RIV, Alarms, Main changes                  [07-06-15]
 *
 * Version:     37
 * Date:        January 2009
 * Changes:
 *  (1) 6.77 Watchdog: OnClickButton and Pet/ffwdcnt                [09-01-22]
 *  (2) 6.77 comp/analog_in/TEI: will now set comm_err[no]          [09-01-22]
 *
 * Version:     38
 * Date:        2009
 * Changes:
 *  (1) 7.00 Same as 6.77 -- begin "FACE the Future"                [09-07-30]
 *  (2) 7.01 Replace daqcrec & comm_dp4 by Ports[] & serial         [09-08-16]
 *  (3) 7.02 DataComm/PortRecv/SerialRec: read terminated string    [09-10-07]
 *           optomux: replace read char loop by read string
 *  (4) 7.03 First stage of IP deployment complete                  [09-11-13]
 *  (5) 7.04 Fix 2 minor bugs in DataComm and MPSample              [09-11-19]
 *
 * Version:     39
 * Date:        2011
 * Changes:
 *  (1) Enclosure temp alarm for AU1 set to 52 (LI-840A)          [2011-10-28]
 *  (2) 7.10 FCP for Festo -- Phase 1 -- stand alone rings        [2011-11-03]
 *  (3) 7.11                                                      [2011-11-09]
 *
 * Version:     40
 * Date:        2012
 * Changes:
 *  (1) 7.12    Compiled 2012-02-06; AU712ZIP package 2012-03-29  [2012-01-17]
 *  (2) 7.13    Changes to logg2net(no)                           [2012-05-01]
 *              Add IPServ capability                             [2012-05-04]
 *  (3) 7.14    comp/gasflow/METER: change err test <0.9 to <0.8  [2012-06-28]
 *  (4) 7.15    Changes in LineIn, IPServ                         [2012-07-03]
 *              Remove everywhere mp3s_* & *_mp3s                 [2012-07-13]
 *              Therefore comp/multiport no longer has own set of variables
 *              Remove from here mp3s_debug := FALSE; mp3s_tsamp := 15.0;
 *              comp/multiport: new MPLink string content & format[2012-07-16]
 *              DataComm: new port type - FileRec switch=3        [2012-07-23]
 *              comp/multiport: make use of DataComm              [2012-07-27]
 *  (5) 7.16    IPServ: add -1 possibility (sensor doesn't exist) [2012-08-19]
 *              Alarms: add errseq[][].exists and use             [2012-08-19]
 *              Globals:  Change PORT_FCPLINK_1..6 to _BASE = 30  [2012-08-22]
 *              Main/Config/LOAD:  Use PORT_LINK_BASE             [2012-08-22]
 *              COMD: change maxfcplink from 9 to 4               [2012-08-22]
 *              COMP/tinter: use PORT_FCPLINK_BASE instead of _1+ [2012-08-22]
 *              DataComm.dfm: Virtual port index DropDownCount=15 [2012-08-22]
 *              COMD:  Add CONST maxlogger = 1                    [2012-08-23]
 *              Globals:  Replace PORT_LOGGER_1 41 by _BASE 40    [2012-08-23]
 *              Main/Config/LOAD:  Use PORT_LOGGER_BASE in loop   [2012-08-23]
 *              COMP/sampling: Replace PORT_LOGGER_1 by _BASE loop[2012-08-23]
 *              COMD: dataflow_var[15] now ambient base value     [2012-08-24]
 *              COMD: add ambient_base_value to list_addr record  [2012-08-24]
 *              COMD: new float var AmbientBaseValue[ring]        [2012-08-24]
 *              COMP/sampling: dataflow_var[,15] AmbientBaseValue [2012-08-24]
 *              COMP/dataflow: Output Pvvp and AmbientBaseValue   [2012-08-24]
 *              Main/Config/LOAD/SHOW: ambient_base_value related [2012-08-24]
 *              COMP/algorithm: now 3 cases calculate ambient base[2012-08-25]
 *              Status.pas/dfm: LPF ShowDump for ambient base     [2012-08-25]
 *              MPSample: objMPGroup made Public                  [2012-08-26]
 *              COMP/algorithm: show raw data for cases 1 and 2   [2012-08-26]
 *              COMP/showit: new little procedure needed for above[2012-08-26]
 *              COMP/showit: show ring label and hint as well     [2012-08-27]
 *  (6) 7.17    DataComm: add protocol to VPI pull down listings  [2012-09-14]
 *              Compare: use some labels and units from list_addr [2012-09-14]
 *      in AU   IPServ:  drop the decimal place for many vars     [2012-09-15]
 *              LineIn:  some diagnostics around the UDP PortClose[2012-09-16]
 *              Remove call to NetLog.AssignFiles                 [2012-09-16]
 *              NetLog: change .CSV files from forever to weekly  [2012-09-16]
 *              Change default calibrate_param llimit.high from   [2012-09-18]
 *                300 to 350 (for AU span2 gas nominally 300)
 *              LineIn/Process/FCPLINK: clear resp1; test for null[2012-09-18]
 *              coms/lpt_constants/windstuck: Response Time = 0 s [2012-09-19]
 *              coms/lpt_constants/windstuck: Cancel previous     [2012-09-20]
 *              CalibLi840: new unit for on-line calibrations     [2012-09-24]
 *              Alarms: deal with slowly changing WD from files   [2012-09-25]
 *              IPServ: reinstate decimal point for agc5min field [2012-09-29]
 *  (7) 7.18    COMP/tinter: change "new day" test                [2012-11-13]
 *
 * Version:     41
 * Date:        2013 in Cape Town
 * Changes:
 *  (1)         DataComm.dfm: memoRaw.MaxLength to 30000 from 0   [2013-12-15]
 *  (2) 7.19    COMP/algorithm: fix ZA1 in simulation issue       [2013-12-15]
 *  (3) 7.20    licor/init_DS_840: comment out configuration      [2013-12-16]
 *              commands to IRGA (the xml2dutec statements)
 *  (4) 7.21    licor/init_DS_840:                                [2013-12-17]
 *              (a) uncomment out xml2dutec statements
 *              (b) nchcodes=4 if LI820, =5 if LI840  
 *  (5) 7.22    Alarms/errset: add Else msg := ERRTYPE i          [2013-12-18]
 *                             multimsg --> multimsg + IntToStr(code)
 *  (6) 7.23    licor/init_DS_840: comment out xml2dutec config   [2013-12-19]
 *  (7) 7.24    licr/errcheck: add 'IF wind_direction.exists THEN'[2013-12-19]
 *
 * Version:     42
 * Date:        2014
 * Changes:
 *  (1) 7.25    comp/gasflow(METER) scaling non-linear flow result[2014-02-27]
 *
 * Version:     43
 * Date:        2015
 * Changes:
 *  (1) 7.26    Main/old_consoles: disable console close (red-X)  [2015-11-18]
 *
 * Version:     44
 * Date:        2016
 * Changes:
 *  (1) Enclosure temp alarm for UK1 set to 52 (LI-840A)          [2016-02-21]
 *  (2) 7.27
 *  (3) LineIn: add additional OutputDebug lines                  [2016-07-07]
 *  (4) DataComm.dfm: Change memo size to 0 from 30000            [2016-07-07]
 *  (5) 7.28
 *  (6) LineIn: 9 corrections -- FALSE) --> TRUE)                 [2016-07-09]
 *  (7) DataComm.dfm: Change memo size to 0 30000000              [2016-07-09]
 *  (8) LineIn: Add hour to OutoutDebug time stamps               [2016-07-28]
 *  (9) DataComm: OnChangeText changes for edit3                  [2016-07-28]
 * (10) DataComm: Add CopyToClipboard button                      [2016-07-28]
 * (11) 7.30
 * (12) DataComm: Move btnCopy into the "raw" group               [2016-07-30]
 * (13) FestoCI: Time stamp OPEN... and CLOSE...                  [2016-07-30]
 * (14) LineIn: more time stamps                                  [2016-07-30]
 * (15) comp: debugging time stamps in MPLINK section             [2016-07-30]
 * (16) 7.31
 *
 * Version:     45
 * Date:        2017
 * Changes:
 *  (1) COMDIS/display/docurrent section: suppress freeze         [2017-03-24]
 *
 * Version:     46
 * Date:        2018
 * Changes:
 *  (1) NETLOG/logg2net: lift fast CSV recording restriction      [2018-03-06]

 * Version:     47
 * Date:        2022-
 * Changes:
 *  (1) Begin development for Brazil after cleanup of source files[2022-12-07]
 *}
    
CONST version_name = 'FCP';
      version_no   = '7.34';
      version_date = '2022-12-xx';

CONST nl  = CHR(13) + CHR(10);
      nl2 = nl + CHR(10);

VAR i,j: INTEGER;
    rloop: INTEGER;
{-------------------------------------------------------------}

PROCEDURE parscomm;
VAR  cmd, mode, cfg: String;
{Parses the command line}  
PROCEDURE usage (errno: INTEGER);  {local}
VAR errtype: String;
CONST usage1 =
  'Usage: ';
CONST usage2 =
  ' run|simulation configuration_file' + nl2 +
  'MODE (1st argument)' + nl2 +
  '  run        --> run real-time, on-line experiment' +nl2 +
  '  simulation --> produce simulated output' + nl2;
CONST usage3 =
  'CONFIGURATION FILE (2nd argument)' + nl2 +
  'An explicit configuration file is required.' + nl +
  'Drive and path may be used.' + nl +
  'There is no default extension.';
BEGIN
  frmStartup.BodyAppend (nl + '*** ERROR ***'+nl2);
  frmStartup.BodyAppend ('See error message window');
  CASE errno OF
    1: BEGIN
       errtype := 'There must be 2 command line arguments';
       SetLastError ($20001001);
       END;
    2: BEGIN
       errtype := 'Unrecognized mode ' + mode + ' (1st argument)';
       SetLastError ($20001002);
       END;
    END;
  FatalErr.Msg (
    'Error parsing command line', 
    errtype + nl2 + usage1 + cmd + usage2 + usage3);
  END;  {of local procedure 'usage'}
BEGIN  {procedure parscomm proper}
  frmStartup.TitleSet ('parscomm...');
  frmStartup.BodyAppend ('PARSING COMMAND LINE: ' + nl);
  run_mode     := FALSE;
  simul_mode   := FALSE;
  archive_mode := FALSE;
  cmd  := UpperCase (ParamStr(0));
  mode := UpperCase (ParamStr(1));
  cfg  := UpperCase (ParamStr(2));
  frmStartup.BodyAppend (cmd + ' ' + mode + ' ' + cfg + nl);
  IF (ParamCount <> 2) THEN usage(1);
  IF mode = 'RUN'               THEN run_mode := TRUE  {on-line, real-time}
    ELSE IF mode = 'SIMULATION' THEN simul_mode := TRUE  {simulated output}
      ELSE IF mode = 'ARCHIVE'  THEN archive_mode := TRUE   {old data}
        ELSE usage(2);
  cfgname := cfg;
  frmStartup.BodyAppend ('Command line OK' + nl2);
  END;  {of procedure 'parscomm'}
{-------------------------------------------------------------}

PROCEDURE check_that_only_instance (progtype, cfgname: String);
VAR handleMutex,
    errorMutex: INTEGER;
    msg,
    localname:  AnsiString;
    i: INTEGER;
BEGIN
  frmStartup.TitleSet ('check_that_only_instance...');
  frmStartup.BodyAppend ('CHECK THAT ONLY INSTANCE'+nl);
  {progtype is the type of program, e.g. FCP, MP3S, etc.}
  localname := progtype + ' ';
  frmStartup.BodyAppend ('localname = "'+localname+'"'+nl);
  {append the configuration file name}
  localname := localname + UpperCase(cfgname);
  frmStartup.BodyAppend ('localname = "'+localname+'"'+nl);
  FOR i := 1 TO Length(cfgname) DO 
    IF localname[i] = '\' THEN localname[i] := '/';
  frmStartup.BodyAppend ('localname = "'+localname+'"'+nl);
  {null terminate}
  localname := localname + CHR(0);
  {obtain handle to a mutex and get error return value}
  handleMutex := CreateMutex (NIL, TRUE, PCHAR(@localname[1]));
  errorMutex  := Windows.GetLastError;
  frmStartup.BodyAppend ('handleMutex = '+IntToStr(handleMutex)+nl);
  frmStartup.BodyAppend ('errorMutex = '+IntToStr(errorMutex)+nl);
  {abort if mutex creation error or previously exists in name space} 
  msg := '';
  IF handleMutex = 0 
    THEN msg := 'CreateMutex failure: Error no. ' + IntToStr (errorMutex)
    ELSE IF errorMutex = ERROR_ALREADY_EXISTS THEN msg := '*';
  IF msg <> '' THEN BEGIN
    CloseHandle (handleMutex);
    IF msg = '*' THEN msg :=
        'A process of the same type (' + progtype + ') is already' + nl +
        'running that uses this configuration file (' + cfgname + ').' + nl2 +
        'Do not run multiple instances of programs that can not' + nl +
        'share resources.' + nl2 +
        'This instance will now halt execution.';
    SetLastError ($20001011);
    FatalErr.Msg ('More than one instance of a configuration', msg);
    END;
  frmStartup.BodyAppend ('Is only instance'+nl2);
  END;  {of procedure 'check_that_only_instance'}
{-------------------------------------------------------------}

BEGIN       { main program }
  Application.Initialize;
  Application.CreateForm (TMain, frmMain);
  //Application.Run;
  
  EventLog.AppEvLog (50000);
  frmStartup := TLblForm.Create (Application);
  frmStartup.Label1.Cursor  := crHourGlass;
  frmStartup.Enabled := FALSE;
  frmStartup.Display ('FCP program start...', '');
  frmStartup.BodyClear;
 {frmStartup.SetFocus; 2004-03-03}
  frmStartup.Left := frmMain.Left + frmMain.Width;

  frmMain.SetFocus;

  parscomm;  {get command line arguments or write usage message}

  {do not allow > 1 FACE control program application with same cfg name}
  check_that_only_instance ('FCP', cfgname);

  IF NOT archive_mode
    THEN Main.config ('LOAD', 0);  {get FACE configuration for site}

  EventLog.AppEvLog (50001);

  frmStartup.BodyAppend ('INITIALIZING VARIABLES'+nl);
  dataflow_show := FALSE;
  FOR rloop := 1 TO numrings DO faceraw_switch[rloop] := FALSE;
  FOR rloop := 1 TO numrings DO BEGIN
    winddown[rloop]:=FALSE; windup[rloop]:=TRUE;
    END;
  frmStartup.BodyAppend ('MULTIPORT SAMPLER INIT'+nl);
  IF ambmp_hardware_var.exists THEN ambient_mp_init;  {do this one first}
  frmStartup.BodyAppend ('RELINIT'+nl);
  FOR rloop := 1 TO numrings DO relinit(rloop);
  NEW(loggfile); NEW(varrfile);

  IF simul_mode THEN FOR rloop:=1 TO numrings DO BEGIN
    gcgrab[rloop]:=600;  wspeed[rloop]:=1;  winddir[rloop]:=0.7;
    END;

  line60:='------------------------------'+
          '------------------------------';
  FOR rloop := 1 TO numrings DO BEGIN
    s1 := rlabel[rloop];  
    frmStartup.BodyAppend ('ASSIGNING RING '+s1+' DATA/SET FILES'+nl);
    IF simul_mode THEN s2 := Concat(s1,'S') ELSE s2 := s1;
    filnam[rloop,1]:=datapath+'LOGG'+s2+'.DAT';
      Assign(logg[rloop],filnam[rloop,1]);
    filnam[rloop,3]:=datapath+'VARR'+s2+'.DAT';
      Assign(varr[rloop],filnam[rloop,3]);
    filnam[rloop,4]:=datapath+'PARR'+s1+'.SET';
      Assign(parr[rloop],filnam[rloop,4]);
    filnam[rloop,5]:=datapath+'DISP'+s1+'.SET';
      Assign(disp[rloop],filnam[rloop,5]);
    filnam[rloop,6]:=datapath+'VALV'+s1+'.SET';
      Assign(moto[rloop],filnam[rloop,6]);

    comm[rloop,1]:='{'+s2+'}System log data       ';
    comm[rloop,2]:='{'+s2+'}System statistics     ';
    comm[rloop,3]:='{'+s2+'}System variables      ';
    comm[rloop,4]:='{'+s2+'}System cntl parameters';
    FOR i := 1 TO 4 DO r[rloop,i]:='00000000';
    END;

  rselinit;

  FOR rloop := 1 TO numrings DO BEGIN
    s1 := rlabel[rloop];
    frmStartup.BodyAppend ('ASSIGNING RING '+s1+' BACKUP FILES'+nl);
    IF simul_mode THEN s2 := Concat(s1,'S') ELSE s2 := s1;
    fileinit(rloop);
    loggback[rloop]:=backuppath[rloop]+'LOGG'+s2+'.BAC';
      Assign(loggb[rloop],loggback[rloop]);
    varrback[rloop]:=backuppath[rloop]+'VARR'+s2+'.BAC';
      Assign(varrb[rloop],varrback[rloop]);
    parrback[rloop]:=backuppath[rloop]+'PARR'+s1+'.BAC';
      Assign(parrb[rloop],parrback[rloop]);
    dispback[rloop]:=backuppath[rloop]+'DISP'+s1+'.BAC';
      Assign(dispb[rloop],dispback[rloop]);
    motoback[rloop]:=backuppath[rloop]+'VALV'+s1+'.BAC';
      Assign(motob[rloop],motoback[rloop]);
    END;

  FOR rloop := 1 TO numrings DO BEGIN
    lttime[rloop]:=0;
    sgcgrab[rloop]:=''; spropc[rloop]:=''; spropresp[rloop]:='';
    swwdir[rloop]:=''; swspeed[rloop]:='';
    sw[maxrings+4*(rloop-1)+3].mess:='';
    sw[maxrings+4*(rloop-1)+4].mess:='';
    wsel[rloop]:=2; psel[rloop]:=1; hsel[rloop]:=2;
    FOR i:=1 TO maxvalvs DO BEGIN
      vact[rloop,i]   := FALSE;
      vnoact[rloop,i] := FALSE;
      END;
    END;

  tinter1;  {NOTE: other initializations may depend on a valid tint existing!}
  tf1last:=tlast; tf2last:=tlast; tf3last:=tlast;

  progload_date := showdate(comd.date);
  progload_time := showtime(comd.time);

  {Boot up default enclosure temperature alarm thresholds as of 98/05/30}
  FOR rloop := 1 TO numrings DO BEGIN
                              encl_temp_alarm_set[rloop] := 35.0;
    IF (site_id = 'AZ2') THEN encl_temp_alarm_set[rloop] := 35.0;  {box w/ ac}
    IF (site_id = 'CH1') THEN encl_temp_alarm_set[rloop] := 45.0;  {box w/o ac}
    IF (site_id = 'DE1') THEN encl_temp_alarm_set[rloop] := 35.0;  {???}
    IF (site_id = 'MN1') THEN encl_temp_alarm_set[rloop] := 40.0;  {LiCor cell}
    IF (site_id = 'NC1') THEN encl_temp_alarm_set[rloop] := 40.0;  {LiCor cell}
    IF (site_id = 'NV1') THEN encl_temp_alarm_set[rloop] := 35.0;  {shed}
    IF (site_id = 'TN1') THEN encl_temp_alarm_set[rloop] := 40.0;  {LiCor cell}
    IF (site_id = 'WI1') THEN encl_temp_alarm_set[rloop] := 40.0;  {LiCor cell}
    IF (site_id = 'ZA1') THEN encl_temp_alarm_set[rloop] := 55.0;  {LI820 cell}
    IF (site_id = 'AU1') THEN encl_temp_alarm_set[rloop] := 52.0;  {LI840 cell}
    IF (site_id = 'UK1') THEN encl_temp_alarm_set[rloop] := 52.0;  {LI840 cell}
    END;

  {define deviation bands used to measure control performance}
  gcband[1] := 0.2;
  gcband[2] := 0.1;
  gcband[3] := 0.2;

  {default starting calibrate mode parameters}  
  WITH calibrate_param DO BEGIN
    llimit.low  :=  -50;
    llimit.high :=  350;
    ulimit.low  :=  950;
    ulimit.high := 1050;
    period := 60;
    END;

  FOR rloop := 1 TO numrings DO WITH list_addr_ptr[rloop]^ DO BEGIN
    winddirsave[rloop] := 0.0;
    loggpoint[rloop]:=1; 
    varrpoint[rloop]:=1;
    loggcount[rloop]:=0;
    agcerr[rloop] := 0;
    agcontsave[rloop] := 0; 
    adif[rloop] := 0; 
    gccntl[rloop] := conc_cont.offscale;
    gcambi[rloop] := conc_ambi.offscale;
    propc[rloop]:=preset[rloop]; cinteg[rloop]:=preset[rloop];
    debug[rloop]:=FALSE; oper[rloop]:=TRUE; cwind[rloop]:=0;
    cprop[rloop]:=0; cdiff[rloop]:=0; gcerr[rloop]:=0; runon[rloop]:=TRUE;
    histo[rloop]:=1;
    WITH calibrate_var[rloop] DO BEGIN  {initialize calibration mode variables}
      enable := FALSE;
      active := FALSE;
      forceon := FALSE;
      timeon  := 0.0;
      timeoff := 0.0;
      forcevalue := 0.0;
      llimit.low  := -9999;
      llimit.high := -9999;
      ulimit.low  := +9999;
      ulimit.high := +9999;
      END;
    WITH vvptime[rloop] DO BEGIN  {initialize most of the vvp refresh vars}
      lastchange := 1.0E+30;
      newpattern := FALSE;
      needsrefresh := FALSE;
      rrrr_old := '00000000000000000000000000000000';
      rrrr_new := '00000000000000000000000000000000';
      msg := '**';
      END;
    WITH co2qt[rloop] DO BEGIN  {QT valve delay control}
      asked := FALSE;
      state := FALSE;
      lastchange := 0.0;
      delay := 5.0;  {seconds}
      END;
    WITH status_var[rloop] DO BEGIN
      current := 0;
      latched := rhex[rloop];
      needs_reset := TRUE;
      END;
    digital_in_fumi[rloop] := 0;
    digital_in_cntl[rloop] := 0;
    FOR i := 1 TO 15 DO WITH dataflow_var[rloop,i] DO BEGIN  {data flow storage}
      digital := 0;
      volts := 0.0;
      value := 0.0;
      END;
    END;

  {Clear alarms}
  frmStartup.BodyAppend ('CLEARING ALARMS'+nl);
  FOR rloop := 1 TO numrings DO Alarms.errclear (rloop);

  {Connect all rings}
  frmStartup.BodyAppend ('CONNECTING ALL RINGS'+nl);
  FOR rloop := 1 TO numrings DO Connect.StateSet (rloop, TRUE);

  {Initialize low pass filter constants.
   Do this also after accessing algorithm setup.}
  frmStartup.BodyAppend ('CALLING LPF_CONSTANTS'+nl);
  lpf_constants;
  ambient_base.Integral := enrich_base[1].default;
  FOR rloop := 1 TO numrings DO wdstuck[rloop].Integral := 1.0;

  {Initialize COM/Opto22 control of Kurz valve}
  frmStartup.BodyAppend ('CALLING GASFLOW INIT'+nl);
  FOR rloop := 1 TO numrings DO gasflow ('INIT', rloop);

  {Allocate storage for snapshot graphics}
  frmStartup.BodyAppend ('Allocating storage for snapshot graphics'+nl);
  snapshot_toggle := TRUE;
  snapshot_fill  := -1;
  snapshot_index := -1;
  snapshot_size  := 0;
  NEW (snapshot_ray);
  WHILE (snapshot_size < snapshot_max) DO BEGIN
    INC (snapshot_size);
    FOR rloop := 1 TO numrings DO BEGIN
      NEW (snapshot_ray^[rloop][snapshot_size]);
      IF snapshot_ray^[rloop][snapshot_size] = NIL THEN BEGIN
        SetLastError ($20001021);
        FatalErr.Msg (
        'Error allocating memory for snapshots',
        'While dynamically allocating memory for "snapshot" ' +
        'line graph screens, FUNCTION NEW returned NIL.' + nl +
        'This means there was no memory left at this point.' + nl2 +
        'Ring = ' + IntToStr(rloop) + nl +
        'Snapshot size = ' + IntToStr(snapshot_size));
        END;
      FOR j := 1 TO 180 DO WITH snapshot_ray^[rloop][snapshot_size]^[j] DO BEGIN
        zeit := '   EMPTY';
        igcgrab := 0;  igc1min := 0;  igccntl := 0;  igcset := 0;
        propctl := 0;  proprsp := 0;
        kinteg  := 0;  kprop   := 0;  kwind   := 0;
        windspd := 0;  winddir := 0;
        END;
      END;
    END;

  ifire   := maxrings;
  no      := 1;

  frmStartup.BodyAppend ('Opening debugging log file...'+nl+nl);
  i := DebugLogFileOpen (datapath+cfgname+'.LOG');
  IF (i <> 0) THEN BEGIN
    SetLastError ($20001031);
    FatalErr.Msg (
    'Error opening debugging log file',
    'Unit/Method: DebugLogFileOpen' + nl2 +
    datapath+cfgname+'.LOG');
    END;

  frmStartup.BodyAppend ('logrec:  '+IntToStr(SizeOf(logrec))+nl);
  frmStartup.BodyAppend ('varrec:  '+IntToStr(SizeOf(varrec))+nl);
  frmStartup.BodyAppend ('parrec:  '+IntToStr(SizeOf(parrec))+nl);
  frmStartup.BodyAppend ('pittman: '+IntToStr(SizeOf(pittman))+nl);
  frmStartup.BodyAppend ('displayrecord: '+IntToStr(SizeOf(displayrecord))+nl);

  Application.Title := cfgname + ' ' + version_name + ' ' + version_no;
  TRY
    Application.Icon.LoadFromFile ('FACE3.ICO');
    EXCEPT
      frmStartup.BodyAppend (
        '!!! WARNING !!!' + nl +
        'Application icon file FACE3.ICO not found ' + 
        'in default subdirectory' + nl + nl);
    END;
  frmMain.Caption := Application.Title + ' -- Main menu';
  frmMain.Init;

  {Enable "help hints"}
  Application.ShowHint := TRUE;
  frmMain.ShowHint     := TRUE;

  statscr := FALSE;

  frmStartup.BodyAppend ('Click or any key to close this window');
  frmStartup.Enabled := TRUE;
  frmStartup.Label1.Cursor  := crDefault;

  {Application.MessageBox ('FCP.DPR', 'Marker', MB_OK);}

  {main menu idling loop}
  REPEAT
    tinter;
    Application.ProcessMessages;
    UNTIL FALSE;
{of project FCP.DPR...}
END.
