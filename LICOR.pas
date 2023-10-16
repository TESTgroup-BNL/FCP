Unit licor;
{$L-}
{$R+}    {Range checking on}
{$B+}    {Boolean complete evaluation on}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N+}    {Numeric coprocessor}
{$E-}    {Do not include emulation code}
{*E+}    {Include emulation code}
{$H-}    {Old Turbo-style strings are default}
{
  Read in data from a LiCor IRGA using its RS232 communications port.

  v1.0  97/05/08  Original for LICOR 6252/62 through serial BIOS or duTec
  v1.1  97/07/10  Replace '\13' by correct '\' = CR+LF for cr when using
                  duTec.  Just a '/13' did not seem to be enough.
  v1.2  98/02/09  Increase number of possible units to 13.
                  For up to six rings, this will allow 6 treatment IRGA's,
                  six control ring IRGA's, and an ambient multiport.
  v1.3  98/04/19  Change from Uses ser95 to ser98.
  v1.4  98/05/02  Add 'auto_print' to licor record.
                  Initialize licor with variable auto_print rather than 0.
                  Don't issue remote print command if auto_print > 0.0.
  v1.5  98/05/03  Define global 'licor6262_toggle' BOOLEAN.
  v1.6  98/07/01  TEMP-TN patches.
  v1.7  98/07/03  a) declare 'read_yet' in type licor6262_type.
                  b) initialize 'read_yet' to FALSE.
                  c) reenable optomux_debug output of error code and msg.
                  d) add list of error messages.
                  e) remove licor6262_toggle.
                  f) declare count_rest & count current initialize to 0.
                  g) new procedure licor6262_input.
                  h) implement "read_yet" and "count_rest" features.
                  i) previous errcode returned if a read is skipped.
                  j) new procedure licor6262_clear (sets read_yet = FALSE).
  v1.8  98/07/25  licor6262_input(): fix already_read & address logic bug
  v1.9            --was none--
  v2.0  98/09/12  a) Delete CONST licor6262_idmax.
                  b) Add CONST licor6262_addr_min = $00.
                  c) Add CONST licor6262_addr_max = $FF.
                  d) Change licor6262_type to just one record, not an array.
                  e) Change licor6262_ptr to a pointer to a
                     static array of _type pointers.
                  f) An intermediate type licor6262_ptrray was required.
                  g) INIT: allocate licor6262_ptr & set all ^[] := NIL.
                  h) licor6262_alloc(): new procedure (includes old INIT).
                  i) licor6262_clear(): modified for id range, etc.
                  j) licor6262_parse(): remove special TN code.
                  k) all procedures: modify for new data structure.
                  l) licor6262_input(): vars j, already_read not needed.
        98/09/13  m) Add PROCEDURE licor6262_show (addr).
                  n) Add Uses Crt; for the ClrScr call.
        98/09/24  o) licor6262_init(): add errcode_save := err;
                  p) noinit renamed licor6262_noinit and put in Interface.
        98/09/25  q) licor6262_clear(): NIL protection added.
        98/09/27  r) Add PROCEDURE licor6262_addcode (addr, code, err).
                  s) Add FUNCTION licor6262_getvalue (addr, code, err).
        98/09/29  t) Add CONST valid_codes=[ .. ].
        99/09/10  u) licor6262_clear(): should be id < 0, not = 0.
        00/01/18  v) Delphi 4 capability (crt32 and $H-)
  v2.1  00/06/15  a) Limit valid address range to 00 - 1F (duTec masters)
                  b) Hardcoded this range in error message <--
                  c) Array of pointers still 0..255 initialized to NIL 
                  d) After allocating record, set error to "not init" 
                  e) licor6262_init: abandon serial attempts at first error
  v3.0  02/03/22  a) Uses ser instead of ser98
                  b) Remove $IFDEF TURBO code and $IFDEF DELPHI
  v3.1  02/12/06  a) [Some change not detailed in notebook or recorded here]
  v4.0  04/08/01  a) Change all licor6262_* identifiers to licor_*
                  b) Recognize new "channel" 22 for LiCor 820/840 IRGA's
                  c) licor_type: add model: Word (set to 21 or 22)
                  d) licor_model_set: new; includes new error #10
        04/08/04  e) init_DS_6262, init_DS_840: new, called by licor_init
                  f) count_rest now set to 50 or 0 (off) in _6262 or _840
                  g) licor_init, licor_read: modified for 62xx vs 8xx use
        04/08/05  h) xml2dutec: new for LI820/LI840 use
        04/08/25  i) xml2dutec, licor_read: P cmd OK; PP not needed; see NB
        04/12/03  j) supress program init of li820/840 for now -- do otherwise
        04/12/04  k) Add Windows to Uses list to pick up Sleep(ms)
                     licor_read: IF model 22, Sleep(100) between 'O' and 'P'
                     licor_read: do a 'PP' loop for trash removal
                     reinstate program init of li820/840
                     licor_init: power_up_clear of master address
  v5.0  05/01/06  a) licor_read: trash removal only if LI8xx
                  b) use code 22 for LI820 and code 24 for LI840
                  c) xml2dutec: handle both 820 and 840 root nodes now
                  d) init_DS_840: handle LI840 water vapor as well
  v5.1  05/10/07  e) init_DS_840: add <RAW>FALSE<RAW>
                  f) add 99 to valid_codes set (a dummy needed for LI840)

  v6.0  09/08/10  a) Delete serial bios support
                  b) Error returns now of form -9990+errcode

  v7.0  13/12/17  a) init_DS_840: nchcodes := 4 if LI820, := 5 if LI840
  v7.1  13/12/19  a) init_DS_840: comment out configuration commands to IRGA
                     Configuration must be done offline by LI840Cfg
                     Done to reduce comm traffic under error conditions and
                     doesn't seem to work completely anyway

  John Nagy, Brookhaven National Lab, Upton NY 11973 U.S.A.

}

