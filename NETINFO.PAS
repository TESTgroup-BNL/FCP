{$L-}
{$R+}    {Range checking on}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N+}    {Numeric coprocessor}
{$E-}    {Do not include emulation code}
{*E+}    {Include emulation code}
{
  Read in sensor data from network files.
  Now also used for writing some sorts of data to network.

  v1.0  99/04/14  Original for ever growing files made by NOAA's SCS
  v1.1  99/05/06  Add netinfo_write procedure
  v1.2  99/05/10  'write_only' record field and check in netinfo_read
  v2.0  00/01/18  IFDEF TURBO (Crt) or DELPHI (crt32, $H-) capability
  v2.1  00/01/25  Add stream: BOOLEAN to netinfo_type record
                  netinfo_alloc: assign stream = FALSE at allocation
                  netinfo_init: add streamset: BOOLEAN to argument list
                  netinfo_init: assign stream = streamset
                  netinfo_init: add block opening file if streaming
                  netinfo_write: open and close file only if not streaming
                  Finalization: section added to close any open stream files
  v2.2  00/01/27  Add suspend: BOOLEAN to netinfo_type record
                  netinfo_show: suspend writing related changes
                  netinfo_write: don't do anything if writing suspended
                  Finalization: section removed.  Apparently closed already.
        00/01/30  netinfo_init: stream filemode 66 (r/w) --> 65 (write only)
        00/01/31  netinfo_init: stream filemode back to 66 (r/w)
                  netinfo_write: filemode_save := FileMode OUTSIDE if stream
        00/02/03  netinfo_write: get IOResult after BlockWrite before Truncate
                  netinfo_eol, _sep: change type from CHAR to String
                  netinfo_init: args eolset, sepset changed to String
                  netinfo_init: local function 'decode_set_string' added
                  PROGRAM part modified for these changes
        00/02/04  netinfo_write: append "eol" to "msg", not <CR><LF>
        00/02/07  netinfo_write: set .reclen = length of last record written
                  Uses: add Dos and dos32 to pick up DiskSize
        00/02/11  netinfo_reduce: new procedure to reduce an output file
        00/02/14  PROGRAM: had forgotten to crt32.init
        00/02/17  netinfo_reduce: change possible, actual vars from Longint
                    to INTEGER for legacy Turbo BlockRead/Write compilation
        00/04/18  netinfo_reduce: change from stack var 'buffer' to
                    heap var 'buffervar' due to overflow under DOS
        00/04/25  netinfo_show: switch + & - in prompt
        00/09/26  Halt; replaced by Halt (3xx);
  v2.3  02/05/14  Halt; replaced by Halt (3xx);
  v3.0  03/01/28  Remove Uses of dos32
                  netinfo_reduce: work: if turbo longint else int64
  v3.1  06/04/29  Implementation Uses: replace tp5utils by comu (2x)

  John Nagy, Brookhaven National Lab, Upton NY 11973 U.S.A. +1-631-344-2667

}

{$IFDEF PROGRAM}
PROGRAM netinfo (INPUT, OUTPUT);
{$IFDEF DELPHI}
{$APPTYPE CONSOLE}
{$ENDIF}
{$ENDIF}

{$IFDEF UNIT}
Unit netinfo;
Interface
{$ENDIF}

{$IFDEF TURBO}
Uses Dos, Crt, comu;
{$ENDIF}

{$IFDEF DELPHI}
{$H-}
Uses SysUtils, crt32, comu;
{$ENDIF}

CONST netinfo_addr_min = 0;  {Range of indices for different files}
      netinfo_addr_max = 9;

      netinfo_errmsg: ARRAY [0..20] OF String[40] = (
      {errcode  message}
          { 0} 'No error',
          { 1} 'File id index out-of-range',
          { 2} 'Failure to allocate memory for records',
          { 3} 'File with this index id not initialized',
          { 4} 'File not found (2)',
          { 5} 'Path not found (3)',
          { 6} 'File access denied (5)',
          { 7} 'Disk read error (100)',
          { 8} 'File not assigned (102)',
          { 9} 'File not open (103)',
          {10} 'Disk is write protected (150)',
          {11} 'Other I/O error',
          {12} 'EOL character not found in file',
          {13} 'Last character is not EOL flag',
          {14} 'Input was not updated',
          {15} 'Field (channel) out-of-range',
          {16} 'Field is empty',
          {17} 'Field decoding error',
          {18} 'Netinfo write only', 
          {19} 'Drive number is invalid',
          {20} '');

      nchmax          = 15;  {range is 0..nchmax}

