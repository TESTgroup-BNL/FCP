{$R+}    {Range checking on}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N+}    {Numeric coprocessor}
{$H-}    {Turbo-style strings is default}

Unit comlog;

Interface

Uses SysUtils,
     crt32,
     comd, Globals, NetLog, comu, comp;

PROCEDURE datlog (no: INTEGER);

{*
 * Name   :  COMLOGyy.PAS
 *
 * Purpose:  BNL FACE Project
 *           On-line data acquistion, control, and monitoring
 *           Data logging utilities
 *
 * Version:     1
 * Date:        04-04-90
 * Programmer:  Z. Kolber
 * Language:    TurboPascal 5.0
 * Hardware:    Dell 310 20MHz 80386 AT
 * O/S:         MS-DOS 3.3
 * Changes:
 *   (1) As developed to this point by Z. Kolber in COMyy.PAS
 *
 * Version:     2
 * Date:        03-03-92
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Made into separate unit called COMLOGyy.
 *   (2) Streamlined a lot of code.
 *   (3) Broke out some datlog(); code as separate procedures:
 *       (a) sidebar();
 *       (b) asciiout;
 *   (4) Replace Intr($10, function 6 calls by scrollup();
 *   (5) Change clwindow(7,1,25,80) to (7,0,24,79).
 *   (6) Fix doexamine problems (doesn't work on all computers; header not in
 *       color) in asciiout(); by using AssignCrt instead of Assign (f,'CPN');
 *       [05-19-92]
 *   (7) Added procedure checkdev() and used it.  [05-19-92]
 *
 * Version:     3
 * Date:        November/December 1992
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Some nonsubstantive cosmetics -- 11/24/92
 *   (2) Collapse some boolean expressions
 *   (3) Replace lf1,lf2,lf3,lf4 by left in datlog();
 *   (4) Fix doubling of last record bug in datlog();
 *   (5) Rename asciiout() to dataout()
 *   (6) Add local procedure 'slidescreen' to dataout();
 *   (7) Add disk dump option (docreate)
 *
 * Version:     4
 * Date:        January 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Replace IF op OR all by IF (op OR all) AND (recnum[no,i]>0)
 *       in 4 procedure datlog sections to prevent bomb when input file 
 *       is empty (12/28/92).
 *   (2) Declare sfilsave boolean used to restore sfil[no,i] to value it had
 *       before being temporarily set to false (12/30/92). 
 *
 * Version:     5
 * Date:        June/July 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Fix crash due to attempting to write header to asciifile if
 *       in binary mode -- procedure dataout.  (06/17/93).
 *
 * Version:     6
 * Date:        December 1993
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Begin use as COMLOG94.                                    [12/10/93]
 *
 * Version:     7
 * Date:        Feb 1995
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMLOG95.PAS                                      [95/02/21]
 *
 * Version:     8
 * Date:        Oct 1995, Jan 1996
 * Programmer:  J. Nagy
 * Changes:
 *   (1) Becomes COMLOG96.PAS; update Uses.                        [95/10/14]
 *   (2) Vars irec .. recend to unit scope.                        [96/01/05]
 *
 * Version:     9
 * Date:        May-June 1996
 * Changes:
 *   (1) Rename procedure dispback() as miscback().                [96/05/21]
 *   (2) Add backing up of current copy of pv motor param file.    [96/05/21]
 *   (3) Change rlabel() references to rlabel[].                   [96/06/22]
 *
 * Version:     9
 * Date:        Dec 1996
 * Changes:
 *   (1) Becomes COMLOG97.PAS; update Uses.                        [96/12/22]
 *
 * Version:     10
 * Date:        December 1997
 * Changes:
 *   (1) Becomes COMLOG98.PAS; update Uses.                        [97/12/23]
 *   (2) Replace 2 occurences of aagc1hr by aagc5m                 [97/12/29]
 *   (3) Replace 2 occurences of ggcont  by ggcgrab                [97/12/29]
 *
 * Version:     11
 * Date:        Nov-Dec 1998
 * Changes:
 *   (1) checkdev: use new tp5utils/errstring in out messages      [98/11/21]
 *   (2) datlog:   show net LOGGing vars at bottom of screen       [98/11/21]
 *   (3) add tp5utils to Uses                                      [98/11/21]
 *   (4) new procedures logg2net and make_msg                      [98/12/03]
 *
 * Version:     12
 * Date:        1999
 * Changes:
 *   (1) Change occurence of disprecord[] by disprecord^[].        [99/01/28]
 *   (2) Use new field names logging to net.                       [99/01/28]
 *   (3) datlog:  don't stomp on examine output with netlogg info  [99/06/25]
 *   (4) logg2net: many mistakes fixed in status word unpacking    [99/09/03]
 *   (4) make_msg: use helios_decra & _altaz to determine sunalt.  [99/09/13]
 *
 * Version:     13
 * Date:        1999-2000
 * Changes:
 *   (1) Name and uses changed to '99.                             [99/12/13]
 *   (2) Uses IFDEF TURBO or DELPHI.                               [00/01/18]
 *   (3) dataout: IFNDEF TURBO skip AssignCrt; don't know how yet. [00/01/19]
 *   (4) IFDEF DELPHI invokes $H-.                                 [00/01/19]
 *   (5) make_msg/fvw: make argument type Double for 1s resolution [00/01/27]
 *   (6) logg2net: add filling of new fields lasterr and lastdt    [00/03/17]
 *   (7) datlog:   add outputting of these to screen               [00/03/17]
 *   (8) mouse awareness (Win32 only)                              [00/04/26]
 *   (9) space left message uses "greater than" if =7FFFFFFF       [00/04/27]
 *  (10) datlog: IFDEF DELPHI trap attempt to Examine & out msg    [00/09/20]
 *  (11) Uses: add musca to list                                   [00/11/07]
 *
 * Version:     14
 * Date:        2001
 * Changes:
 *   (1) logg2net: replace date by showdate(date) in lastdt        [01/06/07]
 *
 * Version:     15
 * Date:        2002
 * Changes:
 *   (1) Unit renamed comlog                                       [02-03-21]
 *   (2) Uses comd99, etc. changed to comd, etc.                   [02-03-21]
 *   (3) datlog: var 'left' changed from Longint to Int64          [02-09-15]
 *   (4) Remove all STAT file related material                     [02-12-17]
 *
 * Version:     16
 * Date:        2003
 * Changes:
 *   (1) datlog: replace tp5utils.beep(1) by SysUtils.Beep         [03-01-05]
 *   (2) datlog: remove 3x IF left=$7FFFFFFF .. no longer relevant [03-01-27]
 *   (3) Remove uses of dos32                                      [03-01-28]
 *   (4) comd/Globals changes                                      [03-05-28]
 *   (5) network logging material moved to NetLog                  [03-05-31]
 *   (6) Remove uses of musca and all mouse_ references            [03-06-08]
 *   (7) datlog: Move IF dobackup code to new Backup.pas           [03-06-08]
 *   (8) datlog: Move local procedure miscback to Backup.pas       [03-06-08]
 *
 * Version:     17
 * Date:        2006
 * Changes:
 *   (1) Interface Uses: remove tp5utils                           [06-04-29]
 *   (2) checkdev: replace errstring( by SysUtils.SysErrorMessage( [06-04-29]
 *}

Implementation

VAR sfilsave: BOOLEAN;
    irec, recstart, recend: Longint;

{-------------------------------------------------------------}

PROCEDURE sidebar;
CONST c = LightGreen;
      b = Blink;
BEGIN
  xywrite(63,1,c                    ,'<ESC> Return');
  xywrite(63,2,c+ORD(docreate    )*b,'<F6>  Dump to disk');
  xywrite(63,3,c+ORD(doexamine   )*b,'<F7>  Examine');
  xywrite(63,4,c+ORD(doprint     )*b,'<F8>  Print');
  xywrite(63,6,c+ORD(doinitialize)*b,'<F10> Initialize');
  GotoXY (63,7);  ClrEol;
  END;  {of procedure 'sidebar'} 
{-------------------------------------------------------------}

PROCEDURE checkdev (VAR ior: INTEGER; col,row: INTEGER; 
  msg1,device,msg2: String);
{check i/o result and maybe
 display device error message while continuing experiment
 JN 5/19/92}
VAR colorsave: INTEGER;
BEGIN
  ior := IOResult;
  IF ior <> 0 THEN BEGIN
    colorsave := TextAttr;
    GotoXY (col,row);  ClrEol;
    TextColor (LightGray);
    WRITE (msg1);
    TextColor (White);
    WRITE (device);
    TextColor (LightGray);
    WRITE (msg2,'  Run-time error: ', ior:1, ' -- ', SysUtils.SysErrorMessage(ior));
    pauseat (col,row+2);
    TextColor (colorsave);
    END;
  END;  {of procedure 'checkdev'}
{-------------------------------------------------------------}

PROCEDURE dataout;
{ Examine/Print/Diskdump service }
CONST msgcol = 10;
      msgrow = 10;
VAR irow: INTEGER;
    asciifile: TEXT;
    b1file: FILE OF logrec;
    b3file: FILE OF varrec;
    b4file: FILE OF parrec;
    binarymode, header: BOOLEAN;
    device: String;

PROCEDURE slidescreen (lines: INTEGER);
VAR last: INTEGER;
BEGIN
 last := 25+1-lines;
 IF irow < last
   THEN BEGIN
     irow:=irow+lines;
     GotoXY(1,irow);
     END 
   ELSE BEGIN
     scrollup (lines,0,7+lines,25,0,79);
     GotoXY (1,last);
     END;
  END;  {of local procedure 'slidescreen'}

BEGIN
  sidebar;
  binarymode := FALSE;

  IF doprint THEN device := 'PRN';

  IF docreate THEN BEGIN
    GotoXY (msgcol,msgrow+2);  ClrEol;
    WRITE ('Enter file name to be appended to: ');  saccept;
    Delete (svalue, Pos(CHR(13),svalue), 255);
    device := svalue;
    REPEAT
      GotoXY (msgcol,msgrow+3);  
      ClrEol;
      WRITE ('Select (A) ascii, or (B) binary: ');  
      caccept;  
      calr := UpCase(calr);
      binarymode := (calr = 'B');
      UNTIL (calr = 'A') OR (calr = 'B');
    END;

  header := doexamine;
  IF NOT (binarymode OR doexamine) THEN REPEAT
    GotoXY (msgcol,msgrow+3);  
    ClrEol;
    WRITE ('Do you want column headings (y|n)? ');  
    caccept;  
    calr := UpCase(calr);
    header := (calr = 'Y');
    UNTIL (calr = 'Y') OR (calr = 'N');

  GotoXY (msgcol,msgrow);
  WRITE ('Waiting for output device...');
  {$I-}  
  IF doexamine 
    THEN BEGIN
      {Turbo-only code that was here removed}
      END
    ELSE IF binarymode 
      THEN BEGIN
        IF loggop THEN BEGIN Assign (b1file, device);  REWRITE (b1file);  END;
        IF varrop THEN BEGIN Assign (b3file, device);  REWRITE (b3file);  END;
        IF parrop THEN BEGIN Assign (b4file, device);  REWRITE (b4file);  END;
{         RESET (b4file); Seek (b4file,FileSize(b4file));  END; }
        END
      ELSE BEGIN
        Assign (asciifile, device);
        REWRITE (asciifile);  
        WRITELN (asciifile);
        END;
  {$I+}
  clwindow (7,0,24,79);
  checkdev (ior,msgcol,msgrow,'Cannot open device ',device,' for writing.');

  IF (recnum[no,row-2]>0) AND (ior=0) THEN BEGIN
    TextColor(2);
    REPEAT
      xywrite(63,6,12,'From rec# ');  ClrEol;  iaccept(recstart);
      IF recstart <= 0 THEN recstart := 1;
      UNTIL recstart<=recnum[no,row-2];
    REPEAT
      xywrite(63,7,12,'  To rec# ');  ClrEol;  iaccept(recend);
      IF recend <= 0 THEN recend := recnum[no,row-2];
      UNTIL recend<=recnum[no,row-2];
    irec := recstart;
    GotoXY(1,8);

    IF doprint THEN BEGIN
      WRITELN(asciifile, '*** Records ',recstart:8,' to ',recend:8,
                        ' for Array',no:2,' ***');
      WRITELN(asciifile);
      END;

    IF loggop THEN BEGIN
      IF header THEN BEGIN
        TextColor(13);
        WRITELN(asciifile,'Date     Time     Wspeed Wdir Std',
                          ' PVCont PVResp GCgrab  Agc1m  Agc5m',
                          ' GCcntl');
        TextColor(2);
        END;
      irow:=8;
      sfilsave:=sfil[no,1];  sfil[no,1]:=FALSE;  RESET(logg[no]);
      Seek(logg[no],irec-1);
      REPEAT
        tinter;
        READ(logg[no], loggrecord[no]);
        {$I-}
        IF binarymode
          THEN WRITE (b1file, loggrecord[no])
          ELSE WITH loggrecord[no] DO BEGIN
            IF doexamine THEN slidescreen (1); 
            WRITE (asciifile,ddate,' ',ttime,wwspeed:7:2,' ',wwwdir:3,
                    ' ',sstdwdir:4,' ',ppropc:6:1,' ',ppropresp:6:1,
                    ' ',ggcgrab:6:1,' ',aagc1m:6:1,' ',aagc5m:6:1,
                    ' ',ggccntl:6:1);
            IF doprint OR docreate THEN WRITELN (asciifile);
            END;
        {$I+}
        checkdev (ior,msgcol,msgrow,'Error writing device ',device,'.');
        irec := irec+1;
        UNTIL (irec>recend) OR (ior<>0);
      CloseFile (logg[no]);  sfil[no,1]:=sfilsave;
      END

    ELSE IF varrop THEN BEGIN
      IF header THEN BEGIN
        TextColor(13);
        WRITELN(asciifile,'Date     Time        Ainteg    Aprop    Adiff',
                '    Awind    Propc   AvGC1m');
        WRITELN(asciifile,'                     Cinteg    Cprop    Cdiff',
                '    Cwind  Proplrn  Windlrn');
        TextColor(2);
        END;
      irow:=10;
      sfilsave:=sfil[no,3];  sfil[no,3]:=FALSE;  RESET(varr[no]);
      Seek(varr[no],irec-1);
      REPEAT
        tinter;
        READ(varr[no],varrecord[no]);
        {$I-}
        IF binarymode
          THEN WRITE (b3file, varrecord[no])
          ELSE WITH varrecord[no] DO BEGIN
            IF doexamine THEN slidescreen (2);
            WRITELN (asciifile, ddate, '  ', ttime, aainteg_adj:9:3,
              aaprop_adj:9:3, aadiff_adj:9:3, aawind_adj:9:3,
              ppropc:9:3, ggcav:9:3);
            WRITE (asciifile, '                  ', ccinteg:9:3, ccprop:9:3,
              ccdiff:9:3, ccwind:9:3, pproplearn:9:3, wwindlearn:9:3);
            IF doprint OR docreate THEN WRITELN (asciifile);
            END;
        {$I+}
        checkdev (ior,msgcol,msgrow,'Error writing device ',device,'.');
        irec:=irec+1;
        UNTIL irec>recend;
      CloseFile (varr[no]);  sfil[no,3]:=sfilsave;
      END

    ELSE IF parrop THEN BEGIN
      IF header THEN BEGIN
        TextColor(13);
        WRITELN(asciifile,'Date         Time    Tsamp    Tcont  Ainteg',
                '  Aprop   Adiff    Awind   GCpres');
        WRITELN(asciifile,'                     GCint    WSint  WDint',
                '   Tlearn  Conlim   Windthr Alarm');
        TextColor(2);
        END;
      irow:=10;
      sfilsave:=sfil[no,4];  sfil[no,4]:=FALSE;  RESET(parr[no]);
      Seek(parr[no],irec-1);
      REPEAT
        tinter;
        READ(parr[no],parrecord[no]);
        {$I-}
        IF binarymode
          THEN WRITE (b4file, parrecord[no])
          ELSE WITH parrecord[no] DO BEGIN
            IF doexamine THEN slidescreen (2);
            WRITELN(asciifile,ddate,'  ',ttime,ttsamp:8:3,ttcont:8:3,
                  aainteg:8:3,aaprop:8:3,aadiff:8:3,
                  aawind:9:3,ppreset:9:3);
            WRITE(asciifile,'                  ',ggcint:8:3,wwsint:8:3,
                wwdint:8:3,ttlearn:8:1,llimit:8:3,
                wwindthr:9:3,ffalarm:9:3);
            IF doprint OR docreate THEN WRITELN (asciifile);
            END;
        {$I+}
        checkdev (ior,msgcol,msgrow,'Error writing device ',device,'.');
        irec:=irec+1;
        UNTIL irec>recend;
      CloseFile (parr[no]);  sfil[no,4]:=sfilsave;
      END;

    IF binarymode
      THEN BEGIN
        IF loggop THEN CloseFile (b1file);
        IF varrop THEN CloseFile (b3file);
        IF parrop THEN CloseFile (b4file);  
        END
      ELSE CloseFile (asciifile);
    END;
  END;  {of procedure 'dataout'}
{-------------------------------------------------------------}

PROCEDURE datlog (no: INTEGER);
VAR left: Int64;
    lll: Longint;
    ans: String[1];
    action, update, all: BOOLEAN;
    i: INTEGER;
    nostring: String[1];

BEGIN
  ClrScr;
  TextColor(2);
  update:=FALSE;
  nostring := rlabel[no];
  WRITELN('File name    Status  Tstep  RecNo  Length(k)',
          '    Comment     |');
  WRITE(line60,'|');
  len[no,1] := recnum[no,1]*SizeOf(logrec)  DIV 1000;
  len[no,3] := recnum[no,3]*SizeOf(varrec)  DIV 1000;
  len[no,4] := recnum[no,4]*SizeOf(parrec)  DIV 1000;
  len[no,5] := recnum[no,5]*SizeOf(displayrecord) DIV 1000;
  FOR i:= 1 TO 4 DO BEGIN
    xywrite (1,i+2,-1,filnam[no,i]);
    IF sfil[no,i] THEN xywrite (19,i+2,LightGreen,'O') 
                  ELSE xywrite (19,i+2,Red,       'C');
    IF i<4
     THEN WRITE(timestep[i]:4:0)
     ELSE WRITE(' ---');
    WRITE(recnum[no,i]:8,len[no,i]:8);
    GotoXY(41,i+2); WRITELN(comm[no,i],'|');
    END;
  GotoXY(1,7); WRITE(line60,'|');
  col:=1; row:=3; 
  xywrite(col,row,15,filnam[no,row-2]);

  REPEAT
    docreate     := FALSE;
    doexamine    := FALSE;
    doprint      := FALSE;
    doinitialize := FALSE;
    sidebar;
    GotoXY (1,row);
    kbin;
    doexit := (alr=27);
    IF alr=0 THEN BEGIN
      GotoXY(col,row);
      IF col=1 THEN xywrite (1,row,2,filnam[no,row-2]);
      cursor_row (row, 3, 6, ahr);
      IF ahr=77 THEN col:=13;
      IF col=13 THEN BEGIN
        update:=TRUE;
        xywrite (18,row,-1,'< >');
        GotoXY(19,row);
        kbin;
        IF (calr='o') or (calr='O')
          THEN BEGIN
            xywrite (18,row,LightGreen,' O ');
            sfil[no,row-2]:=TRUE;
            END
          ELSE BEGIN
            xywrite (18,row,Red,' C ');
            sfil[no,row-2]:=FALSE;
            END;
        IF (row<>6) and sfil[no,row-2] THEN BEGIN
          xywrite (22,row,-1,'<   >');
          GotoXY(23,row);  raccept(timestep[row-2]);
          GotoXY(20,row);  WRITE(timestep[row-2]:4:0,' ');
          END;
        END;
      col:=1; 
      xywrite (1,row,15,filnam[no,row-2]);
      GotoXY(col,row);

      loggop := (row=3);
      varrop := (row=5);
      parrop := (row=6);

      docreate     := (ahr=64);
      doexamine    := (ahr=65);
      doprint      := (ahr=66);
      doinitialize := (ahr=68);

      {Examine not supported by 32-bit compilation}
      IF doexamine THEN BEGIN
        doexamine := FALSE;
        GotoXY (1,9);
        WRITE   ('Examine is not supported in Windows 32-bit version');
        WRITELN (' of the FACE control program.');
        WRITE   ('(Examine dumps selected variables from a *.DAT file');
        WRITELN (' to the screen.)');
        WRITE   ('Use <F6> Dump to disk instead. Use a file name like');
        WRITELN (' JUNK.TXT.');
        WRITELN ('Select ASCII output with or without a header.');
        WRITELN ('Then view output using any text processor or browser.');
        WRITELN ('Delete JUNK.TXT when you are finished.');
        WRITE   ('If LOGG*.NET files are being written, another method');
        WRITELN (' is to view these files.');
        WRITELN ('LOGG*.NET files contain all LOGG variables but no header.');
        SysUtils.Beep;
        continue;
        GotoXY (1,9);
        FOR i := 1 TO 10 DO BEGIN ClrEol; WRITELN; END;
        END;
      
      IF doexamine OR doprint OR docreate 
        THEN dataout  {>>> examine or print or disk dump <<<}

      ELSE IF doinitialize THEN BEGIN    {>>> initialize <<<}
        sidebar;
        clwindow(7,0,24,79);
        action:=FALSE;
        xywrite (63,7,12,'Are you sure ? ');  caccept;
        IF (calr='y') or (calr='Y') THEN BEGIN
          xywrite (63,7,12,'Files backed ?   ');  caccept;
          IF (calr='y') or (calr='Y') THEN BEGIN
            action:=TRUE;
            REWRITE(logg[no]); recnum[no,1]:=0; len[no,1]:=0; back1[no]:=0;
              loggrecord[no].bback1:=0;
            REWRITE(varr[no]); recnum[no,3]:=0; len[no,3]:=0; back3[no]:=0;
              varrecord[no].bback3:=0;
            xywrite(63,7,12,'Files initialized ');
            FOR i:=1 TO 3 DO BEGIN
              GotoXY(24,2+i); WRITE(recnum[no,1]:8,len[no,i]:8);
              END;
            END;
          END;
        IF NOT action THEN xywrite(63,7,12,'No action taken   ');
      END;

    END;
  UNTIL doexit;
  IF update and sfil[no,4] THEN
  BEGIN
    WITH parrecord[no] DO BEGIN
      tfil1:=timestep[1];  tfil2:=timestep[2];  tfil3:=timestep[3];
      sfil1:=sfil[no,1];   sfil2:=sfil[no,2];
      sfil3:=sfil[no,3];   sfil4:=sfil[no,4];
      bback4:=back4[no];
      END;
    RESET(parr[no]);
    IF FileSize(parr[no])>0 THEN Seek(parr[no],FileSize(parr[no])-1);
    WRITE(parr[no],parrecord[no]);
    CloseFile (parr[no]);
  END;
END; {of procedure 'datlog'}

{---------------------------------------------------------------------}

Initialization

BEGIN
  END;

Finalization

BEGIN
  END;

{of unit COMLOG.PAS...}
END.