Interface

Uses Windows, crt32, optomux;

CONST licor_addr_min = $00;  {Address address range 0}
      licor_addr_max = $1F;  {reasonable for duTec master addresses}

      licor_noinit = '??';

      licor_errmsg: ARRAY [0..12] OF String[48] = (
      {errcode  message}
          { 0} 'No error',
          { 1} 'Address is out-of-range 0 to 31 (0x00 - 0x1F)',
          { 2} 'Failure to allocate memory for record',
          { 3} 'Record with this address not allocated',
          { 4} 'Requested LiCor variable code not valid',
          { 5} 'Number of codes requested exceeds max',
          { 6} 'Unit with this address not initialized',
          { 7} 'Unrecognized DAQC type',
          { 8} 'Illegal character in LiCor returned string',
          { 9} 'Insufficient number of returned values',
          {10} 'This LiCor ID already allocated to another model',
          {11} 'Serial BIOS error',
          {12} 'Optomux error');

      nchmax          = 5;

      valid_codes     = [21..27, 29, 31..39, 41..47, 49, 99];

TYPE  licor_type = RECORD
                     daqc:          String[8];
                     port,
                     address,
                     model,         {21->6252/6262 22->820 24->840}
                     speed:         Word;
                     auto_print:    REAL;
                     read_yet:      BOOLEAN;
                     nchcodes:      Byte;
                     chcode:        ARRAY [1..nchmax] OF Byte;
                     value:         ARRAY [1..nchmax] OF REAL;
                     count_rest,
                     count_current: INTEGER;
                     errcode_save:  INTEGER;
                     END;

      licor_ptrray =
        ARRAY [0..255] OF ^licor_type;

VAR   licor_ptr: ^licor_ptrray;

PROCEDURE licor_init      (id: INTEGER; VAR errcode: INTEGER);
PROCEDURE licor_read      (id: INTEGER; VAR errcode: INTEGER);
PROCEDURE licor_input     (id: INTEGER; VAR errcode: INTEGER);
PROCEDURE licor_alloc     (id: INTEGER; VAR errcode: INTEGER);
PROCEDURE licor_addcode   (id, code: INTEGER; VAR errcode: INTEGER);
PROCEDURE licor_model_set (id, channel: INTEGER; VAR errcode: INTEGER);
PROCEDURE licor_clear     (id: INTEGER);
PROCEDURE licor_show      (id: INTEGER);
FUNCTION  licor_getvalue  (id, code: INTEGER; VAR errcode: INTEGER): REAL;

