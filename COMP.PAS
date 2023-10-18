Unit comp;
{$R+  Range checking ON}
{$H-  Turbo-style strings are default}

Interface

Uses
  crt32, graph32,
  faced, comd, comu, coms, MPSample, optomux, licor, tei49c,
  netinfo, gra, AVSD, Sol,
  Globals;

{*
 * Purpose:  BNL FACE Project
 *           On-line data acquisition, monitoring and control
 *           Workhorse routines
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
 *   (3) TYPE float = Single added to declaration
 *   (4) REAL types in all units redeclared as float
 *       (see J.N. memo "FACE Binary Records Changed" 4/19/90)
 *   (5) timeon and timeoff changed from floating point seconds since
 *       midnight to integer minutes since midnight
 *   (6) procedure disk; changed to disk (drive: String);
 *   (7) function/procedures bytesleft, changering, clearhist added in spring
 *
 * Version:     3
 * Date:        07-18-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Added local function 'adcvolts' to procedure 'sampling'
 *   (2) Added variables ppmperv[] and voffset[] to
 *       gas concentration engineering conversion in
 *       procedure 'sampling'
 *
 * Version:     4
 * Date:        11-xx-90
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add procedure 'changering'
 *   (2) Added ring=0 option to procedure 'clearhist'
 *   (3) Raised scope of function 'adcvolts' to full rank.
 *   (4) Added procedures 'mid64_out', 'mai16' and 'outport'
 *       and functions 'mid64_in' and 'inport'.
 *   (5) Modified procedure 'sampling' to use item (4).
 *   (6) In procedure 'algorithm', defined constant
 *       'maxpropc' and made use of item (4).
 *   (7) Cleaned up procedure 'rring' making use of (4).
 *   (8) Add procedures 'currenttime' and 'currentdate'.
 *   (9) In procedure 'algor', do not write a new PARR
 *       record unless spacebar has been pressed, i.e.,
 *       some value was actually changed.
 *
 * Version:     5
 * Date:        April 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add/use local procedure 'lpf' to proc 'average'.
 *   (2) Add procedure 'flasher'; replace 'tinter' code.
 *   (3) Add procedure 'watchdog' and use in 'tinter'.
 *   (4) Move display of date and time to 'statdis'
 *         from 'tinter'.
 *   (5) ADC offset changed to user units rather than volts;
 *         has been renamed offset[] from voffset[].
 *   (6) For 'average', wsweight added which is wspeed[]
 *         if wspeed[] > 0 but 0.001 otherwise.
 *   (7) Add and use procedure 'xywrite' which is a
 *         replacement for the common sequence
 *         GotoXY(); TextColor(); WRITE();.
 *   (8) Correct integer*integer overflow bug in proc
 *         'currenttime' (hour*3600 --> hour*3600.0).
 *   (9) Add 'dioread' and 'diowrite' as general purpose
 *         digital i/o read/write routines.
 *
 * Version:     6
 * Date:        May 1991
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add procedures 'errclear', 'errset' and 'errcheck'.
 *   (2) Code for controlling calls to error checking in 'tinter'.
 *   (3) Code to calculate errors in procedure 'average'.
 *   (4) Code for displaying error conditions in procedure 'statdis'.
 *   (5) Added procedure 'setco2qt' and used it when turning CO2 manifold
 *         valves on or off.  Show 'asked' and 'state' from proc 'statdis'.
 *   (6) Have bytes left message in procedure 'disk' blink if there are left
 *         less than 2 MBytes on data logging drive.
 *   (7) Add 'offscale', value to set concentration to when analyzer off scale
 *         as part of engineering set.  Changed 'com91' and 'comd91' as well.
 *
 * Version:     7
 * Date:        February/March 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Write procedure scrollup().
 *   (2) Use scrollup() in clwindow().  
 *   (3) In tinter, execute only if not in archive mode.
 *   (4) Brought in procedures beep, dselected, tselected, wselected
 *       from DATP.
 *   (5) Add procedure pauseat().
 *
 * Version:     8
 * Date:        November/December 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Change algor() to eliminate backuppath[] and add vvpvar.period[].
 *   (2) Replace tsamp(last), tcont(last) scalars by arrays by ring
 *       BUT only use values for Ring 1 at this time.
 *   (3) Modify code reflecting change of wdir and stdwdir from
 *       String to INTEGER.
 *   (4) Added function 'hhmmss' and use after calls to 'currenttime'.
 *   (5) Change procedure 'currenttime' removing calculation of time string.
 *   (6) Add display of calibration mode information to 'statdis'.
 *       Add suppress accumulation of gc integrals if gc out of range.
 *       Add display of calibration mode in 'flasher'.
 *   (7) Introduce loggcount[ring] which is samples in a file write interval.
 *   (8) Output loggcount[] and loggpoint[] on status display.
 *   (9) In 'mai16', read high byte first due to problem encountered when
 *       testing adc (12/13/92).
 *  (10) Rewrote 'adcvolts' procedure for data_flow (12/14/92).
 *
 * Version:     9
 * Date:        January 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Query state of ppm forcing in sampling() if in simulation.  1/5/93
 *   (2) Moved calculation of calibrate_var[no].active from average() to
 *         sampling().  1/5/93
 *   (3) For simulation mode sampling gcont, make 350 ppm when PropC=0
 *         rather than 0 ppm!  1/5/93
 *   (4) Must set gcerr and agcerr equal to 0.0 in algorithm() so that
 *         PropC doesn't move too much when calibration mode active.  1/5/93
 *   (5) Rewrite relinit(), mid64_in(), and mid64_out() so that I/O request
 *         is ignored unless run_mode=TRUE.  Since BPSD ethernet board
 *         default base address is also 768(0x300), this was causing massive
 *         amounts of collision noise on network.  1/6/93
 *   (6) Changes relevant to making calibration mode active lower and upper
 *         bands rather than simple limits.  1/26/93
 *
 * Version:     10
 * Date:        February-June 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin development of COM93 which will include Opto22 DAQC. [2/22/93]
 *   (2) Add functions getchunk(), hex2word(), and str2word().
 *   (3) Replace references to ppmperv, etc. by CO2_center. [2/23/93]
 *   (4) Move Metrabyte related routines to new unit metrabyt.pas. [2/24/93]
 *   (5) Write general purpose, switchable I/O routines
 *         analog_out(), digital_out(), analog_in(), digital_in().
 *   (6) Add ringnumber argument to procedure relinit;  [4/12/93]
 *   (7) Change low wind pattern to 0101..01 to match
 *       NC failsafe pattern as built.  CH will be the same.  [4/15/93]
 *   (8) Read in miscellaneous digital board as misc_digital_in[].  [4/28/93]
 *   (8' Change width of flasher from numrings to maxrings blocks.  [5/??/93]
 *   (9) Error code changed from powers of 10 to bit position.
 *       Added more error conditions in errset(), etc.
 *  (10) Change sampling; to sampling(iring);
 *  (11) Add procedure errview(iring);
 *  (12) Concentration alarm now 50% of set point minus ambient 
 *       (was 50% set point)  [6/1/93].  Made that 75% [6/5/93]
 *  (13) Add code in many places related to new "disconnect" mode.
 *  (14) Cdiff term in procedure algorithm changed from Adiff*diff
 *       to Adiff*diff/tsamp and Cinteg increment to 
 *       -Ainteg*error*tsamp*0.001 (see J.N. NB V pp. 144ff).  [6/3/93]
 *  (15) Move call to procedure 'algorithm' from "sampling" to "control" [6\4]
 *  (16) Do errclear() upon transition from runon to runoff.
 *  (17) Add function rlabel(iring) which returns 1 or A, 2 or B, etc.
 *  (18) Add functions showdate() and showtime() which can display
 *       date and time in non-US formats; depends on site_id.  [05.06.93]
 *  (19) Gcont now set to 2x Gcset on underflow, not offscale config value.
 *  (20) Add code for autocalibration.  [06/07/93]
 *  (21) Replace std. dev. of wind direction by 1-minute lpf integral
 *       of the absolute change in wind direction grab measurement.  [6/8/93]
 *  (22) Enable optomux brain watchdogs for analog and miscellaneous digital
 *       boards in procedure relinit.  [6/14/93]  And VVP boards [6/28/93]
 *  (23) Change CO2 QT cutoff from propc[] < 0.5 to
 *       < 0.001*pv_control[].offscale.  [6/25/93]
 *  (24) In procedure 'watchdog', bring AZ1 code up to date and
 *       add code for NC1.  [6/26/93]
 *  (25) In procedure 'algorithm', add code necessary for varying strength
 *       of PID coefficients.  [6/28/93]
 *
 * Version:     11
 * Date:        July/August 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Add procedure 'multiport' for linking. [7/15/93]
 *   (2) Need to Use ser93 if serial bios being called for this.
 *   (3) Need to Use comm_tp4 if interrupt package called.
 *   (4) Averaging for multiport values added to 'average'. [7/18/93]
 *   (5) Begin use of dynamic adjustment of PIP coefficients. [8/01/93]
 *       datalog: in varr, replace a*[no] by a*_adj[no], agc1m by agcont.
 *       algorithm: calculate a*_adj coefficients.
 *
 * Version:     12
 * Date:        September/October 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) multiport(): changes to accomadate more than one active. [09/09/93]
 *   (2) algorithm(): cripple dynamic adjustment for CH COM93.    [18.10.93]
 *   (3) analog_in(): change conversion to proper (d-4096)/4095.  [29.10.93]
 *
 * Version:     13
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as COMP94.                                      [12/10/93]
 *   (2) relinit(): in IF 'MP' correct port --> base               [12/11/93]
 *   (3) rring(): change settle_delay back to 100 from 25 ms       [12/12/93]
 *   (4) rring(): replace ssr_open, _close by .cfg input vars      [12/12/93]
 *   (5) rring(): don't activate vvp open, close, or multiplexor   [12/12/93]
 *                for AZ1 if the ring is disconnected.
 *   (6) analog_in(): had to change "exists" logic a little bit.   [12/12/93]
 *   (7) tinter(): enrichment mode is bit 3 of status word.        [12/12/93]
 *                 This limits number of rings now to 7.
 *   (8) isrunon(): new function for fumigation on or off.         [12/13/93]
 *   (9) algor() & status display: changes related run on/off,     [12/13/93]
 *         enrichment mode, and [CO2] alarm.
 *  (10) add change +- feature to algor().                         [12/15/93]
 *  (11) digital_in(): implement for dasystem type MP.             [12/15/93]
 *  (12) flasher(): turn of sound at end of flash regardless       [12/16/93]
 *  (13) algor(): Reorder and change text.                         [12/21/93]
 *  (14) algor(): Replace windprop[] by pidfactormin|max[]         [12/21/93]
 *
 * Version:     14
 * Date:        January/February 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Many functions/procedures moved to new unit COMUyy.PAS    [01/06/94]
 *   (2) Add procedure ephemeris for sun's position                [01/06/94]
 *   (3) Make pidfactor a global ring number array                 [02/05/94]
 *   (4) algorithm: use awspeed rather than windlearn for pidfactor[02/05/94]
 *   (5) algorithm: code to prevent co2 supply oscillations in AZ  [02/08/94]
 *
 * Version:     15
 * Date:        March/April/May 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Calibration active bit in status word = manual OR auto    [94/03/01]
 *   (2) algortihm():  changes to accomodate riv() debug[] option  [94/03/15]
 *   (3) post():  argument 'where' replaces 'ir'                   [94/03/16]
 *   (4) putring():  argument 'where' added                        [94/03/16]
 *   (5) relinit():  optomux_debug no longer TRUE during this proc [94/03/18]
 *   (6) isrunon():  add section (usually commented out) which     [94/04/18]
 *                   overrides PARR information for special tests
 *   (7) isrunon():  change special section from Maricopa 4/94     [94/04/28]
 *                   (see NB VI 85) to Eschikon 5/94 (tentative).
 *   (8) multiport, relinit, tinter: looping for multiple mp links [94/05/02]
 *   (9) dataflow():  individually toggle raw FACE and MP3S        [94/05/03]
 *  (10) tinter: fix if not comm_err[no] then algorithm(ninter) bug[94/05/10]
 *  (11) multiport:  add DISConnect command                        [94/05/30]
 *  (12) reldisc:  new procedure to drop serial connections        [94/05/30]
 *  (13) multiport:  also send over gcset and latched status to MP [94/05/31]
 *
 * Version:     16
 * Date:        June/July 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) algorithm:  use Kurz controller AND/OR procedure gasflow  [94/06/11]
 *   (2) gasflow:    new procedure for direct pv motor control     [94/06/11]
 *   (3) Must move some routines to new unit COMS;                 [94/06/11]
 *       getting "Code segment too large" compiler error!
 *   (4) gasflow: (a) backlash; (b) projection of control signal   [94/06/20]
 *   (5) tinter: code to fill in the snapshot graphics array       [94/06/27]
 *   (6) tinter: use snapshot_toggle to save only every 2nd record [94/07/09]
 *   (7) gasflow: when learning use ratio of integrals instead of  [94/07/12]
 *       integral of ratio of flow change to time step
 *   (8) pv_motor: still another attempt at a learning algorithm   [94/07/22]
 *   (9) relinit: remove initializations of ICTDs since not needed [94/07/22]
 *
 * Version:     17
 * Date:        August/September 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) analog_in: optomux -- now more efficient if "borrowing"   [94/08/28]
 *   (2) tinter: move adc_read reset outside ring sampling loop    [94/08/28]
 *         (there will be a problem if ring borrowed from is "disconnected")
 *
 * Version:     18
 * Date:        November 1994
 * Changes:
 *   (1) gasflow/move_motor: switch over to unipolar PS w/ dir     [94/11/14]
 *   (2) rring: <>AZ1, vvp loop limited to (numvalvs-1) DIV chans  [94/11/14]
 *
 * Version:     19
 * Date:        Feb 1995
 * Changes:
 *   (1) Becomes COMP95.PAS                                        [95/02/21]
 *
 * Version:     20
 * Date:        June/July/August 1995
 * Changes:
 *   (1) alogrithm(): pv_control[no].exists AND (channel IN [0..15])]
 *         See discussion J.N. NB VII p. 49                        [95/06/02]
 *   (2) tinter(): gcamb_peak --> airpres  ***TEMPORARY            [95/06/06]
 *   (3)           move position of line inc'ing loggcount[]       [95/06/06]
 *   (4) isrunon(), status, statdis(): display solar_ton/off[]     [95/06/07]
 *   (5) sampling(): failsafe the pv_response (dataflow #9)        [95/06/07]
 *   (6) gasflow(): using comments, go back to bipolar motor PS    [95/06/07]
 *   (7) gasflow(): change default maximum step to 500 ms          [95/06/07]
 *   (8) h2ovapor(): new procedure; see also tinter                [95/06/15]
 *   (9) dataflow(): many changes related to pH2O                  [95/06/15]
 *  (10) rename all local procedures 'sidebar' to 'template'       [95/06/15]
 *  (11) add procedure 'sidebar' to do common work of 'template's  [95/06/15]
 *  (12) mostly use errlatch[]; err[] cleared at buffer write      [95/06/16]
 *  (13) gasflow(): using comments, go back to unipolar motor PS   [95/06/26]
 *         gain=100, kp=0.75, tolerance=0.002, tmax=750, lp=300
 *  (14) daqerrs(): record and show date/time of last err clear    [95/06/29]
 *  (15) gasflow(): some fine adjustments                       [95/07/09-12]
 *  (16) gasflow(): learning in CH finding much too small a gain;  [95/07/17]
 *         set learning=0 for now.
 *  (17) gasflow(): blflag now global with one per ring; Kp=0.5    [95/07/29]
 *  (18) tinter():  pressure slot now back to pressure; see (2)    [95/08/04]
 *  (19) algorithm: v14 #5 above now applies only for site AZ1     [95/08/06]
 *  (20) gasflow(): further diddling of parameters                 [95/08/07]
 *
 * Version:     21
 * Date:        Sep 1995
 * Changes:
 *   (1) Replace occurences of dasystem by ringdaqc.protocol       [95/09/04]
 *   (2) Change from IF site_id = to IF protocol = if necessary    [95/09/04]
 *   (3) Add call to cts10_display in tinter if cts10_show is true [95/09/04]
 *   (4) Add use of WWV cts_unit.tpu                               [95/09/04]
 *
 * Version:     22
 * Date:        Oct-Dec 1995, Jan 1996
 * Changes:
 *   (1) Becomes COMP96.pas; update Uses except leave as ser95.    [95/10/14]
 *   (2) tinter(): IF ifire > maxrings --> numrings AND 4.         [95/10/15]
 *   (3) algor():  update for ambient+ and conditional fumigation. [95/11/06]
 *   (4) sampling(): update for new wcl mp channels and codes.     [95/11/18]
 *   (5) rring: Copy(matr,-start+73,32) numvalv generalized.       [95/12/19]
 *   (6) runon[] now becomes fumigation_enabled AND conditional_ok [96/01/01]
 *   (7) new status word; AZ short haul modem overflow deleted     [96/01/01]
 *   (8) algorithm(): update for additive or multiplicative        [96/01/01]
 *   (9) lpf(): in average(): moved to unit comu96                 [96/01/01]
 *  (10) wspeed_avsd use in average(); and datalog();              [96/01/05]
 *  (11) aairpres logg record slots used for WCL "ambient"         [96/01/06]
 *  (12) runon[] now includes NOT shut as well                     [96/01/06]
 *  (13) delete occurences of shut[] not now needed (see 12)       [96/01/07]
 *  (14) error alarm routines: add "no ambient signal"             [96/01/08]
 *  (15) make some use of pround (= protected ROUND)               [96/01/16]
 *
 * Version:     23
 * Date:        May-Sep 1996
 * Changes:
 *   (1) gasflow()/INIT: read paramters from MOTOn.DAT if exists.  [96/05/29]
 *   (2) gasflow()/SHOW: refresh on exit all MOTOn.DAT everytime.  [96/05/29]
 *   (3) algorithm():    set pidfactor[] := cinteg[]/200.0         [96/06/12]
 *   (4) move inport and outport to comu96 to reduce code segment  [96/06/12]
 *   (5) move proc ephemeris to comdis due to code segment too big [96/06/20]
 *   (6) tinter: replace call to ephemeris(1) by _decra and _altaz [96/06/20]
 *   (7) tinter: reset new_sample[] on entry; set upon sampling    [96/06/21]
 *   (8) move proc h2ovapor to comdis to further reduce code seq   [96/06/22]
 *   (9) tinter: remove direct call to h2ovapor(1)                 [96/06/22]
 *  (10) move procedure sidebar() to coms96.pas                    [96/06/22]
 *  (11) move function rlabel() to coms96.pas                      [96/06/22]
 *  (12) change rlabel() references to rlabel[]                    [96/06/22]
 *  (13) tinter: mask_fan logic changes for slaved control rings   [96/07/01]
 *  (14) relinit: initialize slaved contril ring devices           [96/07/01]
 *  (15) rring: set vvp state in both fumi and cont rings          [96/07/01]
 *  (16) errview, etc.: incorporate fan rotation of cont rings     [96/07/01]
 *  (17) rring: will use the bootup default offset of $80 between  [96/07/03]
 *         MasterDigital and Expander1 addresses when equipment
 *         is duTec ('DS') instead of usual convention of $01
 *  (18) relinit: ditto + power-up-clear & protocol for duTec MC   [96/07/03]
 *  (19) relinit: simplified set watchdog delay of analog board    [96/07/03]
 *  (20) misc_digital_in[] now digital_in_fumi and _cntl           [96/07/31]
 *  (21) relinit: initialize control ring misc digital board if any[96/07/31]
 *  (22) fan on/off activation/deactivation for possible C ring    [96/08/02]
 *  (23) errcheck: power supply may be in the C ring of a rep      [96/08/02]
 *  (24) relinit: misc di/o configure - fix $FFFF Shl bug          [96/08/03]
 *  (25) sampling: for FACTS-I call to ambient_mp prior to WCL MP  [96/08/03]
 *  (26) ambient_mp: new procedure for active, imbedded mp         [96/08/03]
 *  (27) errview: sensor[?]:=?[ring].exists was being incorrectly  [96/08/29]
 *                set OUTSIDE of the repeat as ring # changed loop
 *  (28) flasher: display rlabel[] character instead of 'X' when   [96/08/29]
 *                error condition has been set in a ring
 *  (29) algor: ring number displayed on screen corrected from the [96/08/29]
 *              ordinal = CHR(ORD('0')+no) to ring label = rlabel[no]
 *  (30) ambient_mp: (1) insert unchecked code for duTec to read a [96/09/03]
 *         LI-62x2; (2) comment out code which reads an ADC instead, (3) add 
 *         reading of the apparatus test bit for inclusion in "good bit"
 *  (31) relinit, rring: RS422 repeat not working for WI prototype [96/10/22]
 *         Must use COM1: for Misc and COM2: for VVP's.
 *         Patches are labeled {!!! WI0 emergency.
 *  (32) analog_out: A calculated 'digital' < 0 causes range error.[96/10/24]
 *         Add statement to set to 0 if negative otherwise.
 *  (33) sampling: For [O3] and/or voltage ADC, must change        [96/10/24]
 *         "underflow test from < 250 to < 0.  OK still for AZ short haul
 *         modem and 4-20 mA ADC signals if 4mA -> 0 units but will not
 *         detect e.g. broken voltage signal wire.
 *  (34) sampling: For open loop flow control situations when there[96/10/24]
 *         is no response signal, IF NOT pv_response[].exists THEN
 *         propresp[] := propc[]; so that Cinteg will update.  Won't think
 *         something wrong with closed loop flow control.  (propresp[] delayed.
 *
 * Version:     24
 * Date:        Dec 1996
 * Changes:
 *   (1) Becomes COMP97.pas; update Uses except leave as ser95.    [96/12/22]
 *   (2) errview/daqerrs: pull down page showing optomux error     [96/12/28]
 *         count by address.
 *
 * Version:     25
 * Date:        Jan-Apr 1997
 * Changes:
 *   (1) algor: change because conditional_var[] now on heap.      [97/01/12]
 *   (2) conditional_test: new function.                           [97/01/13]
 *   (3) tinter: after sampling, compute conditional test values.  [97/01/13]
 *   (4) Uses: must add faced97 to pick up max_conditionals.       [97/01/19]
 *   (5) Move procedures changering and clearhist to comu97.       [97/01/20]
 *   (6) Remove procedure disk which is duplicted in comu97.       [97/01/20]
 *   (7) Make required change in changering & clearhist arg list.  [97/01/20]
 *   (8) Move procedure algor to com97 due to CSegment problem.    [97/02/01]
 *   (9) relinit: remove power-up clearing of duTec master address [97/03/23]
 *         in vvp valve section.
 *  (10) errview: remove optomux_protocol toggling capability.     [97/03/23]
 *         Never used.  Probably never worked and caused problems
 *         when Opto22and duTec used in mixed facilities.
 *  (11) statdis: output site_tz text after time in main menu.     [97/04/10]
 *  (12) gasflow(), sampling(): nonlinear Kurz flow meter option.  [97/04/12]
 *  (13) algorithm():    set pidfactor[] := awspeed[]              [97/04/14]
 *  (14) Change occurences of CO2 to GAS where relevant.           [97/04/18]
 *  (15) Add setting of new var num_conditionals in proc tinter;   [97/04/19]
 *  (15) tinter: add propc[] as 4th conditional fumigation value.  [97/04/20]
 *  (16) dataflow, tinter: optomux raw data flow ring selectable.  [97/04/20]
 *  (17) analog_in: digital := $7FFF And adc_read range protection.[97/04/25]
 *  (18) sampling:  make underflow test < 100 ppm for NV startup.  [97/04/25]
 *
 * Version:     26
 * Date:        May-August 1997
 * Changes:
 *   (1) Uses: add new licor.pas unit to list.                     [97/05/14]
 *   (2) relinit, sampling, ambient_mp: make use of licor.pas.     [97/05/14]
 *   (3) Switch from snapshot_ray (DS) to snapshot_ray^ (Heap).    [97/05/18]
 *   (4) watchdog(): restructure; add WDT500P and WDT501P.         [97/05/21]
 *   (5) Use errgrab with watchdog at beginning of tinter;         [97/05/21]
 *   (6) relinit: special ITCT-1 initialization for NV1.           [97/06/13]
 *   (6) algorithm: put 120% of offscale limit on cinteg.          [97/07/01]
 *   (7) tinter(): extensive changes to implement debugging manual [97/07/08]
 *                 of fan and gas qt valve switches.
 *   (8) removed !!! WIO emergency code.                           [97/07/08]
 *   (9) myriad changes related to new list_addr_ptr on heap       [97/07/08]
 *  (10) errview: use ps0?.label_name instead of PS #?             [97/07/20]
 *  (11) errcheck/bittest: implement false positive killing        [97/07/21]
 *  (12) errclear: also resets the errseq[][].count                [97/07/21]
 *  (13) tinter: use var do_dialout to activate watchdog for       [97/07/21]
 *               persistent selected alarms
 *  (14) tinter: for NV1 only, dialout if a encltemp[ring] > 35 oC [97/07/22]
 *  (15) tinter: insert some temporary IF topo[ring] IN [1..4]]    [97/07/22]
 *  (16) ambient_mp: change inputs from 6 to 7                     [97/07/29]
 *  (17) err*: add encl temp (11) and stuck wind direction (12)    [97/07/29]
 *  (18) tinter: no longer need special NV dialout on encl temp    [97/07/29]
 *  (19) statdis: output ring descriptor on first line of menu     [97/07/31]
 *  (20) errcheck: change wind dir std trip from <1 to <0.5 deg    [97/08/01]
 *  (21) errcheck: remove the wind direction stuck alarm for now   [97/08/05]
 *  (22) gasflow(), sampling(): 4-parameter Kurz meter fit.        [97/08/05]
 *
 * Version:     27
 * Date:        September-December 1997
 * Changes:
 *   (1) average(), err*(): new wind dir stuck method              [97/09/25]
 *   (2) watchdog(): FFPWC1.0C(ISA) and Serial options added       [97/09/25]
 *   (3) watchdog(): execute only if watchdog_debug is false       [97/09/28]
 *   (4) err*(): change wdstuck init to 1 & test to 0.5 (from 2&1) [97/09/28]
 *   (5) errview(): diagnostics output of errseq parameters        [97/10/01]
 *   (6) tinter(): live output of do_dialout to alarm page 1       [97/10/01]
 *   (7) errcheck/bittest(): move inc of errsq.count to errset()   [97/10/01]
 *   (8) errreset(): new                                           [97/10/01]
 *   (9) ambient_mp(): must detect whether FACTS-I is 3x2 or 6x1   [97/10/10]
 *  (10) dataflow(): temporarily limit ambient_mp loop to 1 TO 4   [97/10/10]
 *  (11) rring(): Code to resolve conflicting commands to VVP valv [97/10/19]
 *  (12) errcheck(): alarm on ambient in default only if mode 1..2 [97/10/20]
 *  (13) algor(): add constant array wio3 for FACTS-II O3 profile  [97/10/20]
 *  (14) algor(): activate enrich_mode=3 as an absolute profile    [97/10/20]
 *  (16) algor(): change cinteg limit from 1.20 offscale to 1.10   [97/10/21]
 *  (17) tinter(): on off-->on transition of fumigation_enabled    [97/10/23]
 *         reset cinteg and proplearn to 0.0.  This done to ensure
 *         slow startup of O3 treatment (and now everything else!).
 *  (18) rring(): comment out some AZ1 code to gain some needed CS [97/10/23]
 *  (19) relinit(): k-command, code=18 for NC1 R2 air temp probe   [97/12/16]
 *
 * Version:     28
 * Date:        December 1997
 * Changes:
 *   (1) Becomes COMP98.pas; update Uses except leave as ser95.    [97/12/23]
 *   (2) Remove metrabyt from Uses.                                [97/12/23]
 *   (3) Comment out 'MP' & 'MS' code in analog/digital_in/out().  [97/12/23]
 *   (4) relinit(): remove IF ringdaqc.protocol = 'MP' statement.  [97/12/23]
 *   (5) rring(): remove IF site_id='AZ1' code.                    [97/12/23]
 *   (6) tinter(): remove IF site_id='AZ1' code setting fan/qt bits[97/12/23]
 *   (7) sampling(): more of the same AZ1 code removal.            [97/12/23]
 *   (8) Replace gcgrab, gc1min, gcambi, gctarget -- see COMD98.   [97/12/29]
 *   (9) dataflow(), average(), histogram(), files(): replace      [97/12/29]
 *         occurences of agc1hr[] and aagc1hr by agc5m[], aagc5m.  [97/12/29]
 *  (10) Replace gcamb[] by gccntl[]; add gcambi[] assignments.    [97/12/29]
 *  (11) Replace gcont[], ggcont by gcgrab[], ggcgrab.             [97/12/30]
 *  (12) Replace airtemp, encltemp by temp1, temp2.                [97/12/30]
 *  (13) Remove 'gaincode' declaration and assignments.            [97/12/30]
 *  (14) Remove 'gaincode'. Use 'range' in analog_in().            [97/12/30]
 *  (15) Begin making use of new proc 'outband' from COMU          [97/12/31]
 *  (16) relinit(): rewrite temp probe init code using 'range'     [97/12/31]
 *  (17) relinit(): add pressure to LiCor FACE IRGA print list     [97/12/31]
 *  (18) relinit(): and add water vapor pressure in Pa             [98/01/01]
 *  (19) analog_in(): do not execute if channel not in 0..15       [98/01/01]
 *  (20) sampling(): if channel for temp2, barometric pressure and [98/01/01]
 *         /or H2O vapor pressure are 21, get Tcell, Patm, pH2O from
 *         from the gcgrab LiCor, which must be 21!
 *  (21) tinter1(): remove unnecessary/incorrect decl of ymd & hms [98/01/01]
 *  (22) statdis()/status(): display DOY after Date.               [98/01/01]
 *  (23) tinter(): load global var 'doy' after currentday/helios.  [98/01/01]
 *  (24) move procedure statdis() and status() to COMS.            [98/01/01]
 *  (25) gasflow(): new method for handling nonlinear Kurz meter.  [98/01/04]
 *
 * Version:     29
 * Date:        February/April/May 1998
 * Changes:
 *   (1) relinit: possibly initialize [control] for LiCor RS232.   [98/02/09]
 *   (2) sampling: possibly read [control] by RS232 direct.        [98/02/09]
 *   (3) tinter: replace gas_flow conditional ok by wind_lowest.   [98/04/02]
 *   (4) Change from Uses ser95 to ser98.                          [98/04/19]
 *   (5) sampling(): add CSI HMP35C thermistor for temp1 and temp2 [98/04/29]
 *   (6) analog_in(): add thermistor (range 200 to 299)            [98/04/29]
 *   (7) files: comment out stat writing for code space            [98/04/29]
 *   (8) sampling(): add ADC read of conc_ambi (BUT SEE AMBIENT MP)[98/04/30]
 *   (9) dataflow(): enable showing of ambient conc dataflow_var   [98/04/30]
 *  (10) ambient_mp, sampling, tinter: use licor6262_toggle        [98/05/03]
 *  (11) comments: PARR, DISP, VALV primary files become .SET      [98/05/27]
 *  (12) errcheck: enclosure temp alarm point now a var            [98/05/30]
 *  (13) errcheck: fix windstuck logic when wind down              [98/05/30]
 *  (14) errview: hidden alt-T key to change encl temp alarm set[] [98/05/30]
 *  (15) sampling: fix cont_conc [NUMRINGS+iring] indexing err     [98/05/30]
 *  (16) algor: EMERGENCY -- if WI1 & NOT fan_rotation -> propc=0  [98/05/30]
 *
 * Version:     30
 * Date:        July-August 1998
 * Changes:
 *   (1) replace licor6262_toggle/_read by licor6262_input.        [98/07/03]
 *   (2) tinter: call to licor6262_clear before sampling.          [98/07/03]
 *   (3) relinit: set nchcodes=3, i.e. drop pH2O read.             [98/07/03]
 *   (4) relinit: set count_rest=50, i.e. skip 50'th read.         [98/07/03]
 *   (5) ambient_mp, sampling():                                   [98/07/11]
 *       use dataflow_var[1,12] for ambient_mp work space          [98/07/11]
 *       make inputs a variable and assign for NC1 or AZ2          [98/07/11]
 *       expand CASE valve OF to include ring & class assignments  [98/07/11]
 *       replace ring by rep                                       [98/07/11]
 *       fix the NC INC(rep) crap                                  [98/07/11]
 *       misc di bits changed to allow more than 4 reps            [98/07/11]
 *   (6) ambient_mp, relinit():                                    [98/07/13]
 *       local procedure licor_init for all RS232 LiCors           [98/07/13]
 *       ambient mp licor basis changed from $80 to $00            [98/07/13]
 *   (7) sampling(): [2x] maybe use pH2O slot for amb_mp[]fumi     [98/07/15]
 *   (8) ambient_mp(): new ambient mp sequence as per B.Kimball    [98/07/29]
 *   (9) sampling(): [2x] switch (7) from pH2O to air temp         [98/07/29]
 *  (10) sampling(): pH2O[iring]=pH2O[1] (AZ2 only)                [98/07/29]
 *  (11) relinit(): go back to 4 values from a LiCor -- see (3)    [98/07/29]
 *  (12) ambient_mp(): define separate flow_on var                 [98/07/29]
 *  (13) ambient_mp(): flow_on must be inverted for AZ2            [98/07/29]
 *  (14) procedures setco2qt(); average(); histogram(); flasher(); [98/08/18]
 *       moved to COMS to make some more code segment space.
 *  (15) make changes (16-22) done originally for the .AZ2 version [98/08/20]
 *  (16) relinit(): AZ2 ONLY -- initialize temp_auxiliary.         [98/08/01]
 *  (17) sampling(): AZ2 ONLY -- read in temp3 (cntl encl temp)    [98/08/01]
 *  (18) errcheck(): define var "higher_temp" (see below)          [98/08/01]
 *  (19) errcheck(): AZ2 ONLY -- use higher of temp2 or temp3      [98/08/01]
 *  (20) dataflow(): AZ2 ONLY -- show the slaved cntl encl temps   [98/08/01]
 *  (21) analog_in(): Optomux ADC board read mask is $00FF ex CH1  [98/08/01]
 *  (22) sampling(): [2x] switch (7) from air temp to solar        [98/08/01]
 *  (23) relinit/licor-init: nchcodes for TN1 = 3                  [98/08/25]
 *  (24) analog_in(): RS232 reading of a LiCor moved here.         [98/09/24]
 *  (25) sampling():  RS232 reading of a LiCor moved to analog_in. [98/09/24]
 *  (26) ambient_mp:  RS232 reading of a LiCor moved to analog_in. [98/09/24]
 *  (27) relinit: modifications for generalized LiCor handling.    [98/09/25]
 *  (28) ../licor_init: modifications for generalized RS232 LiCor. [98/09/25]
 *  (29) ambient_mp: changes related to partial encapsulation of mp[98/10/25]
 *  (30) sampling:   changes related to partial encapsulation of mp[98/10/25]
 *  (31) dataflow: show the new ambmp_hardware_var^.digital_in     [98/10/25]
 *  (32) files: had I- and I+ instead of $I- and $I+               [98/11/21]
 *  (33) files: add local ior: INTEGER                             [98/11/21]
 *  (34) files: add code to write LOGGs to network drive           [98/11/21]
 *  (35) files: deaden code to log binary logg to net.             [98/12/03]
 *  (36) files: above replace by call to logg2net in comlog.       [98/12/03]
 *  (37) Add Uses comlog98; in Implementation section.             [98/12/03]
 *  (38) ikbin: replace BIOS call by ReadKey.                      [98/12/08]
 *
 * Version:     31
 * Date:        1999
 * Changes:
 *   (1) Uses faced99 (instead of 98).                             [99/01/15]
 *   (2) tinter: change NOT simul_mode to NOT archive_mode         [99/01/27]
 *               for the two calls to watchdog().
 *   (3) multiport: delete CONST ctype; use mp[].protocol instead  [99/01/28]
 *   (4) multiport: INIT/DISC/FLAG changes for net file option     [99/01/28]
 *   (5) Use new field names logging to net.                       [99/01/28]
 *   (6) analog_in(): "300" range                                  [99/02/12]
 *   (7) sampling():  handle changing RH probe into pascals        [99/02/12]
 *   (8) algorithm: custom profile - WI  use 2 packed parameters   [99/04/11]
 *   (9) algorithm: custom profile - TN  new (absolute day & nite) [99/04/11]
 *  (10) files: read any initialized netinfo files.                [99/04/21]
 *  (11) analog_in: handle range code 9xx (netinfo).               [99/04/21]
 *  (12) files: add local procedure 'special_file' now for WI1 WIN [99/04/29]
 *  (13) files: call to 'special_file' at data logging time        [99/04/29]
 *  (14) relinit: do not try to init fan_onoff_fumi or pv_cntrl    [99/05/02]
 *                digital or analog boards if they don't exist
 *  (15) files: 'special_file' now uses netinfo_write              [99/05/10]
 *  (16) kbin: toggle 'super_switch' on Ctrl-J                     [99/05/15]
 *  (17) analog_in: put super_switch debugging in net_info section [99/05/15]
 *  (18) sampling: don't do RH-->VP calculation if sensor not exist[99/05/15]
 *  (19) analog_in/sampling: comment out use of super_switch       [99/06/04]
 *  (20) analog_in: type 9xx -- use function return, not array val [99/06/04]
 *  (21) (changes related to ambient mp forgot to record)          [99/06/25]
 *  (22) tinter: use cinteg[]:=preset[], not :=0.0. See V27#17.    [99/07/07]
 *  (23) ambient_mp_config (READ/SHOW): new procedure.             [99/07/12]
 *  (24) ambient_mp_init: new procedure.                           [99/07/13]
 *  (25) tinter: call ambient_mp_init if previous error condition. [99/07/13]
 *  (26) reldisc: disconnect ambient mp if any.                    [99/07/13]
 *  (27) ambient_mp: extensive changes.                            [99/07/13]
 *  (28) relinit/licor_init: don't init amb_mp if different port.  [99/07/15]
 *  (29) digital_in/out:  add "protocol" to argument list.         [99/07/15]
 *  (30) ambient_mp_*: moved to new unit AMBMP.PAS.  Add Uses.     [99/07/15]
 *  (31) watchdog/parallel: implement code for LPTx.               [99/08/04]
 *  (32) errview: Alt-A switch to toggle audible alarm testing.    [99/09/04]
 *  (33) tinter:  licor6262_clear(0) --> (-1).                     [99/09/10]
 *  (34) gasflow: tolerance_absolute=tolerance*(offscale+2*setto)  [99/09/10]
 *  (35) gasflow: default nonlinear offscale .response, not .cont~ [99/09/10]
 *  (36) errview/optomux_errout: Assign, Append/REWRITE, Close     [99/09/13]
 *  (37) analog_in: replace postions := by select[]                [99/09/29]
 *  (38) tinter: for DE only, load ambient mp readings into R2 & R3[99/10/04]
 *  (39) errcheck: wind stuck -- cover possible WS sensor is dead  [99/10/06]
 *  (40) gasflow: Manual 3: cont_use := resp_use; --> propc        [99/10/07]
 *  (41) errview: hidden alt-M key to SetTOMult comm timeout       [99/11/14]
 *  (42) ikbin: map alt-Q (0,16) to be alternate for ESC (27)      [99/12/12]
 *  (43) ikbin: map alt-1..0 keys (0, 120..129) to F1..F10         [99/12/13]
 *
 * Version:     32
 * Date:        1999-2000
 * Changes:
 *   (1) Unit name and Uses changed to '99.                        [99/12/13]
 *   (2) Uses $IFDEF TURBO | DELPHI                                [99/12/14]
 *   (3) dataflow, tinter: replace 'class' by 'group'              [00/01/19]
 *   (4) IFDEF DELPHI does not Uses cts10_unit                     [00/01/19]
 *   (5) tinter: cts10_display call only IFDEF TURBO               [00/01/19]
 *   (6) IFDEF DELPHI involkes $H-                                 [00/01/19]
 *   (7) dataflow: for raw add hidden D-switch for comm_dp4_debug  [00/01/20]
 *   (8) relinit: $FFFF Shl ch --> mask And (mask Shl ch)          [00/01/21]
 *   (9) make_msg_fast: Copy & Paste of COMLOG99 make_msg          [00/01/25]
 *  (10) make_msg_fast: edit to operate on realtime memory vars    [00/01/25]
 *  (11) tinter: at end add calls to make_msg_fast & netinfo_write [00/01/25]
 *  (12) files: don't read (and close!) a writeonly at logging time[00/01/27]
 *  (13) files: cancel (12); this being handled by netinfo_read.   [00/01/27]
 *  (14) files: add local procedure print_error.                   [00/01/28]
 *  (15) files: in LOGG section, get IOResult and maybe print_error[00/01/28]
 *  (16) files: in VARR section, do the same                       [00/01/29]
 *  (17) files: fix infinite loop WHILE bug                        [00/01/30]
 *  (18) files: remove binary net logging code deadened 12/3/98    [00/01/31]
 *  (19) tinter: for fast netinfo_write use MOD sep instead of eol [00/02/03]
 *  (20) tinter: call netinfo_reduce call after _write call        [00/02/07]
 *  (21) Uses: for IFDEF DELPHI add graph32                        [00/03/08]
 *  (22) tinter: add call to windows_message_loop to get them      [00/03/08]
 *  (23) tinter: forgot to surround #22 with IFDEF DELPHI ENDIF!   [00/03/16]
 *  (24) dataflow: change alternate data color LightBlue to Cyan   [00/04/17]
 *  (25) errview: add mouse awareness at two levels                [00/04/20]
 *  (26) dataflow: add mouse awareness at many places              [00/04/21]
 *  (27) ikbin: do a mouse to key conversion if alr=255            [00/04/22]
 *  (28) calls to mouse_add now need button mask                   [00/04/25]
 *  (29) gasflow: mouse aware (Win32 only)                         [00/04/26]
 *  (30) gasflow: calibration point mouse columns 1 to 3 only      [00/05/07]
 *  (31) gasflow/INIT: crash protection defaults u, V, ErrReturn   [00/05/07]
 *  (32) relinit/licor_init: local procedure elevated to full rang [00/06/15]
 *  (33) licor_init: remove setting of comm_err[iring]             [00/06/15]
 *  (34) relinit: loop over licor_init(all) removed (see #35)      [00/06/15]
 *  (35) tinter: initialize licors that need it at sampling time   [00/06/15]
 *  (36) gasflow/INIT: message and halt if VALV file not found.    [00/09/07]
 *  (37) files: make .needs_reset=TRUE; do no reset .latched here. [00/09/07]
 *  (38) tinter: reset .latched during status calculation, if nec. [00/09/07]
 *  (39) multiport & gasflow: replace Halt; by Halt (7xx);         [00/09/26]
 *  (40) tinter: .latched := rhex[no] corrected to [ninter] !!!!!! [00/10/02]
 *  (41) tinter: check mark | epsilon for .NET after <F4> Data log [00/10/04]
 *  (42) daqerrs: mods required for new ISO 8601 showdate/showtime [00-10-12]
 *  (43) isrunon: load solar_ton/toff directly; don't use showtime [00-10-12]
 *  (44) Implementation Uses: add musca to list                    [00-11-07]
 *
 * Version:     33
 * Date:        2001
 * Changes:
 *   (1) tinter: if DE1 load agc1|5m[2|3] from ambmp as well       [01/06/07]
 *   (2) sampling: change Vx & Vs arguments in therm107 calls      [01/06/07]
 *   (3) Uses: add tei49c                                          [01/09/19]
 *   (4) analog_in: add code for TEI serial (channel 40..49)       [01/09/19]
 *
 * Version:     34
 * Date:        2002
 * Changes:
 *   (1) Unit name change from comp99 to comp                      [02-03-21]
 *   (2) Change Uses comd99 to Uses comd, etc.                     [02-03-21]
 *   (3) Remove $IFDEF TURBO code $ENDIF, $IFDEF DELPHI $ENDIF     [02-03-25]
 *   (4) conditional_test: calculate/save conditional_state[][]    [02-03-25]
 *   (5) tinter: status - NOT conditional_state[][temp] bit 9      [02-03-25]
 *   (6) tinter: status - NOT conditional_state[][wind] bit 15     [02-03-25]
 *   (7) Uses debuglog                                             [02-05-23]
 *   (8) dataflow: debugging log file enable/disable menu added    [02-05-23]
 *   (9) files: at .DAT file write time, flush the DebugLogFile    [02-05-23]
 *  (10) dataflow: (8) continued; fix some annoyances              [02-05-26]
 *  (11) gasflow: pipe_id_other: float (for Delphi 6)              [02-06-11]
 *  (12) tinter: don't set fan or co2 bits if they don't exist     [02-06-27]
 *  (13) special_file: change logic; 901 now reserved for WI N     [02-07-10]
 *  (14) special_file: add [O3] control as 5th 901 field           [02-07-10]
 *  (15) special_file: #13 logic needs IF netinfoinstalled AND     [02-07-18]
 *  (16) add Forms to local Uses list                              [02-09-14]
 *  (17) kbin: add Application.ProcessMessages to wait loop        [02-09-14]
 *  (18) IF statscr THEN disk(datapath); statements removed        [02-09-15]
 *  (19) functionality of procedure errview moved to Alarms.pas    [02-11-16]
 *  (20) functionality of procedure watchdog moved to Watchdog.pas [02-12-02]
 *  (21) Data flow, raw:  remove hidden D-swtich (comm_dp4)        [02-12-06]
 *  (22) files: remove STAT file section                           [02-12-17]
 *  (23) tinter: do NOT clear errs on an off-to-on transition      [02-12-17]
 *  (24) errcheck, errset, errreset: moved to Alarms               [02-12-17]
 *
 * Version:     35
 * Date:        2003
 * Changes:
 *   (1) Changes related to new LPF objects                        [03-01-05]
 *   (2) algorithm: simplify ambient_base calculation              [03-01-06]
 *   (3) tinter: RangeMin/Max for the conditional_value objects    [03-01-06]
 *   (4) ephemeris: moved here from COMDIS via COMS                [03-01-07]
 *   (5) h2ovapor:  moved here from COMDIS via COMS                [03-01-07]
 *   (6) Replace IFDEF CLX ELSE->IFDEF LINUX ENDIF IFDEF MSWINDOWS [03-01-24]
 *   (7) Add LineGraf to USES; calls to HeartBeat and UpdateIt     [03-03-14]
 *   (8) Delete procedure ephemeris; functionality in Ephem.pas.dfm[03-03-17]
 *   (9) Add call to Ephem.UpdateIt                                [03-03-17]
 *  (10) tinter: remove IF statscr THEN statdis(no)                [03-03-19]
 *  (11) algor: moved here from FCP.DPR                            [03-03-19]
 *  (12) tinter: set inrings false if IsWindow is not true         [03-03-20]
 *  (13) ikbin: make use of new graph32 Event record               [03-05-09]
 *  (14) kbin: loop until OR graph32.Event.Flag as well            [03-05-09]
 *  (15) tinter: new (null) argument list for windows_message_loop [03-05-09]
 *  (16) kbin: bracket Appl~.Proc~Mess~ w/ windows_message_loop    [03-05-09]
 *  (17) ikbin: echo windows F or G; otherwise locks up !!!        [03-05-10]
 *  (18) ikbin: escape if no mouse to key map; otherwise locks !!! [03-05-10]
 *  (19) tinter: call H2OVapor.UpdateIt                            [03-05-26]
 *  (20) tinter: remove use of new_sample[ring]                    [03-05-26]
 *  (21) tinter: delete procedure h2ovapor()                       [03-05-26]
 *  (22) comd/Globals changes                                      [03-05-28]
 *  (23) tinter/runon[]: (NOT shut[]) -> (oper[] OR debug[])       [03-05-31]
 *  (24) algorithm/propc[]: this was a staged shutdown bug!        [03-05-31]
 *    IF oper[no] AND runon[no] -> runon[no] AND (NOT debug[no])
 *    IF oper[no] AND (NOT runon[no]) -> (NOT runon[no]) AND (NOT debug[no])
 *  (25) rring: loading from new pattern IF oper -> IF NOT debug   [03-05-31]
 *  (26) files: Uses NetLog.logg2net(ring)                         [03-05-31]
 *  (27) ikbin: negate #17 & #18; see use of Sleep in riv.pas      [03-06-15]
 *
 * Version:     36
 * Date:        2004
 * Changes:
 *  (1) algor/submenus for conditionals: <F10> TLPF[r][n].ShowDump [04-02-29]
 *  (2) tinter: delete num_conditionals := 4; now in COMD Init...  [04-02-29]
 *  (3) tinter: status bit 15 - either wind test bad (ind or low)  [04-06-22]
 *  (4) dataflow/ambmp section: add rep_select array and use it    [04-07-01]
 *  (5) dataflow/ambmp section: remove rep_select array            [04-07-07]
 *  (6) dataflow: remove Ambient MP related code in key 19 only    [04-07-07]
 *  (7) In Uses replace ambmp by MPSample.                         [04-07-08]
 *  (8) Add call to MPSample.UpdateIt                              [04-07-12]
 *  (9) sampling: move setting tint_last to MPSample.ambient_mp    [04-07-15]
 * (10) sampling: simulation - ambmp dataflow set once only        [04-07-16]
 * (11) analog_in: add reading of imbedded multiport (range 800)   [04-07-22]
 * (12) tinter/DE1: delete loading ambmp R2 & R3; use range 800    [04-07-22]
 * (13) sampling, tinter: massive range 800 changes                [04-07-22]
 * (14) COMP/licor_init: renamed licor_start                       [04-08-01]
 * (15) tinter: call to licor_init now licor_start                 [04-08-01]
 * (16) analog_in, licor_start, tinter: licor6262_* refs to licor_*[04-08-01]
 * (17) licor_start: remove count_rest=50, but see licor/licor_init[04-08-02]
 * (18) dataflow: show aux temp on temperature page if AZ2 or NV1  [04-10-03]
 * (19) sampling: replace IF AZ2 by temp_auxiliary.exists (2X)     [04-10-03]
 * (20) relinit: remove IF AZ2 for temp_auxiliary; use exists      [04-10-03]
 * (21) tinter: move call to files; outside sampling section       [04-10-26]
 * (22) files:  loggcount[] reinitialized to 0 (was 1)             [04-10-27]
 * (23) ambmp_hardware_var^ changed to ambmp_hardware_var          [04-12-02]
 * (24) algorithm: add ZA1 SANBI chambers specific code            [04-12-03]
 * (25) algorithm: testlimit := x --> ABS(x)                       [04-12-03]
 * (26) tinter: add call to Compare.UpdateIt                       [04-12-09]
 * (27) Implementation Uses: Compare added                         [04-12-09]
 * (28) algorithm: ZA1 [CO2] valid range 50-2000, was 100-1500     [04-12-09]
 *
 * Version:     37
 * Date:        2005
 * Changes:
 *  (1) dataflow: show aux temp on temperature pg if AZ2 NV1 | WI1 [05-05-05]
 *
 * Version:     38
 * Date:        2006
 * Changes:
 *  (1) Interface Uses: replace tp5utils by AVSD, Sol              [06-04-30]
 *  (2) Replace errstring() by SysUtils.SysErrorMessage()  3 times [06-04-30]
 *  (3) multiport/err_check: SetLastError $20003001                [06-09-23]
 *
 * Version:     39
 * Date:        2007
 * Changes:
 *  (1) sampling/sim: use essentially fixed wd for each ring       [07-02-28]
 *  (2) algorithm: vaporizer temp trip protection for TN1 only     [07-02-28]
 *  (3) rring: special NC1 only code for testing 8 vs 10 vvp open  [07-02-28]
 *  (4) rring: NC1 March 2007 only code - 8 VVP is now default     [07-03-13]
 *  (5) algor: WI1 O3 PEAK limited to 120 ppb (was 100)            [07-06-14]
 *
 * Version:     40
 * Date:        January 2009
 * Changes:
 *  (1) analog_in/TEI: add error := error OR (volts >= offscale)   [09-01-22]
 *      This will cause comm_err[no] to be set.  This will suppress
 *      bad flagged values (555, 9992, etc.) from getting into integrals.
 *      Do not know if this will have any bad side effects at this time.
 *
 * Version:     41
 * Date:        2009
 * Changes:
 *  (1) multiport: delete protocol 'SB' serial bios link support   [09-08-07]
 *  (2) multiport: delete link argument; there is now only 1       [09-08-10]
 *  (3) Deleted already commented out Metrabyte parallel & serial  [09-08-10]
 *  (4) move_motor: delete already commented our bipolar PS code   [09-08-10]
 *  (5) Other extensive changes related to DataComm.Ports[]        [09-08-11]
 *  (6) analog_in: recognize "channel" 24 (LI840)                  [09-08-17]
 *
 * Version:     42
 * Date:        2011
 * Changes:
 *  (1) super_switch: remove all references                      [2011-09-23]
 *  (2) analog_in: add code for Festo CPX FEC                    [2011-09-23]
 *  (3) sampling: add call to analog_in for vvp pressure sensor  [2011-09-23]
 *  (4) sampling: set Pvvp[ring] = dataflow_var[ring,14].value   [2011-09-26]
 *  (5) tinter: add variables fan_boolean, gas_boolean           [2011-09-27]
 *              add fan/gas on/off section for protocol FE
 *              latter does not support a rep's control ring fan
 *  (6) digital_out: add protocol = FE option code               [2011-10-04]
 *                   delete not longer needed protocol argument
 *  (7) rring: handle either 8 or 16 VVP's per command to DO     [2011-10-18]
 *  (8) gasflow/move_motor: add code for Festo CPX-FEC           [2011-10-19]
 *                          delete CONST maxpulse (not used)
 *  (9) sampling: add code for direct read PORT_GA, _WIND        [2011-10-26]
 * (10) analog_in: add code for range 400 ascii line devices     [2011-10-27]
 * (11) analog_in: remove objFestoCI.Open/.Close sandwich        [2011-11-02]
 *    digital_out: remove objFestoCI.Open/.Close sandwich        [2011-11-02]
 *     move_motor: remove objFestoCI.Open/.Close sandwich        [2011-11-02]
 *         tinter: remove objFestoCI.Open/.Close sandwich        [2011-11-02]
 * (12) tinter: add objFestoCI.Open when begin sample/control    [2011-11-02]
 * (13) rring: needs refresh logic changed slightly              [2011-11-02]
 * (14) digital_in: remove Metrabyte MP and MS code              [2011-11-02]
 *                  add Festo CPX FEC code                       [2011-11-03]
 * (15) digital_in: set value=0 if there has been an error       [2011-11-09]
 * (16) tinter: objFestoCI.Close before .Open; otherwise get     [2011-11-14]
 *        error 10055 because ephemeral port resources used up
 * (17) sampling: add code for direct read PORT_LOGGER_1         [2011-12-01]
 *
 * Version:     43
 * Date:        2012
 * Changes:
 *  (1) files: LOGG2NET no longer inside buffering loop          [2012-05-01]
 *  (2) Implementation Uses: add IPServ                          [2012-05-03]
 *  (3) kbin: add call to IPServ.Process                         [2012-05-03]
 *  (4) tinter: calls to .Process, .Close & .Open at end sampling[2012-05-03]
 *  (5) kbin: remove Process call -- never getting there!        [2012-05-04]
 *  (6) tinter: call .Process near entry, i.e. every time        [2012-05-04]
 *  (7) gasflow/METER/nonlinear: change err test from <0.9 to 0.8[2012-06-28]
 *  (8) multiport: remove protocol='IN'; now network file only   [2012-07-13]
 *  (9) multiport: remove all mp3s_ and _mp3s related code       [2012-07-13]
 * (10) multiport: remove TIME option                            [2012-07-13]
 * (11) dataflow:  remove mp3s debugging code; nothing for now   [2012-07-13]
 * (12) multiport: reformat, rearrange, add to output file       [2012-07-17]
 * (13) tinter1: change tmplinklast := tint; to := 0.0;          [2012-07-17]
 * (14) multiport: add ambient_base.Integral to variable list    [2012-07-20]
 * (15) multiport, relinit, reldisc: drop INIT and DISC commands [2012-07-24]
 *        Functionality now in DataComm
 * (16) multiport: remove err_check and link2mp local procedures [2012-07-24]
 * (17) multiport: add calls to objLineIn.OutputDebug            [2012-07-25]
 * (18) analog_in: change objLineIn.DataGet(channel) to ValueGet [2012-07-30]
 * (19) tinter1: initialization of tfcplinklast[] := 0.0;        [2012-08-01]
 * (20) tinter:  reinitialization of tfcplinklast[] at midnight  [2012-08-01]
 * (21) tinter:  code to get existing FCPLink inside samp/cont   [2012-08-01]
 * (22) sampling: replace PORT_LOGGER_1 by PORT_LOGGER_BASE+i    [2012-08-23]
 * (23) sampling: analog read of dataflow_var[,15] ambient base  [2012-08-24]
 * (24) sampling: set AmbientBaseValue[] = datalow_var[,15].value[2012-08-24]
 * (25) dataflow by ring: Pvvp, AmbientBaseValue now output      [2012-08-24]
 * (26) algorithm: add cases for ambient base value calculation  [2012-08-25]
 *      algorithm: write cases 1 and 2 candidates to objMPGroup  [2012-08-26]
 *      showit: new little procedure needed to this reasonable   [2012-08-26]
 *      showit: add a little bit of description (hint)           [2012-08-27]
 * (27) tinter: "new day" test now (tint-tintlast) < (-60)       [2012-11-13]
 *              due to frequent negative AboutTime corrections in AU
 *
 * Version:     44
 * Date:        2013 in Cape Town
 * Changes:
 *  (1) algorithm: In ZA1 part replace ELSE BEGIN by             [2013-12-15]
 *                 ELSE IF (run_mode) THEN BEGIN in valve pulsing
 *                 section.  Was accessing data comm when in
 *                 simulation mode.
 *
 * Version:     45
 * Date:        2014
 * Changes:
 *  (1) gasflow ('METER': scaling of final non-linear flow       [2014-02-27]
 *        Had to add list_addr_ptr[ringno]^.pv_response to WITH
 *
 * Version:     46
 * Date:        2016
 * Changes:
 *  (1) Add time stamps to PORT_MPLINK debugging output          [2016-07-30]
 *}

PROCEDURE algor (no: INTEGER);
PROCEDURE algorithm(no: INTEGER);
PROCEDURE dataflow (kall: INTEGER);
PROCEDURE gasflow (command: String; ringno: INTEGER);
PROCEDURE files;
PROCEDURE caccept;
PROCEDURE raccept (VAR rvalue: float);
PROCEDURE iaccept (VAR lvalue: Longint);
PROCEDURE saccept;  {from con accept chars including CR into 'svalue'}
PROCEDURE daccept;  {from console accept only digits into 'svalue'}
PROCEDURE ikbin;
PROCEDURE kbin;
PROCEDURE pauseat (row, col: INTEGER);
PROCEDURE relinit (iring: INTEGER);
PROCEDURE reldisc;
PROCEDURE rring(no: INTEGER);
PROCEDURE tinter;
PROCEDURE tinter1;
{TEMPORARY FOR AMBMP.PAS SAKE}
PROCEDURE analog_out (port, address, channel: Word; volts: float; 
                      VAR digital: INTEGER; VAR error: BOOLEAN);
PROCEDURE digital_out (port, address, value: Word; VAR error: BOOLEAN);
PROCEDURE analog_in (daqc: daqc_addr; VAR data: dataflow_rec; 
  port: Word; VAR error: BOOLEAN);
PROCEDURE digital_in (protocol: String; port, address: Word; 
                      VAR value: Word; VAR error: BOOLEAN);

Implementation

USES
{$IFDEF LINUX}
  QForms, QGraphics,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Forms, Graphics,
{$ENDIF}
  Windows, SysUtils,
  Main, 
  CalibAut, CalibMan, Compare, DataComm, Ephem, H2OVapor, NetLog, Watchdog,
  Alarms, Status, LineGraf,
  RingBar, FatalErr, Connect, RVSetup,
  IPServ,
  comlog, musca, debuglog;

CONST crlf = CHR(13)+CHR(10);

{------------------------------------------------------------}

PROCEDURE algor (no: INTEGER);
{Set PARR file variables}
CONST firstline = 5;
VAR p: array[1..20] OF INTEGER;
    change,
    submenu,
    need_help: BOOLEAN;
    temp_mode, code: INTEGER;
    temp, temp2, temp3: float;
    i: INTEGER;

PROCEDURE show_value (line, ring, color: INTEGER);
{Display current value of a parameter on proper line.
 If line=0, then recurses all lines.}
VAR i: INTEGER;
BEGIN
  IF line <= 0
    THEN FOR i := firstline TO 25 DO show_value (i, ring, color)
    ELSE BEGIN
      GotoXY(40,line);
      TextColor(color);
      CASE line-firstline+1 OF
        1: BEGIN
             CASE enrich_mode[ring] OF
               0: WRITE ('CONSTANT      ');
               1: WRITE ('ADDITIVE      ');
               2: WRITE ('MULTIPLICATIVE');
               3: WRITE ('CUSTOM PROFILE');
               END; {case}
             CASE enrich_mode[ring] OF
               0,1,2: WRITE (enrich_val[ring][enrich_mode[ring]]:8:3);
               3: BEGIN
                    IF site_id = 'WI1' THEN BEGIN
                      WRITE (funpack(enrich_val[ring][3],1000000,1000):8:3);
                      WRITE (funpack(enrich_val[ring][3],   1000,   1):8:3);
                      END;
                    IF site_id = 'TN1' THEN BEGIN       
                      WRITE (funpack(enrich_val[ring][3],1000000000,1000000):8:3);
                      WRITE (funpack(enrich_val[ring][3],1000000,1000):8:3);
                      WRITE (funpack(enrich_val[ring][3],   1000,   1):8:3);
                      END;
                    END;
               END; {case}
             END;
        2: WITH enrich_base[ring] DO BEGIN
             WRITE (low    :7:0,'=L');
             WRITE (high   :7:0,'=H');
             WRITE (default:7:0,'=D');
             WRITE (int    :7:0,'s=T');
             END;
        3: WRITE (tsamp[ring]:10:3);
        4: WRITE (tcont[ring]:10:3);
        5: WRITE (vvptime[ring].period:10:3);
        6: WRITE (windthr[ring]:10:3);
        7: WRITE (preset[ring]:10:3);
        8: WRITE (falarm[ring]:10:3);
        9: WRITE (calarm[ring]:10:3);
       10: WRITE (gcint[ring]:10:3);
       11: WRITE (wsint[ring]:10:3);
       12: WRITE (wdint[ring]:10:3);
       13: WRITE (pidfactormin[ring]:10:3, pidfactormax[ring]:10:3);
       14: WRITE (ainteg[ring]:10:3);
       15: WRITE (aprop[ring]:10:3);
       16: WRITE (adiff[ring]:10:3);
       17: WRITE (awind[ring]:10:3);
       18: WRITE (tlearn[ring]:10:3);
       19: WRITE (limit[ring]:10:3);
       20: IF conditional_enabled[ring] THEN WRITE ('   ENABLED')
                                        ELSE WRITE ('  DISABLED');
       21: BEGIN
             CASE onoff_mode[no] OF
               0:  WRITE ('       OFF');
               1:  WRITE ('CONTINUOUS'); 
               2:  BEGIN
                     WRITE ('     CLOCK');
                     GotoXY(60,line); WRITE (stimeon[no]);
                     GotoXY(75,line); WRITE (stimeoff[no]);
                     END;
               3:  BEGIN
                     WRITE ('     SOLAR');
                     GotoXY(62,line); WRITE (dawn_altitude[no]:5:3);
                     END;
               END;  {case}
             END;
       END;  {of case}
      END;  {of else begin}
    TextColor(Green);
  END;  {of local procedure 'show_value'}

PROCEDURE ioerrmsg (where: String);
BEGIN
  WRITELN;
  WRITE   (where:5,  '  I/OResult:', ior:1, '  ',
           SysUtils.SysErrorMessage(ior));
  WRITELN ('  Current FileMode:', FileMode:1);
  pauseat (WhereX, WhereY);
  END;  {of local procedure 'ioerrmsg'}

PROCEDURE sidebar (level: INTEGER);
{Print instructions on right side}
BEGIN
  xywrite(55, 8,Yellow,'RING '+rlabel[no]);
  xywrite(62, 8,LightRed,   descriptor[no]);
  xywrite(55, 9,10,'--------------------------');
  xywrite(55,11,10,'<UP DN>   Select field');
  xywrite(55,12,10,'<SP>   Open change window');
  xywrite(55,13,10,'<CR>   Accept new value');
  mouse_clear (0);
  mouse_add (3, 55, 56, 11, 11, 0, 72);
  mouse_add (3, 57, 80, 11, 11, 0, 80);
  mouse_add (3, 55, 80, 12, 12, 32, 0);
  mouse_add (3, 55, 80, 13, 13, 13, 0);
  IF level = 0 
    THEN BEGIN
      xywrite(55,10,10,'<F1>   Help');
      xywrite(55,14,10,'<PgDn> Go to submenu ...');
      xywrite(55,15,10,'<-+>   Another ring');
      xywrite(55,16,10,'<ESC>  Return to main menu');
      mouse_add (3, 55, 80, 10, 10, 0, fkey[1]);
      mouse_add (3, 55, 80, 14, 14, 0, 81);
      mouse_add (3, 55, 56, 15, 15, ORD('-'), 0);
      mouse_add (3, 57, 80, 15, 15, ORD('+'), 0);
      mouse_add (3, 55, 80, 16, 16, 27, 0);
      mouse_add (1, 55, 80, 10, 16, 27, 0);
      mouse_add (2, 55, 80, 10, 16, ORD('+'), 0);
      END
    ELSE BEGIN
      xywrite(55,10,10,'<<- ->>');
      xywrite(55,14,10,'<PgUp> Previous menu');
      mouse_add (3, 55, 56, 10, 10, 0, 75);
      mouse_add (3, 57, 80, 10, 10, 0, 77);
      mouse_add (3, 55, 80, 14, 14, 0, 73);
      END;
  END;  {of local procedure 'sidebar'}

PROCEDURE template;
{Initial text and filling in of variables}
BEGIN
  ClrScr;
  GotoXY (1,firstline);
  TextColor(Green);
  WRITELN ('Enrichment mode');
  WRITELN ('Ambient base calculations ...');
  WRITELN ('Period: sampling [s]');
  WRITELN ('Period: control  [s]');
  WRITELN ('Period: VVP valve refresh [s]');
  WRITELN ('Wind speed threshold level');
  WRITELN ('Proportional valve preset');
  WRITELN ('Alarm trigger: gas mass flow');
  WRITELN ('Alarm trigger: gas concentration');
  WRITELN ('Integration time: gas concentration');
  WRITELN ('Integration time: wind speed');
  WRITELN ('Integration time: wind direction');
  WRITELN ('PID adjustment factor (PAF), min & max');
  WRITELN ('PID coeff: integral           (Ainteg)');
  WRITELN ('PID coeff: proportional        (Aprop)');
  WRITELN ('PID coeff: differential        (Adiff)');
  WRITELN ('PID coeff: wind speed adaptive (Awind)');
  WRITELN ('Wind response learning period [s]');
  WRITELN ('Limit value for proportional control');
  WRITELN ('Conditional fumigation global ...');
  WRITE   ('Operation mode');
  sidebar(0);
  show_value (0, no, White);
  END;  {of local procedure 'template'}

PROCEDURE algor_help;
CONST lines = 9;
      msg: ARRAY [1..lines] OF String[80] =
        ('Control algorithm:  ValveControl = Cinteg + Cprop + Cdiff + Cadapt',
         '     Cinteg = - (PAF * Ainteg) * Int{0-Tint}(GCerror)',
         '     Cprop  = - (PAF *  Aprop) * GCerror',
         '     Cdiff  = - (PAF *  Adiff) * {d/dt}GCerror',
         '     Cadapt =   (AWSpeed-WSpeedLearn) * ValContLearn/(WSpeedLearn+Awind)',
         '',
         'PAF = PAF_MIN if wind speed < PAF_MIN',
         '    = PAF_MAX if wind speed > PAF_MAX',
         '    =            wind speed otherwise');
VAR i: INTEGER;
BEGIN
  ClrScr;
  FOR i := 1 TO lines DO BEGIN
    xywrite (10, i, Magenta, msg[i]);
    WRITELN;
    END;
  pauseat (10,15);
  need_help := FALSE;
  template;
  END;  {of local procedure 'algor_help'}

PROCEDURE new_value (row, col: INTEGER; VAR x: float);
{Get a new floating point value.}
VAR temp: float;
BEGIN
  GotoXY (col,row);
  TextColor (LightRed);
  WRITE ('<        >');
  ClrEol;
  GotoXY(col+1,row);
  raccept (temp);
  IF (svalue <> '') AND (temp <> x) THEN BEGIN
    x := temp;
    change := TRUE;  {change is global to algor;}
    END;
  TextColor(Green);
  END;  {of local procedure 'new_value'}

PROCEDURE submenus (item: INTEGER);
VAR row, rowbase, rowmax,
    col, colbase, colmax: INTEGER;
    i: INTEGER;
    do_pageup: BOOLEAN;
BEGIN
  do_pageup := FALSE;
  IF item IN [2,20] THEN BEGIN
    ClrScr;
    sidebar (1);
    CASE item OF
      2: BEGIN
           TextColor (LightRed);
xywrite( 5,2,-1,
'Note:  Currently, there is only one ambient gas concentration base value');
xywrite( 5,3,-1,
'       calculated for the whole facility.  The parameters are stored in');
xywrite( 5,4,-1,
'       the 1st ring''s memory area and files.  Thus to actually change the');
xywrite( 5,5,-1,
'       ambient base calculation parameters, you MUST make changes from');
xywrite( 5,6,-1,
'       the 1st ring''s window.  (Use +/- keys in previous menu.)');
           TextColor (Green);
xywrite( 5,10,-1,'Lowest  acceptable value for');
xywrite( 5,11,-1,'  valid ambient readings:');
xywrite( 5,13,-1,'Highest acceptable value for');
xywrite( 5,14,-1,'  valid ambient readings:');
xywrite( 5,16,-1,'Default base value to use when');
xywrite( 5,17,-1,'  no valid readings are present:');
xywrite( 5,19,-1,'Integration time (smoothing)');
xywrite( 5,20,-1,'  in seconds:');
           rowmax  := 4;
           rowbase := 10;
           colbase := 40;
           row     := 1;
           WITH enrich_base[no] DO REPEAT
             TextColor (White);
             GotoXY (colbase, rowbase  );  WRITE (low    :7:1);
             GotoXY (colbase, rowbase+3);  WRITE (high   :7:1);
             GotoXY (colbase, rowbase+6);  WRITE (default:7:1);
             GotoXY (colbase, rowbase+9);  WRITE (int    :7:1);
             GotoXY (colbase, rowbase+3*(row-1));
             kbin;
             IF (alr=0) THEN BEGIN
               cursor_row (row, 1, rowmax, ahr);
               do_pageup := (ahr=73);
               END;
             IF (alr=32) THEN BEGIN
               IF row=1 THEN new_value (rowbase+3*(row-1), colbase+1, low);
               IF row=2 THEN new_value (rowbase+3*(row-1), colbase+1, high);
               IF row=3 THEN new_value (rowbase+3*(row-1), colbase+1, default);
               IF row=4 THEN new_value (rowbase+3*(row-1), colbase+1, int);
               END;
             do_pageup := do_pageup OR (alr=27);
             UNTIL do_pageup;
           END;
     20: BEGIN
           TextColor (LightRed);
           xywrite( 5,2,-1,
             'SETTING OF PARAMETERS FOR CONDITIONAL FUMIGATION OF A RING');
           xywrite( 5,3,-1,
             'Fumigation will be shut off if (1) the current value of');
           xywrite( 5,4,-1,
             'the selected variable is not within the LOW to HIGH range,');
           xywrite( 5,5,-1,
             '(2) this variable is ENABLED for conditional testing, and');
           xywrite( 5,6,-1,
             '(3) conditional testing is ENABLED GLOBALLY for THIS RING.');
           TextColor (Green);
           xywrite(1,10,-1,'Title:');
           xywrite(1,13,-1,'Current value:');
           xywrite(1,15,-1,'Enabled:');
           xywrite(1,17,-1,'Integration:');
           xywrite(1,19,-1,'Range -- low:');
           xywrite(1,21,-1,'Range -- high:');
           xywrite(1,23,-1,'Hysteresis:');
           rowmax  := 5;
           colmax  := num_conditionals;
           rowbase := 15;
           colbase := 15;
           row := 1;  col := 1;
           REPEAT
             FOR i := 1 TO colmax DO WITH conditional_var^[no][i] DO BEGIN
{***TEMPORARY  IF ODD(i) THEN TextColor (White) ELSE TextColor (LightGray);}
               GotoXY (colbase+8*(i-1), rowbase-5);  WRITE (Copy(title,1,8));
               GotoXY (colbase+8*(i-1), rowbase-4);  WRITE (Copy(title,9,8));
               GotoXY (colbase+8*(i-1), rowbase-2);  
                 WRITE (conditional_value[no][i].Integral:8:2);
               GotoXY (colbase+8*(i-1), rowbase  );  WRITE (enable:8);
               GotoXY (colbase+8*(i-1), rowbase+2);  WRITE (int:8:0);
               GotoXY (colbase+8*(i-1), rowbase+4);  WRITE (low:8:2);
               GotoXY (colbase+8*(i-1), rowbase+6);  WRITE (high:8:2);
               GotoXY (colbase+8*(i-1), rowbase+8);  WRITE (hysteresis:8:2);
               END;
             GotoXY (colbase+8*(col-1), rowbase+2*(row-1));
             kbin;
             IF (alr=0) THEN BEGIN
               cursor_row (row, 1, rowmax, ahr);
               cursor_col (col, 1, colmax, ahr);
               IF (ahr=68){F10} THEN conditional_value[no][col].ShowDump; 
               do_pageup := (ahr=73);
               END;
             IF (alr=32) THEN WITH conditional_var^[no][col] DO BEGIN
               IF row=1 THEN BEGIN
                               enable := NOT enable;
                               change := TRUE;
                               END;
               IF row=2 THEN new_value (rowbase+2, colbase+9*(col-1), int);
               IF row=3 THEN new_value (rowbase+4, colbase+9*(col-1), low);
               IF row=4 THEN new_value (rowbase+6, colbase+9*(col-1), high);
               IF row=5 THEN new_value (rowbase+8, colbase+9*(col-1), hysteresis);
               END;
             do_pageup := do_pageup OR (alr=27);
             UNTIL do_pageup;
           END;
     END;  {case}
    submenu := FALSE;
    template;
    END;
  END;  {of local procedure 'submenus'}

BEGIN  {procedure proper}
  row := firstline;
  REPEAT  {until <ESC>}

  template;
  FOR i := firstline TO 25 DO
    mouse_add (3, 1, 50, i, i, 0, i);
  change := FALSE;
  submenu := FALSE;
  need_help := FALSE;

  REPEAT  {until <ESC> or another ring requested}
    GotoXY(39,row);  TextColor(Green);  WRITE (' ');
    kbin;
    IF alr=0 THEN BEGIN
      cursor_row (row, firstline, 25, ahr);
      submenu   := (ahr=81);
      need_help := (ahr=59);
      END
    ELSE IF alr=32 THEN BEGIN
      CASE row-firstline+1 OF
        1: BEGIN
             temp_mode := enrich_mode[no];
             REPEAT
               value_cycle (temp_mode, 0,3, ' ');
               GotoXY(40,row);
               CASE temp_mode OF
                 0: WRITE ('  CONSTANT     ');
                 1: WRITE ('  ADDITIVE     ');
                 2: WRITE ('MULTIPLICATIVE ');
                 3: WRITE ('CUSTOM PROFILE ');
                 END; {case}
               ClrEol;
               temp := enrich_val[no][temp_mode];
               WRITE (temp:8:3);
               kbin;
               UNTIL (alr=13) OR (alr=27);
             IF alr=27
               THEN alr := 127
               ELSE BEGIN
                 IF temp_mode IN [0..2] THEN BEGIN
                   new_value (row, 64, temp);
                   IF (temp_mode <> enrich_mode[no]) OR
                      (temp      <> enrich_val[no][temp_mode]) THEN BEGIN
                     enrich_mode[no] := temp_mode;
                     enrich_val [no][temp_mode] := temp;
                     change := TRUE;
                     END;
                   END;
                 IF temp_mode IN [3] THEN BEGIN
                   IF site_id = 'WI1' THEN BEGIN
                     xywrite (64, row, Yellow, 'PEAK');
                     temp2 := funpack (temp,    1000000.0,    1000.0);
                     new_value (row, 68, temp2);
                     IF temp2 > 120.0 THEN temp2 := 120.0;  {limited}
                     temp3 := Int(temp2);
                     xywrite (64, row, Yellow, 'PED ');
                     temp2 := funpack (temp,       1000.0,       1.0);
                     new_value (row, 68, temp2);
                     IF temp2 > temp3 THEN temp2 := temp3;  {limited}
                     IF temp2 < 0.0   THEN temp2 := 0.0;    {limited}
                     IF temp3 >= 0.0
                       THEN temp3 := 1000.0 * temp3 + Int(temp2)
                       ELSE temp3 := 1000.0 * temp3 - Int(temp2);
                     END;
                   IF site_id = 'TN1' THEN BEGIN
                     xywrite (64, row, Yellow, 'ALT ');
                     temp2 := funpack (temp, 1000000000.0, 1000000.0);
                     new_value (row, 68, temp2);
                     temp3 := Int(temp2);
                     xywrite (64, row, Yellow, 'DAY ');
                     temp2 := funpack (temp,    1000000.0,    1000.0);
                     new_value (row, 68, temp2);
                     IF temp2 <     0.0 THEN temp2 :=   0.0;
                     IF temp2 >= 1000.0 THEN temp2 := 999.0;
                     IF temp3 >= 0.0
                       THEN temp3 := 1000.0 * temp3 + Int(temp2)
                       ELSE temp3 := 1000.0 * temp3 - Int(temp2);
                     xywrite (64, row, Yellow, 'NITE');
                     temp2 := funpack (temp,       1000.0,       1.0);
                     new_value (row, 68, temp2);
                     IF temp2 <     0.0 THEN temp2 :=   0.0;
                     IF temp2 >= 1000.0 THEN temp2 := 999.0;
                     IF temp3 >= 0.0
                       THEN temp3 := 1000.0 * temp3 + Int(temp2)
                       ELSE temp3 := 1000.0 * temp3 - Int(temp2);
                     END;
                   enrich_mode[no]   := 3;
                   enrich_val[no][3] := temp3;
                   change := TRUE;
                   END;
                 END;
             END;
        2: ;  {all changes are made using submenu}
        3: new_value (row, 55, tsamp[no]);
        4: new_value (row, 55, tcont[no]);
        5: new_value (row, 55, vvptime[no].period);
        6: new_value (row, 55, windthr[no]);
        7: BEGIN
             new_value (row, 55, preset[no]);  
             cinteg[no] := preset[no];
             propc[no]  := cinteg[no];
             END;
        8: new_value (row, 55, falarm[no]);
        9: new_value (row, 55, calarm[no]);
       10: new_value (row, 55, gcint[no]);
       11: new_value (row, 55, wsint[no]);
       12: new_value (row, 55, wdint[no]);
       13: BEGIN
             xywrite (65,row,-1,'MIN:');  new_value (row, 70, pidfactormin[no]);
             xywrite (65,row,-1,'MAX:');  new_value (row, 70, pidfactormax[no]);
             END;
       14: new_value (row, 55, ainteg[no]);
       15: new_value (row, 55, aprop[no]);
       16: new_value (row, 55, adiff[no]);
       17: new_value (row, 55, awind[no]);
       18: new_value (row, 55, tlearn[no]);
       19: new_value (row, 55, limit[no]);
       20: BEGIN
             conditional_enabled[no] := (NOT conditional_enabled[no]);
             change := TRUE;
             END;
       21: BEGIN
             change := TRUE;
             TextColor (LightRed);
             temp_mode := onoff_mode[no];
             REPEAT
               value_cycle (temp_mode, 0,3, ' ');
               GotoXY(40,row);
               CASE temp_mode OF
                 0: WRITE ('       OFF');
                 1: WRITE ('CONTINUOUS');
                 2: WRITE ('     CLOCK');
                 3: WRITE ('     SOLAR');
                 END;  {of case}
               ClrEol;
               kbin; 
               UNTIL (alr=27{ESC}) OR (alr=13{CR});
             IF (temp_mode = 2) AND (alr <> 27) THEN BEGIN
               GotoXY(51,row);
               WRITE('Time ON: '+stimeon[no]);
               GotoXY(60,row); daccept;
               IF Length(svalue)>0 THEN BEGIN
                 WHILE Length(svalue)<4 DO svalue := Concat('0',svalue);
                 stimeon[no] := svalue;
                 GotoXY(60,row); ClrEol; WRITE(stimeon[no]);
                 END;
               GotoXY(65,row);
               WRITE('Time OFF: '+stimeoff[no]);
               GotoXY(75,row); daccept;
               IF Length(svalue)>0 THEN BEGIN
                 WHILE Length(svalue)<4 DO svalue := Concat('0',svalue);
                 stimeoff[no] := svalue;
                 GotoXY(75,row); ClrEol; WRITE(stimeoff[no]);
                 END;
               Val(Copy(stimeon[no], 1,2),houron[no],code);
               Val(Copy(stimeon[no], 3,2),minon[no],code);
               Val(Copy(stimeoff[no],1,2),houroff[no],code);
               Val(Copy(stimeoff[no],3,2),minoff[no],code);
               timeon [no]:=houron [no]*60+minon [no];
               timeoff[no]:=houroff[no]*60+minoff[no];
               END;
             IF (temp_mode = 3) AND (alr <> 27) THEN BEGIN
               GotoXY (51,row);
               WRITE( 'Altitude: ',dawn_altitude[no]:6:2);
               new_value (row, 69, dawn_altitude[no]);
               END;
             IF alr = 27 THEN alr := 127
                         ELSE onoff_mode[no] := temp_mode;
             TextColor(Green);
             END;
        END;  {of case}
      tinter;
      show_value (row, no, White);
      END;
    IF need_help THEN algor_help;
    IF submenu   THEN submenus (row-firstline+1);
    UNTIL (alr=27) OR (calr='+') OR (calr='-');

  {store new parameter set on disk}
  IF change THEN BEGIN
    WITH parrecord[no] DO BEGIN
      ddate:=comd.date; ttime:=comd.time;
      ttsamp:=tsamp[no]; ttcont:=tcont[no];
      aainteg:=ainteg[no]; aaprop:=aprop[no];
      aadiff:=adiff[no]; aawind:=awind[no];
      ppidfactormin := pidfactormin[no]; ppidfactormax := pidfactormax[no];
      wwindthr:=windthr[no];
      ppreset:=preset[no]; 
      ffalarm := falarm[no]; 
      ccalarm := calarm[no];
      ggcint:=gcint[no]; wwsint:=wsint[no]; wwdint:=wdint[no];
      ttlearn:=tlearn[no];
      llimit:=limit[no]; bback4:=back4[no];
      tfil1:=timestep[1]; tfil2:=timestep[2]; tfil3:=timestep[3];
      sfil1:=sfil[no,1]; sfil2:=sfil[no,2];
      sfil3:=sfil[no,3]; sfil4:=sfil[no,4];
      eenrich_mode := enrich_mode[no];
      eenrich_base := enrich_base[no];
      FOR i := 0 TO 3 DO eenrich_val[i] := enrich_val[no][i];
      oonoff_mode := onoff_mode[no];
      ttimeon:=timeon[no]; ttimeoff:=timeoff[no];
      ddawn_altitude := dawn_altitude[no];
      cconditional_enabled := conditional_enabled[no];
      cconditional_var := conditional_var^[no];
      wwindprop:=windprop[no];
      rrefreshvvp:=vvptime[no].period;
      END;  {of WITH DO}
    IF sfil[no,4] THEN BEGIN
      {$I-}
      RESET(parr[no]);
      ior := IOResult;
      IF ior <> 0 
        THEN ioerrmsg ('RESET')
        ELSE BEGIN
          Seek(parr[no],FileSize(parr[no]));
          ior := IOResult;
          IF ior <> 0 
            THEN ioerrmsg ('Seek')
            ELSE BEGIN
              WRITE(parr[no],parrecord[no]); 
              ior := IOResult;
                IF ior <> 0 
                THEN ioerrmsg ('WRITE')
                ELSE BEGIN
                  recnum[no,4]:=recnum[no,4]+1;
                  END;
              END;
          END;
      CloseFile (parr[no]);
      ior := IOResult;
      {$I+}
      END;
    END;  {of IF change}

  changering (no, numrings, calr);

  UNTIL alr=27;  {ESC}
lpf_constants;  {brute force; has possibly been delayed}
END;  {of procedure 'algor'}
{-------------------------------------------------------------}

PROCEDURE analog_out (port, address, channel: Word; volts: float;
                      VAR digital: INTEGER; VAR error: BOOLEAN);
{Output one analog value to data acquistition system.  
 Action depends on data acquistion and control system in use.
 Note -- optomux routine ORs old error condition with result of this call!
 J.N. -- 02/24/93
 }
VAR resolution: float;
BEGIN
WITH DataComm.Ports[port] DO BEGIN
  {Optomux and duTec}
  IF (protocol = 'OS') OR (protocol = 'DS') THEN BEGIN
    resolution :=  4095.0/5.0;
    digital := TRUNC(0.999999 * resolution * volts);
    IF digital < 0 THEN digital := 0;
    write_analog (port, address, 1 Shl channel, digital);
    error := error OR optomux_var.error;
    END;
  END;  {with}
  END;  {of procedure 'analog_out'}
{----------------------------------------------------------------------------}

PROCEDURE digital_out (port, address, value: Word; VAR error: BOOLEAN);
BEGIN
WITH DataComm.Ports[port] DO BEGIN
  {Optomux or duTec}
  IF (protocol = 'OS') OR (protocol = 'DS') THEN BEGIN
    write_digital (port, address, value);
    error := error OR optomux_var.error;
    END;
  {Festo CPX FEC}
  IF (protocol = 'FE') THEN WITH DataComm.Ports[port].IPRec DO BEGIN
    {objFestoCI.Open;}
    error := (NOT objFestoCI.WordWrite ('A', value, address));
    {objFestoCI.Close;}
    END;
  END;  {with}
  END;  {of procedure 'digital_out'}
{----------------------------------------------------------------------------}

PROCEDURE analog_in (daqc: daqc_addr; VAR data: dataflow_rec; 
  port: Word; VAR error: BOOLEAN);
VAR positions: Word;
    i, id: INTEGER;
    protocol: String[2];
    span, shift: float;
    errcode: INTEGER;
    fSuccess: BOOLEAN;

{Input analog from data acquistition system.
 Action depends on data acquistion and control system in use.
 Note -- optomux routine ORs old error condition with result of this call!
 J.N. -- 93/02/24  never used
         93/04/09  completely rewritten
         93/08/04  positions: $FFFF --> depends
         93/10/29  changed v = 5 * (d-4095)/4096 to proper (d-4096)/4095
         94/08/28  new adc_read method
         95/06/15  positions: $007F --> $00FF for NC1 since no DAC anymore
         97/12/30  remove gaincode from argument list
         97/12/30  add span & shift for new multiranging capability.
         98/01/01  execution only if channel in range 0 to 15       
         98/09/24  put RS232 reads of LiCor (channel = 21) here as well       
         99/02/12  define and use special "300" series range       
         99/04/21  define and use special "900" series range
         01/09/19  put RS232 reads of TEI (channel = 4x) here as well       
         04/07/22  put imbedded multiport sampler 800 reads here as well       
         11/09/23  add code for Festo CPX FEC       
         11/10/27  define and use special "400" series range       
 }
BEGIN
  WITH daqc, data DO 
  
  IF exists AND (channel IN [0..15, 21,22,24, 27, 40..49]) THEN BEGIN
    protocol := DataComm.Ports[port].protocol;
      
    IF ABS(range) < 100.0
      THEN
        IF range > 0.0
          THEN BEGIN
            span  := range;
            shift := 0.0;
            END
          ELSE BEGIN
            span  := 2.0 * ABS(range);
            shift := range;
            END
      ELSE IF (range >= 200.0) AND (range < 299.9) THEN BEGIN
        span  := (range - 200.0) / 1000.0;
        shift := 0.0;
        END
      ELSE IF (range >= 300.0) AND (range < 399.9) THEN BEGIN
        span  := (range - 300.0);
        shift := 0.0;
        END
      ELSE BEGIN
        span  := 1.0;
        shift := 0.0;
        END;

      {Optomux or duTec}
      IF (protocol = 'OS') OR (protocol = 'DS') THEN BEGIN
        {ADC board}
        IF (channel IN [0..15]) AND (ROUND(range) < 800) THEN BEGIN
          WITH adc_read^[address] DO IF NOT flag THEN BEGIN
            read_analog_input (port, address, select);
            error := error OR optomux_var.error;
            FOR i := 0 TO 15 DO data[i] := optomux_var.data_in[i];
            flag := TRUE;
            END;  {actually reading the ADC board}
          digital := ($7FFF And adc_read^[address].data[channel]);  {***TEMP***}
          volts := span * (digital-4096.0) / 4095.0 + shift;
          END;  {ADC board 00..15}

        {LiCor serial reads}
        IF (channel IN [21, 22, 24, 27]) THEN BEGIN
          licor_input (address, errcode);
          error := error OR (errcode <> 0);
          IF errcode = 0
            THEN volts := licor_getvalue (address, ROUND(range), errcode)
            ELSE volts := -1.0;
          END;  {RS232 reading of LiCor}

        {TEI}
        IF (channel IN [40..49]) THEN BEGIN
          volts := tei_read (port, address, channel, ROUND(range));
          IF (volts < 0.0)
            THEN BEGIN
              digital := ROUND(ABS(volts));
              volts := offscale;
              END
            ELSE digital := 0;
          error := error OR (volts >= offscale);
          END;  {RS232 reading of TEI}

        {Imbedded multiport sampler}
        IF (ROUND(range) = 800) THEN
          WITH ambmp_hardware_var.node[channel] DO
            IF NOT timedout
              THEN volts := concentration
              ELSE volts := 2228.0;

        {NetInfo}
        id := ROUND(range) MOD 100;
        IF ((ROUND(range) DIV 100) = 9) THEN BEGIN
          volts := netinfo_getvalue (id, channel, errcode);
          END;  {Getting netinfo value}

        IF (NOT optomux_var.error)
          THEN value := gain * volts + offset
          ELSE value := offscale;

        END;  {OS or DS protocol}

      {Festo CPX FEC}
      IF (protocol = 'FE') AND
         (ROUND(range) <> 400) THEN WITH DataComm.Ports[port].IPRec DO BEGIN
        {objFestoCI.Open;}
        fSuccess := objFestoCI.WordRead ('E', digital, address);
        {objFestoCI.Close;}
        volts := digital * span / 4096.0 + shift;
        IF fSuccess
          THEN value := gain * volts + offset
          ELSE value := offscale;
        error := NOT fSuccess;
        END;  {FE protocol}

      {ASCII line devices read with own DataComm port}
      IF (ROUND(range) = 400) THEN WITH DataComm.Ports[address] DO BEGIN
        volts := objLineIn.ValueGet(channel);
        IF (volts < 9990)
          THEN value := gain * volts + offset
          ELSE value := offscale;
        END;

    END  {of if exists and channel in allowed set}

      ELSE value := -99.9;

  END;  {of procedure 'analog_in'}
{----------------------------------------------------------------------------}

PROCEDURE digital_in (protocol: String; port, address: Word; 
                      VAR value: Word; VAR error: BOOLEAN);
{Input digital from data acquistition system.  
 Action depends on data acquistion and control system in use.
 Optomux always reads in one word (16 bits).
 Note -- optomux routine ORs old error condition with result of this call!
 }
VAR temp: INTEGER;  {If not used, get type conflict.}
BEGIN
  value := 0;

  {Optomux or duTec}
  IF (protocol = 'OS') OR (protocol = 'DS') THEN BEGIN
    read_onoff (port, address);
    IF NOT optomux_var.error
      THEN value := optomux_var.data_in[0]
      ELSE error := error OR optomux_var.error;
    END;

  {Festo CPX FEC}
  IF (protocol = 'FE') THEN WITH DataComm.Ports[port].IPRec DO BEGIN
    {objFestoCI.Open;}
    error := NOT objFestoCI.WordRead ('E', temp, address);
    {objFestoCI.Close;}
    IF error
      THEN value := 0
      ELSE value := temp;
    END;  {FE protocol}

  END;  {of procedure 'digital_in'}
{----------------------------------------------------------------------------}

PROCEDURE multiport (command: String);
{For providing FCP computer information to other cpu's, like the MP3S
}
CONST flag = '>';  {this and other formatting must be known to RINGyy prog}
      sep  = ',';  {comma delimited}
      crlf = CHR(13)+CHR(10);
VAR s: String;
    i: INTEGER;
    fSuccess: BOOLEAN;

BEGIN

  WITH DataComm.Ports[PORT_MPLINK], FileRec DO IF exists THEN BEGIN

    IF command = 'FLAG' THEN BEGIN

      tmplink := FileRec.param1;  {Note tied to text file type!!!}
      IF (tint-tmplinklast) > tmplink THEN BEGIN
        tmplinklast := tint;

        objLineIn.OutputDebug (PORT_MPLINK, 'Begin transaction' + FormatDateTime (' hh:nn:ss.zzz', Time), TRUE);
        fSuccess := PortOpen (PORT_MPLINK);
        objLineIn.OutputDebug (PORT_MPLINK, 'OPEN ' + filename, fSuccess);

        IF fSuccess THEN BEGIN

          {This is the first line}
          s := flag+filename+sep+showdate(comd.date)+sep+comd.time;
          fSuccess := PortSend (PORT_MPLINK, s);
          objLineIn.OutputDebug (PORT_MPLINK, 'SEND ' + s, fSuccess);
          PortSend (PORT_MPLINK, crlf);

          {Now loop over all plots}
          FOR i := 1 TO numrings DO BEGIN
            rmplink := i;
            multiport ('DATA');
            END;
          END;

        fSuccess := PortClose (PORT_MPLINK);
        objLineIn.OutputDebug (PORT_MPLINK, 'CLOSE', fSuccess);
        objLineIn.OutputDebug (PORT_MPLINK, 'End   transaction' + FormatDateTime (' hh:nn:ss.zzz', Time), TRUE);
        END;

      END;  {of look for FLAG}

    IF command = 'DATA' THEN BEGIN  {send the FACE data}

      s :=     '';
{ 1}  s := s + rlabel                    [rmplink]            + sep;
{ 2}  s := s + Format ('%1.0f', [agcont  [rmplink].Integral]) + sep;
{ 3}  s := s + Format ('%3.1f', [awspeed [rmplink].Integral]) + sep;
{ 4}  s := s + Format ('%1.0f', [awinddir[rmplink]*360])      + sep;
{ 5}  s := s + Format ('%1.0f', [ph2o    [rmplink]])          + sep;
{ 6}  s := s + Format ('%1.0f', [propresp[rmplink]])          + sep;
{ 7}  s := s + Format ('%1.0f', [gcset   [rmplink]])          + sep;
{ 8}  s := s + Format ('%1.0f', [gccntl  [rmplink]])          + sep;
{ 9}  s := s + Format ('%1.0f', [gcambi  [rmplink]])          + sep;
{10}  s := s + Format ('%1.0f', [ambient_base     .Integral]) + sep;
{11}  s := s + IntToHex (status_var[rmplink].latched, 4);

      fSuccess := PortSend (PORT_MPLINK, s);
      objLineIn.OutputDebug (PORT_MPLINK, 'SEND ' + s, fSuccess);
      PortSend (PORT_MPLINK, crlf);
      END;  {of send DATA}

    END;  {of with}
  END;  {of procedure 'multiport'}
{----------------------------------------------------------------------------}

PROCEDURE dataflow (kall: INTEGER);
CONST c1 = Red;         {title}
      c2 = LightGreen;  {side bar}
      c3 = White;       {labels}
      c4 = Yellow;      {data}
      c5 = Cyan;        {alternate data}
      b = Blink;
      col  = 50;
      escape = 27;  {ordinal of <esc>}
      heading = '  digital     volts     value  variable';
VAR doexit: BOOLEAN;
    fullmin, fullmax: Word;  {saves size of initial window}
    msg: String;
    varlabel: String;
    faceraw_save: ARRAY[1..maxrings] OF BOOLEAN;
    ambmp_save: BOOLEAN;
    i, j, k, mm: INTEGER;
    cc: INTEGER;
    rhex: CHAR;

PROCEDURE outflow (x, y, color, ring, index: INTEGER; variable: float);
VAR colorsave: INTEGER;
BEGIN
  colorsave := TextAttr;
  TextColor(color);
  GotoXY(x,y);
  IF index >= 0
    THEN WITH dataflow_var[ring,index] DO
      WRITE (digital:10, volts:10:4, value:10:3)
    ELSE WRITE (' ':30);
  WRITE (variable:10:3);
  TextColor(colorsave);
  END;  {of local procedure 'outflow'}

BEGIN
  CASE kall OF
    0: REPEAT                             {called from higher menu}
      sidebar ('DATA FLOW DIAGNOSTICS', 0);
      fullmin := WindMin;
      fullmax := WindMax;
      dataflow_key := 0;
      dataflow_show := FALSE;
      FOR i := 1 TO numrings DO BEGIN
        varlabel := rep_hex(i,1);
        rhex := varlabel[1];
        xywrite (col,i+11,c2,
          '<'+rhex+'>   Ring '+rlabel[i]+' -- all data');
        mouse_add (3, 1, 80, i+11, i+11, ORD(rhex), 0);
        END;
      xywrite (col, 3, c2, '<F3>  Gas concentrations');
      xywrite (col, 4, c2, '<F4>  Wind speed and direction');
      xywrite (col, 5, c2, '<F5>  Temperatures');
      xywrite (col, 6, c2, '<F6>  Patm, pH2O, and solar');
      xywrite (col, 7, c2, '<F7>  Proportional valves');
      xywrite (col, 8, c2, '<F8>  Raw input/output');
      xywrite (col,10, c2, '<F10> Debug log file');
      mouse_add (3, 1, 80,  3,  3, 0, fkey[3]);
      mouse_add (3, 1, 80,  4,  4, 0, fkey[4]);
      mouse_add (3, 1, 80,  5,  5, 0, fkey[5]);
      mouse_add (3, 1, 80,  6,  6, 0, fkey[6]);
      mouse_add (3, 1, 80,  7,  7, 0, fkey[7]);
      mouse_add (3, 1, 80,  8,  8, 0, fkey[8]);
      mouse_add (3, 1, 80,  9,  9, 0, fkey[9]);
      mouse_add (3, 1, 80, 10, 10, 0, fkey[10]);
      GotoXY (1,24);
      kbin;
      doexit := (alr=escape);
      IF alr=0 THEN dataflow_key := ahr-fkey[0]+10
               ELSE dataflow_key := alr-ORD('0');
      IF (dataflow_key < 0) OR (dataflow_key > 255) THEN dataflow_key := 0;

      IF dataflow_key IN [1..numrings] THEN BEGIN  {all data for a ring}
        sidebar ('', dataflow_key);
        xywrite(21,7,c3,heading);
        xywrite(1, 9,c3,'[Gas] treatment');
        xywrite(1,10,c3,'[Gas] control');
        xywrite(1,11,c3,'[Gas] ambient');
        xywrite(1,12,c3,'Air temperature');
        xywrite(1,13,c3,'Enclosure temp');
        xywrite(1,14,c3,'Air pressure');
        xywrite(1,15,c3,'Air H2O vapor');
        xywrite(1,16,c3,'Solar radiation');
        xywrite(1,17,c3,'Wind speed');
        xywrite(1,18,c3,'Wind direction');
        xywrite(1,19,c3,'PropValv control');
        xywrite(1,20,c3,'PropValv response');
        xywrite(1,21,c3,'VVP pressure');
        xywrite(1,22,c3,'Ambient base value');
        xywrite(1, 1,c3,'Status current:');
        xywrite(1, 2,c3,'Status latched:');
        xywrite(1, 4,c3,'Digital in -- fumi:');
        xywrite(1, 5,c3,'Digital in -- cntl:');
        dataflow_show := TRUE;
        REPEAT 
          xywrite(40,1,Yellow,rlabel[dataflow_key]);
          kbin; 
          changering (dataflow_key, numrings, calr);
          UNTIL alr=escape;
        END;

      IF dataflow_key IN [13..17] THEN BEGIN       {specialized data types}
        CASE dataflow_key OF
          13: msg := 'GAS CONCENTRATIONS';
          14: msg := 'WIND SPEED & DIRECTION';
          15: msg := 'TEMPERATURES';
          16: msg := 'BAROMETRIC PRESSURE, pH2O and SOLAR';
          17: msg := 'PROPORTIONAL VALVES';
          END;  {of case}
        sidebar (msg, 0);
        xywrite (21, 3, c3, heading);
        GotoXY (1,4);
        FOR i := 1 TO 3 DO BEGIN
          IF (numrings <= 6) THEN WRITELN;
          FOR j := 1 TO numrings DO BEGIN
            varlabel := '';
            IF (dataflow_key = 13) THEN CASE i OF
              1:  varlabel := 'GAS FUMI ';
              2:  varlabel := 'GAS CNTL ';
              3:  varlabel := 'GAS AMBI ';
              END;  {of case}
            IF (dataflow_key = 14) THEN CASE i OF
              1:  varlabel := 'WIND SPED';
              2:  varlabel := 'WIND DIR ';
              END; {of case}
            IF (dataflow_key = 15) THEN CASE i OF
              1:  varlabel := 'AIR TEMP ';
              2:  varlabel := 'ENCL TEMP';
              3:  varlabel := 'AUX TEMP ';
              END; {of case}
            IF (dataflow_key = 16) THEN CASE i OF
              1:  varlabel := 'BARO PRES';
              2:  varlabel := 'H2O VP   ';
              3:  varlabel := 'SOL RAD  ';
              END; {of case}
            IF (dataflow_key = 17) THEN CASE i OF
              1:  varlabel := 'CONTROL  ';
              2:  varlabel := 'RESPONSE ';
              END;  {of case}
            IF varlabel <> '' THEN BEGIN
              IF j<>1 THEN varlabel := '         ';
              WRITE (varlabel, '  Ring ', rlabel[j], ':');
              END;
            WRITELN;
            END;
          END;
        dataflow_show := TRUE;
        REPEAT kbin; UNTIL alr=escape;
        END;

{All of this functionality must be provided by FCP some day -- raw input and output}
      IF dataflow_key = 18 THEN BEGIN
        REPEAT 
          Window (1,1,Lo(fullmax)+1,Hi(fullmax)+1);
          sidebar ('', 0);
          xywrite (1,1,Green,'RingSeq:');
          FOR i := 1 TO numrings DO BEGIN
            IF faceraw_switch[i] THEN TextColor(Red) ELSE TextColor (LightGray);
            mouse_add (3, WhereX, WhereX+3, 1, 1, ORD('0')+i, 0);
            WRITE ('<',i:1,'>');
            END;
          xywrite (-1,-1,Green,' AmbMP:');
          IF ambmp_debug THEN TextColor(Red) ELSE TextColor (LightGray);
          mouse_add (3, WhereX, WhereX+3, 1, 1, ORD('A'), 0);
          WRITE ('<A>');
          TextColor (LightGreen);
          Window (1,2,Lo(fullmax)+1,Hi(fullmax)+1);
          WITH DataComm.Ports[PORT_RINGS] DO
            IF (protocol = 'OS') OR (protocol = 'DS')
              THEN BEGIN END
              ELSE xywrite (10,10,c1+b, '\' + protocol + '\ ' +
                'Raw input/output data flow not supported for this DAQC system');

          kbin;
          calr := UpCase(calr);
          i := alr-ORD('0');  IF i < 0 THEN i := 0;
          IF i IN [1..numrings] THEN faceraw_switch[i] := NOT faceraw_switch[i];
          IF calr ='A' THEN ambmp_debug := NOT ambmp_debug;
          IF calr='P' THEN BEGIN
            FOR i := 1 TO numrings DO faceraw_save[i] := faceraw_switch[i];
            FOR i := 1 TO numrings DO faceraw_switch[i] := FALSE;
            ambmp_save  := ambmp_debug;
            ambmp_debug := FALSE;
            kbin;
            FOR i := 1 TO numrings DO faceraw_switch[i] := faceraw_save[i];
            ambmp_debug := ambmp_save;
            END;
          UNTIL alr=escape;

        FOR i := 1 TO numrings DO faceraw_switch[i] := FALSE;
        {optomux_debug := FALSE;}
        ambmp_debug   := FALSE;
        Window (1,1,Lo(fullmax)+1,Hi(fullmax)+1);
        END;

      IF dataflow_key = 20 THEN REPEAT             {debugging log file}
        ClrScr;
        sidebar ('Debugging Log File', 0);
        GotoXY (1,2);
        WRITE ('*[] asterisk denotes debug output is ENABLED');
        GotoXY (1,3);
        WRITE ('Have not implemented file open or closed test yet');
        {Haven't got this NONE/ALL stuff right yet ***}
        FOR i := DEBUGLOG_NONE+1 TO DEBUGLOG_ALL-1 DO BEGIN
          GotoXY (20, 5+i);
          IF DebugLogEnableGet(i)
            THEN WRITE ('*')
            ELSE WRITE (' ');
          WRITE ('[', word2hex (i, 1, 1), '] ');
          WRITE (DebugLogUnitNameGet(i));
          IF (i <= 9) 
            THEN mouse_add (3, 1, 80,  5+i,  5+i, ORD('0')+i, 0)
            ELSE mouse_add (3, 1, 80,  5+i,  5+i, ORD('A')+i-10, 0);
          END;
        GotoXY (20, 22);
        WRITE ('<F7> Open debugging log file ' + DebugLogFileNameGet);
        mouse_add (3, 1, 80, 22, 22, 0, fkey[7]);
        GotoXY (20, 23);
        WRITE ('<F8> Close debugging log file');
        mouse_add (3, 1, 80, 23, 23, 0, fkey[8]);
        GotoXY (20, 24);
        WRITE ('<F9> Close, erase , and open debugging log file');
        mouse_add (3, 1, 80, 24, 24, 0, fkey[9]);
        kbin;
        IF (alr <> 0)
          THEN BEGIN
            IF (calr IN ['0'..'9']) THEN i := ORD(calr) - ORD('0');
            IF (calr IN ['a'..'f']) THEN i := ORD(calr) - ORD('a') + 10;
            IF (calr IN ['A'..'F']) THEN i := ORD(calr) - ORD('A') + 10;
            DebugLogEnableSet (i, NOT (DebugLogEnableGet(i)));
            END
          ELSE BEGIN
            IF (ahr = fkey[7]) THEN DebugLogFileOpen (DebugLogFileNameGet);
            IF (ahr = fkey[8]) THEN DebugLogFileClose;
            IF (ahr = fkey[9]) THEN DebugLogFileClear;
            END;
        UNTIL alr=escape;

      UNTIL doexit;

    1: IF dataflow_show THEN BEGIN        {called from tinter to show data}
         IF dataflow_key IN [1..numrings] THEN BEGIN
           xywrite (17,1,-1, rep_binary(status_var[dataflow_key].current,16));
           xywrite (17,2,-1, rep_binary(status_var[dataflow_key].latched,16));
           xywrite (21,4,-1, rep_binary(digital_in_fumi[dataflow_key],   16));
           xywrite (21,5,-1, rep_binary(digital_in_cntl[dataflow_key],   16));
           outflow (20, 9,c4,dataflow_key, 1,gcgrab[dataflow_key]);
           outflow (20,10,c4,dataflow_key, 2,gccntl[dataflow_key]);
           outflow (20,11,c4,dataflow_key,12,gcambi[dataflow_key]);
           outflow (20,12,c4,dataflow_key, 3,temp1 [dataflow_key]);
           outflow (20,13,c4,dataflow_key,10,temp2 [dataflow_key]);
           outflow (20,14,c4,dataflow_key, 4,airpres[dataflow_key]);
           outflow (20,15,c4,dataflow_key,11,   ph2o[dataflow_key]);
           outflow (20,16,c4,dataflow_key, 7,solrad[dataflow_key]);
           outflow (20,17,c4,dataflow_key, 5,wspeed[dataflow_key]);
           outflow (20,18,c4,dataflow_key, 6,1.0*wwdir[dataflow_key]);
           outflow (20,19,c4,dataflow_key, 8,propc   [dataflow_key]);
           outflow (20,20,c4,dataflow_key, 9,propresp[dataflow_key]);
           outflow (20,21,c4,dataflow_key,14,Pvvp[dataflow_key]);
           outflow (20,22,c4,dataflow_key,15,AmbientBaseValue[dataflow_key]);
           END;
         IF (numrings <= 6) 
           THEN BEGIN
             j  := 1;
             k  := 4;
             cc := c4;
             END
           ELSE BEGIN
             j  := 0;
             k  := 3;
             cc := c5;
             END;
         IF dataflow_key = 13 THEN FOR i := 1 TO numrings DO BEGIN
           outflow (20, k               +i,c4,i, 1, gcgrab[i]);
           outflow (20, k+  (numrings+j)+i,cc,i, 2, gccntl[i]);
           outflow (20, k+2*(numrings+j)+i,c4,i,12, gcambi[i]);
           END;
         IF dataflow_key = 14 THEN FOR i := 1 TO numrings DO BEGIN
           outflow (20, k               +i,c4,i, 5,wspeed[i]);
           outflow (20, k+  (numrings+j)+i,cc,i, 6,1.0*wwdir[i]);
           END;
         IF dataflow_key = 15 THEN FOR i := 1 TO numrings DO BEGIN
           outflow (20, k               +i,c4,i, 3,temp1[i]);
           outflow (20, k+  (numrings+j)+i,cc,i,10,temp2[i]);
           IF ((site_id = 'AZ2')  OR
               (site_id = 'NV1')  OR
               (site_id = 'WI1')) THEN
           outflow (20, k+2*(numrings+j)+i,c4,i,13,temp3[i]);
           END;
         IF dataflow_key = 16 THEN FOR i := 1 TO numrings DO BEGIN
           outflow (20, k+              +i,c4,i, 4,airpres[i]);
           outflow (20, k+  (numrings+j)+i,cc,i,11,   ph2o[i]);
           outflow (20, k+2*(numrings+j)+i,c4,i, 7, solrad[i]);
           END;
         IF dataflow_key = 17 THEN FOR i := 1 TO numrings DO BEGIN
           outflow (20, k               +i,c4,i,8,propc   [i]);
           outflow (20, k+  (numrings+j)+i,cc,i,9,propresp[i]);
           END;
         END;
    END;  {of case}
  END;  {of procedure 'dataflow'}
{-------------------------------------------------------------}

PROCEDURE gasflow (command: String; ringno: INTEGER);
{For direct COM and Opto22 control of the gas flow proportional valve.
 J.N.  94/06/11  Original
 J.N.  94/06/20  Backlash (tbacklash & last_direction)
                 Control projection using cont_history (quadratic fit)
 J.N.  94/06/27  Replace optomux_talk('k' by start_on_pulse(
 J.N.  94/11/14  In move_motor, switch over to unipolar PS w/ direction
 J.N.  95/06/07  Go back to bipolar code, temporarily
                 Change default maximum step to 500 ms
 J.N.  95/06/26  And back to unipolar code
                 Reset many default parameters
 J.N.  95/06/28  Put limits on gain learned
 J.N.  95/07/09  Loosen criterion for accepting a response change as
                   not noise from 1.5*tolerance to 1.0*
                 Tighten criterion for accepting a step time from > 0
                   to 0.015 s, i.e. de facto minimum of 2 counts
                 Set load time gain to 100, learning period to 0
 J.N.  95/07/12  Kp=0.50, gain-f-min=0.03, gain-f-max=0.15, learn-period=100
 J.N.  95/07/13  Rewrite learning accumulating delta response better.
                 New defaults:  Kp = 0.75, Tbacklash = 100 ms, LP = 60 s.
 J.N.  95/07/15  Don't use forward extrapolation of control signal.
 J.N.  95/07/29  Fix bug involving blflag; Kp=0.5.
 J.N.  95/08/07  defaults: learning=0 (off), backlash=0
                 don't update learned gain unless int_dt > 100 ms
                 change gain_factor_min to 0.05 from 0.03
 J.N.  96/05/29  Get pv_motor[ring] (except first_relay) from MOTOn.DAT  
                   if it exists.
                 Refresh MOTOn.DAT each time gasflow screen exits.
 J.N.  97/04/11+ Nonlinear Kurz flow meter code added.  
                 Only refresh VALV file for those rings actually accessed.
 J.N.  97/08/05  Nonlinear Kurz -- use quadratic fit of ln(kg/h) to ln(v-z).
 J.N.  98/01/04+ Nonlinear Kurz -- complete change of calculation technique.
 J.N.  02/06/11  pipe_id_other: float (for Delphi 6).
 See list at beginning of file for further history.
 }
CONST nl2  = CHR(13) + CHR(10) + CHR(10);
      quit = 27;  {ascii key code for exit}
      col  = 2;   {position of input prompts}
      row  = 21;
      ci   = LightGray;  {color for instructions}
      cd   = White;      {color for data listing}
      nhistory = 1;  {+- range of points in control history; see also COMD}
      phistory = 2;  {where to project into the future (> nhistory}
      gain_factor_min = 0.05;
      gain_factor_max = 0.15;

      pipe_asa_name: ARRAY [0..16] OF String[13] = ( '        OTHER',
        'Sched40 1 IN.', 'Sched40 1 1/4', 'Sched40 1 1/2', 'Sched40 2 IN.',
        'Sched40 2 1/2', 'Sched40 3 IN.', 'Sched40 3 1/2', 'Sched40 4 IN.',
        'Sched80 1 IN.', 'Sched80 1 1/4', 'Sched80 1 1/2', 'Sched80 2 IN.',
        'Sched80 2 1/2', 'Sched80 3 IN.', 'Sched80 3 1/2', 'Sched80 4 IN.');

      pipe_asa_id: ARRAY [0..16] OF float = ( 999.0,
        1.315-2.0*0.133, 1.660-2.0*0.140, 1.900-2.0*0.145, 2.375-2.0*0.154,
        2.875-2.0*0.203, 3.500-2.0*0.216, 4.000-2.0*0.226, 4.500-2.0*0.237,
        1.315-2.0*0.179, 1.660-2.0*0.191, 1.900-2.0*0.200, 2.375-2.0*0.218,
        2.875-2.0*0.276, 3.500-2.0*0.300, 4.000-2.0*0.318, 4.500-2.0*0.337);

      velocity_type:  ARRAY [0..3] OF String[4] 
        = ('SFPS', 'SFPM', 'SMPS', 'SMPM');
      velocity_scale: ARRAY [0..3] OF float 
        = (0.3048, 0.3048/60.0, 1.0, 1.0/60.0);

VAR doexit,
    refresh: BOOLEAN;    {used to possibly refresh screen}
    millisecs,           {used as motion totalizer in M mode}
    i: INTEGER;
    msg: String;
    tolerance_absolute,
    response_change, lambda: float;
    gainflag: String[3];
    gaincalc: String[7];
    c0, c1, c2: float;   {coefficients used to anticipate control value}
    first_relay_save: daqc_addr;    {so VALV.SET doesn't overwrite .CFG}
    accessed: ARRAY [1..maxrings] OF BOOLEAN;  {used to refresh file(s)}
    vcorr,         {for possible correction of Kurz meter sense voltage}
    lnvdiff: float;
    pipe_id_other: float;

PROCEDURE move_motor (ring: INTEGER; direction: INTEGER; digitime: Word);
VAR seed: Word;
    fSuccess: BOOLEAN;
BEGIN
  {This code for unipolar power supply with polarity reverser ***
   The first channel of 2 adjacent is for direction (ON=fwd, OFF=rev)}

  WITH DataComm.Ports[PORT_RINGS], pv_motor^[ring].first_relay DO BEGIN

    IF ((protocol = 'OS') OR (protocol = 'DS')) THEN BEGIN
      seed := 1;
      IF direction = +1
        THEN   activate_digital (PORT_RINGS, address, seed Shl channel);
      IF direction = -1 
        THEN deactivate_digital (PORT_RINGS, address, seed Shl channel);  
      start_on_pulse (PORT_RINGS, address, seed Shl (channel+1), digitime);
      comm_err[ring] := comm_err[ring] OR optomux_var.error;
      END;  {OS  or DS}

    IF (protocol = 'FE') THEN WITH IPRec.objFestoCI DO BEGIN
      {Open;}
      fSuccess := BitWrite ('A', (direction = (+1)), address, channel);
      Windows.Sleep (20);  {Note: hardwired every move}
      fSuccess := fSuccess AND WordWrite ('M', digitime, 310);  {<--!!!}
      {Close;}
      comm_err[ring] := comm_err[ring] OR (NOT fSuccess);
      END;  {FE}

    END;  {with}

  END;  {of local procedure 'move_motor'}

PROCEDURE template;
BEGIN
  sidebar ('DIRECT CONTROL OF GAS FLOW VALVE ', ringno);
  xywrite (50,     3, LightGreen,'<UP>   Open  (manual mode)');
  xywrite (50,     4, LightGreen,'<DN>   Close (manual mode)');
  xywrite (50,     5, LightGreen,'<F1>  Help pages');
  xywrite (col,    3, cd, '[A] Automatic');
  xywrite (col,    4, cd, '[S] Semi-automatic (uses [C] entry)');
  xywrite (col,    5, cd, '[M] Manual with step in ms = ');
  xywrite (col,    6, cd, '[P] Process gain (dF per s)');
  xywrite (col,    7, cd, '[F] f -- aggressiveness factor');
  xywrite (col,    8, cd, '[T] Tolerance factor');
  xywrite (col,    9, cd, '[L] Learning period');
  xywrite (col,   10, cd, '    Response change');
  xywrite (col,   11, cd, '    Previous time step (s)');
  xywrite (col,   12, cd, '    Grab calculation of gain');
  xywrite (col,   13, cd, '[N] Minimum time step (ms)');
  xywrite (col,   14, cd, '[X] Maximum time step (ms)');
  xywrite (col,   15, cd, '[B] Backlash term     (ms)');
  xywrite (col,   16, cd, '    Correction / gain');
  xywrite (col,   17, cd, '      times aggressiveness');
  xywrite (col,   18, cd, '      limited');
  xywrite (col,   19, cd, '    Direction');
  xywrite (col,   20, cd, '    Digital increment');
  xywrite (col+40,18, cd, '[C] PV control signal');
  xywrite (col+40,19, cd, '    PV response signal');
  xywrite (col+40,20, cd, '    Correction');
  xywrite (col,   22, Yellow,       '  <F9> Linear flow meter    [ ]');
  xywrite (col,   23, Yellow,       ' <F10> Kurz nonlinear meter [ ]');
  xywrite (col,   24, LightMagenta, '<PgDn> Nonlinear parameters');
  WITH pv_motor^[ringno].flow_meter,
       list_addr_ptr[ringno]^.pv_response DO CASE code OF
    0: BEGIN
         xywrite (col+29,22,Yellow,'X');
         xywrite (col+29,23,Yellow,' ');
         xywrite (col+35,22,cd,'>>> Using .CFG entries');
         xywrite (col+35,22,cd,'Linear gain  =');  WRITE (gain    :9:3);
         xywrite (col+35,23,cd,'Offset       =');  WRITE (offset  :9:3);
         xywrite (col+35,24,cd,'Error return =');  WRITE (offscale:9:3);
         END;
    1: BEGIN
         xywrite (col+29,22,Yellow,' ');
         xywrite (col+29,23,Yellow,'X');
         xywrite (col+35,22,cd,'S/N        = ');  WRITE (serial_no);
         xywrite (col+35,23,cd,'Calib date = ');  WRITE (calib_date);
         xywrite (col+35,24,cd,'Err return = ');  WRITE (errvalue:8:3);
         xywrite (col+64,22,cd,'CSV CORRECTION');
         xywrite (col+57,23,cd,'Add to      = ');  WRITE (add_to:7:3);
         xywrite (col+57,24,cd,'Multiply by = ');  WRITE (multiply_by:7:3);
         END;
    END;  {case}
  mouse_clear (3);
  mouse_add (3, 50, 80,  3,  3, 0, 72);
  mouse_add (3, 50, 80,  4,  4, 0, 80);
  mouse_add (3, 50, 80,  5,  5, 0, fkey[1]);
  mouse_add (3,  1, 49,  3,  3, ORD('A'), 0);
  mouse_add (3,  1, 49,  4,  4, ORD('S'), 0);
  mouse_add (3,  1, 49,  5,  5, ORD('M'), 0);
  mouse_add (3,  1, 49,  6,  6, ORD('P'), 0);
  mouse_add (3,  1, 49,  7,  7, ORD('F'), 0);
  mouse_add (3,  1, 49,  8,  8, ORD('T'), 0);
  mouse_add (3,  1, 49,  9,  9, ORD('L'), 0);
  mouse_add (3,  1, 49, 13, 13, ORD('N'), 0);
  mouse_add (3,  1, 49, 14, 14, ORD('X'), 0);
  mouse_add (3,  1, 49, 15, 15, ORD('B'), 0);
  mouse_add (3,  1, 80, 18, 18, ORD('C'), 0);
  mouse_add (3,  1, 49, 22, 22, 0, fkey[ 9]);
  mouse_add (3,  1, 49, 23, 23, 0, fkey[10]);
  mouse_add (3,  1, 49, 24, 24, 0, 81);
  END;  {of local procedure 'template'}

PROCEDURE help;
VAR pageno: INTEGER;
    do_return: BOOLEAN;
BEGIN
  pageno := 1;
  REPEAT
    ClrScr;
    mouse_clear (0);
    mouse_add (3,  1, 21, 1,  2, 0, 73);
    mouse_add (3, 22, 39, 1,  2, 0, 81);
    mouse_add (3, 40, 80, 1,  2, 27, 0);
    mouse_add (3,  1, 80, 3, 25, 0, 81);
    xywrite (1,1,LightMagenta,
      '<PgUp> Previous page  <PgDn> Next page  <Esc> Return');
    xywrite (66,1,Yellow,'Page '+word2hex(pageno,1,2));
    WRITELN;
    CASE pageno OF
      1: WRITE (
  crlf,'These two menus contain parameters for',
  crlf,'  (1) closed loop control of the valve motor,',
  crlf,'  (2) reading the mass flow meter.',
  crlf,
  crlf,'The main menu primarily concerns the motor.',
  crlf,'[L] Leave this value at 0!!!',
  crlf,'[P] Increase this value if response oscillates around control.',
  crlf,'    Decrease this value if response of the valve is sluggish.',
  crlf,'[T] Error tolerance = tolerance_factor * (offscale + 2 * control).',
  crlf,
  crlf,'                   <MORE>',
  CHR(0));
      2: WRITE (
  crlf,'page2',
  crlf,
  crlf,'                   <MORE>',
  CHR(0));
      3: WRITE (
  crlf,'Flow Meter -- The .CFG file OR this proportional valve', 
  crlf,'controller page contains the information for converting ADC voltage', 
  crlf,'reading to gas flow.  There are currently two options.  The flow',
  crlf,'meter linearization option code is stored in the file VALVx.SET which',
  crlf,'is accessed by this Mass Flow Valve Controller utility menu page.',
  crlf,
  crlf,'Hit <F9> to select linear conversion using .CFG coefficients.',
  crlf,
  crlf,'Hit <F10> to select nonlinear conversion.',
  crlf,'Hit <PgDn> to access page to fill in calibration data.',
  crlf,
  crlf,'Method selection <F9> or <F10> must match actual hardware setup.',
  crlf,
  crlf,'                   <MORE>',
  CHR(0));
      4: WRITE (
  crlf,'<F9> LINEAR -- The .CFG entry for Proportional Valve Response', 
  crlf,'contains engineering coefficients for linear conversion of voltage to', 
  crlf,'flow units.  Originally this was the only method for conversion.', 
  crlf,'See discussion in .CFG file.  Before switching to the linear .CFG', 
  crlf,'option, make sure .CFG values are reasonable.',
  crlf,
  crlf,'<F10> KURZ NONLINEAR -- Voltage is read across a sensing resistor of',
  crlf,'the 2-wire flow meter excitation.  You enter the calibration data',
  crlf,'from Kurz meter calibration sheet and specifics for the FACE ring',
  crlf,'set up (your current sensing resistor, pipe inner diameter, etc.).',
  crlf,'The program does all calculations to convert the meter input',
  crlf,'to the correct CO2 mass flow.  Two parameters, "add_to" and',
  crlf,'"multiply_by" are provided for fine adjustment of the voltage.',
  crlf,
  crlf,'At some future time I will include an option to read calibration',
  crlf,'data from .CAL files selected by meter serial number.  The only',
  crlf,'additional information needed will be pipe size, FACE resistor,',
  crlf,'and voltage input adjustment.',
  CHR(0));
      END;  {case}
    kbin;
    do_return := (alr=quit);
    cursor_page (pageno, 1, 4, ahr);
    UNTIL do_return;
  refresh := TRUE;
  END;  {of local procedure 'help'}

PROCEDURE nonlinear_page (ringo: INTEGER);
{Setting parameters when using nonlinear flow meter.}
VAR ch: CHAR;
    index: INTEGER;
PROCEDURE template (ringno: INTEGER);
VAR i: INTEGER;
    t_deg_c: float;
    shex: String;
    rhex: CHAR;
BEGIN
  ClrScr;
  mouse_clear (0);
  WITH pv_motor^[ringno].flow_meter DO BEGIN
    xywrite ( 1,23, LightRed,
             'Values are live.  Changes take effect immediately');
    xywrite ( 1, 1, LightRed,      'Ring: '+rlabel[ringno]);
    xywrite (26, 1, LightMagenta,  '<Esc> Return to previous page');
    xywrite (53, 4, White, '[E] Error return ');  WRITE (errvalue   :8:2);
    xywrite (53, 5, White, '[+] Add to volts ');  WRITE (add_to     :8:3);
    xywrite (53, 6, White, '[M] Multiply by  ');  WRITE (multiply_by:8:3);
    xywrite ( 1, 2, White, '[S] Serial nr.  ');   WRITE (serial_no);
    xywrite ( 1, 3, White, '[D] Calib date  ');   WRITE (calib_date);
    xywrite ( 1, 4, White, '[T] Calib temp   ');  WRITE (t_ref:7:2);
      xywrite (26, 4, White, '[UT] Temp unit ');
        IF (t_unit = 0) THEN WRITE ('oC') ELSE WRITE ('oF');
    xywrite ( 1, 5, White, '[P] Calib pres   ');  WRITE (p_ref:7:2);
      xywrite (26, 5, White, '[UP] Pres unit ');
        IF (p_unit = 0) THEN WRITE ('mmHg') ELSE WRITE ('inHg');
    xywrite (26, 2, White, '[R1] Calib resister ');  WRITE (r_ref :7:3);
    xywrite (26, 3, White, '[R2] FACE  resister ');  WRITE (r_face:7:3);
    xywrite ( 1, 6, White, '[X] Pipe   ');
      WRITE (pipe_asa_name[pipe_type]);
    IF (pipe_type <> 0)
      THEN BEGIN
        xywrite (26, 6,    -1, '[ID]');
        pipe_id := pipe_asa_id[pipe_type];
        END
      ELSE BEGIN
        xywrite (26, 6, White, '[ID]');
        pipe_id := pipe_id_other;
        END;
      WRITE (pipe_id:7:4, '"', pipe_id*2.54:8:4,'cm');
    xywrite ( 1, 7, White, '[V] Velocity unit   ');
      WRITE (velocity_type[v_unit]);
    WRITELN;  WRITELN;
    xywrite ( 8, 9, LightBlue,
      'u['+velocity_type[v_unit]+']    u[SMPS] F[m3/s] F[kg/h]'+
      '  V[calib]   V[FACE]  ln(v-z)    ln(F)');
    FOR i := 1 TO 12 DO BEGIN
      IF velocity_calib[i] >= 0.0 THEN BEGIN
        velocity_si[i] := velocity_scale[v_unit] * velocity_calib[i];
        volume[i] := 0.0254*0.0254*
                     (pi*pipe_asa_id[pipe_type]*pipe_asa_id[pipe_type]/4.0)*
                     velocity_si[i];
        mass_flow[i] := 3600.0*mw_co2/1000.0*atm_si/r_si/(-abs_zero)*volume[i];
        IF t_unit = 0
          THEN t_deg_c := t_ref
          ELSE t_deg_c := 5.0/9.0*(t_ref-32.0);
        mass_flow[i] := mass_flow[i] * (-abs_zero)/(t_deg_c-abs_zero);
        IF p_unit = 0
          THEN mass_flow[i] := mass_flow[i] * p_ref/atm_mmHg
          ELSE mass_flow[i] := mass_flow[i] * p_ref/atm_inHg;
        csrvdc_face[i] := r_face/r_ref * csrvdc_calib[i];
        IF i>1 THEN ln_vz[i] := LN(csrvdc_face[i]-csrvdc_face[1])
               ELSE ln_vz[i] := -9.999;
        IF i>1 THEN ln_mf[i] := LN(mass_flow[i]-mass_flow[1])
               ELSE ln_mf[i] := -9.999;
        END;
      shex := rep_hex(i,1);
      rhex := shex[1];
      xywrite ( 1, 9+i, White, '['+rhex+']');
      mouse_add (3, 1, 3, 9+i, 9+i, ORD(rhex), 0);
      IF velocity_calib[i] >= 0.0
        THEN WRITELN (velocity_calib[i]:11:4, velocity_si[i]:11:4,
          volume[i]:8:3, mass_flow[i]:8:2,
          csrvdc_calib[i]:10:4, csrvdc_face[i]:10:4,
          ln_vz[i]:9:4, ln_mf[i]:9:4)
        ELSE WRITELN;
      END;
    END;  {of with}
  mouse_add (3,  1, 80,  1,  1, 27, 0);
  mouse_add (3, 53, 80,  4,  4, ORD('E'), 0);
  mouse_add (3, 53, 80,  5,  5, ORD('+'), 0);
  mouse_add (3, 53, 80,  6,  6, ORD('M'), 0);
  mouse_add (3,  1, 25,  2,  2, ORD('S'), 0);
  mouse_add (3,  1, 25,  3,  3, ORD('D'), 0);
  mouse_add (3,  1, 25,  4,  4, ORD('T'), 0);
  mouse_add (3, 26, 52,  4,  4, ORD('U'), 0);
  mouse_add (3,  1, 25,  5,  5, ORD('P'), 0);
  mouse_add (3, 26, 52,  5,  5, ORD('U'), 0);
  mouse_add (3, 26, 52,  2,  2, ORD('R'), 0);
  mouse_add (3, 26, 52,  3,  3, ORD('R'), 0);
  mouse_add (3,  1, 25,  6,  6, ORD('X'), 0);
  mouse_add (3,  1, 25,  7,  7, ORD('V'), 0);
  mouse_add (3, 26, 52,  6,  6, ORD('I'), 0);
  END;  {of local^2 procedure 'template' for nonlinear_page}
PROCEDURE rinput (msg: String; VAR x: float);
BEGIN
  xywrite (1, 24, White, msg);
  ClrEol;
  raccept (x);
  END;  {of local^2 procedure 'rinput' for nonlinear_page}
PROCEDURE sinput (msg: String{; VAR s: String});
BEGIN
  xywrite (1, 24, White, msg);
  saccept;
{  s := svalue; }
  END;  {of local^2 procedure 'sinput' for nonlinear_page}
BEGIN
  REPEAT WITH pv_motor^[ringno].flow_meter DO BEGIN
    template (ringno);
    kbin;
    ch := UpCase(calr);
    index := 0;
    IF (ch IN ['1'..'9']) THEN index := ORD(ch) - ORD('0');
    IF (ch IN ['A'..'Z']) THEN index := ORD(ch) - ORD('A') + 10;
    CASE ch OF
      'E': rinput ('Enter value to return upon error: ', errvalue);
      '+': rinput ('Voltage correction -- add this: ', add_to);
      'M': rinput ('Voltage correction -- then, multiply by: ', multiply_by);
      'S': BEGIN sinput ('Flow meter serial number: '{, serial_no});
           serial_no := svalue; END;
      'D': BEGIN sinput ('Flow meter calibration date: '{, calib_date});
           calib_date := svalue; END;
      'T': rinput ('Calibration temperature: ', t_ref);
      'P': rinput ('Calibration pressure: ', p_ref);
      'U': BEGIN
             xywrite (1, 24, White, 'Press "T", "P", or "q"...');
             mouse_clear (0);
             mouse_add (3,  7, 10, 24, 24, ORD('T'), 0);
             mouse_add (3, 11, 15, 24, 24, ORD('P'), 0);
             mouse_add (3, 16, 80, 24, 24, ORD('q'), 0);
             kbin;
             CASE calr OF
               'T','t': t_unit := 1 - t_unit;
               'P','p': p_unit := 1 - p_unit;
               END;  {of case}
             END;
      'R': BEGIN
             xywrite (1, 24, White, 'Press "1", "2", or "q"...');
             mouse_clear (0);
             mouse_add (3,  7, 10, 24, 24, ORD('1'), 0);
             mouse_add (3, 11, 15, 24, 24, ORD('2'), 0);
             mouse_add (3, 16, 80, 24, 24, ORD('Q'), 0);
             kbin;
             CASE calr OF
               '1': rinput ('Calibration resistor: ', r_ref);
               '2': rinput ('FACE sensing resistor: ', r_face);
               END;  {of case}
             END;
      'X': cycle_byte (pipe_type, 0, 16);
      'I': IF pipe_type = 0 THEN
             rinput ('Enter pipe inner diameter in inches: ', pipe_id_other);
      'V': cycle_byte (v_unit, 0, 3);
      END;  {case}
    IF index IN [1..12] THEN BEGIN
      rinput (ch+'= Enter calibration velocity (-1 to remove): ',
               velocity_calib[index]);
      rinput (ch+'= Enter calibration voltage: ',
               csrvdc_calib[index]);
      END;
    END;
    UNTIL ch=CHR(quit);
  END;  {of local procedure 'nonlinear_page'}

BEGIN

{Initialize parameters.  Called once at beginning of main program.}
IF command = 'INIT' THEN WITH pv_motor^[ringno] DO BEGIN
  {$I-}
  RESET (moto[ringno]);
  {$I+}
  IF IOResult = 0 
    THEN BEGIN
      first_relay_save := first_relay;
{Application.MessageBox (PCHAR(IntToStr(SizeOf(pv_motor^[ringno]))),'***TEMP',MB_OK);}
      Try
        READ (moto[ringno], pv_motor^[ringno]);
        Except On E: Exception DO FatalErr.Msg (
          'comp --> gasflow --> INIT',
          'Error reading proportional valve file ' +
            filnam[ringno,6] + nl2 +
            E.Message);
        End;
      first_relay := first_relay_save;
      CloseFile (moto[ringno]);
      END
    ELSE FatalErr.Msg ('comp --> gasflow --> INIT',
      filnam[ringno,6] +  ' not found.' + nl2 +
      'Check logging path in .CFG.' + nl2 +
      'Load archived VALV*.SET file, if necessary.');
    END;  {of command INIT}

{Call from sampling() for nonlinear readout of flow meter.}
IF command = 'METER' THEN WITH pv_motor^[ringno].flow_meter,
                               list_addr_ptr[ringno]^.pv_response,
                               dataflow_var[ringno, 9] DO BEGIN
  vcorr := multiply_by * (volts + add_to);
       IF vcorr <  (0.800 * csrvdc_face[1]) {changed from 0.900 2012-06-28}
         THEN value := offscale
  ELSE IF vcorr <= csrvdc_face[2]
         THEN value := mass_flow[2] * (vcorr - csrvdc_face[1])
                                    / (csrvdc_face[2] - csrvdc_face[1])
  ELSE BEGIN
         lnvdiff := LN(vcorr-csrvdc_face[1]);
         i := 2;
         WHILE (velocity_calib[i] > 0.0) AND
               (lnvdiff > ln_vz[i])      AND
               (i < 12)                      DO INC(i);
         value :=
          EXP (ln_mf[i-1] + (ln_mf[i]-ln_mf[i-1]) * (lnvdiff-ln_vz[i-1])
                                                  / (ln_vz[i]-ln_vz[i-1]));
         END;
  IF (value <> offscale)
    THEN propresp[ringno] := gain*(value+offset)
    ELSE propresp[ringno] := offscale;
  END;  {of command METER}

{Call from algorithm() for direct control of prop valve motor.}
IF command = 'CONTROL' THEN WITH pv_motor^[ringno] DO BEGIN

  {learn the motor gain}
  {this form replaced on 94/07/12...
  gain_grab := -999.9;
  IF (old_dt <> 0.0) AND (direction*last_direction = 1) THEN BEGIN 
    gain_grab := (propresp[ringno]-old_response) / old_dt;
    IF (gain_grab > 10.0) AND (gain_grab < 200.0)
      THEN IF learning_period >= 1.0 THEN BEGIN
        lambda := ABS(old_dt) / learning_period;                      
        gain := (1.0 - lambda) * gain + lambda * gain_grab;
        END;
    END; ...}

  {this form replaced on 95/07/13...
  response_change := ABS(propresp[ringno]-old_response);
  IF learning_period >= 1.0 THEN BEGIN
    lambda := 1.0 / learning_period;
    IF response_change > 1.0*tolerance*pv_control[ringno].offscale 
      THEN int_change := (1.0-lambda)*int_change + lambda*response_change;
    IF old_dt > 0.015
      THEN int_dt     := (1.0-lambda)*int_dt     + lambda*old_dt;
    gain := int_change / int_dt;
    IF gain < gain_factor_min*pv_control[ringno].offscale THEN BEGIN
      gain := gain_factor_min*pv_control[ringno].offscale;
      gainflag := 'MIN';
      END;
    IF gain > gain_factor_max*pv_control[ringno].offscale THEN BEGIN
      gain := gain_factor_max*pv_control[ringno].offscale;
      gainflag := 'MAX';
      END;
    END; ...}

  gainflag := '   ';
  gaincalc := '       ';
  response_change := propresp[ringno]-old_response;
  IF (learning_period >= 1.0) AND runon[ringno] AND co2qt[ringno].state
  THEN WITH list_addr_ptr[ringno]^ DO BEGIN
    IF blflag THEN BEGIN  {process, then clear, accumulators}
      IF ABS(int_dt) > 0.1 THEN BEGIN
        lambda := ABS(int_dt) / learning_period;
        kp := (1.0-lambda)*kp + lambda*(int_change/int_dt);
        Str (int_change/int_dt:7:1, gaincalc);
        IF kp < gain_factor_min*pv_control.offscale THEN BEGIN
          kp := gain_factor_min*pv_control.offscale;
          gainflag := 'MIN';
          END;
        IF kp > gain_factor_max*pv_control.offscale THEN BEGIN
          kp := gain_factor_max*pv_control.offscale;
          gainflag := 'MAX';
          END;
        END;
      int_change := 0.0;
      int_dt     := 0.0;
      END;
    int_change := int_change + response_change;
    IF ABS(old_dt) >= 0.005 THEN int_dt := int_dt + old_dt;
    END;

  {update the control value history}
  {comment out history***
  FOR i := -nhistory TO (nhistory-1) DO BEGIN
    cont_history[i] := cont_history[i+1];
    END;
  cont_history[nhistory] := propc[ringno];
  ***}

  {maybe move the motor}
  IF propresp[ringno] > 0.0 THEN resp_use := propresp[ringno]
                            ELSE resp_use := 0.0;
  CASE mode OF
    {Auto} 1: {This would be cont_use := propc[ringno]; if anticipation 
               were not being used.  See J.N. NB VI p. 106 for theory.}
              cont_use := propc[ringno];
              {comment out history***
              BEGIN
                c0 := cont_history[0];
                c2 := (cont_history[-1]+cont_history[+1])/2.0 - c0;
                c1 := cont_history[+1] - c0 - c2;
                cont_use := c0 + c1*phistory + c2*phistory*phistory;
                END;
              ***}
    {Semi} 2: ;                          {set target using [C] button}
    {Manu} 3: cont_use := propc[ringno];
    END;  {of case}
  correction := cont_use - resp_use;
  IF kp = 0 THEN tcalc:= 0   //Arbitrary default for testing
  ELSE tcalc := 1000.0 * correction / kp;                      {time units are ms}
  tstep := f * ABS(tcalc);
  IF tstep > tmax THEN tlimit := tmax
                  ELSE tlimit := tstep;
  digitime  := 0;
  direction := 0;
  blflag := FALSE;
  IF mode <> 3 THEN WITH list_addr_ptr[ringno]^ DO BEGIN
    tolerance_absolute := tolerance * pv_control.offscale;
    IF (cont_use > 0.0) AND (cont_use <= pv_control.offscale)
      THEN tolerance_absolute := 
           tolerance_absolute + 2.0 * tolerance * cont_use;
    IF (tlimit > (tmin - 5.0)) AND 
       (ABS(correction) > (tolerance_absolute)) THEN BEGIN                                  {Opto22 units are 10 ms}
         direction := 2 * ORD(tcalc >= 0.0) - 1;
         blflag := (direction * last_direction = (-1));
         digitime  := ROUND(0.1 * (tlimit + ORD(blflag)*tbacklash));
         last_direction := direction;
         END;
    IF run_mode AND (digitime > 0) 
      THEN move_motor (ringno, direction, digitime);
    END;

  {viewing action}
  IF screen_active THEN BEGIN
    FOR i := 1 TO 3 DO BEGIN
      IF mode=i THEN msg := '*' ELSE msg := ' ';
      xywrite (1,i+2,LightBlue,msg);
      END;
    GotoXY (col+30,  5);  WRITE (tstep_manual:6:0);
    GotoXY (col+30,  6);  WRITE (kp:6:2, '  ', gainflag);
    GotoXY (col+30,  7);  WRITE (f :6:2);
    GotoXY (col+30,  8);  WRITE (tolerance:6:3);
    GotoXY (col+40,  8);  WRITE ('(', tolerance_absolute:3:1, ')');
    GotoXY (col+30,  9);  WRITE (learning_period:6:0);
    GotoXY (col+30, 10);  WRITE (response_change:6:1);
    GotoXY (col+30, 11);  WRITE (old_dt:6:3);
    GotoXY (col+30, 12); {IF gain_grab > (-999.0) THEN WRITE (gain_grab:6:1)
                                                  ELSE WRITE (' ':6);}
                          WRITE ('Irc=', int_change:6:2, '   ');
                          WRITE ('Idt=', int_dt    :6:3);
                          WRITE ('    ', gaincalc);
    GotoXY (col+30, 13);  WRITE (tmin:6:0);
    GotoXY (col+30, 14);  WRITE (tmax:6:0);
    GotoXY (col+30, 15);  WRITE (tbacklash:6:0);
    GotoXY (col+30, 16);  WRITE (tcalc:6:0);
    GotoXY (col+30, 17);  WRITE (tstep:6:0);
    GotoXY (col+30, 18);  WRITE (tlimit:6:0);
    GotoXY (col+30, 19);  IF direction > 0 THEN WRITE ('+':6)
                          ELSE IF direction < 0 THEN WRITE ('-':6)
                          ELSE WRITE (' ':6);
    GotoXY (col+30, 20);  WRITE (digitime:6);
                          IF blflag THEN WRITE ('  BL') ELSE WRITE (' ':4);
    GotoXY (col+65, 18);  WRITE (cont_use:6:1,'  <--');
                          {comment out history***
                          FOR i := nhistory DOWNTO -nhistory DO
                            WRITE (cont_history[i]:6:1);
                          ***}
    GotoXY (col+65, 19);  WRITE (propresp[ringno]:6:1);
    GotoXY (col+65, 20);  WRITE (correction:6:1);
    END;

  old_response := resp_use;
{ old_dt       := 0.01 * direction * digitime; }
{ old_dt       := ABS( 0.01 * digitime - 0.001 * ORD(blflag) * tbacklash); }
  old_dt       := 0.001 * direction * tlimit;
  END;  {of command CONTROL}

{For viewing and debugging.}
IF command = 'SHOW' THEN BEGIN
  refresh := TRUE;
  FOR i := 1 TO numrings DO accessed[i] := FALSE;
  REPEAT
    IF refresh THEN template;
    refresh := FALSE;
    WITH pv_motor^[ringno] DO BEGIN
      accessed[ringno] := TRUE;
      screen_active := TRUE;
      kbin;
      screen_active := FALSE;
      doexit := (alr=quit);
      CASE UpCase(calr) OF
        'A': mode := 1;
        'S': mode := 2;
        'M': BEGIN  msg := 'Enter manual time step [ms]: ';
               xywrite (col,row,ci,msg);  ClrEol;  raccept(tstep_manual);  
               mode := 3;  END;
        'P': BEGIN  msg := 'Enter process gain in flow units per sec: ';
               xywrite (col,row,ci,msg);  ClrEol;  raccept(kp);  END;
        'F': BEGIN  msg := 'Enter aggressiveness factor: ';
               xywrite (col,row,ci,msg);  ClrEol;  raccept(f);  END;
        'T': BEGIN  msg := 'Enter tolerance as fraction of full scale: ';
               xywrite (col,row,ci,msg);  ClrEol;  raccept(tolerance);  END;
        'L': BEGIN  msg := 'Enter learning period in seconds of motion: ';
       {'L': BEGIN  msg := 'Enter learning period in number of movements: ';}
               xywrite (col,row,ci,msg);  ClrEol;  raccept(learning_period);  END;
        'N': BEGIN  msg := 'Enter minimum time step [ms]: ';
               xywrite (col,row,ci,msg);  ClrEol;  raccept(tmin);  END;
        'X': BEGIN  msg := 'Enter maximum time step [ms]: ';
               xywrite  (col,row,ci,msg);  ClrEol;  raccept(tmax);  END;
        'B': BEGIN  msg := 'Enter backlash term [ms]: ';
               xywrite (col,row,ci,msg);  ClrEol;  raccept(tbacklash);  END;
        'C': IF mode=2 THEN BEGIN  msg := 'Enter target gas flow rate: ';
               xywrite (col,row,ci,msg);  ClrEol;  raccept(cont_use);  END;
        ' ',
        '+',
        '-': BEGIN
               changering (ringno, numrings, calr);
               refresh := TRUE;
               END;
        CHR(0): CASE ahr OF
     {F1} 59: help;
     {Up} 72,
     {Dn} 80: IF mode=3 THEN BEGIN
                digitime := ROUND(0.1*tstep_manual);
                IF ahr=72 THEN direction := +1;
                IF ahr=80 THEN direction := -1;
                move_motor (ringno, direction, digitime);
                END;
     {F9} 67: WITH flow_meter DO BEGIN
                refresh := TRUE;
                code := 0;
                END;
    {F10} 68: WITH flow_meter DO BEGIN
                refresh := TRUE;
                code := 1;
                END;
   {PgDn} 81: BEGIN
                refresh := TRUE;
                nonlinear_page (ringno);
                END;
          END;  {of extended key code case}
        END;  {case}
      END;  {with}
    UNTIL doexit;
  FOR i := 1 TO numrings DO WITH pv_motor^[i] DO IF accessed[i] THEN BEGIN
    screen_active := FALSE;
    mode := 1;
    date_last_access := comd.date;
    time_last_access := comd.time;
    REWRITE (moto[i]);
    WRITE (moto[i], pv_motor^[i]);
    CloseFile (moto[i]);
    END;
  END;  {of command SHOW}

  END;  {of procedure 'gasflow'}
{------------------------------------------------------------}

PROCEDURE licor_start (id: INTEGER);
VAR errcode: INTEGER;
BEGIN
  IF licor_ptr^[id] <> NIL THEN  {must be allocated}
    WITH licor_ptr^[id]^ DO 
    IF PORT_RINGS <> PORT_EMB_MP THEN  {kludge}
      IF (daqc = licor_noinit) OR (errcode_save <> 0) THEN BEGIN
        daqc       := DataComm.Ports[PORT_RINGS].protocol;
        port       := PORT_RINGS;
        address    := id;  {note they are now the same}
        speed      := 9600;
        auto_print := 0.0;
        licor_init (id, errcode);
        END;
  END;  {of procedure 'licor_start'}
{------------------------------------------------------------}

PROCEDURE relinit (iring: INTEGER);
{Initialize and configure data acquisition system
  For Opto22, duTec
    Serial communications are initialized if Ring 1 specified.
    Attempt to initialize stops if error returned for ANY board in ring.
    Power_up_clear is sent because it may be needed.
    Boards are then configured according to a convention
      Misc DIO is input up to but not including fan bit
      Analog is output above and including pv control
  Now call for multiport link(s) has been added 93/07/15, 94/05/02}
VAR i, j, k: INTEGER;
    dummy_daqc: daqc_addr;
    board,
    boffset,
    mask: Word;
    fSuccess,
    error: BOOLEAN;
    dumword: Word;
    dumint: INTEGER;
    port:   INTEGER;

PROCEDURE checkforerr;
BEGIN
  comm_err[iring] := comm_err[iring] OR optomux_var.error;
  error := comm_err[iring];
  END;  {of local procedure 'checkforerr'}

PROCEDURE temp_probe_init (spigot: daqc_addr);
VAR code: INTEGER;
BEGIN
  WITH spigot DO
    IF (NOT error) AND exists AND (range > 100.0) AND (range < 200.0) 
      THEN BEGIN
        code := ROUND(range-100.0);
        mask := 1;
        set_temp_probe (PORT_RINGS, address, mask Shl channel, code);
        checkforerr;
        END;
  END;  {of local procedure 'temp_probe_init'}

BEGIN  {body of procedure}

comm_err[iring] := FALSE;
IF run_mode THEN WITH DataComm.Ports[PORT_RINGS], list_addr_ptr[iring]^ DO BEGIN

  IF (protocol = 'OS') OR (protocol = 'DS') THEN BEGIN

    IF iring = 1 THEN BEGIN  {*** only when R1 involved ***}
      fSuccess := DataComm.PortOpen (PORT_RINGS);
      IF NOT fSuccess THEN DataComm.PortErrorWindow (PORT_RINGS, 'comp/relinit');
      END;

    WITH fan_onoff_fumi DO {fumigation miscellaneous DIO board}
      IF exists THEN BEGIN
        power_up_clear (PORT_RINGS, address);
        checkforerr;
        {bits at and above fan_onoff_fumi are output}
        mask := $FFFF;
        IF NOT error
          THEN configure_positions (PORT_RINGS, address, mask And (mask Shl channel));
        checkforerr;
        {turn OFF miscellaneous digital on ALL output channels following
         watchdog timeout of ten minutes}
        IF NOT error
          THEN set_watchdog_delay (PORT_RINGS, address, 0, min_10+all_off);
        checkforerr;
        END;

    WITH fan_onoff_cont DO
      IF exists THEN BEGIN               {control ring miscellaneous DIO board}
      power_up_clear (PORT_RINGS, address);
      checkforerr;
      {bits at and above fan_onoff_cont are output}
      mask := $FFFF;
      IF NOT error
        THEN configure_positions (PORT_RINGS, address, mask And (mask Shl channel));
      checkforerr;
      {turn OFF miscellaneous digital on ALL output channels following
       watchdog timeout of ten minutes}
      IF NOT error
        THEN set_watchdog_delay (PORT_RINGS, address, 0, min_10+all_off);
      checkforerr;
      END;

    FOR k := 1 TO 3 DO BEGIN                           {vvp boards}
      CASE k OF
        1: dummy_daqc := vvp_open_fumi;
        2: dummy_daqc := vvp_open_cont;
        3: dummy_daqc := vvp_close;
        END;  {case}
      IF NOT error THEN WITH dummy_daqc DO IF exists THEN BEGIN
        j := (numvalvs DIV channel);  {determine number of boards}
        IF (numvalvs MOD channel) <> 0 THEN INC(j);
        IF protocol <> 'DS' THEN boffset := $01
                            ELSE boffset := $80;
        FOR board := 0 TO (j-1) DO BEGIN
          power_up_clear (PORT_RINGS, address + board * boffset);
          {Removed March 1997 because NC now mixed Opto22 and duTec...
          IF protocol = 'DS' THEN
            power_up_clear (PORT_RINGS, address - $40);
          IF protocol <> 'DS' 
            THEN set_protocol (PORT_RINGS, address,       optomux_protocol)
            ELSE set_protocol (PORT_RINGS, address - $40, optomux_protocol);
          ...}
          checkforerr;
          {configure for all digital outputs}
          IF NOT error
            THEN configure_positions (PORT_RINGS, address + board * boffset, $FFFF);
          checkforerr;
          {turn OFF VVP SSR's following watchdog timeout of ten minutes}
          IF NOT error
            THEN set_watchdog_delay (PORT_RINGS, address + board * boffset, 
              0, min_10+all_off); 
          checkforerr;
          END;
        END;
      END;  {of loop over vvp boards}

    IF NOT error THEN WITH pv_control DO {analog board}
      IF exists THEN BEGIN
        power_up_clear (PORT_RINGS, address);
        checkforerr;
        {analog at and above pv_control are output; below that input}
        mask := $FFFF;
        IF NOT error
          THEN configure_positions (PORT_RINGS, address, mask And (mask Shl channel));
        checkforerr;

        {Initialize any temperature probe modules.}
        temp_probe_init (temp_atmosphere);
        temp_probe_init (temp_enclosure);
        temp_probe_init (temp_auxiliary);

        {set watchdog timeout of ten minutes with ZERO output for all output
         channels on the analog board, if any -- no harm to input channels}
        IF NOT error
          THEN set_watchdog_delay (PORT_RINGS, address, $FFFF, min_10+zero_scale);
        checkforerr;
        END;

    END;  {OS or DS protocol}

  END;  {of with [PORT_RINGS]}

  END;  {of procedure 'relinit'}
{------------------------------------------------------------}

PROCEDURE reldisc;
{Close any serial connections to FACE rings and/or multiport computers.
 }

VAR i: INTEGER;

BEGIN  {body of procedure}

  IF run_mode THEN BEGIN

    DataComm.PortClose (PORT_RINGS);

    WITH DataComm.Ports[PORT_EMB_MP] DO
      IF exists THEN DataComm.PortClose (PORT_EMB_MP);

    END;  {if run mode}

  END;  {of procedure 'reldisc'}
{------------------------------------------------------------}

PROCEDURE sampling (iring: INTEGER);

VAR i: INTEGER;
    wss, esat, dum: float;
    errcode: INTEGER;
    {for remote calibration devices}
    iauto: GasAuto;  isthere: BOOLEAN;  temp_addr, temp_mask: Word;
    {$H+}
    t: STRING;  {scratch}
    {$H-}

PROCEDURE simfill (index: INTEGER; center, wobble: float);
{Fills dataflow_var[iring,index].value using random number generator
 using center + wobble * -0.5 to +0.5.}
BEGIN
  WITH dataflow_var[iring,index] DO BEGIN
    value := center + wobble * (Random-0.5);
    IF (value < 0.0) THEN value := 0.1;
    END;
  END;  {of local procedure 'simfill'}

BEGIN

IF simul_mode THEN BEGIN

  IF (iring=1) THEN
  ambmp_hardware_var.dataflow.value := 380.0 + 10.0 * (Random-0.5);

  simfill ( 5, wspeed[iring], 0.1);

 {simfill ( 6, winddir[iring], 0.05);}
  simfill ( 6, (iring-1) * 0.125, 0.03);  {2007-02-28}

  simfill ( 1, 370.0 + 5.0*propc[iring]/wspeed[iring],  40.0);
  simfill ( 2, 380.0, 10.0);
  simfill (12, 390.0, 10.0);

  simfill ( 3, 20.0, 2.0);
  simfill (10, 30.0, 3.0);
  simfill (13, 40.0, 4.0);

  simfill ( 4, 100.0, 2.0);

  simfill ( 7, 900.0, 100.0);

  simfill (11, 1000.0, 100.0);

  simfill ( 9, propc[iring], 5.0);

  simfill (15, 410.0, 10.0);

  digital_in_fumi[iring] := $FFFF;
  digital_in_cntl[iring] := $FFFF;

  ambmp_hardware_var.digital_ambmp := $FFFF;

  END;  {of simulation generation of values}

IF ambmp_hardware_var.exists AND (iring=1) THEN ambient_mp;

{When simulating, cause "analog read" of the "800" device}
IF simul_mode THEN WITH list_addr_ptr[iring]^ DO BEGIN
  IF (ROUND(conc_fumi.range)=800) THEN
  analog_in (conc_fumi, dataflow_var[iring,1], PORT_RINGS, comm_err[iring]);
  IF (ROUND(conc_cont.range)=800) THEN
  analog_in (conc_cont, dataflow_var[iring,2], PORT_RINGS, comm_err[iring]);
  IF (ROUND(conc_ambi.range)=800) THEN
  analog_in (conc_ambi, dataflow_var[iring,12], PORT_RINGS, comm_err[iring]);
  END;

{***** RUN MODE STARTS HERE *****}

IF run_mode THEN WITH DataComm.Ports[PORT_RINGS], list_addr_ptr[iring]^ DO BEGIN

  IF fan_onoff_fumi.exists
    THEN BEGIN
      temp_addr := fan_onoff_fumi.address;
      digital_in (protocol, PORT_RINGS, temp_addr,
                  digital_in_fumi[iring], comm_err[iring]);
      END
    ELSE digital_in_fumi[iring] := $FFFF;

  IF fan_onoff_cont.exists
    THEN BEGIN
      temp_addr := fan_onoff_cont.address;
      digital_in (protocol, PORT_RINGS, temp_addr,
                  digital_in_cntl[iring], comm_err[iring]);
      END
    ELSE digital_in_cntl[iring] := $FFFF;

{If PORT_GA exists then read it now.
 Input values will be plucked later.
 }
  WITH DataComm.Ports[PORT_GA] DO
    IF exists THEN objLineIn.Process (PORT_GA);

{If PORT_WIND exists then read it now.
 Input values will be plucked later.
 }
  WITH DataComm.Ports[PORT_WIND] DO
    IF exists THEN objLineIn.Process (PORT_WIND);

{If PORT_LOGGER_* exists then read it now.
 Input values will be plucked later.
 }
  FOR i := 1 TO maxlogger DO
  WITH DataComm.Ports[PORT_LOGGER_BASE+i] DO
    IF exists THEN objLineIn.Process (PORT_LOGGER_BASE+i);

  analog_in (wind_speed, dataflow_var[iring,5], PORT_RINGS, comm_err[iring]);

  analog_in (wind_direction, dataflow_var[iring,6], PORT_RINGS, comm_err[iring]);

  analog_in (conc_fumi, dataflow_var[iring,1], PORT_RINGS, comm_err[iring]);

  analog_in (pv_response, dataflow_var[iring,9], PORT_RINGS, comm_err[iring]);

  analog_in (conc_cont, dataflow_var[iring,2], PORT_RINGS, comm_err[iring]);

  analog_in (conc_ambi, dataflow_var[iring,12], PORT_RINGS, comm_err[iring]);

  analog_in (temp_atmosphere, dataflow_var[iring,3], PORT_RINGS, comm_err[iring]);

  analog_in (temp_enclosure, dataflow_var[iring,10], PORT_RINGS, comm_err[iring]);

  analog_in (temp_auxiliary, dataflow_var[iring,13], PORT_RINGS, comm_err[iring]);

  analog_in (pressure_atmosphere, dataflow_var[iring,4], PORT_RINGS, comm_err[iring]);

  analog_in (solar_radiation, dataflow_var[iring,7], PORT_RINGS, comm_err[iring]);

  analog_in (water_vapor, dataflow_var[iring,11], PORT_RINGS, comm_err[iring]);

  analog_in (vvp_pressure, dataflow_var[iring,14], PORT_RINGS, comm_err[iring]);

  analog_in (ambient_base_value, dataflow_var[iring,15], PORT_RINGS, comm_err[iring]);

  END;  {of if run_mode and with}

WITH list_addr_ptr[iring]^ DO BEGIN  
  wspeed[iring]  := dataflow_var[iring, 5].value;
  winddir[iring] := dataflow_var[iring, 6].value;

  gcgrab[iring]  := dataflow_var[iring, 1].value;
  IF conc_cont.exists THEN
  gccntl[iring]  := dataflow_var[iring, 2].value;
  IF conc_ambi.exists THEN
  gcambi[iring]  := dataflow_var[iring,12].value;

  temp1[iring]   := dataflow_var[iring, 3].value;
  WITH temp_atmosphere DO IF (range > 200) AND (range <= 299) THEN
    {.value = gain * .volts + offset should be Vs/Vx}
    temp1[iring] := therm107 (1.000, dataflow_var[iring,3].value, 1000.0, 249000.0);

  temp2[iring]   := dataflow_var[iring,10].value;
  WITH temp_enclosure DO IF (range > 200) AND (range <= 299) THEN
    temp2[iring] := therm107 (1.000, dataflow_var[iring,10].value, 1000.0, 249000.0);

  IF temp_auxiliary.exists THEN
  temp3[iring]   := dataflow_var[iring,13].value;

  airpres[iring] := dataflow_var[iring, 4].value;

  IF solar_radiation.exists THEN BEGIN {needed if possible amb_mp []fumi filling}
    solrad[iring]  := dataflow_var[iring, 7].value;
    END;

  Pvvp[iring] := dataflow_var[iring, 14].value;

  AmbientBaseValue[iring] := dataflow_var[iring, 15].value;

  WITH water_vapor DO IF exists THEN
    IF (range >= 300) AND (range < 399) THEN BEGIN
      h2o_saturation (9999.9, temp1[iring], esat, dum, dum, dum);
      ph2o[iring] {Pa} :=
        dataflow_var[iring,11].value {RH%} * esat {Pa} /100.0;
      END
    ELSE IF (range = 32) {LI840}
      THEN ph2o[iring] {Pa} :=
        dataflow_var[iring,11].value {mmol/mol} * airpres[iring] {kPa}
    ELSE ph2o[iring] := dataflow_var[iring,11].value;

  IF dataflow_var[iring,9].value > (-0.10*pv_response.offscale)
    THEN propresp[iring] := dataflow_var[iring,9].value  {ok}
    ELSE propresp[iring] := pv_response.offscale; {flow meter problem}
  {Up to this point, the linear engineering conversion contained in the
   .CFG file has been used.  Now entertain the possibility of replacing
   this work by a nonlinear conversion.}
  IF pv_motor^[iring].flow_meter.code <> 0 THEN gasflow ('METER', iring);
  {For open loop flow control when there is no response signal}
  IF NOT(pv_response.exists) THEN propresp[iring] := propc[iring];
  END;

{this may freeze all concentration integrals and PID terms}
  WITH calibrate_var[iring], list_addr_ptr[iring]^ DO BEGIN
    active := FALSE;  {this is paranoid but safe}    
    IF enable THEN active := 
      ((gcgrab[iring]>llimit.low) AND (gcgrab[iring]<llimit.high)) OR 
      ((gcgrab[iring]>ulimit.low) AND (gcgrab[iring]<ulimit.high));
    {Check imbedded multiport sampler}
    IF AmbientMultiportCalibratingGet THEN BEGIN
      active := active OR
        (ROUND(conc_fumi.range) = 800) AND
        (NOT ambmp_hardware_var.node[conc_fumi.channel].timedout) AND
        ((gcgrab[iring] < calibrate_param.llimit.high) OR
         (gcgrab[iring] > calibrate_param.ulimit.low ));
      active := active OR
        (ROUND(conc_cont.range) = 800) AND
        (NOT ambmp_hardware_var.node[conc_cont.channel].timedout) AND
        ((gccntl[iring] < calibrate_param.llimit.high) OR
         (gccntl[iring] > calibrate_param.ulimit.low ));
      active := active OR
        (ROUND(conc_ambi.range) = 800) AND
        (NOT ambmp_hardware_var.node[conc_ambi.channel].timedout) AND
        ((gcambi[iring] < calibrate_param.llimit.high) OR
         (gcambi[iring] > calibrate_param.ulimit.low ));
      END;
    END;

  IF (NOT comm_err[iring]) AND
     (Connect.StateGet(iring)) AND 
     (NOT calibrate_var[iring].enable) THEN  
    FOR iauto := Zero TO Span DO 
      {Temporarily commented out 9/19/02...
      IF NOT autocalib_var[iring][1-iauto].active THEN
      ...end of temporary comment out}
      WITH list_addr_ptr[iring]^, autocalib_var[iring][iauto] DO BEGIN
        IF iauto=Zero THEN WITH irga_zero DO BEGIN
                                            temp_addr := address;
                                            temp_mask := $1 Shl channel;
                                            isthere := exists;
                                            END
                      ELSE WITH irga_span DO BEGIN
                                            temp_addr := address;
                                            temp_mask := $1 Shl channel;
                                            isthere := exists;
                                            END;
        {handle passing through midnight; this will stop a calibration}
        IF tint < timebegan THEN BEGIN 
          timebegan := tint;
          intval := intvalmin;
          END;
        {start a autocalibration}
        IF enable AND (tint > (timebegan+intval)) THEN BEGIN 
          timebegan := tint;
          active := TRUE;
          IF run_mode AND isthere THEN 
            IF NOT inverted
              THEN activate_digital   (PORT_RINGS, temp_addr, temp_mask)
              ELSE deactivate_digital (PORT_RINGS, temp_addr, temp_mask);
          END;
        {stop the autocalibration pulse}
        IF (NOT enable) OR (tint > (timebegan+timepulse)) THEN
          IF run_mode AND isthere THEN 
            IF NOT inverted
              THEN deactivate_digital (PORT_RINGS, temp_addr, temp_mask)
              ELSE activate_digital   (PORT_RINGS, temp_addr, temp_mask);
        {autocalibration should be over; go back to normal}
        IF (tint > (timebegan+timeactive)) AND active THEN BEGIN
          active := FALSE;
          intval := intval * intvalmult;
          IF intval > intvalmax THEN intval := intvalmax;
          END;
        END;

  IF (NOT calibrate_var[iring]      .active) AND
     (NOT autocalib_var[iring][Zero].active) AND    
     (NOT autocalib_var[iring][Span].active) THEN BEGIN   
     {protect from bad IRGA or wrapping of the AZ short-haul modem;
      0v is really a big concentration}
     gcgrab_underflow[iring] := (gcgrab[iring] < -100.0);
     IF gcgrab_underflow[iring] 
       THEN gcgrab[iring] := 2.0*gcset[iring];
     END;

END;  {of procedure 'sampling'}
{------------------------------------------------------------}

PROCEDURE showit (nodeno: INTEGER; hint: String; candidate: float);
BEGIN
  IF Assigned (MPSample.frmMPSample) THEN BEGIN
    MPSample.frmMPSample.objMPGroup[nodeno].minflow.caption := hint;
    MPSample.frmMPSample.objMPGroup[nodeno].flow.caption := '';
    MPSample.frmMPSample.objMPGroup[nodeno].value.caption :=
      FloatToStrF (candidate, ffFixed, 8, 1);
    END;
  END;  {of procedure 'showit'}
{------------------------------------------------------------}

PROCEDURE algorithm (no: INTEGER);
{Proportional valve setting}
CONST wio3: ARRAY [0..23{CDT}] OF float =
              {peak normalized Leelanaw Co. MI "base" July/August 1987}
              (0.254, 0.231, 0.214, 0.199, 0.161, 0.151,
               0.182, 0.307, 0.491, 0.677, 0.791, 0.877,
               0.950, 0.988, 0.997, 1.000, 0.982, 0.951,
               0.868, 0.748, 0.580, 0.443, 0.348, 0.286);
VAR diff: float;
    testlimit: float;  {1/5/92}
    resolution: INTEGER;
    i: INTEGER;
    {these vars used by custom profiles}
    pedastal,
    peak_target,
    day_target,
    night_target,
    sun_altitude: float;
    {these vars used by SANBI chambers (ZA1)}
    WeightA, WeightB: float;
    one, bitmask: Word;
    pwm_port, pwm_address, pwm_channel, pwm_count: Word;
    xxx: float;  {used by revised ambient base value calculation}
    rrr: String;
BEGIN

  {AMBIENT BASE}

  {see procedure lpf_constants for fields of ambient_base: TLPF}
  {determine ambient base value -- same for all fumigation rings}
  {N.B. -- Does not account for dual gas possibility}

  IF no = 1 THEN WITH enrich_base[no] DO BEGIN
    {get the lowest control/ambient plot value that is greater than .low}
    amb_base_grab := 2.0*high;

    {Case where ambient base value is being obtained by an
     analog input channel, AU1 fumigation plots for example.}

      IF list_addr_ptr[no]^.ambient_base_value.exists THEN BEGIN
        amb_base_grab := AmbientBaseValue[no];
        showit (0, 'ABV'+rlabel[no], amb_base_grab);
        END

    {Case where neither input from analog channel or
     embedded multiport.  Rather specific to AU1 control plots.
     The measurements used, if they exist are:
       (0) Own [CO2] grab
       (1) Own [CO2] ambient plot grab
       (2) Paired fumigation [CO2] ambient grab
       (3) Another control ring [CO2] average
       (4) Another control ring [CO2] ambient plot grab
       (5) The other control ring [CO2] average
       (6) The other control ring [CO2] ambient plot grab
     The others that might be available would only be the
     non-paired fumigation [CO2] ambient plot grabs (2 of 9).}

      ELSE IF (NOT list_addr_ptr[no]^.ambient_base_value.exists) AND
              (NOT DataComm.Ports[PORT_EMB_MP].exists) THEN BEGIN

        xxx := gcgrab[no];
          showit (0, 'C'+rlabel[no], xxx);
          IF (xxx >= low) AND (xxx < amb_base_grab) THEN amb_base_grab := xxx;

        xxx := gcambi[no];
          showit (1, 'C'+rlabel[no]+' amb', xxx);
          IF (xxx >= low) AND (xxx < amb_base_grab) THEN amb_base_grab := xxx;

        xxx := DataComm.Ports[PORT_FCPLINK_BASE+1].objLineIn.ValueGet(11);
          rrr := DataComm.Ports[PORT_FCPLINK_BASE+1].objLineIn.TokenGet(3);
          showit (2, 'F'+rrr+' amb', xxx);
          IF (xxx >= low) AND (xxx < amb_base_grab) THEN amb_base_grab := xxx;

        xxx := DataComm.Ports[PORT_FCPLINK_BASE+2].objLineIn.ValueGet( 4);
          rrr := DataComm.Ports[PORT_FCPLINK_BASE+2].objLineIn.TokenGet(3);
          showit (3, 'C'+rrr, xxx);
          IF (xxx >= low) AND (xxx < amb_base_grab) THEN amb_base_grab := xxx;

        xxx := DataComm.Ports[PORT_FCPLINK_BASE+2].objLineIn.ValueGet(11);
          rrr := DataComm.Ports[PORT_FCPLINK_BASE+2].objLineIn.TokenGet(3);
          showit (4, 'C'+rrr+' amb', xxx);
          IF (xxx >= low) AND (xxx < amb_base_grab) THEN amb_base_grab := xxx;

        xxx := DataComm.Ports[PORT_FCPLINK_BASE+3].objLineIn.ValueGet( 4);
          rrr := DataComm.Ports[PORT_FCPLINK_BASE+3].objLineIn.TokenGet(3);
          showit (5, 'C'+rrr, xxx);
          IF (xxx >= low) AND (xxx < amb_base_grab) THEN amb_base_grab := xxx;

        xxx := DataComm.Ports[PORT_FCPLINK_BASE+3].objLineIn.ValueGet(11);
          rrr := DataComm.Ports[PORT_FCPLINK_BASE+3].objLineIn.TokenGet(3);
          showit (6, 'C'+rrr+' amb', xxx);
          IF (xxx >= low) AND (xxx < amb_base_grab) THEN amb_base_grab := xxx;

        showit (8, 'USE', amb_base_grab);  {this is the one selected}
        END

    {This is the default case which is the original code for a classic
     BNL design site with or without an embedded multiport.}

      ELSE
      FOR i := 1 TO numrings DO BEGIN
        IF (gcambi[i] >= low) AND (gcambi[i] < amb_base_grab) THEN
          amb_base_grab := gcambi[i];
        IF (gccntl[i] >= low) AND (gccntl[i] < amb_base_grab) THEN
          amb_base_grab := gccntl[i];
        END;

    {do a range checked integration}
    ambient_base.Integrate (amb_base_grab);
    {while in default, integration will decay to .default value}
    amb_in_default := (amb_base_grab >= 2.0*high);
    END;

  {calculate [gas] set point}
  WITH ambient_base DO CASE enrich_mode[no] OF
    0:  gcset[no] := ROUND (enrich_val[no][0]           );  {const}
    1:  gcset[no] := ROUND (enrich_val[no][1] + Integral);  {add}
    2:  gcset[no] := ROUND (enrich_val[no][2] * Integral);  {mult}
    3:  BEGIN                                               {profiles}
          gcset[no] := 0.0;
          IF site_id = 'WI1' THEN BEGIN
            peak_target := funpack (enrich_val[no][3], 1000000.0, 1000.0);
            pedastal    := funpack (enrich_val[no][3],    1000.0,    1.0);
            gcset[no] := (peak_target-pedastal) * wio3[hour] + pedastal;
            END;
          IF site_id = 'TN1' THEN BEGIN
            sun_altitude := funpack (enrich_val[no][3], 1000000000.0, 1000000.0);
            day_target   := funpack (enrich_val[no][3],    1000000.0,    1000.0);
            night_target := funpack (enrich_val[no][3],       1000.0,       1.0);
            IF helios_var.sun_alt.degrees > sun_altitude
              THEN gcset[no] := day_target
              ELSE gcset[no] := night_target;
            END;
          END;
    END;  {case}

  pr1[no]  := gcset[no]*0.01;  pr2[no]  := gcset[no]*0.02;
  pr5[no]  := gcset[no]*0.05;  pr10[no] := gcset[no]*0.1;
  pr20[no] := gcset[no]*0.2;

  IF (NOT calibrate_var[no]      .active) AND
     (NOT autocalib_var[no][Zero].active) AND
     (NOT autocalib_var[no][Span].active)
    THEN BEGIN
      IF (site_id <> 'ZA1')
        THEN BEGIN  {normal FACE code}
          gcerr[no]  := gcgrab[no] - gcset[no];
          agcerr[no] := agcont[no].Integral - gcset[no];
          END
        ELSE BEGIN  {special code for SANBI chambers}
          IF (gcgrab[no] > 50.0) AND (gcgrab[no] <= 2200.0)
            THEN WeightA := 1.0 ELSE WeightA := 0.0;
          IF (gccntl[no] > 100.0) AND (gccntl[no] < 1500.0)
            THEN WeightB := 1.0 ELSE WeightB := 0.0;
          IF (WeightA <> 0.0) OR (WeightB <> 0.0)
            THEN gcerr[no] := (WeightA * gcgrab[no] + WeightB * gccntl[no])
                              / (WeightA + WeightB) - gcset[no]
            ELSE gcerr[no] := 0.0;
          agcerr[no] := 0.0;  {essentially kills P & D action}
          propresp[no] := propc[no];  {avoid any non-agreement problems}
          END
      END
    ELSE BEGIN  {freeze I term, zero P term}
      gcerr[no]  := 0.0;
      agcerr[no] := 0.0;
      END;

  {modification of PID coefficients}
  pidfactor[no] := awspeed[no].Integral;
 {pidfactor[no] := cinteg[no]/200.0;}
  IF pidfactor[no] < pidfactormin[no] THEN pidfactor[no] := pidfactormin[no];
  IF pidfactor[no] > pidfactormax[no] THEN pidfactor[no] := pidfactormax[no];
  ainteg_adj[no] := pidfactor[no]*ainteg[no];
  aprop_adj [no] := pidfactor[no]*aprop [no];
  adiff_adj [no] := pidfactor[no]*adiff [no];

  {Adjust cinteg only if PVResponse keeping up.              -- since always
   Following made to apply at AZ1 only since it was causing  -- 8/6/95
   mean Cinteg to be too low at NC1 when gas supply was
   was simply not keeping up due to low pressure.
   In addition, should the gas supply have turned off,       -- 2/8/94
   possibly reduce cinteg so that demand is not too high
   when gas pressure is restored.
   Now applies only to TN1 at 0.05*offscale (AZ2 dropped).   -- 2/28/07
   }
  IF runon[no] AND oper[no] THEN WITH list_addr_ptr[no]^ DO BEGIN
    IF (propc[no]-propresp[no]) < 0.10*pv_control.offscale
      THEN cinteg[no]:=cinteg[no]-ainteg_adj[no]*gcerr[no]*tsamp[no]*0.001
      ELSE IF ((err[no].code And 1) <> 0) AND (site_id = 'TN1')
        THEN cinteg[no] := 0.05*pv_control.offscale;
    IF cinteg[no] < 0 
      THEN cinteg[no] := 0.0;
    IF cinteg[no] > 1.10 * pv_control.offscale
      THEN cinteg[no] := 1.10 * pv_control.offscale;
    IF (cinteg[no] > pv_control.offscale) AND (site_id = 'ZA1')
      THEN cinteg[no] := pv_control.offscale;

    cprop[no] := -aprop_adj[no]*agcerr[no];
    testlimit := ABS (cinteg[no]*limit[no]*wspeed[no]);
         IF cprop[no] < -testlimit THEN cprop[no] := -testlimit
    ELSE IF cprop[no] >  testlimit THEN cprop[no] :=  testlimit;

    diff := agcont[no].Integral - agcontsave[no]; 
    agcontsave[no] := agcont[no].Integral;
    adif[no]:=0.5 * adif[no] + 0.5 * diff;
    cdiff[no] := -adiff_adj[no] * adif[no] / tsamp[no];
    testlimit := cinteg[no] * limit[no];
         IF cdiff[no] < -testlimit THEN cdiff[no] := -testlimit
    ELSE IF cdiff[no] >  testlimit THEN cdiff[no] :=  testlimit;

    cwind[no]:= (awspeed[no].Integral-windlearn[no].Integral)
                *proplearn[no].Integral/(windlearn[no].Integral+awind[no]);

    cwindprop[no]:=wspeed[no]*windprop[no];
    END;

  IF runon[no] AND (NOT debug[no])
    THEN propc[no] := cinteg[no]+cprop[no]+cdiff[no]+cwind[no]+cwindprop[no];
  IF (NOT runon[no]) AND (NOT debug[no])
    THEN propc[no] := 0.0;
  IF debug[no]
    THEN ;  {do nothing}     

  WITH list_addr_ptr[no]^, pv_control, dataflow_var[no,8] DO BEGIN
    value := propc[no];
    IF propc[no] < 0.0      THEN propc[no] := 0.0;
    IF propc[no] > offscale THEN propc[no] := offscale;
    {This code added when lower limit switch broke in NC 6/15/94.
     Move the closing comment up here to enable this feature.
     If demand gets below pv_alarm / 1000, doesn't go lower
     to avoid hitting switch.
    IF propc[no] < falarm[no]/1000.0 THEN propc[no] := falarm[no]/1000.0;
     *** (closing comment)}

    {set DAC}
    {!!! turn off gas (any gas) if have fan rotation error !!!}
    IF (site_id = 'WI1') AND ((errlatch[no].code AND $0010) <> 0) 
      THEN propc[no] := 0.0;
    volts := (propc[no]-offset)/gain;
    IF run_mode THEN IF pv_control.exists AND (channel IN [0..15]) THEN
        analog_out (PORT_RINGS, address, channel, volts, digital, comm_err[no]);
    IF pv_motor^[no].first_relay.exists THEN {software may try to use both!}
      IF (site_id <> 'ZA1')
        THEN gasflow ('CONTROL', no)
        ELSE IF (run_mode) THEN BEGIN
          pwm_port    := PORT_RINGS;
          pwm_address := pv_motor^[no].first_relay.address;
          pwm_channel := pv_motor^[no].first_relay.channel;
          pwm_count   := ROUND (propc[no] * tcont[no]);
          one := 1;
          bitmask := one Shl pwm_channel;
          IF (propc[no] <= 0.5)
            THEN deactivate_digital (pwm_port, pwm_address, bitmask);
          IF (propc[no] >= 99.5)
            THEN   activate_digital (pwm_port, pwm_address, bitmask);
          IF (propc[no] > 0.5) AND (propc[no] < 99.5)
            THEN start_on_pulse (pwm_port, pwm_address, bitmask, pwm_count);
          comm_err[no] := comm_err[no] OR optomux_var.error;
          END;
    END;  {of with}

END;  {of procedure 'algorithm'}
{------------------------------------------------------------}

PROCEDURE rring (no: INTEGER);
CONST nowindmult= 1.5; {gas rate multiplier when wind down}
VAR ww, v, i, j, jj, start: INTEGER;
    mask: Word;
    dummy_daqc: daqc_addr;
    boffset: INTEGER;
    set_your_valves: BOOLEAN;
BEGIN
  WITH vvptime[no], list_addr_ptr[no]^ DO BEGIN

  IF oper[no] THEN BEGIN

    {Special NC1-only code for 10 vs 8 VVP open experiment -- 2007-02-28
     Change default to 8 VVP open                          -- 2007-03-13
     Applied only during March 2007
     Set Ring 2 to 10 VVP open on DOY even days
     Set Ring 4 to 10 VVP open on DOY odd  days
     ... Move this line to end to comment out special code.}
    IF ((site_id = 'NC1') AND (year=2007) AND (month=3)) THEN BEGIN
    matr := '00001111111100000000000000000000';
    IF ( ((doy MOD 2) = 0) AND (no=2) ) OR
       ( ((doy MOD 2) = 1) AND (no=4) ) THEN
    matr := '00101111111101000000000000000000';
    matr := matr + matr + matr + matr;
    END;

    start := ROUND(awinddir[no]*numvalvs);
    rrrr_new := Copy(matr,-start+2*numvalvs+(numvalvs DIV 4)+1,numvalvs);
    IF awspeed[no].Integral < windthr[no]
      THEN BEGIN
        rrrr_new := pattern_windlow;
        IF NOT winddown[no] THEN BEGIN
          winddown[no] := TRUE;  windup[no] := FALSE;
          cinteg[no] := cinteg[no]*nowindmult;
          END;
        END
      ELSE
        IF NOT windup[no] THEN BEGIN
          windup[no] := TRUE;  winddown[no] := FALSE;
          cinteg[no] := cinteg[no]/nowindmult;
          END;
    END;

  IF NOT runon[no] THEN rrrr_new := pattern_runoff;
  FOR j:=1 TO numvalvs DO vnoact[no,j]:=vact[no,j];

  IF NOT debug[no] THEN FOR j:=1 TO numvalvs DO
    vact[no,j] := (Copy(rrrr_new,j,1)='1');

  WITH DataComm.Ports[PORT_RINGS] DO BEGIN
    FOR j:=1 TO 4 DO BEGIN
      v:=1;
      rval[no,j]:=0;
      FOR jj:=1 TO 8 DO BEGIN
        IF vact[no,(j-1)*8+jj] THEN rval[no,j]:=rval[no,j]+v;
        v:=v*2;
        END;
      END;

  {Hit the solenoids only if needed.  This code added 1992 by JN.}
    newpattern   := (rrrr_new <> rrrr_old);
    needsrefresh := (tint>=(lastchange+period)) OR (tint<lastchange);
    msg := '..';
    IF newpattern OR needsrefresh THEN BEGIN
      IF newpattern   THEN msg[1] := 'N';
      IF needsrefresh THEN msg[2] := 'R';
      lastchange := tint;
      
      rrrr_old := rrrr_new;

      FOR j := 1 TO 2 DO BEGIN
        {VVP CONFLICT RESOLUTION
         If two "logical" rings share the same "physical" VVP valves (e.g. CO2
         and O3 fumigation rings in Wisconsin), the possibility exists that the
         separate logic may issue conflicting commands to the same valves.
         The VVP pattern requested by two logical rings need not be the same
         even though the same wind sensors are used.  They may differ due to
         different low wind threshold, wind speed and direction integration
         times, and obviously fumigation ON versus OFF.
         Rings take turn setting their VVP valve patterns each control
         interval.  (A legacy of the Arizona doghouse.)  New code is added
         in Unit COMP, Procedure RRING, to check if a conflict exists and take
         appropriate action.  A general solution is provided.
         First, a variable set_your_valves is made TRUE.  Whether this logical
         ring will actually attempt to set the valves depends on if this
         variable remains true.  Then the data acquisition and control address
         for this ring's VVP valves is compared to that of the other rings.
         If there is no match (conflict), operation proceeds as usual.  If
         there is a match, set_your_valves is determined as follows:
           This ring ON; other ring OFF --> TRUE     (An ON ring
           This ring OFF; other ring ON --> FALSE     has priority.)
           Both the same (ON or OFF)
             This ring follows  other in the .CFG file --> TRUE
             This ring proceeds other in the .CFG file --> FALSE.
         (As of this writing 10/19/97, O3 logical rings come after the
         corresponding CO2 rings in the .CFG files.  Thus O3 has priority.)
         Proper action of this algorithm must be checked by observation in
         the field.  The program itself shows the result on the status screen
         (main menu).  The program can be seen cycling through the rings:
         1st, 2nd, etc.  If the ring's VVP action is being inhibited by one
         with higher priority, then an "FF" for false will appear where the
         "..", ".R", or "NR" usually do.}
        set_your_valves := TRUE;
        IF j = 1 THEN                             {fumigation rings only}
          FOR jj := 1 TO numrings DO
            IF jj <> no THEN                      {don't test against itself!}
              IF vvp_open_fumi.address            {test for conflict match}
                 = list_addr_ptr[jj]^.vvp_open_fumi.address THEN
                IF      runon[no] AND (NOT runon[jj])       {ON  OFF}
                  THEN set_your_valves := TRUE
                ELSE IF (NOT runon[no]) AND runon[jj]       {OFF  ON}
                  THEN set_your_valves := FALSE
                ELSE IF (no < jj)                           {ON ON or OFF OFF}
                  THEN set_your_valves := FALSE;
        IF set_your_valves = FALSE THEN msg := 'FF';
        CASE j OF
          1: dummy_daqc := vvp_open_fumi;
          2: dummy_daqc := vvp_open_cont;
          END;  {case}
        WITH dummy_daqc DO IF exists AND set_your_valves THEN
          FOR i := 0 TO (numvalvs-1) DIV channel DO BEGIN

            IF (channel = 8) THEN BEGIN  {e.g. Festo-CPX}
            mask := rval[no,1+i];
            mask := mask Xor vvpfailsafe[i];
            END;

            IF (channel = 16) THEN BEGIN  {e.g. Optomux}
            mask := (rval[no,2+2*i] Shl 8) Or rval[no,1+2*i];
            mask := mask Xor ((vvpfailsafe[1+2*i] Shl 8) Or vvpfailsafe[2*i]);
            END;

            IF protocol <> 'DS' THEN boffset := $01
                                ELSE boffset := $80;
            IF run_mode AND Connect.StateGet(no) THEN
              digital_out (PORT_RINGS, address+boffset*i, mask, comm_err[no]);
            END;  {boards for a ring}
        END;  {loop over fumigation and control vvp open}
      END;  {new pattern or refresh}

    END;  {of with [PORT_RINGS]}
  END;  {of with vvptime[no]}
  END;  {of procedure 'rring'}
{------------------------------------------------------------}

PROCEDURE files;
CONST debug = FALSE;
VAR i, no, ior: INTEGER;

PROCEDURE print_error (ringno, filetype, ior: INTEGER);
BEGIN
  WRITE ('RING ', ringno:1, '  FILETYPE ', filetype:1, '  ERR ', ior:1,
         ': ', SysUtils.SysErrorMessage(ior));
  END;  {of local procedure 'print_error'}

PROCEDURE special_file (site_id, key: String);
{write special files to network}
VAR msg,
    sss1: String;
    sss2: String;
    errcode: INTEGER;
BEGIN
{WI North rep [CO2]control}
  IF netinfo_installed AND netinfo_ptr^[1].init THEN BEGIN  {this is "901"}
    Str (gccntl[1]:5:0, sss1);
    Str (gccntl[2]:5:0, sss2);
    msg := site_id +','+ key +','+ comd.date +','+ comd.time +
           ','+ sss1 +','+ sss2 +',';
    netinfo_write (1, msg, FALSE, errcode);  {<-- hardwired as "901" !!!}
    END;
  END;  {of local procedure 'special_file'}

BEGIN
  IF tint >= tf1last+timestep[1] THEN BEGIN
    tf1last:=tint;
    {flush the debugging log file..keep almost up to date}
    DebugLogFileFlush;
    {write to any special files on 'netpath' here}
    special_file (site_id, cfgname);

    {read the netinfo files now}
    IF netinfo_installed THEN 
      FOR i := netinfo_addr_min TO netinfo_addr_max DO
        WITH netinfo_ptr^[i] DO IF init THEN BEGIN
          netinfo_clear (i);
          netinfo_read (i, ior);
          END;

    FOR no:=1 TO numrings DO IF Connect.StateGet(no) THEN BEGIN
      loggput[no]   := TRUE;
      loggcount[no] := 0;
      WITH loggrecord[no] DO BEGIN
        ssite := site_id;
        ddate := comd.date; ttime := comd.time;
        zzd := site_zd;
        wwspeed:=wspeed[no]; wwwdir:=wwdir[no];
        ppropc:=propc[no]; 
        ppropresp:=propresp[no]; 
        ggcgrab:=gcgrab[no];
        aagc1m:=agc1m[no].Integral; 
        aagc5m:=agc5m[no].Integral;
        ggcset:=gcset[no]; bback1:=back1[no];
        sstdwdir:=ROUND(stdwdir[no].Integral);
        avsd_calc (wspeed_avsd[no]);
        WITH wspeed_avsd[no] DO
          IF mean > 0.0 THEN ccvspeed := stddev/mean
                        ELSE ccvspeed := 0.0;
        avsd_init (wspeed_avsd[no]);
        ggccntl  := gccntl[no];
        ggcambi  := gcambi[no];
        ttemp1   := temp1 [no];
        ttemp2   := temp2 [no];
        pph2o    := ph2o  [no];
        aairpres := airpres[no];
        ssolrad  := solrad[no];
        sstatus := status_var[no].latched;
        END;
      status_var[no].needs_reset := TRUE;
      err[no].code := 0;
      err[no].msg  := '';

      loggfile^[(no-1)*10+loggpoint[no]]:=loggrecord[no];
      IF loggpoint[no]<10 THEN loggpoint[no]:=loggpoint[no]+1;

      {The buffered binary records may now be written out here}
      IF sfil[no,1] AND (loggpoint[no]>8) THEN BEGIN
        {$I-}
        RESET(logg[no]); Seek(logg[no],FileSize(logg[no]));
        ior := IOResult;
        IF (ior = 0) THEN FOR i:=1 TO loggpoint[no]-1 DO BEGIN
          WRITE(logg[no],loggfile^[(no-1)*10+i]);
          ior := IOResult;
          END;
        CloseFile (logg[no]);
        ior := IOResult;
        IF (ior <> 0) THEN print_error (no, 1, ior);
        {$I+}
        recnum[no,1]:=recnum[no,1]+loggpoint[no]-1;
        loggpoint[no]:=1;
        loggwrite[no]:=TRUE;
        END;

      {The ascii logg record written out here}
      logg2net (no);  {this procedure in COMLOG}

      END;
    END;

  IF tint>tf3last+timestep[3] THEN BEGIN
    tf3last:=tint;
    FOR no:=1 TO numrings DO IF Connect.StateGet(no) THEN BEGIN
      varrput[no]:=TRUE;
      WITH varrecord[no] DO BEGIN
        ddate := comd.date;          ttime := comd.time;
        aainteg_adj := ainteg_adj[no];  ccinteg := cinteg[no];
        aaprop_adj  := aprop_adj [no];  ccprop  := cprop [no];
        aadiff_adj  := adiff_adj [no];  ccdiff  := cdiff [no];
        aawind_adj  := awind[no];       ccwind  := cwind[no];
        ppropc := propc[no];    
        ggcinst := gcgrab[no];  
        ggcav := agcont[no].Integral;
        pproplearn := proplearn[no].Integral;  {added by J.N. 4/27/90}
        wwindlearn := windlearn[no].Integral;  { " }
        ggcset:=gcset[no];
        bback3:=back3[no];
        END;

      varrfile^[(no-1)*10+varrpoint[no]]:=varrecord[no];

      IF varrpoint[no]<10 THEN varrpoint[no]:=varrpoint[no]+1;
{      WRITELN('varrpoint[',no:1,']: ',varrpoint[no]:4);}

      IF sfil[no,3] AND (varrpoint[no]>8) THEN BEGIN
        {$I-}
        RESET(varr[no]); Seek(varr[no],FileSize(varr[no]));
        ior := IOResult;
        IF (ior = 0) THEN FOR i:=1 TO varrpoint[no]-1 DO BEGIN
          WRITE(varr[no],varrfile^[(no-1)*10+i]);
          ior := IOResult;
          END;
        CloseFile (varr[no]);
        ior := IOResult;
        IF (ior <> 0) THEN print_error (no, 3, ior);
        {$I+}
        recnum[no,3]:=recnum[no,3]+varrpoint[no]-1;
        varrpoint[no]:=1;
        varrwrite[no]:=TRUE;
      END;
    END;
  END;
END;  {of procedure 'files'}
{------------------------------------------------------------}

FUNCTION isrunon (ringno: INTEGER; tint: float): BOOLEAN;
PROCEDURE fan (rno: INTEGER; state: BOOLEAN);
{Used by special tests section to independently control fan
 J.N. 94/04/28
 }
BEGIN
  IF state 
    THEN BEGIN                         {fan ON, gas OFF} 
      onoff_mode[rno] := 1;
      gcset[rno]      := 300.0;
      calarm[rno]     := 1000.0;
      proplearn[rno].Integral  := 0.0;
      cinteg[rno]     := 0.0;
      END
    ELSE onoff_mode[ringno] := 0;      {both OFF}
  END;  {of local procedure 'fan'}
BEGIN
  {Code for special tests.
   Move "terminating comment" up to next line to activate this code.

  WITH parrecord[ringno] DO BEGIN
    onoff_mode[ringno] := oonoff_mode;
    gcset[ringno]      := ggcset;
    calarm[ringno]     := ccalarm;
    IF (tint/3600.0 >= 19.5) OR (tint/3600.0 < 07.0) THEN CASE ringno OF
      1:      IF ((day <= 7)                ) THEN fan (ringno, TRUE)
         ELSE IF ((day  = 8) AND (hour < 12)) THEN fan (ringno, TRUE)
         ELSE fan (ringno, (hour MOD 2) = 0);
      2:      IF ((day >= 9)                ) THEN fan (ringno, TRUE)
         ELSE IF ((day  = 8) AND (hour > 12)) THEN fan (ringno, TRUE)
         ELSE fan (ringno, (hour MOD 2) = 0);
      3: fan (ringno, FALSE); 
      END;
    END;

    *** TERMINATING COMMENT}

  CASE onoff_mode[ringno] OF
    0: isrunon := FALSE;
    1: isrunon := TRUE;
    2: isrunon := (tint >  60.0*timeon [ringno]) AND 
                  (tint <= 60.0*timeoff[ringno]);
    3: BEGIN
       isrunon := (helios_var.sun_alt.degrees > dawn_altitude[ringno]);
       helios_riset (dawn_altitude[ringno]);
       solar_ton [ringno] := helios_var.sun_rise.txt;
       solar_toff[ringno] := helios_var.sun_set .txt;
       END;
    END;

  END;  {of function 'isrunon'}
{------------------------------------------------------------}

FUNCTION conditional_test (ringno: INTEGER; tint: float): BOOLEAN;
VAR conditional_last: ARRAY [1..max_conditionals] OF BOOLEAN;
    lopoint, hipoint: float;
    condno: INTEGER;
BEGIN
  conditional_test := TRUE;  {finished if global conditional not enabled}
  FOR condno := 1 TO num_conditionals DO BEGIN
    conditional_last[condno] := conditional_state[ringno][condno];
    conditional_state[ringno][condno] := TRUE;
    END;
  IF conditional_enabled[ringno] THEN BEGIN
    FOR condno := 1 TO num_conditionals DO
      WITH conditional_var^[ringno][condno] DO
        IF enable THEN BEGIN
          lopoint := low;                     {use these when currently OK}
          hipoint := high;
          IF NOT conditional_last[condno] THEN BEGIN   {provide hysteresis}
            lopoint := lopoint + hysteresis;
            hipoint := hipoint - hysteresis;
            END;
          IF (conditional_value[ringno][condno].Integral < lopoint) OR
             (conditional_value[ringno][condno].Integral > hipoint) THEN BEGIN
               conditional_state[ringno][condno] := FALSE;
               conditional_test := FALSE;
               END;
          END;  {of a specific condition test}
    END;  {of global conditional enabled}
  END;  {of function 'conditional_test'}
{------------------------------------------------------------}

PROCEDURE make_msg_fast (ring: INTEGER; VAR msg: String);
{Modified make_msg() of COMLOG99}

VAR fulldate, t1, t2, t3: String;
    d1990,
    sunalt,
    suntime: REAL;
    sunstr:  String;  {suntime as HH:MM}
    i, code: INTEGER;

PROCEDURE ivw (value, cols: INTEGER);
VAR s: String;
    i: Integer;
BEGIN
  Str (value:cols, s);
  IF (Length(s) > cols) THEN BEGIN
    s := '';
    FOR i := 1 TO cols DO s := s + ' ';
    END;
  msg := msg + ' ' + s;
  END;  {of local procedure 'ivw'}

PROCEDURE fvw (value: Double; cols, decpts: INTEGER);
VAR s: String;
    i: Integer;
BEGIN
  Str (value:cols:decpts, s);
  IF (Length(s) > cols) THEN BEGIN
    s := '';
    FOR i := 1 TO cols DO s := s + ' ';
    END;
  msg := msg + ' ' + s;
  END;  {of local procedure 'fvw'}

BEGIN
  Str (year :4, t1);
  Str (month:2, t2);
  Str (day  :2, t3);
  fulldate := t1 + '/' + t2 + '/' + t3;
  FOR i := 1 TO Length(fulldate) DO 
    IF fulldate[i] = ' ' THEN fulldate [i] := '0';
  d1990 := mjd(year,month,day) - mjd(1990,1,1) + 1 +
           ((hour + (minute + second/60.0)/60.0)/24.0);
  suntime := 3600.0*( 
             24.0*(d1990 - TRUNC(d1990)) +  {civil sec into day}
             helios_var.site_lead.td +      {mean leads civil}
             helios_var.eqoft.td ) +        {equation of time}
             30.0;                          {will be truncated to minute}
  IF (suntime >= 86400.0) THEN suntime := suntime - 86400.0;
  IF (suntime <      0.0) THEN suntime := suntime + 86400.0;
  sunstr  := Copy (hhmmss(suntime),1,5);
  sunalt := helios_var.sun_alt.degrees;
  msg := site_id;
  ivw (rhex[ring], 2);
  msg := msg + ' ' + fulldate;
  msg := msg + ' ' + comd.time;
  fvw (d1990, 10, 5);
  ivw ((status_var[ring].current Shr  4) And 3 {emode},     1);
  ivw (1-((status_var[ring].current Shr  7) And 1) {fumienab},  1);
  ivw (1-((status_var[ring].current Shr  6) And 1) {condiok},   1);
  ivw (ORD(((status_var[ring].current Shr  6) And 3) = 0 {fumion}), 1);
  ivw ((status_var[ring].current Shr  8) And 1 {debugging}, 1);
  ivw ((status_var[ring].current Shr 11) And 1 {calibenab}, 1);
  ivw ((status_var[ring].current Shr 10) And 1 {calibact},  1);
  ivw ((status_var[ring].current Shr 12) And 1 {alarm_pv},  1);
  ivw ((status_var[ring].current Shr 13) And 1 {alarm_gc},  1);
  ivw ((status_var[ring].current Shr 14) And 1 {alarm_dc},  1);
  ivw (0                      {future1},   1);
  ivw (0                      {future2},   1);
  fvw (wspeed[ring],   4, 1);
  fvw (0,              4, 2);  {Assume cvspeed meaningless here}
  ivw (wwdir[ring],    3);
  ivw (0,              3);     {Assume stdwdir meaningless here}
  fvw (temp1[ring],    5, 1);
  fvw (temp2[ring],    5, 1);
  fvw (10.0*airpres[ring], 4, 0);
  fvw (ph2o[ring],     5, 0);
  fvw (solrad[ring],   4, 0);
  fvw (0.0,       4, 0);
  fvw (sunalt,    5, 1);
  msg := msg + ' ' + sunstr;
  ivw (9 {gas},   1); 
  fvw (propc[ring],    6, 1);
  fvw (propresp[ring], 6, 1);
  fvw (gcambi[ring],   6, 1);
  fvw (gccntl[ring],   6, 1);
  fvw (gcset[ring],    6, 1);
  fvw (gcgrab[ring],   6, 1);
  fvw (agc1m[ring].Integral,    6, 1);
  fvw (agc5m[ring].Integral,    6, 1);
  END;  {of procedure 'make_msg'}
{---------------------------------------------------------------------}

PROCEDURE tinter;
CONST thisproc = 'TINTER: ';
VAR ring, group, period: INTEGER;
    i, v: INTEGER;
    fanbits, gasbits: INTEGER;
    mask, mask_fan, mask_gas: Word;
    temp_highest,         {used in conditional fumigation section}
    wind_lowest:  float;
    errfound: BOOLEAN;
    msg: String;
    fan_boolean, gas_boolean: BOOLEAN;

BEGIN

{***TEMPORARY***}
{Needed if Ring Pictures closed using [X]}
IF inrings Then IF NOT IsWindow(hWndGraph) THEN inrings := FALSE;

IF NOT archive_mode THEN BEGIN

  {Process graph32 messages}
  windows_message_loop;
  
  tintlast := tint;
  currenttime (tint, hour, minute, second);
  comd.time := hhmmss(tint);

  multiport ('FLAG');  {provide MPLink protocol data to other cpu's}

  IPServ.Process;  {see if another program requesting data using IP}

  IF (tint-tintlast) < (-60) THEN BEGIN  {we have passed midnight}
    FOR ring := 1 TO numrings DO BEGIN
      tsamplast[ring]:=0.0;
      tcontlast[ring]:=0.0;  
      calibrate_var[ring].enable := FALSE;
      calibrate_var[ring].active := FALSE;
      AmbientMultiportCalibratingSet (FALSE);  {nothing else will}
      END;
    tf1last:=0.0; tf2last:=0.0; tf3last:=0.0;
    timeerrlast := 0.0;
    tmplinklast := 0.0;
    FOR i := 1 TO maxfcplink DO tfcplinklast[i] := 0.0;
    ambmp_hardware_var.tint_begin := -3600.0;  {kill running cycle}
    END;

  IF tint >= tsamplast[1]+tsamp[1] THEN BEGIN  {other tsamp[] ignored for now}

    {See if time to collect FCPLink data from other FCP's}
    FOR i := 1 TO maxfcplink DO
      WITH DataComm.Ports[PORT_FCPLINK_BASE+i] DO
        IF exists THEN
          IF (tint-tfcplinklast[i]) > FileRec.param1 THEN BEGIN
            objLineIn.Process (PORT_FCPLINK_BASE+i);
            tfcplinklast[i] := tint;
            END;

    {If this is Festo, (re)open the UDP port here}
    IF (DataComm.Ports[PORT_RINGS].protocol = 'FE') THEN
      WITH DataComm.Ports[PORT_RINGS].IPRec.objFestoCI DO BEGIN
      Close;
      Open;
      END;

    {Heartbeats on}
    frmMain.HeartBeat (TRUE);
    FOR ring := 1 TO numrings DO BEGIN
      Alarms.HeartBeat (ring, TRUE);
      Status.HeartBeat (ring, TRUE);
      FOR group := 1 TO LG_GROUP_MAX DO
        FOR period := 1 TO LG_PERIOD_MAX DO
          LineGraf.HeartBeat (ring, group, period, TRUE);
      END;

    {Trailer alarm}
    errfound := FALSE;
    FOR ring := 1 TO numrings DO
      errfound := errfound OR (errlatch[ring].code <> 0 );
    IF (errfound OR Alarms.TestAudibleGet) THEN
      FOR i := 1 TO 1 DO Windows.MessageBeep (message_beep_code);

    {Initialize direct RS232 read out of LiCor IRGA's}
    IF run_mode THEN 
      FOR i := licor_addr_min TO licor_addr_max DO licor_start (i);

    Watchdog.DialoutSet (FALSE);
    FOR ring := 1 TO numrings DO
      FOR i := 0 TO 15 DO WITH errseq[ring][i] DO
        IF (dialout_count >= 0) AND (count > dialout_count)
          THEN Watchdog.DialoutSet (TRUE);

    {sun ephemeris calculations}
    currentdate (comd.date, year, month, day);
    helios_decra (year, month, day, hour, minute, second);
    doy := helios_var.lct.doy;
    helios_altaz;

    FOR ring:=1 TO numrings DO BEGIN
      tsamplast[ring] := tint;
      {has calibration mode timed out?}
      WITH calibrate_var[ring] DO IF enable
        THEN BEGIN
          enable := (tint < timeoff);
          active := FALSE;
          END
        ELSE active := FALSE;  {paranoid, but safe}

      {determine if ring is running or not}
      fumigation_enabled[ring] := isrunon (ring, tint);
      conditional_ok[ring] := conditional_test (ring, tint);
      runon[ring] := fumigation_enabled[ring] AND
                       (oper[ring] OR debug[ring]) AND
                       conditional_ok[ring];

      {upon a false to true transition of runon, i.e. after a brief
       conditional off, clear all histograms for the ring and clear errors.}
      IF (runon[ring]=TRUE) AND (runsave[ring]=FALSE) THEN BEGIN
        clearhist (ring, 0, numrings);
        END;
      runsave[ring] := runon[ring];

      {upon a false to true transition of fumigation_enabled, i.e. morning
       startup, set cinteg and proplearn to 0.0 to ensure slow turn on of
       treatment.  Motivated by commisioning of O3 running.
       Compromised cinteg = preset 99/07/07.
       }
      IF (fumigation_enabled[ring]=TRUE) AND (fumisave[ring]=FALSE) THEN
        BEGIN
        cinteg[ring] := preset[ring];
        proplearn[ring].Integral := 0.0;
        END;
      fumisave[ring] := fumigation_enabled[ring];
      END;  {of ring run on/off loop}

    {*** Application.MessageBox ('Marker 1', 'TINTER', MB_OK); {***}
    {*** Application.MessageBox ('Marker 2', 'TINTER', MB_OK); {***}
    adc_read_clear;       {reset having read any opto22-type ADC board}
    licor_clear(-1);      {reset having read all LiCor's}
    IF ambmp_hardware_var.commerr THEN ambient_mp_init;
    FOR ring := 1 TO numrings DO idataput[ring]:=TRUE;
    FOR ring := 1 TO numrings DO IF Connect.StateGet(ring) THEN BEGIN
      {put into DataComm --- optomux_debug := faceraw_switch[ring];}
      IF comm_err[ring] THEN relinit(ring);
      IF NOT comm_err[ring] THEN BEGIN
        sampling(ring);
        average(ring);
        wwdir[ring]:=wdir(winddir[ring]);
        Str(wdir(awinddir[ring]):4,awwdir[ring]);
        histogram;
        END;
      WITH status_var[ring] DO BEGIN  {service the status words}
        IF needs_reset THEN BEGIN
          latched := rhex[ring];
          needs_reset := FALSE;
          END;
        current := 0;
        current := current Or (enrich_mode[ring]                   Shl  4);
        current := current Or (ORD(NOT conditional_ok[ring])       Shl  6);
        current := current Or (ORD(NOT fumigation_enabled[ring])   Shl  7);
        current := current Or (ORD(debug[ring])                    Shl  8);
{temp}  current := current Or (ORD(NOT conditional_state[ring][3]) Shl  9);
        current := current Or (ORD(calibrate_var[ring].active
                             OR autocalib_var[ring][Zero].active
                             OR autocalib_var[ring][Span].active)  Shl 10);
        current := current Or (ORD(calibrate_var[ring].enable)     Shl 11);
        current := current Or (ORD((err[ring].code And $1)<>0)     Shl 12);
        current := current Or (ORD((err[ring].code And $2)<>0)     Shl 13);
        current := current Or (ORD(comm_err[ring])                 Shl 14);
{wind}  current := current Or (ORD((NOT conditional_state[ring][1])
                                OR (NOT conditional_state[ring][4])) Shl 15);
        latched := latched Or current;
        END;
      INC(loggcount[ring]);
      END;  {end of sampling loop over rings}

    FOR ring := 1 TO numrings DO IF Connect.StateGet(ring) THEN BEGIN

      {1}
      conditional_var^ [ring][1].title := '    WIND   SPEED';
      conditional_value[ring][1].RangeMin :=  0.0;
      conditional_value[ring][1].RangeMax := 50.0;
      conditional_value[ring][1].Integrate (wspeed[ring]); 

      {2}
      conditional_var^ [ring][2].title := '    ENCL    TEMP';
      conditional_value[ring][2].RangeMin := -40.0;
      conditional_value[ring][2].RangeMax :=  70.0;
      conditional_value[ring][2].Integrate (temp2[ring]); 

      {3}
      conditional_var^ [ring][3].title := ' HIGHEST AIRTEMP';
      conditional_value[ring][3].RangeMin := -40.0;
      conditional_value[ring][3].RangeMax :=  70.0;
      IF ring  = 1 THEN BEGIN
        temp_highest := -999.9;
        FOR i := 1 TO numrings DO
          IF temp1[i] > temp_highest THEN temp_highest := temp1[i];
        conditional_value[ring][3].Integrate (temp_highest);
        END;
      IF ring <> 1
        THEN conditional_value[ring][3].Integral := 
             conditional_value[1]   [3].Integral;

      {4}
      {Replace this one by facility wide wind speed condition---
      conditional_var^ [ring][4].title := '     GAS  DEMAND';
      IF conditional_var^[ring][4].int <= 0.0
        THEN conditional_value[ring][4] :=  propc[ring]
        ELSE lpf (conditional_value[ring][4], propc[ring], 
                  tsamp[no]/conditional_var^[ring][4].int);
      --}

      {4}
      conditional_var^ [ring][4].title := '  LOWEST WINDSPD';
      conditional_value[ring][4].RangeMin :=  0.0;
      conditional_value[ring][4].RangeMax := 50.0;
      IF ring  = 1 THEN BEGIN
        wind_lowest := +999.9;
        FOR i := 1 TO numrings DO
          IF (awspeed[i].Integral < wind_lowest) AND
             (awspeed[i].Integral > 0.05) 
               THEN wind_lowest := awspeed[i].Integral;
          conditional_value[ring][4].Integrate (wind_lowest); 
        END;
      IF ring <> 1
        THEN conditional_value[ring][4].Integral := 
             conditional_value[1]   [4].Integral;

      END;  {end of calculating values used for conditional running}

    {Call to files; was here}

    IF tint>=tcontlast[1]+tcont[1] THEN BEGIN  {use only ring 1's for now}

      {fan and gas shut off valve control}
      fanbits := 0; gasbits := 0;  v:=1;

      FOR ring := 1 TO numrings DO IF Connect.StateGet(ring) THEN
       WITH list_addr_ptr[ring]^ DO BEGIN
        {put into DataComm --- optomux_debug := faceraw_switch[ring];}
        tcontlast[ring] := tint;
        IF NOT comm_err[ring] THEN algorithm(ring);

{+++++This section for fan and quarter turn valve setting with Optomux+++++}

        IF (DataComm.Ports[PORT_RINGS].protocol = 'OS') OR
           (DataComm.Ports[PORT_RINGS].protocol = 'DS') THEN BEGIN

        IF NOT debug[ring] THEN BEGIN
          IF runon[ring]         THEN fanbits:=fanbits+v;
          fan_debug_set[ring] := runon[ring];
          setco2qt (ring,
            runon[ring] AND
            (propc[ring]>0.001*pv_control.offscale));
          END;
        IF     debug[ring] THEN BEGIN
          IF fan_debug_set[ring] THEN fanbits:=fanbits+v;
          co2qt[ring].state := gas_debug_set[ring];
          END;
        gas_debug_set[ring] := co2qt[ring].state;
        IF co2qt[ring].state THEN gasbits:=gasbits+v;
        v:=v*2;

        IF (NOT comm_err[ring]) THEN BEGIN  
          {assumes fan and gas on/off at same addr!}
          IF fan_onoff_fumi.exists
            THEN mask_fan := $1 Shl fan_onoff_fumi.channel
            ELSE mask_fan := 0;
          IF gas_shutoff.exists
            THEN mask_gas := $1 Shl gas_shutoff.channel
            ELSE mask_gas := 0;
          mask := mask_fan OR mask_gas;
          IF run_mode THEN BEGIN
            IF fan_debug_set[ring] AND gas_debug_set[ring]
              THEN BEGIN
                activate_digital (PORT_RINGS, fan_onoff_fumi.address, mask)
              END;
            IF fan_debug_set[ring] AND (NOT gas_debug_set[ring])
              THEN BEGIN
                activate_digital (PORT_RINGS, fan_onoff_fumi.address, mask_fan);
              deactivate_digital (PORT_RINGS, gas_shutoff   .address, mask_gas);
              END;
            IF (NOT fan_debug_set[ring]) AND gas_debug_set[ring]
              THEN BEGIN
              deactivate_digital (PORT_RINGS, fan_onoff_fumi.address, mask_fan);
                activate_digital (PORT_RINGS, gas_shutoff   .address, mask_gas);
              END;
            IF (NOT fan_debug_set[ring]) AND (NOT gas_debug_set[ring])
              THEN BEGIN
              deactivate_digital (PORT_RINGS, fan_onoff_fumi.address, mask);
              END;
            IF fan_onoff_cont.exists THEN BEGIN
              mask := $1 Shl fan_onoff_cont.channel;
              IF fan_debug_set[ring]
                THEN   activate_digital (PORT_RINGS, fan_onoff_cont.address, mask)
                ELSE deactivate_digital (PORT_RINGS, fan_onoff_cont.address, mask);
              END;
            comm_err[ring] := comm_err[ring] OR optomux_var.error;
            END;
          END;

        END;  {of Optomux section}

{+++++This section for fan and quarter turn valve setting with Festo+++++++}

        IF (DataComm.Ports[PORT_RINGS].protocol = 'FE') THEN BEGIN

        IF (NOT debug[ring]) THEN BEGIN
          fan_boolean := runon[ring];
          gas_boolean := runon[ring] AND
                        (propc[ring]>0.001*pv_control.offscale);
          fan_debug_set[ring] := fan_boolean;
          gas_debug_set[ring] := gas_boolean;
          END;

        IF debug[ring] THEN BEGIN
          fan_boolean := fan_debug_set[ring];
          gas_boolean := gas_debug_set[ring];
          END;

        WITH DataComm.Ports[PORT_RINGS].IPRec.objFestoCI DO BEGIN
          {Open;}
          WITH fan_onoff_fumi DO BitWrite ('A',fan_boolean, address, channel);
          WITH gas_shutoff    DO BitWrite ('A',gas_boolean, address, channel);
          {Close;}
          END;

        END;  {of Festo section}

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}


        END;

    {vertical ventpipe valve open/close}
      ifire:=ifire+1; 
      IF (ifire>numrings) AND (ifire>4) THEN ifire:=1;
      IF (ifire IN [1..numrings]) AND (NOT comm_err[ifire]) THEN BEGIN
        {put into DataComm --- optomux_debug := faceraw_switch[ifire];}
        rring(ifire);
        IF inrings AND (topo[ifire] IN [1..4]) THEN BEGIN
          putring (topo[ifire], ifire, numvalvs);
          puthisto (ifire);
          END;
        END;
      END;  {of control period}

    IF inrings THEN
      FOR ring := 1 TO numrings DO
        IF (topo[ring] IN [1..4])
          THEN putwindow(ring);
    IF dataflow_show THEN dataflow(1);
    IF tint > (timeerrlast+timeerrtest) THEN Alarms.errcheck;

    snapshot_toggle := NOT snapshot_toggle;
    IF snapshot_toggle THEN BEGIN
      INC(snapshot_index);
      IF NOT (snapshot_index IN [1..180]) THEN BEGIN
        snapshot_index := 1;
        INC(snapshot_fill);
        IF NOT (snapshot_fill IN [1..snapshot_size]) THEN snapshot_fill := 1;
        END;
      FOR ring := 1 TO numrings DO
        WITH snapshot_ray^[ring][snapshot_fill]^[snapshot_index] DO BEGIN
          zeit    := comd.time;
          igcgrab := pround (gcgrab  [ring]);
          igc1min := pround (agc1m[ring].Integral);
          igccntl := pround (gccntl  [ring]);
          propctl := pround (propc   [ring] * 10.0);
          proprsp := pround (propresp[ring] * 10.0);
          windspd := pround (wspeed  [ring] * 100.0);
          winddir := pround (wwdir   [ring]);
          kinteg  := pround (cinteg  [ring] * 10.0);
          kprop   := pround (cprop   [ring] * 10.0);
          kwind   := pround (cwind   [ring] * 10.0);
          igcset  := pround (gcset   [ring]);
          END;
      END;

    {Streaming of fast data to net information file every "sep" seconds}
    IF netinfo_installed THEN WITH netinfo_ptr^[2] DO IF init THEN
      IF (loggcount[1] MOD ORD(sep)) = 0 THEN BEGIN
        make_msg_fast (1, msg);           {<-- hardwired ring 1 only  !!!}
        netinfo_write (2, msg, TRUE, i);  {<-- hardwired as "902"     !!!}
        IF (loggcount[1] MOD 100*ORD(sep)) = 1 
          THEN netinfo_reduce (2, 60, 100000, i);
        END;
    
    FOR ring := 1 TO numrings DO BEGIN
      IF runon[ring] THEN 
        IF simul_mode 
          THEN RingColorValueSet (1, ring, clBlue)
          ELSE RingColorValueSet (1, ring, clLime);
      IF NOT conditional_ok[ring]   
        THEN RingColorValueSet (1, ring, clYellow);
      IF NOT fumigation_enabled[ring]            
        THEN RingColorValueSet (1, ring, clWhite);
      RingColorValueSet (2, ring, RingColorValueGet (1, ring));
      IF (errlatch[ring].code <> 0) 
        THEN RingColorValueSet (2, ring, clRed);
      END;

    {Update any real time variables on forms}
    RingColorToggleMasterSet (NOT RingColorToggleMasterGet); 
    FOR ring := 1 TO numrings DO BEGIN
      Status.UpdateIt (ring);  {This one first for toggling}
      Alarms.UpdateIt (ring);
      FOR group := 1 TO LG_GROUP_MAX DO
        FOR period := 1 TO LG_PERIOD_MAX DO
          LineGraf.UpdateIt (ring, group, period);
      END;
    frmMain.UpdateIt;
    Compare.UpdateIt;
    CalibAut.UpdateIt;
    CalibMan.UpdateIt;
    Ephem.UpdateIt;
    H2OVapor.UpdateIt;
    MPSample.Updateit;

    IF (NOT archive_mode) AND 
       (NOT Watchdog.DialoutGet) THEN Watchdog.Pet;

    {Heartbeats off}
    frmMain.HeartBeat (FALSE);
    FOR ring := 1 TO numrings DO BEGIN
      Alarms.HeartBeat (ring, FALSE);
      Status.HeartBeat (ring, FALSE);
      FOR group := 1 TO LG_GROUP_MAX DO
        FOR period := 1 TO LG_PERIOD_MAX DO
          LineGraf.HeartBeat (ring, group, period, FALSE);
      END;

    IPServ.Process;
    IPServ.Close;
    IPServ.Open;

    END;  {of sampling period satisfied}

  files;

  END;  {of not archive mode}

  END;  {of procedure 'tinter'}
{------------------------------------------------------------}

PROCEDURE tinter1;
{initialize time "last" variables}
VAR i: INTEGER;
BEGIN
  tintlast:=tint;
  currenttime (tint, hour, minute, second);
  comd.time := hhmmss(tint);
  tlast:=tint;
  tmplinklast := 0.0;
  FOR i := 1 TO maxfcplink DO tfcplinklast[i] := 0.0;
  FOR i := 1 TO numrings DO BEGIN
    tsamplast[i]:=tint;
    tcontlast[i]:=tint;
    END;

  currentdate (comd.date, year, month, day);

  END;  {of procedure 'tinter1'}
{------------------------------------------------------------}

PROCEDURE ikbin;
BEGIN
  IF graph32.Event.Flag
    THEN WITH graph32.Event DO BEGIN {graph32.Event.Flag was true}
      Flag := FALSE;
      calr := KeyChar1;
      alr  := ORD(calr);
      IF alr = 0 THEN cahr := KeyChar2
                 ELSE cahr := CHR(0);
      ahr := ORD(cahr);
      IF (alr = 255) THEN BEGIN
        mouse_convert (Button, X, Y, alr, ahr, calr, cahr);
        END;
      END
    ELSE BEGIN  {Console KeyPressed was true}
      calr := ReadKey;
      alr  := ORD(calr);
      IF alr = 0 THEN cahr := ReadKey
                 ELSE cahr := CHR(0);
      ahr := ORD(cahr);
      IF (alr = 255) THEN WITH crt32_mouse DO
        mouse_convert (button, col, row, alr, ahr, calr, cahr);
      END;
  END;  {of procedure 'ikbin'}
{------------------------------------------------------------}

PROCEDURE kbin;
BEGIN
  REPEAT
    tinter;
    windows_message_loop;
    Application.ProcessMessages;
    windows_message_loop;
    UNTIL KeyPressed OR graph32.Event.Flag;
  ikbin;
END;  {of procedure 'kbin'}
{------------------------------------------------------------}

PROCEDURE pauseat (row, col: INTEGER);
VAR colorsave: INTEGER;
BEGIN
  GotoXY (row,col);
  colorsave := TextAttr;
  TextColor (LightGray + Blink);
  WRITE ('Hit any key to continue...');
  kbin;
  TextColor (colorsave);
  GotoXY (row,col);  ClrEol;
  END;  {of procedure 'pauseat'}
{------------------------------------------------------------}

PROCEDURE caccept;
BEGIN
  kbin;
  WRITE(calr);
END;  {of procedure 'caccept'}
{------------------------------------------------------------}

PROCEDURE saccept;
CONST bs = 8;
      cr = 13;
{puts characters typed in on console into string 'svalue'
 including terminating CR (ascii 13) -- Z.K.
 add backspace capability -- J.N.}
BEGIN
  FillChar(svalue,SizeOf(svalue),' ');
  svalue[0] := #30;
  Delete(svalue,1,30);
  REPEAT
    caccept;
    IF alr<>bs THEN svalue:=svalue+calr
               ELSE BEGIN
                 Delete(svalue,Length(svalue),1);
                 WRITE(' ',CHR(bs));
                 END;
    UNTIL alr=cr;
  END; {of procedure 'saccept'}
{------------------------------------------------------------}

PROCEDURE daccept;
VAR i: Byte;
{puts digit characters typed in on console into string 'svalue';
 no other characters go into the string}
BEGIN
  saccept;
  i := 1;
  REPEAT
    IF svalue[i] IN ['0'..'9'] THEN i := i+1
                               ELSE Delete(svalue,i,1);
    UNTIL i>Length(svalue);
  END;  {of procedure 'daccept'}
{------------------------------------------------------------}

PROCEDURE iaccept(VAR lvalue: Longint);
VAR rr: float;
{accept integer input from the console -- Z.K.
 modified to go through procedure raccept -- J.N.}
BEGIN
  raccept(rr);
  lvalue:=ROUND(rr);
  END;  {of procedure 'iaccept'}
{------------------------------------------------------------}

PROCEDURE raccept(VAR rvalue: float);
{accept floating point input from console -- Z.K.
 modified to eliminate invalid characters -- J.N.
 should use 'code' in argument list and REPEAT..UNTIL loop}
VAR code,i: INTEGER;
BEGIN
  saccept;
  i := 1;
  REPEAT
    IF (svalue[i] IN ['0'..'9']) OR
       (svalue[i] = '.')         OR
       (svalue[i] = '-')         OR
       (svalue[i] = 'E')         OR
       (svalue[i] = 'e')         THEN i := i+1
                                 ELSE Delete(svalue,i,1);
    UNTIL i>Length(svalue);
  Val(Copy(svalue,1,Length(svalue)),rvalue,code);
  END;  {of procedure 'raccept'}
{------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of unit COMP.PAS...}
END.