TYPE  netinfo_type = RECORD
                       filename:      String;
                       eol,                        {end of line flag}
                       sep:           CHAR;        {field separator}
                       init,
                       read_yet,
                       write_only,
                       stream,
                       suspend:       BOOLEAN;
                       reclen:        INTEGER;
                       size,
                       recno:         Longint;
                       last_input:    String[80];
                       last_ioresult,
                       last_errno:    INTEGER;
                       value:         ARRAY [0..nchmax] OF REAL;
                       END;

      netinfo_ptrray =
        ARRAY [netinfo_addr_min..netinfo_addr_max] OF netinfo_type;

VAR   netinfo_ptr: ^netinfo_ptrray;
      fnetinfo: ARRAY [netinfo_addr_min..netinfo_addr_max] OF FILE;
      netinfo_installed,
      netinfo_debug: BOOLEAN;
      netinfo_filename: String;  {scratch only; do an _init}
      netinfo_eol,
      netinfo_sep: String;  {Note: will be converted to a char in _init}
      netinfo_writeonly,
      netinfo_stream: BOOLEAN;

{$IFDEF PROGRAM}
VAR sep,
    eol: String;
    filename: String;
    i, j, code,
    id,
    channel,
    period,
    errcode: INTEGER;
    value: REAL;
{$ENDIF}

{$IFDEF UNIT}

PROCEDURE netinfo_check   (errcode: INTEGER; haltit: BOOLEAN);
PROCEDURE netinfo_alloc   (VAR errcode: INTEGER);
PROCEDURE netinfo_init    (id: INTEGER; fname: String; eolset, sepset: String;
                           writeonlyset, streamset: BOOLEAN; 
                           VAR errcode: INTEGER);
PROCEDURE netinfo_read    (id: INTEGER; VAR errcode: INTEGER);
PROCEDURE netinfo_write   (id: INTEGER; msg: String; addto: BOOLEAN;
                           VAR errcode: INTEGER);
PROCEDURE netinfo_reduce  (id, percent: INTEGER; triggersize: Longint;
                           VAR errcode: INTEGER);
PROCEDURE netinfo_clear   (id: INTEGER);
PROCEDURE netinfo_show    (id: INTEGER);
FUNCTION netinfo_getvalue (id, channel: INTEGER; VAR errcode: INTEGER): REAL;

Implementation

{$ENDIF}

VAR errno: INTEGER;

FUNCTION set_ioerr (errno: INTEGER): INTEGER;
VAR temp: INTEGER;
BEGIN
  CASE errno OF
      0: temp :=  0;
      2: temp :=  4;
      3: temp :=  5;
      5: temp :=  6;
    100: temp :=  7;
    102: temp :=  8;
    103: temp :=  9;
    150: temp := 10;
    Else temp := 11;
    END;  {case}
  set_ioerr := temp;
  END;  {of function 'set_ioerr'}

PROCEDURE netinfo_check (errcode: INTEGER; haltit: BOOLEAN);
BEGIN
  IF errcode <> 0 THEN BEGIN
    WRITELN ('NETINFO_CHECK: ', errcode:1, '  ', netinfo_errmsg[errcode]);
    IF haltit THEN Halt (301);
    END;
  END;  {of procedure 'netinfo_check'}