Implementation

VAR err: BOOLEAN;
    msg: String;

PROCEDURE licor_alloc (id: INTEGER; VAR errcode: INTEGER);
{Allocates memory for record with address = id}
BEGIN
  errcode := 0;
  IF (id < licor_addr_min) OR (id > licor_addr_max)
    THEN errcode := 1;
  IF (errcode = 0) THEN BEGIN
    IF (licor_ptr^[id] = NIL) THEN BEGIN
      NEW (licor_ptr^[id]);
      IF (licor_ptr^[id] = NIL) THEN errcode := 2;
      IF (errcode = 0) THEN WITH licor_ptr^[id]^ DO BEGIN
        daqc          := licor_noinit;
        port          := 0;
        address       := id;
        speed         := 0;
        model         := 0;
        auto_print    := 0.0;
        read_yet      := FALSE;
        nchcodes      := 0;
        count_rest    := 0;
        count_current := 0;
        errcode_save  := 6;
        END;  {fill fields of new record}
      END;  {allocating new (previously undefined) record}
    END;  {record allocation request with address valid}
  END;  {of procedure 'licor_alloc'}

PROCEDURE licor_addcode (id, code: INTEGER; VAR errcode: INTEGER);
{Adds LiCor variable code to list in record}
VAR i: INTEGER;
    have: BOOLEAN;
BEGIN
  errcode := 0;
  IF (id < licor_addr_min) OR (id > licor_addr_max) THEN errcode := 1;
  IF (errcode = 0) THEN BEGIN
    IF (licor_ptr^[id] = NIL) THEN errcode := 3;
    IF (errcode = 0) THEN BEGIN
      IF NOT (Lo(code) IN valid_codes) THEN errcode := 4;
      IF (errcode = 0) THEN WITH licor_ptr^[id]^ DO BEGIN
        have := FALSE;
        FOR i := 1 TO nchcodes DO
          IF (code = chcode[i]) THEN have := TRUE;
        IF NOT have THEN BEGIN
          IF (nchcodes >= nchmax) THEN errcode := 5;
          IF (errcode = 0) THEN BEGIN
            INC (nchcodes);
            chcode[nchcodes] := code;
            value [nchcodes] := 6262;
            END;  {do it; number of max codes not exceeded}
          END;  {code not yet in list}
        END;  {fill code list in record}
      END;  {valid variable code}
    END;  {id in range}
  END;  {of procedure 'licor_addcode'}

PROCEDURE licor_model_set (id, channel: INTEGER; VAR errcode: INTEGER);
{Set which LiCor model this ID is}
BEGIN
  errcode := 0;
  IF (id < licor_addr_min) OR (id > licor_addr_max) THEN errcode := 1;
  IF (errcode = 0) THEN BEGIN
    IF (licor_ptr^[id] = NIL) THEN errcode := 3;
    IF (errcode = 0) THEN WITH licor_ptr^[id]^ DO BEGIN
      IF (model = 0) OR (model = channel)
        THEN model := channel
        ELSE errcode := 10;
      END;  {id allocated}
    END;  {id in range}
  END;  {of procedure 'licor_model_set'}

FUNCTION licor_getvalue (id, code: INTEGER; VAR errcode: INTEGER): REAL;
{Get a value (LiCor variable code) that has been read in}
VAR i, index: INTEGER;
BEGIN
  errcode := 0;
  index   := 0;
  IF (id < licor_addr_min) OR (id > licor_addr_max) THEN errcode := 1;
  IF (errcode = 0) THEN BEGIN
    IF (licor_ptr^[id] = NIL) THEN errcode := 3;
    IF (errcode = 0) THEN BEGIN
      IF NOT (Lo(code) IN valid_codes) THEN errcode := 4;
      IF (errcode = 0) THEN WITH licor_ptr^[id]^ DO BEGIN
        FOR i := 1 TO nchcodes DO IF (code = chcode[i]) THEN index := i;
        IF NOT (index IN [1..nchcodes]) THEN errcode := 5;
        END;
      END;  {record was allocated}
    END;  {id in range}
  IF (errcode = 0)
    THEN licor_getvalue := licor_ptr^[id]^.value[index]
    ELSE licor_getvalue := -(9990+errcode);
  END;  {of function 'licor_getvalue'}

