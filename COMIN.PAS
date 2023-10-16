Unit comin;
{$H-}

Interface

Uses
  crt32,
  Globals, comd, comdis, comu;

PROCEDURE fileinit (no: INTEGER);

{*
 * Name:     COMINyy.PAS
 *
 * Purpose:  BNL FACE Project
 *           On-line data acquisition, control, and monitoring
 *           Run initialization routines
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
 *   (3) Default (no PARRx files) cont[no] (continuous running)
 *       set to TRUE if simulating, FALSE otherwise.
 *   (4) Default (no PARRx files) timeon and timeoff set to
 *       0450 and 1905 hrs (5 am to 7 pm) as per Atlanta meeting.
 *   (5) timeon and timeoff changed from floating point seconds since
 *       midnight to integer minutes since midnight
 *
 * Version:     3
 * Date:        03-02-92
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Removed many redundant BEGIN/END pairs
 *   (2) Added many IF's to incorporate DAT's 'fileinit'
 *
 * Version:     4
 * Date:        November/December 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Delete backuppath[], add vvpvar.period[] references related to PARR
 *   (2) Make tsamp[ring] and tcont[ring] rather than same for all rings.
 *   (3) Make default state for writing STAT files FALSE.
 *
 * Version:     5
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as COMIN94.                                      [12/10/93]
 *   (2) PARR file new/replaced variables changes                   [12/13/93]
 *   (3) Replace calarm_bracket, _base setting by calarm.           [12/14/93]
 *   (4) Add pidfactormin[], pidfactormax[] setting.                [12/15/93]
 *   (5) Add calcualtion of dawn_alt_sin & dawn_alt_cos[].          [12/23/93]
 *
 * Version:     6
 * Date:        March 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use of new graphics display file format.             [03/08/94]
 *   (2) With no parr files present, make defaults CH1 or Else      [03/16/94]
 *
 * Version:     7
 * Date:        June 1994
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Empty file initialization for "snapshot" type graphics.    [94/06/26]
 *
 * Version:     8
 * Date:        Feb 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMIN95.PAS                                        [95/02/21]
 *
 * Version:     9
 * Date:        June 1995
 * Changes:
 *   (1) Changes due to adding pH2O to auxiliary display screen     [95/06/16]
 *
 * Version:     10
 * Date:        Oct 1995, Jan 1996, June 1996
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMIN96.PAS; update Uses.                          [95/10/14]
 *   (2) gcset --> eenrich_val[];  initialize eenrich_base[]        [95/11/19]
 *   (3) remove site specific initializations when file missing     [95/11/19]
 *   (4) initialize conditional_enabled, conditional_var            [96/01/07]
 *   (5) provide reasonable initialization of agc1m[] and agc1hr[]  [96/06/06]
 *
 * Version:     11
 * Date:        Dec 1996
 * Changes:
 *   (1) Becomes COMIN97.PAS; update Uses.                          [96/12/22]
 *
 * Version:     12
 * Date:        January 1997
 * Changes:
 *   (1) fileinit: changes related to conditional_var being on heap.[97/01/12]
 *   (2) fileinit: all conditional_var are undefined.  Title and    [97/01/12]
 *         tested value will be coded in comp/tinter.  Parameters will be
 *         part of the PARR handling.
 *
 * Version:     13
 * Date:        October 1997
 * Changes:
 *   (1) fileinit: initialize new var fumisave[] as FALSE.          [97/10/23]
 *
 * Version:     14
 * Date:        December 1997
 * Changes:
 *   (1) Becomes COMIN98.PAS; update Uses.                          [97/12/23]
 *   (2) fileinit(): change enrich_val[][]:= loop from 0..2 to 0..3 [97/12/29]
 *   (3) fileinit(): initialize PARR rec with enrich_val[][3] = 99  [97/12/29]
 *   (4) fileinit(): initialize agc1m with enrich_val[][3] if mode=3[97/12/29]
 *   (5) fileinit(): replace 5x agc1hr/aagc1hr by agc5m/aagc5m      [97/12/29]
 *   (6) fileinit(): replace gcont, etc. by gcgrab.                 [97/12/29]
 *
 * Version:     15
 * Date:        1998
 * Changes:
 *   (1) fileinit(): Assign (ambmp_def_file, datapath+AMBMP.SET)    [98/10/25]
 *   (2) fileinit(): Read the ambient multiport definition file     [98/10/25]
 *
 * Version:     16
 * Date:        1999
 * Changes:
 *   (1) Uses faced99 (instead of 98).                              [99/01/15]
 *   (2) Change 2 occurences of disprecord[] to disprecord^[].      [99/01/28]
 *   (3) fileinit: no-PARR file default for enrich_val[,3] make 0.0 [99/04/12]
 *   (4) fileinit: init agc1m and 5m to funpack(...                 [99/04/12]
 *   (5) Uses comu98 to pick up function funpack()                  [99/04/12]
 *   (6) rewriterr: output IOResult value on file open for writing  [99/05/17]
 *   (7) fileinit: change IOResult <> to errno := IOResult; errno <>[99/05/17]
 *   (8) ambmperr:  output IOResult value on file err and halt      [99/06/17]
 *   (9) Add COMS to Uses                                           [99/06/19]
 *  (10) Negate v15 and v16 #8 and #9; move ambient stuff to COMP   [99/07/12]
 *
 * Version:     17
 * Date:        2000
 * Changes:
 *   (1) Becomes COMIN99.PAS; update Uses.                          [99/12/13]
 *   (2) IFDEF TURBO and DELPHI in Uses.                            [00/01/19]
 *   (3) $H- directive added to use old Pascal strings.             [00/02/14]
 *   (4) rewriterr: changes reflecting required .SET files.         [00/09/07]
 *   (5) fileinit: do not create .SET when they don't exist; abort. [00/09/07]
 *   (6) fileinit: delete setting parameters to default values.     [00/09/07]
 *   (7) rewriterr: Halt replaced by Halt (601);                    [00/09/26]
 *
 * Version:     18
 * Date:        2001
 * Changes:
 *   (1) emptyerr: new; err msg and halt if parr present but empty  [01/05/08]
 *   (2) fininit:  trap on an empty parr file                       [01/05/08]
 *
 * Version:     19
 * Date:        2002
 * Changes:
 *   (1) Unit renamed comin                                         [02-03-21]
 *   (2) Change Uses faced99, etc. to Uses faced, etc.              [02-03-21]
 *   (3) Remove $IFDEF TURBO Uses and $IFDEF DELPHI                 [02-03-24]
 *   (4) Remove STAT file sections                                  [02-12-17]
 *
 * Version:     20
 * Date:        2003
 * Changes:
 *   (1) 4 changes related to new TLPF class for prop-, windlearn   [03-01-05]
 *   (2) Remove initializations of prop-, windlearn here            [03-01-06]
 *   (3) Replace Uses faced by Globals                              [03-06-08]
 *
 * Version:     21
 * Date:        2006
 * Changes:
 *   (1) Remove Uses tp5utils                                       [06-03-17]
 *   (2) Replace errstring() by SysUtils.SysErrorMessage()          [06-03-17]
 *   (3) emptyerr: SetLastError $20004001                           [06-09-23]
 *}

Implementation

Uses 
  SysUtils,
  FatalErr;

PROCEDURE rewriterr (ior, ring, fileno: INTEGER);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
VAR s: String;
BEGIN
  s := 'I/OResult: ' + IntToStr(ior) +
       '  ' + SysUtils.SysErrorMessage (ior) + nl2;
  IF fileno IN [4..5]  {for PARR*.SET and DISP*.SET}
    THEN BEGIN
      s := s + 'Cannot open ' + filnam[ring,fileno] + nl2;
      s := s + 'Assure that logging path specified in .CFG exists.' + nl2;
      s := s + 'Copy previous .SET files into this directory.';
      END
    ELSE BEGIN
      s := s + 'Cannot open ' + filnam[ring,fileno] + ' for writing!!!';
      END;
  FatalErr.Msg ('comin --> rewriterr', s);
  END;  {of procedure 'rewriterr'}

PROCEDURE emptyerr (ring, fileno: INTEGER);
CONST nl2 = CHR(13) + CHR(10) + CHR(10);
BEGIN
  SetLastError ($20004001);
  FatalErr.Msg ('comin --> emptyerr',
    'Empty settings file: ' + filnam[ring,fileno] + nl2 +
    'Copy last backed up file into data logging directory.');
  END;  {of procedure 'emptyerr'}                 

PROCEDURE fileinit (no: INTEGER);
VAR i: INTEGER;
    errno: INTEGER;
BEGIN
  {$I-}  RESET(logg[no]);  {$I+}
  IF (IOResult=0) 
    THEN recnum[no,1] := FileSize(logg[no])
    ELSE BEGIN
      recnum[no,1] := 0;
      IF NOT archive_mode THEN BEGIN
        {$I-} REWRITE(logg[no]); {$I+}
        errno := IOResult;
        IF errno <> 0 THEN rewriterr (errno, no, 1);
        END;
      END;
  len[no,1] := (recnum[no,1]*SizeOf(logrec)) DIV 1000;

  {$I-}  RESET(varr[no]);  {$I+}
  IF (IOResult=0) 
    THEN recnum[no,3] := FileSize(varr[no])
    ELSE BEGIN
      recnum[no,3] := 0;
      IF NOT archive_mode THEN BEGIN
        {$I-}  REWRITE(varr[no]);  {$I+}
        errno := IOResult;
        IF errno <> 0 THEN rewriterr (errno, no, 3);
        END;
      END;
    len[no,3] := (recnum[no,3]*SizeOf(varrec)) DIV 1000;

  {$I-}  RESET(parr[no]);  {$I+}
  IF (IOResult <> 0) THEN rewriterr (errno, no, 4);
  recnum[no,4] := FileSize(parr[no]);
  IF (recnum[no,4] = 0) THEN emptyerr (no, 4);
  len[no,4] := (recnum[no,4]*SizeOf(parrec)) DIV 1000;

  {$I-}  RESET(disp[no]);  {$I+}
  IF (IOResult <> 0) THEN rewriterr (errno, no, 5);
  recnum[no,5] := FileSize(disp[no]);
  len[no,5] := (recnum[no,5]*SizeOf(displayrecord)) DIV 1000;

  IF NOT archive_mode THEN BEGIN {----- run and simul only -----}

  IF (recnum[no,1])>0
    THEN BEGIN
      Seek(logg[no],recnum[no,1]-1);
      READ(logg[no],loggrecord[no]);
      back1[no]:=loggrecord[no].bback1;
      END 
    ELSE BEGIN
      back1[no]:=0; loggrecord[no].bback1:=0;
      END;
  CloseFile (logg[no]);

  IF recnum[no,3]>0 
    THEN BEGIN
      Seek(varr[no],recnum[no,3]-1);
      READ(varr[no],varrecord[no]);
      back3[no] := varrecord[no].bback3;
      END 
    ELSE BEGIN
      back3[no] := 0;
      varrecord[no].bback3 := 0;
      END;
  CloseFile (varr[no]);

  IF (recnum[no,4])>0 
    THEN BEGIN
      Seek(parr[no],recnum[no,4]-1);
      READ(parr[no],parrecord[no]);
      WITH parrecord[no] DO BEGIN
        ainteg[no]:=aainteg; tsamp[no]:=ttsamp;
        tcont[no]:=ttcont;
        aprop[no]:=aaprop; adiff[no]:=aadiff;
        awind[no]:=aawind; windthr[no]:=wwindthr;
        pidfactormin[no] := ppidfactormin; pidfactormax[no] := ppidfactormax;
        preset[no]:=ppreset;  { if presetting after restarting }
        falarm[no]:=ffalarm;
        calarm[no]:=ccalarm; 
        gcint[no]:=ggcint; wsint[no]:=wwsint; wdint[no]:=wwdint;
        tlearn[no]:=ttlearn; limit[no]:=llimit;
        timestep[1]:=tfil1; timestep[2]:=tfil2; timestep[3]:=tfil3;
        sfil[no,1]:=sfil1; sfil[no,2]:=sfil2;
        sfil[no,3]:=sfil3; sfil[no,4]:=sfil4;
        back4[no]:=bback4;
        enrich_mode[no] := eenrich_mode;
        FOR i := 0 TO 3 DO enrich_val[no][i] := eenrich_val[i];
        enrich_base[no] := eenrich_base;
        onoff_mode [no] := oonoff_mode;
        timeon[no]:=ttimeon; timeoff[no]:=ttimeoff;
        dawn_altitude[no] := ddawn_altitude;
        conditional_enabled[no] := cconditional_enabled;
        conditional_var^[no] := cconditional_var;
        windprop[no]:=wwindprop;
        vvptime[no].period:=rrefreshvvp;
        END;  {with}
      END;
  CloseFile (parr[no]);

  END  {----- above for run and simul modes only -----}

  ELSE FOR i := 1 TO 4 DO  {----- archive mode only -----}
    sfil[no,i] := (recnum[no,i] > 0);    

  IF recnum[no,5]>0  {----- all three modes -----}
    THEN READ (disp[no], disprecord^[no]);
  CloseFile (disp[no]);

  {make display representations of timeon[] and timeoff[]}
  stimeon[no]  := istr(timeon [no] DIV 60,2) + istr(timeon [no] MOD 60,2);
  IF stimeon[no][1]=' ' THEN stimeon[no][1] := '0';
  IF stimeon[no][3]=' ' THEN stimeon[no][3] := '0';
  stimeoff[no] := istr(timeoff[no] DIV 60,2) + istr(timeoff[no] MOD 60,2);
  IF stimeoff[no][1]=' ' THEN stimeoff[no][1] := '0';
  IF stimeoff[no][3]=' ' THEN stimeoff[no][3] := '0';

  {this will force initialization of histograms and resetting of cinteg}
  runsave[no]  := FALSE;
  fumisave[no] := FALSE;

  END;  {of procedure 'fileinit'}

{of unit 'COMIN.PAS'}
END.