PROCEDURE netinfo_alloc (VAR errcode: INTEGER);
{Allocates memory for netinfo record array}
VAR i,j: INTEGER;
BEGIN
  errcode := 0;
  NEW (netinfo_ptr);
  IF (netinfo_ptr = NIL) THEN errcode := 2;
  IF netinfo_debug THEN
    WRITELN ('NETINFO_ALLOC: ', errcode:1, ' ', netinfo_errmsg[errcode]);
  IF (errcode = 0) THEN BEGIN
    netinfo_installed := TRUE;
    FOR i := netinfo_addr_min TO netinfo_addr_max DO
      WITH netinfo_ptr^[i] DO BEGIN
        filename      := 'NONE';
        eol           := CHR(0);
        sep           := CHR(0);
        init          := FALSE;
        read_yet      := FALSE;
        write_only    := FALSE;
        stream        := FALSE;
        suspend       := FALSE;
        reclen        := -1;
        size          := -1;
        recno         := -1;
        last_input    := 'NEVER';
        last_ioresult := 0;
        last_errno    := 0;
        FOR j := 0 TO nchmax DO value[j] := -999.0;
        END;  {fill fields of new record}
    END;
  END;  {of procedure 'netinfo_alloc'}

PROCEDURE netinfo_init    (id: INTEGER; fname: String; eolset, sepset: String;
                           writeonlyset, streamset: BOOLEAN;
                           VAR errcode: INTEGER);
VAR filemode_save: Byte;

FUNCTION decode_set_string (argument: String): CHAR;
VAR i, code: INTEGER;
    temp: CHAR;
BEGIN
  code := 0;
  temp := CHR(32);
  IF      argument = ''   THEN temp := CHR(32)  {space is default}
  ELSE IF argument = 'CR' THEN temp := CHR(13)
  ELSE IF argument = 'LF' THEN temp := CHR(10)
  ELSE IF argument = 'SP' THEN temp := CHR(32)
  ELSE BEGIN {to try to decode an ordinal in range [0..255]}
    Val (argument, i, code);
    IF code = 0 THEN temp := CHR(i MOD 256);
    END;
  IF code <> 0 THEN temp := argument[1];
  decode_set_string := temp;
  END;  {of local function 'decode_set_string'}

BEGIN {body of 'netinfo_init'}
  filemode_save := FileMode;
  WITH netinfo_ptr^[id] DO BEGIN
    {$I-}
    Assign (fnetinfo[id], fname);
    {$I+}
    errno := IOResult;
    IF errno = 0
      THEN BEGIN
        eol        := decode_set_string(UpperCase(eolset));
        sep        := decode_set_string(UpperCase(sepset));
        filename   := fname;
        init       := TRUE;
        write_only := writeonlyset;
        stream     := streamset;
        END
      ELSE errcode := set_ioerr (errno);
    IF errno = 0 THEN IF stream THEN BEGIN
      {$I-}
      FileMode := 66;  {share = all + access = read/write}
      RESET (fnetinfo[id], 1);
      errno := IOResult;
      IF errno = 2 THEN BEGIN
        REWRITE (fnetinfo[id], 1);
        errno := IOResult;
        END;
      {$I+}
      END;
    last_ioresult := errno;
    last_errno    := errcode;
    END;
  FileMode := filemode_save;
  IF netinfo_debug THEN
    WRITELN ('NETINFO_INIT: id=', id:1, errcode:3, ' ', netinfo_errmsg[errcode]);
  END;  {of procedure 'netinfo_init'}

PROCEDURE netinfo_read (id: INTEGER; VAR errcode: INTEGER);
CONST max = 255;  {maximum line length including control characters}
VAR filemode_save: Byte;
    i, j,
    errno,
    lresult: INTEGER;
    k: ARRAY [1..2] OF INTEGER;
    index: Longint;
    cinput: ARRAY[1..max] OF CHAR;
    buffer: String[80];