PROCEDURE licor_clear (id: INTEGER);
{Set one selected or all (id < 0) read_yet to FALSE}
VAR i, mn, mx: INTEGER;
BEGIN
  IF id < 0
    THEN BEGIN mn := licor_addr_min;  mx := licor_addr_max;  END
    ELSE BEGIN mn := id;              mx := id;              END;
  FOR i := mn TO mx DO 
    IF (licor_ptr^[i] <> NIL) 
      THEN licor_ptr^[i]^.read_yet := FALSE;
  END;  {of procedure 'licor_clear'}

PROCEDURE licor_list (id: INTEGER; VAR msg: String);
{Construct the "Set print list" command for the LiCor 6252/6262}
VAR i: INTEGER;
    field: String[16];
BEGIN
  msg := '*13';
  WITH licor_ptr^[id]^ DO FOR i := 1 TO nchcodes DO BEGIN
    Str (chcode[i]:1, field);
    msg := msg + field;
    IF i <> nchcodes THEN msg := msg + ','
                     ELSE msg := msg;
    END;
  END;  {of procedure 'licor_list'}

PROCEDURE init_DS_6262 (id: INTEGER; VAR err: BOOLEAN);
{6252/6262 specific initialization through duTec}
VAR arg: String;
VAR cr: String;
BEGIN
  WITH licor_ptr^[id]^ DO BEGIN
    count_rest := 50;
    cr := '\';
    IF auto_print <= 0.0
      THEN arg := '0'
      ELSE Str (auto_print:4:2, arg);
    IF NOT err THEN BEGIN
      dutec_out (port, address, '*14'+arg+cr);  {auto print off}
      err := err OR optomux_var.error;
      END;
    IF NOT err THEN BEGIN
      dutec_out (port, address, '*150'+cr);     {auto header none}
      err := err OR optomux_var.error;
      END;
    licor_list (id, msg);                       {set up print list}
    IF NOT err THEN BEGIN
      dutec_out (port, address, msg+cr);
      err := err OR optomux_var.error;
      END;
    IF NOT err THEN BEGIN
      dutec_out (port, address, '*12');         {flush noise and buffers}
      err := err OR optomux_var.error;
      END;
    END; {with}
  END;  {of procedure 'init_DS_6262'}

PROCEDURE xml2dutec (id: INTEGER; cmd: String; VAR err: BOOLEAN);
{Apply needed escapes to xml and send to LI-8xx through duTec}
VAR rootbegin, rootend: String;
    msg, msg_escaped: String;
    i: INTEGER;