BEGIN
  errcode := 0;
  errno := 0;
  WITH netinfo_ptr^[id] DO BEGIN
    IF NOT init THEN
      errcode := 3  {file id has not been initialized}
      ELSE BEGIN
        IF write_only THEN errcode := 18;
        IF errcode = 0 THEN BEGIN
          filemode_save := FileMode;
          FileMode := 64;
          {$I-}
          RESET (fnetinfo[id], 1);
          errno := IOResult;
          errcode := set_ioerr (errno);
          IF errcode = 0 THEN BEGIN
            size := FileSize (fnetinfo[id]);
            index := size - max;
            IF index < 0 THEN index := 0;
            Seek (fnetinfo[id], index);
            BlockRead (fnetinfo[id], cinput, max, lresult);
            errno := IOResult;
            errcode := set_ioerr (errno);
            IF errcode = 0 THEN BEGIN
              i := 1;
              k[2] := -1;
              FOR j := 1 TO ORD(index<>0)+1 DO BEGIN
                k[j] := 0;
                WHILE (i <= lresult) AND (k[j] = 0) DO BEGIN
                  IF cinput[i] = eol THEN k[j] := i;
                  INC (i);
                  END;
                END;
              IF k[2] < 0 THEN reclen := k[1]
                          ELSE reclen := k[2] - k[1];
              IF reclen <= 0 THEN errcode := 12;
              IF errcode = 0 THEN BEGIN
                recno := size DIV reclen;
                index := size - reclen;
                Seek (fnetinfo[id], index); 
                BlockRead (fnetinfo[id], cinput, reclen, lresult);
                errno := IOResult;
                errcode := set_ioerr (errno);
                IF errcode = 0 THEN BEGIN
                  buffer := '';
                  FOR i := 1 TO  reclen DO buffer := buffer + cinput[i];
                  IF buffer[Length(buffer)] <> eol THEN errcode := 13;
                  FOR i := 1 TO Length(buffer) DO BEGIN
                    IF (buffer[i] = eol)            THEN buffer[i] := '^';
                    IF (ORD(buffer[i]) IN [00..31]) THEN buffer[i] := '!';
                    END;
                  IF buffer = last_input THEN errcode := 14;
                  last_input := buffer;
                  read_yet := TRUE;
                  END;
                END;  {found eol}
              END;  {seek and block read ok}
            END;  {file is open}
          CloseFile (fnetinfo[id]);
          i := IOResult;
          {$I+}
          FileMode := filemode_save;
          END;  {not netinfo write only}
        END;  {id is initialized}
    last_ioresult := errno;
    last_errno    := errcode;
    IF netinfo_debug THEN BEGIN
       WRITELN ('NETINFO_READ: id=', id:1, 
         errcode:3, ' ', netinfo_errmsg[errcode]);
       WRITELN (last_input);
       END;
    END;
  END;  {procedure 'netinfo_read'}

PROCEDURE netinfo_write (id: INTEGER; msg: String; addto: BOOLEAN;
                         VAR errcode: INTEGER);
{Open the file pointed to by 'id' and either append to ('addto' TRUE)
 or not ('addto' FALSE) the line 'msg' + eol.  File already open at
 init time if the stream is TRUE.
 }
VAR filemode_save: Byte;
    buffer: String;
    i: INTEGER;
BEGIN
  errcode := 0;
  errno := 0;
  filemode_save := FileMode;
  WITH netinfo_ptr^[id] DO BEGIN
    IF NOT init THEN
      errcode := 3  {file id has not been initialized}
      ELSE BEGIN
        {$I-}
        IF NOT stream THEN BEGIN  {otherwise file is already open}
          FileMode := 65;
          RESET (fnetinfo[id], 1);
          errno := IOResult;
          IF errno = 2 THEN BEGIN
            REWRITE (fnetinfo[id], 1);
            errno := IOResult;
            END;
          END;
        IF errno = 0 THEN BEGIN
          IF addto THEN Seek (fnetinfo[id], FileSize(fnetinfo[id]))
                   ELSE Seek (fnetinfo[id], 0);
          errno := IOResult;
          END;
        errcode := set_ioerr (errno);
        END;
    buffer := msg;
    {append eol to msg; append <CR><LF> if eol=LF}
    IF ORD(eol) = 10 THEN 
    buffer := buffer + CHR(13);
    buffer := buffer + eol;
    reclen := Length(buffer);
    IF (errcode = 0) AND NOT suspend THEN BEGIN
      BlockWrite (fnetinfo[id], buffer[1], Length(buffer));
      errno := IOResult;
      IF errno = 0 THEN BEGIN
        Truncate (fnetinfo[id]);
        errno := IOResult;
        END;
      END;
    errcode := set_ioerr (errno);
    last_ioresult := errno;
    last_errno    := errcode;
    IF NOT stream THEN BEGIN
      CloseFile (fnetinfo[id]);
      i := IOResult;
      END;
    {$I+}
    FileMode := filemode_save;
    IF netinfo_debug AND NOT suspend THEN BEGIN
       WRITELN (msg);
       WRITELN ('NETINFO_WRITE: id=', id:1, '  append=', addto:1,
         errcode:3, ' ', netinfo_errmsg[errcode]);
       END;
    END;  {with}
  END;  {procedure 'netinfo_write'}

PROCEDURE netinfo_reduce (id, percent: INTEGER; triggersize: Longint;
                          VAR errcode: INTEGER);
{Reduce the size of a fixed record length ASCII file to about "percent"
 percent of its original size.  About (100-percent) of the oldest
 records are removed.
 id:          netinfo file id number [netinfo_addr_min..netinfo_addr_max]
 percent:     percentage of original size to reduce it to
 triggersize: the file will be reduced if the current size exceeds this
              value;  if triggersize < 0, then maxfrac% of disk size is used.
 }
CONST maxfrac =      95;
      buffersize =   65000;
TYPE  buffertype =   ARRAY [1..buffersize] OF Byte;
VAR   filemode_save: Byte;
      buffervar:     ^buffertype;
      reduceit,
      finished:      BOOLEAN;
      drive:         Byte;
      possible,
      actual:        INTEGER;
      rpoint,
      wpoint:        Longint;
{$IFDEF TURBO}
VAR work: Longint;
{$ELSE}
VAR work: Int64;
{$ENDIF}
BEGIN
  errcode := 0;
  errno := 0;
  reduceit := FALSE;
  filemode_save := FileMode;
  WITH netinfo_ptr^[id] DO BEGIN
    IF NOT init THEN
      errcode := 3  {file id has not been initialized}
      ELSE BEGIN
        {$I-}

        {Get disk size, if necessary.  Assumes drive mapping.}
        IF triggersize < 0 THEN BEGIN
          IF (filename[2] <> ':')
            THEN drive := 0
            ELSE drive := ORD(UpCase(filename[1])) - ORD('A') + 1;
          work := DiskSize(drive);
          IF work <= 0 THEN errcode := 19;
          work := work DIV 100;
          work := maxfrac * work;
          triggersize := work;
          END;

        {Determine if file should be reduced in size.}
        IF (errcode = 0) THEN BEGIN
          work := FileSize(fnetinfo[id]);
          errno := IOResult;
          IF (errno <> 0) THEN BEGIN  {file probably not open}
            FileMode := 0;
            RESET (fnetinfo[id], 1);
            work := FileSize(fnetinfo[id]);
            errno := IOResult;
            CloseFile (fnetinfo[id]);
            END;
          IF (errno = 0) THEN reduceit := (work >= triggersize);
          END;

        {Reduce the file size.}
        IF reduceit THEN BEGIN
          NEW (buffervar);
          CloseFile (fnetinfo[id]);  {possibly redundant}
          errno := IOResult;
          FileMode := 2;         {read/write, no sharing}
          RESET (fnetinfo[id], reclen);
          possible := buffersize DIV reclen;
          rpoint := (percent * ((work DIV reclen) DIV 100));
          wpoint := 0;
          finished := FALSE;
          WHILE (errno = 0) AND NOT finished DO BEGIN
            Seek (fnetinfo[id], rpoint);
            BlockRead (fnetinfo[id], buffervar^[1], possible, actual);
            finished := EOF(fnetinfo[id]);
            Seek (fnetinfo[id], wpoint);
            BlockWrite (fnetinfo[id], buffervar^[1], actual);
            rpoint := rpoint + actual;
            wpoint := wpoint + actual;
            END;
          Truncate (fnetinfo[id]);
          CloseFile (fnetinfo[id]);
          IF stream THEN BEGIN  {reopen if this is a stream file}
            FileMode := 66;
            RESET (fnetinfo[id], 1);
            END;
          errno := IOResult;
          DISPOSE (buffervar);
          END; {of file size reduction}
        END; {has been initialized}
    errcode := set_ioerr (errno);
    last_ioresult := errno;
    last_errno    := errcode;
    {$I+}
    FileMode := filemode_save;
    IF netinfo_debug THEN BEGIN
       WRITELN ('NETINFO_REDUCE: id=', id:1, '  ', work:1, ' ', reduceit:1,
         errcode:3, ' ', netinfo_errmsg[errcode]);
       END;
    END;  {with}
  END;  {procedure 'netinfo_reduce'}