BEGIN
  IF licor_ptr^[id]^.model = 22 THEN BEGIN
    rootbegin := '<LI820>';  
    rootend   := '</LI820>';  
    END;
  IF licor_ptr^[id]^.model = 24 THEN BEGIN
    rootbegin := '<LI840>';  
    rootend   := '</LI840>';  
    END;
  IF licor_ptr^[id]^.model = 27 THEN BEGIN
    rootbegin := '<LI850>';  
    rootend   := '</LI850>';  
    END;

  msg := rootbegin + cmd + rootend;

  msg_escaped := '';
  FOR i := 1 TO Length(msg) DO BEGIN
         IF (ORD(msg[i]) = $0A) THEN msg_escaped := msg_escaped + '/0A' {LF}
    ELSE IF (ORD(msg[i]) = $0D) THEN msg_escaped := msg_escaped + '/0D' {CR}
    ELSE IF (ORD(msg[i]) = $2F) THEN msg_escaped := msg_escaped + '/2F' {/}
    ELSE IF (ORD(msg[i]) = $3E) THEN msg_escaped := msg_escaped + '/3E' {>}
    ELSE IF (ORD(msg[i]) = $5C) THEN msg_escaped := msg_escaped + '/5C' {\}
    ELSE                        msg_escaped := msg_escaped + msg[i];
    END;

  err := FALSE;
  WITH licor_ptr^[id]^ DO BEGIN
    dutec_out (port, address, msg_escaped + '/0A');
    err := err OR optomux_var.error;
{IF FALSE THEN BEGIN {removed for now...}
    IF NOT err THEN BEGIN
      dutec_in  (port, address, 'PP', msg);
      {err := err OR optomux_var.error;}
      END;
{END; {...removed for now}
    END; {with}
  END;  {of procedure 'xml2dutec'}

PROCEDURE init_DS_840 (id: INTEGER; VAR err: BOOLEAN);
{820/840 specific initialization through duTec
 }
BEGIN
  WITH licor_ptr^[id]^ DO BEGIN
    count_rest := 0;  {no resting}

    {Override _addcode results}
                         nchcodes := 4;  {LI820}
    IF (model in [24, 27]) THEN nchcodes := 5;  {LI840}
    chcode[1] := 42;  {Cell temperature oC}
    chcode[2] := 43;  {Cell pressure kPa}
    chcode[3] := 22;  {CO2 umol/mol=ppm}
    chcode[4] := 99;  {IVOLT}
    chcode[5] := 32;  {H2O mmol/mol=ppt}

{Comment out online configuration 2013-12-19 in SA...

    xml2dutec (id, '<RS232><CO2>TRUE</CO2></RS232>', err);
    xml2dutec (id, '<RS232><CO2ABS>FALSE</CO2ABS></RS232>', err);

  IF model = 24 THEN BEGIN
    xml2dutec (id, '<RS232><H2O>TRUE</H2O></RS232>', err);
    xml2dutec (id, '<RS232><H2ODEWPOINT>FALSE</H2ODEWPOINT></RS232>', err);
    xml2dutec (id, '<RS232><H2OABS>FALSE</H2OABS></RS232>', err);
    END;

    xml2dutec (id, '<RS232><CELLTEMP>TRUE</CELLTEMP></RS232>', err);
    xml2dutec (id, '<RS232><CELLPRES>TRUE</CELLPRES></RS232>', err);
    xml2dutec (id, '<RS232><IVOLT>TRUE</IVOLT></RS232>', err);
    xml2dutec (id, '<RS232><RAW>FALSE</RAW></RS232>', err);
    xml2dutec (id, '<RS232><ECHO>FALSE</ECHO></RS232>', err);
    xml2dutec (id, '<RS232><STRIP>TRUE</STRIP></RS232>', err);

    xml2dutec (id, '<CFG><OUTRATE>0.0</OUTRATE></CFG>', err);
    xml2dutec (id, '<CFG><HEATER>TRUE</HEATER></CFG>', err);
    xml2dutec (id, '<CFG><PCOMP>TRUE</PCOMP></CFG>', err);
    xml2dutec (id, '<CFG><FILTER>0</FILTER></CFG>', err);

...end commenting out}

    END; {with}
  END;  {of procedure 'init_DS_840'}

PROCEDURE licor_init (id: INTEGER; VAR errcode: INTEGER);
BEGIN
  err := FALSE;
  errcode := 0;
  IF id IN [licor_addr_min..licor_addr_max]
    THEN WITH licor_ptr^[id]^ DO BEGIN
      read_yet := FALSE;
      count_current := 0;
      IF daqc = 'SB' THEN BEGIN  {serial bios direct}
        END ELSE
      IF daqc = 'DS' THEN WITH optomux_var DO BEGIN
      {duTec DAQC using optomux/comm_dp4 communications drivers}
        power_up_clear (port, address);
        dutec_speed (port, address, speed);  {duTec port speed only}
        err := err OR optomux_var.error;
        CASE model OF
          21: init_DS_6262 (id, err);
          22,
          24,
		  27: init_DS_840  (id, err);
          END; {case}
        IF err THEN errcode := 12;          {optomux error has occurred}
        errcode_save := errcode;
        END ELSE
      IF daqc = licor_noinit THEN BEGIN
        errcode := 6;   {unit id has not been initialized}
        END ELSE
      errcode := 7;     {unrecognized daqc type}
      END
    ELSE errcode := 1;  {id out-of-range}
  END;  {procedure 'licor_init'}

PROCEDURE licor_parse (id: INTEGER; msg: String; VAR errcode: INTEGER);
{Put ascii fields into array of float}
CONST numeric = ['0'..'9','+','-','.','e','E'];
VAR i,j: INTEGER;
    field: String[16];
    valcode: INTEGER;
BEGIN
  i := 1;
  j := 0;
  WITH licor_ptr^[id]^ DO BEGIN
    WHILE (i <= Length(msg)) AND (j < nchcodes) DO BEGIN
      field := '';
      WHILE NOT (msg[i] IN numeric) DO INC(i);
      WHILE (i <= Length(msg)) AND (msg[i] IN numeric) DO BEGIN
        field := field + msg[i];
        INC(i);
        END;
      Val (field, value[j+1], valcode);
      IF (valcode <> 0) THEN errcode := 8;  {probably invalid character}
      {*** debugging -- replace by LiCor debugging, not Optomux
        IF optomux_debug AND (errcode = 8) THEN
          WRITELN (i:3, j+1:3, '\', msg, '\', field, '\');
        ***}
      INC (j);
      END;
    IF (errcode = 0) AND (j < nchcodes) THEN errcode := 9;     {too few}
    END;  {of with}
  END;  {of procedure 'licor_parse'}

PROCEDURE licor_read (id: INTEGER; VAR errcode: INTEGER);
VAR j: INTEGER;
    cmd: String;
BEGIN
  err := FALSE;
  errcode := 0;
  msg := '';
  IF id IN [licor_addr_min..licor_addr_max]
    THEN WITH licor_ptr^[id]^ DO BEGIN
      FOR j := 1 TO nchcodes DO value[j] := -888.0;
      IF daqc = 'SB' THEN BEGIN  {serial bios direct}
        END ELSE
      IF daqc = 'DS' THEN WITH optomux_var DO BEGIN
      {duTec DAQC using optomux/comm_tp4 communications drivers}
        IF auto_print <= 0.0 THEN BEGIN
          IF model IN [22,24,27] THEN REPEAT  {discard any trash -- LI8xx only}
            dutec_in (port, address, 'PP', msg);
            UNTIL (msg = '');
          CASE model OF
            21: cmd := '*12';
            22: cmd := '<LI820/3E<DATA/3E?</2FDATA/3E</2FLI820/3E/0A';
            24: cmd := '<LI840/3E<DATA/3E?</2FDATA/3E</2FLI840/3E/0A';
			27: cmd := '<LI850/3E<DATA/3E?</2FDATA/3E</2FLI850/3E/0A';
            END; {case}
          dutec_out (port, address, cmd);
          err := err OR optomux_var.error;
          END;
        IF (model IN [22,24,27]) THEN Windows.Sleep (100);
        dutec_in (port, address, 'P', msg);
        err := err OR optomux_var.error;
        IF NOT err
          THEN licor_parse (id, msg, errcode)
          ELSE errcode := 12;           {optomux error has occurred}
        END ELSE
      IF daqc = licor_noinit THEN BEGIN
        errcode := 6;   {unit id has not been initialized}
        END ELSE
      errcode := 7;     {unrecognized daqc type}
      errcode_save := errcode;
      END
    ELSE errcode := 1;  {id out-of-range}
  {*** Echo non-zero error code if optomux debug on ...
  --replace this by LiCor debugging, not Optomux
  IF optomux_debug AND (errcode <> 0) 
    THEN WRITELN ('Errcode = ',errcode:1, '  ', licor_errmsg[errcode]);
    ... move this line to enable/disable echo ***}
  END;  {procedure 'licor_read'}

PROCEDURE licor_input (id: INTEGER; VAR errcode: INTEGER);
{This procedure is an (optional) front porch for licor_read.
 It implements two features:
 (1) Not reading the LiCor every N'th sampling interval so that the
     LiCor program loop can get everything done occasionally, such
     as updating the cell temperature value.  Calling program has
     responsibility for setting .count_rest = N during initialization.
 (2) Checking to see if the LiCor has already been read this sampling
     interval.  Calling program has responsibility of calling
     licor_clear() at beginning of sampling procedure.
 Both features depend on data in buffer and flags being undisturbed.}
BEGIN
  WITH licor_ptr^[id]^ DO
    IF NOT read_yet
      THEN IF (count_current <= count_rest)
        THEN BEGIN
          licor_read (id, errcode);
          read_yet := TRUE;
          IF (count_rest > 0) THEN INC (count_current);
          END
        ELSE BEGIN
          count_current := 0;
          read_yet      := TRUE;
          errcode       := errcode_save;
          END
      ELSE BEGIN  {get previously read values}
        errcode := errcode_save;
        END;
  END;  {procedure 'licor_input'}

PROCEDURE licor_show  (id: INTEGER);
{Displays status and contents of licor records.}
VAR i, j: INTEGER;
    colorsave: INTEGER;
BEGIN
  ClrScr;
  IF (id < 0) THEN BEGIN  {show matrix of allocated licor records}
    WRITELN ('MATRIX SHOWING ACTIVE LICOR RECORDS');
    WRITELN;
    colorsave := TextAttr;
    TextColor (Yellow);
    WRITE (' ':10);
    FOR i := 0 TO $F DO WRITE (' x', word2hex(i,2,2):2);
    WRITELN;
    FOR j := 0 TO $F DO BEGIN
      IF ((j MOD 4) = 0) THEN WRITELN;
      TextColor (Yellow);
      WRITE ('x', word2hex(16*j,2,2), ' ':7);
      FOR i := 0 TO $F DO
        IF (licor_ptr^[16*j+i] <> NIL) 
          THEN BEGIN TextColor (LightRed);   WRITE ('X':4); END
          ELSE BEGIN TextColor (LightGreen); WRITE ('-':4); END;
      WRITELN;
      END;
    TextColor (colorsave);
    END;
  IF (id >= licor_addr_min) AND (id <= licor_addr_max) THEN BEGIN
    WRITELN ('CONTENTS OF SELECTED LICOR RECORD');
    WRITELN;
    IF (licor_ptr^[id] <> NIL) THEN WITH licor_ptr^[id]^ DO BEGIN
      WRITELN ('DAQC TYPE:    ', daqc:8);
      WRITELN ('PORT:         ', port:8);
      WRITELN ('ADDRESS:      ', word2hex(address,2,4):8, 'h  =', address:3);
      WRITELN ('SPEED:        ', speed:8);
      WRITELN ('MODEL:        ', model:8);
      WRITELN ('AUTO PRINT:   ', auto_print:8:2);
      WRITELN ('READ YET:     ', read_yet:8);
      WRITELN ('N CODES:      ', nchcodes:8);
      WRITE   ('CODE:         ');
        FOR i := 1 TO nchcodes DO WRITE (chcode[i]:8);
        WRITELN;
      WRITE   ('VALUE:        ');
        FOR i := 1 TO nchcodes DO WRITE (value[i]:8:2);
        WRITELN;
      WRITELN ('COUNT REST:   ', count_rest:8);
      WRITELN ('COUNT CURRENT:', count_current:8);
      WRITELN ('LAST ERRCODE: ', errcode_save:8);
      WRITELN ('LAST MESSAGE: ', licor_errmsg[errcode_save]);
      END
      ELSE WRITELN ('RECORD AT ADDRESS ', word2hex(id,2,2):2,
                    'h NOT YET ALLOCATED!');
    END;
  END;  {procedure 'licor_show'}

{initialization of unit}

VAR i: INTEGER;
BEGIN
  NEW (licor_ptr);
  FOR i := 0 TO 255 DO
    licor_ptr^[i] := NIL;
  {of unit 'licor'...}
  END.