PROCEDURE netinfo_show  (id: INTEGER);
{Displays status and contents of netinfo records.}
VAR i, j: INTEGER;
BEGIN
  IF (id >= netinfo_addr_min) AND (id <= netinfo_addr_max) THEN BEGIN
    ClrScr;
    WRITELN ('CONTENTS OF SELECTED NETINFO RECORD');
    WITH netinfo_ptr^[id] DO BEGIN
      WRITELN ('ID NUMBER:    ', id:8);
      WRITELN ('FILENAME:     ', filename);
      WRITELN ('ORD(EOL):     ', ORD(eol):8);
      WRITELN ('ORD(SEP):     ', ORD(sep):8);
      WRITELN ('INIT:         ', init:8);
      WRITELN ('READ YET:     ', read_yet:8);
      WRITE   ('WRITE ONLY:   ', write_only:8);
      WRITE   (' ':5);
      WRITE   ('STREAM:       ', stream:8);
      WRITE   (' ':5);
      WRITELN ('SUSPEND:      ', suspend);
      WRITELN ('FILE SIZE:    ', size:8);
      WRITELN ('RECORD LENGTH:', reclen:8);
      WRITELN ('NUMBER OF REC:', recno:8);
      WRITELN ('LAST INPUT:   ', '\', last_input, '\');
      WRITELN ('LAST IORESULT:', last_ioresult:8);
      WRITELN ('LAST ERRNO:   ', last_errno:8,'  ',netinfo_errmsg[last_errno]);
      j := nchmax DIV 2;
      FOR i := 0 TO j DO BEGIN
        WRITE   ('[', i    :2, ']', value[i    ]:20:6, ' ':8);
        WRITELN ('[', i+j+1:2, ']', value[i+j+1]:20:6);
        END;
      WRITELN ('<-+> Change displayed file id  <ESC> Quit  ');
      WRITE   ('<D> Toggle debug output        <S> Toggle writing to file');
      END;
    END;
  END;  {procedure 'netinfo_show'}

PROCEDURE netinfo_clear (id: INTEGER);
{Set one selected or all (id < 0) read_yet to FALSE}
VAR i, mn, mx: INTEGER;
BEGIN
  IF id < 0
    THEN BEGIN mn := netinfo_addr_min;  mx := netinfo_addr_max;  END
    ELSE BEGIN mn := id;                mx := id;                END;
  IF (netinfo_ptr <> NIL) THEN
    FOR i := mn TO mx DO netinfo_ptr^[i].read_yet := FALSE;
  END;  {of procedure 'netinfo_clear'}

FUNCTION netinfo_getvalue (id, channel: INTEGER; VAR errcode: INTEGER): REAL;
{Get a value that has been read in}
VAR tid, i, code: INTEGER;
    field: String;
    temp: REAL;
BEGIN
  temp := -888.0;
  errcode := 0;
  tid := id MOD 10;
  IF (tid < netinfo_addr_min) OR (tid > netinfo_addr_max) THEN errcode := 1;
  IF errcode=0 THEN WITH netinfo_ptr^[tid] DO IF last_errno=0 THEN BEGIN
    temp := -777.0;
    IF NOT (channel IN [0..nchmax]) THEN errcode := 15;
    IF (errcode = 0) THEN BEGIN
      temp := -666.0;
      field := getfield (last_input, sep, channel+1);
      IF field = '' THEN errcode := 16;
      IF (errcode = 0) THEN BEGIN
        temp := -555.0;
        FOR i := 1 TO Length(field) DO
          IF (field[i] = '!') OR (field[i] = '^') THEN field[i] := ' ';
        WHILE field[Length(field)] = ' ' DO Delete (field, Length(field), 1);
        Val (field, temp, code);
        IF code <> 0 THEN BEGIN
          temp := -444.0;
          errcode := 17;
          END;
        END;
      END;  {error check}
    IF last_errno = 0 THEN last_errno := errcode;
    value[channel] := temp;
    IF netinfo_debug THEN BEGIN
      WRITELN ('NETINFO_GET:  id=', id:1,
        last_errno:3, ' ', netinfo_errmsg[last_errno]);
      WRITELN ('channel=', channel:1, '  value=', value[channel]:20:6);
      END;
    END   {id in range and no previous error}
    ELSE IF netinfo_debug THEN BEGIN
      WRITE ('NETINFO_GET:  id=', id:1);
      IF errcode = 1
        THEN
          WRITELN (errcode:3, ' ', netinfo_errmsg[errcode])
        ELSE
          WRITELN (last_errno:3, ' ', netinfo_errmsg[last_errno]);
      END;
  netinfo_getvalue := temp;
  END;  {of function 'netinfo_getvalue'}

VAR i: INTEGER;

{initialization/finalization of unit}
{$IFDEF UNIT}

{$IFDEF TURBO}
BEGIN
{$ENDIF}

{$IFDEF DELPHI}
Initialization
{$ENDIF}

netinfo_installed := FALSE;
netinfo_debug     := FALSE;

{$IFDEF DELPHIbutskip}
Finalization
IF netinfo_installed AND (netinfo_ptr <> NIL) THEN
  FOR i := netinfo_addr_min TO netinfo_addr_max DO
    WITH netinfo_ptr^[i] DO
      IF (init AND stream) THEN BEGIN
        {$I-}
        CloseFile (fnetinfo[i]);
        {$I+}
        netinfo_check (set_ioerr(IOResult), FALSE);
        END;
{$ENDIF}

{$ENDIF}

{test program}
{$IFDEF PROGRAM}
  {Setup}
BEGIN
  {$IFDEF DELPHI}
  crt32.init;
  {$ENDIF}
  WRITELN;
  WRITELN ('Test reading last line of ascii file from SCS.');
  WRITELN ('Usage: netinfo file id channel sep eol period(seconds)');
  WRITELN ('Hit <ESC> to exit program');
  i := 1;  {1st argument}
  WRITE ('[', i:1, '] "', ParamStr(i),'"  ');
  IF ParamStr(i) = '' THEN Halt (311);
  filename := ParamStr(i);
  WRITELN (filename);
  i := 2;  {2nd argument}
  WRITE ('[', i:2, '] "', ParamStr(i),'"  ');
  IF ParamStr(i) = '' THEN Halt (312);
  Val (ParamStr(i), id, code);
  WRITELN (id:1, '  code=', code:1);
  i := 3;  {3rd argument}
  WRITE ('[', i:2, '] "', ParamStr(i),'"  ');
  IF ParamStr(i) = '' THEN Halt (313);
  Val (ParamStr(i), channel, code);
  WRITELN (channel:1, '  code=', code:1);
  i := 4;  {4th argument}
  WRITE ('[', i:2, '] "', ParamStr(i),'"  ');
  IF ParamStr(i) = '' THEN Halt (314);
  sep := ParamStr(i);
  i := 5;  {5th argument}
  WRITE ('[', i:2, '] "', ParamStr(i),'"  ');
  IF ParamStr(i) = '' THEN Halt (315);
  eol := ParamStr(i);
  i := 6;  {6th argument}
  WRITE ('[', i:2, '] "', ParamStr(i),'"  ');
  IF ParamStr(i) = '' THEN Halt (316);
  Val (ParamStr(i), period, code);
  WRITELN (period:1, '  code=', code:1);
  netinfo_alloc (errcode);
  IF errcode <> 0 THEN BEGIN
    WRITELN (errcode:1, '  ', netinfo_errmsg[errcode]);
    Halt (317);
    END;
  netinfo_init (id, filename, eol, sep, FALSE, FALSE, errcode);
  IF errcode <> 0 THEN BEGIN
    WRITELN (errcode:1, '  ', netinfo_errmsg[errcode]);
    Halt (318);
    END;
  {loop}
  REPEAT
    FOR i := 1 TO period DO BEGIN
      Delay (1000);
      IF KeyPressed THEN BEGIN sep := ReadKey; Halt (319); END;
      END;
    netinfo_read (id, errcode);
    value := netinfo_getvalue (id, channel, errcode);
    netinfo_show (id);
    netinfo_clear (id);
    UNTIL FALSE;
{$ENDIF}
{of program/unit 'netinfo'...}
  END.
